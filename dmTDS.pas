unit dmTDS;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection, SCMDefines, Windows, Winapi.Messages, vcl.Forms,
  FireDAC.Phys.SQLiteVDataSet, Datasnap.DBClient, FireDAC.Stan.StorageXML,
  FireDAC.Stan.StorageBin, FireDAC.Stan.Storage, Datasnap.Provider, uWatchTime,
  AbZipper, AbBase, AbBrowse, AbZBrows, AbZipKit, system.zip;


type

  TTDS = class(TDataModule)
		dsmEvent: TDataSource;
		dsmHeat: TDataSource;
		dsmLane: TDataSource;
		dsmNoodle: TDataSource;
		dsmSession: TDataSource;
		FDStanStorageBinLink1: TFDStanStorageBinLink;
		FDStanStorageXMLLink1: TFDStanStorageXMLLink;
		tblmEvent: TFDMemTable;
		tblmHeat: TFDMemTable;
		tblmLane: TFDMemTable;
		tblmNoodle: TFDMemTable;
		tblmSession: TFDMemTable;
		procedure DataModuleCreate(Sender: TObject);
		procedure DataModuleDestroy(Sender: TObject);
		procedure tblmHeatAfterScroll(DataSet: TDataSet);
	private
		FConnection: TFDConnection;  //---
		fDataIsActive: Boolean;
		fMasterDetailActive: Boolean;
		FPatchesEnabled: Boolean;  // TForm.dtfrmExec ...   // Both DataModules
		msgHandle: HWND;
		procedure POST_LaneToLane(LaneNum: Integer);
		procedure POST_Noodle(NoodleID: Integer);
		procedure POST_Record(EventType: scmEventType = etUnknown);

	public
		procedure ActivateDataTDS();  //---
		procedure BuildAppData;
		procedure CalcRaceTimeM(ADataSet: TDataSet);
		procedure CalcRTSplitTime(ADataSet: TDataSet);
		procedure DeActivateDataTDS();  //---
		procedure DisableAllTDControls;
		procedure DisableTDMasterDetail();
		procedure EmptyAllTDDataSets;
		procedure EnableAllTDControls;
		procedure EnableTDMasterDetail();
		// .......................................................
		// Simplified : Call here if table relationships are active.
		// ApplyMaster isn't called for these locate record routines.
		function Locate_LaneID(ALaneID: integer): boolean;
		function Locate_LaneNum(ALaneNum: integer): boolean;
		function Locate_NoodleID(ANoodleID: integer): boolean;
		// .......................................................
		// L O C A T E S   F O R   D T   D A T A.
		// WARNING : Master-Detail is enabled and locating to an ID isn't garenteed.
		// Use DisableDTMasterDetail() before locating to ID's?
		// USED BY TdtUtils.ProcessSession.
		// .......................................................
		function LocateTEventID(AEventID: integer): boolean;
		function LocateTEventNum(ASessionID, AEventNum: integer): boolean;
		function LocateTHeatID(AHeatID: integer): boolean;
		function LocateTHeatNum(AEventID, AHeatNum: integer): boolean;
		function LocateTLaneNum(AHeatID, ALaneNum: integer): boolean; overload;
		function LocateTRaceNum(aRaceNum: integer): boolean;
		function LocateTSessionID(ASessionID: integer): boolean;
		function LocateTSessionNum(ASessionNum: integer): boolean;
		function MaxID_Event(): integer;
		function MaxID_Heat(): integer;

		// .......................................................
		// FIND MAXIMUM IDENTIFIER VALUE IN TIME-DROPS TABLES.
		// These routines are needed as there is no AutoInc on Primary Key.
		// WARNING : DisableDTMasterDetail() before calling MaxID routines.
		// .......................................................
		function MaxID_Lane: integer;
		function MaxID_Noodle(): integer;
		function MaxID_Session(): integer;
		procedure POST_All;
		procedure POST_Lane;
		
		// Read/Write Application Data State to file
		procedure ReadFromBinary(AFileName: string);
		// SET dtActiveRT : artAutomatic, artManual, artUser, artSplit, artNone
		procedure SetActiveRT(ADataSet: TDataSet; aActiveRT: scmActiveRT);
		function SyncCheck(SessionID, EventNum, HeatNum: Integer): boolean;
		function SyncCheckSession: boolean; //---
		function SyncDTtoSCM(SessionID, EventNum, HeatNum: Integer): boolean;
		function ToggleActiveRT(ADataSet: TDataSet; Direction: Integer = 0): scmActiveRT;
		// toggle [T1M .. T3M] [T1A .. T3A] - TimeKeeper's watch-time 'active state'.
		function ToggleWatchTime(ADataSet: TDataSet; idx: integer; art: scmActiveRT): Boolean;
		// Tests IsEmpty, IsNull, [T1M .. T3M] [T1A .. T3A] STATE.
		function ValidateWatchTime(ADataSet: TDataSet; TimeKeeperIndx: integer; art:
				scmActiveRT): boolean;
		// Read/Write Application Data State to file
		procedure WriteToBinary(AFileName: string);
		property Connection: TFDConnection read FConnection write FConnection; //---
		property DataIsActive: Boolean read fDataIsActive;
		property MasterDetailActive: Boolean read fMasterDetailActive;
		property MSG_Handle: HWND read msgHandle write msgHandle;  // Both DataModules
		property PatchesEnabled: boolean read FPatchesEnabled write FPatchesEnabled;
	end;


const
  XMLDataSubFolder = 'GitHub\SCM_TimeDrops\XML\';

var
  TDS: TTDS;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses System.Variants, System.DateUtils, tdSetting, System.IOUtils, dmSCM;

procedure TTDS.ActivateDataTDS;
begin
	fDataIsActive := false;
	// MAKE LIVE THE TIME-DROPS TABLES
	try
		tblmSession.Open;
		if tblmSession.Active then
		begin
			tblmEvent.Open;
			if tblmEvent.Active then
			begin
				tblmHeat.Open;
				if tblmHeat.Active then
				begin
					tblmLane.Open;
					tblmNoodle.Open;
					if tblmLane.Active and tblmNoodle.Active then
						fDataIsActive := true;
				end;
			end;
		end;
	except on E: Exception do
		// failed to open memory table.
	end;
end;

procedure TTDS.BuildAppData;
var
	fn: TFileName;

	function GetDocumentDir_TPath: string;
	begin
		Result := TPath.GetDocumentsPath;
		// TPath functions usually don't include the trailing delimiter,
		Result := IncludeTrailingPathDelimiter(Result);
	end;

