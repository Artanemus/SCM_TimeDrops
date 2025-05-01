unit dlgInfoPushResults;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  tdSetting;

type
  TInfoPushResults = class(TForm)
    pnlBody: TPanel;
    pnlFooter: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    RichEdit1: TRichEdit;
    chkbHideInfoBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InfoPushResults: TInfoPushResults;

implementation

{$R *.dfm}

procedure TInfoPushResults.FormCreate(Sender: TObject);
begin
  if Assigned(Settings) then
    chkbHideInfoBox.Checked := Settings.HideExtendedHelp;
end;

procedure TInfoPushResults.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TInfoPushResults.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TInfoPushResults.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(Settings) then
    Settings.HideExtendedHelp := chkbHideInfoBox.Checked;
end;

procedure TInfoPushResults.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

end.
