unit tdReConstruct;

(*
  The results .json files will have the following content:
  {
    "createdAt": "2023-07-31T17:53:00.042-07:00",
    "protocolVersion": "1.1.0",
    "sessionNumber": 123, // from program
    "sessionId": "67251", // from program
    "eventNumber": "1",
    "heatNumber": 2,
    "raceNumber": 2,
    "startTime": "2023-07-31T17:52:11.234-07:00",

    "lanes": [
        {
          "lane": 1,
          // combination of the pad and button times. Meet Management program
          // may prefer to calculate this time themselves

          “finalTime”: 4883,
          "padTime": 4883, // only present when using pads
          "timer1": 4942, // in 1/100th of seconds
          "timer2": 4925,
          "timer3": 4904,
          "isEmpty": false, // lane declared empty by timing operator, may still have times in case of
          operator error
          "isDq": false, // for relay judging platform
          "splits": [
              {
              "distance": 25,
              "time": 1686
              }
          ]
        },
    //…… more lanes to follow
    ]

  }
*)



interface

uses dmSCM, dmAppData, System.SysUtils, System.Classes, system.Hash,
DateUtils, variants, SCMDefines, Data.DB, tdSetting, XSuperJSON, XSuperObject;

procedure ReConstructTD(SessionID: integer);

implementation

var
X: ISuperObject;
AFormatSettings: TFormatSettings;
raceNumber: integer;

function ConverDateTimeTo100thSeconds(ADateTime:TDateTime): integer;
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

procedure ReConstructLanes(ADataSet: TDataSet; aEventType: scmEventType);
var
  laneValue: Variant;
  s, lane, dtstr: string;
  rt, rtk: TDateTime;
  fs: TFormatSettings;
  msec: integer;
  raceObj, splitObj: ISuperObject;
  ID: integer;
begin
  if ADataSet.IsEmpty then exit;

  ADataSet.First;
  fs := TFormatSettings.Create;

  // Set the time format to nn:ss.zzz
  // NOTE: No swimming race runs 1+ hours. Hours are not used.
  fs.ShortTimeFormat := 'nn:ss.zzz';
  fs.TimeSeparator := ':';
  fs.DecimalSeparator := '.';
  with X.A['Lanes'] do
  begin
    while not ADataSet.Eof do
    begin
      RaceObj := SO();

      // lane data
      laneValue := ADataSet.FieldByName('Lane').AsVariant;
      if not VarIsNull(laneValue) then
        RaceObj.I['lane'] := laneValue
      else
        // SCM will always return a lane number.
        // SCM uses lane numbers 1 to TotalNumOfLanes in swimming pool
        // Safe to assign Dolphin Timing File with zero lane number.
        // Does indicates a error but this code line will never be reached.
        RaceObj.I['lane'] := 0; // SAFE...

      // in 1/100th of seconds

      RaceObj.I['finalTime'] := ConverDateTimeTo100thSeconds(ADataSet.FieldByName('RaceTime').AsDateTime);
      // only present when using pads
      // RaceObj.I['padTime'] :=
      RaceObj.I['timer1'] := ConverDateTimeTo100thSeconds(ADataSet.FieldByName('RaceTime').AsDateTime);
      // RaceObj.I['timer2'] :=
      // RaceObj.I['timer3'] :=

      if aEventType = etINDV then
        RaceObj.B['isEmpty'] := ADataSet.FieldByName('MemberID').IsNull
      else if aEventType = etTEAM then
        RaceObj.B['isEmpty'] := ADataSet.FieldByName('TeamID').IsNull;

      RaceObj.B['isDq'] := false;
      Add(RaceObj);

      {TODO -oBSA -cGeneral : Insert split data into superObject. }
      (*
      With RaceObj.A['Splits'] do
      begin
        AppData.qrySplit.Close;
        AppData.qrySplit.ParamByName('EVENTTYPEID').AsInteger := Ord(aEventType);
        if aEventType = etINDV then
        begin
          ID := AppData.qryINDV.FieldByName('EntrantID').AsInteger;
          AppData.qrySplit.ParamByName('ID').AsInteger := ID;
        end
        else if aEventType = etTEAM then
        begin
          ID := AppData.qryTEAM.FieldByName('TeamID').AsInteger;
          AppData.qrySplit.ParamByName('ID').AsInteger := ID;
        end;
        AppData.qrySplit.Prepare;
        AppData.qrySplit.Open;
        if AppData.qrySplit.Active then
        begin
          AppData.qrySplit.first;
          while not AppData.qrySplit.eof do
          begin
            splitObj := SO();
            splitObj.I['distance'] := 25;
            splitObj.I['time'] := ConverDateTimeTo100thSeconds(AppData.qrySplit.FieldByName('RaceTime').AsDateTime);
            Add(splitObj);
            AppData.qrySplit.next;
          end;
        end;
      end;
      *)


      ADataSet.Next;
    end;
  end;
