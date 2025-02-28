unit frmMain;

{
(Typical Meet Manager)  ... will read the data into the proper lanes.
- If there is one watch per lane, that time will also be placed in the result
column.
- If there are 3 watch times for a given lane, the middle time will be placed in
  the result column.
- If there are two watches for a given lane, the average will be computed and
  placed in the result column. Please note that if there is .3 or more seconds
  difference between the two watch times, the average result time will NOT be
  computed and a yellow line will show for this lane. Decide whether to throw out one
  of the watch times if you determine one of them is way off. If you are OK with the
  two times, then click Ctrl-K to display the watch averaging menu and it will compute
  the average for you and place it in the result column. If one of the times is no good,
  delete it and use Ctrl-K, or simply type in the time of the one good watch.
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ControlList, Vcl.VirtualImage, Vcl.Buttons, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.Menus, dmSCM, dmAppData, tdSetting, FireDAC.Comp.Client,
  Data.DB, Vcl.Grids, Vcl.DBGrids, SCMDefines, System.StrUtils, AdvUtil, AdvObj,
  BaseGrid, AdvGrid, DBAdvGrid, System.Actions, Vcl.ActnList, Vcl.ToolWin,
  Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ExtDlgs, FireDAC.Stan.Param, Vcl.ComCtrls, Vcl.DBCtrls, tdReConstruct,
  Vcl.PlatformVclStylesActnCtrls, Vcl.WinXPanels, Vcl.WinXCtrls,
  System.Types, System.IOUtils, uAppUtils, Math, DirectoryWatcher;

type
  TMain = class(TForm)
    actnManager: TActionManager;
    actnMenuBar: TActionMainMenuBar;
    actnSelectSession: TAction;
    dtGrid: TDBAdvGrid;
    btnNextDTFile: TButton;
    btnNextEvent: TButton;
    btnPrevDTFile: TButton;
    btnPrevEvent: TButton;
    FileSaveDlgMeetProgram: TFileSaveDialog;
    lblEventDetails: TLabel;
    lblHeatNum: TLabel;
    lblMeters: TLabel;
    PickDTFolderDlg: TFileOpenDialog;
    sbtnSyncDTtoSCM: TSpeedButton;
    scmGrid: TDBAdvGrid;
    spbtnPost: TSpeedButton;
    vimgHeatNum: TVirtualImage;
    vimgHeatStatus: TVirtualImage;
    vimgRelayBug: TVirtualImage;
    vimgStrokeBug: TVirtualImage;
    pBar: TProgressBar;
    dbtxtDTFileName: TDBText;
    actnExportDTCSV: TAction;
    actnReConstructDO4: TAction;
    actnReConstructDO3: TAction;
    actnPreferences: TAction;
    actnImportAppendDO: TAction;
    actnClearReScanMeets: TAction;
    pnlSCM: TPanel;
    pnlDT: TPanel;
    actnSaveSession: TAction;
    actnLoadSession: TAction;
    rpnlBody: TRelativePanel;
    pnlTool1: TPanel;
    pnlTool2: TPanel;
    stackpnlTool2: TStackPanel;
    ShapeSpacer: TShape;
    actnAbout: TAction;
    actnSyncDT: TAction;
    actnConnect: TAction;
    actnPost: TAction;
    lblMetersRelay: TLabel;
    lblSessionStart: TLabel;
    btnPickSCMTreeView: TButton;
    btnPickDTTreeView: TButton;
    actnSelectSwimClub: TAction;
    btnDataDebug: TButton;
    lblDTDetails: TLabel;
    actnRefresh: TAction;
    DTAppendFile: TFileOpenDialog;
    actnReportSCMSession: TAction;
    actnReportDT: TAction;
    actnReportSCMEvent: TAction;
    sbtnAutoPatch: TSpeedButton;
    sbtnSyncSCMtoDT: TSpeedButton;
    sbtnRefreshSCM: TSpeedButton;
    ShapeSpaceerSCM: TShape;
    actnSyncSCM: TAction;
    StatBar: TStatusBar;
    Timer1: TTimer;
    procedure actnExportDTCSVExecute(Sender: TObject);
    procedure actnExportDTCSVUpdate(Sender: TObject);
    procedure actnClearReScanMeetsExecute(Sender: TObject);
    procedure actnImportAppendDOExecute(Sender: TObject);
    procedure actnPostExecute(Sender: TObject);
    procedure actnPostUpdate(Sender: TObject);
    procedure actnPreferencesExecute(Sender: TObject);
    procedure actnReConstructDO3Execute(Sender: TObject);
    procedure actnReConstructDO3Update(Sender: TObject);
    procedure actnReConstructDO4Execute(Sender: TObject);
    procedure actnReConstructDO4Update(Sender: TObject);
    procedure actnRefreshExecute(Sender: TObject);
    procedure actnSelectSessionExecute(Sender: TObject);
    procedure actnSetDTMeetsFolderExecute(Sender: TObject);
    procedure actnSyncDTExecute(Sender: TObject);
    procedure actnSyncSCMExecute(Sender: TObject);
    procedure btnDataDebugClick(Sender: TObject);
    procedure btnNextDTFileClick(Sender: TObject);
    procedure btnNextEventClick(Sender: TObject);
    procedure btnPickDTTreeViewClick(Sender: TObject);
    procedure btnPickSCMTreeViewClick(Sender: TObject);
    procedure btnPrevDTFileClick(Sender: TObject);
    procedure btnPrevEventClick(Sender: TObject);
    procedure dtGridClickCell(Sender: TObject; ARow, ACol: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure scmGridGetDisplText(Sender: TObject; ACol, ARow: Integer; var Value:
        string);
    procedure Timer1Timer(Sender: TObject);

  private
    { Private declarations }
    FConnection: TFDConnection;
    fDolphinMeetsFolder: string;
    // dtPrecedence = (dtPrecHeader, dtPrecFileName);
    fPrecedence: dmAppData.dtPrecedence;
    fDirectoryWatcher: TDirectoryWatcher;
    { On FormShow - prompt user to select session.
      Default value : FALSE     }
    fFlagSelectSession: boolean;

    procedure OnFileChanged(Sender: TObject; const FileName: string);

    procedure LoadFromSettings; // JSON Program Settings
    procedure LoadSettings; // JSON Program Settings
    procedure SaveToSettings; // JSON Program Settings
    procedure UpdateCaption();
    procedure UpdateSessionStartLabel();
    procedure UpdateEventDetailsLabel();
    procedure UpdateDTDetailsLabel();
    procedure DeleteFilesWithWildcard(const APath, APattern: string);
    procedure ReconstructAndExportFiles(fileExtension: string; messageText: string);
    procedure UpdateCellIcons(ADataset: TDataSet; ARow: Integer; AActiveRT:
        dtActiveRT);

  const
    AcceptedTimeKeeperDeviation = 0.3;
    SCM_SELECTSESSION = WM_USER + 999;

  protected
    procedure MSG_UpdateUI(var Msg: TMessage); message SCM_UPDATEUI;
    procedure MSG_UpdateUI2(var Msg: TMessage); message SCM_UPDATEUI2;
    procedure MSG_UpdateUI3(var Msg: TMessage); message SCM_UPDATEUI3;
    procedure MSG_SelectSession(var Msg: TMessage); message SCM_SELECTSESSION;

  public
    { Public declarations }
    procedure Prepare(AConnection: TFDConnection);
    property DolphinFolder: string read fDolphinMeetsFolder write fDolphinMeetsFolder;
    property FlagSelectSession: boolean read fFlagSelectSession write fFlagSelectSession;
  end;

var
  Main: TMain;
  AppUtils: TAppUtils;

implementation

{$R *.dfm}

uses UITypes, DateUtils ,dlgSessionPicker, dlgOptions, dlgTreeViewSCM,
  dlgDataDebug, dlgTreeViewData, dlgUserRaceTime, dlgPostData;

const
  MSG_CONFIRM_RECONSTRUCT =
    'This uses the data in the current session to build Time-Drops %s files.' +
    sLineBreak +
    'Files are saved to the reconstruct folder specified in preferences.' +
    sLineBreak +
    'Do you want to perform the reconstruct?';
  MSG_RECONSTRUCT_COMPLETE = 'Re-construct and export of %s files is complete.';
  CAPTION_RECONSTRUCT = '%s files ...';
  DO4_FILE_EXTENSION = 'DO4';
  DO3_FILE_EXTENSION = 'DO3';


procedure TMain.actnExportDTCSVExecute(Sender: TObject);
var
  fn: TFileName;
  i: integer;
  dt: TDatetime;
  s: string;
  fs: TFormatSettings;
begin
  FileSaveDlgMeetProgram.DefaultFolder := Settings.ProgramFolder;
  i := AppData.qrySession.FieldByName('SessionID').AsInteger;
try
  dt := AppData.qrySession.FieldByName('SessionStart').AsDateTime;
  fs := TFormatSettings.Create;
  fs.DateSeparator := '_';
  s := '-' + DatetoStr(dt, fs);
except
  on E: Exception do
    s := '';
end;
  fn := 'meet_program.json';
  FileSaveDlgMeetProgram.FileName := fn;
  if FileSaveDlgMeetProgram.Execute then
  begin
    fn := FileSaveDlgMeetProgram.FileName;
    AppData.BuildCSVEventData(fn); // Build CSV Event Data and save to file.
    MessageBox(0,
      PChar('Export of the Dolphin Timing event csv has been completed.'),
      PChar('Export Event CSV'), MB_ICONINFORMATION or MB_OK);
  end;
end;

procedure TMain.actnExportDTCSVUpdate(Sender: TObject);
begin
  if Assigned(AppData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnClearReScanMeetsExecute(Sender: TObject);
var
  s: string;
  mr: TModalResult;
begin
  s := '''
    This will clear all patches. The dolphin meets folder will be re-scanned and the DT data tables will be rebuilt.
    Any posted racetimes, made to SwimClubMeet, will remain intact. There is no undo.
    (HINT: use ''Save SCM-DT Session'' to store all work prior to calling here.)
    Do you really want to rescan?
  ''';
  mr := MessageBox(0, PChar(s), PChar('Clear and Rescan Meets Folder. '),
    MB_ICONEXCLAMATION or MB_YESNO or MB_DEFBUTTON2);
  if IsPositiveResult(mr) then
  begin
    // Test DT directory exists...
    if DirectoryExists(Settings.MeetsFolder) then
    begin
        if AppUtils.DirHasResultFiles(Settings.MeetsFolder) then
        begin
          AppUtils.PrepareTDData;
          AppUtils.PopulateTDData(Settings.MeetsFolder, pBar);
          // Update lblDTDetails.
          PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
          // Paint cell icons.
          PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);
        end;
    end;
  end;

end;

procedure TMain.actnImportAppendDOExecute(Sender: TObject);
var
  AFile: string;
begin
  if DTAppendFile.Execute() then
  begin
    // =====================================================
    // De-attach from Master-Detail. Create flat files.
    // Necessary to calculate table Primary keys.
    AppData.DisableDTMasterDetail;
    // =====================================================
    try
      for AFile in DTAppendFile.Files do
      begin
        { Calls - PrepareExtraction, ProcessEvent, ProcessHeat, ProcessEntrant }
        AppUtils.ProcessSession(AFile);
      end;
    finally
      // =====================================================
      // Re-attach Master-Detail.
      AppData.EnableDTMasterDetail;
      // =====================================================
    end;
  end;
end;

procedure TMain.actnPostExecute(Sender: TObject);
var
  dlg: TPostData;
  mr: TModalResult;
  I, idx: integer;
  ALaneNum: integer;
  s: string;
begin
  // Establish if SCM AND DT are syncronized.
  if not AppData.SyncCheck(fPrecedence) then
  begin
    s := '''
      SCM and DT are not synronized. (Based on Session ID, event and heat number.)
      However you are permitted to perform the post.
      Do you want to CONTINUE?
      ''';
    mr := MessageBox(0, PChar(s), PChar('POST ''RACE-TIMES'' WARNING'), MB_ICONEXCLAMATION or MB_YESNO or MB_DEFBUTTON2);
    if not IsPositiveResult(mr) then
    begin
      StatBar.SimpleText := 'No POST was made.';
      Timer1.Enabled := true;
      exit;
    end;
  end;

  // dialogue to pick 'selected' or 'all'.
  dlg := TPostData.Create(Self);
  mr := dlg.ShowModal;
  idx := dlg.rgrpSelection.ItemIndex;
  // release the dlg in case of 'POST' exceptions.
  dlg.free;

  if IsPositiveResult(mr) then
  begin
    // Post all race-times to SCM ...
    if idx = 0 then
    begin
      DTGrid.BeginUpdate;
      AppData.POST_All;
      DTGrid.ClearRowSelect;  // UI clean-up .
      DTGrid.EndUpdate;
    end
    // Post only racetimes from selected lanes to SCM ...
    else if idx = 1 then
    begin
      DTGrid.BeginUpdate;
      for i := 0 to DTGrid.SelectedRowCount - 1 do
      begin
        idx := DTGrid.SelectedRow[i];
        ALaneNum := StrToIntDef(DTGrid.Cells[2, idx], 0);
        AppData.POST_Lane(ALaneNum);
      end;
      DTGrid.ClearRowSelect; // UI clean-up .
      DTGrid.EndUpdate;
    end;
    StatBar.SimpleText := 'The POST race-times to SCM completed.';
    Timer1.Enabled := true;
  end
  else
  begin
    StatBar.SimpleText := 'The POST was aborted.';
    Timer1.Enabled := true;
  end;
end;

procedure TMain.actnPostUpdate(Sender: TObject);
begin
  if Assigned(AppData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnPreferencesExecute(Sender: TObject);
var
  dlg: TOptions;
  mr: TModalResult;
begin
  // open options menu
  dlg := TOptions.Create(Self);
  mr := dlg.ShowModal;
  if IsPositiveResult(mr) then
    // Update any preference changes
    LoadSettings;
  dlg.Free;
  UpdateCaption;
end;


procedure TMain.DeleteFilesWithWildcard(const APath, APattern: string);
var
  SR: TSearchRec;
  FullPath: string;
begin
  FullPath := IncludeTrailingPathDelimiter(APath) + APattern;
  if FindFirst(FullPath, faAnyFile, SR) = 0 then
  try
    repeat
      // Build the full filename
      if (SR.Attr and faDirectory) = 0 then
        DeleteFile(IncludeTrailingPathDelimiter(APath) + SR.Name);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

{
procedure TdtExec.actnReConstructDO4Execute(Sender: TObject);
var
  SessionID, currEv, currHt: integer;
  sess: string;
  mr: TModalResult;
begin
  if AppData.qrysession.Active then
  begin
    mr := MessageBox(0,
      PChar('''
      This uses the data in the current session to build Dolphin Timing DO4 files.
      Files are saved to the EventCSV folder specified in preferences.
      Do you want to perform the reconstruct?
      '''),
      PChar('Re-construct and export DO4 files...'), MB_ICONQUESTION or
        MB_YESNO);
    if isPositiveResult(mr) then
    begin
      scmGrid.BeginUpdate;
      scmGrid.DataSource.DataSet.DisableControls;
      currEv := AppData.qryEvent.FieldByName('EventID').AsInteger;
      currHt := AppData.qryHeat.FieldByName('HeatID').AsInteger;
      SessionID := AppData.qrysession.FieldByName('SessionID').AsInteger;
      // remove the current session DO4 files.
      sess := Get3Digits(SessionID);
      DeleteFilesWithWildcard(Settings.DolphinReConstructDO4, sess + '-*.DO4');
      // re-contruct the Dolphin Timing DO4 files for this session.
      ReConstructDO4(SessionID);
      AppData.LocateEvent(currEv);
      AppData.LocateHeat(currHt);
      scmGrid.DataSource.DataSet.EnableControls;
      scmGrid.EndUpdate;
      MessageBox(0,
        PChar('Re-construct and export of DO4 files is complete.'),
        PChar('DO4 files ...'), MB_ICONINFORMATION or MB_OK);
    end;
  end;
end;

procedure TdtExec.actnReConstructDO3Execute(Sender: TObject);
var
  SessionID, currEv, currHt: integer;
  sess: string;
  mr: TModalResult;
begin
  if AppData.qrysession.Active then
  begin
    mr := MessageBox(0,
      PChar('''
      This uses the data in the current session to build Dolphin Timing DO3 files.
      Files are saved to the EventCSV folder specified in preferences.
      Do you want to perform the reconstruct?
      '''),
      PChar('Re-construct and export DO3 files...'), MB_ICONQUESTION or
        MB_YESNO);
    if isPositiveResult(mr) then
    begin
      scmGrid.BeginUpdate;
      scmGrid.DataSource.DataSet.DisableControls;
      currEv := AppData.qryEvent.FieldByName('EventID').AsInteger;
      currHt := AppData.qryHeat.FieldByName('HeatID').AsInteger;
      SessionID := AppData.qrysession.FieldByName('SessionID').AsInteger;
      // remove the current session DO3 files.
      sess := Get3Digits(SessionID);
      DeleteFilesWithWildcard(Settings.DolphinReConstructDO3, sess + '-*.DO3');
      // re-contruct the Dolphin Timing DO3 files for this session.
      ReConstructDO4(SessionID);
      AppData.LocateEvent(currEv);
      AppData.LocateHeat(currHt);
      scmGrid.DataSource.DataSet.EnableControls;
      scmGrid.EndUpdate;
      MessageBox(0,
        PChar('Re-construct and export of DO3 files is complete.'),
        PChar('DO3 files ...'), MB_ICONINFORMATION or MB_OK);
    end;
  end;
end;
}

procedure TMain.actnReConstructDO4Execute(Sender: TObject);
begin
  ReconstructAndExportFiles(DO4_FILE_EXTENSION, 'DO4');
end;

procedure TMain.actnReConstructDO3Execute(Sender: TObject);
begin
  ReconstructAndExportFiles(DO3_FILE_EXTENSION, 'DO3');
end;


procedure TMain.actnReConstructDO3Update(Sender: TObject);
begin
  if Assigned(AppData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnReConstructDO4Update(Sender: TObject);
begin
  if Assigned(AppData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnRefreshExecute(Sender: TObject);
begin
  SCMGrid.BeginUpdate;
  AppData.RefreshSCM;
  SCMGrid.EndUpdate;
end;

procedure TMain.actnSelectSessionExecute(Sender: TObject);
var
  dlg: TSessionPicker;
  mr: TModalResult;
begin
  dlg := TSessionPicker.Create(Self);
  // the picker will locate to the given session id.
  dlg.rtnSessionID := AppData.qrySession.FieldByName('SessionID').AsInteger;
  mr := dlg.ShowModal;
  if IsPositiveResult(mr) and (dlg.rtnSessionID > 0) then
  begin
    AppData.MSG_Handle := 0;
    AppData.LocateSCMSessionID(dlg.rtnSessionID);
    AppData.MSG_Handle := Self.Handle;
  end;
  dlg.Free;
  UpdateCaption;
  PostMessage(Self.Handle, SCM_UPDATEUI, 0, 0);
end;

procedure TMain.actnSetDTMeetsFolderExecute(Sender: TObject);
var
  fn: TFileName;
begin
  if PickDTFolderDlg.Execute then
    fn := PickDTFolderDlg.FileName
  else
    Exit; // User cancelled.
  // Make the path persistent in JSON.
  fDolphinMeetsFolder := fn;
  // SavePreferencesToJSON.
end;

procedure TMain.actnSyncDTExecute(Sender: TObject);
var
found: boolean;
begin
  DTGrid.BeginUpdate;
  found := AppData.SyncDTtoSCM(fPrecedence); // data event - scroll.
  DTGrid.EndUpdate;
  UpdateDTDetailsLabel;
  if not found then
  begin
    StatBar.SimpleText := 'Syncronization of Dolphin Timing to SwimClubMeet failed. '
    + 'Your Dolphin Meets folder may not contain the session files required to sync.';
    timer1.enabled := true;
  end;
end;

procedure TMain.actnSyncSCMExecute(Sender: TObject);
begin
  if not AppData.SyncCheckSession(fPrecedence) then
  begin
    StatBar.SimpleText := 'The SwimClubMeet session cannot be synced to the DT data. '
    +   'Load the correct session and try again.';
    timer1.enabled := true;
    exit;
  end;

  SCMGrid.BeginUpdate;
  AppData.SyncSCMtoDT(fPrecedence);
  SCMGrid.EndUpdate;
  UpdateEventDetailsLabel;
end;

procedure TMain.btnDataDebugClick(Sender: TObject);
var
dlg: TDataDebug;
begin
  dlg := TDataDebug.Create(self);
  dlg.ShowModal;
  dlg.Free;
end;

procedure TMain.btnNextDTFileClick(Sender: TObject);
var
  lastHtID, lastEvID, IDht, IDev: integer;
  found: boolean;
begin
  DTGrid.BeginUpdate;
  // this hack find the last event ID and last heat ID in the current
  // Master-Detail linked Dolphin Timing data tables.
  IDHt := AppData.tblmHeat.fieldbyName('HeatID').AsInteger;
  AppData.tblmHeat.Last;
  lastHtID := AppData.tblmHeat.fieldbyName('HeatID').AsInteger;
  IDEv := AppData.tblmEvent.fieldbyName('EventID').AsInteger;
  AppData.tblmEvent.Last;
  lastEvID := AppData.tblmHeat.fieldbyName('EventID').AsInteger;
  found := AppData.tblmEvent.Locate('EventID', IDEv);
  if found then
    AppData.tblmHeat.Locate('HeatID', IDHt);
  DTGrid.EndUpdate;

  // CNTRL+SHIFT - quick key to move to NEXT S E S S I O N .
  if (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_SHIFT) < 0) then
  begin
    AppData.dsmSession.DataSet.next;
    AppData.dsmEvent.DataSet.first;
    AppData.dsmHeat.DataSet.first;
  end
    // CNTRL- quick key to move to NEXT E V E N T .
  else if (GetKeyState(VK_CONTROL) < 0) then
  begin
    { After reaching the last event for the current session ...
      a second click of btnNextDTFileClick is needed to recieve a Eof.
      Checking for max eventID removes this UI nonscence.}
    if ((AppData.dsmEvent.DataSet.Eof) or
      (AppData.tblmEvent.fieldbyName('EventID').AsInteger = lastEvID)) then
    begin
      AppData.dsmSession.DataSet.next;
      AppData.dsmHeat.DataSet.First;
      AppData.dsmHeat.DataSet.first;
    end
    else
    begin
      AppData.dsmEvent.DataSet.next;
      AppData.dsmHeat.DataSet.First;
    end;
  end
    // move to N E X T   H E A T .
  else
  begin
    { After reaching the last record a second click of btnNextDTFileClick is needed to
      recieve a Eof. Checking for max heatID removes this UI nonscence.}
    if AppData.dsmHeat.DataSet.Eof or
      (AppData.tblmHeat.fieldbyName('HeatID').AsInteger = lastHtID) then
    begin
      AppData.dsmEvent.DataSet.next;
      AppData.dsmHeat.DataSet.First;
    end
    else
    begin
      AppData.dsmHeat.DataSet.next;
    end;
  end;
  // Update lblDTDetails.
  PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
  // paint cell icons into grid
  PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);
end;

procedure TMain.btnNextEventClick(Sender: TObject);
var
  v: variant;
  sql: string;
  id: integer;
begin
  if (GetKeyState(VK_CONTROL) < 0) then
  begin
      AppData.dsEvent.DataSet.next;
      AppData.dsHeat.DataSet.First;
  end
  else
  begin
    // Get the MAX HeatNum...
    sql := 'SELECT MAX(HeatNum) FROM [SwimClubMeet].[dbo].[HeatIndividual] WHERE [EventID] = :ID';
    id := AppData.dsEvent.DataSet.FieldByName('EventID').AsInteger;
    v := SCM.scmConnection.ExecSQLScalar(sql,[id]);
    if VarIsNull(v) then v := 0;
    { After reaching the last record a second click of btnNextEvent is needed to
      recieve a Eof. Checking for max heatnum removes this UI nonsence.}
    if AppData.dsHeat.DataSet.Eof or (AppData.dsHeat.DataSet.FieldByName('HeatNum').AsInteger = v)  then
    begin
      AppData.dsEvent.DataSet.next;
      AppData.dsHeat.DataSet.First;
    end
    else
    begin
      AppData.dsHeat.DataSet.next;
    end;
  end;
  PostMessage(Self.Handle, SCM_UPDATEUI, 0, 0);
end;

procedure TMain.btnPickDTTreeViewClick(Sender: TObject);
var
dlg: TTreeViewData;
sessID, evID, htID: integer;
mr: TModalResult;
found: boolean;
SearchOptions: TLocateOptions;
begin
  {
  MANATORY HERE - ELSE IT DOESN'T WORK!
  Use the ApplyMaster method to synchronize this detail dataset with the
  current master record.  This method is useful, when DisableControls was
  called for the master dataset or when scrolling is disabled by
  MasterLink.DisableScroll.
  }
  dtGrid.BeginUpdate;

  // Open the SCM TreeView.
  dlg := TTreeViewData.Create(Self);
  SearchOptions := [];
  // Params to cue-to-record in DT TreeView.
    sessID := AppData.dsmSession.DataSet.FieldByName('SessionID').AsInteger;
    evID := AppData.dsmEvent.DataSet.FieldByName('EventID').AsInteger;
    htID := AppData.dsmHeat.DataSet.FieldByName('HeatID').AsInteger;

  // DT TreeView will attemp to cue-to-node based on params.

  dlg.Prepare(sessID, evID, htID);
  mr := dlg.ShowModal;
  // A TreeView node was selected.
  if IsPositiveResult(mr) then
  begin
    { NOTE: DT session pick by the user may differ from the current
      SCM session being operated on. }

    AppData.dsmLane.DataSet.DisableControls;
    AppData.dsmHeat.DataSet.DisableControls;
    AppData.dsmEvent.DataSet.DisableControls;
    AppData.dsmSession.DataSet.DisableControls;
    // Attempt to cue-to-data in Dolphin Timing tables.
    if (dlg.SelectedSessionID > 0) then
    begin
      found := AppData.LocateDTSessionID(dlg.SelectedSessionID);
      if not found then
        AppData.tblmSession.First;
      AppData.tblmEvent.ApplyMaster;
      AppData.tblmEvent.First;
      AppData.tblmHeat.ApplyMaster;
      AppData.tblmHeat.First;
    end;
    if (dlg.SelectedEventID > 0) then
    begin
      found := AppData.LocateDTEventID(dlg.SelectedEventID);
      if not found then
        AppData.tblmEvent.First;
      AppData.tblmHeat.ApplyMaster;
      AppData.tblmHeat.First;
      AppData.tblmLane.ApplyMaster;
      AppData.tblmLane.First;

    end;
    if (dlg.SelectedHeatID > 0) then
    begin
      found := AppData.LocateDTHeatID(dlg.SelectedHeatID);
      if not found then
        AppData.tblmHeat.First;
    end;

    // Update the Dolphin Timing TDBAdvGrid.
    AppData.dsmSession.DataSet.EnableControls;
    AppData.dsmEvent.DataSet.EnableControls;
    AppData.dsmHeat.DataSet.EnableControls;
    AppData.dsmLane.DataSet.EnableControls;

//    dtGrid.update

    // Update UI controls ...
    PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
    // paint cell icons
    PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);

    end;
  dlg.Free;
  dtGrid.EndUpdate;

end;

procedure TMain.btnPickSCMTreeViewClick(Sender: TObject);
var
dlg: TTreeViewSCM;
sess, ev, ht: integer;
mr: TModalResult;
found: boolean;
begin
  // Open the SCM TreeView.
  dlg := TTreeViewSCM.Create(Self);

  sess := AppData.dsSession.DataSet.FieldByName('SessionID').AsInteger;
  ev := AppData.dsEvent.DataSet.FieldByName('EventID').AsInteger;
  ht := AppData.dsHeat.DataSet.FieldByName('HeatID').AsInteger;
  dlg.Prepare(SCM.scmConnection, sess, ev, ht);
  mr := dlg.ShowModal;

    // CUE-TO selected TreeView item ...
  if IsPositiveResult(mr) then
  begin
    AppData.dsEvent.DataSet.DisableControls;
    AppData.dsHeat.DataSet.DisableControls;
    if (dlg.SelectedEventID <> 0) then
    begin
      found := AppData.LocateSCMEventID(dlg.SelectedEventID);
      if found then
      begin
        AppData.dsHeat.DataSet.Close;
        AppData.dsHeat.DataSet.Open;
        if (dlg.SelectedHeatID <> 0) then
          AppData.LocateSCMHeatID(dlg.SelectedHeatID);
      end;
    end;
    AppData.dsEvent.DataSet.EnableControls;
    AppData.dsHeat.DataSet.EnableControls;
    // Update UI controls ...
    PostMessage(Self.Handle, SCM_UPDATEUI, 0, 0);
  end;
  dlg.Free;

end;

procedure TMain.btnPrevDTFileClick(Sender: TObject);
var
  evNum, htNum: integer;
begin

  if fPrecedence = dtPrecFileName then
  begin
    evNum := AppData.dsmEvent.DataSet.FieldByName('fnEventNum').AsInteger;
    htNum := AppData.dsmHeat.DataSet.FieldByName('fnHeatNum').AsInteger;
  end
  else
  begin
    evNum := AppData.dsmEvent.DataSet.FieldByName('EventNum').AsInteger;
    htNum := AppData.dsmHeat.DataSet.FieldByName('HeatNum').AsInteger;
  end;

  // CNTRL+SHIFT - quick key to move to previous session.
  if (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_SHIFT) < 0) then
  begin
    // reached bottom of table ...
    if AppData.dsmSession.DataSet.BOF then exit;
    AppData.dsmSession.DataSet.prior;
    AppData.dsmEvent.DataSet.first;
    AppData.dsmHeat.DataSet.first;
  end
  // CNTRL move to previous event ...
  else if (GetKeyState(VK_CONTROL) < 0) then
  begin
    if AppData.dsmEvent.DataSet.BOF or (evNum = 1) then
    begin
      AppData.dsmSession.DataSet.prior;
      AppData.dsmEvent.DataSet.first;
    end
    else
      AppData.dsmEvent.DataSet.prior;
  end
  else
  begin
    { After reaching the first record a second click of btnPrevDTFileClick is needed to
      recieve a Bof. Checking for heatnum = 1 removes this UI nonsence.}
    if AppData.dsmHeat.DataSet.BOF or (htNum = 1) then
    begin
      AppData.dsmEvent.DataSet.prior;
      AppData.dsmHeat.DataSet.Last;
    end
    else
      AppData.dsmHeat.DataSet.prior;
  end;
  // Update UI controls ...
  PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
  // paint cell icons into grid.
  PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);
