unit dmTDData;

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
  dtFileType = (dtUnknown, dtDO4, dtDO3, dtALL);
  // 5 x modes m-enabled, m-disabled, a-enabled, a-disabled, unknown (err or nil).
  //  dtTimeModeErr = (tmeUnknow, tmeBadTime, tmeExceedsDeviation, tmeEmpty);
  dtPrecedence = (dtPrecHeader, dtPrecFileName);
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

  TDTData = class(TDataModule)
    dsDTEntrant: TDataSource;
    dsDTEvent: TDataSource;
    dsDTHeat: TDataSource;
    dsDTSession: TDataSource;
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
    tblDTEntrant: TFDMemTable;
    tblDTEvent: TFDMemTable;
    tblDTHeat: TFDMemTable;
    tblDTNoodle: TFDMemTable;
    tblDTSession: TFDMemTable;
    vimglistDTCell: TVirtualImageList;
    vimglistDTEvent: TVirtualImageList;
    vimglistDTGrid: TVirtualImageList;
    vimglistMenu: TVirtualImageList;
    vimglistStateImages: TVirtualImageList;
    vimglistTreeView: TVirtualImageList;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure tblDTHeatAfterScroll(DataSet: TDataSet);
  private
    FConnection: TFDConnection;
    fDTDataIsActive: Boolean;
    fDTMasterDetailActive: Boolean;
    fSCMDataIsActive: Boolean;
    msgHandle: HWND;  // TForm.dtfrmExec ...
    function GetSCMActiveSessionID: integer;
    procedure DeActivateDataSCM();

  public
    procedure ActivateDataDT();
    procedure ActivateDataSCM();
    procedure BuildCSVEventData(AFileName: string);
    procedure BuildDTData;
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
    procedure DisableDTMasterDetail();
    procedure EnableDTMasterDetail();
    // MISC SCM ROUTINES/FUNCTIONS
    function GetSCMNumberOfHeats(AEventID: integer): integer;
    function GetSCMRoundABBREV(AEventID: integer): string;

    // L O C A T E S   F O R   D T   D A T A.
    // WARNING : Master-Detail is enabled and locating to an ID isn't garenteed.
    // Use DisableDTMasterDetail() before locating to ID's?
    // USED BY TdtUtils.ProcessSession.
    // .......................................................
    function LocateDTSessionID(ASessionID: integer): boolean;
    function LocateDTSessionNum(ASessionNum: integer; Aprecedence: dtPrecedence):
        boolean;
    function LocateDTEventID(AEventID: integer): boolean;
    function LocateDTEventNum(SessionID, AEventNum: integer; Aprecedence: dtPrecedence):
        boolean;
    function LocateDTHeatID(AHeatID: integer): boolean;
    function LocateDTHeatNum(EventID, AHeatNum: integer; Aprecedence: dtPrecedence):
        boolean;
    function LocateDTLane(ALane: integer): boolean;

    // L O C A T E S   F O R   S W I M C L U B M E E T   D A T A.
    // WARNING : Master-Detail enabled...
    // .......................................................
    function LocateSCMEventID(AEventID: integer): boolean;
    function LocateSCMHeatID(AHeatID: integer): boolean;
    // Uses SessionStart TDateTime...
    function LocateSCMNearestSessionID(aDate: TDateTime): integer;
    function LocateSCMSessionID(ASessionID: integer): boolean;
    function LocateSCMLane(ALane: integer; aEventType: scmEventType): boolean;
    // .......................................................

    function SyncDTtoSCM(APrecedence: dtPrecedence): boolean;
    function SyncSCMtoDT(APrecedence: dtPrecedence): boolean;
    function SyncCheck(APrecedence: dtPrecedence): boolean;
    function SyncCheckSession(APrecedence: dtPrecedence): boolean;

    // .......................................................
    // FIND MAXIMUM IDENTIFIER VALUE IN DOLPHIN TIMING TABLES.
    // These routines are needed as there is no AutoInc on Primary Key.
    // WARNING : DisableDTMasterDetail() before calling MaxID routines.
    // .......................................................
    function MaxID_Entrant: integer;
    function MaxID_Event(): integer;
    function MaxID_Heat(): integer;
    function MaxID_Session():integer;

    procedure POST_All;
    procedure POST_Lane(ALane: Integer);

    // Read/Write DTData State to file
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
    // Read/Write DTData State to file
    procedure WriteToBinary(AFilePath:string);

    property ActiveSessionID: integer read GetSCMActiveSessionID;
    property Connection: TFDConnection read FConnection write FConnection;
    property DTDataIsActive: Boolean read fDTDataIsActive;
    property DTMasterDetailActive: Boolean read fDTMasterDetailActive;
    property MSG_Handle: HWND read msgHandle write msgHandle;
    property SCMDataIsActive: Boolean read fSCMDataIsActive;
  end;

