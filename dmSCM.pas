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
  FireDAC.Comp.DataSet, WinApi.Windows, SCMDefines, System.Variants;

type
  TSCM = class(TDataModule)
    qrySCMSystem: TFDQuery;
    scmFDManager: TFDManager;
    qrySession: TFDQuery;
    qryEvent: TFDQuery;
    qryHeat: TFDQuery;
    qryINDV: TFDQuery;
    qryTEAM: TFDQuery;
    qryTEAMEntrant: TFDQuery;
    dsSession: TDataSource;
    dsEvent: TDataSource;
    dsHeat: TDataSource;
    dsINDV: TDataSource;
    dsTEAM: TDataSource;
    dsTEAMEntrant: TDataSource;
    qryNearestSessionID: TFDQuery;
    qryDistance: TFDQuery;
    qryStroke: TFDQuery;
    qryListSwimmers: TFDQuery;
    qrySplit: TFDQuery;
    qryListTeams: TFDQuery;
    qrySwimClub: TFDQuery;
    dsSwimClub: TDataSource;
    TestFDConnection: TFDConnection;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure qryHeatAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    fDBModel, fDBVersion, fDBMajor, fDBMinor: integer;
    fDataIsActive: Boolean;
  public
    { Public declarations }
    scmConnection: TFDConnection;   //---
    fLoginTimeout: integer;  //---
    msgHandle: HWND;  // TForm.dtfrmExec ...   // Both DataModules
    procedure ActivateDataSCM();  //---
    procedure DeActivateDataSCM();  //---
    procedure WriteConnectionDef(const ConnectionName, ParamName, ParamValue: string);
    procedure ReadConnectionDef(const ConnectionName, ParamName: string; out ParamValue: string);

    procedure BuildCSVEventData(AFileName: string); //---
    // MISC SCM ROUTINES/FUNCTIONS
    function GetNumberOfHeats(AEventID: integer): integer;
    function GetRoundABBREV(AEventID: integer): string;
    // L O C A T E S   F O R   S W I M C L U B M E E T   D A T A.
    // WARNING : Master-Detail enabled...
    // .......................................................
    function LocateEventID(AEventID: integer): boolean;
    function LocateHeatID(AHeatID: integer): boolean;
    // Uses SessionStart TDateTime...
    function LocateNearestSessionID(aDate: TDateTime): integer;
    function LocateSessionID(ASessionID: integer): boolean;
    function LocateSwimClubID(ASwimClubID: integer): boolean;
    function LocateLaneNum(ALaneNum: integer; aEventType: scmEventType): boolean;
    // .......................................................
    function SyncSCMtoDT(aTDSessionNum, aTDEventNum, aTDHeatNum: Integer): boolean;
    function SyncCheckSession(aTDSessionID: Integer): boolean;
    function SyncCheck(aTDSessionID, aTDEventNum, aTDHeatNum: Integer): boolean;
    // If events, heats, etc change within SwimClubMeet then call here to
    // reload and sync to changes.
    procedure RefreshSCM();  //---
    function  GetDBVerInfo(): string;

    property MSG_Handle: HWND read msgHandle write msgHandle;  // Both DataModules
    property DataIsActive: Boolean read fDataIsActive;

  end;

var
  SCM: TSCM;

implementation

uses
  System.DateUtils;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function ExpandEnvVars(const Value: string): string;
var
  Buffer: array[0..MAX_PATH-1] of Char;
begin
  if ExpandEnvironmentStrings(PChar(Value), Buffer, Length(Buffer)) = 0 then
    RaiseLastOSError;
  Result := Buffer;
end;

procedure TSCM.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(scmConnection);
end;

procedure TSCM.ActivateDataSCM;
begin
  if Assigned(scmConnection) and scmConnection.Connected then
  begin

    // GRAND MASTER.
    qrySwimClub.Connection := scmConnection;
    qrySwimClub.Open;
    if qrySwimClub.Active then
      {TODO -oBSA -cGeneral : locate the current active swimming club.}
      qrySwimClub.First;

    { If the dataset is the master of a master/detail relationship,
      calling DisableControls also disables the master/detail relationship.}
    qryTEAM.DisableControls;
    qryINDV.DisableControls;
    qryHeat.DisableControls;
    qryEvent.DisableControls;
    qrySession.DisableControls;
    qrySwimClub.DisableControls;

    // setup connection for master - detail
    qrySession.Connection := scmConnection;
    qryEvent.Connection := scmConnection;
    qryDistance.Connection := scmConnection;
    qryStroke.Connection := scmConnection;
    qryHeat.Connection := scmConnection;
    qryINDV.Connection := scmConnection;
    qryTEAM.Connection := scmConnection;
    qryTEAMEntrant.Connection := scmConnection;

    try
      qrySession.Open;
      if qrySwimClub.Active and qrySession.Active then
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
    finally
      qrySwimClub.EnableControls;
      qrySession.EnableControls;
      qryEvent.EnableControls;
      qryHeat.EnableControls;
      qryINDV.EnableControls;
      qryTEAM.EnableControls;
    end;
  end;
end;

procedure TSCM.DeActivateDataSCM;
begin
  if Assigned(scmConnection) and scmConnection.Connected then
  begin
    fDataIsActive := false;
    qryTEAMEntrant.Close; // Detail of TEAM
    qryTEAM.Close;  // Detail of Heat
    qryINDV.Close;  // Detail of Heat
    qryHeat.Close;  // Detail of event
    qryStroke.Close; // Detail of event
    qryDistance.Close;  // Detail of event
    qryEvent.Close;
    qrySession.Close;
    qrySwimClub.Close;  // GRAND MASTER.
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
      result := dsEvent.DataSet.Locate('EventID', aEventID, LOptions);
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
      result := dsHeat.DataSet.Locate('HeatID', AHeatID, LOptions);
end;

function TSCM.LocateLaneNum(ALaneNum: integer; aEventType: scmEventType):
    boolean;
var
  found: boolean;
  LOptions: TLocateOptions;
begin
  // IGNORES SYNC STATE...
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
      found := qryTEAM.Locate('Lane', ALaneNum, LOptions);
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
   result := qryNearestSessionID.FieldByName('SessionID').AsInteger;
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
      result := dsSession.DataSet.Locate('SessionID', ASessionID, LOptions);
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
      result := dsSwimClub.DataSet.Locate('SwimClubID', ASwimClubID, LOptions);
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
      qryEvent.ApplyMaster;
      if LocateEventID(AEventID) then
      begin
        qryHeat.ApplyMaster;
        if not LocateHeatID(AHeatID) then
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

function TSCM.SyncSCMtoDT(aTDSessionNum, aTDEventNum, aTDHeatNum: Integer):
    boolean;
var
  found: boolean;
begin
  result := false;
  found := false;

  if not SyncCheckSession(aTDSessionNum) then exit;

  qryTEAM.DisableControls;
  qryINDV.DisableControls;
  qryHeat.DisableControls;
  qryEvent.DisableControls;
  qrySession.DisableControls;

  if qryEvent.Locate('EventNum', aTDEventNum, [])
  then
    found := qryHeat.Locate('HeatNum', aTDHeatNum, []);

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

procedure TSCM.BuildCSVEventData(AFileName: string);
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
    (NOTE: The application's folder contains a backup of this file.)
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

procedure TSCM.qryHeatAfterScroll(DataSet: TDataSet);
begin
  if (msgHandle <> 0) then
    PostMessage(msgHandle, SCM_UPDATEUI_SCM, 0,0);
end;


end.
