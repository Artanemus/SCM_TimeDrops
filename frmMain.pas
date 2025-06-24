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
  Vcl.ImageCollection, Vcl.Menus, tdSetting, FireDAC.Comp.Client,
  Data.DB, Vcl.Grids, Vcl.DBGrids, SCMDefines, System.StrUtils, AdvUtil, AdvObj,
  BaseGrid, AdvGrid, DBAdvGrid, System.Actions, Vcl.ActnList, Vcl.ToolWin,
  Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ExtDlgs, FireDAC.Stan.Param, Vcl.ComCtrls, Vcl.DBCtrls, tdReConstruct,
  Vcl.PlatformVclStylesActnCtrls, Vcl.WinXPanels, Vcl.WinXCtrls,
  System.Types, System.IOUtils, System.Math, DirectoryWatcher,
  tdReConstructDlg, dmIMG, uNoodleFrame,
	System.Generics.Collections, System.Generics.Defaults;
//	System.Diagnostics, System.IO;


type
  TMain = class(TForm)
    actnBuildTDTables: TAction;
    actnAbout: TAction;
    actnClearAndScan: TAction;
    actnClearGrid: TAction;
    actnConnectToSCM: TAction;
    actnExportMeetProgram: TAction;
    actnLoadSession: TAction;
    actnManager: TActionManager;
    actnMenuBar: TActionMainMenuBar;
    actnPost: TAction;
    actnPreferences: TAction;
    actnPushResults: TAction;
    actnReConstructTDResultFiles: TAction;
    actnRefresh: TAction;
    actnReportTD: TAction;
    actnRestartDirectoryWatcher: TAction;
    actnRptSCMEventBasic: TAction;
    actnRptSCMEventDetailed: TAction;
    actnSaveSession: TAction;
    actnScanMeetsFolder: TAction;
    actnSCMSession: TAction;
    actnSelectSwimClub: TAction;
    actnSyncSCM: TAction;
    actnSyncTD: TAction;
    actnTDTableViewer: TAction;
    actnFireDACExplorer: TAction;
    btnNextDTFile: TButton;
    btnNextEvent: TButton;
    btnPickDTTreeView: TButton;
    btnPickSCMTreeView: TButton;
    btnPrevDTFile: TButton;
    btnPrevEvent: TButton;
    dbtxtDTFileName: TDBText;
    FileOpenDlg: TFileOpenDialog;
    FileSaveDlg: TFileSaveDialog;
    lblEventDetails: TLabel;
    lblEventDetailsTD: TLabel;
    lblHeatNum: TLabel;
    lblKeyBoardInfo: TLabel;
    lblMeters: TLabel;
    lblMetersRelay: TLabel;
    lblSessionStart: TLabel;
    lblSwimClubName: TLabel;
    lbl_scmGridOverlay: TLabel;
    lbl_tdsGridOverlay: TLabel;
    pnlNoodle: TPanel;
    pnlTool1: TPanel;
    pnlTool2: TPanel;
    rpnlBody: TRelativePanel;
    spbtnActivatePatches: TSpeedButton;
    sbtnDirWatcher: TSpeedButton;
    sbtnRefreshSCM: TSpeedButton;
    scmGrid: TDBAdvGrid;
    ShapeSpaceerSCM: TShape;
    ShapeSpacer: TShape;
    spbtnPost: TSpeedButton;
    stackpnlTool2: TStackPanel;
    StatBar: TStatusBar;
    TDPushResultFile: TFileOpenDialog;
    tdsGrid: TDBAdvGrid;
    Timer1: TTimer;
    vimgHeatNum: TVirtualImage;
    vimgHeatStatus: TVirtualImage;
    vimgRelayBug: TVirtualImage;
    vimgStrokeBug: TVirtualImage;
    pnlSCMGrid: TPanel;
    pnlTDSGrid: TPanel;
    frameNoodles: TNoodleFrame;
    actnActivatePatches: TAction;
    sbtnAutoSync: TSpeedButton;
    actnAutoSync: TAction;
    actnExploreMeetsFolder: TAction;
		procedure actnAboutExecute(Sender: TObject);
		procedure actnAboutUpdate(Sender: TObject);
		procedure actnExploreMeetsFolderUpdate(Sender: TObject);
    procedure actnBuildTDTablesExecute(Sender: TObject);
    procedure actnBuildTDTablesUpdate(Sender: TObject);
    procedure actnActivatePatchesExecute(Sender: TObject);
    procedure actnActivatePatchesUpdate(Sender: TObject);
    procedure actnAutoSyncExecute(Sender: TObject);
    procedure actnAutoSyncUpdate(Sender: TObject);
    procedure actnClearAndScanExecute(Sender: TObject);
    procedure actnClearAndScanUpdate(Sender: TObject);
    procedure actnClearGridExecute(Sender: TObject);
    procedure actnClearGridUpdate(Sender: TObject);
    procedure actnConnectToSCMExecute(Sender: TObject);
    procedure actnConnectToSCMUpdate(Sender: TObject);
		procedure actnExploreMeetsFolderExecute(Sender: TObject);
    procedure actnExportMeetProgramExecute(Sender: TObject);
    procedure actnExportMeetProgramUpdate(Sender: TObject);
    procedure actnLoadSessionExecute(Sender: TObject);
    procedure actnLoadSessionUpdate(Sender: TObject);
    procedure actnPostExecute(Sender: TObject);
    procedure actnPostUpdate(Sender: TObject);
    procedure actnPreferencesExecute(Sender: TObject);
    procedure actnPushResultsExecute(Sender: TObject);
    procedure actnPushResultsUpdate(Sender: TObject);
    procedure actnReConstructTDResultFilesExecute(Sender: TObject);
    procedure actnReConstructTDResultFilesUpdate(Sender: TObject);
    procedure actnRefreshExecute(Sender: TObject);
    procedure actnRestartDirectoryWatcherExecute(Sender: TObject);
    procedure actnRestartDirectoryWatcherUpdate(Sender: TObject);
    procedure actnRptSCMEventBasicExecute(Sender: TObject);
    procedure actnRptSCMEventBasicUpdate(Sender: TObject);
    procedure actnSaveSessionExecute(Sender: TObject);
    procedure actnSaveSessionUpdate(Sender: TObject);
    procedure actnScanMeetsFolderExecute(Sender: TObject);
    procedure actnScanMeetsFolderUpdate(Sender: TObject);
    procedure actnSCMSessionExecute(Sender: TObject);
    procedure actnSCMSessionUpdate(Sender: TObject);
    procedure actnSelectSwimClubExecute(Sender: TObject);
    procedure actnSelectSwimClubUpdate(Sender: TObject);
    procedure actnSyncSCMExecute(Sender: TObject);
    procedure actnSyncSCMUpdate(Sender: TObject);
    procedure actnSyncTDExecute(Sender: TObject);
    procedure actnSyncTDUpdate(Sender: TObject);
    procedure actnTDTableViewerExecute(Sender: TObject);
    procedure actnFireDACExplorerExecute(Sender: TObject);
		procedure actnRefreshUpdate(Sender: TObject);
    procedure btnNextDTFileClick(Sender: TObject);
    procedure btnNextEventClick(Sender: TObject);
    procedure btnPickDTTreeViewClick(Sender: TObject);
    procedure btnPickSCMTreeViewClick(Sender: TObject);
    procedure btnPrevDTFileClick(Sender: TObject);
    procedure btnPrevEventClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
		procedure frameNoodlespbNoodlesMouseDown(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);
    procedure scmGridGetDisplText(Sender: TObject; ACol, ARow: Integer; var Value:
        string);
    procedure tdsGridClickCell(Sender: TObject; ARow, ACol: Integer);
    procedure Timer1Timer(Sender: TObject);

  private
  var
    fClearAndScan_Done: Boolean;
    { Private declarations }
    fDirectoryWatcher: TDirectoryWatcher;
    { User preference: On boot-up, populated the TDS data tables with any
      'results' that may reside in the 'meets' folder. }
    fDoClearAndScanOnBoot: boolean;
    { User preference: Connect to the SCM DB Server on boot. Default: FALSE }
    fDoLoginOnBoot: boolean;
    FSyncSCMVerbose: Boolean;
    FSyncTDSVerbose: Boolean;

		procedure GridSelectCurrentTDSLane;
    procedure LoadSettings; // JSON Program Settings
    procedure OnFileChanged(Sender: TObject; const FileName: string; Action: DWORD);
    procedure UpdateCaption();
    procedure UpdateCellIcons(ADataset: TDataSet; ARow: Integer; AActiveRT:
        scmActiveRT);
  protected
    procedure MSG_ClearAndScan(var Msg: TMessage); message SCM_CLEARANDSCAN_TIMEDROPS;
    // perform either RESCAN or CLEARANDRESCAN based on Msg.wParam
    // 1 = RESCAN, 2 = CLEARANDRESCAN (destrucive).
    // make silent based on Msg.lParam
    // 0 = verbose, 1 = silent.
    procedure MSG_ClearGrid(var Msg: TMessage); message SCM_CLEAR_TIMEDROPS;
    procedure MSG_Connect(var Msg: TMessage); message SCM_CONNECT;
    procedure MSG_PushResults(var Msg: TMessage); message SCM_PUSH_TIMEDROPS;
    procedure MSG_ScanMeets(var Msg: TMessage); message SCM_SCAN_TIMEDROPS;
    procedure MSG_UpdateUISCM(var Msg: TMessage); message SCM_UPDATEUI_SCM;
    procedure MSG_UpdateUITDS(var Msg: TMessage); message SCM_UPDATEUI_TDS;
    procedure MSG_UpdateUINOODLES(var Msg: TMessage); message SCM_UPDATE_NOODLES;

  public
  end;

  const
    AcceptedTimeKeeperDeviation = 0.3;

var
  Main: TMain;

implementation

{$R *.dfm}

uses System.UITypes, System.DateUtils ,dlgSessionPicker, dlgOptions, dlgTreeViewSCM,
  dlgDataDebug, dlgTreeViewData, dlgUserRaceTime, dlgPostData, tdMeetProgram,
  tdMeetProgramPick, tdResults, uWatchTime, uAppUtils, tdLogin,
  Winapi.ShellAPI, dlgFDExplorer, dmSCM, dmTDS, dlgScanOptions, rptReportsSCM,
  dlgSwimClubPicker, dlgAbout;

const

  CAPTION_RECONSTRUCT = '%s files ...';



function ExtractSessionEventHeat(const FileName: string; out SessionID,
  EventNum, HeatNum: Integer): Boolean;
var
  fn: string;
  Fields: TArray<string>;
begin
  // Example: parse FileName to extract SessionID, EventNum, HeatNum
  // You must implement this based on your filename format
  // Return True if successful, False otherwise
  result := false;
  // remove path from filename
  fn := ExtractFileName(FileName);
  Fields := System.StrUtils.SplitString(fn, '_');
  if Length(Fields) > 1 then
  begin
    // Strip non-numeric characters from Fields[1]
    Fields[0] := StripNonNumeric(Fields[0]);
    SessionID := StrToIntDef(Fields[0], 0);
    if (SessionID <> 0) then
    begin
      // Filename syntax used by Time Drops: SessionSSSS_Event_EEEE_HeatHHHH_RaceRRRR_XXX.json
      if Length(Fields) > 2 then
      begin
        EventNum := StrToIntDef(StripNonNumeric(Fields[1]), 0);
        if Length(Fields) > 3 then
        begin
          HeatNum := StrToIntDef(StripNonNumeric(Fields[2]), 0);
          //      if Length(Fields) > 4 then
          //        RaceNum := StrToIntDef(StripNonNumeric(Fields[3]), 0);
          result := true;
        end;
      end;
    end;
  end;