begin
	fDataIsActive := false;
	tblmSession.Active := false;
	tblmEvent.Active := false;
	tblmHeat.Active := false;
	tblmLane.Active := false;
	tblmNoodle.Active := false;

	// Create TIME-DROPS DATA TABLES SCHEMA.
	// ---------------------------------------------
	tblmSession.FieldDefs.Clear;
	// Primary Key.  Derived from ..... SCM dbo.Session.SessionID.
	tblmSession.FieldDefs.Add('SessionID', ftInteger);
	// Unique - incremental number - not implimented in SCM. (redundant).
	tblmSession.FieldDefs.Add('SessionNum', ftInteger);
	// An approx start time for the session.
	// the start of recording of race data from TimeDrops.
	tblmSession.FieldDefs.Add('CreatedOn', ftDateTime);
	// session id and date...
	tblmSession.FieldDefs.Add('Caption', ftString, 64);
	tblmSession.CreateDataSet;

{$IFDEF DEBUG}
	// save schema ...
	fn := GetDocumentDir_TPath() +  XMLDataSubFolder + 'AppDataSession.xml';
	tblmSession.SaveToFile(fn, sfAuto);
{$ENDIF}

	tblmEvent.FieldDefs.Clear;
	// Primary Key.
	tblmEvent.FieldDefs.Add('EventID', ftInteger);
	// FK. Master-detail  (tblmSession)
	tblmEvent.FieldDefs.Add('SessionID', ftInteger);
	tblmEvent.FieldDefs.Add('EventNum', ftInteger);
	tblmEvent.FieldDefs.Add('Caption', ftString, 64);
	tblmEvent.CreateDataSet;
{$IFDEF DEBUG}
	// save schema ...
	fn := GetDocumentDir_TPath() +  XMLDataSubFolder + 'AppDataEvent.xml';
	tblmEvent.SaveToFile(fn, sfAuto);
{$ENDIF}

	tblmHeat.FieldDefs.Clear;
	// Create the HEAT MEM TABLE schema... tblmHeat.
	// ---------------------------------------------
	tblmHeat.FieldDefs.Add('HeatID', ftInteger); // PK.
	tblmHeat.FieldDefs.Add('EventID', ftInteger); // Master- Detail
	tblmHeat.FieldDefs.Add('HeatNum', ftInteger);
	// Auto-created eg. 'Event 1 : #FILENAME#'
	tblmHeat.FieldDefs.Add('Caption', ftString, 64);
	// The time of creation of the TimeDrops 'result' file.
	tblmHeat.FieldDefs.Add('CreatedOn', ftDateTime);
	// TimeDrops : time given when the hardware began recording race data?
	tblmHeat.FieldDefs.Add('StartTime', ftDateTime);
	// Derived from ... TimeDrops.
	tblmHeat.FieldDefs.Add('RaceNum', ftInteger);

	// Miscellaneous params...
	// FileName includes file extension. (.JSON)  Path isn't stored.
	tblmHeat.FieldDefs.Add('FileName', ftString, 128);
	// Filename params sess, ev, ht don't match SCM session, event, heat
	tblmHeat.FieldDefs.Add('BadFN', ftBoolean);
	tblmHeat.CreateDataSet;
{$IFDEF DEBUG}
	// save schema ...
	fn := GetDocumentDir_TPath() +  XMLDataSubFolder + 'AppDataHeat.xml';
	tblmHeat.SaveToFile(fn, sfAuto);
{$ENDIF}

	{ NOTE :
		TIME-DROPS doesn't destinct INDV and TEAM.
		tblEntrant holds both INDV and TEAM data.
	}

	tblmLane.FieldDefs.Clear;
	// Create the LANE MEM TABLE schema... tblmLane.
	// ---------------------------------------------
	tblmLane.FieldDefs.Add('LaneID', ftInteger); // PK.
	tblmLane.FieldDefs.Add('HeatID', ftInteger); // Master- Detail
	tblmLane.FieldDefs.Add('LaneNum', ftInteger); // Lane Number.
	// TIME-DROPS Specific
	tblmLane.FieldDefs.Add('Caption', ftString, 64); // Summary of status/mode

	// If all timekeeper watch times are empty - then true;
	// calculated during load of DT file. Read Only.
	tblmLane.FieldDefs.Add('LaneIsEmpty', ftBoolean);  //

	// A race-time cacluated by Time-Drops. Assigned on load. ReadOnly.
	// DOCUMENTATION ....
	// combination of the pad and button times.
	tblmLane.FieldDefs.Add('finalTime', ftTime);
	// A race-time cacluated by Time-Drops. Assigned on load. ReadOnly.
	// DOCUMENTATION ....
	// only present when using pads
	tblmLane.FieldDefs.Add('padTime', ftTime);

	// Race-Time that will be posted to SCM.
	// Value shown here is dependant on ActiveRT.
	tblmLane.FieldDefs.Add('RaceTime', ftTime);
	// A race-time entered manually by the user.
	tblmLane.FieldDefs.Add('RaceTimeUser', ftTime);
	// dtAutomatic - calc on load. Read-Only.
	tblmLane.FieldDefs.Add('RaceTimeA', ftTime);
	// lane is disqualified - used by TimeDrops in relays?
	tblmLane.FieldDefs.Add('isDq', ftBoolean);

	// dtActiveRT = (artAutomatic, artManual, artUser, artSplit, artNone);
	// ----------------------------------------------------------------
	// artAutomatic ...
	//  A race-time calculated when loading the DT file - read only.
	// artManual ...
	//  A race-time calculated on demand.
	// artUser ...
	//  The user must switch to manual mode and then CNTRL-LMB the race-time cell.
	//  AND then will be prompted to enter a user race-time. An icon will
	//  be displayed in the race-time cell. CNTRL-LMB to exit this mode.
	// artSplit ...
	// dtfiletype dtDO4 ONLY. Use the final split-time as race-time.
	// artNone ...
	// The lane is empty or data error.
	tblmLane.FieldDefs.Add('ActiveRT', ftInteger);
	// CELL ICON - PATCH cable .
	tblmLane.FieldDefs.Add('imgPatch', ftInteger);

	// CELL ICON - ActiveRT.
	tblmLane.FieldDefs.Add('imgActiveRT', ftInteger);

	// TimeKeeper's RACE_TIMES - 1,2, 3  (Allows for 3 TimeKeepers.)
	tblmLane.FieldDefs.Add('Time1', ftTime); // timekeeper 1.
	tblmLane.FieldDefs.Add('Time2', ftTime); // timekeeper 2.
	tblmLane.FieldDefs.Add('Time3', ftTime);  // timekeeper 3.

	// dtManual - store flip/flop.
	// The watch time is enabled (true) - is disabled (false).
	tblmLane.FieldDefs.Add('T1M', ftBoolean);
	tblmLane.FieldDefs.Add('T2M', ftBoolean);
	tblmLane.FieldDefs.Add('T3M', ftBoolean);

	// dtAutomatic - store flip/flop.
	// The watch time is valid  (true).
	// SET on load of DT file (DO3 .. DO4). Read only.
	tblmLane.FieldDefs.Add('T1A', ftBoolean);
	tblmLane.FieldDefs.Add('T2A', ftBoolean);
	tblmLane.FieldDefs.Add('T3A', ftBoolean);

	// Deviation - store flip/flop.
	// The watch time is within accepted deviation (true).
	// Only 2xfields Min-Mid, Mid-Max
	// SET on load of DT file (DO3 .. DO4). Read only.
	tblmLane.FieldDefs.Add('TDev1', ftBoolean);
	tblmLane.FieldDefs.Add('TDev2', ftBoolean);

	// TIME-DROPS - stores MAX 10 splits.
	tblmLane.FieldDefs.Add('Split1', ftTime);
	tblmLane.FieldDefs.Add('Split2', ftTime);
	tblmLane.FieldDefs.Add('Split3', ftTime);
	tblmLane.FieldDefs.Add('Split4', ftTime);
	tblmLane.FieldDefs.Add('Split5', ftTime);
	tblmLane.FieldDefs.Add('Split6', ftTime);
	tblmLane.FieldDefs.Add('Split7', ftTime);
	tblmLane.FieldDefs.Add('Split8', ftTime);
	tblmLane.FieldDefs.Add('Split9', ftTime);
	tblmLane.FieldDefs.Add('Split10', ftTime);

	tblmLane.FieldDefs.Add('SplitDist1', ftTime);
	tblmLane.FieldDefs.Add('SplitDist2', ftTime);
	tblmLane.FieldDefs.Add('SplitDist3', ftTime);
	tblmLane.FieldDefs.Add('SplitDist4', ftTime);
	tblmLane.FieldDefs.Add('SplitDist5', ftTime);
	tblmLane.FieldDefs.Add('SplitDist6', ftTime);
	tblmLane.FieldDefs.Add('SplitDist7', ftTime);
	tblmLane.FieldDefs.Add('SplitDist8', ftTime);
	tblmLane.FieldDefs.Add('SplitDist9', ftTime);
	tblmLane.FieldDefs.Add('SplitDist10', ftTime);


	tblmLane.CreateDataSet;
{$IFDEF DEBUG}
	// save schema ...
	fn := GetDocumentDir_TPath() +  XMLDataSubFolder + 'AppDataLane.xml';
	tblmLane.SaveToFile(fn, sfAuto);
{$ENDIF}

	tblmNoodle.FieldDefs.Clear;
	// Create the NOODLE MEM TABLE schema... tblmNoodle.
	// ---------------------------------------------
	// Primary Key
	tblmNoodle.FieldDefs.Add('NoodleID', ftInteger);

	// dtHeat Master-Detail.
	tblmNoodle.FieldDefs.Add('HeatID', ftInteger);

	tblmNoodle.FieldDefs.Add('Enabled', ftBoolean);
	tblmNoodle.FieldDefs.Add('Tab', ftInteger);

	{ Noodle HANDLE BANK 0 ... }
	tblmNoodle.FieldDefs.Add('SCMHeatID', ftInteger); // HeatIndividual.HeatID.
	tblmNoodle.FieldDefs.Add('SCMLane', ftInteger);   // Entrant/Team LaneNum.
	{ Noodle HANDLE BANK 1 ... }
	tblmNoodle.FieldDefs.Add('TDSHeatID', ftInteger);  // tblmHeat.HeatID.
	tblmNoodle.FieldDefs.Add('TDSLane', ftInteger);    // tblmLane.LaneNum.

	tblmNoodle.CreateDataSet;
{$IFDEF DEBUG}
	// save schema ...
	fn := GetDocumentDir_TPath() +  XMLDataSubFolder + 'AppDataNoodle.xml';
	tblmNoodle.SaveToFile(fn, sfAuto);
{$ENDIF}

