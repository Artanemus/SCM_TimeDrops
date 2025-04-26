unit dlgFDExplorer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFDExplorer = class(TForm)
    pnlBody: TPanel;
    pnlFooter: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    lblBodyText2: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FDExplorer: TFDExplorer;

implementation

{$R *.dfm}

procedure TFDExplorer.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFDExplorer.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TFDExplorer.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then ModalResult := mrCancel;
end;

end.
