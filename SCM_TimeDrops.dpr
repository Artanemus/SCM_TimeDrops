program SCM_TimeDrops;

uses
  Vcl.Forms,
  tdLogin in 'tdLogin.pas' {Login},
  dmSCM in 'dmSCM.pas' {SCM: TDataModule},
  dmTDData in 'dmTDData.pas' {DTData: TDataModule},
  SCMDefines in '..\SCM_SHARED\SCMDefines.pas',
  SCMSimpleConnect in '..\SCM_SHARED\SCMSimpleConnect.pas',
  tdSetting in 'tdSetting.pas',
  XSuperJSON in '..\x-superobject\XSuperJSON.pas',
  XSuperObject in '..\x-superobject\XSuperObject.pas',
  frmMain in 'frmMain.pas' {Main},
  Vcl.PlatformVclStylesActnCtrls in '..\SCM_SHARED\Vcl.PlatformVclStylesActnCtrls.pas',
  tdUtils in 'tdUtils.pas',
  DirectoryWatcher in 'DirectoryWatcher.pas',
  tdMeetPrg in 'tdMeetPrg.pas',
  Vcl.Themes,
  Vcl.Styles,
  tdReConstruct in 'tdReConstruct.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TLogin, Login);
  Application.Run;
end.