end;

function FileNameComparer(const Left, Right: string): Integer;
var
  S1, S2, E1, E2, H1, H2: Integer;
begin
  if not ExtractSessionEventHeat(Left, S1, E1, H1) then
    Exit(-1);
  if not ExtractSessionEventHeat(Right, S2, E2, H2) then
    Exit(1);

  Result := S1 - S2;
  if Result = 0 then
    Result := E1 - E2;
  if Result = 0 then
    Result := H1 - H2;
end;



procedure TMain.actnAboutExecute(Sender: TObject);
var
	dlg: TAbout;
begin
	dlg := TAbout.Create(Self);
  dlg.ShowModal;
	dlg.Free;
end;

procedure TMain.actnAboutUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := true;
end;

procedure TMain.actnExploreMeetsFolderUpdate(Sender: TObject);
begin
	if Assigned(Settings) then
	begin
		if not TAction(Sender).Enabled then
			TAction(Sender).Enabled := true;
	end
	else
		if TAction(Sender).Enabled then
			TAction(Sender).Enabled := false;
end;

procedure TMain.actnBuildTDTablesExecute(Sender: TObject);
begin
  // Allow only in debug
{$IFDEF DEBUG}
  TDS.BuildAppData;
{$ENDIF};
end;

procedure TMain.actnBuildTDTablesUpdate(Sender: TObject);
begin
	if Assigned(TDS) then
	begin
		if not TAction(Sender).Enabled then
			TAction(Sender).Enabled := true;
	end
	else
		if TAction(Sender).Enabled then
			TAction(Sender).Enabled := false;
end;

procedure TMain.actnActivatePatchesExecute(Sender: TObject);
begin
  TAction(Sender).Checked := not(TAction(Sender).Checked);
  if TAction(Sender).Checked then
  begin
    spbtnActivatePatches.ImageIndex := 14;
    frameNoodles.pbNoodles.Enabled := true;
  end
  else
  begin
    spbtnActivatePatches.ImageIndex := 20;
    frameNoodles.pbNoodles.Enabled := false;
  end;
end;

procedure TMain.actnActivatePatchesUpdate(Sender: TObject);
begin
  if Assigned(TDS) and TDS.DataIsActive
    and Assigned(SCM) and SCM.DataIsActive then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
    if TAction(Sender).Enabled then
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnAutoSyncExecute(Sender: TObject);
begin
	TAction(Sender).Checked := not (TAction(Sender).Checked);
	if TAction(Sender).Checked then
		sbtnAutoSync.ImageIndex := 19
	else
		sbtnAutoSync.ImageIndex := 21;

  if TAction(Sender).Checked then // Perform SYNCRONIZATION ...
  begin
    if SCM.qrySession.FieldByName('SessionID').AsInteger <>
    TDS.tblmSession.FieldByName('SessionNum').AsInteger then
      SCM.LocateSessionID(TDS.tblmSession.FieldByName('SessionNum').AsInteger);

		FSyncSCMVerbose := false; // Silent Mode.
		actnSyncSCM.Execute(); // Syncronize SCM grid.
		FSyncSCMVerbose := true;
	end;
end;

procedure TMain.actnAutoSyncUpdate(Sender: TObject);
begin
	if Assigned(TDS) and TDS.DataIsActive
		and Assigned(SCM) and SCM.DataIsActive then
	begin
		if not TAction(Sender).Enabled then
			TAction(Sender).Enabled := true;
	end
	else
		if TAction(Sender).Enabled then
			TAction(Sender).Enabled := false;
end;

procedure TMain.actnClearAndScanExecute(Sender: TObject);
begin
  actnClearGridExecute(actnClearGrid);
  actnScanMeetsFolderExecute(actnClearGrid);
end;

procedure TMain.actnClearAndScanUpdate(Sender: TObject);
begin
  if Assigned(TDS) and TDS.DataIsActive then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
    if TAction(Sender).Enabled then
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnClearGridExecute(Sender: TObject);
var
  mr: TModalResult;
begin
  if (not fClearAndScan_Done) then
    mr := mrOk
  else
    // Because this proc is destructive - confirmation is required.
    mr := MessageDlg('Do you want to EMPTY TimeDrop''s' + sLineBreak + 'data tables and CLEAR the grid? ',
      mtConfirmation, [mbYes, mbNo], 0, mbNo);
  if IsPositiveResult(mr) then
  begin
    // Test DT directory exists...
    if DirectoryExists(Settings.MeetsFolder) then
    begin
      if DirHasResultFiles(Settings.MeetsFolder) then
      begin
        TDS.DisableAllTDControls;
        tdsGrid.BeginUpdate;
        try
          TDS.EmptyAllTDDataSets;
        finally
          TDS.EnableAllTDControls;
          tdsGrid.EndUpdate;
          // Assert : remove display of lbl_tdsGridOverlay.
          fClearAndScan_Done := true;
          // paint the TDS grid.
          PostMessage(self.Handle, SCM_UPDATEUI_TDS, 0, 0);
        end;
      end;
    end;
  end;
end;

procedure TMain.actnClearGridUpdate(Sender: TObject);
begin
  if Assigned(TDS) and TDS.DataIsActive then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
    if TAction(Sender).Enabled then
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnConnectToSCMExecute(Sender: TObject);
var
  aLoginDlg: TLogin;  // 24/04/2020 uses simple INI access
  NumOfLanes: integer;
begin
  fDoLoginOnBoot := false; // Do Once...
  // -----------------------------------------------------------
  // 02/05/2025 connect - %AppData%\Artanemus\SCM\FDConnectionDefs.ini
  // -----------------------------------------------------------
  aLoginDlg := TLogin.Create(self);
  aLoginDlg.ShowModal;
  aLoginDlg.Free;

  if SCM.scmConnection.Connected then
  begin
    scmGrid.BeginUpdate;
    try
      SCM.ActivateDataSCM;
    finally
      scmGrid.EndUpdate;
    end;
    TAction(Sender).Caption := 'Disconnect from the SCM database...';
  end
  else
  begin
    TAction(Sender).Caption := 'Connect to the SCM database...';
  end;

  if SCM.DataIsActive then
  begin
    NumOfLanes := SCM.qrySwimClub.FieldByName('NumOfLanes').AsInteger;
    // NOTE: TimeDrops maxium of ten lanes but some pools have 10 lanes.
    if NumOfLanes in [1..12] then
    begin
      if frameNoodles.NumberOflanes <> NumOfLanes then
        frameNoodles.NumberOflanes := NumOfLanes;
    end;
  end;

end;

procedure TMain.actnConnectToSCMUpdate(Sender: TObject);
begin
  if Assigned(SCM) and SCM.scmFDManager.Active then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
    if TAction(Sender).Enabled then
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnExploreMeetsFolderExecute(Sender: TObject);
var
  FolderPath: string;
begin
  FolderPath := Settings.MeetsFolder;
  if DirectoryExists(FolderPath) then
    ShellExecute(0, 'open', PChar(FolderPath), nil, nil, SW_SHOWNORMAL)
  else
    MessageDlg('The folder does not exist: ' + FolderPath, mtError, [mbOK], 0);
end;


procedure TMain.actnExportMeetProgramExecute(Sender: TObject);
var
  fn: TFileName;
  dlg: TMeetProgramPick;
  AModalResult: TModalResult;
  msg: string;
begin

  if (SCM.qrySession.IsEmpty) or (SCM.qryEvent.IsEmpty)
    or (SCM.qryHeat.IsEmpty) then
  begin
    msg := '''
    Missing elements in the SwimClubMeet Session.
    Check that the session contains events with heats, else a ''Meet Program'' can''t be built).
    ''';
    MessageDlg(msg, mtInformation, [mbOK], 0);
    exit;
  end;

  dlg := TMeetProgramPick.Create(self);
  AModalResult := dlg.ShowModal;
  if IsPositiveResult(AModalResult) then
  begin
    // The meet program folder may have changed.
    Settings.LoadFromFile();
    // The default filename required by TimeDrops
		fn := IncludeTrailingPathDelimiter(Settings.ProgramFolder)  + 'meet_program.json';
    SCMGrid.BeginUpdate;
    if Settings.MeetProgramType = 1 then
      BuildAndSaveMeetProgramDetailed(fn) // Detailed meet program.
		else if Settings.MeetProgramType = 0 then
      BuildAndSaveMeetProgramBasic(fn); // Basic meet program.
    // re-set to head of session.
    SCM.dsEvent.DataSet.First;
    SCM.dsHeat.DataSet.First;
    // update grid.
    SCMGrid.EndUpdate;
    // Message user.
    MessageBox(0,
      PChar('Export of the Time Drops Meet Program has been completed.'),
      PChar('Export Meet Program'), MB_ICONINFORMATION or MB_OK);
  end;
  dlg.Free;

end;

procedure TMain.actnExportMeetProgramUpdate(Sender: TObject);
begin
  if Assigned(SCM) and SCM.DataIsActive then
    begin
    if (TAction(Sender).Enabled = false) then
      TAction(Sender).Enabled := true;
    end
  else
    begin
    if (TAction(Sender).Enabled = true) then
      TAction(Sender).Enabled := false;
    end;
end;

procedure TMain.actnLoadSessionExecute(Sender: TObject);
begin
  // file explorer init
  if Assigned(Settings) then
  begin
    if DirectoryExists(Settings.AppDataFolder) then
        FileOpenDlg.DefaultFolder := Settings.AppDataFolder;
  end;
  // open - select folder to save too.
  if FileOpenDlg.Execute then
  begin
    try
      tdsGrid.BeginUpdate;
      TDS.ReadFromBinary(FileOpenDlg.FileName);
    finally
      tdsGrid.EndUpdate;
    end;
  end;
end;

procedure TMain.actnLoadSessionUpdate(Sender: TObject);
begin
  if (Assigned(TDS)) and (TDS.DataIsActive = true) then
  begin
    if (TAction(Sender).Enabled = false) then
      TAction(Sender).Enabled := true;
  end
  else
  begin
    if TAction(Sender).Enabled = true then
      TAction(Sender).Enabled := false;
  end;
end;

procedure TMain.actnPostExecute(Sender: TObject);
var
  dlg: TPostData;
  mr: TModalResult;
	I, idx, LaneID, HeatID, LaneNum: integer;
  aTDSessionID, aTDEventNum, aTDHeatNum, ALaneNum: integer;
  s: string;