var
  DTData: TDTData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses System.Variants, System.DateUtils, dtuSetting;


procedure TDTData.ActivateDataDT;
begin
  fSCMDataIsActive := false;
  // MAKE LIVE THE DOLPHIN TIMING TABLES
  try
    tblDTSession.Open;
    if tblDTSession.Active then
    begin
      tblDTEvent.Open;
      if tblDTEvent.Active then
      begin
        tblDTHeat.Open;
        if tblDTHeat.Active then
        begin
          tblDTEntrant.Open;
          tblDTNoodle.Open;
          if tblDTEntrant.Active and tblDTNoodle.Active then
            fSCMDataIsActive := true;
        end;
      end;
    end;
  except on E: Exception do
    // failed to open memory table.
  end;
end;

procedure TDTData.ActivateDataSCM;
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

procedure TDTData.BuildCSVEventData(AFileName: string);
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
    { TODO -oBSA : Implement Splits for Dolphin Timing }
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

procedure TDTData.BuildDTData;
begin
  fSCMDataIsActive := false;
  tblDTSession.Active := false;
  tblDTEvent.Active := false;
  tblDTHeat.Active := false;
  tblDTEntrant.Active := false;
  tblDTNoodle.Active := false;

  // Create Dolphin Timing DATA TABLES SCHEMA.
  // ---------------------------------------------
  tblDTSession.FieldDefs.Clear;
  // Primary Key
  tblDTSession.FieldDefs.Add('SessionID', ftInteger);
  // Derived from line one 'Header' within file.
  tblDTSession.FieldDefs.Add('SessionNum', ftInteger);
  // Derived from filename : Last three digits of SCM qrySession.SessionID.
  tblDTSession.FieldDefs.Add('fnSessionNum', ftInteger);
  // file creation date  - produced by Dolphin timing when file was saved.
  tblDTSession.FieldDefs.Add('SessionStart', ftDateTime);
  // TimeStamp - Now.
  tblDTSession.FieldDefs.Add('CreatedOn', ftDateTime);
  tblDTSession.FieldDefs.Add('Caption', ftString, 64);
  tblDTSession.CreateDataSet;
{$IFDEF DEBUG}
  // save schema ...
  tblDTSession.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataSession.xml', sfAuto);
{$ENDIF}

  tblDTEvent.FieldDefs.Clear;
  // Primary Key.
  tblDTEvent.FieldDefs.Add('EventID', ftInteger);
  // FK. Master-detail  (tblDTSession)
  tblDTEvent.FieldDefs.Add('SessionID', ftInteger);
  // Derived from SplitString Field[1]
  // SYNC with SCM EventNum.
  tblDTEvent.FieldDefs.Add('EventNum', ftInteger);
  // Derived from filename : matches SCM qryEvent.EventNum.
  tblDTEvent.FieldDefs.Add('fnEventNum', ftInteger);
  tblDTEvent.FieldDefs.Add('Caption', ftString, 64);
  tblDTEvent.FieldDefs.Add('GenderStr', ftString, 1); // DO4 A=boys, B=girls, X=any.
  // Derived from filename
  // Round – “A” for all, “P” for prelim or “F” for final.
  tblDTEvent.FieldDefs.Add('fnRoundStr', ftString, 1);
  tblDTEvent.CreateDataSet;
{$IFDEF DEBUG}
  // save schema ...
  tblDTEvent.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataEvent.xml', sfAuto);
{$ENDIF}

  tblDTHeat.FieldDefs.Clear;
  // Create the HEAT MEM TABLE schema... tblDTHeat.
  // ---------------------------------------------
  tblDTHeat.FieldDefs.Add('HeatID', ftInteger); // PK.
  tblDTHeat.FieldDefs.Add('EventID', ftInteger); // Master- Detail
  // This timestamp is the moment when the event is brought into the
  // swimclubmeet dolphin timing application.
  // It's used to assist in 'pooling time' of the DT Meet Bin
  tblDTHeat.FieldDefs.Add('TimeStampDT', ftDateTime);
  // heat number should match
  // - SCM.dsHeat.Dataset.FieldByName('HeatNum)
  // - DT Filename - SplitString Field[2] - only available in D04
  // - Line one of FileName. Referenced as 'Header' - SplitString Field[2]
  tblDTHeat.FieldDefs.Add('HeatNum', ftInteger);
  // the heat number as shown in the DT filename.
  tblDTHeat.FieldDefs.Add('fnHeatNum', ftInteger);
  // Auto-created eg. 'Event 1 : #FILENAME#'
  tblDTHeat.FieldDefs.Add('Caption', ftString, 64);
  // Time stamp of file - created by Dolphin Timing system on write of file.
  tblDTHeat.FieldDefs.Add('CreatedDT', ftDateTime);
  // Path isn't stotred
  // FileName includes file extension.    (.DO3, .DO4)
  // determines dtFileType dtDO3, dtDO4.
  tblDTHeat.FieldDefs.Add('FileName', ftString, 128);
  // Last line of file - Referenced as 'Footer'
  tblDTHeat.FieldDefs.Add('CheckSum', ftString, 16); // footer.
  // Filename params sess, ev, ht don't match SCM session, event, heat
  // Used to prompt user to rename DT FileName.
  tblDTHeat.FieldDefs.Add('fnBadFN', ftBoolean);
  // Derived from FileName.
  // DO3 - SplitString Field[2] hash number (alpha-numerical).
  // DO4 - SplitString Field[3] hash number (numerical - sequence).
  tblDTHeat.FieldDefs.Add('fnHashStr', ftString, 8);
  // Derived from FileName.
  // DO4 Hashstr can be converted to RaceID.
  tblDTHeat.FieldDefs.Add('fnRaceID', ftInteger);
  tblDTHeat.CreateDataSet;
{$IFDEF DEBUG}
  // save schema ...
  tblDTHeat.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataHeat.xml');
{$ENDIF}

  { NOTE :
    Dolphin Timing doesn't destinct INDV and TEAM.
    tblEntrant holds both INDV and TEAM data.
  }

  tblDTEntrant.FieldDefs.Clear;
  // Create the LANE MEM TABLE schema... tblDTEntrant.
  // ---------------------------------------------
  tblDTEntrant.FieldDefs.Add('EntrantID', ftInteger); // PK.
  tblDTEntrant.FieldDefs.Add('HeatID', ftInteger); // Master- Detail
  tblDTEntrant.FieldDefs.Add('Lane', ftInteger); // Lane Number.
  // Dolphin Timing Specific
  tblDTEntrant.FieldDefs.Add('Caption', ftString, 64); // Summary of status/mode

  // If all timekeeper watch times are empty - then true;
  // calculated during load of DT file. Read Only.
  tblDTEntrant.FieldDefs.Add('LaneIsEmpty', ftBoolean);  //

  // Race-Time that will be posted to SCM.
  // Value shown here is dependant on ActiveRT.
  tblDTEntrant.FieldDefs.Add('RaceTime', ftTime);

  // A race-time entered manually by the user.
  tblDTEntrant.FieldDefs.Add('RaceTimeUser', ftTime);

  // dtAutomatic - calc on load. Read-Only.
  tblDTEntrant.FieldDefs.Add('RaceTimeA', ftTime);

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
  tblDTEntrant.FieldDefs.Add('ActiveRT', ftInteger);

  // CELL ICON - PATCH cable . index given in DTData.vimglistDTGrid.
  tblDTEntrant.FieldDefs.Add('imgPatch', ftInteger);

  // CELL ICON - ActiveRT.  index given in DTData.vimglistDTGrid.
  tblDTEntrant.FieldDefs.Add('imgActiveRT', ftInteger);

  // TimeKeeper's RACE_TIMES - 1,2, 3  (DT allows for 3 TimeKeepers.)
  tblDTEntrant.FieldDefs.Add('Time1', ftTime); // timekeeper 1.
  tblDTEntrant.FieldDefs.Add('Time2', ftTime); // timekeeper 2.
  tblDTEntrant.FieldDefs.Add('Time3', ftTime);  // timekeeper 3.

  // dtManual - store flip/flop.
  // The watch time is enabled (true) - is disabled (false).
  tblDTEntrant.FieldDefs.Add('T1M', ftBoolean);
  tblDTEntrant.FieldDefs.Add('T2M', ftBoolean);
  tblDTEntrant.FieldDefs.Add('T3M', ftBoolean);

  // dtAutomatic - store flip/flop.
  // The watch time is valid  (true).
  // SET on load of DT file (DO3 .. DO4). Read only.
  tblDTEntrant.FieldDefs.Add('T1A', ftBoolean);
  tblDTEntrant.FieldDefs.Add('T2A', ftBoolean);
  tblDTEntrant.FieldDefs.Add('T3A', ftBoolean);

  // Deviation - store flip/flop.
  // The watch time is within accepted deviation (true).
  // Only 2xfields Min-Mid, Mid-Max
  // SET on load of DT file (DO3 .. DO4). Read only.
  tblDTEntrant.FieldDefs.Add('TDev1', ftBoolean);
  tblDTEntrant.FieldDefs.Add('TDev2', ftBoolean);

  // Dolphin timing (dtfiletype dtDO4) stores MAX 10 splits.
  tblDTEntrant.FieldDefs.Add('Split1', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split2', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split3', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split4', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split5', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split6', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split7', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split8', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split9', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split10', ftTime); // DO4.

  tblDTEntrant.CreateDataSet;
{$IFDEF DEBUG}
  // save schema ...
  tblDTEntrant.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataEntrant.xml');
{$ENDIF}

  tblDTNoodle.FieldDefs.Clear;
  // Create the NOODLE MEM TABLE schema... tblDTNoodle.
  // ---------------------------------------------
  // Primary Key
  tblDTNoodle.FieldDefs.Add('NoodleID', ftInteger);
  // dtHeat Master-Detail.
  tblDTNoodle.FieldDefs.Add('HeatID', ftInteger);
  // dtEntrant - Route to lane/timekeepers/splits details
  tblDTNoodle.FieldDefs.Add('EntrantID', ftInteger);
  // dtEntrant.Lane - Quick lookup. Improve search times?
  tblDTNoodle.FieldDefs.Add('Lane', ftInteger);
  // LINK TO SwimClubMeet DATA
  // An entrant may be INDV or TEAM event.
  tblDTNoodle.FieldDefs.Add('SCM_EventTypeID', ftInteger);
  // Route to individual entrant.
  tblDTNoodle.FieldDefs.Add('SCM_INDVID', ftInteger);
  // Route to team (relay-team) entrant.
  tblDTNoodle.FieldDefs.Add('SCM_TEAMID', ftInteger);
  // Quick lookup?
  tblDTNoodle.FieldDefs.Add('SCM_Lane', ftInteger);
  tblDTNoodle.CreateDataSet;
{$IFDEF DEBUG}
  // save schema ...
  tblDTNoodle.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataNoodle.xml');
{$ENDIF}

end;

procedure TDTData.CalcRaceTimeA(ADataSet: TDataSet; AcceptedDeviation: double;
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

procedure TDTData.CalcRaceTimeM(ADataSet: TDataSet);
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
    // If no valid times, clear the RaceTime field
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

procedure TDTData.DataModuleCreate(Sender: TObject);
begin
  // Init params.
  fDTDataIsActive := false;
  fDTMasterDetailActive := false;
  FConnection := nil;
  fSCMDataIsActive := false; // activated later once FConnection is assigned.
  // Assign all the params to create the Master-Detail relationships
  // between Dolphin Timing memory tables.
  EnableDTMasterDetail();
  // Makes 'Active' the Dolphin Timing tables.
  ActivateDataDT;
  msgHandle := 0;
end;

procedure TDTData.DataModuleDestroy(Sender: TObject);
begin
  DeActivateDataSCM;
end;

procedure TDTData.DeActivateDataSCM;
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

procedure TDTData.DisableDTMasterDetail();
begin
  // ASSERT Master - Detail
  tblDTSession.IndexFieldNames := 'SessionID';
  tblDTEvent.MasterSource := nil;
  tblDTEvent.MasterFields := '';
  tblDTEvent.DetailFields := '';
  tblDTEvent.IndexFieldNames := 'EventID';
  tblDTHeat.MasterSource := nil;
  tblDTHeat.MasterFields := '';
  tblDTHeat.DetailFields := '';
  tblDTHeat.IndexFieldNames := 'HeatID';
  tblDTEntrant.MasterSource := nil;
  tblDTEntrant.MasterFields := '';
  tblDTEntrant.DetailFields := '';
  tblDTEntrant.IndexFieldNames := 'EntrantID';
  tblDTNoodle.MasterSource := nil;
  tblDTNoodle.MasterFields := '';
  tblDTNoodle.DetailFields := '';
  tblDTNoodle.IndexFieldNames := 'NoodleID';
  tblDTSession.First;
  {
  Use the ApplyMaster method to synchronize this detail dataset with the
  current master record.  This method is useful, when DisableControls was
  called for the master dataset or when scrolling is disabled by
  MasterLink.DisableScroll.
  }
  tblDTEvent.ApplyMaster;
  tblDTEvent.First;
  tblDTHeat.ApplyMaster;
  tblDTHeat.First;
  tblDTEntrant.ApplyMaster;
  tblDTEntrant.First;
  tblDTNoodle.ApplyMaster;
  tblDTNoodle.First;

  fDTMasterDetailActive := false;
end;

procedure TDTData.EnableDTMasterDetail();
begin
  // Master - index field.
  tblDTSession.IndexFieldNames := 'SessionID';
  // ASSERT Master - Detail
  tblDTEvent.MasterSource := dsDTSession;
  tblDTEvent.MasterFields := 'SessionID';
  tblDTEvent.DetailFields := 'SessionID';
  tblDTEvent.IndexFieldNames := 'SessionID';
  tblDTHeat.MasterSource := dsDTEvent;
  tblDTHeat.MasterFields := 'EventID';
  tblDTHeat.DetailFields := 'EventID';
  tblDTHeat.IndexFieldNames := 'EventID';
  tblDTEntrant.MasterSource := dsDTHeat;
  tblDTEntrant.MasterFields := 'HeatID';
  tblDTEntrant.DetailFields := 'HeatID';
  tblDTEntrant.IndexFieldNames := 'HeatID';
  tblDTNoodle.MasterSource := dsDTHeat;
  tblDTNoodle.MasterFields := 'HeatID';
  tblDTNoodle.DetailFields := 'HeatID';
  tblDTNoodle.IndexFieldNames := 'HeatID';
  tblDTSession.First;
  fDTMasterDetailActive := true;
end;

function TDTData.GetSCMActiveSessionID: integer;
begin
  result := 0;
  if not fSCMDataIsActive then exit;
  if qrySession.Active and not qrySession.IsEmpty then
    result := qrySession.FieldByName('SessionID').AsInteger;
end;

function TDTData.GetSCMNumberOfHeats(AEventID: integer): integer;
var
SQL: string;
v: variant;
begin
  result := 0;
  SQL := 'SELECT COUNT(HeatID) FROM dbo.HeatIndividual WHERE EventID = :ID;';
  v := DTData.Connection.ExecSQLScalar(SQL, [AEventID]);
  if VarIsNull(v) or VarIsEmpty(v) or (v=0)  then exit;
  result := v;
end;

function TDTData.GetSCMRoundABBREV(AEventID: integer): string;
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
  v := DTData.Connection.ExecSQLScalar(SQL, [AEventID]);
  if VarIsNull(v) or VarIsEmpty(v) or (v=0)  then exit;
  ARoundID := v;

  SQL := 'SELECT [ABREV] FROM dbo.Round WHERE RoundID = :ID;';
  v := DTData.Connection.ExecSQLScalar(SQL, [ARoundID]);
  if VarIsNull(v) or VarIsEmpty(v) then exit;
  result := v;

end;

function TDTData.LocateDTEventID(AEventID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tblDTHeat.Active then exit;
  if (AEventID = 0) then exit;
  SearchOptions := [];
  result := dsdtEvent.DataSet.Locate('EventID', AEventID, SearchOptions);
  if result then
    dsdtHeat.DataSet.Refresh;
end;

function TDTData.LocateDTEventNum(SessionID, AEventNum: integer; APrecedence:
  dtPrecedence): boolean;
var
  indexStr: string;
begin
  // WARNING : DisableDTMasterDetail() before calling here.
  // USED ONLY BY TdtUtils.ProcessEvent.
  result := false;
  // Exit if the table is not active or if AEventNum is 0
  if not tbldtEvent.Active then exit;
  if AEventNum = 0 then exit;
  // Store the original index field names
  indexStr := tbldtEvent.IndexFieldNames;
  tbldtEvent.IndexFieldNames := 'EventID';
  // Set the index based on the precedence
  if APrecedence = dtPrecFileName then
    result := tbldtEvent.Locate('SessionID;fnEventNum', VarArrayOf([SessionID,
      AEventNum]), [])
  else if APrecedence = dtPrecHeader then
    result := tbldtEvent.Locate('SessionID;EventNum', VarArrayOf([SessionID,
      AEventNum]), []);
  // Restore the original index field names
  tbldtEvent.IndexFieldNames := indexStr;
end;

function TDTData.LocateDTHeatID(AHeatID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tblDTHeat.Active then exit;
  if (AHeatID = 0) then exit;
  SearchOptions := [];
  result := dsdtHeat.DataSet.Locate('HeatID', AHeatID, SearchOptions);
end;

function TDTData.LocateDTHeatNum(EventID, AHeatNum: integer; Aprecedence:
    dtPrecedence): boolean;
var
  indexStr: string;
begin
  // WARNING : DisableDTMasterDetail() before calling here.
  // USED ONLY BY TdtUtils.ProcessHeat.
  result := false;
  // Exit if the table is not active or if AHeatNum is 0
  if not tbldtHeat.Active then exit;
  if AHeatNum = 0 then exit;
  // Store the original index field names
  indexStr := tbldtHeat.IndexFieldNames;
  tbldtHeat.IndexFieldNames := 'HeatID';
  // Set the index based on the precedence
  if APrecedence = dtPrecFileName then
    result := tbldtHeat.Locate('EventID;fnHeatNum', VarArrayOf([EventID,
      AHeatNum]), [])
  else if APrecedence = dtPrecHeader then
    result := tbldtHeat.Locate('EventID;HeatNum', VarArrayOf([EventID,
      AHeatNum]), []);
  // Restore the original index field names
  tbldtHeat.IndexFieldNames := indexStr;
end;

function TDTData.LocateDTLane(ALane: integer): boolean;
begin
  // IGNORES SYNC STATE...
  result := tbldtEntrant.Locate('Lane', ALane, []);
end;

function TDTData.LocateDTSessionID(ASessionID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tblDTSession.Active then exit;
  if (ASessionID = 0) then exit;
  SearchOptions := [];
  result := dsdtSession.DataSet.Locate('SessionID', ASessionID, SearchOptions);
  if result then
  begin
    dsdtEvent.DataSet.Refresh;
    dsdtHeat.DataSet.Refresh;
  end;
end;

function TDTData.LocateDTSessionNum(ASessionNum: integer; Aprecedence:
    dtPrecedence): boolean;
var
  indexStr: string;
begin
  // WARNING : DisableDTMasterDetail() before calling here.
  // USED ONLY BY TdtUtils.ProcessSession
  result := false;
  if not tbldtSession.Active then exit;
  if ASessionNum = 0 then exit;
  // Store the original index field names
  indexStr := tbldtSession.IndexFieldNames;
  if (ASessionNum = 0) then exit;
  tbldtSession.IndexFieldNames := 'SessionID';
  if (Aprecedence = dtPrecFileName) then
    result := tbldtSession.Locate('fnSessionNum', ASessionNum, [])
  else if (Aprecedence = dtPrecHeader) then
    result := tbldtSession.Locate('SessionNum', ASessionNum, []);
  // Restore the original index field names
  tbldtSession.IndexFieldNames := indexStr;
end;

function TDTData.LocateSCMEventID(AEventID: integer): boolean;
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

function TDTData.LocateSCMHeatID(AHeatID: integer): boolean;
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

function TDTData.LocateSCMLane(ALane: integer; aEventType: scmEventType):
    boolean;
var
found: boolean;
begin
  // IGNORES SYNC STATE...
  found := false;
  case aEventType of
    etUnknown:
      found := false;
    etINDV:
      found := qryINDV.Locate('Lane', ALane, []);
    etTEAM:
      found := qryTEAM.Locate('Lane', ALane, []);
  end;
  result := found;
end;

function TDTData.LocateSCMNearestSessionID(aDate: TDateTime): integer;
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

function TDTData.LocateSCMSessionID(ASessionID: integer): boolean;
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

function TDTData.MaxID_Entrant: integer;
var
max, id: integer;
begin
  // To function correctly disableDTMasterDetail.
  max := 0;
  tblDTEntrant.First;
  while not tblDTEntrant.eof do
  begin
    id := tblDTEntrant.FieldByName('EntrantID').AsInteger;
    if (id > max) then
      max := id;
    tblDTEntrant.Next;
  end;
  result := max;
end;

function TDTData.MaxID_Event: integer;
var
max, id: integer;
begin
  // To function correctly disableDTMasterDetail.
  max := 0;
  tblDTEvent.First;
  while not tblDTEvent.eof do
  begin
    id := tblDTEvent.FieldByName('EventID').AsInteger;
    if (id > max) then
      max := id;
    tblDTEvent.Next;
  end;
  result := max;
end;

function TDTData.MaxID_Heat: integer;
var
max, id: integer;
begin
  // To function correctly disableDTMasterDetail.
  max := 0;
  tblDTHeat.First;
  while not tblDTHeat.eof do
  begin
    id := tblDTHeat.FieldByName('HeatID').AsInteger;
    if (id > max) then
      max := id;
    tblDTHeat.Next;
  end;
  result := max;
end;

function TDTData.MaxID_Session: integer;
var
max, id: integer;
begin
  // To function correctly disableDTMasterDetail.
  max := 0;
  tblDTSession.First;
  while not tblDTSession.eof do
  begin
    id := tblDTSession.FieldByName('SessionID').AsInteger;
    if (id > max) then
      max := id;
    tblDTSession.Next;
  end;
  result := max;
end;

procedure TDTData.POST_All;
var
  AEventType: scmEventType;
  ALaneNum: integer;
begin
  qryINDV.DisableControls;
  qryTEAM.DisableControls;
  tblDTEntrant.DisableControls;

  AEventType := scmEventType(qryDistance.FieldByName('EventTypeID').AsInteger);

  // ONE TO ONE SYNC....
  tblDTEntrant.First;
  while not (tblDTEntrant.eof or qryINDV.eof) do
  begin
    ALaneNum := tblDTEntrant.FieldByName('Lane').AsInteger;
    if LocateSCMLane(ALaneNum, AEventType) then
    begin
      if AEventType = etINDV then
      begin
        // can't post a time to a lane with no swimmer!
        if not qryINDV.FieldByName('MemberID').IsNull then
        begin
          qryINDV.Edit;
          qryINDV.FieldByName('RaceTime').AsDateTime :=
          tblDTEntrant.FieldByName('RaceTime').AsDateTime;
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
          tblDTEntrant.FieldByName('RaceTime').AsDateTime;
          qryTEAM.Post;
        end;
      end;
    end;
    tblDTEntrant.Next;
  end;
  if AEventType = etINDV then
    qryINDV.First
  else if AEventType = etTEAM then
    qryTEAM.First;
  tblDTEntrant.First;
  tblDTEntrant.EnableControls;
  qryTEAM.EnableControls;
  qryINDV.EnableControls;

end;

procedure TDTData.POST_Lane(ALane: Integer);
var
  AEventType: scmEventType;
  b1, b2: boolean;
begin
  qryINDV.DisableControls;
  qryTEAM.DisableControls;
  tblDTEntrant.DisableControls;
  AEventType := scmEventType(qryDistance.FieldByName('EventTypeID').AsInteger);
  // SYNC to ROW ...
  b1 := LocateDTLane(ALane);
  b2 := LocateSCMLane(ALane, AEventType);
  if (b1 and b2) then
  begin
      if AEventType = etINDV then
      begin
        // can't post a time to a lane with no swimmer!
        if not qryINDV.FieldByName('MemberID').IsNull then
        begin
          qryINDV.Edit;
          qryINDV.FieldByName('RaceTime').AsDateTime :=
          tblDTEntrant.FieldByName('RaceTime').AsDateTime;
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
          tblDTEntrant.FieldByName('RaceTime').AsDateTime;
          qryTEAM.Post;
        end;
      end;
  end;
  tblDTEntrant.EnableControls;
  qryTEAM.EnableControls;
  qryINDV.EnableControls;
end;

procedure TDTData.ReadFromBinary(AFilePath:string);
var
s: string;
begin
  if Length(AFilePath) > 0 then
    // Assert that the end delimiter is attached
    s := IncludeTrailingPathDelimiter(AFilePath)
  else
    s := ''; // or handle this case if the path is mandatory
  tblDTSession.LoadFromFile(s + 'DTMaster.fsBinary');
  tblDTEvent.LoadFromFile(s + 'DTEvent.fsBinary');
  tblDTHeat.LoadFromFile(s + 'DTHeat.fsBinary');
  tblDTEntrant.LoadFromFile(s + 'DTLane.fsBinary');
  tblDTNoodle.LoadFromFile(s + 'DTNoodle.fsBinary');
end;

procedure TDTData.RefreshSCM;
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
        LocateSCMHeatID(AHeatID);
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

procedure TDTData.SetActiveRT(ADataSet: TDataSet; aActiveRT: dtActiveRT);
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

function TDTData.SyncDTtoSCM(APrecedence: dtPrecedence): boolean;
var
  found: boolean;
begin
  result := false;
  tblDTEvent.DisableControls;
  tblDTHeat.DisableControls;
  tblDTEntrant.DisableControls;
  tblDTSession.DisableControls;
  // NOTE : SCM Sesssion ID = DT SessionNum.
  found :=
  LocateDTSessionNum(qrySession.FieldByName('SessionID').AsInteger, APrecedence);
  tblDTEvent.ApplyMaster;
  if found then
  begin
    if APrecedence = dtPrecFileName then
      found := tbldtEvent.Locate('fnEventNum',
        qryEvent.FieldByName('EventNum').AsInteger)
    else if APrecedence = dtPrecHeader then
      found := tbldtEvent.Locate('EventNum',
        qryEvent.FieldByName('EventNum').AsInteger);
    tblDTHeat.ApplyMaster;
    if found then
    begin
      if APrecedence = dtPrecFileName then
        found := tbldtHeat.Locate('fnHeatNum',
          qryHeat.FieldByName('HeatNum').AsInteger)
      else if APrecedence = dtPrecHeader then
        found := tbldtHeat.Locate('HeatNum',
          qryHeat.FieldByName('HeatNum').AsInteger);
      tblDTEntrant.ApplyMaster;
      if found then
        result := true;
    end;
  end;
  tblDTSession.EnableControls;
  tblDTEvent.EnableControls;
  tblDTHeat.EnableControls;
  tblDTEntrant.EnableControls;
end;

function TDTData.SyncCheck(APrecedence: dtPrecedence): boolean;
var
  IsSynced: boolean;
begin
  IsSynced := false;
  case APrecedence of
    dtPrecHeader:
      begin
        if qrySession.FieldByName('SessionID').AsInteger =
        tbldtSession.FieldByName('SessionNum').AsInteger then
          if qryEvent.FieldByName('EventNum').AsInteger =
          tbldtEvent.FieldByName('EventNum').AsInteger then
            if qryHeat.FieldByName('HeatNum').AsInteger =
            tbldtHeat.FieldByName('HeatNum').AsInteger then
              IsSynced := true;
      end;
    dtPrecFileName:
      begin
        if qrySession.FieldByName('SessionID').AsInteger =
        tbldtSession.FieldByName('fnSessionNum').AsInteger then
          if qryEvent.FieldByName('EventNum').AsInteger =
          tbldtEvent.FieldByName('fnEventNum').AsInteger then
            if qryHeat.FieldByName('HeatNum').AsInteger =
            tbldtHeat.FieldByName('fnHeatNum').AsInteger then
              IsSynced := true;
      end;
  end;
  result := IsSynced;

end;

function TDTData.SyncCheckSession(APrecedence: dtPrecedence): boolean;
var
  sessNum: integer;
begin
  result := false;
  if APrecedence = dtPrecHeader then
    sessNum := tbldtSession.FieldByName('SessionNum').AsInteger
  else if APrecedence = dtPrecFileName then
    sessNum := tbldtSession.FieldByName('fnSessionNum').AsInteger
  else sessNum := 0;
  if qrySession.FieldByName('SessionID').AsInteger = sessNum then
    result := true;
end;

function TDTData.SyncSCMtoDT(APrecedence: dtPrecedence): boolean;
var
  found: boolean;
begin
  result := false;
  found := false;

  if not SyncCheckSession(Aprecedence) then exit;

  qryTEAM.DisableControls;
  qryINDV.DisableControls;
  qryHeat.DisableControls;
  qryEvent.DisableControls;
  qrySession.DisableControls;

  case APrecedence of
    dtPrecHeader:
    begin
      if qryEvent.Locate('EventNum', tbldtEvent.FieldByName('EventNum').AsInteger, []) then
        found :=  qryHeat.Locate('HeatNum', tbldtHeat.FieldByName('HeatNum').AsInteger, []);
    end;

    dtPrecFileName:
    begin
      if qryEvent.Locate('EventNum', tbldtEvent.FieldByName('fnEventNum').AsInteger, []) then
        found :=  qryHeat.Locate('HeatNum', tbldtHeat.FieldByName('fnHeatNum').AsInteger, []);
    end;
  end;

  result := found;
  qrySession.EnableControls;
  qryEvent.EnableControls;
  qryHeat.EnableControls;
  qryINDV.EnableControls;
  qryTEAM.EnableControls;
end;


procedure TDTData.tblDTHeatAfterScroll(DataSet: TDataSet);
begin
  if (msgHandle <> 0) then
    PostMessage(msgHandle, SCM_UPDATEUI3, 0,0);
end;

function TDTData.ToggleActiveRT(ADataSet: TDataSet; Direction: Integer = 0):
dtActiveRT;
var
  art: dtActiveRT;
begin
  result := artNone;
  if not ADataSet.Active then exit;
  if not (ADataSet.Name = 'tblDTEntrant') then exit;
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

function TDTData.ToggleWatchTime(ADataSet: TDataSet; idx: integer; art: dtActiveRT): Boolean;
var
s, s2: string;
b: boolean;
begin
  // RANGE : idx in [1..3].
  result := false;

  // Assert state ...
  if not ADataSet.Active then exit;
  if (ADataSet.Name <> 'tblDTEntrant') then exit;
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

function TDTData.ValidateWatchTime(ADataSet: TDataSet; TimeKeeperIndx: integer;
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

procedure TDTData.WriteToBinary(AFilePath:string);
var
s: string;
begin
  if Length(AFilePath) > 0 then
    // Assert that the end delimiter is attached
    s := IncludeTrailingPathDelimiter(AFilePath)
  else
    s := ''; // or handle this case if the path is mandatory
  tblDTSession.SaveToFile(s + 'DTMaster.fsBinary', sfXML);
  tblDTEvent.SaveToFile(s + 'DTEvent.fsBinary', sfXML);
  tblDTHeat.SaveToFile(s + 'DTHeat.fsBinary', sfXML);
  tblDTEntrant.SaveToFile(s + 'DTLane.fsBinary', sfXML);
  tblDTNoodle.SaveToFile(s + 'DTNoodle.fsBinary', sfXML);
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
  RULES USED BY DOLPHIN TIMING METHOD. (DEFAULT).
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
      // DOLPHIN TIMING RULES - use mid watch-time.
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
      { Dolphin Timing doesn't consider check deviation on 3xwatch-times
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
    fAcceptedDeviation := Settings.DolphinAcceptedDeviation;
    fCalcRTMethod := Settings.DolphinCalcRTMethod;
  end
  else
  begin
    fAcceptedDeviation := 0.3;
    fCalcRTMethod := 0; // default - Dolphin Timing Method.
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
