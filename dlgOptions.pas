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
    btnedtEventCSV: TButtonedEdit;
    btnedtMeetFolder: TButtonedEdit;
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
    rgrpPrecedence: TRadioGroup;
    rgrpSwimmerAge: TRadioGroup;
    dtpickSwimmerAge: TDateTimePicker;
    lblSwimmerAge: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnedtAppDataRightButtonClick(Sender: TObject);
    procedure btnedtEventCSVRightButtonClick(Sender: TObject);
    procedure btnedtMeetFolderRightButtonClick(Sender: TObject);
    procedure btnedtReConstructRightButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
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

procedure TOptions.btnedtEventCSVRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for DT events CSV export folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtEventCSV.Text) ;
  BrowseFolderDlg.DefaultExtension := '.JSON';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select SCM_TimeDrops program folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtEventCSV.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TOptions.btnedtMeetFolderRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for meets folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtMeetFolder.Text) ;
  BrowseFolderDlg.DefaultExtension := '.JSON';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select SCM_TimeDrops results folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtMeetFolder.Text := BrowseFolderDlg.FileName;
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
  btnedtMeetFolder.Text := Settings.MeetsFolder;
  btnedtEventCSV.Text := Settings.ProgramFolder;
  btnedtAppData.Text := Settings.AppData;
  btnedtReConstruct.Text := Settings.ReConstruct;
  case Settings.Precedence of
  dtPrecHeader:
    rgrpPrecedence.ItemIndex := 0;
  dtPrecFileName:
    rgrpPrecedence.ItemIndex := 1;
  end;
  case Settings.CalcRTMethod of
  1:
    // extended SCM method.
    rgrpMeanTimeMethod.ItemIndex := 1;
  2:
    // Use TimeDrops 'finalTime' field.
    rgrpMeanTimeMethod.ItemIndex := 2;
  else
    // default DT method (default).
    rgrpMeanTimeMethod.ItemIndex := 0;
  end;
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
  Settings.MeetsFolder := btnedtMeetFolder.Text;
  Settings.ProgramFolder := btnedtEventCSV.Text;
  Settings.AppData := btnedtAppData.Text;
  Settings.ReConstruct := btnedtReConstruct.Text;
  case rgrpPrecedence.ItemIndex of
    1:
    Settings.Precedence := dtPrecFileName;
    else
    Settings.Precedence := dtPrecHeader;
  end;
  Settings.CalcRTMethod := rgrpMeanTimeMethod.ItemIndex;
  try
    Settings.AcceptedDeviation := strToFloat(lbledtDeviation.Text);
  except on E: Exception do
    Settings.AcceptedDeviation := 0.3;
  end;
  Settings.SaveToFile();
end;

end.