end;

procedure TTDS.CalcRaceTimeM(ADataSet: TDataSet);
var
	I: Integer;
	s: string;
	count: integer;
	b: boolean;
	t: TTime;
begin
	t := 0;
	count:= 0;
	// check isnull, zero and T?M
	for I := 1 to 3 do
	begin
		b := ValidateWatchTime(ADataSet, I, artManual);
		if b then
		begin
			s := 'Time' + IntToStr(I);
			t := t + TimeOF(ADataSet.FieldByName(s).AsDateTime);
			INC(count);
		end;
	end;

	ADataSet.Edit;
	if count = 0 then
	begin
		// If no valid times, clear the RaceTime field.
		ADataSet.FieldByName('RaceTime').Clear;
	end
	else
	begin
		// Calculate average time
		t := t / count;
		ADataSet.FieldByName('RaceTime').AsDateTime := t;
	end;
	ADataSet.Post;
end;

procedure TTDS.CalcRTSplitTime(ADataSet: TDataSet);
var
	t, t2: TTime;
	tOk: boolean;
	I: integer;
	s: string;

begin
	tOk := false;
	t := 0;
	if Assigned(Settings) then
	begin
		if Settings.UseTDpadTime then
		begin
			if not ADataSet.FieldByName('padTime').IsNull then
			begin
				t := ADataSet.FieldByName('padTime').AsDatetime;
				if (t<>0) then tOk := true;
			end;
		end
		else
		begin
			// assume split is acculmative time ....
			// locate MAX(split)  : stack order not important.
			t := 0;
			for I := 1 to 10 do
			begin
				s := 'split' + IntTostr(I);
				t2 := 0;
				if not ADataSet.FieldByName(s).IsNull then
					t2 := TimeOf(ADataSet.FieldByName(s).AsDatetime);
				if (t < t2) then
					t := t2
			end;

			if (t <> 0) then tOk := true;
		end;
	end;

	try
		begin
			ADataSet.Edit;
			if tOk then
				ADataSet.FieldByName('RaceTime').AsDateTime := t
			else
				ADataSet.FieldByName('RaceTime').Clear;
			ADataSet.Post;
		end;
	except on E: Exception do
			ADataSet.Cancel;
	end;

end;

procedure TTDS.DataModuleCreate(Sender: TObject);
begin
	// Init params.
	fDataIsActive := false;
	fMasterDetailActive := false;
	FConnection := nil;
	fDataIsActive := false; // activated later once FConnection is assigned.
	msgHandle := 0;
	FPatchesEnabled := true;
end;

procedure TTDS.DataModuleDestroy(Sender: TObject);
begin
		msgHandle := 0;
end;

procedure TTDS.DeActivateDataTDS;
begin
		tblmNoodle.close;
		tblmLane.close;
		tblmHeat.close;
		tblmEvent.close;
		tblmSession.close;
		fDataIsActive := false;
end;

procedure TTDS.DisableAllTDControls;
begin
	tblmSession.DisableControls;
	tblmEvent.DisableControls;
	tblmHeat.DisableControls;
	tblmLane.DisableControls;
	tblmNoodle.DisableControls;
end;

