unit tdReConstruct;

interface

uses dmSCM, dmAppData, System.SysUtils, System.Classes, system.Hash,
DateUtils, variants, SCMDefines, Data.DB, tdSetting;

procedure ReConstructDO3(SessionID: integer);
procedure ReConstructDO4(SessionID: integer);
function Get3Digits(i: integer): string;
function Get4Digits(i: integer): string;

implementation

var
seed: integer = 1;

function ConvertTimeToSecondsStr(ATime: TTime): string;
var
  Hours, Minutes, Seconds, Milliseconds: Word;
  TotalSeconds: Double;
begin
  // Decode the TTime value into its components
  DecodeTime(ATime, Hours, Minutes, Seconds, Milliseconds);

  // Calculate the total number of seconds as a floating point value
  TotalSeconds := Hours * 3600 + Minutes * 60 + Seconds + Milliseconds / 1000.0;

  // Convert the floating point value to a string
  Result := FloatToStr(TotalSeconds);
end;

{
  function ConvertSecondsStrToTime(ASecondsStr: string): TTime;
  var
    TotalSeconds: Double;
    Hours, Minutes, Seconds, Milliseconds: Word;
  begin
    // Convert the string representation of seconds to a floating point value
    TotalSeconds := StrToFloat(ASecondsStr);

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
}


function GetStringListChecksum(sl: TStringList; hashLength: Integer = 8): string;
var
  fullHash: string;
begin
  // Generate the full SHA256 hash of the concatenated TStringList text
  fullHash := THashSHA2.GetHashString(sl.Text);

  // Truncate to the desired length if needed (e.g., first 8 characters for a short checksum)
  Result := Copy(fullHash, 1, hashLength);
end;

function GetEventType(aEventID: integer): scmEventType;
var
  v: variant;
  SQL: string;
begin
  result := etUnknown;
    if not AppData.qryEvent.IsEmpty then
    begin
      SQL := 'SELECT [EventTypeID] FROM [SwimClubMeet].[dbo].[Event] ' +
        'INNER JOIN Distance ON [Event].DistanceID = Distance.DistanceID ' +
        'WHERE EventID = :ID';
      v := SCM.scmConnection.ExecSQLScalar(SQL, [aEventID]);
      if VarIsNull(v) or VarIsEmpty(v) or (v = 0) then exit;
    end;
    case v of
      1: result := etINDV;
      2: result := etTEAM;
    end;
end;

function Get4Digits(i: integer): string;
var
  s: string;
begin
  // Step 2: Convert i to a string
  s := IntToStr(i);
  // Step 3: Pad with leading zeros if less than four characters
  while Length(s) < 4 do
    s := '0' + s;
  // Step 4: Trim to four characters if longer than four
  if Length(s) > 4 then
    s := Copy(s, Length(s) - 3, 4);
  // Return the result
  Result := s;
end;

function Get3Digits(i: integer): string;
var
s: string;
begin
    // Step 2: Convert i to a string
    s := IntToStr(i);
    // Step 3: Pad with leading zeros if less than three characters
    while Length(s) < 3 do
      s := '0' + s;
    // Step 4: Trim to three characters if longer than three
    if Length(s) > 3 then
      s := Copy(s, Length(s) - 2, 3);
  // Return the result
  Result := s;
end;

function CreateHash(sess, ev, ht: integer): string;
var
  combinedValue: Integer;
begin
  // Step 1: Combine sess, ev, and ht as integers
  combinedValue := sess * 1000000 + ev * 1000 + ht;
  // Step 2: Generate a seven-digit hex hash (mod a large prime to constrain size)
  combinedValue := combinedValue mod 9999999;
  // Step 3: Convert to a hexadecimal string, padded to ensure seven digits
  Result := UpperCase(IntToHex(combinedValue, 7));
end;

function GetGenderTypeStr(AEventID: integer): string;
var
  boysCount, girlsCount: Integer;
  SQL: string;
