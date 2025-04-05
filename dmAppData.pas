unit dmAppData;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, dmSCM,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection, SCMDefines, Windows, Winapi.Messages, vcl.Forms,
  FireDAC.Phys.SQLiteVDataSet, Datasnap.DBClient, FireDAC.Stan.StorageXML,
  FireDAC.Stan.StorageBin, FireDAC.Stan.Storage, Datasnap.Provider,
  SVGIconImageCollection;

type
//  dtFileType = (dtUnknown, dtDO4, dtDO3, dtALL);
  // 5 x modes m-enabled, m-disabled, a-enabled, a-disabled, unknown (err or nil).
  //  dtTimeModeErr = (tmeUnknow, tmeBadTime, tmeExceedsDeviation, tmeEmpty);
//  dtPrecedence = (dtPrecHeader, dtPrecFileName);
  dtActiveRT = (artAutomatic, artManual, artUser, artSplit, artNone);

type

  TWatchTime = class(TObject)
  private
    Times: array[1..3] of variant; // Array to store the times (as Variants).
    Indices: array[1..3] of Integer; // Array to store the original indices
    IsValid: array[1..3] of boolean; // Array to store the validation
    DevOk: array[1..2] of boolean; // Array to store min-mid, mid-max deviations
    fAcceptedDeviation, fAccptDevMsec: double;
    fCalcRTMethod: integer;
    fRaceTime: variant;

    function CnvSecToMsec(ASeconds: double): double;
    function LaneIsEmpty: boolean;
    function IsValidWatchTime(ATime: variant): boolean;
    function CalcAvgWatchTime(): variant;
    function CalcRaceTime: Variant;
    procedure SortWatchTimes();
    procedure ValidateWatchTimes;
    procedure CheckDeviation();
    procedure LoadFromSettings();
  protected

  public
    constructor Create(aVar1, aVar2, aVar3: variant);
    destructor Destroy; override;
    procedure Prepare();
    procedure SyncData(ADataSet: TDataSet);

  end;

  TAppData = class(TDataModule)
    dsmLane: TDataSource;
    dsmEvent: TDataSource;
    dsmHeat: TDataSource;
    dsmSession: TDataSource;
    dsEvent: TDataSource;
    dsHeat: TDataSource;
    dsINDV: TDataSource;
    dsSession: TDataSource;
    dsSessionList: TDataSource;
    dsSwimClub: TDataSource;
    dsTEAM: TDataSource;
    dsTEAMEntrant: TDataSource;
    FDStanStorageBinLink1: TFDStanStorageBinLink;
    FDStanStorageXMLLink1: TFDStanStorageXMLLink;
    imgcolDT: TImageCollection;
    qryDistance: TFDQuery;
    qryEvent: TFDQuery;
    qryHeat: TFDQuery;
    qryINDV: TFDQuery;
    qryNearestSessionID: TFDQuery;
    qrySession: TFDQuery;
    qrySessionList: TFDQuery;
    qrySessionListCaption: TWideStringField;
    qrySessionListClosedDT: TSQLTimeStampField;
    qrySessionListSessionID: TFDAutoIncField;
    qrySessionListSessionStart: TSQLTimeStampField;
    qrySessionListSessionStatusID: TIntegerField;
    qrySessionListSwimClubID: TIntegerField;
    qryStroke: TFDQuery;
    qrySwimClub: TFDQuery;
    qryTEAM: TFDQuery;
    qryTEAMEntrant: TFDQuery;
    SVGIconImageCollection1: TSVGIconImageCollection;
    tblmLane: TFDMemTable;
    tblmEvent: TFDMemTable;
    tblmHeat: TFDMemTable;
    tblmNoodle: TFDMemTable;
    tblmSession: TFDMemTable;
    vimglistDTCell: TVirtualImageList;
    vimglistDTEvent: TVirtualImageList;
    vimglistDTGrid: TVirtualImageList;
    vimglistMenu: TVirtualImageList;
    vimglistStateImages: TVirtualImageList;
    vimglistTreeView: TVirtualImageList;
    qryListSwimmers: TFDQuery;
    qrySplit: TFDQuery;
    qryListTeams: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure tblmHeatAfterScroll(DataSet: TDataSet);
  private
    FConnection: TFDConnection;
    fTDDataIsActive: Boolean;
    fDTMasterDetailActive: Boolean;
    fSCMDataIsActive: Boolean;
    msgHandle: HWND;  // TForm.dtfrmExec ...
    function GetSCMActiveSessionID: integer;
    procedure DeActivateDataSCM();

  public
    procedure ActivateDataDT();
    procedure ActivateDataSCM();
    procedure BuildCSVEventData(AFileName: string);
    procedure BuildAppData;
    // --------------------------------------------
    // Routines ONLY for ActiveRT = dtAutomatic
    // on called on loading of DT file ...
    procedure CalcRaceTimeA(ADataSet: TDataSet; AcceptedDeviation: double;
        CalcMethod: Integer);
    // Routines ONLY for ActiveRT = dtManual
    // For dtAutomatic Racetime, Deviation and validation are perform on
    // loading of the DO file.
    // --------------------------------------------
    procedure CalcRaceTimeM(ADataSet: TDataSet);
    procedure DisableTDMasterDetail();
    procedure EnableTDMasterDetail();
    // MISC SCM ROUTINES/FUNCTIONS
    function GetSCMNumberOfHeats(AEventID: integer): integer;
    function GetSCMRoundABBREV(AEventID: integer): string;

    // L O C A T E S   F O R   D T   D A T A.
    // WARNING : Master-Detail is enabled and locating to an ID isn't garenteed.
    // Use DisableDTMasterDetail() before locating to ID's?
    // USED BY TdtUtils.ProcessSession.
    // .......................................................
    function LocateTSessionID(ASessionID: integer): boolean;
    function LocateTSessionNum(ASessionNum: integer): boolean;
    function LocateTEventID(AEventID: integer): boolean;
    function LocateTEventNum(SessionID, AEventNum: integer): boolean;
    function LocateTHeatID(AHeatID: integer): boolean;
    function LocateTHeatNum(EventID, AHeatNum: integer): boolean;
    function LocateTLaneNum(ALaneNum: integer): boolean;

    // L O C A T E S   F O R   S W I M C L U B M E E T   D A T A.
    // WARNING : Master-Detail enabled...
    // .......................................................
    function LocateSCMEventID(AEventID: integer): boolean;
    function LocateSCMHeatID(AHeatID: integer): boolean;
    // Uses SessionStart TDateTime...
    function LocateSCMNearestSessionID(aDate: TDateTime): integer;
    function LocateSCMSessionID(ASessionID: integer): boolean;
    function LocateSCMLaneNum(ALaneNum: integer; aEventType: scmEventType): boolean;
    // .......................................................

    function SyncDTtoSCM: boolean;
    function SyncSCMtoDT: boolean;
    function SyncCheck: boolean;
    function SyncCheckSession: boolean;

    // .......................................................
    // FIND MAXIMUM IDENTIFIER VALUE IN TIME-DROPS TABLES.
    // These routines are needed as there is no AutoInc on Primary Key.
    // WARNING : DisableDTMasterDetail() before calling MaxID routines.
    // .......................................................
    function MaxID_Lane: integer;
    function MaxID_Event(): integer;
    function MaxID_Heat(): integer;
    function MaxID_Session():integer;

    procedure POST_All;
    procedure POST_Lane(ALane: Integer);

    // Read/Write Application Data State to file
    procedure ReadFromBinary(AFilePath:string);
    // If events, heats, etc change within SwimClubMeet then call here to
    // reload and sync to changes.
    procedure RefreshSCM();

    // SET dtActiveRT : artAutomatic, artManual, artUser, artSplit, artNone
    procedure SetActiveRT(ADataSet: TDataSet; aActiveRT: dtActiveRT);
    function ToggleActiveRT(ADataSet: TDataSet; Direction: Integer = 0): dtActiveRT;
    // toggle [T1M .. T3M] [T1A .. T3A] - TimeKeeper's watch-time 'active state'.
    function ToggleWatchTime(ADataSet: TDataSet; idx: integer; art: dtActiveRT): Boolean;
    // Tests IsEmpty, IsNull, [T1M .. T3M] [T1A .. T3A] STATE.
    function ValidateWatchTime(ADataSet: TDataSet; TimeKeeperIndx: integer; art:
        dtActiveRT): boolean;
    // Read/Write Application Data State to file
    procedure WriteToBinary(AFilePath:string);

    property ActiveSessionID: integer read GetSCMActiveSessionID;
    property Connection: TFDConnection read FConnection write FConnection;
    property TDDataIsActive: Boolean read fTDDataIsActive;
    property DTMasterDetailActive: Boolean read fDTMasterDetailActive;
    property MSG_Handle: HWND read msgHandle write msgHandle;
    property SCMDataIsActive: Boolean read fSCMDataIsActive;
  end;