procedure TTDS.DisableTDMasterDetail();
begin
	// ASSERT Master - Detail
	tblmSession.IndexFieldNames := 'SessionID';
	tblmEvent.MasterSource := nil;
	tblmEvent.MasterFields := '';
	tblmEvent.DetailFields := '';
	tblmEvent.IndexFieldNames := 'EventID';
	tblmHeat.MasterSource := nil;
	tblmHeat.MasterFields := '';
	tblmHeat.DetailFields := '';
	tblmHeat.IndexFieldNames := 'HeatID';
	tblmLane.MasterSource := nil;
	tblmLane.MasterFields := '';
	tblmLane.DetailFields := '';
	tblmLane.IndexFieldNames := 'LaneID';
	tblmNoodle.MasterSource := nil;
	tblmNoodle.MasterFields := '';
	tblmNoodle.DetailFields := '';
	tblmNoodle.IndexFieldNames := 'NoodleID';
	tblmSession.First;
	{
	Use the ApplyMaster method to synchronize this detail dataset with the
	current master record.  This method is useful, when DisableControls was
	called for the master dataset or when scrolling is disabled by
	MasterLink.DisableScroll.
	}
//  tblmEvent.ApplyMaster;
	tblmEvent.First;
//  tblmHeat.ApplyMaster;
	tblmHeat.First;
//  tblmLane.ApplyMaster;
	tblmLane.First;
//  tblmNoodle.ApplyMaster;
	tblmNoodle.First;

	fMasterDetailActive := false;
end;

procedure TTDS.EmptyAllTDDataSets;
begin
	 // clear all data records - cannot be performed on a closed table.
	if tblmSession.Active then
	begin
		tblmSession.EmptyDataSet;
		tblmEvent.EmptyDataSet;
		tblmHeat.EmptyDataSet;
		tblmLane.EmptyDataSet;
		tblmNoodle.EmptyDataSet;
	end;
end;

procedure TTDS.EnableAllTDControls;
begin
	tblmSession.EnableControls;
	tblmEvent.EnableControls;
	tblmHeat.EnableControls;
	tblmLane.EnableControls;
	tblmNoodle.EnableControls;
end;

procedure TTDS.EnableTDMasterDetail();
begin
	// Master - index field.
	tblmSession.IndexFieldNames := 'SessionID';
	// ASSERT Master - Detail
	tblmEvent.MasterSource := dsmSession;
	tblmEvent.MasterFields := 'SessionID';
	tblmEvent.DetailFields := 'SessionID';
	tblmEvent.IndexFieldNames := 'SessionID';
	tblmHeat.MasterSource := dsmEvent;
	tblmHeat.MasterFields := 'EventID';
	tblmHeat.DetailFields := 'EventID';
	tblmHeat.IndexFieldNames := 'EventID';
	tblmLane.MasterSource := dsmHeat;
	tblmLane.MasterFields := 'HeatID';
	tblmLane.DetailFields := 'HeatID';
	tblmLane.IndexFieldNames := 'HeatID';
	tblmNoodle.MasterSource := dsmHeat;
	tblmNoodle.MasterFields := 'HeatID';
	tblmNoodle.DetailFields := 'HeatID';
	tblmNoodle.IndexFieldNames := 'HeatID';
	fMasterDetailActive := true;
end;

function TTDS.LocateTEventID(AEventID: integer): boolean;
var
  LOptions: TLocateOptions;
begin
  result := false;
	if (not tblmEvent.Active) or (tblmEvent.IsEmpty) then exit;
	if (AEventID = 0) then exit;
	if AEventID = tblmEvent.FieldByName('EventID').AsInteger then
	begin
		result := true;
		exit;
	end;
	LOptions := [];
	result := tblmEvent.Locate('EventID', AEventID, LOptions);
	if result then tblmHeat.ApplyMaster;
end;

function TTDS.LocateTEventNum(ASessionID, AEventNum: integer): boolean;
var
	indexStr: string;
	LOptions: TLocateOptions;
begin
	// WARNING : DisableDTMasterDetail() before calling here.
	// USED ONLY BY TdtUtils.ProcessEvent.
	result := false;
	// Exit if the table is not active or if AEventNum is 0
	if (not tblmEvent.Active) or (tblmEvent.IsEmpty) then exit;
	if (AEventNum = 0) then exit;
	// Store the original index field names
  indexStr := tblmEvent.IndexFieldNames;
  LOptions := [];
  tblmEvent.IndexFieldNames := 'SessionID;EventNum';
  result := tblmEvent.Locate('SessionID;EventNum', VarArrayOf([ASessionID,
    AEventNum]), LOptions);
  // Restore the original index field names
  tblmEvent.IndexFieldNames := indexStr;
  if result then tblmHeat.ApplyMaster;
end;

function TTDS.LocateTHeatID(AHeatID: integer): boolean;
var
  LOptions: TLocateOptions;
begin
  result := false;
	if (not tblmHeat.Active) or tblmHeat.IsEmpty then exit;
	if (AHeatID = 0) then exit;
	if AHeatID = tblmHeat.FieldByName('HeatID').AsInteger then
	begin
		result := true;
		exit;
	end;
	LOptions := [];
	result := tblmHeat.Locate('HeatID', AHeatID, LOptions);
	if result then
	begin
		tblmLane.ApplyMaster;
		tblmNoodle.ApplyMaster;
	end;
end;

function TTDS.LocateTHeatNum(AEventID, AHeatNum: integer): boolean;
var
	indexStr: string;
	LOptions: TLocateOptions;
begin
	// WARNING : DisableDTMasterDetail() before calling here.
	// USED ONLY BY TdtUtils.ProcessHeat.
	result := false;
	// Exit if the table is not active or if AHeatNum is 0
	if (not tblmHeat.Active) or tblmHeat.IsEmpty then exit;
	if (AHeatNum = 0) then exit;
  indexStr := tblmHeat.IndexFieldNames; // Store the original index field names
  LOptions := [];
  tblmHeat.IndexFieldNames := 'EventID;HeatNum';
  result := tblmHeat.Locate('EventID;HeatNum', VarArrayOf([AEventID, AHeatNum]),
    LOptions);
  tblmHeat.IndexFieldNames := indexStr; // Restore the original index field names
  if result then
	begin
    tblmLane.ApplyMaster;
    tblmNoodle.ApplyMaster;
  end;
end;

function TTDS.Locate_LaneID(ALaneID: integer): boolean;
var
  LOptions: TLocateOptions;
  indexStr: string;
begin
  result := false;
	if (not tblmLane.Active) or (tblmLane.IsEmpty) then exit;
	if (ALaneID = 0) then exit;
	if ALaneID = tblmLane.FieldByName('LaneID').AsInteger then
	begin
		result := true;
		exit;
	end;
	indexStr := tblmLane.IndexFieldNames; // Store the original index field names
	LOptions := [];
	tblmLane.IndexFieldNames := 'LaneID';
	result := tblmLane.Locate('LaneID', ALaneID, LOptions);
	tblmLane.IndexFieldNames := indexStr; // Restore the original index field names
end;

function TTDS.Locate_LaneNum(ALaneNum: integer): boolean;
var
  HeatID: integer;