begin
  if (TDS.tblMHeat.IsEmpty) or (SCM.qryHeat.IsEmpty) then
  begin
    MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound.
    StatBar.SimpleText := 'Empty grid. Missing data.';
    Timer1.Enabled := true;
    exit;
  end;
  // Establish if SCM AND DT are syncronized.
  aTDSessionID := SCM.qrySession.FieldByName('SessionID').AsInteger;
  aTDEventNum := SCM.qryEvent.FieldByName('EventNum').AsInteger;
  aTDHeatNum := SCM.qryHeat.FieldByName('HeatNum').AsInteger;
  if not TDS.SyncCheck(aTDSessionID, aTDEventNum, aTDHeatNum) then
  begin
    s := '''
			Based on the Session ID, event and heat number, SCM and DT are not synronized.
			Do you want to CONTINUE?
			YES will result in syncronization begin ignored and a "lane for lane" assignment
			of race-times (including any valid noodles) will be made.
			''';
    mr := MessageBox(0, PChar(s), PChar('POST ''RACE-TIMES'' WARNING'),
      MB_ICONEXCLAMATION or MB_YESNO or MB_DEFBUTTON2);
    if not IsPositiveResult(mr) then
    begin
      StatBar.SimpleText := 'POST was cancelled.';
      Timer1.Enabled := true;
      //      MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound.
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
    // disable AUTO-SYNC ....
    actnAutoSync.Checked := false;
    sbtnAutoSync.ImageIndex := 21;

		LaneID := TDS.tblmLane.FieldByName('LaneID').AsInteger;
		LaneNum:= TDS.tblmLane.FieldByName('LaneNum').AsInteger;
		TDS.PatchesEnabled := actnActivatePatches.Checked;
		// Post all race-times to SCM ...
    if idx = 0 then
    begin
      tdsGrid.BeginUpdate;
      TDS.POST_All;
			tdsGrid.ClearRowSelect; // UI clean-up .
			if TDS.Locate_LaneID(LaneID) then
			begin
				idx := tdsGrid.GetRealRow;
				tdsGrid.SelectRows(idx, 1);
			end;
			tdsGrid.EndUpdate;
			StatBar.SimpleText := 'POST of all valid race-times to SCM : completed.';
		end
			// Post only racetimes from selected lanes to SCM ...
		else if idx = 1 then
		begin
			tdsGrid.BeginUpdate;
			HeatID := TDS.tblmHeat.FieldByName('HeatID').AsInteger;
			GridSelectCurrentTDSLane;	// only works when is nothing selected.
			for i := 0 to tdsGrid.SelectedRowCount - 1 do
			begin
				idx := tdsGrid.SelectedRow[i];
				ALaneNum := StrToIntDef(tdsGrid.Cells[1, idx], 0);
				if TDS.LocateTLaneNum(HeatID, ALaneNum) then // ASSERT record cued.
					TDS.POST_Lane(); // found record.
			end;
			tdsGrid.ClearRowSelect; // UI clean-up.
			TDS.tblmLane.CheckBrowseMode;
			if TDS.LocateTLaneNum(HeatID, LaneNum) then
				GridSelectCurrentTDSLane; // only works when nothing is selected.
				
			tdsGrid.EndUpdate;
      StatBar.SimpleText := 'POST of selected race-times to SCM : completed.';
    end;
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
  if (Assigned(TDS)) and (Assigned(SCM))
    and (SCM.DataIsActive) and (TDS.DataIsActive) then
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
  begin
    // Update any preference changes
    LoadSettings;
    tdsGrid.BeginUpdate;
    TDS.tblmHeat.ApplyMaster;
    TDS.tblmLane.ApplyMaster;
    tdsGrid.EndUpdate;
    // Update lblEventDetailsTD. Paint cell icons into grid.
    PostMessage(Self.Handle, SCM_UPDATEUI_TDS, 0, 0);
    end;
  dlg.Free;
  UpdateCaption;

end;

procedure TMain.actnPushResultsExecute(Sender: TObject);
var
  AFile, s: string;
  mr: TModalResult;
  count: integer;
begin
  count := 0;
  s := '''
  Selecting Ok will open a file explorer.
  Choose any TimeDrops ''result'' files and PUSH to the grid.
  New ''results'' will be added, modified ''results'' will adjust existing heats.
  ''';
  mr := MessageBox(0, PChar(s), PChar('Push Results to Grid'), MB_ICONQUESTION or MB_OKCANCEL);

  if IsPositiveResult(mr) then
  begin
    if TDPushResultFile.Execute() then
    begin
      tdsGrid.BeginUpdate;
      try
        begin
          // terminate system watch folder.
          for AFile in TDPushResultFile.Files do
          begin
            { Calls - PrepareExtraction, ProcessEvent, ProcessHeat, ProcessEntrant }
            tdResults.ProcessFile(AFile);
            inc(Count);
          end;
          s := 'Pushed (' + IntToStr(Count) + ') results completed.';
          MessageDlg(s, mtInformation, [mbOK], 0);
          // Assert : remove display of lbl_tdsGridOverlay.
          fClearAndScan_Done := true;
        end;
      finally
        tdsGrid.EndUpdate;
      end;
    end;
  end;
end;

procedure TMain.actnPushResultsUpdate(Sender: TObject);
begin
  if Assigned(TDS) and TDS.DataIsActive then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
    if TAction(Sender).Enabled then
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnReConstructTDResultFilesExecute(Sender: TObject);
var
  dlg: TReConstructDlg;
  AModalResult: TModalResult;
begin
  dlg := TReConstructDlg.Create(self);
  AModalResult := dlg.ShowModal;
  if IsPositiveResult(AModalResult) then
  begin
    // ASSERT: Settings may have changed.
    Settings.LoadFromFile();
    // The default filename supplied in settings.
    SCMGrid.BeginUpdate;
    ReconstructSession(SCM.qrySession.FieldByName('SessionID').AsInteger);
    // re-set to head of session.
    SCM.dsEvent.DataSet.First;
    SCM.dsHeat.DataSet.First;
    // update grid.
    SCMGrid.EndUpdate;
    // Message user.
    MessageBox(0,
      PChar('Creation of Time Drops Results files has been completed.'),
      PChar('Re-Construct & Export TD Results'), MB_ICONINFORMATION or MB_OK);
  end;
  dlg.Free;
end;

procedure TMain.actnReConstructTDResultFilesUpdate(Sender: TObject);
var
Passed: boolean;
begin
  passed := true;
  if not Assigned(SCM) then passed := false;
  if not Assigned(SCM.scmConnection) then passed := false;
  if not SCM.scmConnection.Connected then passed := false;
  if not Assigned(TDS) then passed := false;
  if not SCM.DataIsActive then passed := false;

  if passed then
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
  SCM.RefreshSCM;
  SCMGrid.EndUpdate;
  StatBar.SimpleText := 'Refresh done.'; // not painting text?
  Timer1.Enabled := true;
end;

procedure TMain.actnRestartDirectoryWatcherExecute(Sender: TObject);
begin
  DirectoryWatcher.StopWatcher(fDirectoryWatcher);
  DirectoryWatcher.StartWatcher(fDirectoryWatcher, OnFileChanged);
end;

procedure TMain.actnRestartDirectoryWatcherUpdate(Sender: TObject);
begin
  if Assigned(fDirectoryWatcher) then
    actnRestartDirectoryWatcher.ImageName := 'VisibilityOn'
  else
    actnRestartDirectoryWatcher.ImageName := 'VisibilityOff';
end;

procedure TMain.actnRptSCMEventBasicExecute(Sender: TObject);
var
  rpt: TReportsSCM;
begin
  try
    rpt := TReportsSCM.Create(self);
  except on E: Exception do exit;
  end;
  rpt.RptExecute;
  FreeAndNil(rpt);
end;

procedure TMain.actnRptSCMEventBasicUpdate(Sender: TObject);
begin
  if (Assigned(SCM)) and (SCM.DataIsActive = true) then
  begin
    if (TAction(Sender).Enabled = false) then
      TAction(Sender).Enabled := true;
  end
  else
  begin
    if TAction(Sender).Enabled = true then TAction(Sender).Enabled := false;
  end;
end;

procedure TMain.actnSaveSessionExecute(Sender: TObject);
begin
  // Assign default folder - else leave as null string.
  if Assigned(Settings) then
  begin
    if DirectoryExists(Settings.AppDataFolder) then
        FileSaveDlg.DefaultFolder := Settings.AppDataFolder;
  end;
  // Build a suitable filename.
  FileSaveDlg.FileName := 'SCM_TimeDrops_' +
    IntToStr(TDS.tblmSession.FieldByName('SessionID').AsInteger);
  // open TFileSaveDlg to select folder to save too.
  if FileSaveDlg.Execute then
  begin
    // Assert file extension?...
    TDS.WriteToBinary(FileSaveDlg.FileName);
  end;
end;

procedure TMain.actnSaveSessionUpdate(Sender: TObject);
begin
  if (Assigned(TDS)) and (TDS.DataIsActive = true) then
  begin
    if (TAction(Sender).Enabled = false) then
      TAction(Sender).Enabled := true;
  end
  else
  begin
    if TAction(Sender).Enabled = true then
      TAction(Sender).Enabled := false;
  end;
end;

procedure TMain.actnScanMeetsFolderExecute(Sender: TObject);
var
  mr: TModalResult;
  LList: TStringDynArray;
  dlg : TScanOptions;
  I: integer;
  LSearchOption: TSearchOption;
  WildCardStr: String;
begin
  // Do not do recursive extract into subfolders
  LSearchOption := TSearchOption.soTopDirectoryOnly;
  WildCardStr := '';


  if (not fClearAndScan_Done) or (fDoClearAndScanOnBoot) then
  begin
    mr := mrOK;
    WildCardStr := 'Session*.JSON';
  end
  else
  begin
    dlg := TScanOptions.Create(Self);
    mr := dlg.ShowModal;
    if dlg.rgrpScanOptions.ItemIndex = 0 then
      WildCardStr := 'Session*.JSON'
    else
      WildCardStr := 'Session' + dlg.edtSessionID.Text + '*.JSON';
    dlg.free;
  end;

  if IsPositiveResult(mr) then
  begin
    // Test DT directory exists...
    if DirectoryExists(Settings.MeetsFolder) then
    begin
      if DirHasResultFiles(Settings.MeetsFolder) then
      begin
        try
          // For files use GetFiles method
          LList := TDirectory.GetFiles(Settings.MeetsFolder, WildCardStr, LSearchOption);
        except
          // Catch the possible exceptions
        end;

        // ... SORT before processing files:
        TArray.Sort<string>(LList, TComparer<string>.Construct(FileNameComparer));

        if Length(LList) > 0 then
        begin
          TDS.DisableAllTDControls;
          tdsGrid.BeginUpdate;
          try
            // NOTE: ProcessFile.
            for I := 0 to Length(LList) - 1 do
            begin
              ProcessFile(LList[i]);
            end;
          finally
            TDS.EnableAllTDControls;
            tdsGrid.EndUpdate;
          end;
        end;
        fClearAndScan_Done :=  true;
        PostMessage(self.Handle, SCM_UPDATEUI_TDS, 0, 0); // Update UI.
      end;
    end;
  end;
end;

procedure TMain.actnScanMeetsFolderUpdate(Sender: TObject);
begin
  if Assigned(TDS) and TDS.DataIsActive then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
    if TAction(Sender).Enabled then
      TAction(Sender).Enabled := false;
end;

procedure TMain.actnSCMSessionExecute(Sender: TObject);
var
  dlg: TSessionPicker;
  mr: TModalResult;
  SessionID: integer;
  found: boolean;
begin
  dlg := TSessionPicker.Create(Self);
  dlg.rtnSessionID := 0;
  // the picker will locate to the given session id.
  if SCM.qrySession.Active and not SCM.qrySession.IsEmpty then
    dlg.rtnSessionID := SCM.qrySession.FieldByName('SessionID').AsInteger;

  mr := dlg.ShowModal; // Pick session
  SessionID := dlg.rtnSessionID;
  dlg.Free;

  if IsPositiveResult(mr) and (SessionID > 0) then
  begin
    found := SCM.LocateSessionID(SessionID); // onchange event called.
		if found and actnAutoSync.Checked then
				actnAutoSync.Execute; // disable AutoSync.
	end;
end;