end;

procedure TMain.btnPrevEventClick(Sender: TObject);
begin
  if (GetKeyState(VK_CONTROL) < 0) then
  begin
      AppData.dsEvent.DataSet.prior;
      AppData.dsHeat.DataSet.first;
  end
  else
  begin
    if (AppData.dsEvent.DataSet.FieldByName('EventNum').AsInteger = 1) and
      (AppData.dsHeat.DataSet.FieldByName('HeatNum').AsInteger = 1) then
    exit;

    { After reaching the first record a second click of btnPrevEvent is needed to
      recieve a Bof. Checking for heatnum = 1 removes this UI nonsence.}
    if AppData.dsHeat.DataSet.BOF or
      (AppData.dsHeat.DataSet.FieldByName('HeatNum').AsInteger = 1) then
    begin
        AppData.dsEvent.DataSet.prior;
        AppData.dsHeat.DataSet.Last;
      end
      else
      begin
        AppData.dsHeat.DataSet.prior;
      end;
    end;
    PostMessage(Self.Handle, SCM_UPDATEUI, 0, 0);
end;

procedure TMain.dtGridClickCell(Sender: TObject; ARow, ACol: Integer);
var
  Grid: TDBAdvGrid;
  ADataSet: TDataSet;
  s: string;
  ActiveRT: dtActiveRT;
  t: TTime;
  dlg: TUserRaceTime;
  mr: TModalResult;
