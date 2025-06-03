unit uNoodleData;
interface
uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uNoodle, dmTDS, dmSCM, SCMDefines;
type
  TNoodleData = class
  private
    FSynced: Boolean;
    function GetMaxID(): integer;

  public
    constructor Create;
    destructor Destroy; override;

    function InsertNData(Noodle: TNoodle): integer;

    procedure DeleteNData(Noodle: TNoodle);
    procedure UpdateNData(Noodle: TNoodle);
    procedure AssignNDataToNoodle(Noodle: TNoodle);

    procedure NoodleCreatedByFrame(Sender: TObject; Noodle: TNoodle);
    procedure NoodleDeletedByFrame(Sender: TObject; Noodle: TNoodle);
    procedure NoodleUpdatedByFrame(Sender: TObject; Noodle: TNoodle);


//    procedure UpdateTblData; overload;
//    procedure UpdateTblData(const RefNoodle: TNoodle); overload;
//    procedure UpdateTblData(const RefHandlePtr: TNoodleHandleP); overload;
//    function SyncTblToNoodle(Noodle: TNoodle): boolean;
//    function SyncNoodleToTbl(Noodle: TNoodle): boolean;
//    function CheckSyncTblWithNoodle(RefNoodle: TNoodle): boolean;

    property Synced: Boolean read FSynced write FSynced;
  end;

var
  NoodleData: TNoodleData;

implementation

uses
  vcl.Dialogs;

procedure TNoodleData.NoodleCreatedByFrame(Sender: TObject; Noodle: TNoodle);
begin
  Noodle.NDataID := InsertNData(Noodle);
end;

procedure TNoodleData.NoodleDeletedByFrame(Sender: TObject; Noodle: TNoodle);
begin
  DeleteNData(Noodle);
end;

procedure TNoodleData.NoodleUpdatedByFrame(Sender: TObject; Noodle: TNoodle);
begin
  UpdateNData(Noodle);
end;

procedure TNoodleData.AssignNDataToNoodle(Noodle: TNoodle);
var
  HandlePtr: TNoodleHandleP;
begin
  if (not TDS.DataIsActive) or (TDS.tblmHeat.IsEmpty)
     or (TDS.tblmNoodle.IsEmpty) then exit;

  Noodle.NDataID := TDS.tblmNoodle.FieldByName('NoodleID').AsInteger;

  HandlePtr := Noodle.GetHandlePtr(0);
  HandlePtr.HeatID := TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger;
  HandlePtr.RefID := TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger;
  HandlePtr.Lane := TDS.tblmNoodle.FieldByName('SCMLane').AsInteger;
  HandlePtr := Noodle.GetHandlePtr(1);
  HandlePtr.HeatID := TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger;
  HandlePtr.RefID := TDS.tblmNoodle.FieldByName('TDSRefID').AsInteger;
  HandlePtr.Lane := TDS.tblmNoodle.FieldByName('TdsLane').AsInteger;

end;

constructor TNoodleData.Create;
begin
  FSynced := True; // Initially, no noodles are present, so we consider it synced;
end;
destructor TNoodleData.Destroy;
begin
  // Cleanup code if necessary
  inherited Destroy;
end;


function TNoodleData.GetMaxID: integer;
begin
  //  TDS.DisableTDMasterDetail;
  TDS.tblmNoodle.MasterSource := nil;
  TDS.tblmNoodle.MasterFields := '';
  TDS.tblmNoodle.DetailFields := '';
  TDS.tblmNoodle.IndexFieldNames := 'NoodleID';
  // Get the MAX (last) unique identifier.
  result := TDS.MaxID_Noodle;
  //  TDS.EnableTDMasterDetail;
  TDS.tblmNoodle.MasterSource := TDS.dsmHeat;
  TDS.tblmNoodle.MasterFields := 'HeatID';
  TDS.tblmNoodle.DetailFields := 'HeatID';
  TDS.tblmNoodle.IndexFieldNames := 'HeatID';
  TDS.tblmNoodle.ApplyMaster;
end;

function TNoodleData.InsertNData(Noodle: TNoodle): integer;
var
  AID: Integer;
  HandlePtr: TNoodleHandleP;
