unit dmSCM;

(*
  An application can specify a connection definition file name in the
  FDManager.ConnectionDefFileName property. FireDAC searches for a connection
  definition file in the following places:
  ◾ If ConnectionDefFileName is specified:
  ◾ search for a file name without a path, then look for it in an
        application EXE folder.
  ◾ otherwise just use a specified file name.

  ◾ If ConnectionDefFileName is not specified:
  ◾ look for FDConnectionDefs.ini in an application EXE folder.
  ◾ If the file above is not found, look for a file specified in the
        registry key HKCU\Software\Embarcadero\FireDAC\ConnectionDefFile.

  By default it is
  C:\Users\Public\Documents\Embarcadero\Studio\FireDAC\FDConnectionDefs.ini.

  Note:
  At design time, FireDAC ignores the value of the
  FDManager.ConnectionDefFileName, and looks for a file in a RAD Studio
  Bin folder or as specified in the registry. If the file is not found,
  an exception is raised.

  If FDManager.ConnectionDefFileAutoLoad is True, a connection definition
  file loads automatically. Otherwise, it must be loaded explicitly by
  calling the FDManager.LoadConnectionDefFile method before the first
  usage of the connection definitions. For example, before setting
  TFDConnection.Connected to True.

*)

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.Client, Data.DB,
  FireDAC.Comp.DataSet, WinApi.Windows, SCMDefines, System.Variants,
  System.UITypes;

type
  TSCM = class(TDataModule)
    dsEvent: TDataSource;
    dsHeat: TDataSource;
    dsINDV: TDataSource;
    dsSession: TDataSource;
    dsSwimClub: TDataSource;
    dsTEAM: TDataSource;
    dsTEAMEntrant: TDataSource;
    qryDistance: TFDQuery;
    qryEvent: TFDQuery;
    qryHeat: TFDQuery;
    qryINDV: TFDQuery;
    qryListSwimmers: TFDQuery;
    qryListTeams: TFDQuery;
    qryNearestSessionID: TFDQuery;
    qrySCMSystem: TFDQuery;
    qrySession: TFDQuery;
    qrySplit: TFDQuery;
    qryStroke: TFDQuery;
    qrySwimClub: TFDQuery;
    qryTEAM: TFDQuery;
    qryTEAMEntrant: TFDQuery;
    scmFDManager: TFDManager;
    TestFDConnection: TFDConnection;
    dsDistance: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure qryHeatAfterScroll(DataSet: TDataSet);
  private
    fDataIsActive: Boolean;
    { Private declarations }
    fDBModel, fDBVersion, fDBMajor, fDBMinor: integer;
//    procedure AssertMasterDetail;
  public
    fLoginTimeout: integer;  //---
    msgHandle: HWND;  // TForm.dtfrmExec ...   // Both DataModules
    { Public declarations }
    scmConnection: TFDConnection;   //---
    procedure ActivateDataSCM();  //---
    procedure BuildCSVEventData(AFileName: string); //---
    procedure DeActivateDataSCM();  //---
    function  GetDBVerInfo(): string;
    // MISC SCM ROUTINES/FUNCTIONS
    function GetNumberOfHeats(AEventID: integer): integer;
    function GetRoundABBREV(AEventID: integer): string;
    function GetEventType(aEventID: integer): scmEventType;
    // L O C A T E S   F O R   S W I M C L U B M E E T   D A T A.
    // WARNING : Master-Detail enabled...
    // .......................................................
    function LocateEventID(AEventID: integer): boolean;
    function LocateHeatID(AHeatID: integer): boolean;
    function LocateLaneNum(ALaneNum: integer; aEventType: scmEventType): boolean; overload;
    function LocateLaneNum(AHeatID: integer; ALaneNum: integer): boolean; overload;
    // Uses SessionStart TDateTime...
    function LocateNearestSessionID(aDate: TDateTime): integer;
    function LocateSessionID(ASessionID: integer): boolean;
    function LocateSwimClubID(ASwimClubID: integer): boolean;
    procedure ReadConnectionDef(const ConnectionName, ParamName: string; out ParamValue: string);
    // If events, heats, etc change within SwimClubMeet then call here to
    // reload and sync to changes.
    procedure RefreshSCM();  //---
    function SyncCheck(aTDSessionID, aTDEventNum, aTDHeatNum: Integer): boolean;
    function SyncCheckSession(aTDSessionID: Integer): boolean;
    // .......................................................
    function GetActive_INDVorTEAM: TDataSource;
    function SyncSCMtoDT(aTDSessionNum, aTDEventNum, aTDHeatNum: Integer; Verbose:
        Boolean = true): boolean;
    procedure WriteConnectionDef(const ConnectionName, ParamName, ParamValue: string);
    property DataIsActive: Boolean read fDataIsActive;
    property MSG_Handle: HWND read msgHandle write msgHandle;  // Both DataModules
  end;