begin
  Grid := Sender as TDBAdvGrid;
  ADataSet := Grid.DataSource.DataSet;


  if (ARow >= DTgrid.FixedRows) then
  begin
    case ACol of
      7: // C O L U M N   E N T E R   U S E R   R A C E T I M E  .
        begin
          if (GetKeyState(VK_MENU) < 0) then
          begin
            ActiveRT := dtActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
            if (ActiveRT = artUser) then // Enter a user race-time.
            begin
              grid.BeginUpdate;
              // create the 'Enter Race-Time' dialogue.
              dlg := TUserRaceTime.Create(Self);
              // Assign : Current displayed racetime.
              dlg.RaceTime := ADataSet.FieldByName('RaceTime').AsDateTime;
              // Assign : Store user racetime.
              dlg.RaceTimeUser := ADataSet.FieldByName('RaceTimeUser').AsDateTime;
              mr := dlg.ShowModal;
              if IsPositiveResult(mr) then
              begin
                t := dlg.RaceTimeUser;
                ADataSet.Edit;
                if (t = 0) then
                  ADataSet.FieldByName('RaceTime').Clear
                else
                  ADataSet.FieldByName('RaceTime').AsDateTime := t;
                ADataSet.FieldByName('RaceTimeUser').AsDateTime := t;
                ADataSet.Post;
              end;
              dlg.Free;
              grid.EndUpdate;
            end;
          end;
        end;
      6: // C O L U M N   T O G G L E   A C T I V E - R T .
        begin
          grid.BeginUpdate;
          { Toggle tblEntrant.ActiveRT}
          if (GetKeyState(VK_MENU) < 0) then
            // toggle backwards
            ActiveRT := AppData.ToggleActiveRT(ADataSet, 1)
          else
            // toggle forward (default)
            ActiveRT := AppData.ToggleActiveRT(ADataSet);
          { Modifies tblEntrant: ActiveRT, RaceTime, imgActiveRT }
          AppData.SetActiveRT(ADataSet, ActiveRT);
          case ActiveRT of
            artAutomatic:
            begin
              UpdateCellIcons(ADataSet, ARow, ActiveRT);
            end;
            artManual:
            begin
              // The RaceTime needs to be recalculated...
              AppData.CalcRaceTimeM(ADataSet);
              UpdateCellIcons(ADataSet, ARow, ActiveRT);
            end;
            artUser:
            begin
              UpdateCellIcons(ADataSet, ARow, ActiveRT);
            end;
            artSplit:
               UpdateCellIcons(ADataSet, ARow, ActiveRT);
            artNone:
               UpdateCellIcons(ADataSet, ARow, ActiveRT);
          end;
          grid.EndUpdate;
        end;
      3, 4, 5:
        begin

          if ADataSet.FieldByName('LaneIsEmpty').AsBoolean then exit;

          ActiveRT := dtActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
          // Must be artmanual for the user to toggle watch-time state.
          if ActiveRT <> artManual then exit;

          // the ALT key is required to perform toggle.
          if (GetKeyState(VK_MENU) < 0) then
          begin
            s := 'Time' + IntToStr(ACol - 2);
            // Can toggle an empty TimeKeeper's stopwatch time...
            if (ADataSet.FieldByName(s).IsNull) then exit;
            grid.BeginUpdate;
            // modify TimeKeeper's stopwatch state.
            // idx in [1..3]. Asserts : dtTimeKeeperMode = dtManual.
            AppData.ToggleWatchTime(ADataSet, (Acol - 2), ActiveRT);
            UpdateCellIcons(ADataSet, ARow, ActiveRT);
            // The RaceTime needs to be recalculated...
            AppData.CalcRaceTimeM(ADataset);
            grid.EndUpdate;
          end;
        end;
    end;
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
begin

  // A Class that uses JSON to read and write application configuration .
  // Created on bootup by dtfrmBoot.
  LoadSettings;
  {
    Sort out the menubar font height - so tiny!

    The font of the MenuItemTextNormal element (or any other) in the style
    designer has no effect, this is because the Vcl Style Engine simply
    ignores the font-size and font-name, and just uses the font color defined in
    the vcl style file.

    S O L U T I O N :

    Define and register a new TActionBarStyleEx descendent and override
    the DrawText methods of the TCustomMenuItem and TCustomMenuButton
    classes, using the values of the Screen.MenuFont to draw the menu
  }
  Screen.MenuFont.Name := 'Segoe UI Semibold';
  Screen.MenuFont.Size := 12;
  actnManager.Style := PlatformVclStylesStyle;
  // local fields init.
  fFlagSelectSession := false;
  // UI initialization.
  lblSessionStart.Caption := '';
  lblEventDetails.Caption := '';
  lblMetersRelay.Caption := '';
  lblHeatNum.Caption := '';
  lblMeters.Caption := '';
  vimgHeatNum.ImageIndex := -1;
  vimgHeatStatus.ImageIndex := -1;
  vimgRelayBug.ImageIndex := -1;
  vimgStrokeBug.ImageIndex := -1;

  AppUtils.AcceptedDeviation := Settings.AcceptedDeviation;

  FDirectoryWatcher := nil;
  // Test DT directory exists...
  if DirectoryExists(Settings.MeetsFolder) then
  begin
      if AppUtils.DirHasResultFiles(Settings.MeetsFolder) then
      begin
        AppUtils.PrepareTDData;
        AppUtils.PopulateTDData(Settings.MeetsFolder, pBar);
        // Update UI controls ...
        PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
        // Paint cell icons.
        PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);
      end;
    // Set up the file system watcher
    FDirectoryWatcher := TDirectoryWatcher.Create(Settings.MeetsFolder);
    FDirectoryWatcher.OnFileChanged := OnFileChanged;
    FDirectoryWatcher.Start;
  end;