end;


procedure ReConstructHeat(aEventType: scmEventType);
var
  HeatNum: integer;
  s, fn, id, sess, ev, ht, RoundStr: string;
  success: boolean;
begin
  AppData.qryHeat.ApplyMaster;
  if AppData.qryHeat.IsEmpty then exit;


  AppData.qryHeat.first;
  while not AppData.qryHeat.eof do
  begin
    X.I['heatID'] := AppData.qryHeat.FieldByName('HeatID').AsInteger;
    X.I['heatNumber'] := AppData.qryHeat.FieldByName('HeatNum').AsInteger;
    X.S['startTime'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now, AFormatSettings);
    Inc(raceNumber);
    X.I['raceNumber'] := raceNumber;

    // lanes and timekeepers times.
    if aEventType = etINDV then
    begin
      AppData.qryINDV.ApplyMaster;
      ReConstructLanes(AppData.qryINDV, aEventType);
    end
    else if aEventType = etTEAM then
    begin
      AppData.qryTEAM.ApplyMaster;
      ReConstructLanes(AppData.qryTEAM, aEventType);
    end;


    AppData.qryHeat.Next
  end;
end;

procedure ReConstructEvent(SessionID: integer);
var
i, EventNum: integer;
gender: string;
aEventType: scmEventType;
begin
  AppData.qryEvent.ApplyMaster;
  if AppData.qryEvent.IsEmpty then exit;
  AppData.qryEvent.first;
  while not AppData.qryEvent.eof do
  begin
    X.I['eventID'] := AppData.qryEvent.FieldByName('EventID').AsInteger;
    X.I['eventNumber'] := AppData.qryEvent.FieldByName('EventNum').AsInteger;
    // R e - c o n s t r u c t   H E A T .
    ReConstructHeat(aEventType);
    AppData.qryEvent.next;
  end;
end;

procedure ReConstructTD(SessionID: integer);
var
  dt: TDateTime;
  success: boolean;
  fn: TFileName;
begin
  // Date/Time in ISO 8601 UTC format
  AFormatSettings := TFormatSettings.Create;
  AFormatSettings.DateSeparator := '-';
  AFormatSettings.TimeSeparator := ':';
  AFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  AFormatSettings.LongTimeFormat := 'hh:nn:ss';
  // Core AppData tables are Master-Detail schema.
  // qrySession is cued, ready to process.
  raceNumber := 0;
  // Create the main SuperObject
  X := SO();
  X.S['type'] := 'Results';
  X.S['createdAt'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now, AFormatSettings);
  dt := DateOf(AppData.qrySession.FieldByName('SessionStart').AsDateTime);
  X.S['protocolVersion'] := '1.1.0';
  X.I['sessionNumber'] := AppData.qrySession.FieldByName('SessionID').AsInteger;
  ReConstructEvent(SessionID);

  // C o n s t r u c t   f i l e n a m e .
  (*
  SessionSSSS_Event_EEEE_HeatHHHH_RaceRRRR_XXX.json
  where SSSS is the session ID, EEEE the heat number, HHHH the heat number, RRRR the race
  number and XXXX the revision number
  T
  *)
  fn := '';
  fn := fn + 'Session'+ IntToStr(AppData.qrySession.FieldByName('SessionID').AsInteger);
  fn := fn + '_Event'+ IntToStr(AppData.qryEvent.FieldByName('EventNum').AsInteger);
  fn := fn + '_Heat' + IntToStr(AppData.qryHeat.FieldByName('HeatNum').AsInteger);
  fn := fn + '_Race' + IntToStr(raceNumber) + '.JSON';
  fn := IncludeTrailingPathDelimiter(Settings.ReConstruct) + fn;
  success := true;
  // trap for exception error.
  if fileExists(fn) then
    success := DeleteFile(fn);
  if success then
    X.SaveTo(fn);


end;





end.