var
  SCM: TSCM;

implementation

uses
  System.DateUtils, uAppUtils, Vcl.Dialogs;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}


function TSCM.GetEventType(aEventID: integer): scmEventType;
var
  v: variant;
  SQL: string;
begin
  result := etUnknown;
    if not SCM.qryEvent.IsEmpty then
    begin
      SQL := 'SELECT [EventTypeID] FROM [SwimClubMeet].[dbo].[Event] ' +
        'INNER JOIN Distance ON [Event].DistanceID = Distance.DistanceID ' +
        'WHERE EventID = :ID';
      v := SCM.scmConnection.ExecSQLScalar(SQL, [aEventID]);
      if VarIsNull(v) or VarIsEmpty(v) or (v = 0) then exit;
    end;
    case v of
      1: result := etINDV;
      2: result := etTEAM;
    end;
end;

procedure TSCM.ActivateDataSCM;
begin
  // ASSERT state
  fDataIsActive := false;

  if Assigned(scmConnection) and scmConnection.Connected then
  begin
    { If the dataset is the master of a master/detail relationship,
      calling DisableControls also disables the master/detail relationship.}

    qryTEAMEntrant.DisableControls;
    qryTEAM.DisableControls;
    qryINDV.DisableControls;
    qryHeat.DisableControls;
    qryEvent.DisableControls;
    qrySession.DisableControls;
    qrySwimClub.DisableControls;

    // assign TFDConnection
    qrySwimClub.Connection := scmConnection;
    qrySession.Connection := scmConnection;
    qryEvent.Connection := scmConnection;
    qryDistance.Connection := scmConnection;
    qryStroke.Connection := scmConnection;
    qryHeat.Connection := scmConnection;
    qryINDV.Connection := scmConnection;
    qryTEAM.Connection := scmConnection;
    qryTEAMEntrant.Connection := scmConnection;

    try
      // GRAND MASTER.
      qrySwimClub.Open;
      if qrySwimClub.Active then
      begin
        {TODO -oBSA -cGeneral : locate the current active swimming club.}
        qrySwimClub.First; // Default ID = 1.
        qrySession.Open;
        if qrySession.Active then
        begin
          qrySession.Last;  // most recent session.
          qryEvent.Open;
          qryDistance.Open;
          qryStroke.Open;
          qryHeat.Open;
          qryINDV.Open;
          qryTEAM.Open;
          qryTEAMEntrant.Open;
          fDataIsActive := true;
        end;
      end;
    finally
      qrySwimClub.EnableControls;
      qrySession.EnableControls;
      qryEvent.EnableControls;
      qryHeat.EnableControls;
      qryINDV.EnableControls;
      qryTEAM.EnableControls;
      qryTEAMEntrant.EnableControls;
    end;
  end;
end;