begin
  result := 0;
  // no data or no heats, or no lanes.
  if (not TDS.DataIsActive) or (TDS.tblmHeat.IsEmpty) then exit;
  AID := GetMaxID();

  TDS.tblmNoodle.Insert;
  TDS.tblmNoodle.FieldByName('NoodleID').AsInteger := AID + 1;

  HandlePtr := Noodle.GetHandlePtr(0);
  if SCM.qryHeat.FieldByName('HeatID').AsInteger = HandlePtr.HeatID then
  begin
    TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger :=
      SCM.qryHeat.FieldByName('HeatID').AsInteger; // SwimClubMeet.dbo.HeatIndividual.HeatID.
  end else
  begin
    TDS.tblmNoodle.FieldByName('HeatID').AsInteger := HandlePtr.HeatID;
    MessageDlg('DeSync - HandlePtr.SCMHeatID <> SCM.qryHeat.HeatID...', mtInformation, [mbOK], 0);
  end;
  TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger := HandlePtr.RefID; // EntrantID/TEAMID.
  TDS.tblmNoodle.FieldByName('SCMLane').AsInteger := HandlePtr.Lane; // lane number.

  HandlePtr := Noodle.GetHandlePtr(1);
  TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger := HandlePtr.HeatID; // dmTDS.tblmHeat.HeatID.
  TDS.tblmNoodle.FieldByName('TDSRefID').AsInteger := HandlePtr.RefID;  // dmTDS.tblmLane.LaneID.
  TDS.tblmNoodle.FieldByName('TDSLane').AsInteger := HandlePtr.Lane; // lane number.

  // Should be identical to Noodle.Handle[1].HeatID.
  if TDS.tblmHeat.FieldByName('HeatID').AsInteger = HandlePtr.HeatID then
  begin
    TDS.tblmNoodle.FieldByName('HeatID').AsInteger :=
      TDS.tblmHeat.FieldByName('HeatID').AsInteger; // Master/Detail relationship.
  end
  else
  begin
    TDS.tblmNoodle.FieldByName('HeatID').AsInteger := HandlePtr.HeatID;
    MessageDlg('DeSync - HandlePtr.TDSHeatID <> TDS.tblmHeat.HeatID...', mtInformation, [mbOK], 0);
  end;

  // Write out the Noodle out.
  try
    TDS.tblmNoodle.Post;
  except
    on E: Exception do
    begin
      TDS.tblmNoodle.Cancel;
      result := 0;
      exit;
    end;
  end;
  result := TDS.tblmNoodle.FieldByName('NoodleID').AsInteger; // (AID+1).
end;

procedure TNoodleData.UpdateNData(Noodle: TNoodle);
var
  AID: Integer;
  found: boolean;
  HandlePtr: TNoodleHandleP;
begin
  if TDS.tblmNoodle.IsEmpty then exit;
  if Noodle.NDataID = 0 then exit;
  found := false;

  if (TDS.tblmNoodle.FieldByName('NoodleID').AsInteger <> Noodle.NDataID) then
    found := TDS.LocateTNoodle(Noodle.NDataID);

  if found then
  begin
    HandlePtr := Noodle.GetHandlePtr(0);
    TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger := HandlePtr.HeatID;
    TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger := HandlePtr.RefID;
    TDS.tblmNoodle.FieldByName('SCMLane').AsInteger := HandlePtr.Lane;
    HandlePtr := Noodle.GetHandlePtr(1);
    TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger := HandlePtr.HeatID;
    TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger := HandlePtr.RefID;
    TDS.tblmNoodle.FieldByName('TdsLane').AsInteger := HandlePtr.Lane;
  end;
end;

procedure TNoodleData.DeleteNData(Noodle: TNoodle);
var
  found: boolean;
begin
  // Code to handle the deletion of a noodle link
  // This could involve removing it from a list or database
  if TDS.tblmNoodle.IsEmpty then exit;
  if Noodle.NDataID = 0 then exit;
  found := false;

  if (TDS.tblmNoodle.FieldByName('NoodleID').AsInteger <> Noodle.NDataID) then
    found := TDS.LocateTNoodle(Noodle.NDataID);

  if found then
  begin
    TDS.tblmNoodle.Delete;
  end;

end;


