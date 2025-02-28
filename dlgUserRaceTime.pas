unit dlgUserRaceTime;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.WinXCtrls;

type
  TUserRaceTime = class(TForm)
    pnlFooter: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    edtRaceTimeUser: TEdit;
    rpnlBody: TRelativePanel;
    lblErrMsg: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    fRaceTime: TTime;
    fRaceTimeUser: TTime;
  public
    { Public declarations }
    property RaceTime: TTime read FRaceTime write FRaceTime;
    property RaceTimeUser: TTime read fRaceTimeUser write fRaceTimeUser;
  end;

var
  UserRaceTime: TUserRaceTime;

implementation

{$R *.dfm}

uses System.DateUtils;

function TryStrToWord(const S: string; out Value: Word): Boolean;
var
  intValue: Integer;
begin
  Result := TryStrToInt(S, intValue) and (intValue >= Low(Word)) and (intValue
    <= High(Word));
  if Result then
    Value := Word(intValue);
end;

function TryStrToTimeWithMilliseconds(const S: string; var Time: TTime): Boolean;
var
  Min, Sec, MSec: Word;
  TimeParts: TArray<string>;
  MSecStr: string;
begin
  Result := False;
  // Split the string into minutes, seconds, and milliseconds
  TimeParts := S.Split([':', '.']);

  // Ensure there are exactly 3 parts: minutes, seconds, and milliseconds
  if Length(TimeParts) = 3 then
  begin
    // Try to convert minutes and seconds to a word (unsigned 16-bit integer)
    if TryStrToWord(TimeParts[0], Min) and
       TryStrToWord(TimeParts[1], Sec) then
    begin
      // Process milliseconds part
      MSecStr := TimeParts[2];
      // Pad the milliseconds part with zeros if necessary to ensure it is three digits
      while Length(MSecStr) < 3 do
        MSecStr := MSecStr + '0';

      if TryStrToWord(MSecStr, MSec) then
      begin
        // Validate the range of each part
        if (Min < 60) and (Sec < 60) and (MSec < 1000) then
        begin
          // Encode the time
          Time := EncodeTime(0, Min, Sec, MSec);
          Result := True;
        end;
      end;
    end;
  end;
end;

procedure TUserRaceTime.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TUserRaceTime.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TUserRaceTime.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
t: TTime;
begin
  if ModalResult = mrOk then
  begin
    if TryStrToTimeWithMilliseconds(edtRaceTimeUser.Text,t) then
    begin
      fRaceTimeUser := t;
      CanClose := true;
    end
    else
      CanClose := false;
  end;
end;

procedure TUserRaceTime.FormCreate(Sender: TObject);
begin
  fRaceTime := 0;
  fRaceTimeUser := 0;
end;

procedure TUserRaceTime.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if (Key = VK_ESCAPE) then
  begin
    ModalResult := mrCancel;
  end;
   lblErrMsg.caption := '';
end;

procedure TUserRaceTime.FormShow(Sender: TObject);
var
fs: TFormatSettings;
begin
  fs := TFormatSettings.Create;
  { Override the default format specified by the LongTimeFormat global variable. }
  fs.LongTimeFormat := 'nn:ss.zzz';
  fs.TimeSeparator := ':';
  if (fRaceTimeUser <> 0) then
    edtRaceTimeUser.Text := TimeToStr(TimeOF(fRaceTimeUser), fs)
  else
    edtRaceTimeUser.Text := TimeToStr(TimeOf(fRaceTime), fs);
end;

end.