(*
  procedure TSCM.AssertMasterDetail;
  begin
    if (fDataIsActive = false) then
    begin
      // should be ok to run this procedure with out a connection.
      // assigning a master will result in query state = close.
      // must be explicitly reopened. (ActivateDataSCM)

      // Master - index field.
      qrySwimClub.IndexFieldNames := 'SwimClubID';

      // ASSERT Master - Detail
      qrySession.MasterSource := dsSwimClub;
      qrySession.MasterFields := 'SwimClubID';
      qrySession.DetailFields := 'SwimClubID';
      qrySession.IndexFieldNames := 'SwimClubID';

      qryEvent.MasterSource := dsSession;
      qryEvent.MasterFields := 'SessionID';
      qryEvent.DetailFields := 'SessionID';
      qryEvent.IndexFieldNames := 'SessionID';

      qryDistance.MasterSource := dsEvent;
      qryDistance.MasterFields := 'DistanceID';
      qryDistance.DetailFields := 'DistanceID';
      qryDistance.IndexFieldNames := 'DistanceID';

      qryStroke.MasterSource := dsEvent;
      qryStroke.MasterFields := 'StrokeID';
      qryStroke.DetailFields := 'StrokeID';
      qryStroke.IndexFieldNames := 'StrokeID';

      qryHeat.MasterSource := dsEvent;
      qryHeat.MasterFields := 'EventID';
      qryHeat.DetailFields := 'EventID';
      qryHeat.IndexFieldNames := 'EventID';

      qryINDV.MasterSource := dsHeat;
      qryINDV.MasterFields := 'HeatID';
      qryINDV.DetailFields := 'HeatID';
      qryINDV.IndexFieldNames := 'HeatID';

      qryTEAM.MasterSource := dsHeat;
      qryTEAM.MasterFields := 'HeatID';
      qryTEAM.DetailFields := 'HeatID';
      qryTEAM.IndexFieldNames := 'HeatID';

      qryTeamEntrant.MasterSource := dsTeam;
      qryTeamEntrant.MasterFields := 'TeamID';
      qryTeamEntrant.DetailFields := 'TeamID';
      qryTeamEntrant.IndexFieldNames := 'TeamID';

    end;

  end;


*)procedure TSCM.BuildCSVEventData(AFileName: string);
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
    i := GetNumberOfHeats(id);
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

procedure TSCM.DataModuleCreate(Sender: TObject);
var
  ExpandedFn, msg: string;
begin
  fDataIsActive := false;
  scmConnection := nil;
  msgHandle := 0;

  { SWITCH from the default application's FDConnectionDefs.ini to
    FDConnectionDefs.ini held in user AppData folder.
    This resolves read-write issues and security. }

  ExpandedFn := ExpandEnvVars('%APPDATA%\Artanemus\SCM\FDConnectionDefs.ini');
  if FileExists(ExpandedFn) then
  begin
    // As ConnectionDefFileAutoLoad := True, the file will be loaded immediately.
    //  and a call to LoadConnectionDefFile isn't needed.
    scmFDManager.ConnectionDefFileName := ExpandedFn;
    // Assert state.
    scmFDManager.Active := true;
  end
  else
  begin
    msg := '''
    While preparing the FireDAC's connection manager, the application
    was unable to find %APPDATA%\Artanemus\SCM\FDConnectionDefs.ini.
    A connection can't be made with the SwimClubMeet database.
    ...
    (NOTE: The application's folder contains a vanilla version of this file
    and can be used to assist in reconstruction of the missing file.)
    ''';
    raise Exception.Create(msg);
  end;

  try
    begin
      scmConnection := TFDConnection.Create(Self);
      scmConnection.ConnectionDefName := 'MSSQL_SwimClubMeet';
      // The connection isn't opened. This will occur on the main form -
      // via the TLogin dialogue.
    end;
  except on E: Exception do
    begin
      msg := Format('Failed to create FireDAC''s connection component. Error: %s', [E.Message]);
      FreeAndNil(scmConnection);
      raise Exception.Create(msg);
    end;
  end;