procedure TMain.actnSCMSessionUpdate(Sender: TObject);
begin
  if (Assigned(SCM)) and (SCM.DataIsActive = true) then
  begin
    if (TAction(Sender).Enabled = false) then
      TAction(Sender).Enabled := true;
  end
  else
  begin
    if TAction(Sender).Enabled = true then
      TAction(Sender).Enabled := false;
  end;
end;

procedure TMain.actnSelectSwimClubExecute(Sender: TObject);
var
  dlg: TSwimClubPicker;
  mr: TModalResult;
	currSwimClubID: integer;
	found: boolean;
begin
  dlg := TSwimClubPicker.Create(Self);
  dlg.SwimClubID := 0;

	// the picker will locate to the given session id.
  if SCM.qrySwimClub.Active and not SCM.qrySwimClub.IsEmpty then
  begin
		try
			currSwimClubID := SCM.qrySwimClub.FieldByName('SwimClubID').AsInteger;
			mr := dlg.ShowModal;
			if IsPositiveResult(mr) and (dlg.SwimClubID > 0) then
			begin
				if dlg.SwimClubID <> currSwimClubID then
				begin
					SCM.MSG_Handle := 0;
					found := SCM.LocateSwimClubID(dlg.SwimClubID);
					SCM.MSG_Handle := Self.Handle;
					if found then
					begin
						PostMessage(Self.Handle, SCM_UPDATEUI_SCM, 0, 0);
						if Assigned(NoodleFrame) then
							PostMessage(Self.Handle, SCM_UPDATE_NOODLES, 0, 0);
					end;
				end;
			end;
		finally
			dlg.Free;
		end;
	end;
end;

procedure TMain.actnSelectSwimClubUpdate(Sender: TObject);
begin
	if (Assigned(SCM)) and (SCM.DataIsActive = true) then
	begin
		if not TAction(Sender).Enabled then
			TAction(Sender).Enabled := true;
		(*
		// multi-swimclub is available.
		if SCM.qrySwimClub.RecordCount > 1 then
		begin
		if not TAction(Sender).Enabled then
			TAction(Sender).Enabled := true;
		end
		else
		begin
			if TAction(Sender).Enabled then // option is disabled.
				TAction(Sender).Enabled := false;
		end;
		*)
	end
	else
		if TAction(Sender).Enabled then
			TAction(Sender).Enabled := false;
end;

procedure TMain.actnSyncSCMExecute(Sender: TObject);
var
  found: boolean;
  aTDSSessionNum, aTDSEventNum, aTDSHeatNum: integer;
begin
  scmGrid.BeginUpdate;
  aTDSSessionNum := TDS.tblmSession.FieldByName('SessionID').AsInteger;
  aTDSEventNum := TDS.tblmEvent.FieldByName('EventNum').AsInteger;
	aTDSHeatNum := TDS.tblmHeat.FieldByName('HeatNum').AsInteger;
	
	// PART 1 : ensure we are using the correct session.
  if actnAutoSync.Checked then
	begin // Does the current SCM session match the TD session? 
		if SCM.qrySession.FieldByName('SessionID').AsInteger <> aTDSSessionNum then
      found :=
				SCM.LocateSessionID(TDS.tblmSession.FieldByName('SessionNum').AsInteger)
		else found := true;
    if not found then
		begin // Error finding the SCM sessionID.
			StatBar.SimpleText := 'Syncronization of SCM to TD failed. '
			+ 'Auto-Sync was unable to find the SCM Session.';
      timer1.enabled := true;
      if FSyncSCMVerbose then
				MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound 
			scmGrid.EndUpdate;
			Exit;
		end;
	end;

	// PART 2 : try to syncronize with TimeDrops.
	found := SCM.SyncSCMToDT(aTDSSessionNum, aTDSEventNum, aTDSHeatNum);
	scmGrid.EndUpdate;

	if not found then
	begin	
		StatBar.SimpleText := 'Syncronization of SCM to TD failed. '
		+ 'Enable Auto-Sync or manually ''Select SCM Session''.';
		timer1.enabled := true;
		if FSyncSCMVerbose then
			MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound
	end
  else
  begin
		StatBar.SimpleText := 'Synced.';
    timer1.enabled := true;
  end;
end;

procedure TMain.actnSyncSCMUpdate(Sender: TObject);
begin
  if (Assigned(SCM)) and Assigned(TDS) and (SCM.DataIsActive = true) and
  (TDS.DataIsActive = true) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
  begin
    if TAction(Sender).Enabled then
      TAction(Sender).Enabled := false;
  end;
end;

procedure TMain.actnSyncTDExecute(Sender: TObject);
var
found: boolean;
aSCMSessionID, aSCMEventNum, aSCMHeatNum: integer;
begin
	tdsGrid.BeginUpdate;
  aSCMSessionID := SCM.qrySession.FieldByName('SessionID').AsInteger;
  aSCMEventNum := SCM.qryEvent.FieldByName('EventNum').AsInteger;
  aSCMHeatNum := SCM.qryHeat.FieldByName('HeatNum').AsInteger;
  found := TDS.SyncDTtoSCM(aSCMSessionID, aSCMEventNum, aSCMHeatNum);
  // data event - scroll.
  tdsGrid.EndUpdate;
  
  {TODO -oBSA -cGeneral : CHECK: Usage of UpdateEventDetails}
//  PostMessage(Self.Handle, SCM_UPDATEUI_TDS, 0 , 0);

  if not found then
  begin
		StatBar.SimpleText := 'Syncronization of TD to SCM failed. '
      + 'Your ''Results'' folder may not contain the session files required to sync.';
    timer1.enabled := true;
    if FSyncTDSVerbose then MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound
  end
  else
  begin
		StatBar.SimpleText := 'Synced.';
    timer1.enabled := true;
  end;
end;

procedure TMain.actnSyncTDUpdate(Sender: TObject);
begin
	if (Assigned(SCM)) and (Assigned(TDS)) and (SCM.DataIsActive = true)
		and (TDS.DataIsActive = true)  then
	begin
		if not TAction(Sender).Enabled then
			TAction(Sender).Enabled := true;
	end
	else
		if TAction(Sender).Enabled then
			TAction(Sender).Enabled := false;
end;

procedure TMain.actnTDTableViewerExecute(Sender: TObject);
var
dlg: TDataDebug;
begin
  dlg := TDataDebug.Create(self);
  dlg.ShowModal;
  dlg.Free;
end;

procedure TMain.actnFireDACExplorerExecute(Sender: TObject);
var
	ExplorerPath: string;
	IniFilePath: string;
	BDSBinPath: string;
	dlg: TFDExplorer;
begin

{$IFDEF DEBUG}
	// Retrieve the value of the BDSBIN environment variable
	SetLength(BDSBinPath, 256); // Allocate enough space
	SetLength(BDSBinPath, GetEnvironmentVariable('BDSBIN', PChar(BDSBinPath), Length(BDSBinPath)));
	if BDSBinPath <> '' then
	// Path to the FireDAC Explorer executable
		ExplorerPath := IncludeTrailingPathDelimiter(BDSBinPath) + 'FDExplorer.exe'
	else
		raise Exception.Create('Environment variable BDSBIN is not set.');
{$ELSE}
	ExplorerPath := ExtractFilePath(Application.ExeName);
	ExplorerPath := ExplorerPath + 'FDExplorer.exe';
{$ENDIF}

	dlg := TFDExplorer.Create(self);
	try
	begin
		if IsPositiveResult(dlg.ShowModal) then
		begin
			// Path to your FDConnectionDefs.ini file
			IniFilePath := SCM.scmFDManager.ActualDriverDefFileName;
			if FileExists(ExplorerPath) then
				ShellExecute(0, 'open', PChar(ExplorerPath), PChar(IniFilePath), nil, SW_SHOWNORMAL)
			else
				ShowMessage('FireDAC Explorer executable not found.');
		end;
	end;
	finally
			dlg.free;
	end;

end;

procedure TMain.actnRefreshUpdate(Sender: TObject);
begin
	if (Assigned(SCM)) and (SCM.DataIsActive = true)  then
	begin
		if not TAction(Sender).Enabled then
			TAction(Sender).Enabled := true;
	end
	else
		if TAction(Sender).Enabled then
			TAction(Sender).Enabled := false;
end;

procedure TMain.btnNextDTFileClick(Sender: TObject);
var
  lastHtID, lastEvID, IDht, IDev: integer;
  found: boolean;
begin
  // OR - if any are true then exit.
  if (not Assigned(TDS)) or (not TDS.DataIsActive) then
  begin
    MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound
    exit;
  end;

  tdsGrid.BeginUpdate;
  // this hack finds the last event ID and last heat ID in the current
  // Master-Detail linked Dolphin Timing data tables.
  IDHt := TDS.tblmHeat.fieldbyName('HeatID').AsInteger;
  TDS.tblmHeat.Last;
  lastHtID := TDS.tblmHeat.fieldbyName('HeatID').AsInteger;
  IDEv := TDS.tblmEvent.fieldbyName('EventID').AsInteger;
  TDS.tblmEvent.Last;
  lastEvID := TDS.tblmHeat.fieldbyName('EventID').AsInteger;
  found := TDS.tblmEvent.Locate('EventID', IDEv);
  if found then
    TDS.tblmHeat.Locate('HeatID', IDHt);
  tdsGrid.EndUpdate;

  // CNTRL+SHIFT - quick key to move to NEXT S E S S I O N .
  if (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_SHIFT) < 0) then
  begin
    TDS.dsmSession.DataSet.next;
    TDS.dsmEvent.DataSet.first;
    TDS.dsmHeat.DataSet.first;
  end
    // CNTRL- quick key to move to NEXT E V E N T .
  else if (GetKeyState(VK_CONTROL) < 0) then
  begin
    { After reaching the last event for the current session ...
      a second click of btnNextDTFileClick is needed to recieve a Eof.
      Checking for max eventID removes this UI nonscence.}
    if ((TDS.dsmEvent.DataSet.Eof) or
      (TDS.tblmEvent.fieldbyName('EventID').AsInteger = lastEvID)) then
    begin
      TDS.dsmSession.DataSet.next;
      TDS.dsmHeat.DataSet.First;
      TDS.dsmHeat.DataSet.first;
    end
    else
    begin
      TDS.dsmEvent.DataSet.next;
      TDS.dsmHeat.DataSet.First;
    end;
  end
    // move to N E X T   H E A T .
  else
  begin
    { After reaching the last record a second click of btnNextDTFileClick is needed to
      recieve a Eof. Checking for max heatID removes this UI nonscence.}
    if TDS.dsmHeat.DataSet.Eof or
      (TDS.tblmHeat.fieldbyName('HeatID').AsInteger = lastHtID) then
    begin
      TDS.dsmEvent.DataSet.next;
      TDS.dsmHeat.DataSet.First;
    end
    else
    begin
      TDS.dsmHeat.DataSet.next;
    end;
  end;

  if sbtnAutoSync.Down then
  begin
    FSyncSCMVerbose := false;
    actnSyncSCM.Execute(); // Syncronize SCM grid.
    FSyncSCMVerbose := true;
  end;

  // Update lblEventDetailsTD.
  // paint cell icons into grid
  PostMessage(Self.Handle, SCM_UPDATEUI_TDS, 0, 0);
  if Assigned(NoodleFrame) then
    PostMessage(Self.Handle, SCM_UPDATE_NOODLES, 0, 0);
end;

procedure TMain.btnNextEventClick(Sender: TObject);
var
  v: variant;
  sql: string;
  id: integer;