(*
  function TNoodleData.InsertNData: integer;
  var
    AID: Integer;
    EventType: scmEventType;
  begin
    result := 0;
    // no data or no heats, or no lanes.
    if (not TDS.DataIsActive) or (TDS.tblmHeat.IsEmpty)
      or (TDS.tblmLane.IsEmpty) then exit;

    AID := GetMaxID();


    TDS.tblmNoodle.Insert;
    TDS.tblmNoodle.FieldByName('NoodleID').AsInteger := AID + 1;
    TDS.tblmNoodle.FieldByName('HeatID').AsInteger :=
      TDS.tblmHeat.FieldByName('HeatID').AsInteger; // Master/Detail.

    // BANK 0 - HANDLE DATA.
    TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger :=
      SCM.qryHeat.FieldByName('HeatID').AsInteger;

    EventType := SCM.GetEventType(SCM.qryHeat.FieldByName('EventID').AsInteger);
    // Are we looking at a team event of an individual event?
    if EventType = scmEventType.etINDV then
    begin
      TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger :=
        SCM.qryINDV.FieldByName('EntrantID').AsInteger;
      TDS.tblmNoodle.FieldByName('SCMLane').AsInteger :=
        SCM.qryINDV.FieldByName('Lane').AsInteger;
    end
    else
    begin
      TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger :=
        SCM.qryTEAM.FieldByName('TeamID').AsInteger;
      TDS.tblmNoodle.FieldByName('SCMLane').AsInteger :=
        SCM.qryTEAM.FieldByName('Lane').AsInteger;
    end;

  //    TDS.tblmNoodle.FieldByName('SCMHeatID').Clear;
  //    TDS.tblmNoodle.FieldByName('SCMRefID').Clear;

    // BANK 1 - HANDLE DATA.
      TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger :=
        TDS.tblmLane.FieldByName('HeatID').AsInteger;
      TDS.tblmNoodle.FieldByName('TDSRefID').AsInteger :=
        TDS.tblmLane.FieldByName('LaneID').AsInteger;
      TDS.tblmNoodle.FieldByName('TDSLane').AsInteger :=
        TDS.tblmLane.FieldByName('LaneNum').AsInteger;

  //    TDS.tblmNoodle.FieldByName('TDSHeatID').Clear;
  //    TDS.tblmNoodle.FieldByName('TDSRefID').Clear;
  //    TDS.tblmNoodle.FieldByName('TDSLane').Clear;

    // Write out the Noodle out.
    try
      TDS.tblmNoodle.Post;
    except
      on E: Exception do
      begin result := 0; exit; end;
    end;

    result := TDS.tblmNoodle.FieldByName('NoodleID').AsInteger; // (AID+1).

  end;
*)


(*
  procedure TNoodleData.UpdateTblData(const RefNoodle: TNoodle);
  var
    HandlePtr: TNoodleHandleP;
  begin
    // RefNoodle and TABLES are correctly parked. (In Sync).
    SyncTblToNoodle(RefNoodle);
    UpdateTblData(); // NoodleData ALWAYS references TDS Tables.
  end;
*)

(*
  function TNoodleData.CheckSyncTblWithNoodle(RefNoodle: TNoodle): boolean;
  var
    HandlePtr: TNoodleHandleP;
    EventType: scmEventType;
  begin
    result := false;
    FSynced := false; // Set State.

    if SCM.DataIsActive and TDS.DataIsActive then
    begin
      HandlePtr := RefNoodle.GetHandlePtr(0); // Bank0.
      if SCM.qryHeat.FieldByName('HeatID').AsInteger <> HandlePtr.HeatID then exit;

      EventType := SCM.GetEventType(SCM.qryHeat.FieldByName('EventID').AsInteger);
      // CHECKS
      case EventType of
        scmEventType.etINDV:
          begin
            if SCM.qryINDV.FieldByName('EntrantID').AsInteger <> HandlePtr.RefID
              then exit;
          end;
        scmEventType.etTEAM:
          begin
            if SCM.qryTEAM.FieldByName('TeamID').AsInteger <> HandlePtr.RefID
              then exit;
          end;
      end;

      HandlePtr := RefNoodle.GetHandlePtr(1); // Bank0.
      if TDS.tblmHeat.FieldByName('HeatID').AsInteger <> HandlePtr.HeatID then exit;
      if TDS.tblmLane.FieldByName('LaneID').AsInteger <> HandlePtr.RefID then exit;

      FSynced := true; // Set State.
      result := true;
    end;

  end;
*)

(*
  function TNoodleData.SyncNoodleToTbl(Noodle: TNoodle): boolean;
  var
    HandlePtr: TNoodleHandleP;
    EventType: scmEventType;
  begin
    result := false;

    EventType := SCM.GetEventType(SCM.qryHeat.FieldByName('EventID').AsInteger);
    HandlePtr := Noodle.GetHandlePtr(0); // Bank 0.
    case EventType of
      scmEventType.etINDV:
        begin
          HandlePtr.RefID := SCM.qryINDV.FieldByName('EntrantID').AsInteger;
          HandlePtr.Lane := SCM.qryINDV.FieldByName('Lane').AsInteger;
          HandlePtr.Bank := 0;
        end;
      scmEventType.etTEAM:
        begin
          HandlePtr.RefID := SCM.qryTEAM.FieldByName('TeamID').AsInteger;
          HandlePtr.Lane := SCM.qryTeam.FieldByName('Lane').AsInteger;
          HandlePtr.Bank := 0;
        end;
    end;
    //  HandlePtr.RectF :=


    HandlePtr := Noodle.GetHandlePtr(1); // Bank0.
    HandlePtr.RefID := TDS.tblmNoodle.FieldByName('TDSRefID').AsInteger;
    HandlePtr.HeatID := TDS.tblmHeat.FieldByName('HeatID').AsInteger;
    HandlePtr.Lane := TDS.tblmNoodle.FieldByName('LaneNum').AsInteger;
    HandlePtr.Bank := 1;
    //  HandlePtr.RectF :=
  end;
*)

