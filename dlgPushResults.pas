unit dlgPushResults;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TPushResults = class(TForm)
    pnlBody: TPanel;
    pnlFooter: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    chkbDoShowAgain: TCheckBox;
    RichEdit1: TRichEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PushResults: TPushResults;

implementation

{$R *.dfm}

procedure TPushResults.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TPushResults.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TPushResults.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

end.