{$IFNDEF DEBUG}
  btnDataDebug.Visible := false;
{$ENDIF}

  // Assert StatusBar params
  // Ensure that the StyleElements property does not include seFont
  //  StatBar.StyleElements := StatBar.StyleElements - [seFont];
  //  StatBar.ParentFont := False;
  StatBar.Font.Size := 12;
  StatBar.Font.Color := clWebAntiqueWhite;

  // Enable hint information
  Application.ShowHint := true;

end;

procedure TMain.FormDestroy(Sender: TObject);
begin
{
Summary:
SignalTerminate Method: This public method in TDirectoryWatcher signals the
termination event, allowing the Execute method to exit cleanly.

Calling SignalTerminate: In FormDestroy, SignalTerminate is called after
calling Terminate to ensure the thread exits properly.

This approach ensures that the TDirectoryWatcher thread can be terminated
gracefully without causing the application to hang.
}
  if Assigned(FDirectoryWatcher) then
  begin
    try
      FDirectoryWatcher.Terminate;
      {  Problems terminating ... }
      // Signal the termination event...
      FDirectoryWatcher.SignalTerminate;
      FDirectoryWatcher.WaitFor;
    finally
      FDirectoryWatcher.Free;
    end;
  end;

  SaveToSettings;
  if Assigned(AppData) then AppData.MSG_Handle := 0;