const
  XMLDataSubFolder = 'GitHub\SCM_TimeDrops\XML\';

var
  AppData: TAppData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses System.Variants, System.DateUtils, tdSetting, System.IOUtils;

function GetDocumentDir_TPath: string;
begin
  Result := TPath.GetDocumentsPath;
  // TPath functions usually don't include the trailing delimiter,
  // add it if you specifically need it.
  Result := IncludeTrailingPathDelimiter(Result);
end;

// Example Usage:
// ShowMessage('Documents folder: ' + GetDocumentDir_TPath);

procedure TAppData.ActivateDataDT;
begin
  fSCMDataIsActive := false;
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
            fSCMDataIsActive := true;
        end;
      end;
    end;
  except on E: Exception do
    // failed to open memory table.
  end;
end;

procedure TAppData.ActivateDataSCM;
begin
  if Assigned(fConnection) and fConnection.Connected then
  begin
    // GRAND MASTER.
    qrySwimClub.Connection := fConnection;
    qrySwimClub.Open;
    if qrySwimClub.Active then
      qrySwimClub.First;

    // Query used by pick session dialogue.
    qrySessionList.Connection := fConnection;
    qrySessionList.Close;
    qrySessionList.ParamByName('SWIMCLUBID').AsInteger :=
      qrySwimClub.FieldByName('SwimClubID').AsInteger;
    qrySessionList.Prepare;
    qrySessionList.Open;
    // Sessions listed are 'OPEN' and reference SwimClubID.
    if qrySessionList.Active and not qrySessionList.IsEmpty then
    begin
      qrySessionList.First;
    end;

    // setup connection for master - detail
    qrySession.Connection := fConnection;
    qryEvent.Connection := fConnection;
    qryDistance.Connection := fConnection;
    qryStroke.Connection := fConnection;
    qryHeat.Connection := fConnection;
    qryINDV.Connection := fConnection;
    qryTEAM.Connection := fConnection;
    qryTEAMEntrant.Connection := fConnection;

    qrySession.Open;

    if qrySwimClub.Active and qrySession.Active then
    begin
      qrySession.First;
      qryEvent.Open;
      qryDistance.Open;
      qryStroke.Open;
      qryHeat.Open;
      qryINDV.Open;
      qryTEAM.Open;
      qryTEAMEntrant.Open;
      fSCMDataIsActive := true;
    end;

  end;
end;

