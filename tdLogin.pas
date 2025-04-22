unit tdLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.Actions,
  Vcl.ActnList, Vcl.Imaging.pngimage, Vcl.WinXCtrls, Vcl.StdCtrls, dmSCM,
  tdSetting, SCMDefines, SCMSimpleConnect, dmAppData,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB;

type
  TLogin = class(TForm)
    lblServer: TLabel;
    lblUserName: TLabel;
    lblPassword: TLabel;
    lblLoginErrMsg: TLabel;
    chkbUseOsAuthentication: TCheckBox;
    edtPassword: TEdit;
    edtServerName: TEdit;
    edtUser: TEdit;
    pnlSideBar: TPanel;
    imgDTBanner: TImage;
    ActionList1: TActionList;
    actnConnect: TAction;
    actnDisconnect: TAction;
    actnTimeDrops: TAction;
    Panel2: TPanel;
    lblMsg: TLabel;
    btnAbort: TButton;
    btnConnect: TButton;
    RelativePanel1: TRelativePanel;
    pnlBody: TPanel;

    procedure btnAbortClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    fDBName: String;
    fDBConnection: TFDConnection;

  public
    { Public declarations }

  published
    property DBName: string read fDBName write fDBName;
    property DBConnection: TFDConnection read fDBConnection write fDBConnection;
  end;

var
  Login: TLogin;

implementation

{$R *.dfm}

uses exeinfo, System.IniFiles, frmMain, SCMUtility;


procedure TLogin.btnAbortClick(Sender: TObject);
begin
  // setting modal result will Close() the form;
  ModalResult := mrAbort;
end;

procedure TLogin.btnConnectClick(Sender: TObject);
var
  sc: TSimpleConnect;
begin
  // Hide the Login and abort buttons while attempting connection
  lblLoginErrMsg.Visible := false;
  btnAbort.Visible := false;
  btnConnect.Visible := false;
  lblMsg.Visible := true;
  lblMsg.Update();
  Application.ProcessMessages();

  if Assigned(fDBConnection) then
  begin
    sc := TSimpleConnect.CreateWithConnection(Self, fDBConnection);

    sc.DBName := fDBName;  // default dbo.SwimClubMeet.
    // ON SUCCESS - SimpleMakeTemporyConnection saves the connection details
    // to %AppData%\Artanemus\SCM\SCM_SharedPref.ini
    sc.SimpleMakeTemporyConnection(edtServerName.Text, edtUser.Text,
      edtPassword.Text, chkbUseOsAuthentication.Checked);
    lblMsg.Visible := false;

    if (fDBConnection.Connected) then
    begin
      // save login params?

      // setting modal result will Close() the form;
      ModalResult := mrOk;
    end
    else
    begin
      // show error message - let user try again or abort
      lblLoginErrMsg.Visible := true;
      btnAbort.Visible := true;
      btnConnect.Visible := true;
    end;
    sc.Free;
  end;
end;

procedure TLogin.FormCreate(Sender: TObject);
var
  AValue, ASection, AName: string;
begin
  lblLoginErrMsg.Visible := false;
  lblMsg.Visible := false;
  fDBName := 'SwimClubMeet'; // DEFAULT

  // Read last successful connection params and load into controls.
  // %AppData%\Artanemus\SCM\SCM_SharedPref.ini
  ASection := 'MSSQL_Connection';
  AName := 'Server';
  edtServerName.Text := LoadSharedIniFileSetting(ASection, AName);
  AName := 'User';
  edtUser.Text := LoadSharedIniFileSetting(ASection, AName);
  AName := 'Password';
  edtPassword.Text := LoadSharedIniFileSetting(ASection, AName);
  AName := 'OsAuthent';
  AValue := LoadSharedIniFileSetting(ASection, AName);
  if ((UpperCase(AValue) = 'YES') or (UpperCase(AValue) = 'TRUE')) then
    chkbUseOsAuthentication.Checked := true
  else
    chkbUseOsAuthentication.Checked := false;
end;

procedure TLogin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_ESCAPE then
    ModalResult := mrAbort;
end;

procedure TLogin.FormShow(Sender: TObject);
begin
  Caption := 'Login to the ' + fDBName + ' Database Server ...';

  if not Assigned(fDBConnection) then
  begin
    lblLoginErrMsg.Visible := false;
    lblLoginErrMsg.Caption := 'SCM SYSTEM ERROR : Connection not assigned!';
    btnAbort.Visible := true;
    btnConnect.Visible := false;
  end;

  btnConnect.SetFocus;
end;

end.