(*
  function TNoodleData.SyncTblToNoodle(Noodle: TNoodle): boolean;
  var
    HandlePtr: TNoodleHandleP;
    EventType: scmEventType;
    chk1, chk2: boolean;
  begin
    result := false;
    chk1 := false;
    chk2 := false;

    HandlePtr := Noodle.GetHandlePtr(0); // Bank0.
    SCM.LocateHeatID(HandlePtr.HeatID);
    EventType := SCM.GetEventType(SCM.qryHeat.FieldByName('EventID').AsInteger);
    if SCM.LocateLaneNum(HandlePtr.Lane, EventType) then
    begin
      // CHECKS
      case EventType of
        scmEventType.etINDV:
          begin
            if SCM.qryINDV.FieldByName('EntrantID').AsInteger = HandlePtr.RefID
              then
              chk1 := true;
          end;
        scmEventType.etTEAM:
          begin
            if SCM.qryTEAM.FieldByName('TeamID').AsInteger = HandlePtr.RefID then
              chk1 := true;
          end;
      end;
    end;
    HandlePtr := Noodle.GetHandlePtr(1); // Bank0.
    TDS.LocateTHeatID(HandlePtr.HeatID);
    if TDS.LocateTLaneID(HandlePtr.Lane) then
    begin
      // CHECKS
      if TDS.tblmNoodle.FieldByName('TDSRefID').AsInteger = HandlePtr.RefID then
        chk2 := true;
    end;
    if chk1 and chk2 then result := true;
  end;
*)

(*
  procedure TNoodleData.UpdateTblData(const RefHandlePtr: TNoodleHandleP);
  var
    EventType: scmEventType;
  begin
    case RefHandlePtr.Bank of
    0:
      begin
        SCM.LocateHeatID(RefHandlePtr.HeatID);
        EventType := SCM.GetEventType(SCM.qryHeat.FieldByName('EventID').AsInteger);
        SCM.qryINDV.ApplyMaster;
        SCM.qryTEAM.ApplyMaster;
        SCM.LocateLaneNum(RefHandlePtr.Lane, EventType);
      end;
    1:
      begin
        TDS.LocateTHeatID(RefHandlePtr.HeatID);
        TDS.tblmLane.ApplyMaster;
        TDS.LocateTLaneID(RefHandlePtr.Lane);
      end;
    end;

    TDS.tblmNoodle.ApplyMaster;
    TDS.LocateTNoodle(RefHandlePtr.Lane);
  end;
*)

(*
  procedure TNoodleData.UpdateTblData;
  var
    EventType: scmEventType;
  begin

    // ADDITIONAL CHECK : SYNCED ?
    // if FSynced then begin end;

    if TDS.DataIsActive then
    begin
      // Master/Detail broken? ... is this checkredundant?
      if TDS.tblmNoodle.FieldByName('HeatID').AsInteger <>
        TDS.tblmHeat.FieldByName('HeatID').AsInteger then
      begin
        // Assert Master / Detail. ???
        TDS.tblmNoodle.FieldByName('HeatID').AsInteger :=
          TDS.tblmHeat.FieldByName('HeatID').AsInteger;
        TDS.tblmNoodle.ApplyMaster;
      end;

      EventType := SCM.GetEventType(SCM.qryHeat.FieldByName('EventID').AsInteger);
      // What type of event is this.
      if EventType = scmEventType.etINDV then
      begin
        TDS.tblmNoodle.FieldByName('SCMLane').AsInteger :=
          SCM.qryINDV.FieldByName('Lane').AsInteger;
        TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger :=
          SCM.qryINDV.FieldByName('HeatID').AsInteger;
        TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger :=
          SCM.qryINDV.FieldByName('EntrantID').AsInteger;
      end
      else
      begin
        TDS.tblmNoodle.FieldByName('SCMLane').AsInteger :=
          SCM.qryTEAM.FieldByName('Lane').AsInteger;
        TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger :=
          SCM.qryTEAM.FieldByName('HeatID').AsInteger;
        TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger :=
          SCM.qryTEAM.FieldByName('TeamID').AsInteger;
      end;

      TDS.tblmNoodle.FieldByName('TDSLane').AsInteger :=
        TDS.tblmLane.FieldByName('Lane').AsInteger;
      TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger :=
        TDS.tblmLane.FieldByName('HeatID').AsInteger;
      TDS.tblmNoodle.FieldByName('TDSRefID').AsInteger :=
        TDS.tblmLane.FieldByName('LaneID').AsInteger;
    end;

  end;
*)

end.


