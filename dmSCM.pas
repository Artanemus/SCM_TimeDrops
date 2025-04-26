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
  FireDAC.Comp.DataSet;

type
  TSCM = class(TDataModule)
    tblSwimClub: TFDTable;
    dsSwimClub: TDataSource;
    qrySCMSystem: TFDQuery;
    scmFDManager: TFDManager;
    DebugConnection: TFDConnection;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    fDBModel, fDBVersion, fDBMajor, fDBMinor: integer;
    FIsActive: boolean;
  public
    { Public declarations }
    scmConnection: TFDConnection;
    fLoginTimeout: integer;

    procedure ActivateTable();
    procedure DeActivateTable();
    procedure UpdateConnectionDef(const ConnectionName, ParamName, ParamValue: string);
    procedure ReadConnectionDef(const ConnectionName, ParamName: string; out ParamValue: string);

    function  GetDBVerInfo(): string;

    property IsActive: boolean read FIsActive write FIsActive;
  end;

var
  SCM: TSCM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}



{$R *.dfm}

uses
  Winapi.Windows;



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

procedure TSCM.ActivateTable;
begin
  // activate the SCM system table .
  tblSwimClub.Open;
  if tblSwimClub.Active then
    FIsActive := true;
end;

procedure TSCM.DeActivateTable;
begin
  // close all ....
  tblSwimClub.Close;
  FIsActive := false;
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

(*
You do not need to make the TFDManager inactive before updating its
ConnectionDefs. The TFDManager allows you to modify connection definitions
dynamically at runtime without deactivating it.
*)

procedure TSCM.UpdateConnectionDef(const ConnectionName, ParamName,
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

procedure TSCM.DataModuleCreate(Sender: TObject);
var
  ExpandedFn, msg: string;
begin
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


end.