procedure TAppData.BuildCSVEventData(AFileName: string);
var
  sl: TStringList;
  s, s2, s3: string;
  i, id: integer;
begin
{
The Load button lets the user load all event data from an event file.
This is a CSV file and can be hand typed or generated by meet
management software. Each line of this file should be formatted as follows:
Event Number,EventName,Number of Heats,Number of Splits,Round ...

Example:
1A,Boys 50 M Free,4,1,P
1B,Girls 50 M Free,5,1,P
2A,Boys 100 M Breaststroke,2,2,P
2B,Girls 100 M Breaststroke,2,2,P …

The first line will be event index 1, the second line will be event index 2 and so on. Events
will always come up in event index order although this can be overridden and events and
heats may be run in any order.

}
  sl := TStringlist.Create;
  qryEvent.First();
  while not qryEvent.Eof do
  begin
    s := '';
    // Event Number – Up to 5 alpha-numeric characters. Example: 12B ...
    i := qryEvent.FieldByName('EventNum').AsInteger;
    s := s + IntToStr(i) + ',';
    // Event Name – Up to 25 alpha-numeric characters. Example: Men’s 50 Meter Freestyle
    s2 := qryDistance.FieldByName('Caption').AsString + ' ' +
    qryStroke.FieldByName('Caption').AsString;
    s3 := qryEvent.FieldByName('Caption').AsString;
    if Length(s3) > 0 then
      s2 := s2 + ' ' + s3;
    s := s + s2 + ',';
    // Get Number of Heats
    // Number of Heats – (0-99) Number of expected heats for the given event
    id := qryEvent.FieldByName('EventID').AsInteger;
    i := GetSCMNumberOfHeats(id);
    s := s + IntToStr(i) + ',';
    { TODO -oBSA : Implement Splits for TIME-DROPS }
    // Number of Splits - NOT AVAILABLE IN THIS VERSION.
    s := s + '0,';
    { Round .... requires db v1.1.5.4.
    * A: ALL  (CTS DOLPHIN - ref F912 ).
    * P: Preliminary (DEFAULT)
    * Q: Quarterfinals
    * S: Semifinals
    * F: Finals
    }
    // Round – “A” for all, “P” for prelim or “F” for final
    s := s + 'P';
    sl.Add(s);
    qryEvent.Next;
  end;
  qryEvent.First();
  if not sl.IsEmpty then
    sl.SaveToFile(AFileName);
  sl.free;
end;

procedure TAppData.BuildAppData;
var
fn: TFileName;
begin
  fSCMDataIsActive := false;
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
  tblmLane.FieldDefs.Add('Split1', ftTime); // DO4.
  tblmLane.FieldDefs.Add('Split2', ftTime); // DO4.
  tblmLane.FieldDefs.Add('Split3', ftTime); // DO4.
  tblmLane.FieldDefs.Add('Split4', ftTime); // DO4.
  tblmLane.FieldDefs.Add('Split5', ftTime); // DO4.
  tblmLane.FieldDefs.Add('Split6', ftTime); // DO4.
  tblmLane.FieldDefs.Add('Split7', ftTime); // DO4.
  tblmLane.FieldDefs.Add('Split8', ftTime); // DO4.
  tblmLane.FieldDefs.Add('Split9', ftTime); // DO4.
  tblmLane.FieldDefs.Add('Split10', ftTime); // DO4.

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
  // dtEntrant - Route to lane/timekeepers/splits details
  tblmNoodle.FieldDefs.Add('EntrantID', ftInteger);
  // dtEntrant.Lane - Quick lookup. Improve search times?
  tblmNoodle.FieldDefs.Add('Lane', ftInteger);
  // LINK TO SwimClubMeet DATA
  // An entrant may be INDV or TEAM event.
  tblmNoodle.FieldDefs.Add('SCM_EventTypeID', ftInteger);
  // Route to individual entrant.
  tblmNoodle.FieldDefs.Add('SCM_INDVID', ftInteger);
  // Route to team (relay-team) entrant.
  tblmNoodle.FieldDefs.Add('SCM_TEAMID', ftInteger);
  // Quick lookup?
  tblmNoodle.FieldDefs.Add('SCM_Lane', ftInteger);
  tblmNoodle.CreateDataSet;
{$IFDEF DEBUG}
  // save schema ...
  fn := GetDocumentDir_TPath() +  XMLDataSubFolder + 'AppDataNoodle.xml';
  tblmNoodle.SaveToFile(fn, sfAuto);
{$ENDIF}

end;

procedure TAppData.CalcRaceTimeA(ADataSet: TDataSet; AcceptedDeviation: double;
    CalcMethod: Integer);
var
  wt: TWatchtime;
begin
  wt := TWatchTime.Create(ADataSet.FieldByName('Time1').AsVariant,
                ADataSet.FieldByName('Time2').AsVariant,
                ADataSet.FieldByName('Time3').AsVariant);
  wt.Prepare;
  wt.SyncData(ADataSet);
  wt.free;
end;

procedure TAppData.CalcRaceTimeM(ADataSet: TDataSet);
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

procedure TAppData.DataModuleCreate(Sender: TObject);
begin
  // Init params.
  fTDDataIsActive := false;
  fDTMasterDetailActive := false;
  FConnection := nil;
  fSCMDataIsActive := false; // activated later once FConnection is assigned.

  { These actions occur when TimeDrops Button is pressed. See tdLogin}
  //  EnableTDMasterDetail();
  //  ActivateDataDT;

  msgHandle := 0;
end;

procedure TAppData.DataModuleDestroy(Sender: TObject);
begin
  DeActivateDataSCM;
end;