begin
  // NOTE: Ensure that the correct tblmHeat record is selected before calling.
  // Also, consider using 'ApplyMaster' before calling.
  result := false;
  if (not tblmLane.Active) or (tblmLane.IsEmpty) then exit;
  if (not (tblmHeat.Active)) or (tblmHeat.IsEmpty) then exit;
  if (ALaneNum = 0) then exit;
  if ALaneNum = tblmLane.FieldByName('LaneNum').AsInteger then
    result := true
  else
  begin // uses current TDS heat.
    if not tblmHeat.Active then exit;
    if tblmHeat.IsEmpty then exit;
    HeatID := tblmHeat.FieldByName('HeatID').AsInteger;
    result := LocateTLaneNum(HeatID, ALaneNum);
  end;
end;

function TTDS.LocateTLaneNum(AHeatID, ALaneNum: integer): boolean;
var
	indexStr: string;
	LOptions: TLocateOptions;
begin
	// WARNING : DisableDTMasterDetail() before calling here.
	// USED ONLY BY TdtUtils.ProcessHeat.
	result := false;
	// Exit if the table is not active or if AHeatNum is 0
	if (not tblmLane.Active) or (tblmLane.IsEmpty) then exit;
	if ALaneNum = 0 then exit;
	// Store the original index field names
	indexStr := tblmLane.IndexFieldNames;
	LOptions := [];
	tblmLane.IndexFieldNames := 'HeatID;LaneNum';
	result := tblmLane.Locate('HeatID;LaneNum', VarArrayOf([AHeatID, ALaneNum]), LOptions);
	// Restore the original index field names
	tblmLane.IndexFieldNames := indexStr;
end;

function TTDS.Locate_NoodleID(ANoodleID: integer): boolean;
var
  LOptions: TLocateOptions;
begin
  result := false;
	if (not tblmNoodle.Active) or (tblmNoodle.IsEmpty) then exit;
  if (ANoodleID = 0) then exit;
  if ANoodleID = tblmNoodle.FieldByName('NoodleID').AsInteger then
  begin
    result := true;
    exit;
  end;
	LOptions := [];
  result := tblmNoodle.Locate('NoodleID', ANoodleID, LOptions);
end;

function TTDS.LocateTRaceNum(aRaceNum: integer): boolean;
begin
  result := false;
	if (not tblmHeat.Active) or (tblmHeat.IsEmpty) then exit;
  if (aRaceNum = 0) then exit;
  if aRaceNum = tblmHeat.FieldByName('RaceNum').AsInteger then
  begin
    result := true;
    exit;
  end;
	result := tblmHeat.Locate('RaceNum', aRaceNum, []);
  if result then
  begin
    tblmLane.ApplyMaster;
    tblmNoodle.ApplyMaster;
  end;
end;

function TTDS.LocateTSessionID(ASessionID: integer): boolean;
var
  LOptions: TLocateOptions;
begin
  result := false;
	if (not tblmSession.Active) or (tblmSession.IsEmpty) then exit;
	if (ASessionID = 0) then exit;
	if ASessionID = tblmSession.FieldByName('SessionID').AsInteger then
	begin
		result := true;
		exit;
	end;
	LOptions := [];
	result := tblmSession.Locate('SessionID', ASessionID, LOptions);
	if result then tblmEvent.ApplyMaster; // required.
end;

function TTDS.LocateTSessionNum(ASessionNum: integer): boolean;
var
  indexStr: string;
  LOptions: TLocateOptions;
begin
  result := false;
  if (not tblmSession.Active) or (tblmSession.IsEmpty) then exit;
  if ASessionNum = 0 then exit;

  indexStr := tblmSession.IndexFieldNames; // Store
  if (ASessionNum = 0) then exit;
  tblmSession.IndexFieldNames := 'SessionNum';
  LOptions := [];
  result := tblmSession.Locate('SessionNum', ASessionNum, LOptions);

  tblmSession.IndexFieldNames := indexStr; // Restore
  if result then tblmEvent.ApplyMaster; // required.
end;

function TTDS.MaxID_Event: integer;
var
max, id: integer;
begin
	// To function correctly disableDTMasterDetail.
	max := 0;
	tblmEvent.First;
	while not tblmEvent.eof do
	begin
		id := tblmEvent.FieldByName('EventID').AsInteger;
		if (id > max) then
			max := id;
		tblmEvent.Next;
	end;
	result := max;
end;

function TTDS.MaxID_Heat: integer;
var
max, id: integer;
begin
	// To function correctly disableDTMasterDetail.
	max := 0;
	tblmHeat.First;
	while not tblmHeat.eof do
	begin
		id := tblmHeat.FieldByName('HeatID').AsInteger;
		if (id > max) then
			max := id;
		tblmHeat.Next;
	end;
	result := max;
end;

function TTDS.MaxID_Lane: integer;
var
max, id: integer;
begin
	// To function correctly disableDTMasterDetail.
	max := 0;
	tblmLane.First;
	while not tblmLane.eof do
	begin
		id := tblmLane.FieldByName('LaneID').AsInteger;
		if (id > max) then
			max := id;
		tblmLane.Next;
	end;
	result := max;
end;

function TTDS.MaxID_Noodle: integer;
var
max, id: integer;
begin
	// To function correctly disableDTMasterDetail.
	max := 0;
	tblmNoodle.First;
	while not tblmNoodle.eof do
	begin
		id := tblmNoodle.FieldByName('NoodleID').AsInteger;
		if (id > max) then
			max := id;
		tblmNoodle.Next;
	end;
	result := max;
end;

function TTDS.MaxID_Session: integer;
var
max, id: integer;
begin
	// To function correctly disableDTMasterDetail.
	max := 0;
	tblmSession.First;
	while not tblmSession.eof do
	begin
		id := tblmSession.FieldByName('SessionID').AsInteger;
		if (id > max) then
			max := id;
		tblmSession.Next;
	end;
	result := max;
end;

procedure TTDS.POST_All;
begin
	// TEST data integrity before iterating over lane table.
	if not (FDataIsActive) then exit;
	if tblmLane.IsEmpty then exit;
	tblmLane.DisableControls;
	try
		tblmLane.First;
		while not (tblmLane.eof) do // iterate over TimeDrop's lane data.
		begin
			POST_Lane();  
			tblmLane.Next;
		end;
	finally
		tblmLane.EnableControls;
	end;
end;

procedure TTDS.POST_Lane();
var
	NoodleB0, NoodleB1, ALaneNum: integer;
