unit dlgOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dmAppData, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.VirtualImage, Vcl.Mask, tdSetting;

type
  TOptions = class(TForm)
    btnClose: TButton;
    btnedtAppData: TButtonedEdit;
    btnedtMeetProgram: TButtonedEdit;
    btnedtResults: TButtonedEdit;
    btnedtReConstruct: TButtonedEdit;
    chkbxRenameSession: TCheckBox;
    lblAppCaption1: TLabel;
    lbledtDeviation: TLabeledEdit;
    lblAppData: TLabel;
    lblHeaderTitle: TLabel;
    lblMeetFolder: TLabel;
    lblEventCSV: TLabel;
    lblReConstructDO4: TLabel;
    pgcntrl: TPageControl;
    pnlBody: TPanel;
    pnlFooter: TPanel;
    pnlHeader: TPanel;
    rgrpMeanTimeMethod: TRadioGroup;
    tabSettings: TTabSheet;
    tabsheetPaths: TTabSheet;
    vimgDT: TVirtualImage;
    BrowseFolderDlg: TFileOpenDialog;
    rgrpSwimmerAge: TRadioGroup;
    dtpickSwimmerAge: TDateTimePicker;
    lblSwimmerAge: TLabel;
    chkbxFinalTime: TCheckBox;
    chkbxPadTime: TCheckBox;
    vimgAutoTimeSCM: TVirtualImage;
    vimgAutoTimeTD: TVirtualImage;
    vimgSplitSCM: TVirtualImage;
    vimgSplitTD: TVirtualImage;
    bhintOptions: TBalloonHint;
    vimginfo1: TVirtualImage;
    vimgInfo2: TVirtualImage;
    TabSheet1: TTabSheet;
    chk_EnableLoginPrompt: TCheckBox;
    chk_EnableSessionPrompt: TCheckBox;
    procedure btnCloseClick(Sender: TObject);
    procedure btnedtAppDataRightButtonClick(Sender: TObject);
    procedure btnedtMeetProgramRightButtonClick(Sender: TObject);
    procedure btnedtResultsRightButtonClick(Sender: TObject);
    procedure btnedtReConstructRightButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure vimginfo1MouseEnter(Sender: TObject);
    procedure vimginfo1MouseLeave(Sender: TObject);
    procedure vimgInfo2MouseEnter(Sender: TObject);
    procedure vimgInfo2MouseLeave(Sender: TObject);
  private
    procedure LoadFromSettings;
    procedure LoadSettings;
    procedure SaveToSettings;
  end;

var
  Options: TOptions;

implementation

{$R *.dfm}


procedure TOptions.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TOptions.btnedtAppDataRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for application data folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtAppData.Text) ;
  BrowseFolderDlg.DefaultExtension := '.DAT';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select SCM_TimeDrops data folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtAppData.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TOptions.btnedtMeetProgramRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for DT events CSV export folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtMeetProgram.Text) ;
  BrowseFolderDlg.DefaultExtension := '.JSON';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select SCM_TimeDrops program folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtMeetProgram.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TOptions.btnedtResultsRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for meets folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtResults.Text) ;
  BrowseFolderDlg.DefaultExtension := '.JSON';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select SCM_TimeDrops results folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtResults.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TOptions.btnedtReConstructRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for export of SCM to Dolphin Timing DO4 folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtReConstruct.Text) ;
  BrowseFolderDlg.DefaultExtension := '.JSON';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select SCM_TimeDrops re-construct folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtReConstruct.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TOptions.FormDestroy(Sender: TObject);
begin
  SaveToSettings;
end;

procedure TOptions.FormCreate(Sender: TObject);
begin
  // INIT ...
  pgcntrl.TabIndex := 0;
end;

procedure TOptions.FormShow(Sender: TObject);
begin
  LoadSettings;
end;

