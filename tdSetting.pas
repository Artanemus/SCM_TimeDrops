unit tdSetting;

interface

uses
  system.IOUtils,
  system.SysUtils, system.Types, system.UITypes, system.Classes,
  system.Variants, VCL.Controls,
  XsuperObject,
  dmAppData;

type

  TPrgSetting = Class
  private
    { private declarations }

  protected
    { protected declarations }
  public
    { public declarations }
    Server: string;
    User: string;
    Password: string;
    OSAuthent: boolean;
    LoginTimeOut: integer;
    MeetsFolder: string;
    MeetProgramType: integer;
    ProgramFolder: string;
    AppData: string;
    ReConstruct: string;
    AcceptedDeviation: double;
    CalcRTMethod: integer;
    CalcSwimmerAge: integer;
    EnableRenameResultFiles: boolean;
    RaceNumber: integer;
    lastMeetProgramDate: TDateTime;
    UseTDpadTime: boolean;
    UseTDfinalTime: boolean;

    constructor Create();
    function GetDefaultSettingsFilename(): string;
    function GetSettingsFolder(): string;
    procedure LoadFromFile(AFileName: string = '');
    procedure SaveToFile(AFileName: string = '');

    { published declarations }
  end;

  const
    CONNECTIONTIMEOUT = 20;  // default is 0 - infinate...

var
  Settings: TPrgSetting;

implementation

constructor TPrgSetting.Create();
begin
  Server := '';
  User := '';
  Password := '';
  OSAuthent := false;
  LoginTimeOut := CONNECTIONTIMEOUT;
  MeetsFolder := 'c:\TimeDrops\Meets';
  MeetProgramType := 0; // Export a basic meet program (Minimalistic).
  ProgramFolder := 'c:\TimeDrops\Meets';
  AppData := 'c:\TimeDrops\AppData';
  ReConstruct := 'c:\TimeDrops\ReConstruct';
  AcceptedDeviation := 0.3;
  RaceNumber := 0;
  // 0 = default DT method : 1 = extended SCM method.
  CalcRTMethod := 0;
  CalcSwimmerAge := 0;
  EnableRenameResultFiles := false;
  // The datetime of the last meet program contructed and saved _
  // (by SCM_TimeDrops) to the Time-Drops Meet folder.
  lastMeetProgramDate := Now;
  UseTDpadTime := false;
  UseTDfinalTime := false;
  {
  ForceDirectories creates a new directory as specified in Dir,
  which must be a fully-qualified path name. If the directories given in
  the path do not yet exist, ForceDirectories attempts to create them
  }
  ForceDirectories(Settings.GetSettingsFolder());
end;

function TPrgSetting.GetDefaultSettingsFilename(): string;
begin
  result := TPath.Combine(GetSettingsFolder(), 'initTimeDrops.json');
end;

function TPrgSetting.GetSettingsFolder(): string;
begin

//  result := TPath.Combine(TPath.GetHomePath(), 'MyProg');
//  result := ExtractFilePath(ParamStr(0));

{$IFDEF MACOS}
  Result := TPath.Combine(TPath.GetLibraryPath(), 'Artanemus\SWimClubMeet');
{$ELSE}
  // GETHOMEPATH = C:Users\<username>\AppData\Roaming (WINDOWS)
  // Should also work on ANDROID.
  Result := TPath.Combine(TPath.GetHomePath(), 'Artanemus\SwimClubMeet\TimeDrops');
{$ENDIF}

end;

procedure TPrgSetting.LoadFromFile(AFileName: string = '');
var
  Json: string;
begin
  if AFileName = '' then
    AFileName := GetDefaultSettingsFilename();

  if not FileExists(AFileName) then
    exit;

  Json := TFile.ReadAllText(AFileName, TEncoding.UTF8);
  AssignFromJSON(Json); // magic method from XSuperObject's helper
end;

procedure TPrgSetting.SaveToFile(AFileName: string = '');
var
  Json: string;
begin
  if AFileName = '' then
    AFileName := GetDefaultSettingsFilename();

  Json := AsJSON(True); // magic method from XSuperObject's helper too
  TFile.WriteAllText(AFileName, Json, TEncoding.UTF8);
end;




end.