end;

procedure TMain.FormHide(Sender: TObject);
begin
  if Assigned(AppData) then AppData.MSG_Handle := 0;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  if AppData.qrySession.IsEmpty then
  begin
    pnlSCM.Visible := false;
    pnlDT.Visible := false;
    actnSelectSession.Execute;
  end
  else
  begin
    pnlSCM.Visible := true;
    pnlDT.Visible := true;
  end;
  // Windows handle to message after after data scroll...
  if Assigned(AppData) then
  begin
    AppData.MSG_Handle := Self.Handle;
    // Assert Master - Detail ...
    AppData.ActivateDataDT;
  end;
  if fFlagSelectSession then
    // Prompt user to select session. (... and update UI.)
    PostMessage(Self.Handle, SCM_SELECTSESSION, 0 , 0 )
  else
    // Assert UI display is up-to-date.
    PostMessage(Self.Handle, SCM_UPDATEUI, 0 , 0 );

  // Update lblDTDetails.
  PostMessage(Self.Handle, SCM_UPDATEUI2, 0 , 0 );
  // paint cell icons into grid.
  PostMessage(Self.Handle, SCM_UPDATEUI3, 0 , 0 );
end;

procedure TMain.LoadFromSettings;
begin
  fDolphinMeetsFolder := Settings.MeetsFolder;
  fPrecedence := Settings.Precedence;