begin
  // OR - if any are true then exit.
  if (not Assigned(SCM)) or (SCM.DataIsActive = false) then
  begin
    MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound
    exit;
  end;

  if (GetKeyState(VK_CONTROL) < 0) then
  begin
      SCM.dsEvent.DataSet.next;
      SCM.dsHeat.DataSet.First;
  end
  else
  begin
    // Get the MAX HeatNum...
    sql := 'SELECT MAX(HeatNum) FROM [SwimClubMeet].[dbo].[HeatIndividual] WHERE [EventID] = :ID';
    id := SCM.dsEvent.DataSet.FieldByName('EventID').AsInteger;
    v := SCM.scmConnection.ExecSQLScalar(sql,[id]);
    if VarIsNull(v) then v := 0;
    { After reaching the last record a second click of btnNextEvent is needed to
      recieve a Eof. Checking for max heatnum removes this UI nonsence.}
    if SCM.dsHeat.DataSet.Eof or (SCM.dsHeat.DataSet.FieldByName('HeatNum').AsInteger = v)  then
    begin
      SCM.dsEvent.DataSet.next;
      SCM.dsHeat.DataSet.First;
    end
    else
    begin
      SCM.dsHeat.DataSet.next;
    end;
  end;

  if sbtnAutoSync.Down then
  begin
    FSyncTDSVerbose := false;
    actnSyncTD.Execute(); // Syncronize TDS grid.
    FSyncTDSVerbose := true;
  end;

	PostMessage(Self.Handle, SCM_UPDATEUI_SCM, 0, 0);
	if Assigned(NoodleFrame) then
		PostMessage(Self.Handle, SCM_UPDATE_NOODLES, 0, 0);
end;

procedure TMain.btnPickDTTreeViewClick(Sender: TObject);
var
dlg: TTreeViewData;
sessID, evID, htID: integer;
mr: TModalResult;
found: boolean;
SearchOptions: TLocateOptions;
begin
	// OR - if any are true then exit.
  if (not Assigned(TDS)) or (TDS.DataIsActive = false) or
    (TDS.tblmSession.IsEmpty) then
  begin
    MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound
    exit;
  end;

  SearchOptions := [];
  tdsGrid.BeginUpdate;

  // Params required to locate branch in tree.
  sessID := TDS.dsmSession.DataSet.FieldByName('SessionID').AsInteger;
  evID := TDS.dsmEvent.DataSet.FieldByName('EventID').AsInteger;
  htID := TDS.dsmHeat.DataSet.FieldByName('HeatID').AsInteger;

  // Open the SCM TreeView - cue-to-node based on params.
  dlg := TTreeViewData.Create(Self);
  dlg.Prepare(sessID, evID, htID);
  mr := dlg.ShowModal;
  sessID := dlg.SelectedSessionID;
  evID := dlg.SelectedEventID;
  htID := dlg.SelectedHeatID;
  dlg.Free;

  // A TreeView node was selected.
  if IsPositiveResult(mr) then
  begin
    { NOTE: DT session pick by the user may differ from the current
      SCM session being operated on. }
    TDS.dsmLane.DataSet.DisableControls;
    TDS.dsmHeat.DataSet.DisableControls;
    TDS.dsmEvent.DataSet.DisableControls;
    TDS.dsmSession.DataSet.DisableControls;
    try
      // Attempt to cue-to-data in Dolphin Timing tables.
      if (sessID > 0) then
      begin
        found := TDS.LocateTSessionID(sessID);
        if not found then
          TDS.tblmSession.First;
        TDS.tblmEvent.ApplyMaster;
        TDS.tblmEvent.First;
        TDS.tblmHeat.ApplyMaster;
        TDS.tblmHeat.First;
      end;
      if (evID > 0) then
      begin
        found := TDS.LocateTEventID(evID);
        if not found then
          TDS.tblmEvent.First;
        TDS.tblmHeat.ApplyMaster;
        TDS.tblmHeat.First;
        TDS.tblmLane.ApplyMaster;
        TDS.tblmLane.First;

      end;
      if (htID > 0) then
      begin
        found := TDS.LocateTHeatID(htID);
        if not found then
          TDS.tblmHeat.First;
      end;
    finally
      TDS.dsmSession.DataSet.EnableControls;
      TDS.dsmEvent.DataSet.EnableControls;
      TDS.dsmHeat.DataSet.EnableControls;
			TDS.dsmLane.DataSet.EnableControls;
			if actnAutoSync.checked then
				actnSyncSCMExecute(Self);
      (*
			PostMessage(Self.Handle, SCM_UPDATEUI_TDS, 0, 0);
			if Assigned(NoodleFrame) then
			begin
				TDS.tblmNoodle.ApplyMaster;
				PostMessage(Self.Handle, SCM_UPDATE_NOODLES, 0, 0);
			end;
			*)
    end;
  end;

  tdsGrid.EndUpdate;

end;

procedure TMain.btnPickSCMTreeViewClick(Sender: TObject);
var
dlg: TTreeViewSCM;
sess, ev, ht, aEventID, aHeatID: integer;
mr: TModalResult;
found: boolean;
begin
  // OR - if any are true then exit.
  if (not Assigned(SCM)) or (SCM.DataIsActive = false) then
  begin
    MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound
    exit;
  end;
  // information to locate branch in tree.
  sess := SCM.dsSession.DataSet.FieldByName('SessionID').AsInteger;
  ev := SCM.dsEvent.DataSet.FieldByName('EventID').AsInteger;
  ht := SCM.dsHeat.DataSet.FieldByName('HeatID').AsInteger;
  // Open the SCM TreeView.
  dlg := TTreeViewSCM.Create(Self);
  dlg.Prepare(SCM.scmConnection, sess, ev, ht);
  mr := dlg.ShowModal;
  aEventID := dlg.SelectedEventID;
  aHeatID := dlg.SelectedHeatID;
  dlg.Free;

  // CUE-TO selected TreeView item ...
  if IsPositiveResult(mr) then
	begin
    try
      SCM.dsEvent.DataSet.DisableControls;
      SCM.dsHeat.DataSet.DisableControls;
      if (aEventID <> 0) then
      begin
        found := SCM.LocateEventID(aEventID);
        if found then
        begin
          SCM.dsHeat.DataSet.Close;
          SCM.dsHeat.DataSet.Open;
          if (aHeatID <> 0) then
            SCM.LocateHeatID(aHeatID);
        end;
      end;
    finally
      SCM.dsEvent.DataSet.EnableControls;
      SCM.dsHeat.DataSet.EnableControls;
			if actnAutoSync.checked then
				actnSyncTDExecute(Self);

      (*
			// Update UI controls ...
			PostMessage(Self.Handle, SCM_UPDATEUI_SCM, 0, 0);
			if Assigned(NoodleFrame) then
			begin
				TDS.tblmNoodle.ApplyMaster;
				PostMessage(Self.Handle, SCM_UPDATE_NOODLES, 0, 0);
			end;
			*)
		end;
	end;
end;

procedure TMain.btnPrevDTFileClick(Sender: TObject);
var
  evNum, htNum: integer;
begin
  // OR - if any are true then exit.
  if ((not Assigned(TDS)) or (TDS.DataIsActive = false)) then
  begin
    MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound
    exit;
  end;

  evNum := TDS.dsmEvent.DataSet.FieldByName('EventNum').AsInteger;
  htNum := TDS.dsmHeat.DataSet.FieldByName('HeatNum').AsInteger;

  // CNTRL+SHIFT - quick key to move to previous session.
  if (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_SHIFT) < 0) then
  begin
    // reached bottom of table ...
    if TDS.dsmSession.DataSet.BOF then exit;
    TDS.dsmSession.DataSet.prior;
    TDS.dsmEvent.DataSet.first;
    TDS.dsmHeat.DataSet.first;
  end
  // CNTRL move to previous event ...
  else if (GetKeyState(VK_CONTROL) < 0) then
  begin
    if TDS.dsmEvent.DataSet.BOF or (evNum = 1) then
    begin
      TDS.dsmSession.DataSet.prior;
      TDS.dsmEvent.DataSet.first;
    end
    else
      TDS.dsmEvent.DataSet.prior;
  end
  else
  begin
    { After reaching the first record a second click of btnPrevDTFileClick is needed to
      recieve a Bof. Checking for heatnum = 1 removes this UI nonsence.}
    if TDS.dsmHeat.DataSet.BOF or (htNum = 1) then
    begin
      TDS.dsmEvent.DataSet.prior;
      TDS.dsmHeat.DataSet.Last;
    end
    else
      TDS.dsmHeat.DataSet.prior;
  end;

  if sbtnAutoSync.Down then
  begin
    FSyncSCMVerbose := false;
    actnSyncSCM.Execute(); // Syncronize SCM grid.
    FSyncSCMVerbose := true;
  end;

  // paint cell icons into grid.
  PostMessage(Self.Handle, SCM_UPDATEUI_TDS, 0, 0);
  if Assigned(NoodleFrame) then
    PostMessage(Self.Handle, SCM_UPDATE_NOODLES, 0, 0);
end;

procedure TMain.btnPrevEventClick(Sender: TObject);
begin
  // OR - if any are true then exit.
  if (not Assigned(SCM)) or (SCM.DataIsActive = false) then
  begin
    MessageBeep(MB_ICONERROR); // Plays the system-defined warning sound
    exit;
  end;

  if (GetKeyState(VK_CONTROL) < 0) then
  begin
    SCM.dsEvent.DataSet.prior;
    SCM.dsHeat.DataSet.First;
  end
  else
  begin
    if (SCM.dsEvent.DataSet.FieldByName('EventNum').AsInteger = 1) and
    (SCM.dsHeat.DataSet.FieldByName('HeatNum').AsInteger = 1) then
      exit;
    { After reaching the first record a second click of btnPrevEvent is needed to
      recieve a Bof. Checking for heatnum = 1 removes this UI nonsence. }
    if SCM.dsHeat.DataSet.BOF or
    (SCM.dsHeat.DataSet.FieldByName('HeatNum').AsInteger = 1) then
    begin
      SCM.dsEvent.DataSet.prior;
      SCM.dsHeat.DataSet.Last;
    end
    else
      SCM.dsHeat.DataSet.prior;
  end;

  if sbtnAutoSync.Down then
  begin
    FSyncTDSVerbose := false;
    actnSyncTD.Execute(); // Syncronize SCM grid.
    FSyncTDSVerbose := true;
  end;

  // A scroll event in qryHeat may occur and message is posted twice.
  PostMessage(self.Handle, SCM_UPDATEUI_SCM, 0, 0);
  if Assigned(NoodleFrame) then
    PostMessage(self.Handle, SCM_UPDATE_NOODLES, 0, 0);
end;


procedure TMain.FormCreate(Sender: TObject);
var
  msg: string;