begin
  // Default result is 'X' (mixed genders)
  Result := 'X';

  // Ensure the query isn't empty
  if not AppData.qryEvent.IsEmpty then
  begin
    // Query to get boys count
    SQL := 'SELECT COUNT(*) FROM [SwimClubMeet].[dbo].[Event] ' +
           'INNER JOIN HeatIndividual ON [Event].EventID = HeatIndividual.EventID ' +
           'INNER JOIN Entrant ON [HeatIndividual].HeatID = Entrant.HeatID ' +
           'INNER JOIN Member ON [Entrant].MemberID = Member.MemberID ' +
           'WHERE [Event].EventID = :ID AND GenderID = 1';
    boysCount := SCM.scmConnection.ExecSQLScalar(SQL, [AEventID]);

    // Query to get girls count
    SQL := 'SELECT COUNT(*) FROM [SwimClubMeet].[dbo].[Event] ' +
           'INNER JOIN HeatIndividual ON [Event].EventID = HeatIndividual.EventID ' +
           'INNER JOIN Entrant ON [HeatIndividual].HeatID = Entrant.HeatID ' +
           'INNER JOIN Member ON [Entrant].MemberID = Member.MemberID ' +
           'WHERE [Event].EventID = :ID AND GenderID = 2';
    girlsCount := SCM.scmConnection.ExecSQLScalar(SQL, [AEventID]);

    // Determine the result based on counts
    if (boysCount > 0) and (girlsCount > 0) then
      Result := 'X'
    else if boysCount > 0 then
      Result := 'A'
    else if girlsCount > 0 then
      Result := 'B';
  end;
end;

procedure ReConstructLanes(sl: TStringList; adtFileType: dtFileType; ADataSet: TDataSet);
var
  laneValue: Variant;
  s, lane, dtstr: string;
  rt, rtk: TDateTime;
  fs: TFormatSettings;
  msec: integer;
begin
  if ADataSet.IsEmpty then exit;

  ADataSet.First;
  fs := TFormatSettings.Create;

  // Set the time format to nn:ss.zzz
  // NOTE: No swimming race runs 1+ hours. Hours are not used.
  fs.ShortTimeFormat := 'nn:ss.zzz';
  fs.TimeSeparator := ':';
  fs.DecimalSeparator := '.';

  while not ADataSet.Eof do
  begin
    // lane data
    laneValue := ADataSet.FieldByName('Lane').AsVariant;
    if not VarIsNull(laneValue) then
      lane := IntToStr(laneValue)
    else
      // SCM will always return a lane number.
      // SCM uses lane numbers 1 to TotalNumOfLanes in swimming pool
      // Safe to assign Dolphin Timing File with zero lane number.
      // Does indicates a error but this code line will never be reached.
      lane := '0'; // SAFE...

    case adtFileType of
      dtDO4: lane := 'Lane' + lane;
    end;

    rt := TimeOf(ADataSet.FieldByName('RaceTime').AsDateTime);

    if rt <> 0 then
    begin
      dtstr := ConvertTimeToSecondsStr(rt);
{
        // Use FormatDateTime to format the time string
        dtstr := FormatDateTime(fs.ShortTimeFormat, rt, fs);
        // Dolphin Timing time format is terse.
        // Remove leading zeros from the formatted time string
        if dtstr.StartsWith('00:') then
          dtstr := Copy(dtstr, 4, Length(dtstr) - 3) // Remove '00:'
        else if dtstr.StartsWith('0') then
          dtstr := Copy(dtstr, 2, Length(dtstr) - 1); // Remove '0'
}
{$IFDEF DEBUG}
      // construct some dummy times for timekeeper 2 and 3
      s := lane + ';' + dtstr + ';';
      msec := random(400);
      rtk := IncMilliSecond(rt,msec);
      dtstr := ConvertTimeToSecondsStr(rtk);
      s := s + dtstr + ';';
      msec := random(600);
      rtk := IncMilliSecond(rt,msec);
      dtstr := ConvertTimeToSecondsStr(rtk);
      s := s + dtstr;
{$ELSE}
      // indicates no time given by TimeKeepers 2 and 3.
      s := lane + ';' + dtstr + ';;';
{$ENDIF}
    end
    else
      // Dolphin Timing syntax -
      // indicates no time given by TimeKeepers 1, 2 and 3.
      s := lane + ';;;';

    sl.Add(s);
    ADataSet.Next;
  end;
end;

procedure ReConstructINDV(sl: TStringList; adtFileType: dtFileType);
begin
  ReConstructLanes(sl,adtFileType, AppData.qryINDV);
end;

procedure ReConstructTEAM(sl: TStringList; adtFileType: dtFileType);
begin
  ReConstructLanes(sl,adtFileType, AppData.qryTEAM);
end;

procedure ReConstructHeat(SessionID, eventNum: integer; gender: string;
   aEventType: scmEventType; sl: TStringList; adtFileType: dtFileType);
var
  HeatNum: integer;
  s, fn, id, sess, ev, ht, RoundStr: string;
  success: boolean;
