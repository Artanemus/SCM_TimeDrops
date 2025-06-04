
(*
Following TABLE DATA is held in TNoodle -

TNoodle.FNDataID = dmTDS.tblmNoodle.NoodleID.


TABEL FIELD ASSIGNMENT FOR dmTDS.tblmNoodle

dmTDS.tblmNoodle.SCMHeatID -
 - (SCM) SwimClubMeet.dbo.HeatIndividual.HeatID.

dmTDS.tblmNoodle.TDSHeatID -
 - (TDS) dmTDS.tblmHeat.HeatID.

dmTDS.tblmNoodle.SCMRefID.
 - (SCM - EventTypeID = 1) SwimClubMeet.dbo.Entrant.Lane.
 - (SCM - EventTypeID = 2) SwimClubMeet.dbo.Team.Lane.

dmTDS.tblmNoodle.TDSRefID -
 - (TDS) dmTDS.tblmLane.LaneID.

*)



unit uNoodleData;
interface
uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Data.DB, System.UITypes,
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

    property Synced: Boolean read FSynced write FSynced;
  end;

var
  NoodleData: TNoodleData;

implementation

uses
  vcl.Dialogs;

procedure TNoodleData.NoodleCreatedByFrame(Sender: TObject; Noodle: TNoodle);
//var
//EventType: scmEventType;
//B1, B2: boolean;
begin
(*
  // Assert: In sync with noodle selection.
  EventType := SCM.GetEventType(SCM.qryEvent.FieldByName('EventID').AsInteger);
  B1 := SCM.LocateLaneNum(Noodle.GetHandlePtr(0).Lane, EventType);
  B2 := TDS.LocateTLaneNum(TDS.tblmHeat.FieldByName('HeatID').AsInteger,Noodle.GetHandlePtr(1).Lane);
  // was syncronization successful -
  if B1 and B2 then
*)
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
  // ASSUMPTION : TABLES are sync with TPaintBox HotSpots.

  if (not TDS.DataIsActive) or (TDS.tblmHeat.IsEmpty)
     or (TDS.tblmNoodle.IsEmpty) then exit;

  Noodle.NDataID := TDS.tblmNoodle.FieldByName('NoodleID').AsInteger;

  HandlePtr := Noodle.GetHandlePtr(0);
  HandlePtr.Lane := TDS.tblmNoodle.FieldByName('SCMLane').AsInteger;
  HandlePtr.Bank := 0;
  HandlePtr := Noodle.GetHandlePtr(1);
  HandlePtr.Lane := TDS.tblmNoodle.FieldByName('TdsLane').AsInteger;
  HandlePtr.Bank := 1;

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
  EventType: scmEventType;
  LaneNum: integer;
begin
  result := 0;
  LaneNum := 0;
  // no data or no heats, or no lanes.
  if (not TDS.DataIsActive) or (TDS.tblmHeat.IsEmpty) then exit;

  AID := GetMaxID();

  // NOTE: Handles will ONLY have RectF, Bank and Lane data.
  // TABLE DATA for the Handles is done here.

  TDS.tblmNoodle.Insert;
  TDS.tblmNoodle.FieldByName('NoodleID').AsInteger := AID + 1;

  // SCM TABLE DATA -
  TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger :=
    SCM.qryHeat.FieldByName('HeatID').AsInteger; // SwimClubMeet.dbo.HeatIndividual.HeatID.
  // Reference data to Swimmer (EntrantID) or TEAM.
  EventType := SCM.GetEventType(SCM.qryEvent.FieldByName('EventID').AsInteger);
  // CHECKS
  case EventType of
    scmEventType.etINDV:
    begin
      TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger :=
        SCM.qryINDV.FieldByName('EntrantID').AsInteger;
      LaneNum := SCM.qryINDV.FieldByName('Lane').AsInteger;
    end;
    scmEventType.etTEAM:
    begin
      TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger :=
        SCM.qryTEAM.FieldByName('TeamID').AsInteger;
      LaneNum := TDS.tblmLane.FieldByName('Lane').AsInteger;
    end;
  end;

  // lane number.
  HandlePtr := Noodle.GetHandlePtr(0);
  if HandlePtr.Lane = LaneNum then
    TDS.tblmNoodle.FieldByName('SCMLane').AsInteger := HandlePtr.Lane
  else
  begin
    MessageDlg('Lane number mismatch.', mtInformation, [mbOK], 0);
    TDS.tblmNoodle.FieldByName('SCMLane').AsInteger := LaneNum;
  end;

  // TDS TABLE DATA -
  TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger := TDS.tblmHeat.FieldByName('HeatID').AsInteger;
  TDS.tblmNoodle.FieldByName('TDSRefID').AsInteger  := TDS.tblmLane.FieldByName('LaneID').AsInteger;
  // lane number.
  HandlePtr := Noodle.GetHandlePtr(1);
  if HandlePtr.Lane = TDS.tblmLane.FieldByName('LaneNum').AsInteger then
    TDS.tblmNoodle.FieldByName('TDSLane').AsInteger := HandlePtr.Lane
  else
  begin
    MessageDlg('Lane number mismatch.', mtInformation, [mbOK], 0);
    TDS.tblmNoodle.FieldByName('SCMLane').AsInteger := LaneNum;
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
  found: boolean;
  HandlePtr: TNoodleHandleP;
  EventType: scmEventType;
begin
  // ASSUMPTION : TABLES are sync with TPaintBox HotSpots.
  if TDS.tblmNoodle.IsEmpty then exit;
  if Noodle.NDataID = 0 then exit;
  found := false;

  if (TDS.tblmNoodle.FieldByName('NoodleID').AsInteger <> Noodle.NDataID) then
    found := TDS.LocateTNoodle(Noodle.NDataID);

  if found then
  begin
    HandlePtr := Noodle.GetHandlePtr(0);
    TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger := SCM.qryHeat.FieldByName('HeatID').AsInteger;
    TDS.tblmNoodle.FieldByName('SCMLane').AsInteger := HandlePtr.Lane;
    // Find the SCMRefID - dependant on the event type.
    EventType := SCM.GetEventType(SCM.qryEvent.FieldByName('EventID').AsInteger);
    if EventType = etINDV then
      TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger := SCM.qryINDV.FieldByName('EntrantID').AsInteger
    else
      TDS.tblmNoodle.FieldByName('SCMRefID').AsInteger := SCM.qryTEAM.FieldByName('TeamID').AsInteger;

    HandlePtr := Noodle.GetHandlePtr(1);
    TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger := TDS.tblmHeat.FieldByName('HeatID').AsInteger;
    TDS.tblmNoodle.FieldByName('TDSRefID').AsInteger := TDS.tblmLane.FieldByName('LaneID').AsInteger;
    TDS.tblmNoodle.FieldByName('TDSLane').AsInteger := HandlePtr.Lane;
  end;
end;

procedure TNoodleData.DeleteNData(Noodle: TNoodle);
var
  found: boolean;
begin
  // ASSUMPTION : TABLES are sync with TPaintBox HotSpots.
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

end.