end;

procedure TSCM.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(scmConnection);
end;

procedure TSCM.DeActivateDataSCM;
begin
  // Safe to assign early in execution.
  fDataIsActive := false;
  // Can only close TFDQuery if connection is active.
  if Assigned(scmConnection) and scmConnection.Connected then
  begin
    qryTEAMEntrant.Close; // Detail of TEAM
    qryTEAM.Close;  // Detail of Heat
    qryINDV.Close;  // Detail of Heat
    qryHeat.Close;  // Detail of event
    qryStroke.Close; // Detail of event
    qryDistance.Close;  // Detail of event
    qryEvent.Close;
    qrySession.Close;
    qrySwimClub.Close;  // GRAND MASTER.
    {TODO -oBSA -cIMPORTANT : On DeActivate SCM - should we close connection?}
  end;
end;

function TSCM.GetActive_INDVorTEAM: TDataSource;
begin
  result := nil;
  // Check - connected, master-detail ok, queryies open. Has heats.
  if (fDataIsActive = true) and (not qryHeat.IsEmpty) then
  begin
    case qryDistance.FieldByName('EventTypeID').AsInteger of
    1:
      result := dsINDV;
    2:
      result := dsTEAM;
    end;
  end;
end;

function TSCM.GetDBVerInfo: string;
begin
  result := '';
  if scmConnection.Connected then
  begin
    with qrySCMSystem do
    begin
      Connection := scmConnection;
      Open;
      if Active then
      begin
        fDBModel := FieldByName('SCMSystemID').AsInteger;
        fDBVersion := FieldByName('DBVersion').AsInteger;
        fDBMajor := FieldByName('Major').AsInteger;
        fDBMinor := FieldByName('Minor').AsInteger;
        result := IntToStr(fDBModel) + '.' + IntToStr(fDBVersion) + '.' +
          IntToStr(fDBMajor) + '.' + IntToStr(fDBMinor);
      end;
      Close;
    end;
  end;
end;

function TSCM.GetNumberOfHeats(AEventID: integer): integer;
var
SQL: string;
v: variant;
begin
  result := 0;
  SQL := 'SELECT COUNT(HeatID) FROM dbo.HeatIndividual WHERE EventID = :ID;';
  v := scmConnection.ExecSQLScalar(SQL, [AEventID]);
  if VarIsNull(v) or VarIsEmpty(v) or (v=0)  then exit;
  result := v;
end;

function TSCM.GetRoundABBREV(AEventID: integer): string;
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
  v := scmConnection.ExecSQLScalar(SQL, [AEventID]);
  if VarIsNull(v) or VarIsEmpty(v) or (v=0)  then exit;
  ARoundID := v;

  SQL := 'SELECT [ABREV] FROM dbo.Round WHERE RoundID = :ID;';
  v := scmConnection.ExecSQLScalar(SQL, [ARoundID]);
  if VarIsNull(v) or VarIsEmpty(v) then exit;
  result := v;

end;

function TSCM.LocateEventID(AEventID: integer): boolean;
var
  LOptions: TLocateOptions;
begin
  result := false;
  if not fDataIsActive then exit;
  if (aEventID = 0) then exit;
  LOptions := [];
  if dsEvent.DataSet.Active then
  begin
    result := dsEvent.DataSet.Locate('EventID', aEventID, LOptions);
    if result then qryHeat.ApplyMaster; // master-detail
  end;
end;

function TSCM.LocateHeatID(AHeatID: integer): boolean;
var
  LOptions: TLocateOptions;
begin
  result := false;
  if not fDataIsActive then exit;
  if (AHeatID = 0) then exit;
  LOptions := [];
  if dsHeat.DataSet.Active then
  begin
    result := dsHeat.DataSet.Locate('HeatID', AHeatID, LOptions);
    if result then qryHeat.ApplyMaster; // master-detail
  end;