procedure TAppData.DeActivateDataSCM;
begin
  if Assigned(fConnection) and fConnection.Connected then
  begin
    fSCMDataIsActive := false;
    qryTEAMEntrant.Close; // Detail of TEAM
    qryTEAM.Close;  // Detail of Heat
    qryINDV.Close;  // Detail of Heat
    qryHeat.Close;  // Detail of event
    qryStroke.Close; // Detail of event
    qryDistance.Close;  // Detail of event
    qryEvent.Close;
    qrySession.Close;
    qrySessionList.Close; // Query used by pick session dialogue.
    qrySwimClub.Close;  // GRAND MASTER.
  end;
end;

procedure TAppData.DisableTDMasterDetail();
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
  tblmEvent.ApplyMaster;
  tblmEvent.First;
  tblmHeat.ApplyMaster;
  tblmHeat.First;
  tblmLane.ApplyMaster;
  tblmLane.First;
  tblmNoodle.ApplyMaster;
  tblmNoodle.First;

  fDTMasterDetailActive := false;
end;

procedure TAppData.EnableTDMasterDetail();
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
  tblmSession.First;
  fDTMasterDetailActive := true;
end;

function TAppData.GetSCMActiveSessionID: integer;
begin
  result := 0;
  if not fSCMDataIsActive then exit;
  if qrySession.Active and not qrySession.IsEmpty then
    result := qrySession.FieldByName('SessionID').AsInteger;
end;

function TAppData.GetSCMNumberOfHeats(AEventID: integer): integer;
var
SQL: string;
v: variant;
begin
  result := 0;
  SQL := 'SELECT COUNT(HeatID) FROM dbo.HeatIndividual WHERE EventID = :ID;';
  v := AppData.Connection.ExecSQLScalar(SQL, [AEventID]);
  if VarIsNull(v) or VarIsEmpty(v) or (v=0)  then exit;
  result := v;
end;

function TAppData.GetSCMRoundABBREV(AEventID: integer): string;
var
SQL: string;
v: variant;
ARoundID: integer;
begin
  {
  SwimClubMeet.dbo.Round database version 1.1.5.4
  SQL := 'SELECT [ABREV] FROM dbo.Round WHERE RoundID = :ID'
  * P: Preliminary (DEFAULT)
  * Q: Quarterfinals
  * S: Semifinals
  * F: Finals
  }
  result := 'P';
  SQL := 'SELECT [RoundID] FROM dbo.Event WHERE EventID = :ID;';
  v := AppData.Connection.ExecSQLScalar(SQL, [AEventID]);
  if VarIsNull(v) or VarIsEmpty(v) or (v=0)  then exit;
  ARoundID := v;

  SQL := 'SELECT [ABREV] FROM dbo.Round WHERE RoundID = :ID;';
  v := AppData.Connection.ExecSQLScalar(SQL, [ARoundID]);
  if VarIsNull(v) or VarIsEmpty(v) then exit;
  result := v;

end;