begin
	// MAIN ENTRY POINT: ALL data integrity TESTS are performed here.
	if (not SCM.DataIsActive) or (not FDataIsActive) then exit;
	if SCM.qryEvent.IsEmpty or SCM.qryHeat.IsEmpty then exit;
	if tblmLane.IsEmpty then exit;

	// ASSUMPTION: TDS.tblmLane cued to correct record.
	ALaneNum := TDS.tblmLane.FieldByName('LaneNum').AsInteger;

	if not FPatchesEnabled then
		// Noodles have been disabled. Perform a lane-to-Lane assignment.
		POST_LaneToLane(ALaneNum)
	else if (FPatchesEnabled) and tblmNoodle.IsEmpty() then
		// Noodles ARE enabled but no noodles to patch.
		POST_LaneToLane(ALaneNum)
	else
	begin // We have noodles...
		NoodleB0 := 0;
		NoodleB1 := 0;
		// Find any noodles that may interfere with a lane-to-lane operation.
		tblmNoodle.Filter := Format('SCMLane = %d OR TDSLane = %d', [ALaneNum,
				ALaneNum]);
		tblmNoodle.Filtered := true;
		if (tblmNoodle.RecordCount <> 0) then 
		begin // Only 2 banks per lane. Max noodle handles per lane = 2.
			tblmNoodle.First;
			while not tblmNoodle.Eof do
			begin
				if tblmNoodle.FieldByName('SCMLane').AsInteger = ALaneNum then
					NoodleB0 := tblmNoodle.FieldByName('NoodleID').AsInteger;
				if tblmNoodle.FieldByName('TDSLane').AsInteger = ALaneNum then
					NoodleB1 := tblmNoodle.FieldByName('NoodleID').AsInteger;
				tblmNoodle.next;
			end;
		end;
		tblmNoodle.Filtered := false; // disable filtering.
		tblmNoodle.Filter := '';

		if (NoodleB0 = 0) and (NoodleB1 = 0) then
			// No noodles found touching bank0 or bank1 on this lane.
			POST_LaneToLane(ALaneNum) // Perform a lane-to-lane assignment.
		else // Process ONLY noodle found at BANK 1.
			POST_Noodle(NoodleB1);
	end;
end;

procedure TTDS.POST_LaneToLane(LaneNum: integer);
var
  EventType: scmEventType;
  found: boolean;
begin
  SCM.qryINDV.DisableControls;
  SCM.qryTEAMEntrant.DisableControls;
  SCM.qryTEAM.DisableControls;
  tblmLane.DisableControls;
  try
    found := false;
    EventType := SCM.GetEventType(SCM.qryHeat.FieldByName('EventID').AsInteger);
    case EventType of
      etUnknown: exit;
      etINDV:
        begin
          if SCM.qryINDV.FieldByName('lane').AsInteger <> LaneNum then
            found := SCM.LocateLaneNum(LaneNum, EventType);
        end;
      etTEAM:
        begin
          if SCM.qryTEAM.FieldByName('lane').AsInteger <> LaneNum then
            found := SCM.LocateLaneNum(LaneNum, EventType);
        end;
    end;
    if found then POST_Record(EventType);
  finally
    tblmLane.EnableControls;
    SCM.qryINDV.EnableControls;
    SCM.qryTEAM.EnableControls;
    SCM.qryTEAMEntrant.EnableControls;
  end;
end;

procedure TTDS.POST_Noodle(NoodleID: Integer);
var
	Bank0Lane, Bank0HeatID, Bank1Lane, Bank1HeatID: Integer;
	found: boolean;
	storeSCMHeatID: integer;
	AEventType: scmEventType;
begin
	// take data controls offline
	SCM.qryINDV.DisableControls;
	SCM.qryTEAM.DisableControls;
	SCM.qryTEAMEntrant.DisableControls;
	tblmLane.DisableControls;
	SCM.qryHeat.DisableControls;
	// store the current SwimClubMeet heat.
	storeSCMHeatID := SCM.qryHeat.FieldByName('HeatID').AsInteger;
	try
		found := true;
		// locate the correct Noodle to process.
		if tblmNoodle.FieldByName('NoodleID').AsInteger <> NoodleID then
			found := Locate_NoodleID(NoodleID);
		if found then
		begin
			// extract params.
			Bank1Lane := tblmNoodle.FieldByName('TDSLane').AsInteger;
			Bank1HeatID := tblmNoodle.FieldByName('TDSHeatID').AsInteger;
			Bank0Lane := tblmNoodle.FieldByName('SCMLane').AsInteger;
			Bank0HeatID := tblmNoodle.FieldByName('SCMHeatID').AsInteger;
			
			if TDS.tblmLane.FieldByName('HeatID').AsInteger <> Bank1HeatID then
				exit;  // unexpected error
				
			if TDS.tblmLane.FieldByName('LaneNum').AsInteger <> Bank1Lane then
				found  := LocateTLaneNum(TDS.tblmLane.FieldByName('HeatID').AsInteger,Bank1Lane);
			if found then
			begin
				if SCM.qryHeat.FieldByName('HeatID').AsInteger <> Bank0HeatID then
					found := SCM.LocateHeatID(Bank0HeatID); // ApplyMaster...
				if found then 
				begin
					AEventType := SCM.GetEventType(SCM.qryHeat.FieldByName('EventID').AsInteger);
					found := SCM.LocateLaneNum(Bank0Lane, AEventType);	
					if found then POST_Record(AEventType);
				end;
			end;
		end;

	finally
		// re-locate to last SwimClubMeet heat - if required..
		if SCM.qryHeat.FieldByName('HeatID').AsInteger <> storeSCMHeatID then
		begin
			SCM.LocateHeatID(storeSCMHeatID);
			SCM.qryTEAM.ApplyMaster;
			SCM.qryINDV.ApplyMaster;
			SCM.qryTEAMEntrant.ApplyMaster;	
		end;
		
		SCM.qryHeat.EnableControls;
		tblmLane.EnableControls;
		SCM.qryTEAMEntrant.EnableControls;
		SCM.qryTEAM.EnableControls;
		SCM.qryINDV.EnableControls;
	end;
end;

procedure TTDS.POST_Record(EventType: scmEventType = etUnknown);
begin

	if EventType = etINDV then
	begin
		// can't post a time to a lane with no swimmer!
		if not SCM.qryINDV.FieldByName('MemberID').IsNull then
		begin
			try
				SCM.qryINDV.Edit;
				SCM.qryINDV.FieldByName('RaceTime').AsDateTime :=
				tblmLane.FieldByName('RaceTime').AsDateTime;
				SCM.qryINDV.Post;
			except on E: Exception do SCM.qryINDV.Cancel;
			end;
		end;
	end
	else if EventType = etTEAM then
	begin
		// can't post a time to a lane that doesn't have a relay team.
		if not SCM.qryTEAM.FieldByName('TeamNameID').IsNull then
		begin
			try
				SCM.qryTEAM.Edit;
				SCM.qryTEAM.FieldByName('RaceTime').AsDateTime :=
				tblmLane.FieldByName('RaceTime').AsDateTime;
				SCM.qryTEAM.Post;
			except
				on E: Exception do SCM.qryINDV.Cancel;
			end;
		end;
	end;
end;