end;

function TSCM.LocateLaneNum(AHeatID, ALaneNum: integer): boolean;
var
  found: boolean;
  LOptions: TLocateOptions;
  EventType: scmEventType;
begin
  result := false;
  found := true;
  if not fDataIsActive then exit;
  LOptions := [];
  if SCM.qryHeat.FieldByName('HeatID').AsInteger <> AHeatID then
    found := SCM.LocateHeatID(AHeatID);
  if found then
  begin
    EventType := GetEventType(SCM.qryHeat.FieldByName('EventID').AsInteger);
    found := LocateLaneNum(ALaneNum, EventType);
  end;
  result := found;
end;

function TSCM.LocateLaneNum(ALaneNum: integer; aEventType: scmEventType):
    boolean;
var
  found: boolean;
  LOptions: TLocateOptions;
begin
  result := false;
  found := false;
  if not fDataIsActive then exit;
  LOptions := [];
  case aEventType of
    etUnknown:
      found := false;
    etINDV:
      found := qryINDV.Locate('Lane', ALaneNum, LOptions);
    etTEAM:
    begin
      found := qryTEAM.Locate('Lane', ALaneNum, LOptions);
      if found then qryTEAMEntrant.ApplyMaster;
    end;
  end;
  result := found;
end;

function TSCM.LocateNearestSessionID(aDate: TDateTime): integer;
begin
  result := 0;
  if not fDataIsActive then exit;
  // find the session with 'aDate' or bestfit.
  qryNearestSessionID.Connection := scmConnection;
  qryNearestSessionID.ParamByName('ADATE').AsDateTime := DateOf(aDate);
  qryNearestSessionID.Prepare;
  qryNearestSessionID.Open;
  if not qryNearestSessionID.IsEmpty then
  begin
   result := qryNearestSessionID.FieldByName('SessionID').AsInteger;
   if (result <> 0) then qryEvent.ApplyMaster;
  end;
end;

function TSCM.LocateSessionID(ASessionID: integer): boolean;
var
  LOptions: TLocateOptions;
begin
  result := false;
  if not fDataIsActive then exit;
  if (ASessionID = 0) then exit;
  LOptions := [];
  if dsSession.DataSet.Active then
  begin
    result := dsSession.DataSet.Locate('SessionID', ASessionID, LOptions);
    if result then qryevent.ApplyMaster; // master-detail
  end;
end;

function TSCM.LocateSwimClubID(ASwimClubID: integer): boolean;
var
  LOptions: TLocateOptions;
begin
  result := false;
  if not fDataIsActive then exit;
  if (ASwimClubID = 0) then exit;
  LOptions := [];
  if dsSwimClub.DataSet.Active then
  begin
    result := dsSwimClub.DataSet.Locate('SwimClubID', ASwimClubID, LOptions);
    if result then qrySession.ApplyMaster; // master-detail
  end;
end;

procedure TSCM.qryHeatAfterScroll(DataSet: TDataSet);
begin
  if (msgHandle <> 0) then
  begin
    PostMessage(msgHandle, SCM_UPDATEUI_SCM, 0,0);
    PostMessage(msgHandle, SCM_UPDATE_NOODLES, 0,0);
  end;
end;

procedure TSCM.ReadConnectionDef(const ConnectionName, ParamName: string;
  out ParamValue: string);
var
  ConnectionDef: IFDStanConnectionDef;
begin
  // Check if the connection definition exists
  ConnectionDef := SCM.scmFDManager.ConnectionDefs.ConnectionDefByName(ConnectionName);
  if Assigned(ConnectionDef) then
  begin
    // Read the parameter value
    ParamValue := ConnectionDef.Params.Values[ParamName];
  end
  else
    raise Exception.CreateFmt('Connection definition "%s" not found.', [ConnectionName]);
end;

