unit uAppUtils;

interface

uses dmAppData, vcl.ComCtrls, Math, System.Types, System.IOUtils,
  Windows, System.Classes, SCMDefines, System.StrUtils, SysUtils ;

function StripAlphaChars(const InputStr: string): string;
function ConverDateTimeToCentiSeconds(ADateTime:TDateTime): integer;
function ConvertCentiSecondsToDateTime(AHundredths: Integer): TDateTime;
function StripNonNumeric(const AStr: string): string;
procedure DeleteFilesWithWildcard(const APath, APattern: string);


type
  TAppUtils = record
  private
    type
      PTime = ^TTime;
    var
//      fSplits: array[0..9] of double;
//      fTimeKeepers: array[0..2] of double;
      fFileName: string; // Filename + EXTENSION. NO PATH.
//      fCreatedDT: TDateTime;
      fAcceptedDeviation: double;
      fCalcMode: integer; // 0 = DT Method. (Default) 1 = SCM Method.

    // --------------------------------------------
    { Routine to :
      - Extract Filename+Ext to dtUtils.fFileName. (EXCLUDES PATH)
      - load dtUtils.fStrList with TFilename.
      - store dtUtils.fFileType with dtFileType.
     }
//    function PrepareExtraction(const AFileName: TFileName): boolean;

    // --------------------------------------------

//    function ConvertSecondsStrToTime(ASecondsStr: string): TTime;

  public
    procedure PrepareTDData();
    procedure PopulateTDData(const ADirectory: string; pBar: TProgressBar);
//    procedure AppendTDData(const AFileName: string);
    function DirHasResultFiles(const ADirectory: string): boolean;

    class operator Initialize(out Dest: TAppUtils);
    class operator Finalize(var Dest: TAppUtils);

    property AcceptedDeviation: double read FAcceptedDeviation write FAcceptedDeviation;

  end;

// ---------------------------------------------------


implementation

uses System.Character, DateUtils, Data.DB, tdResults;

function StripNonNumeric(const AStr: string): string;
var
  Ch: Char;
begin
  Result := '';
  for Ch in AStr do
  begin
    if CharInSet(Ch, ['0'..'9']) then
      Result := Result + Ch;
  end;
end;


function ConvertCentiSecondsToDateTime(AHundredths: Integer): TDateTime;
var
  ms: Integer;
begin
  // Convert hundredths of a second to milliseconds
  ms := AHundredths * 10;

  // Create a TDateTime from the milliseconds since midnight
  Result := IncMilliSecond(0, ms);
end;


function StripAlphaChars(const InputStr: string): string;
var
  Achar: Char;
begin
  Result := '';
  for Achar in InputStr do
    if Achar.IsDigit then
      Result := Result + Achar;
end;


function ConverDateTimeToCentiSeconds(ADateTime:TDateTime): integer;
var
dt: TTime;
seedTimeInCentiseconds: integer;
begin
  dt := TimeOf(ADateTime);
  // seed time in 1/100 of a second.
  seedTimeInCentiseconds := MilliSecondOfTheDay(dt) div 10;
  // Assign to laneSeedTime
  result := seedTimeInCentiseconds;
end;


procedure DeleteFilesWithWildcard(const APath, APattern: string);
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


(*
function TAppUtils.ConvertSecondsStrToTime(ASecondsStr: string): TTime;
var
  TotalSeconds: Double;
  Hours, Minutes, Seconds, Milliseconds: Word;
begin
  Result := 0; // Initialize the result to zero

  // Check if the input string is empty
  if Trim(ASecondsStr) = '' then
    Exit;

  // Attempt to convert the string to a floating point value
  try
    TotalSeconds := StrToFloat(ASecondsStr);
  except
    // If an error occurs, return zero
    Exit;
  end;

  // Calculate the hours, minutes, seconds, and milliseconds components
  Hours := Trunc(TotalSeconds) div 3600;
  TotalSeconds := TotalSeconds - (Hours * 3600);
  Minutes := Trunc(TotalSeconds) div 60;
  TotalSeconds := TotalSeconds - (Minutes * 60);
  Seconds := Trunc(TotalSeconds);
  Milliseconds := Round(Frac(TotalSeconds) * 1000);

  // Encode the components back into a TTime value
  Result := EncodeTime(Hours, Minutes, Seconds, Milliseconds);
end;
*)

