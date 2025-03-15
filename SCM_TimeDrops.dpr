program SCM_TimeDrops;

uses
  Vcl.Forms,
  tdLogin in 'tdLogin.pas' {Login},
  dmSCM in 'dmSCM.pas' {SCM: TDataModule},
  dmAppData in 'dmAppData.pas' {AppData: TDataModule},
  SCMDefines in '..\SCM_SHARED\SCMDefines.pas',
  SCMSimpleConnect in '..\SCM_SHARED\SCMSimpleConnect.pas',
  tdSetting in 'tdSetting.pas',
  XSuperJSON in '..\x-superobject\XSuperJSON.pas',
  XSuperObject in '..\x-superobject\XSuperObject.pas',
  frmMain in 'frmMain.pas' {Main},
  Vcl.PlatformVclStylesActnCtrls in '..\SCM_SHARED\Vcl.PlatformVclStylesActnCtrls.pas',
  uAppUtils in 'uAppUtils.pas',
  DirectoryWatcher in 'DirectoryWatcher.pas',
  tdMeetProgram in 'tdMeetProgram.pas',
  Vcl.Themes,
  Vcl.Styles,
  tdReConstruct in 'tdReConstruct.pas',
  dlgOptions in 'dlgOptions.pas' {Options},
  dlgPostData in 'dlgPostData.pas' {PostData},
  dlgTreeViewData in 'dlgTreeViewData.pas' {TreeViewData},
  dlgTreeViewSCM in 'dlgTreeViewSCM.pas' {TreeViewSCM},
  dlgDataDebug in 'dlgDataDebug.pas' {DataDebug},
  dlgUserRaceTime in 'dlgUserRaceTime.pas' {UserRaceTime},
  SCMUtility in '..\SCM_SHARED\SCMUtility.pas',
  dlgSessionPicker in 'dlgSessionPicker.pas' {SessionPicker},
  tdResults in 'tdResults.pas',
  tdMeetProgramPick in 'tdMeetProgramPick.pas' {MeetProgramPick};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TLogin, Login);
  Application.Run;
end.