procedure TTDS.ReadFromBinary(AFileName: string);
var
	myZip: TZipFile;
	crcStream: TStream;
	memStream: TMemoryStream;
	zipHeader: TZipHeader;
	fileIndex: Integer;
	procedure StreamFromZip(AFileIndex: integer; AMemTable: TFDMemTable);
	begin
		if AFileIndex < 0 then Exit; // invalid index.
		crcStream := nil;
		memStream := TMemoryStream.Create;
		try
			// Read the file into a CRC Stream
			myZip.Read(AFileIndex, crcStream, zipHeader, True);
			if not Assigned(crcStream) then
				raise Exception.Create('Failed to read file from zip archive.');
			try
				memStream.LoadFromStream(crcStream);
			except
				on E: Exception do
					raise Exception.Create('Error loading data into TMemoryStream: ' + E.Message);
			end;
			// Reset the stream position
			memStream.Position := 0;
			// Load the data into the TFDMemTable
			try
				AMemTable.LoadFromStream(memStream, sfBinary);
				ActivateDataTDS;
			except
				// ExceptionMessage="TCRCStream.Seek not implemented"
				on E: Exception do
					raise Exception.Create('Error loading data into TFDMemTable: ' + E.Message);
			end;
		finally
			if Assigned(crcStream) then
				crcStream.Free; // Free only if it was successfully created
			memStream.Free;
		end;
	end;

begin
	if not FileExists(AFileName) then exit;
	if (not Assigned(TDS)) or (TDS.fDataIsActive = false) then exit;
	DisableAllTDControls;
	DisableTDMasterDetail;
	myZip := TZipFile.Create;  // Create the zip file object
	try
		// Open the zip file for reading
		myZip.Open(AFileName, zmRead);
		// Load DTSession.fsBinary into tblmEvent
		fileIndex := myZip.IndexOf('TDSession.fsBinary');
		StreamFromZip(fileIndex, tblmSession);
		// Load DTEvent.fsBinary into tblmEvent
		fileIndex := myZip.IndexOf('TDEvent.fsBinary');
		StreamFromZip(fileIndex, tblmEvent);
		// Load DTHeat.fsBinary into tblmHeat
		fileIndex := myZip.IndexOf('TDHeat.fsBinary');
		StreamFromZip(fileIndex, tblmHeat);
		// Load DTLane.fsBinary into tblmLane
		fileIndex := myZip.IndexOf('TDLane.fsBinary');
		StreamFromZip(fileIndex, tblmLane);
		// Load DTNoodle.fsBinary into tblmNoodle
		fileIndex := myZip.IndexOf('TDNoodle.fsBinary');
		StreamFromZip(fileIndex, tblmNoodle);
	finally
		// Close and free the zip file
		myZip.Close;
		myZip.Free;
		EnableAllTDControls;
		EnableTDMasterDetail;
	end;
end;

procedure TTDS.SetActiveRT(ADataSet: TDataSet; aActiveRT: scmActiveRT);
var
	RaceTimeField: TField;
	RaceTimeUField: TField;
	RaceTimeAField: TField;
begin

	if ADataSet.FieldByName('LaneIsEmpty').AsBoolean then
	begin
		ADataSet.edit;
		ADataSet.fieldbyName('imgActiveRT').AsInteger := -1;
		ADataSet.FieldByName('RaceTime').Clear;
		ADataSet.post;
		exit;
	end;

	try
		case aActiveRT of
			artAutomatic:
				begin
					ADataSet.edit;
					try
						ADataSet.FieldByName('ActiveRT').AsInteger := Ord(artAutomatic);
						if ADataSet.FieldByName('RaceTimeA').IsNull then
							ADataSet.FieldByName('RaceTime').Clear
						else
							ADataSet.FieldByName('RaceTime').AsVariant :=
							ADataSet.FieldByName('RaceTimeA').AsVariant;
						ADataSet.fieldbyName('imgActiveRT').AsInteger := 2;
						ADataSet.post;
					except on E: Exception do
						begin
							ADataSet.Cancel; // Cancel the changes if an exception occurs
							raise; // Re-raise the exception to propagate it further
						end;
					end;
				end;

			artFinalTime:
			begin
					ADataSet.edit;
					try
						ADataSet.FieldByName('ActiveRT').AsInteger := Ord(artFinalTime);
						// optional - use TimeDrops 'finalTime' for auto race-time.
						if ADataSet.FieldByName('finalTime').IsNull then
							ADataSet.FieldByName('RaceTime').Clear
						else
							ADataSet.FieldByName('RaceTime').AsVariant :=
							ADataSet.FieldByName('finalTime').AsVariant;
						ADataSet.fieldbyName('imgActiveRT').AsInteger := 8;
						ADataSet.post;
					except on E: Exception do
						begin
							ADataSet.Cancel; // Cancel the changes if an exception occurs
							raise; // Re-raise the exception to propagate it further
						end;
					end;
			end;

			artManual:
				begin
					ADataSet.edit;
					ADataSet.FieldByName('ActiveRT').AsInteger := ORD(artManual);
					ADataSet.fieldbyName('imgActiveRT').AsInteger := 3;
					ADataSet.post;
				end;

			artUser:
				begin
					ADataSet.edit;

					RaceTimeField := ADataSet.FieldByName('RaceTime');
					RaceTimeUField := ADataSet.FieldByName('RaceTimeUser');
					RaceTimeAField := ADataSet.FieldByName('RaceTimeA');

					ADataSet.FieldByName('ActiveRT').AsInteger := ORD(artUser);
					ADataSet.fieldbyName('imgActiveRT').AsInteger := 4;

					if RaceTimeUField.IsNull then
						RaceTimeUField.AsVariant := RaceTimeAField.AsVariant;

					RaceTimeField.AsVariant := RaceTimeUField.AsVariant;

					ADataSet.post;
				end;

			artSplit:
				begin
					ADataSet.edit;
					ADataSet.FieldByName('ActiveRT').AsInteger := ORD(artSplit);
					{TODO -oBSA -cGeneral : Find last split time and assign to RaceTime}
					ADataSet.fieldbyName('imgActiveRT').AsInteger := 5;
					ADataSet.FieldByName('RaceTime').Clear;
					ADataSet.post;
				end;

			artPadTime:
			begin
				ADataSet.edit;
				ADataSet.FieldByName('ActiveRT').AsInteger := ORD(artPadTime);
				// optional - use TimeDrops 'padTime' for 'race-time'.
				if ADataSet.FieldByName('padTime').IsNull then
					ADataSet.FieldByName('RaceTime').Clear
				else
					ADataSet.FieldByName('RaceTime').AsVariant :=
					ADataSet.FieldByName('padTime').AsVariant;
				ADataSet.fieldbyName('imgActiveRT').AsInteger := 9;
				ADataSet.post;
			end;

			artNone:
				begin
					ADataSet.edit;
					ADataSet.FieldByName('ActiveRT').AsInteger := ORD(artNone);
					ADataSet.fieldbyName('imgActiveRT').AsInteger := 6;
					ADataSet.FieldByName('RaceTime').Clear;
					ADataSet.post;
				end;
		end;

	except on E: Exception do
			// handle arror.
	end;
end;

function TTDS.SyncCheck(SessionID, EventNum, HeatNum: Integer): boolean;
var
	IsSynced: boolean;