class operator TAppUtils.Finalize(var Dest: TAppUtils);
begin
end;

class operator TAppUtils.Initialize(out Dest: TAppUtils);
begin
  Dest.fFileName := '';
  Dest.fCalcMode := 0;
end;

function TAppUtils.DirHasResultFiles(const ADirectory: string): boolean;
var
  LList: TStringDynArray;
  LSearchOption: TSearchOption;
  fileMask: string;
  I: Integer;
begin
  fileMask := '*.JSON';
  result := false;
  // do not do recursive extract into subfolders
  LSearchOption := TSearchOption.soTopDirectoryOnly;
  try
    { For files use GetFiles method }
    LList := TDirectory.GetFiles(ADirectory, fileMask, LSearchOption);
    // TEST for Dolphin Timing files.
    if (Length(LList) > 0) then
    begin
      result := true;
      exit;
    end;
    for I := LOW(LList) to HIGH(LList) do
    begin
      if LList[I].Contains('Session') then
      begin
        result := true;
        exit;
      end;
    end;

  except
    { Catch the possible exceptions }
    MessageBox(0, PChar('Incorrect path or search mask'),
      PChar('Get file type of directory...'), MB_ICONERROR or MB_OK);
    exit;
  end;
end;


procedure TAppUtils.PrepareTDData();
begin

  // clear all data records ....
  AppData.tblmSession.EmptyDataSet;
  AppData.tblmEvent.EmptyDataSet;
  AppData.tblmHeat.EmptyDataSet;
  AppData.tblmLane.EmptyDataSet;
  AppData.tblmNoodle.EmptyDataSet;

  // re-establish Master Detail ...
  AppData.tblmEvent.MasterSource := AppData.dsmSession;
  AppData.tblmEvent.MasterFields := 'SessionID';
  AppData.tblmEvent.DetailFields := 'SessionID';
  AppData.tblmEvent.IndexFieldNames := 'SessionID';

  AppData.tblmHeat.MasterSource := AppData.dsmEvent;
  AppData.tblmHeat.MasterFields := 'EventID';
  AppData.tblmHeat.DetailFields := 'EventID';
  AppData.tblmHeat.IndexFieldNames := 'EventID';

  AppData.tblmLane.MasterSource := AppData.dsmHeat;
  AppData.tblmLane.MasterFields := 'HeatID';
  AppData.tblmLane.DetailFields := 'HeatID';
  AppData.tblmLane.IndexFieldNames := 'HeatID';

  AppData.tblmNoodle.MasterSource := AppData.dsmHeat;
  AppData.tblmNoodle.MasterFields := 'HeatID';
  AppData.tblmNoodle.DetailFields := 'HeatID';
  AppData.tblmNoodle.IndexFieldNames := 'HeatID';

end;

Procedure TAppUtils.PopulateTDData(const ADirectory: string; pBar: TProgressBar);
begin
  AppData.tblmSession.DisableControls;
  AppData.tblmEvent.DisableControls;
  AppData.tblmHeat.DisableControls;
  AppData.tblmLane.DisableControls;
  AppData.tblmNoodle.DisableControls;

  if Assigned(pBar) then pBar.Position := 0;

  // NOTE: ProcessDirectory will call - disabled/enabled Master-Detail.
  // Necessary to manually calculate Primary keys in each memory table.
  ProcessDirectory(ADirectory);

  AppData.tblmSession.First;
  AppData.tblmEvent.ApplyMaster;
  AppData.tblmEvent.First;
  AppData.tblmHeat.ApplyMaster;
  AppData.tblmHeat.First;

  AppData.tblmSession.EnableControls;
  AppData.tblmEvent.EnableControls;
  AppData.tblmHeat.EnableControls;
  AppData.tblmLane.EnableControls;
  AppData.tblmNoodle.EnableControls;

  end;

end.