begin

  FDirectoryWatcher := nil;
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
  fDoLoginOnBoot := false; // login to DB Server.
  fDoClearAndScanOnBoot := false; // EmptyDataSets and scan 'meets' folder.
  fClearAndScan_Done := false;
  FSyncSCMVerbose := true;
  FSyncTDSVerbose := true;

  // A Class that uses JSON to read and write application configuration
  Settings := TPrgSetting.Create;

  { If settings FILE doesn't exsist in %AppData% - it will be created and
    default data will be assigned.}
  if Assigned(Settings) then
  begin
    LoadSettings;
    // if true the login DLG will appear on first boot-up.
    // TForm.FormShow takes care of this.
    if Settings.DoLoginOnBoot then
      fDoLoginOnBoot := true;
    // If true then on application boot ...
    // EmptyDataset is called for all TFDMemTables.
    // The TimeDrops 'meets' folder is scanned for 'results'.
    if Settings.DoClearAndScanOnBoot then
      fDoClearAndScanOnBoot := true;
  end;

  // CREATE THE CORE SCM CONNECTION DATAMODULE.
  if not Assigned(SCM) then
  begin
    try
      SCM := TSCM.Create(self);
    except on E: Exception do
      begin
        msg := '''
        Creation and full initialisation of the SCM failed!
        SCM_TimeDrops must terminate.
        ''';
        MessageDlg(msg, mtError, [mbOK], 0);
        // shutdown in an orderly fashion.
        Application.Terminate();
        { Terminate is not immediate. Terminate is called automatically
        on a WM_QUIT message and when the main form closes}
        exit;
      end;
      // NOTE: at this point SCM.scmConnection IS NOT ACTIVE.
    end;
  end;

  // Assert Master-Detail. Safe to do while not connected.

  // ASSERT SCM TAdvDBGrid's DATASOURCE.
  if not Assigned(scmGrid.DataSource) then
  begin
    scmGrid.DataSource := SCM.dsINDV;
    if SCM.DataIsActive then
    begin
      if SCM.qryDistance.FieldByName('EventTypeID').AsInteger = 1 then
        scmGrid.DataSource := SCM.dsINDV
      else
        scmGrid.DataSource := SCM.dsTEAM;
    end;
  end;

  // C R E A T E   IMAGE COLLECTION DATAMODULE .
  if not Assigned(IMG) then
  begin
    try
      IMG := TIMG.Create(Self);
    except on E: Exception do
    end;
  end;

  if Assigned(frameNoodles) then
  begin
    frameNoodles.scmGrid := Self.scmGrid;
    frameNoodles.tdsGrid := Self.tdsGrid;
  end;

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

  // Enable of HINTS.
  application.ShowHint := true;


  // Create the TimeDrops system Data Module
  if not Assigned(TDS) then
  begin
    try
      TDS := TTDS.Create(Self);
    except
      on E: Exception do
        // Handle exception if needed.
    end;
  end;

  if Assigned(TDS) then
  begin
    if TDS.MasterDetailActive = false then
      TDS.EnableTDMasterDetail; // Attach master-detail relationships
    TDS.ActivateDataTDS; // Open all tables
    // Assert state.
    if TDS.DataIsActive = true then
      tdsGrid.DataSource := TDS.dsmLane; // Bind grid to data source
  end;

  // Set up the file system watcher ...
  // uses Settings.MeetsFolder else reverts to TimeDrops default folder.
  // on error fDirectoryWatcher = nil.
  DirectoryWatcher.StartWatcher(fDirectoryWatcher, OnFileChanged);

//  try
//    fDirectoryWatcher := TDirectoryWatcher.Create(Settings.MeetsFolder);
//    fDirectoryWatcher.OnFileChanged := OnFileChanged;
//    fDirectoryWatcher.Start;
//  except on E: Exception do
//    FreeAndNil(fDirectoryWatcher);
//  end;

  (*
    {$IFNDEF DEBUG}
      actnReConstructTDResultFiles.Visible := false;
    {$ENDIF}

    {$IFDEF DEBUG}
      // A button that allows me to run dmTDData.BuildTDData.
      // The FieldDefs are save out to XML. Load XML data to restore.
      actnReConstructTDResultFiles.Visible := true;
    {$ENDIF}
  *)

  // Assert StatusBar params
  // Ensure that the StyleElements property does not include seFont
  //  StatBar.StyleElements := StatBar.StyleElements - [seFont];
  //  StatBar.ParentFont := False;

  StatBar.Font.Size := 12;
  StatBar.Font.Color := clWebAntiqueWhite;
  StatBar.ShowHint := false;
  StatBar.SimplePanel := true;

  // Enable hint information
  Application.ShowHint := true;

  // Update UI controls ...
  PostMessage(Self.Handle, SCM_UPDATEUI_SCM, 0, 0);
  PostMessage(Self.Handle, SCM_UPDATEUI_TDS, 0, 0);

  // Allow the form to receive KeyDown events
  Self.KeyPreview := True;

  // images disappears because assignment only in TAction.Execute?
  spbtnPost.ImageIndex := 13;
  spbtnActivatePatches.ImageIndex := 14;
	sbtnRefreshSCM.ImageIndex := 4;
	
  // tidy up of auto-sync
  actnAutoSync.Checked := false;
	sbtnAutoSync.ImageIndex := 21;

{$IFDEF DEBUG}
	actnBuildTDTables.Visible := true;
	actnTDTableViewer.Visible := true;
{$ELSE}
	actnBuildTDTables.Visible := false;
	actnTDTableViewer.Visible := false;
{$ENDIF}

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

  if Assigned(Settings) then
    FreeAndNil(Settings);

  if Assigned(TDS) then TDS.MSG_Handle := 0;
  if Assigned(SCM) then SCM.MSG_Handle := 0;

end;

procedure TMain.FormHide(Sender: TObject);
begin
  if Assigned(TDS) then TDS.MSG_Handle := 0;
  if Assigned(SCM) then SCM.MSG_Handle := 0;
end;

procedure TMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    if Assigned(frameNoodles) then
    begin
      if frameNoodles.SelectedNoodle <> nil then
      begin
        frameNoodles.actDeleteNoodle.Execute;
        Key := 0; // Mark key as handled.
      end;
    end;
  end;
end;

procedure TMain.FormResize(Sender: TObject);
begin
//  PaintBoxNoodles.Invalidate;
//   UpdatePaintBoxBounds; // Reposition paintbox when form resizes
end;

procedure TMain.FormShow(Sender: TObject);
begin

  // Windows handle to message after after data scroll...
  if Assigned(TDS) then
  begin
    TDS.MSG_Handle := Self.Handle;
      // Assert Master - Detail ...
      if not TDS.MasterDetailActive then
        TDS.EnableTDMasterDetail;
      // Assert tables are open ...
			if not TDS.DataIsActive then
        TDS.ActivateDataTDS;
  end;

  if Assigned(SCM) then
  begin
    SCM.MSG_Handle := Self.Handle;
    // SCM.scmConnection must be connected to activate.
    // procedure asserts Master-Detail ...
    SCM.ActivateDataSCM;
  end;

  // LOGIN TO THE SCM DB SERVER.
  if fDoLoginOnBoot then
    // Prompt user to connect to SCM. (... and update UI.)
    // calling ... sets fDoLoginOnBoot := false.
    PostMessage(Self.Handle, SCM_CONNECT, 0 , 0 )
  else
    // Assert UI display is up-to-date.
    PostMessage(Self.Handle, SCM_UPDATEUI_SCM, 0 , 0 );

  // Fill the grid with available 'results'
  if fDoClearAndScanOnBoot and (not fClearAndScan_Done )then
    // calling ... sets fDoClearAndScanOnBoot := false.
    PostMessage(Self.Handle, SCM_CLEARANDSCAN_TIMEDROPS, 0, 0)
  else
    // Assert UI display is up-to-date.
    PostMessage(Self.Handle, SCM_UPDATEUI_TDS, 0 , 0 );

  StatBar.SimpleText := 'Check here for information, messages and warnings.';
	Timer1.Enabled := true;

end;

