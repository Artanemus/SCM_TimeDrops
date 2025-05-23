unit dlgInfoScanResults;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  tdSetting;

type
  TInfoScanResults = class(TForm)
    pnlBody: TPanel;
    RichEditInfo: TRichEdit;
    pnlFooter: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
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
  InfoScanResults: TInfoScanResults;

implementation

{$R *.dfm}

procedure TInfoScanResults.FormCreate(Sender: TObject);
begin
  if Assigned(Settings) then
    chkbHideInfoBox.Checked := Settings.HideExtendedHelp;
end;

procedure TInfoScanResults.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TInfoScanResults.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TInfoScanResults.FormClose(Sender: TObject; var Action:
    TCloseAction);
begin
  if Assigned(Settings) then
    Settings.HideExtendedHelp := chkbHideInfoBox.Checked;
end;

procedure TInfoScanResults.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

end.