function TAppData.LocateTEventID(AEventID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tblmHeat.Active then exit;
  if (AEventID = 0) then exit;
  SearchOptions := [];
  result := dsmEvent.DataSet.Locate('EventID', AEventID, SearchOptions);
  if result then
    dsmHeat.DataSet.Refresh;
end;

function TAppData.LocateTEventNum(SessionID, AEventNum: integer): boolean;
var
  indexStr: string;
begin
  // WARNING : DisableDTMasterDetail() before calling here.
  // USED ONLY BY TdtUtils.ProcessEvent.
  result := false;
  // Exit if the table is not active or if AEventNum is 0
  if not tblmEvent.Active then exit;
  if AEventNum = 0 then exit;
  // Store the original index field names
  indexStr := tblmEvent.IndexFieldNames;
  tblmEvent.IndexFieldNames := 'EventID';
  result := tblmEvent.Locate('SessionID;EventNum', VarArrayOf([SessionID, AEventNum]), []);
  // Restore the original index field names
  tblmEvent.IndexFieldNames := indexStr;
end;

function TAppData.LocateTHeatID(AHeatID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tblmHeat.Active then exit;
  if (AHeatID = 0) then exit;
  SearchOptions := [];
  result := dsmHeat.DataSet.Locate('HeatID', AHeatID, SearchOptions);
end;

function TAppData.LocateTHeatNum(EventID, AHeatNum: integer): boolean;
var
  indexStr: string;
begin
  // WARNING : DisableDTMasterDetail() before calling here.
  // USED ONLY BY TdtUtils.ProcessHeat.
  result := false;
  // Exit if the table is not active or if AHeatNum is 0
  if not tblmHeat.Active then exit;
  if AHeatNum = 0 then exit;
  // Store the original index field names
  indexStr := tblmHeat.IndexFieldNames;
  tblmHeat.IndexFieldNames := 'HeatID';
  result := tblmHeat.Locate('EventID;HeatNum', VarArrayOf([EventID, AHeatNum]), []);
  // Restore the original index field names
  tblmHeat.IndexFieldNames := indexStr;
end;

function TAppData.LocateTLaneNum(ALaneNum: integer): boolean;
begin
  // IGNORES SYNC STATE...
  result := tblmLane.Locate('LaneNum', ALaneNum, []);
end;

function TAppData.LocateTSessionID(ASessionID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tblmSession.Active then exit;
  if (ASessionID = 0) then exit;
  SearchOptions := [];
  result := dsmSession.DataSet.Locate('SessionID', ASessionID, SearchOptions);
  if result then
  begin
    dsmEvent.DataSet.Refresh;
    dsmHeat.DataSet.Refresh;
  end;
end;

function TAppData.LocateTSessionNum(ASessionNum: integer): boolean;
var
  indexStr: string;
begin
  // WARNING : DisableDTMasterDetail() before calling here.
  // USED ONLY BY TdtUtils.ProcessSession
  result := false;
  if not tblmSession.Active then exit;
  if ASessionNum = 0 then exit;
  // Store the original index field names
  indexStr := tblmSession.IndexFieldNames;
  if (ASessionNum = 0) then exit;
  tblmSession.IndexFieldNames := 'SessionID';
  result := tblmSession.Locate('SessionNum', ASessionNum, []);
  // Restore the original index field names
  tblmSession.IndexFieldNames := indexStr;
end;

function TAppData.LocateSCMEventID(AEventID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fSCMDataIsActive then exit;
  if (aEventID = 0) then exit;
  SearchOptions := [];
  if dsEvent.DataSet.Active then
      result := dsEvent.DataSet.Locate('EventID', aEventID, SearchOptions);
end;

function TAppData.LocateSCMHeatID(AHeatID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fSCMDataIsActive then exit;
  if (AHeatID = 0) then exit;
  SearchOptions := [];
  if dsHeat.DataSet.Active then
      result := dsHeat.DataSet.Locate('HeatID', AHeatID, SearchOptions);
end;

function TAppData.LocateSCMLaneNum(ALaneNum: integer; aEventType:
    scmEventType): boolean;
var
found: boolean;
begin
  // IGNORES SYNC STATE...
  found := false;
  case aEventType of
    etUnknown:
      found := false;
    etINDV:
      found := qryINDV.Locate('Lane', ALaneNum, []);
    etTEAM:
      found := qryTEAM.Locate('Lane', ALaneNum, []);
  end;
  result := found;
end;

function TAppData.LocateSCMNearestSessionID(aDate: TDateTime): integer;
begin
  result := 0;
  // find the session with 'aDate' or bestfit.
  qryNearestSessionID.Connection := fConnection;
  qryNearestSessionID.ParamByName('ADATE').AsDateTime := DateOf(aDate);
  qryNearestSessionID.Prepare;
  qryNearestSessionID.Open;
  if not qryNearestSessionID.IsEmpty then
   result := qryNearestSessionID.FieldByName('SessionID').AsInteger;
end;

function TAppData.LocateSCMSessionID(ASessionID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fSCMDataIsActive then exit;
  if (ASessionID = 0) then exit;
  SearchOptions := [];
  if dsSession.DataSet.Active then
      result := dsSession.DataSet.Locate('SessionID', ASessionID, SearchOptions);
end;

function TAppData.MaxID_Lane: integer;
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

function TAppData.MaxID_Event: integer;
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

function TAppData.MaxID_Heat: integer;
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

function TAppData.MaxID_Session: integer;
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

procedure TAppData.POST_All;
var
  AEventType: scmEventType;
  ALaneNum: integer;
begin
  qryINDV.DisableControls;
  qryTEAM.DisableControls;
  tblmLane.DisableControls;

  AEventType := scmEventType(qryDistance.FieldByName('EventTypeID').AsInteger);

  // ONE TO ONE SYNC....
  tblmLane.First;
  while not (tblmLane.eof or qryINDV.eof) do
  begin
    ALaneNum := tblmLane.FieldByName('Lane').AsInteger;
    if LocateSCMLaneNum(ALaneNum, AEventType) then
    begin
      if AEventType = etINDV then
      begin
        // can't post a time to a lane with no swimmer!
        if not qryINDV.FieldByName('MemberID').IsNull then
        begin
          qryINDV.Edit;
          qryINDV.FieldByName('RaceTime').AsDateTime :=
          tblmLane.FieldByName('RaceTime').AsDateTime;
          qryINDV.Post;
        end;
      end
      else if AEventType = etTEAM then
      begin
        // can't post a time to a lane that doesn't have a relay team.
        if not qryINDV.FieldByName('TeamNameID').IsNull then
        begin
          qryTEAM.Edit;
          qryTEAM.FieldByName('RaceTime').AsDateTime :=
          tblmLane.FieldByName('RaceTime').AsDateTime;
          qryTEAM.Post;
        end;
      end;
    end;
    tblmLane.Next;
  end;
  if AEventType = etINDV then
    qryINDV.First
  else if AEventType = etTEAM then
    qryTEAM.First;
  tblmLane.First;
  tblmLane.EnableControls;
  qryTEAM.EnableControls;
  qryINDV.EnableControls;

end;

procedure TAppData.POST_Lane(ALane: Integer);
var
  AEventType: scmEventType;
  b1, b2: boolean;
begin
  qryINDV.DisableControls;
  qryTEAM.DisableControls;
  tblmLane.DisableControls;
  AEventType := scmEventType(qryDistance.FieldByName('EventTypeID').AsInteger);
  // SYNC to ROW ...
  b1 := LocateTLaneNum(ALane);
  b2 := LocateSCMLaneNum(ALane, AEventType);
  if (b1 and b2) then
  begin
      if AEventType = etINDV then
      begin
        // can't post a time to a lane with no swimmer!
        if not qryINDV.FieldByName('MemberID').IsNull then
        begin
          qryINDV.Edit;
          qryINDV.FieldByName('RaceTime').AsDateTime :=
          tblmLane.FieldByName('RaceTime').AsDateTime;
          qryINDV.Post;
        end;
      end
      else if AEventType = etTEAM then
      begin
        // can't post a time to a lane that doesn't have a relay team.
        if not qryINDV.FieldByName('TeamNameID').IsNull then
        begin
          qryTEAM.Edit;
          qryTEAM.FieldByName('RaceTime').AsDateTime :=
          tblmLane.FieldByName('RaceTime').AsDateTime;
          qryTEAM.Post;
        end;
      end;
  end;
  tblmLane.EnableControls;
  qryTEAM.EnableControls;
  qryINDV.EnableControls;
end;

procedure TAppData.ReadFromBinary(AFilePath:string);
var
s: string;
begin
  if Length(AFilePath) > 0 then
    // Assert that the end delimiter is attached
    s := IncludeTrailingPathDelimiter(AFilePath)
  else
    s := ''; // or handle this case if the path is mandatory
  tblmSession.LoadFromFile(s + 'DTMaster.fsBinary');
  tblmEvent.LoadFromFile(s + 'DTEvent.fsBinary');
  tblmHeat.LoadFromFile(s + 'DTHeat.fsBinary');
  tblmLane.LoadFromFile(s + 'DTLane.fsBinary');
  tblmNoodle.LoadFromFile(s + 'DTNoodle.fsBinary');
end;

procedure TAppData.RefreshSCM;
var
  ASwimClubID, ASessionID, AEventID, AHeatID: integer;
begin
  qryTEAM.DisableControls;
  qryINDV.DisableControls;
  qryHeat.DisableControls;
  qryEvent.DisableControls;
  qrySession.DisableControls;
  qrySwimClub.DisableControls;

  // Store database record position(s).
  ASwimClubID := qrySwimClub.FieldByName('SwimClubID').AsInteger;
  ASessionID := qrySession.FieldByName('SessionID').AsInteger;
  AEventID := qryEvent.FieldByName('EventID').AsInteger;
  AHeatID := qryHeat.FieldByName('HeatID').AsInteger;
  // close
  DeActivateDataSCM;
  // open : assign connection : assert Master-Detail, etc.
  ActivateDataSCM;
  // cue-to-record : locate.
  if qrySwimClub.Locate('SwimClubID', ASwimClubID, []) then
  begin
    qrySession.ApplyMaster;
    if LocateSCMSessionID(ASessionID) then
    begin
      qryEvent.ApplyMaster;
      if LocateSCMEventID(AEventID) then
      begin
        qryHeat.ApplyMaster;
        if not LocateSCMHeatID(AHeatID) then
          qryHeat.First;
      end
      else
      begin
        qryEvent.First;
      end;
    end;
  end;
  // cue-to-lane 1
  qryINDV.first;
  qryTEAM.first;

  qrySwimClub.EnableControls;
  qrySession.EnableControls;
  qryEvent.EnableControls;
  qryHeat.EnableControls;
  qryINDV.EnableControls;
  qryTEAM.EnableControls;

end;

procedure TAppData.SetActiveRT(ADataSet: TDataSet; aActiveRT: dtActiveRT);
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
            ADataSet.fieldbyName('imgActiveRT').AsInteger := 2;
            if ADataSet.FieldByName('RaceTimeA').IsNull then
              ADataSet.FieldByName('RaceTime').Clear
            else
              ADataSet.FieldByName('RaceTime').AsVariant :=
              ADataSet.FieldByName('RaceTimeA').AsVariant;
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
          ADataSet.fieldbyName('imgActiveRT').AsInteger := 5;
          ADataSet.FieldByName('RaceTime').Clear;
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

function TAppData.SyncDTtoSCM: boolean;
var
  found: boolean;
begin
  result := false;
  tblmEvent.DisableControls;
  tblmHeat.DisableControls;
  tblmLane.DisableControls;
  tblmSession.DisableControls;
  // NOTE : SCM Sesssion ID = DT SessionNum.
  found :=
  LocateTSessionNum(qrySession.FieldByName('SessionID').AsInteger);
  tblmEvent.ApplyMaster;
  if found then
  begin
    found := tblmEvent.Locate('EventNum',
        qryEvent.FieldByName('EventNum').AsInteger);
    tblmHeat.ApplyMaster;
    if found then
    begin
      found := tblmHeat.Locate('HeatNum',
          qryHeat.FieldByName('HeatNum').AsInteger);
      tblmLane.ApplyMaster;
      if found then
        result := true;
    end;
  end;
  tblmSession.EnableControls;
  tblmEvent.EnableControls;
  tblmHeat.EnableControls;
  tblmLane.EnableControls;
end;

function TAppData.SyncCheck: boolean;
var
  IsSynced: boolean;
begin
  IsSynced := false;
  if qrySession.FieldByName('SessionID').AsInteger =
  tblmSession.FieldByName('SessionNum').AsInteger then
    if qryEvent.FieldByName('EventNum').AsInteger =
    tblmEvent.FieldByName('EventNum').AsInteger then
      if qryHeat.FieldByName('HeatNum').AsInteger =
      tblmHeat.FieldByName('HeatNum').AsInteger then
        IsSynced := true;
  result := IsSynced;
end;

function TAppData.SyncCheckSession: boolean;
var
  sessNum: integer;
begin
  result := false;
  sessNum := tblmSession.FieldByName('SessionNum').AsInteger;
  if qrySession.FieldByName('SessionID').AsInteger = sessNum then
    result := true;
end;

function TAppData.SyncSCMtoDT: boolean;
var
  found: boolean;
begin
  result := false;
  found := false;

  if not SyncCheckSession() then exit;

  qryTEAM.DisableControls;
  qryINDV.DisableControls;
  qryHeat.DisableControls;
  qryEvent.DisableControls;
  qrySession.DisableControls;

  if qryEvent.Locate('EventNum', tblmEvent.FieldByName('EventNum').AsInteger, [])
  then
    found := qryHeat.Locate('HeatNum', tblmHeat.FieldByName('HeatNum')
      .AsInteger, []);

  result := found;
  qrySession.EnableControls;
  qryEvent.EnableControls;
  qryHeat.EnableControls;
  qryINDV.EnableControls;
  qryTEAM.EnableControls;
end;


procedure TAppData.tblmHeatAfterScroll(DataSet: TDataSet);
begin
  if (msgHandle <> 0) then
    PostMessage(msgHandle, SCM_UPDATEUI3, 0,0);
end;

function TAppData.ToggleActiveRT(ADataSet: TDataSet; Direction: Integer = 0):
dtActiveRT;
var
  art: dtActiveRT;
begin
  result := artNone;
  if not ADataSet.Active then exit;
  if not (ADataSet.Name = 'tblmLane') then exit;
  // Get the current ActiveRT value
  art := dtActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
  if (Direction = 0) then
  begin
    // Toggle state using Succ and handling wrapping
    if art = High(dtActiveRT) then
      art := Low(dtActiveRT)
    else
      art := Succ(art);
  end
  else
  begin
    // Toggle state using Succ and handling wrapping
    if art = Low(dtActiveRT) then
      art := High(dtActiveRT)
    else
      art := Pred(art);
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

function TAppData.ToggleWatchTime(ADataSet: TDataSet; idx: integer; art: dtActiveRT): Boolean;
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

function TAppData.ValidateWatchTime(ADataSet: TDataSet; TimeKeeperIndx: integer;
    art: dtActiveRT): boolean;
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

procedure TAppData.WriteToBinary(AFilePath:string);
var
s: string;
begin
  if Length(AFilePath) > 0 then
    // Assert that the end delimiter is attached
    s := IncludeTrailingPathDelimiter(AFilePath)
  else
    s := ''; // or handle this case if the path is mandatory
  tblmSession.SaveToFile(s + 'DTMaster.fsBinary', sfXML);
  tblmEvent.SaveToFile(s + 'DTEvent.fsBinary', sfXML);
  tblmHeat.SaveToFile(s + 'DTHeat.fsBinary', sfXML);
  tblmLane.SaveToFile(s + 'DTLane.fsBinary', sfXML);
  tblmNoodle.SaveToFile(s + 'DTNoodle.fsBinary', sfXML);
end;

{ TWatchTime }

function TWatchTime.CalcAvgWatchTime: variant;
var
  I, C: Integer;
  t: variant;
begin
  // call ValidateWatchTimes prior to calling here.
  t := 0;
  c := 0;
  for I := 1 to 3 do
  begin
    if IsValid[I] then
    begin
      t := t + Times[I];
      inc(c);
    end;
  end;
  if c > 0 then
    result := t / c
  else
    result := 0;
end;

function TWatchTime.CalcRaceTime: Variant;
var
I, count: integer;

begin

  {
  RULES USED BY 'DOLPHIN TIMING' METHOD. (DEFAULT).
- A. If there is one watch per lane, that time will also be placed in
  'racetime'.

- B. If there are two watches for a given lane, the average will be
  computed and placed in 'racetime'.

- C. If there are 3 watch times for a given lane, the middle time will be
  placed in 'racetime'.

  CASE B. NOTE:
  If there is more than the 'Accepted Deviation' difference between the
  two watch times, the average result time will NOT be computed and
  warning icons will show for both watch times in this lane.
  The 'RaceTime' will be empty.
  Switch to manaul mode and select which time to use.
  You are permitted to select both - in which case a average of the
  two watch times is used in 'racetime' .

  }
  {
    RULES USED BY SWIMCLUBMEET METHOD.
    The average is always used - for 2x or 3x watch-times.
    Deviation between 3xwatch-times is always checked and swimclubmeet may
    concluded that all watch-times should be dropped!
  }

  result := null;
  count := 0;
  for I := 1 to 3 do
    if IsValid[I] then inc(count);

  case count of
  0:
    ;
  1:
    BEGIN
      for I := 1 to 3 do
        if IsValid[I] then
        begin
          result := Times[I]; // NOTE: deviation is ignored.
          break;
        end;
    END;
  2:
    // if deviation is within accepted value.
    if DevOk[1] then
      result := CalcAvgWatchTime;
  3:
    BEGIN
      // TIMING RULES - use mid watch-time.
      if (fCalcRTMethod = 0) then
      begin
        if IsValid[2] then
          // The middle time is the second element in the sorted array
          result := times[2];
      end
      // SwimClubMeet RULES - assert deviation and find use average.
      else
      begin
        if DevOk[1] and DevOk[2] then
          result := CalcAvgWatchTime
        else if DevOk[1] then
          result := (Times[1]+Times[2])/2.0
        else if DevOk[2] then
          result := (Times[2]+Times[3])/2.0;
      end;
    END
  END;

end;

procedure TWatchTime.CheckDeviation;
var
I, j, count: integer;
t1, t2: TTime;
GapA, GapB: double;
begin
  // prior to calling here call SortWatchTimes ... ValidWatchTimes ...
  count := 0;
  // reset accepted deviation state;
  for I := 1 to 3 do
    if IsValid[I] then inc(count);

  DevOk[1] := false;
  DevOk[2] := false;

  case count of
  0, 1: // LANE IS EMPTY or Single watch time.
    ; // there is no deviation gap to calculate.
  2:
    BEGIN
      j := 0;
      t1:=0;
      // Loop through array to find the 2 valid watch times.
      for I := 1 to 3 do
      begin
        if IsValid[I] then
        begin
          if j = 0 then
          begin
            t1 := TimeOf(Times[I]);
          end
          else if j = 1 then
          begin
            t2 := TimeOf(Times[I]);
            // Calculate deviation between the two valid times
            GapA := MilliSecondsBetween(t1, t2);
            // Check if the deviation is acceptable
            if GapA <= fAccptDevMsec then
              DevOk[1] := true;
            break;
          end;
          Inc(j);
        end;
      end;
    END;

    3:
    BEGIN
      { Timing doesn't consider check deviation on 3xwatch-times
        and instead picks the middle watch time.
      }
      if (fCalcRTMethod = 0) then
      Begin
      End;
      if (fCalcRTMethod = 1) then
      Begin
        // Calculate deviation between the two valid times
        GapA := MilliSecondsBetween(Times[2], Times[1]);
        // Calculate deviation between the two valid times
        GapB := MilliSecondsBetween(Times[3],Times[2]);

        // Check if the deviation is acceptable
        if (GapA >= fAccptDevMsec) AND (GapB >= fAccptDevMsec) then
        begin
          // Both deviations exceed the limit. Ambiguous issue.
          ;
        end
        else if (GapA <= fAccptDevMsec) then
          // If false - likely issue with MinTime index
          DevOk[1] := true
        else if (GapB <= fAccptDevMsec) then
          // If false - likely issue with MaxTime index
          DevOk[2] := true;
      End;
    END;
  end;
end;

function TWatchTime.CnvSecToMsec(ASeconds: double): double;
begin
  { A TDateTime value is essentially a double, where the integer part is the
      number of days and fraction is the time.
    In a day there are 24*60*60 = 86400 seconds (SecsPerDay constant
      declared in SysUtils) so to get AcceptedDeviation (given in seconds)
      as TDateTime do:
  }
  if fAcceptedDeviation = 0 then fAcceptedDeviation := 0.3;
  // Convert AcceptedDeviation from seconds to milliseconds
  result := fAcceptedDeviation * 1000;
end;

constructor TWatchTime.Create(aVar1, aVar2, aVar3: variant);
begin
  inherited Create;
  Times[1] := aVar1;
  Times[2] := aVar2;
  Times[3] := aVar3;
  Indices[1] := 1;
  Indices[2] := 2;
  Indices[3] := 3;
  DevOk[1] := false;
  DevOk[2] := false;
  IsValid[1] := false;
  IsValid[2] := false;
  IsValid[3] := false;
  fAcceptedDeviation := 0;
  fRaceTime := null;
end;

destructor TWatchTime.Destroy;
begin

  inherited;
end;

function TWatchTime.IsValidWatchTime(ATime: variant): boolean;
begin
  result := false;
  if VarIsEmpty(ATime) then exit;
  if VarIsNull(ATime) then exit;
  if (ATime = 0) then exit;
  result := true;
end;

function TWatchTime.LaneIsEmpty: boolean;
var
I: integer;
begin
  result := true;
  ValidateWatchTimes;
  for I := 1 to 3 do
    if isValid[I] then
    begin
      result := false;
      break;
    end;
end;

procedure TWatchTime.LoadFromSettings;
begin
  if Settings <> nil then
  begin
    fAcceptedDeviation := Settings.AcceptedDeviation;
    fCalcRTMethod := Settings.CalcRTMethod;
  end
  else
  begin
    fAcceptedDeviation := 0.3;
    fCalcRTMethod := 0; // default - Timing Method.
  end;
end;

procedure TWatchTime.Prepare();
begin
  LoadFromSettings; // loads the accepted deviation gap for watch times.
  fAccptDevMsec := CnvSecToMsec(fAcceptedDeviation);
  SortWatchTimes;
  ValidateWatchTimes;
  CheckDeviation;
  fRaceTime := CalcRaceTime;
end;

procedure TWatchTime.SortWatchTimes;
var
I, J: integer;
TempTime: Variant;
TempIndex: integer;
TempBool: boolean;
begin
  // Sort the Times array and keep the Indices array in sync
  for i := 1 to 2 do
  begin
    for j := i + 1 to 3 do
    begin
      if Times[i] > Times[j] then
      begin
        // Swap Times
        TempTime := Times[i];
        Times[i] := Times[j];
        Times[j] := TempTime;
        // Swap corresponding Indices
        TempIndex := Indices[i];
        Indices[i] := Indices[j];
        Indices[j] := TempIndex;
        // Swap corresponding IsValid state. (boolean)
        TempBool := IsValid[i];
        IsValid[i] := IsValid[j];
        IsValid[j] := TempBool;
      end;
    end;
  end;
end;

procedure TWatchTime.SyncData(ADataSet: TDataSet);
var
  I, J: integer;
begin
  ADataSet.Edit;
  try
    ADataSet.FieldByName('LaneIsEmpty').AsBoolean := LaneIsEmpty;
    for I := 1 to 3 do
    begin
      j := Indices[I];
      case j of
      1:
        ADataSet.FieldByName('T1A').AsBoolean := IsValid[I];
      2:
        ADataSet.FieldByName('T2A').AsBoolean := IsValid[I];
      3:
        ADataSet.FieldByName('T3A').AsBoolean := IsValid[I];
      end;
    end;

    // deviation status min-mid.
    ADataSet.FieldByName('TDev1').AsBoolean := DevOk[1];
    // deviation status mid-max.
    ADataSet.FieldByName('TDev2').AsBoolean := DevOk[2];

    if LaneIsEmpty then
      ADataSet.FieldByName('RaceTimeA').Clear
    else
    begin
      fRaceTime := CalcRaceTime;
      if VarIsNull(fRaceTime)  then
        ADataSet.FieldByName('RaceTimeA').Clear
      else
      ADataSet.FieldByName('RaceTimeA').AsDateTime := TimeOf(fRaceTime);
    end;

    ADataSet.Post;
  except on E: Exception do
    ADataSet.Cancel;
  end;
end;

procedure TWatchTime.ValidateWatchTimes;
var
I: Integer;
begin
  for I := 1 to 3 do
  begin
    // Validate time and set IsValidWatchTime state.
    isValid[I] := IsValidWatchTime(Times[I]);
  end;
end;

end.
