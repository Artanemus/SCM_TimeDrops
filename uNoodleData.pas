
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

    function InsertNData(const Noodle: TNoodle): integer;
    function GetRefID(const Noodle: TNoodle; const Bank, Lane: integer): integer;
    function LocateToRecord(const Bank, Lane: integer): boolean;

    procedure DeleteNData(Noodle: TNoodle);
    procedure UpdateNData(Noodle: TNoodle);
    function AssignNDataToNoodle(var Noodle: TNoodle): boolean;

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

function TNoodleData.AssignNDataToNoodle(var Noodle: TNoodle): boolean;
var
  HandlePtr: TNoodleHandleP;
begin
  // ASSUMPTION : TABLE SYNC.

  if (not TDS.DataIsActive) or (TDS.tblmHeat.IsEmpty)
     or (TDS.tblmNoodle.IsEmpty) then
    begin
      Noodle.NDataID := 0;
      result := false;
      exit;
    end;

  Noodle.NDataID := TDS.tblmNoodle.FieldByName('NoodleID').AsInteger;
  HandlePtr := Noodle.GetHandlePtr(0);
  HandlePtr.Lane := TDS.tblmNoodle.FieldByName('SCMLane').AsInteger;
	HandlePtr.Bank := 0;
	// ID's used to display NoodleInfo. (AND query other table data)
	HandlePtr.HeatID := TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger;
	HandlePtr := Noodle.GetHandlePtr(1);
	HandlePtr.Lane := TDS.tblmNoodle.FieldByName('TDSLane').AsInteger;
	HandlePtr.Bank := 1;
	HandlePtr.HeatID := TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger;
	result := true;

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

function TNoodleData.GetRefID(const Noodle: TNoodle; const Bank, Lane:
    integer): integer;
var
  TDSHeatID, RefID: integer;
  EventType: scmEventType;
begin
  result := 0;
  RefID := 0;
  case Bank of
  0:
    begin
      EventType := SCM.GetEventType(SCM.qryEvent.FieldByName('EventID').AsInteger);
      if SCM.LocateLaneNum(Lane, EventType) then
      begin
        if EventType = etINDV then
          RefID := SCM.qryINDV.FieldByName('EntrantID').AsInteger
        else
          RefID := SCM.qryTEAM.FieldByName('TeamID').AsInteger;
      end;
    end;
  1:
    begin
      TDSHeatID :=  TDS.tblmHeat.FieldByName('HeatID').AsInteger;
      if TDS.LocateTLaneNum(TDSHeatID, Lane) then
        RefID := TDS.tblmLane.FieldByName('LaneID').AsInteger;
    end;
  end;
  if RefID <> 0 then result := RefID;

end;

function TNoodleData.InsertNData(const Noodle: TNoodle): integer;
var
  AID: Integer;
  HandlePtr: TNoodleHandleP;
begin
  result := 0;
  // no data or no heats, or no lanes.
  if (not TDS.DataIsActive) or (TDS.tblmHeat.IsEmpty) then exit;
  if (not SCM.DataIsActive) or (SCM.qryHeat.IsEmpty) then exit;

  AID := GetMaxID();

  // NOTE: Handles will ONLY have RectF, Bank and Lane data.
  // TABLE DATA for the Handles is done here.

  TDS.tblmNoodle.Insert;
  TDS.tblmNoodle.FieldByName('NoodleID').AsInteger := AID + 1;

  // SCM TABLE DATA -
  TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger :=
    SCM.qryHeat.FieldByName('HeatID').AsInteger;
  HandlePtr := Noodle.GetHandlePtr(0);
  TDS.tblmNoodle.FieldByName('SCMLane').AsInteger := HandlePtr.Lane;

  // TDS TABLE DATA -
  TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger :=
    TDS.tblmHeat.FieldByName('HeatID').AsInteger;
  // lane number.
  HandlePtr := Noodle.GetHandlePtr(1);
  TDS.tblmNoodle.FieldByName('TDSLane').AsInteger := HandlePtr.Lane;

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

function TNoodleData.LocateToRecord(const Bank, Lane: integer): Boolean;
var
  HeatID: integer;
  EventType: scmEventType;
begin
  result := false;
  case Bank of
    0:
      begin
        EventType :=
        SCM.GetEventType(SCM.qryEvent.FieldByName('EventID').AsInteger);
        if SCM.LocateLaneNum(Lane, EventType) then
          result := true;
      end;
    1:
      begin
        HeatID := TDS.tblmHeat.FieldByName('HeatID').AsInteger;
        if TDS.LocateTLaneNum(HeatID, Lane) then
          result := true;
      end;
	end;
end;

procedure TNoodleData.UpdateNData(Noodle: TNoodle);
var
  found: boolean;
  HandlePtr: TNoodleHandleP;
begin
  // ASSUMPTION : TABLES are sync with TPaintBox HotSpots.
  if TDS.tblmNoodle.IsEmpty then exit;
  if Noodle.NDataID = 0 then exit;
  found := true;

  if (TDS.tblmNoodle.FieldByName('NoodleID').AsInteger <> Noodle.NDataID) then
		found := TDS.Locate_NoodleID(Noodle.NDataID);

  if found then
  begin
    try
      TDS.tblmNoodle.Edit;
      HandlePtr := Noodle.GetHandlePtr(0);
      TDS.tblmNoodle.FieldByName('SCMHeatID').AsInteger :=
        SCM.qryHeat.FieldByName('HeatID').AsInteger;
      TDS.tblmNoodle.FieldByName('SCMLane').AsInteger := HandlePtr.Lane;
      HandlePtr := Noodle.GetHandlePtr(1);
      TDS.tblmNoodle.FieldByName('TDSHeatID').AsInteger :=
        TDS.tblmHeat.FieldByName('HeatID').AsInteger;
      TDS.tblmNoodle.FieldByName('TDSLane').AsInteger := HandlePtr.Lane;
      TDS.tblmNoodle.Post;
    except
      on E: Exception do
        TDS.tblmNoodle.Cancel;
    end;
  end;
end;

procedure TNoodleData.DeleteNData(Noodle: TNoodle);
var
  found: boolean;
begin
  // ASSUMPTION : TABLES are sync with TPaintBox HotSpots.
  if TDS.tblmNoodle.IsEmpty then exit;
  if Noodle.NDataID = 0 then exit;
  found := true;
  if (TDS.tblmNoodle.FieldByName('NoodleID').AsInteger <> Noodle.NDataID) then
		found := TDS.Locate_NoodleID(Noodle.NDataID);
  if found then
  begin
    TDS.tblmNoodle.Delete;
  end;
end;

end.
