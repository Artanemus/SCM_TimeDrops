unit dlgPostData;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, dmAppData,
  Vcl.VirtualImage;

type
  TPostData = class(TForm)
    pnlHeader: TPanel;
    pnlBody: TPanel;
    pnlFooter: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    rgrpSelection: TRadioGroup;
    vimgPostData: TVirtualImage;
    lblHeaderTitle: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PostData: TPostData;

implementation

{$R *.dfm}

procedure TPostData.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TPostData.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TPostData.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if key = VK_ESCAPE then
  begin
    ModalResult := mrAbort;
  end;
end;

end.
