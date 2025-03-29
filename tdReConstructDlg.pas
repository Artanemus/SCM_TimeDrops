unit tdReConstructDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.VirtualImage, tdSetting;

type
  TReConstructDlg = class(TForm)
    pnlFooter: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlBody: TPanel;
    lblEventCSV: TLabel;
    vimgInfo1: TVirtualImage;
    btnedtExportFolder: TButtonedEdit;
    BrowseFolderDlg: TFileOpenDialog;
    BalloonHint1: TBalloonHint;
    lblInfo: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnedtExportFolderClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure vimgInfo1MouseEnter(Sender: TObject);
    procedure vimgInfo1MouseLeave(Sender: TObject);
  private
    procedure LoadFromSettings;
    procedure LoadSettings;
    procedure SaveToSettings;

  public
    { Public declarations }
  end;

var
  ReConstructDlg: TReConstructDlg;

implementation

{$R *.dfm}

procedure TReConstructDlg.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TReConstructDlg.btnedtExportFolderClick(Sender: TObject);
begin
  // Default folder to export result files.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(Settings.MeetsFolder) ;
  if BrowseFolderDlg.Execute then
  begin
    btnedtExportFolder.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TReConstructDlg.btnOkClick(Sender: TObject);
begin
  SaveToSettings;
  ModalResult := mrOk;
end;

procedure TReConstructDlg.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TReConstructDlg.FormShow(Sender: TObject);
begin
  LoadSettings;
end;

procedure TReConstructDlg.LoadFromSettings;
begin
  btnedtExportFolder.Text := Settings.ReConstruct;
end;

procedure TReConstructDlg.LoadSettings;
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

procedure TReConstructDlg.SaveToSettings;
begin
  Settings.ReConstruct := btnedtExportFolder.Text;
  Settings.SaveToFile();
end;

procedure TReConstructDlg.vimgInfo1MouseEnter(Sender: TObject);
begin
  BalloonHint1.Title := 'Export Folder ...';
  BalloonHint1.Description := '''
    The SCM_TimeDrops writes files to the given folder with the pattern
    "SessionSSSS_Event_EEEE_HeatHHHH_RaceRRRR_XXX.json".
    These files contains JSON data identical to "results" files produced by
    Time-Drops.
    With each file written a sudo "Timing System" status file is updated.
    These files can be used to simulate or repair a Time-Drops session (meet).
  ''';
  BalloonHint1.ShowHint(vimgInfo1);
end;

procedure TReConstructDlg.vimgInfo1MouseLeave(Sender: TObject);
begin
  BalloonHint1.HideHint;

end;

end.
