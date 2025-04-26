unit tdLoginBAK;

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
    btnDisconnect: TButton;
    btnConnect: TButton;
    RelativePanel1: TRelativePanel;
    pnlBody: TPanel;
    btnDone: TButton;

    procedure btnDisconnectClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnDoneClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
//    fDBName: String;
//    fDBConnection: TFDConnection;
    procedure ReadLoginParams();
    procedure WriteLoginParams();

  public
    { Public declarations }

  published
//    property DBName: string read fDBName write fDBName;
//    property DBConnection: TFDConnection read fDBConnection write fDBConnection;
  end;

var
  Login: TLogin;

implementation

{$R *.dfm}

uses exeinfo, System.IniFiles, frmMain, SCMUtility;


procedure TLogin.btnDisconnectClick(Sender: TObject);
begin
  // setting modal result will Close() the form;
  ModalResult := mrAbort;
end;

procedure TLogin.btnConnectClick(Sender: TObject);
var
  sc: TSimpleConnect;
begin
  if Assigned(SCM.scmConnection) then
  begin
    if (SCM.scmConnection.Connected) then
      SCM.scmConnection.Close;
    lblLoginErrMsg.Caption := 'Attempting to connect.';
    btnDisconnect.Visible := false;
    btnConnect.Visible := false;
    WriteLoginParams();
    SCM.scmConnection.Open;
    if (SCM.scmConnection.Connected) then
    begin
      btnDisconnect.Visible := true;
      btnConnect.Visible := false;
    end
    else
    begin
      lblLoginErrMsg.Caption := 'Could not connect.';
      btnDisconnect.Visible := false;
      btnConnect.Visible := true;
    end;
    sc.Free;
  end;
end;

procedure TLogin.btnDoneClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TLogin.FormCreate(Sender: TObject);
var
  AValue, ASection, AName: string;
begin
  lblLoginErrMsg.Visible := false;
  ReadLoginParams;
end;

procedure TLogin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_ESCAPE then
    ModalResult := mrAbort;
end;

procedure TLogin.FormShow(Sender: TObject);
var
DatabaseName, ParamValue: string;
begin
  lblLoginErrMsg.Caption := '';
  if not Assigned(SCM.scmConnection) then
  begin
    SCM.ReadConnectionDef('MSSQL_SwimClubMeet', 'DataBase', ParamValue);
    Caption := 'Login to the ' + DatabaseName + ' Database Server ...';
    lblLoginErrMsg.Visible := false;
    if SCM.scmConnection.Connected then
    begin
      btnDisconnect.Visible := true;
      btnConnect.Visible := false;
    end
    else
    begin
      btnDisconnect.Visible := false;
      btnConnect.Visible := true;
    end;
  end;
  btnConnect.SetFocus;
end;

procedure TLogin.ReadLoginParams();
var
  iFile: TIniFile;
  iniFileName, UseOsAuthentication: string;
begin
  iniFileName := SCM.scmFDManager.ActualConnectionDefFileName;
  if not FileExists(iniFileName) then exit;
  iFile := TIniFile.Create(iniFileName);
  edtServerName.Text := iFile.ReadString('MSSQL_SwimClubMeet', 'Server', 'localHost\SQLEXPRESS');
  edtUser.Text := iFile.ReadString('MSSQL_SwimClubMeet', 'User_Name', '');
  edtPassword.Text := iFile.ReadString('MSSQL_SwimClubMeet', 'Password', '');
  UseOsAuthentication := iFile.ReadString('MSSQL_SwimClubMeet', 'OSAuthent', 'Yes');
  UseOsAuthentication := LowerCase(UseOsAuthentication);
  if UseOsAuthentication.Contains('yes') or UseOsAuthentication.Contains('true') then
    chkbUseOsAuthentication.Checked := true else chkbUseOsAuthentication.Checked := false;
  iFile.Free;
end;

procedure TLogin.WriteLoginParams();
var
  iFile: TIniFile;
  iniFileName: string;
begin
  iniFileName := SCM.scmFDManager.ActualConnectionDefFileName;
  if not FileExists(iniFileName) then exit;
  iFile := TIniFile.Create(iniFileName);
  if chkbUseOsAuthentication.Checked then
    iFile.WriteString('MSSQL_SwimClubMeet', 'OSAuthent', 'Yes')
  else
    iFile.WriteString('MSSQL_SwimClubMeet', 'OSAuthent', 'No');
  iFile.WriteString('MSSQL_SwimClubMeet', 'Password', edtPassword.Text);
  iFile.WriteString('MSSQL_SwimClubMeet', 'User_Name', edtUser.Text);
  iFile.WriteString('MSSQL_SwimClubMeet', 'Server', edtServerName.Text);
  iFile.Free;
end;

end.