end;

procedure TMain.LoadSettings;
begin
  if not FileExists(Settings.GetDefaultSettingsFilename()) then
  begin
    ForceDirectories(Settings.GetSettingsFolder());
    Settings.SaveToFile();
  end;
  Settings.LoadFromFile();
  LoadFromSettings();
end;

procedure TMain.MSG_SelectSession(var Msg: TMessage);
begin
  actnSelectSessionExecute(Self);
end;

procedure TMain.MSG_UpdateUI(var Msg: TMessage);
var
i: integer;
begin
  // update HEATUI elements.
  if Assigned(AppData) AND AppData.SCMDataIsActive then
  begin
    UpdateEventDetailsLabel; // append heat number to label
    UpdateSessionStartLabel; //

    i := AppData.qryEvent.FieldByName('StrokeID').AsInteger;
    case i of
      1:
        vimgStrokeBug.ImageName := 'StrokeFS';
      2:
        vimgStrokeBug.ImageName := 'StrokeBS';
      3:
        vimgStrokeBug.ImageName := 'StrokeBK';
      4:
        vimgStrokeBug.ImageName := 'StrokeBF';
      5:
        vimgStrokeBug.ImageName := 'StrokeIM';
    else
      vimgStrokeBug.ImageIndex := -1;
    end;

    i := AppData.qryDistance.FieldByName('EventTypeID').AsInteger;
    case i of
      2:
      begin
        vimgRelayBug.ImageName := 'RELAY_DOT'; // RELAY.
        lblMetersRelay.Caption := UpperCase(AppData.qryDistance.FieldByName('Caption').AsString);
        lblMetersRelay.Visible := true;
        lblMeters.Caption := '';
      end;
    else
      begin
        vimgRelayBug.ImageIndex := -1; // INDV or Swim-O-Thon.
        lblMeters.Caption := UpperCase(AppData.qryDistance.FieldByName('Caption').AsString);
        lblMetersRelay.Visible := false;
      end;
    end;

    i := AppData.qryHeat.FieldByName('HeatNum').AsInteger;
    if i = 0 then
    begin
      lblHeatNum.Caption := '';
      vimgHeatNum.ImageIndex := -1;
      vimgHeatStatus.ImageIndex := -1;
    end
    else
    begin
      lblHeatNum.Caption := IntToStr(i);
      vimgHeatNum.ImageIndex := 14;
      i := AppData.qryHeat.FieldByName('HeatStatusID').AsInteger;
      case i of
      1:
        vimgHeatStatus.ImageName := 'HeatOpen';
      2:
        vimgHeatStatus.ImageName := 'HeatRaced';
      3:
        vimgHeatStatus.ImageName := 'HeatClosed';
      else
        vimgHeatStatus.ImageIndex := -1;
      end;
    end;

  end;