procedure TMain.frameNoodlespbNoodlesMouseDown(Sender: TObject; Button:
  TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SessNum, EventNum, HeatNum: integer;
begin
  if actnAutoSync.Enabled then
  begin
    if Assigned(SCM) and Assigned(TDS) and SCM.DataIsActive and TDS.DataIsActive
      then
    begin
      SessNum := TDS.tblmSession.FieldByName('SessionNum').AsInteger;
      EventNum := TDS.tblmEvent.FieldByName('EventNum').AsInteger;
      HeatNum := TDS.tblmHeat.FieldByName('HeatNum').AsInteger;
      if SCM.SyncCheck(SessNum, EventNum, HeatNum) then
        frameNoodles.pbNoodlesMouseDown(Sender, Button, Shift, X, Y);
    end;
  end;
end;

procedure TMain.GridSelectCurrentTDSLane;
var
	idx: integer;
begin
  if tdsGrid.SelectedRowCount = 0 then
  begin
    if Assigned(TDS) and TDS.DataIsActive and (not (TDS.tblmLane.IsEmpty)) then
		begin
			idx := (tdsGrid.FixedRows - 1) + TDS.tblmLane.FieldByName('LaneNum').AsInteger;
			tdsGrid.SelectRows(idx, 1);
		end;
  end;
end;

procedure TMain.LoadSettings;
begin
  if not FileExists(Settings.GetDefaultSettingsFilename()) then
  begin
    ForceDirectories(Settings.GetSettingsFolder());
    Settings.SaveToFile();
  end;
  Settings.LoadFromFile();
end;

procedure TMain.MSG_ClearAndScan(var Msg: TMessage);
begin
  // Destructive - call on boot.
  if actnClearAndScan.Enabled and (not fClearAndScan_Done) then
    actnClearAndScanExecute(Self);
end;

procedure TMain.MSG_ClearGrid(var Msg: TMessage);
begin
  // Destructive - call on boot.
  if actnClearGrid.Enabled then
    actnClearGridExecute(Self);
end;

procedure TMain.MSG_Connect(var Msg: TMessage);
begin
  if actnConnectToSCM.Enabled then
      // proc assigns fDoLoginOnBoot := false;
			actnConnectToSCMExecute(Self);
end;

procedure TMain.MSG_PushResults(var Msg: TMessage);
begin
  if actnPushResults.Enabled then
    actnPushResultsExecute(Self);
end;

procedure TMain.MSG_ScanMeets(var Msg: TMessage);
begin
  // Scan meet's folder - non destructive. (Refresh TDS Data).
  if actnScanMeetsFolder.Enabled then
    actnScanMeetsFolderExecute(Self);
end;

procedure TMain.MSG_UpdateUINOODLES(var Msg: TMessage);
begin
  if Assigned(frameNoodles) then
  begin
    if Assigned(TDS) and TDS.DataIsActive then
        frameNoodles.LoadNoodleData();
  end;
//  frameNoodles.Invalidate;
//  frameNoodles.pbNoodles.Invalidate;
end;

procedure TMain.MSG_UpdateUISCM(var Msg: TMessage);
var
  i: integer;
  ASessionID: integer;
  s, s2: string;
  v: variant;
  dt: TDateTime;

  procedure SetEmptyToolsPanel();
  begin
    vimgStrokeBug.ImageIndex := -1;
    lblHeatNum.Caption := '';
    vimgHeatNum.ImageIndex := -1;
    vimgHeatStatus.ImageIndex := -1;
    vimgRelayBug.ImageIndex := -1;
    lblMeters.Caption := '';
    lblMetersRelay.Visible := false;
  end;

  procedure SetSessionStartCaption();
  begin
    // ------------------------------------------------------------
    // Assign session details in pnlTools. (Bottom left of display)
    if ASessionID <> 0 then
    begin
    s := 'Session: ' + IntToStr(ASessionID) + sLineBreak;
    v := SCM.qrysession.FieldByName('SessionStart').AsVariant;
    if not VarIsNull(v) then
    begin
      dt := TDateTime(v);
      s := s + DateToStr(dt);
    end;
    lblSessionStart.Caption := s;
    end;
  end;

begin
  // Init SCM labels.
  lbl_scmGridOverlay.Caption := '';
  lblEventDetails.Caption := '';
  lbl_scmGridOverlay.Visible := true;
  lblSwimClubName.Caption := '';
  lblSessionStart.Caption := '';
  ASessionID := 0;

  if not Assigned(SCM) then
  begin
    lbl_scmGridOverlay.Caption := 'Failed to create the SCM data module!';
    pnlTool1.Visible := false;
    scmGrid.DataSource := nil;
    exit;
  end;
  if not Assigned(SCM.scmConnection) then
  begin
    lbl_scmGridOverlay.Caption := 'The database is offline!' + sLineBreak +
      'Failed to create TFDConnection.' + sLineBreak +'Critical error.';
    pnlTool1.Visible := false;
    scmGrid.DataSource := nil;
    exit;
  end;
  if not SCM.scmConnection.Connected then
  begin
    lbl_scmGridOverlay.Caption := 'The database is offline.' + sLineBreak +
      'Connect (Login) to the'  + sLineBreak + 'SwimClubMeet database.';
    pnlTool1.Visible := false;
    scmGrid.DataSource := nil;
    exit;
  end;
  if not SCM.DataIsActive then
  begin
    lbl_scmGridOverlay.Caption := 'The SwimClubMeet data is offline.' + sLineBreak +
      'A re-Connect is required.';
    pnlTool1.Visible := false;
    scmGrid.DataSource := nil;
    exit;
  end;
  if SCM.qrySession.IsEmpty then
  begin
    lbl_scmGridOverlay.Caption := 'The SwimClub has no sessions!';
    lblSessionStart.Caption := '';
    pnlTool1.Visible := true;
    SetEmptyToolsPanel;
    scmGrid.DataSource := nil;
    exit;
  end;

  // ----------------------------------------------------------------
  // ASSERT LABEL/PANEL STATE.
  lbl_scmGridOverlay.Visible := false;
  lbl_scmGridOverlay.Caption := '';
  pnlTool1.Visible := true;

  lblSwimClubName.Caption := SCM.qrySwimClub.FieldByName('Caption').AsString;

  // ASSERT DATASOURCE.
  if not Assigned(scmGrid.DataSource) then
    scmGrid.DataSource := SCM.GetActive_INDVorTEAM;

  // UPDATE pnlSCM HEADER DESCRIPTION.
  s := '';
  begin
    ASessionID := SCM.qrySession.FieldByName('SessionID').AsInteger;
    s := 'Session ID: ' + IntToStr(ASessionID);
    if SCM.qryEvent.IsEmpty then
    begin
      s:= s + ' NO EVENTS.';
    end
    else
    begin
      i := SCM.qryEvent.FieldByName('EventNum').AsInteger;
      s := s + ' : Event ' + IntToStr(i) + ' : ';
      // build the event detail string...  Distance Stroke (OPT: Caption)
      s := s + SCM.qryDistance.FieldByName('Caption').AsString;
      s := s + ' ' + SCM.qryStroke.FieldByName('Caption').AsString;
      if SCM.qryHeat.IsEmpty then
      begin
        s:= s + ' NO HEATS.';
      end
      else
      begin
        // heat number...
        i:=SCM.qryHeat.FieldByName('HeatNum').AsInteger;
        if (i > 0) then
          s := s + ' - Heat : ' + IntToStr(i);
        // event description - entered in core app's grid extension mode.
        s2 := SCM.qryEvent.FieldByName('Caption').AsString;
        if (length(s2) > 0) then
        begin
          if (length(s2) > 128) then
            s2 := s2.Substring(0, 124) + '...';
          s := s + sLineBreak +  s2;
        end
        else
        begin
          s := s + sLineBreak +  'No event description was given';
        end;
      end;
    end;
  end;

  // assign DESCRIPTION .
  if Length(s) > 0 then
    lblEventDetails.Caption := s;
  SetSessionStartCaption;


  // PAINT ICON BUGS - EVENT.
  if SCM.qryEvent.IsEmpty then
  begin
    lbl_scmGridOverlay.Visible := true;
    lbl_scmGridOverlay.Caption := 'No events for the current session.';
    scmGrid.DataSource := nil;
    vimgStrokeBug.ImageIndex := -1;
    vimgRelayBug.ImageIndex := -1;
    lblMeters.Caption := '';
    lblMetersRelay.Visible := false;
    lblHeatNum.Caption := '';
    vimgHeatNum.ImageIndex := -1;
    vimgHeatStatus.ImageIndex := -1;
    exit;
  end
  else
  begin
    i := SCM.qryEvent.FieldByName('StrokeID').AsInteger;
    case i of
      0:
        vimgStrokeBug.ImageIndex := -1;
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
    end;
  end;


  // PAINT ICON BUGS - EVENT DISTANCE + EVENTYPE.
  if SCM.qryDistance.IsEmpty then
    i := 0
  else
    i := SCM.qryDistance.FieldByName('EventTypeID').AsInteger;
  case i of
    2:
    begin
      vimgRelayBug.ImageName := 'RELAY_DOT'; // RELAY.
      lblMetersRelay.Caption := UpperCase(SCM.qryDistance.FieldByName('Caption').AsString);
      lblMetersRelay.Visible := true;
      lblMeters.Caption := '';
    end;
  else
    begin
      vimgRelayBug.ImageIndex := -1; // INDV or Swim-O-Thon.
      lblMeters.Caption := UpperCase(SCM.qryDistance.FieldByName('Caption').AsString);
      lblMetersRelay.Visible := false;
    end;
  end;

    // PAINT ICON BUGS - HEAT NUMBER AND STATUS.
  if SCM.qryHeat.IsEmpty then
  begin
    lbl_scmGridOverlay.Visible := true;
    lbl_scmGridOverlay.Caption := 'No heats for the current event.';
    scmGrid.DataSource := nil;
    lblHeatNum.Caption := '';
    vimgHeatNum.ImageIndex := -1;
    vimgHeatStatus.ImageIndex := -1;
    exit;
  end
  else
  begin
    i := SCM.qryHeat.FieldByName('HeatNum').AsInteger;
    lblHeatNum.Caption := IntToStr(i);
    vimgHeatNum.ImageIndex := 14;

    i := SCM.qryHeat.FieldByName('HeatStatusID').AsInteger;
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

procedure TMain.MSG_UpdateUITDS(var Msg: TMessage);
var
i: integer;
s: string;
  J: integer;
  ActiveRT: scmActiveRT;
  ADataSet: TDataSet;

begin

  // UPDATE DESCRIPTION.
  // -----------------------------------------------------
  lblEventDetailsTD.caption := '';
  lbl_tdsGridOverlay.Caption := '';
  lbl_tdsGridOverlay.Visible := true;

  if not Assigned(TDS) then
  begin
    lbl_tdsGridOverlay.Caption := 'Failed to create ' + sLineBreak +
      'the TDS data module!';
    tdsGrid.DataSource := nil;
    pnlTool2.Visible := false;
    lblEventDetailsTD.Visible := false;
    exit;
  end;

  if TDS.DataIsActive = false then
  begin
    lbl_tdsGridOverlay.Caption := 'Data offline.';
    tdsGrid.DataSource := nil;
    pnlTool2.Visible := false;
    lblEventDetailsTD.Visible := false;
    exit;
  end;

  // ASSERT DATASOURCE.
  {TODO -oBSA -cGeneral : CHECK tdsGrid DataSource assignment. This should
  occur on TDS creation?}
  // -----------------------------------------------------
  if not Assigned(tdsGrid.DataSource) then
    tdsGrid.DataSource := TDS.dsmLane;
  // -----------------------------------------------------

  // most of the tools (currently) require both TD/SCM to be ready.
  pnlTool2.Visible := true;
  lblEventDetailsTD.Visible := true;

  if not fClearAndScan_Done then
  begin
    lbl_tdsGridOverlay.Caption := 'A scan of the ''meets''' + sLineBreak +
    'folder is needed...' + sLineBreak +
    'Perform a ''Scan Meets Folder''.';
  end
  else
  begin
    // ASSERT LABEL/PANEL STATE.
    lbl_tdsGridOverlay.Visible := false;
    lbl_tdsGridOverlay.Caption := '';
  end;

  s := 'Session : ';
  if TDS.tblmSession.IsEmpty then
    s := s +'EMPTY'
  else
  begin
    i := TDS.tblmSession.FieldByName('SessionNum').AsInteger;
    s := s + IntToStr(i);
    s := s + '  Event : ';
    if TDS.tblmEvent.IsEmpty then
      s := s + 'EMPTY'
    else
    begin
      i := TDS.tblmEvent.FieldByName('EventNum').AsInteger;
      s := s + IntToStr(i);
      s := s + ' - Heat : ';
      if TDS.tblmHeat.IsEmpty then
        s := s + 'EMPTY'
      else
      begin
        i := TDS.tblmHeat.FieldByName('HeatNum').AsInteger;
        s := s + IntToStr(i);
      end;
    end;
  end;
  lblEventDetailsTD.caption := s;


  if not tdsGrid.DataSource.DataSet.IsEmpty then
  begin
    // TDS.dsmHeat - AfterScroll event.
    // UI images in grid cells need to be re-assigned.
    tdsGrid.BeginUpdate;
    // improve code readability ...
    ADataSet := tdsGrid.DataSource.DataSet;

    // iterate AppData and assign a cell images if needed.
    // --------------------------------------------------
    for j := tdsGrid.FixedRows to (tdsGrid.RowCount-tdsGrid.FixedRows) do
    begin
      // SYNC TDS record to tdsGrid row.
      ADataSet.RecNo := j;

      // A C T I V E R T .
      ActiveRT := scmActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
      case ActiveRT of
        // A U T O M A T I C .
        artAutomatic:
        begin
          // Switch to the Auto-Calculated RaceTime.
          // RacetimeA was calculated when the DT file was first imported.
          TDS.SetActiveRT(ADataSet, artAutomatic);
          UpdateCellIcons(ADataSet, J, ActiveRT);
        end;

        // TIME DROPS AUTOMATIC RACETIME.
        artFinalTime:
        begin
          TDS.SetActiveRT(ADataSet, artFinalTime);
          UpdateCellIcons(ADataSet, J, ActiveRT);
        end;

        // M A N U A L .
        artManual:
        begin
          TDS.SetActiveRT(ADataSet, artManual);
          TDS.CalcRaceTimeM(ADataSet);
          UpdateCellIcons(ADataSet, J, ActiveRT);
        end;

        artUser:
        begin
          TDS.SetActiveRT(ADataSet, artUser);
          UpdateCellIcons(ADataSet, J, ActiveRT);
        end;

        artSplit:
        begin
          TDS.SetActiveRT(ADataSet, artSplit);
          UpdateCellIcons(ADataSet, J, ActiveRT);
        end;

        artPadTime:
        begin
          TDS.SetActiveRT(ADataSet, artPadTime);
          UpdateCellIcons(ADataSet, J, ActiveRT);
        end;

        artNone:
        begin
          TDS.SetActiveRT(ADataSet, artNone);
          UpdateCellIcons(ADataSet, J, ActiveRT);
        end;

      end;

    end;
    ADataSet.First;
    tdsGrid.EndUpdate;
  end;

  tdsGrid.ClearRowSelect;

end;

procedure TMain.OnFileChanged(Sender: TObject; const FileName: string; Action: DWORD);
var
  s, ActionDescription: string;
begin
  // Determine the type of action
  case Action of
    FILE_ACTION_ADDED: ActionDescription := 'File added';
    FILE_ACTION_REMOVED: ActionDescription := 'File removed';
    FILE_ACTION_MODIFIED: ActionDescription := 'File modified';
    FILE_ACTION_RENAMED_OLD_NAME: ActionDescription := 'File renamed (old name)';
    FILE_ACTION_RENAMED_NEW_NAME: ActionDescription := 'File renamed (new name)';
  else
    ActionDescription := 'Unknown action';
  end;

  // Handle the new file
  s := UpperCase(ExtractFileExt(FileName));

  if (s = '.JSON') then
  begin
    s := UpperCase(FileName);
    if s.Contains('SESSION') then
    begin
      ShowMessage(Format('The meets folder was modified: %s (%s)', [FileName, ActionDescription]));
      tdsGrid.BeginUpdate;
      tdResults.ProcessFile(FileName);
      tdsGrid.EndUpdate;
    end;
  end;
end;

procedure TMain.scmGridGetDisplText(Sender: TObject; ACol, ARow: Integer; var
  Value: string);
begin
  if not Assigned(SCM) then exit;
  if not SCM.DataIsActive then exit;

//  if not Assigned(SCM.scmConnection) then exit;
//  if not SCM.scmConnection.Connected then exit;
  if not Assigned(scmGrid.DataSource) then exit;

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

procedure TMain.tdsGridClickCell(Sender: TObject; ARow, ACol: Integer);
var
  Grid: TDBAdvGrid;
  ADataSet: TDataSet;
  s: string;
  ActiveRT: scmActiveRT;
  t: TTime;
  dlg: TUserRaceTime;
  mr: TModalResult;
begin
  Grid := Sender as TDBAdvGrid;
  ADataSet := Grid.DataSource.DataSet;

  if (ARow >= tdsGrid.FixedRows) then
  begin
    if ACol = tdsGrid.ColumnByName['RT'].Index then // RaceTime
    begin
      // C O L U M N   E N T E R   U S E R   R A C E T I M E  .
      // 2025/04/16 :: The ALT key isn't required.
      ActiveRT := scmActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
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
          try
            begin
              if (t = 0) then
                ADataSet.FieldByName('RaceTime').Clear
              else
                ADataSet.FieldByName('RaceTime').AsDateTime := t;
              ADataSet.FieldByName('RaceTimeUser').AsDateTime := t;
              ADataSet.Post;
            end;
          except on E: Exception do
            ADataSet.Cancel;
          end;
        end;
				dlg.Free;
				GridSelectCurrentTDSLane; // only works if nothing is selected.
				grid.EndUpdate;
			end;
    end;

    if ACol = tdsGrid.ColumnByName['ActiveRT'].Index then
    begin
      // C O L U M N   T O G G L E   A C T I V E - R T .
      grid.BeginUpdate;
      { ALT KEY is active :: Toggle tblEntrant.ActiveRT}
      if (GetKeyState(VK_MENU) < 0) then
        // toggle backwards
        ActiveRT := TDS.ToggleActiveRT(ADataSet, 1)
      else
        // toggle forward (default)
        ActiveRT := TDS.ToggleActiveRT(ADataSet);
      { Modifies tblEntrant: ActiveRT, RaceTime, imgActiveRT }
      TDS.SetActiveRT(ADataSet, ActiveRT);
      case ActiveRT of
        artAutomatic, artFinalTime:
        begin
          UpdateCellIcons(ADataSet, ARow, ActiveRT);
        end;
        artManual:
        begin
          // The RaceTime needs to be recalculated...
          TDS.CalcRaceTimeM(ADataSet);
          UpdateCellIcons(ADataSet, ARow, ActiveRT);
        end;
        artUser, artPadTime:
        begin
          UpdateCellIcons(ADataSet, ARow, ActiveRT);
        end;
        artSplit:
        begin
          // The RaceTime needs to be recalculated...
          TDS.CalcRTSplitTime(ADataSet);
          UpdateCellIcons(ADataSet, ARow, ActiveRT);
        end;
        artNone:
           UpdateCellIcons(ADataSet, ARow, ActiveRT);
      end;
      grid.EndUpdate;
    end;

    if (ACol = tdsGrid.ColumnByName['T1'].Index)
      or (ACol = tdsGrid.ColumnByName['T2'].Index)
        or (ACol = tdsGrid.ColumnByName['T3'].Index) then
    begin
      if ADataSet.FieldByName('LaneIsEmpty').AsBoolean then exit;
      ActiveRT := scmActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
      // Must be artmanual for the user to toggle watch-time state.
      if ActiveRT <> artManual then exit;
      // the ALT key is required to perform toggle.
      if (GetKeyState(VK_MENU) < 0) then
      begin
        s := tdsGrid.Columns[ACol].FieldName; // Time1, Time2, Time3
        // Can toggle an empty TimeKeeper's stopwatch time...
        if (ADataSet.FieldByName(s).IsNull) then exit;
        grid.BeginUpdate;
        // modify TimeKeeper's stopwatch state.
        // idx in [1..3]. Asserts : dtTimeKeeperMode = dtManual.
        {TODO -oBSA -cGeneral : Obtain an index either by using name suffix
          or peek at Tag value for ACol ?? - which ever is clearer and concise.
         TDS.ToggleWatchTime(ADataSet, (Acol - 1), ActiveRT);
          }
        TDS.ToggleWatchTime(ADataSet, tdsGrid.Columns[Acol].Tag, ActiveRT);
        UpdateCellIcons(ADataSet, ARow, ActiveRT);
        // The RaceTime needs to be recalculated...
        TDS.CalcRaceTimeM(ADataset);
        grid.EndUpdate;
      end;
    end;
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
  if not SCM.qrysession.Active then
    Caption := 'SwimClubMeet - Dolphin Timing. ' // error ...
  else
  begin
    s2 := 'SwimClubMeet';
    v := SCM.qrysession.FieldByName('SessionStart').AsVariant;
    if not VarIsNull(v) then
    begin
      dt := TDateTime(v);
      s2 := s2 + ' - Session: ' + DateToStr(dt);
    end;
    s := SCM.qrysession.FieldByName('Caption').AsString;
    if Length(s) > 0 then s2 := s2 + ' ' + s;
    Caption := s2;
  end;
end;

procedure TMain.UpdateCellIcons(ADataset: TDataSet; ARow: Integer; AActiveRT:
    scmActiveRT);
var
I, indx: integer;
s: string;
b, b2: boolean;
begin

  // SOURCE FOR GRID CELL IMAGES : AppData.vimglistDTCell.

  tdsGrid.BeginUpdate;
  // Clear out - point to cell icon
  indx := tdsGrid.ColumnByName['ActiveRT'].Index;
  tdsGrid.RemoveImageIdx(indx, ARow);

  case AActiveRT of
    artAutomatic:
    begin
      // Update watch time : cell's icon.  for I := 2 to 4 do
      for I := tdsGrid.ColumnByName['T1'].Index to tdsGrid.ColumnByName['T3'].Index do
      begin
        tdsGrid.RemoveImageIdx(I, ARow);
        s := tdsGrid.Columns[I].FieldName; // Time1, Time2, Time3
        if ADataSet.FieldByName(s).IsNull then
          continue
        else
        begin
          s := tdsGrid.Columns[I].Name + 'A'; // T1A, T2A, T3A
          b := ADataSet.FieldByName(s).AsBoolean;
          // Empty, zero or bad race-time - display CROSS in BOX.
          if (b = false) then
          begin
            tdsGrid.AddImageIdx(I, ARow, 5, TCellHAlign.haFull,
                TCellVAlign.vaFull);
          end;
          { watch-time 1 :
              If the time is valid but the deviation between min and mid_
              is not acceptable then ...
          }
          if (I = tdsGrid.ColumnByName['T1'].Index)  then
          begin
            s := 'TDev1';
            b2 := ADataSet.FieldByName(s).AsBoolean;
            // Unacceptable deviation - display DEV,CROSS in BOX.
            if (b = true) and (b2 = false) then
            begin
                tdsGrid.AddImageIdx(I, ARow, 10, TCellHAlign.haFull,
                  TCellVAlign.vaFull);
            end;
          end;
          { watch-time 3 :
              If the time is valid but the deviation between mid and max
              is not acceptable then ...
          }
          if (I = tdsGrid.ColumnByName['T3'].Index)  then
          begin
            s := 'TDev2';
            b2 := ADataSet.FieldByName(s).AsBoolean;
            // Unacceptable deviation - display DEV,CROSS in BOX.
            if (b = true) and (b2 = false) then
            begin
                tdsGrid.AddImageIdx(I, ARow, 10, TCellHAlign.haFull,
                  TCellVAlign.vaFull);
            end;
          end;
        end;
      end;
      tdsGrid.ColumnByFieldName['imgActiveRT'].Header := 'AUTO';

    end;

    artFinalTime:
    begin
      for I := tdsGrid.ColumnByName['T1'].Index to tdsGrid.ColumnByName['T3'].Index do
        tdsGrid.RemoveImageIdx(I, ARow);
      tdsGrid.ColumnByFieldName['imgActiveRT'].Header := 'FINALTIME';
    end;

    artManual:
    begin
      for I := tdsGrid.ColumnByName['T1'].Index to tdsGrid.ColumnByName['T3'].Index do
      begin
        tdsGrid.RemoveImageIdx(I, ARow);
        s := tdsGrid.Columns[I].FieldName; // Time1, Time2, Time3
        if ADataSet.FieldByName(s).IsNull then
          continue
        else
          begin
            s := tdsGrid.Columns[I].Name + 'M'; // T1M, T2M, T3M
            b := ADataSet.FieldByName(s).AsBoolean;
            // Empty, zero or illegal watch time - display CROSS in BOX.
            if (not b) then
            begin
                tdsGrid.AddImageIdx(I, ARow, 6, TCellHAlign.haFull,
                  TCellVAlign.vaFull);
            end;
          end;
      end;
      tdsGrid.ColumnByFieldName['imgActiveRT'].Header := 'MANUAL';
    end;

    artUser:
    begin
      for I := tdsGrid.ColumnByName['T1'].Index to tdsGrid.ColumnByName['T3'].Index do
      begin
        tdsGrid.RemoveImageIdx(i, ARow);
      end;
      tdsGrid.ColumnByFieldName['imgActiveRT'].Header := 'EDIT RT';
    end;

    artSplit:
    begin
      for I := tdsGrid.ColumnByName['T1'].Index to tdsGrid.ColumnByName['T3'].Index do
        tdsGrid.RemoveImageIdx(I, ARow);
      tdsGrid.ColumnByFieldName['imgActiveRT'].Header := 'SPLIT';
    end;

    artPadTime:
    begin
      for I := tdsGrid.ColumnByName['T1'].Index to tdsGrid.ColumnByName['T3'].Index do
        tdsGrid.RemoveImageIdx(I, ARow);
      tdsGrid.ColumnByFieldName['imgActiveRT'].Header := 'PADTIME';
    end;

    artNone:
    begin
      for I := tdsGrid.ColumnByName['T1'].Index to tdsGrid.ColumnByName['T3'].Index do
      begin
        tdsGrid.RemoveImageIdx(I, ARow);
        tdsGrid.AddImageIdx(I, ARow, 8, TCellHAlign.haFull,
            TCellVAlign.vaFull);
      tdsGrid.ColumnByFieldName['imgActiveRT'].Header := 'NONE';
      end;
    end;
  end;

  tdsGrid.EndUpdate;

end;







end.
