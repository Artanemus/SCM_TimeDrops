unit DirectoryWatcher;

interface
uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages,
  VCL.Dialogs;

type
  TFileChangedEvent = procedure(Sender: TObject; const FileName: string; Action: DWORD) of object;

  TDirectoryWatcher = class(TThread)
  private
    FDirectory: string;
    FNotifyHandle: THandle;
    FTerminateEvent: THandle;
    FBuffer: array[0..1023] of Byte;
    FOnFileChanged: TFileChangedEvent;
  protected
    procedure Execute; override;
    procedure DoDirectoryChange;
  public
    constructor Create(const Directory: string);
    destructor Destroy; override;
    procedure SignalTerminate; // Public method to signal the termination event
    property OnFileChanged: TFileChangedEvent read FOnFileChanged write FOnFileChanged;
  end;

  PFileNotifyInformation = ^TFileNotifyInformation;
  TFileNotifyInformation = record
    NextEntryOffset: DWORD;
    Action: DWORD;
    FileNameLength: DWORD;
    FileName: array[0..0] of WideChar;
  end;

  procedure StopWatcher(FDirectoryWatcher: TDirectoryWatcher);
  procedure StartWatcher(fDirectoryWatcher: TDirectoryWatcher; FOnFileChanged: TFileChangedEvent);

implementation

uses
  tdSetting, uAppUtils;

{ TDirectoryWatcher }

procedure StopWatcher(FDirectoryWatcher: TDirectoryWatcher);
begin
    if Assigned(FDirectoryWatcher) then
    begin
      try
        FDirectoryWatcher.Terminate;
        {  Problems terminating ... }
        // Signal the termination event...
        FDirectoryWatcher.SignalTerminate;
        FDirectoryWatcher.WaitFor;
      finally
        FreeAndNil(FDirectoryWatcher);
      end;
    end;
end;

procedure StartWatcher(fDirectoryWatcher: TDirectoryWatcher; FOnFileChanged: TFileChangedEvent);
var
watchFolder: string;
begin
  watchFolder := ExpandEnvVars('%SYSTEMDRIVE%\TimeDrops\Meets'); // default folder.
  if (not Assigned(fDirectoryWatcher)) then
  begin
    if Assigned(Settings) then
    begin
      if FileExists(Settings.MeetsFolder) then
        watchFolder := Settings.MeetsFolder;
    end;

    // restart file system watcher...
    try
      if DirectoryExists(watchFolder) then
      begin
        fDirectoryWatcher := TDirectoryWatcher.Create(watchFolder);
        fDirectoryWatcher.OnFileChanged := FOnFileChanged;
        fDirectoryWatcher.Start;
      end;
    except on E: Exception do
      FreeAndNil(fDirectoryWatcher);
    end;
  end;
end;

constructor TDirectoryWatcher.Create(const Directory: string);
begin
  inherited Create(True);
  FDirectory := Directory;

  FNotifyHandle := CreateFile(PChar(FDirectory), FILE_LIST_DIRECTORY,
    FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, nil, OPEN_EXISTING,
    FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED, 0);

  { Delphi defines several thread priority levels, such as tpIdle, tpLowest,
      tpLower, tpNormal, tpHigher, tpHighest and tpTimeCritical.
  }
  // Set the thread priority to lower
  Priority := tpNormal;
  // Create a manual-reset event
  FTerminateEvent := CreateEvent(nil, True, False, nil);
end;

destructor TDirectoryWatcher.Destroy;
begin
  CloseHandle(FNotifyHandle);
  CloseHandle(FTerminateEvent); // Close the event handle
  inherited Destroy;
end;

procedure TDirectoryWatcher.DoDirectoryChange;
var
  Info: PFileNotifyInformation;
  Offset: DWORD;
  FileName: string;
  Action: DWORD;
begin
  Info := PFileNotifyInformation(@FBuffer[0]);
  repeat
    Offset := Info.NextEntryOffset;
    SetLength(FileName, Info.FileNameLength div SizeOf(WideChar));
    Move(Info.FileName[0], FileName[1], Info.FileNameLength);
    FileName := FDirectory + '\' + FileName;
    Action := Info.Action; // Capture the action type

    // Handle the file change event (e.g., notify or process the file)
    if Assigned(FOnFileChanged) then
      FOnFileChanged(Self, FileName, Action); // Pass the action to the event

    Info := PFileNotifyInformation(PByte(Info) + Offset);
  until Offset = 0;
end;

procedure TDirectoryWatcher.Execute;
var
  BytesRead: DWORD;
  Overlapped: TOverlapped;
  WaitHandles: array[0..1] of THandle;
  WaitResult: DWORD;
begin
  ZeroMemory(@Overlapped, SizeOf(TOverlapped));
  WaitHandles[0] := FNotifyHandle;
  WaitHandles[1] := FTerminateEvent;

  while not Terminated do
  begin
    { Use specific notification filters to reduce the number of notifications.
        For example, if you only care about file creation, you can set the
        filter to FILE_NOTIFY_CHANGE_FILE_NAME.
    }

    {
    if ReadDirectoryChangesW(FNotifyHandle, @FBuffer, SizeOf(FBuffer), True,
      FILE_NOTIFY_CHANGE_FILE_NAME or FILE_NOTIFY_CHANGE_DIR_NAME or
      FILE_NOTIFY_CHANGE_ATTRIBUTES or FILE_NOTIFY_CHANGE_SIZE or
      FILE_NOTIFY_CHANGE_LAST_WRITE or FILE_NOTIFY_CHANGE_LAST_ACCESS or
      FILE_NOTIFY_CHANGE_CREATION or FILE_NOTIFY_CHANGE_SECURITY, @BytesRead,
      @Overlapped, nil) then
    }
    if ReadDirectoryChangesW(FNotifyHandle, @FBuffer, SizeOf(FBuffer), True,
      FILE_NOTIFY_CHANGE_FILE_NAME, @BytesRead, @Overlapped, nil) then
    begin
      WaitResult := WaitForMultipleObjects(2, @WaitHandles, False, INFINITE);
      if WaitResult = WAIT_OBJECT_0 then
      begin
          // Directory change detected .
          // ASSERT : if not Terminated then ?
          Synchronize(DoDirectoryChange);
      end
      else if WaitResult = WAIT_OBJECT_0 + 1 then
      begin
        // Terminate event signaled.
        Exit;
      end;
    end;
  end;
end;

procedure TDirectoryWatcher.SignalTerminate;
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
  SetEvent(FTerminateEvent);
end;

end.