procedure TOptions.LoadFromSettings;
begin
  btnedtResults.Text := Settings.MeetsFolder;
  btnedtMeetProgram.Text := Settings.ProgramFolder;
  btnedtAppData.Text := Settings.AppData;
  btnedtReConstruct.Text := Settings.ReConstruct;

  case Settings.CalcRTMethod of
  1:
    // extended SCM method.
    rgrpMeanTimeMethod.ItemIndex := 1;
  else
    // standard behaviour as specified by Dolphin Timing. (default).
    rgrpMeanTimeMethod.ItemIndex := 0;
  end;

  chkbxFinalTime.Checked := Settings.UseTDfinalTime;
  chkbxPadTime.Checked := Settings.UseTDpadTime;
  chk_EnableLoginPrompt.Checked := Settings.EnableLoginPrompt;
  chk_EnableSessionPrompt.Checked := Settings.EnableSessionPrompt;

  try
    lbledtDeviation.Text := FloatToStr(Settings.AcceptedDeviation);
  except on E: Exception do
    lbledtDeviation.Text := '0.3';
  end;

end;

procedure TOptions.LoadSettings;
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

procedure TOptions.SaveToSettings;
begin
  Settings.MeetsFolder := btnedtResults.Text;
  Settings.ProgramFolder := btnedtMeetProgram.Text;
  Settings.AppData := btnedtAppData.Text;
  Settings.ReConstruct := btnedtReConstruct.Text;
  Settings.CalcRTMethod := rgrpMeanTimeMethod.ItemIndex;
  try
    Settings.AcceptedDeviation := strToFloat(lbledtDeviation.Text);
  except on E: Exception do
    Settings.AcceptedDeviation := 0.3;
  end;
  Settings.UseTDfinalTime := chkbxFinalTime.Checked;
  Settings.UseTDpadTime := chkbxPadTime.Checked;
  Settings.EnableLoginPrompt := chk_EnableLoginPrompt.Checked;
  Settings.EnableSessionPrompt := chk_EnableSessionPrompt.Checked;

  Settings.SaveToFile();
end;

procedure TOptions.vimginfo1MouseEnter(Sender: TObject);
begin
  bhintOptions.Title := 'finalTime vs AutoCalc';
  bhintOptions.Description := '''
  Checking this box results in using Time Drops' 'finalTime',
  instead of using SwimClubMeet's auto-calculated race time.

  SwimClubMeet offers two methods for auto-calculated race time.
  METHOD 1 - Standard Practice:
  - If there is one watch per lane, that time will also be
      placed in 'raceTime'.
  - If there are two watches for a given lane, the average
      will be computed and placed in 'raceTime'.
  - If there are three watch times for a given lane,
      the middle time will be placed in 'raceTime'.

  METHOD 2 - Enhanced:
  The average is always used—whether for two or three watch times.
  Deviation between three watch times is always checked, and
  SwimClubMeet may conclude that all watch times should be dropped.

  NOTES:
  If the difference between the two watch times exceeds the
  'Accepted Deviation', the average result time will NOT be computed,
  and warning icons will appear for both watch times in this lane.
  The 'raceTime' will be empty.
  Switch to manual mode and select which time to use.
  You are permitted to select both, in which case an average of the
  two watch times will be used in 'raceTime'.

  Rules for 'finalTime' are undocumented

  ''';

  bhintOptions.ShowHint;
end;

procedure TOptions.vimginfo2MouseEnter(Sender: TObject);
begin
  bhintOptions.Title := 'padTime vs Split-Time';
  bhintOptions.Description := '''
  Checking this box will use Time-Drops' 'padTime' instead
  of SwimClubMeet's calculated split time.' +
                 '
  SwimClubMeet calculates split times by searching all 10
  stored splits for each lane, identifying the maximum split time.
  SCM assumes split times are cumulative, and that the maximum
  split time represents the lane’s end time (i.e., the entrant's
  race time).

  There is no official documentation for Time-Drops' 'padTime'.
  However, it is likely that the anticipated split count provided
  when building the Meet Program plays a role in determining the
  final 'padTime'.

  ''';
  bhintOptions.ShowHint;

end;

procedure TOptions.vimginfo1MouseLeave(Sender: TObject);
begin
  bhintOptions.HideHint;
end;

procedure TOptions.vimgInfo2MouseLeave(Sender: TObject);
begin
  bhintOptions.HideHint;
end;

end.
