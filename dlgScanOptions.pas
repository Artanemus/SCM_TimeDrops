unit dlgScanOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, tdSetting,
  uAppUtils;

type
  TScanOptions = class(TForm)
    pnlHeader: TPanel;
    pnlBody: TPanel;
    pnlFooter: TPanel;
    lblHeader: TLabel;
    rgrpScanOptions: TRadioGroup;
    edtSessionID: TEdit;
    lblSessionID: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FfSessionID: Integer;
    procedure SetfSessionID(const Value: Integer);
    { Private declarations }
  public
    property fSessionID: Integer read FfSessionID write SetfSessionID;
    { Public declarations }
  end;

var
  ScanOptions: TScanOptions;

implementation

{$R *.dfm}

procedure TScanOptions.FormDestroy(Sender: TObject);
begin
  if Assigned(Settings) then
  begin
    Settings.ScanOption := rgrpScanOptions.ItemIndex;
    Settings.ScanOptionSessionID := fSessionID;
  end;
end;

procedure TScanOptions.FormCreate(Sender: TObject);
begin
  edtSessionID.Text := '';
  fSessionID := 0;
  if Assigned(Settings) then
  begin
    if Settings.ScanOption in [0,1] then
      rgrpScanOptions.ItemIndex := Settings.ScanOption
    else
      rgrpScanOptions.ItemIndex := -1;
    edtSessionID.Text := IntToStr(Settings.ScanOptionSessionID);
  end;
end;

procedure TScanOptions.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TScanOptions.btnOkClick(Sender: TObject);
var
i: integer;
begin
  if length(edtSessionID.Text) > 0 then
  begin
    // NumbersOnly = true;
    // Note, however, that a user can paste non-numeric characters in the
    // textfield even when this property is set
    i := StrToIntDef(uAppUtils.StripNonNumeric(edtSessionID.Text), 0);
    fSessionID := i;
  end else fSessionID := 0;
  ModalResult := mrOk;
end;

procedure TScanOptions.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_Escape then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TScanOptions.SetfSessionID(const Value: Integer);
begin
  FfSessionID := Value;
end;


end.
