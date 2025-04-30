unit dlgInfoRescanResults;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TInfoReScanResults = class(TForm)
    pnlBody: TPanel;
    chkbDoShowAgain: TCheckBox;
    RichEditInfo: TRichEdit;
    pnlFooter: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    chkbHideInfoBox: TCheckBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InfoReScanResults: TInfoReScanResults;

implementation

{$R *.dfm}

procedure TInfoReScanResults.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TInfoReScanResults.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TInfoReScanResults.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

end.