procedure TSCM.RefreshSCM;
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

  // cue-to-record : locate.
  if qrySwimClub.Locate('SwimClubID', ASwimClubID, []) then
  begin
    qrySession.ApplyMaster;
    if LocateSessionID(ASessionID) then
    begin
      // qryEvent.ApplyMaster; // performed in Locate procedure.
      if LocateEventID(AEventID) then
      begin
        // qryHeat.ApplyMaster; // performed in Locate procedure.
        if not LocateHeatID(AHeatID) then qryHeat.First;
      end
      else
        qryEvent.First;
    end;
  end;

  // cue-to-lane 1
  qryINDV.First;
  qryTEAM.first;

  qrySwimClub.EnableControls;
  qrySession.EnableControls;
  qryEvent.EnableControls;
  qryHeat.EnableControls;
  qryINDV.EnableControls;
  qryTEAM.EnableControls;

end;

function TSCM.SyncCheck(aTDSessionID, aTDEventNum, aTDHeatNum: Integer):
    boolean;
var
  IsSynced: boolean;
begin
  IsSynced := false;
  if aTDSessionID =  qrySession.FieldByName('SessionID').AsInteger then
    if aTDEventNum = qryEvent.FieldByName('EventNum').AsInteger then
      if aTDHeatNum = qryHeat.FieldByName('HeatNum').AsInteger then
        IsSynced := true;
  result := IsSynced;
end;

function TSCM.SyncCheckSession(aTDSessionID: Integer): boolean;
begin
  result := false;
  if aTDSessionID = 0 then exit;
  if qrySession.FieldByName('SessionID').AsInteger = aTDSessionID then
    result := true;
end;

function TSCM.SyncSCMtoDT(aTDSessionNum, aTDEventNum, aTDHeatNum: Integer;
    Verbose: Boolean = true): boolean;
var
  found: boolean;
begin
  result := false;
  found := false;

  if not SyncCheckSession(aTDSessionNum) then
  begin
    if Verbose then
      MessageDlg('The SwimClubMeet andTimeDrops sessions don''t match.'+#13+#10+
      'Open the correct session with ''Select SCM Session'' and try  again.',
      mtInformation, [mbOK], 0);
    exit;
  end;

  qryTEAM.DisableControls;
  qryINDV.DisableControls;
  qryHeat.DisableControls;
  qryEvent.DisableControls;
  qrySession.DisableControls;
  qryEvent.ApplyMaster;
  if qryEvent.Locate('EventNum', aTDEventNum, [])
  then
  begin
    qryHeat.ApplyMaster;
    found := qryHeat.Locate('HeatNum', aTDHeatNum, []);
    if found then
    begin
      qryTEAM.ApplyMaster; // ... qryTEAMEntrant will update.
      qryINDV.ApplyMaster;
    end;
  end;
  result := found;
  qrySession.EnableControls;
  qryEvent.EnableControls;
  qryHeat.EnableControls;
  qryINDV.EnableControls;
  qryTEAM.EnableControls;
end;

(*
You do not need to make the TFDManager inactive before updating its
ConnectionDefs. The TFDManager allows you to modify connection definitions
dynamically at runtime without deactivating it.
*)

procedure TSCM.WriteConnectionDef(const ConnectionName, ParamName,
  ParamValue: string);
var
  ConnectionDef: IFDStanConnectionDef;
begin
  // Get the connection definition by name
  ConnectionDef := SCM.scmFDManager.ConnectionDefs.ConnectionDefByName(ConnectionName);

  if Assigned(ConnectionDef) then
  begin
    // Update the parameter
    ConnectionDef.Params.Values[ParamName] := ParamValue;

    // Save the changes to the FDConnectionDefs.ini file
    SCM.scmFDManager.ConnectionDefs.Save;
  end
  else
    raise Exception.CreateFmt('Connection definition "%s" not found.', [ConnectionName]);
end;



end.
