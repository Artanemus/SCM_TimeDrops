unit tdMeetProgramPick;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, dmIMG,
  Vcl.VirtualImage, tdSetting;

type
  TMeetProgramPick = class(TForm)
    lblEventCSV: TLabel;
    btnedtMeetProgram: TButtonedEdit;
    BrowseFolderDlg: TFileOpenDialog;
    rgrpMeetProgramType: TRadioGroup;
    pnlFooter: TPanel;
    pnlBody: TPanel;
    vimgInfo1: TVirtualImage;
    BalloonHint1: TBalloonHint;
    vimgInfo2: TVirtualImage;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnedtMeetProgramRightButtonClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure vimgInfo1MouseEnter(Sender: TObject);
    procedure vimgInfo1MouseLeave(Sender: TObject);
    procedure vimgInfo2MouseEnter(Sender: TObject);
    procedure vimgInfo2MouseLeave(Sender: TObject);
  private
    procedure LoadFromSettings;
    procedure LoadSettings;
    procedure SaveToSettings;
  public
    { Public declarations }
  end;

var
  MeetProgramPick: TMeetProgramPick;

implementation

{$R *.dfm}

procedure TMeetProgramPick.btnedtMeetProgramRightButtonClick(Sender: TObject);

begin
  // Default folder to browse for TD "meet program" files.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(Settings.MeetsFolder) ;
  if BrowseFolderDlg.Execute then
  begin
    btnedtMeetProgram.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TMeetProgramPick.vimgInfo1MouseEnter(Sender: TObject);
begin
  BalloonHint1.Title := 'Export Folder ...';
  BalloonHint1.Description := '''
    The SCM_TimeDrops writes a file to the given folder with the name “meet_program.json”.
    This file contains JSON which can be read by the Time Drops system to initalize
    and/or update it's application state.
  ''';
  BalloonHint1.ShowHint(vimgInfo1);
end;

procedure TMeetProgramPick.vimgInfo1MouseLeave(Sender: TObject);
begin
  BalloonHint1.HideHint;
end;

procedure TMeetProgramPick.vimgInfo2MouseEnter(Sender: TObject);
begin
  BalloonHint1.Title := 'Meet Program Type ...';
  BalloonHint1.Description := '''
    The basic meet program has the minimum allowed JSON data. (Minimalistic).
    The detailed version contains all the JSON data as per the Kotlin class
    definition given in "TimeDrops Interface Specifications".
  ''';
  BalloonHint1.ShowHint(vimgInfo2);
end;

procedure TMeetProgramPick.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TMeetProgramPick.btnOkClick(Sender: TObject);
begin
  SaveToSettings;
  ModalResult := mrOk;
end;

procedure TMeetProgramPick.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TMeetProgramPick.FormShow(Sender: TObject);
begin
  LoadSettings;
end;

procedure TMeetProgramPick.vimgInfo2MouseLeave(Sender: TObject);
begin
  BalloonHint1.HideHint;
end;

procedure TMeetProgramPick.LoadFromSettings;
begin
  btnedtMeetProgram.Text := Settings.ProgramFolder;
  rgrpMeetProgramType.ItemIndex := Settings.MeetProgramType;
end;

procedure TMeetProgramPick.LoadSettings;
begin
  if Settings = nil then
    Settings := TPrgSetting.Create;
  if not FileExists(Settings.GetDefaultSettingsFilename()) then
  begin
    ForceDirectories(Settings.GetSettingsFolder());
    Settings.SaveToFile();
  end;
  Settings.LoadFromFile();
  LoadFromSettings();
end;

procedure TMeetProgramPick.SaveToSettings;
begin
  Settings.ProgramFolder := btnedtMeetProgram.Text;
  Settings.MeetProgramType := rgrpMeetProgramType.ItemIndex;
  Settings.SaveToFile();
end;

end.