end;

procedure TMain.MSG_UpdateUI2(var Msg: TMessage);
begin
    UpdateDTDetailsLabel;
end;

procedure TMain.MSG_UpdateUI3(var Msg: TMessage);
var
  J: integer;
  ActiveRT: dtActiveRT;
  ADataSet: TDataSet;
begin
  // AppData.dsmHeat - AfterScroll event.
  // UI images in grid cells need to be re-assigned.
  DTGrid.BeginUpdate;
  // improve code readability ...
  ADataSet := DTGrid.DataSource.DataSet;

  { Typically this routine is call when
    a AppData.OnAfterScroll occurs..
    A DTGrid.Reload isn't required at this execution point. }

  // clear out all images in TimeKeepers columns [3..5]
  // --------------------------------------------------
  {
  for j := DTgrid.FixedRows to DTGrid.RowCount do
  begin
    for I := 3 to 5 do
    begin
      DTGrid.RemoveImageIdx(I, j); // Remove icon.
    end;
    // Remove UseUserRaceTime icon.
    DTGrid.RemoveImageIdx(7, j);
  end;
  }

  // iterate AppData and assign a cell images if needed.
  // --------------------------------------------------
  for j := DTgrid.FixedRows to (DTGrid.RowCount-DTgrid.FixedRows) do
  begin
    // SYNC AppData record to DTGrid row.
    ADataSet.RecNo := j;

    // A C T I V E R T .
    ActiveRT := dtActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
    case ActiveRT of
      // A U T O M A T I C .
      artAutomatic:
      begin
        // Switch to the Auto-Calculated RaceTime.
        // RacetimeA was calculated when the DT file was first imported.
        AppData.SetActiveRT(ADataSet, artAutomatic);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

      // M A N U A L .
      artManual:
      begin
        AppData.SetActiveRT(ADataSet, artManual);
        AppData.CalcRaceTimeM(ADataSet);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

      artUser:
      begin
        AppData.SetActiveRT(ADataSet, artUser);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

      artSplit:
      begin
        AppData.SetActiveRT(ADataSet, artSplit);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

      artNone:
      begin
        AppData.SetActiveRT(ADataSet, artNone);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

    end;

  end;
  ADataSet.First;
  DTGrid.EndUpdate;
  DTGrid.ClearRowSelect;

end;

procedure TMain.OnFileChanged(Sender: TObject; const FileName: string);
var
s: string;
begin
  // Handle the new file
  s := UpperCase(ExtractFileExt(FileName));

  if (s = '.JSON') then
  begin
    s := UpperCase(FileName);
    if s.Contains('SESSION') then
    begin
      ShowMessage('A new results file was added to the directory: ' + FileName);
      AppUtils.ProcessFile(FileName, PBar);
    end;
  end;
end;

procedure TMain.Prepare(AConnection: TFDConnection);
begin
  FConnection := AConnection;
  Caption := 'SwimClubMeet - Dolphin Timing. ';
end;

procedure TMain.ReconstructAndExportFiles(fileExtension: string; messageText:
  string);
var
  SessionID, currEv, currHt: integer;
  sessionPrefix: string;
  mr: TModalResult;
begin
  if AppData.qrysession.Active then
  begin
    mr := MessageBox(0,
      PChar(Format(MSG_CONFIRM_RECONSTRUCT, [fileExtension])),
      PChar(Format(CAPTION_RECONSTRUCT, [fileExtension])), MB_ICONQUESTION or
      MB_YESNO);
    if isPositiveResult(mr) then
    begin
      scmGrid.BeginUpdate;
      scmGrid.DataSource.DataSet.DisableControls;
      currEv := AppData.qryEvent.FieldByName('EventID').AsInteger;
      currHt := AppData.qryHeat.FieldByName('HeatID').AsInteger;
      SessionID := AppData.qrysession.FieldByName('SessionID').AsInteger;
      sessionPrefix := Get3Digits(SessionID);
      DeleteFilesWithWildcard(Settings.ReConstruct + fileExtension,
        sessionPrefix + '-*.%' + fileExtension);
      if messageText = 'DO3' then
        ReConstructDO3(SessionID)
      else
        ReConstructDO4(SessionID);
      AppData.LocateSCMEventID(currEv);
      AppData.LocateSCMHeatID(currHt);
      scmGrid.DataSource.DataSet.EnableControls;
      scmGrid.EndUpdate;
      MessageBox(0,
        PChar(Format(MSG_RECONSTRUCT_COMPLETE, [fileExtension])),
        PChar(Format(CAPTION_RECONSTRUCT, [fileExtension])), MB_ICONINFORMATION
          or MB_OK);
    end;
  end;
end;


procedure TMain.SaveToSettings;
begin
  Settings.MeetsFolder := fDolphinMeetsFolder;
  Settings.SaveToFile();
end;

procedure TMain.scmGridGetDisplText(Sender: TObject; ACol, ARow: Integer; var
  Value: string);
begin
  { Quick 'hack' to clear the HTML text in the Entrant cells for lanes that
    don't have a swimmer assigned.}
  // Must be entrant column. Ignore header row.
  if (ACol = 4) and (ARow > 0) then
  begin
    { The hack works like this...
    A lane with no entrant will have a empty member's name surrounded by
    the HTML bold tag.
    NOTE: the 'empty' <#FName> results in a single space being
      inserted between the 'tag'
    }
    if Value.Contains('<B> </B>') then // The 'hack'.
      Value := ' ';
    { The event doesn't have any heats...
      ...but it will have a single empty row 1.
    }
    if scmGrid.DataSource.DataSet.IsEmpty then Value := ' ';
  end;
end;

procedure TMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False; // Stop the timer
  StatBar.SimpleText := ''; // Clear the message
end;


procedure TMain.UpdateCaption;
var
s, s2: string;
v: variant;
dt: TDateTime;
begin
  if not AppData.qrysession.Active then
    Caption := 'SwimClubMeet - Dolphin Timing. ' // error ...
  else
  begin
    s2 := 'SwimClubMeet';
    v := AppData.qrysession.FieldByName('SessionStart').AsVariant;
    if not VarIsNull(v) then
    begin
      dt := TDateTime(v);
      s2 := s2 + ' - Session: ' + DateToStr(dt);
    end;
    s := AppData.qrysession.FieldByName('Caption').AsString;
    if Length(s) > 0 then s2 := s2 + ' ' + s;
    Caption := s2;
  end;
end;

procedure TMain.UpdateCellIcons(ADataset: TDataSet; ARow: Integer; AActiveRT:
    dtActiveRT);
var
I: integer;
s: string;
b, b2: boolean;
begin

  // SOURCE FOR GRID CELL IMAGES : AppData.vimglistDTCell.

  DTGrid.BeginUpdate;
  // Clear out - point to cell icon
  DTGrid.RemoveImageIdx(7, ARow);

  case AActiveRT of
    artAutomatic:
    begin
      // Update watch time : cell's icon.
      for I := 3 to 5 do
      begin
        DTGrid.RemoveImageIdx(I, ARow);
        s := 'Time' + IntToStr(I - 2);
        if ADataSet.FieldByName(s).IsNull then
          continue
        else
        begin
          s := 'T' + IntToStr(I - 2) + 'A';
          b := ADataSet.FieldByName(s).AsBoolean;
          // Empty, zero or bad race-time - display CROSS in BOX.
          if (b = false) then
          begin
              DTGrid.AddImageIdx(I, ARow, 5, TCellHAlign.haFull,
                TCellVAlign.vaFull);
          end;
          { watch-time 1 :
              If the time is valid but the deviation between min and mid_
              is not acceptable then ...
          }
          if (I = 3)  then
          begin
            s := 'TDev1';
            b2 := ADataSet.FieldByName(s).AsBoolean;
            // Unacceptable deviation - display DEV,CROSS in BOX.
            if b and b2 then
            begin
                DTGrid.AddImageIdx(I, ARow, 10, TCellHAlign.haFull,
                  TCellVAlign.vaFull);
            end;
          end;
          { watch-time 3 :
              If the time is valid but the deviation between mid and max
              is not acceptable then ...
          }
          if (I = 5)  then
          begin
            s := 'TDev2';
            b2 := ADataSet.FieldByName(s).AsBoolean;
            // Unacceptable deviation - display DEV,CROSS in BOX.
            if b and b2 then
            begin
                DTGrid.AddImageIdx(I, ARow, 10, TCellHAlign.haFull,
                  TCellVAlign.vaFull);
            end;
          end;
        end;
      end;
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'AUTO';
    end;
    artManual:
    begin
      for I := 3 to 5 do
      begin
        DTGrid.RemoveImageIdx(I, ARow);
        s := 'Time' + IntToStr(I - 2);
        if ADataSet.FieldByName(s).IsNull then
          continue
        else
          begin
            s := 'T' + IntToStr(I - 2) + 'M';
            b := ADataSet.FieldByName(s).AsBoolean;
            // Empty, zero or illegal watch time - display CROSS in BOX.
            if (not b) then
            begin
                DTGrid.AddImageIdx(I, ARow, 6, TCellHAlign.haFull,
                  TCellVAlign.vaFull);
            end;
          end;
      end;
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'MANUAL';
    end;
    artUser:
    begin
      for I := 3 to 5 do
      begin
        dtGrid.RemoveImageIdx(i, ARow);
      { s := 'Time' + IntToStr(I - 2);
        if ADataSet.FieldByName(s).IsNull then
        continue;
        DTGrid.AddImageIdx(I, ARow, 7, TCellHAlign.haFull,
        TCellVAlign.vaFull); }
      end;
        // USER MODE : display - cell pointer
      DTGrid.AddImageIdx(7, ARow, 9, TCellHAlign.haAfterText, TCellVAlign.vaTop);
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'USER RT';
    end;
    artSplit:
    begin
      for I := 3 to 5 do
      begin
        DTGrid.RemoveImageIdx(I, ARow);
        // display small blue bug.
        DTGrid.AddImageIdx(I, ARow, 11, TCellHAlign.haFull,
            TCellVAlign.vaFull);
      end;
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'SPLIT';
    end;
    artNone:
    begin
      for I := 3 to 5 do
      begin
        DTGrid.RemoveImageIdx(I, ARow);
        // display red cross.
        DTGrid.AddImageIdx(I, ARow, 8, TCellHAlign.haFull,
            TCellVAlign.vaFull);
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'NONE';
      end;
    end;
  end;

  DTGrid.EndUpdate;

end;

procedure TMain.UpdateDTDetailsLabel;
var
i: integer;
s: string;
begin
  lblDTDetails.caption := '';

  if AppData.tblmSession.IsEmpty then exit;
  s := 'Session : ';
  if fPrecedence = dtPrecFileName then
    i := AppData.tblmSession.FieldByName('fnSessionNum').AsInteger
  else
    i := AppData.tblmSession.FieldByName('SessionNum').AsInteger;
  s := s + IntToStr(i);

  if AppData.tblmEvent.IsEmpty then
  begin
    lblDTDetails.caption := s;
    exit;
  end;
  s := s + '  Event : ';
  if fPrecedence = dtPrecFileName then
    i := AppData.tblmEvent.FieldByName('fnEventNum').AsInteger
  else
    i := AppData.tblmEvent.FieldByName('EventNum').AsInteger;
  s := s + IntToStr(i);

  if AppData.tblmHeat.IsEmpty then
  begin
    lblDTDetails.caption := s;
    exit;
  end;
  s := s + ' - Heat : ';
  if fPrecedence = dtPrecFileName then
    i := AppData.tblmHeat.FieldByName('fnHeatNum').AsInteger
  else
    i := AppData.tblmHeat.FieldByName('HeatNum').AsInteger;
  s := s + IntToStr(i);
  lblDTDetails.caption := s;

end;

procedure TMain.UpdateEventDetailsLabel;
var
i, ASessionID: integer;
s, s2: string;
begin
  lblEventDetails.Caption := '';
  if AppData.qryEvent.IsEmpty then exit;

  i := AppData.qryEvent.FieldByName('EventNum').AsInteger;
  if (i = 0) then exit;

  ASessionID := AppData.qryEvent.FieldByName('SessionID').AsInteger;
  s := IntToStr(ASessionID);

  s := s + ' : Event ' + IntToStr(i) + ' : ';
  // build the event detail string...  Distance Stroke (OPT: Caption)
  s := s + AppData.qryDistance.FieldByName('Caption').AsString;
  s := s + ' ' + AppData.qryStroke.FieldByName('Caption').AsString;
  // heat number...
  i:=AppData.qryHeat.FieldByName('HeatNum').AsInteger;
  if (i > 0) then
    s := s + ' - Heat : ' + IntToStr(i);
  // event description - entered in core app's grid extension mode.
  s2 := AppData.qryEvent.FieldByName('Caption').AsString;
  if (length(s2) > 0) then
  begin
    if (length(s2) > 128) then
      s2 := s2.Substring(0, 124) + '...';
    s := s + sLineBreak +  s2;
  end;
  // assignment
  if Length(s) > 0 then
  begin
    lblEventDetails.Caption := s;
  end;
end;

procedure TMain.UpdateSessionStartLabel;
var
  s: string;
  v: variant;
  dt: TDateTime;
begin
  if not AppData.qrysession.Active then
  begin
    lblSessionStart.Caption := ''; // error ...
    exit;
  end;
  if AppData.qrySession.IsEmpty or
  (AppData.qrySession.FieldByName('SessionID').AsInteger = 0) then
    lblSessionStart.Caption := ''
  else
  begin
    s := 'Session: ' + IntToStr(AppData.qrysession.FieldByName('SessionID').AsInteger)
      + sLineBreak;
    v := AppData.qrysession.FieldByName('SessionStart').AsVariant;
    if not VarIsNull(v) then
    begin
      dt := TDateTime(v);
      s := s + DateToStr(dt);
    end;
    lblSessionStart.Caption := s;
  end;
end;

end.