begin
  if AppData.qryHeat.IsEmpty then exit;
  if adtFileType = dtUnknown then exit;

  // Dolphin Timing term 'Round' : defined as :
  //  A = ALL, P = Prelimary, F = Final.

  // NOTE: GENDER >> A=boys, B=girls, X=mixed. (Not used in ReConstructHeat)

  {
  SCM 'Round' : defined as :
    A = 1, 'All', 'A'   -  (for compatability)
    P = 2, 'Prelimary',  'P'
    Q = 3, 'QuaterFinal', 'Q'
    S = 4, 'SemiFinal', 'S'
    F = 5, 'Final', 'F"
  }
  {TODO -oBSA -cGeneral :
    DB version 1.1.5.4 will have table dbo.Round.
    Linked to dbo.Event on RoundID.
    RoundID := AppData.qryEvent.FieldByName('RoundID').AsInteger;
    SQLstr :=  'SELECT ABREV FROM SwimClubMeet.dbo.Round WHERE RoundID = :ID)';
    v :=  SCM.scmConnection.ExecScalar(SQLstr,[RoundID]);
    if not VarIsNull(v) then
    begin
      RoundStr := var.AsString;
    end;
  }
  // DEFAULT ASSIGNMENT (DBv1.1.5.3 doesn't have knowledge of param).
  RoundStr := 'A';

  // Assert the state of the local param 'seed' (int) ...
  if (seed > 999) or (seed = 0) then seed := 1;
  AppData.qryHeat.first;
  while not AppData.qryHeat.eof do
  begin
    sl.Clear; // ensures - only one heat per file.
    HeatNum := AppData.qryHeat.FieldByName('HeatNum').AsInteger;
    // first line - header.
    s := IntTostr(SessionID) + ';' + IntTostr(EventNum) + ';' + IntTostr(HeatNum) + ';' + gender;
    sl.Add(s);
    // body - lanes and timekeepers times.
    if aEventType = etINDV then
      ReConstructINDV(sl, adtFileType)
    else if aEventType = etTEAM then
      ReConstructTEAM(sl, adtFileType);
    // last line - footer. - checksum
    s := UpperCase(GetStringListChecksum(sl, 16));
    // ALT METHOD : THashSHA2.GetHashString(sl.Text, SHA256);
    sl.Add(s);
    if not sl.IsEmpty then
    begin
      success := true;
      // C o n s t r u c t   f i l e n a m e .
      // pad numbers with leading zeros.
      ht := Get3Digits(HeatNum);
      ev := Get3Digits(EventNum);
      sess := Get3Digits(SessionID);
      case adtFileType of
        dtUnknown:
          fn := '';
        dtDO3:
          begin
          id := CreateHash(SessionID, EventNum, HeatNum);
          fn := sess + '-' + ev + '-' + id + '.DO3';
          end;
        dtDO4:
        begin
          id := Get4Digits(seed);
          fn := sess + '-' + ev + '-' + ht + RoundStr + '-' + id + '.DO4';
        end;
      end;
      fn := IncludeTrailingPathDelimiter(Settings.ReConstruct) + fn;
      // trap for exception error.
      if fileExists(fn) then
        success := DeleteFile(fn);
      if success then
      begin
        sl.SaveToFile(fn);
        inc(seed); // calculate next seed number.
        if seed > 9999 then seed := 1; // check - out of bounds.
      end;
    end;
    AppData.qryHeat.Next
  end;
end;

procedure ReConstructEvent(SessionID: integer; sl: TStringList; adtFileType: dtFileType);
var
i, EventNum: integer;
gender: string;
aEventType: scmEventType;
begin
  if AppData.qryEvent.IsEmpty then exit;
  AppData.qryEvent.first;
  while not AppData.qryEvent.eof do
  begin
    EventNum := AppData.qryEvent.FieldByName('EventNum').AsInteger;
    i := AppData.qryEvent.FieldByName('EventID').AsInteger;
    // NOTE: scmEventType >> etUnknown, etINDV, etTEAM.
    aEventType := GetEventType(i);
    // NOTE: GENDER >> A=boys, B=girls, X=mixed.
    gender := GetGenderTypeStr(i);
    // R e - c o n s t r u c t   D O 4 .
    ReConstructHeat(SessionID, EventNum, gender, aEventType, sl, adtFileType);
    AppData.qryEvent.next;
  end;
end;

procedure ReConstructDO4(SessionID: integer);
var
sl: TStringList;
begin
  // Core AppData tables are Master-Detail schema.
  // qrySession is cued, ready to process.
  seed := 1;
  sl := TStringList.Create;
  ReConstructEvent(SessionID, sl, dtDO4);
  sl.Free;
end;

procedure ReConstructDO3(SessionID: integer);
var
sl: TStringList;
begin
  // Core AppData tables are Master-Detail schema.
  // qrySession is cued, ready to process.
  seed := 1;
  sl := TStringList.Create;
  ReConstructEvent(SessionID, sl, dtDO3);
  sl.Free;
end;



end.