begin
	IsSynced := false;
	if SessionID =  tblmSession.FieldByName('SessionID').AsInteger then
		if EventNum = tblmEvent.FieldByName('EventNum').AsInteger then
			if HeatNum = tblmHeat.FieldByName('HeatNum').AsInteger then
				IsSynced := true;
	result := IsSynced;
end;

function TTDS.SyncCheckSession: boolean;
var
	sessNum: integer;
begin
	result := false;
	sessNum := tblmSession.FieldByName('SessionNum').AsInteger;
	if SCM.qrySession.FieldByName('SessionID').AsInteger = sessNum then
		result := true;
end;

function TTDS.SyncDTtoSCM(SessionID, EventNum, HeatNum: Integer): boolean;
var
	found: boolean;
	LOptions: TLocateOptions;
begin
	result := false;
	LOptions := [];
	tblmEvent.DisableControls;
	tblmHeat.DisableControls;
	tblmLane.DisableControls;
	tblmSession.DisableControls;

	found := LocateTSessionID(SessionID);
	if found then
	begin
		tblmEvent.ApplyMaster;
		found := tblmEvent.Locate('EventNum', EventNum, LOptions);
		if found then
		begin
			tblmHeat.ApplyMaster;
			found := tblmHeat.Locate('HeatNum', HeatNum, LOptions);
			if found then begin
				tblmLane.ApplyMaster;
				tblmNoodle.ApplyMaster;
				result := true;
			end;
		end;
	end;
	tblmSession.EnableControls;
	tblmEvent.EnableControls;
	tblmHeat.EnableControls;
	tblmLane.EnableControls;
end;

procedure TTDS.tblmHeatAfterScroll(DataSet: TDataSet);
begin
	if (msgHandle <> 0) then
	begin
		PostMessage(msgHandle, SCM_UPDATEUI_TDS, 0,0);
		PostMessage(msgHandle, SCM_UPDATE_NOODLES, 0,0);
	end;
end;

function TTDS.ToggleActiveRT(ADataSet: TDataSet; Direction: Integer = 0):
scmActiveRT;
var
	art: scmActiveRT;
begin
	result := artNone;
	if not ADataSet.Active then exit;
	if not (ADataSet.Name = 'tblmLane') then exit;
	// Get the current ActiveRT value
	art := scmActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
	if (Direction = 0) then
	begin
		// Toggle state using Succ and handling wrapping
		if art = High(scmActiveRT) then
			art := Low(scmActiveRT)
		else
		begin
			art := Succ(art);
			if art = artFinalTime then
			begin
				if Assigned(Settings) and (Settings.UseTDfinalTime = false)  then
					art := Succ(art); // skip this action.
			end;
			if art = artPadTime then
			begin
				if Assigned(Settings) and (Settings.UseTDpadTime = false)  then
					art := Succ(art); // skip this action.
			end;
		end;

	end
	else
	begin
		// Toggle state using Succ and handling wrapping
		if art = Low(scmActiveRT) then
			art := High(scmActiveRT)
		else
		begin
			art := Pred(art);
			if art = artFinalTime then
			begin
				if Assigned(Settings) and (Settings.UseTDfinalTime = false)  then
					art := Pred(art); // skip this action.
			end;
			if art = artPadTime then
			begin
				if Assigned(Settings) and (Settings.UseTDpadTime = false)  then
					art := Pred(art); // skip this action.
			end;
		end;
	end;

	try
		ADataSet.Edit;
		ADataSet.FieldByName('ActiveRT').AsInteger := ORD(art);
		ADataSet.Post;
		result := art;
	except on E: Exception do
		begin
			ADataSet.Cancel;
		end;
	end;
end;

function TTDS.ToggleWatchTime(ADataSet: TDataSet; idx: integer; art: scmActiveRT): Boolean;
var
s, s2: string;
b: boolean;
begin
	// RANGE : idx in [1..3].
	result := false;

	// Assert state ...
	if not ADataSet.Active then exit;
	if (ADataSet.Name <> 'tblmLane') then exit;
	if not idx in [1..3] then exit;
	if art = artManual  then
		s2 := 'M'
	else if art = artAutomatic  then
		s2 := 'A';
	s := 'T' + IntToStr(idx) + s2;
	b := ADataSet.FieldByName(s).AsBoolean;
	b := not b; // Perform toggle;
	try
		ADataSet.edit;
		ADataSet.FieldByName(s).AsBoolean := b;
		ADataSet.Post;
	finally
		result := b;
	end;
end;

function TTDS.ValidateWatchTime(ADataSet: TDataSet; TimeKeeperIndx: integer;
		art: scmActiveRT): boolean;
var
	TimeField, EnabledField: TField;
begin
	result := false;
	EnabledField := nil;

	if ADataSet.FieldByName('LaneIsEmpty').AsBoolean then exit;

	// Check if TimeKeeperIndx is within the valid range
	if (TimeKeeperIndx < 1) or (TimeKeeperIndx > 3) then
		exit;

	// Determine the field names based on the index
	TimeField := ADataSet.FindField(Format('Time%d', [TimeKeeperIndx]));
	if (art = artManual) then
		EnabledField := ADataSet.FindField(Format('T%dM', [TimeKeeperIndx]))
	else if (art = artAutomatic) then
		EnabledField := ADataSet.FindField(Format('T%dA', [TimeKeeperIndx]));

	// Check if fields are found
	if (TimeField = nil) or (EnabledField = nil) then
		exit;

	try
		// Validate - is the Time Active...
		if not EnabledField.AsBoolean then
			exit;
		// Validate the TTime field value.
		if TimeField.IsNull then
			exit;
		if TimeOf(TimeField.AsDateTime) = 0 then
			exit;

	except
		on E: Exception do
			exit; // Trap any unexpected errors
	end;

	result := true;
end;

procedure TTDS.WriteToBinary(AFileName: string);
var
	myZip: TZipFile;
	memStream: TMemoryStream;

	procedure StreamToZip(AFileName: string; AMemTable: TFDMemTable);
	begin
		memStream := TMemoryStream.Create;
		try
			if not AMemTable.Active then AMemTable.Open;
			AMemTable.SaveToStream(memStream, sfBinary);
			memStream.Position := 0;
			myZip.Add(memStream, AFileName);
		finally
			memStream.Free;
		end;
	end;

begin
	// Create the zip file
	myZip := TZipFile.Create;
	try
		// Open the zip file for writing
		myZip.Open(AFileName, zmWrite);
		DisableAllTDControls;
		DisableTDMasterDetail;
		// Save TFDMemTables to stream and add it to the zip
		StreamToZip('TDSession.fsBinary',tblmSession);
		StreamToZip('TDEvent.fsBinary',tblmEvent);
		StreamToZip('TDHeat.fsBinary',tblmHeat);
		StreamToZip('TDLane.fsBinary',tblmLane);
		StreamToZip('TDNoodle.fsBinary',tblmNoodle);
	finally
		// Close and free the zip file
		EnableTDMasterDetail;
		EnableAllTDControls;
		myZip.Close;
		myZip.Free;
	end;
end;





end.
