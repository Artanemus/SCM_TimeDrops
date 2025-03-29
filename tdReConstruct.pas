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
DateUtils, variants, SCMDefines, Data.DB, tdSetting, XSuperJSON, XSuperObject,
FireDAC.Stan.Param, dtTimingSystemStatus;

procedure ReConstructSession(SessionID: integer);

implementation

var
X: ISuperObject;
AFormatSettings: TFormatSettings;
raceNumber: integer;
laneObj: ISuperObject;


function SaveToTimeDropResultFile: boolean;
var
fn: TFileName;
begin
  result := false;
  (*
  SessionSSSS_Event_EEEE_HeatHHHH_RaceRRRR_XXX.json
  where SSSS is the session ID, EEEE the heat number, HHHH the heat number, RRRR the race
  number and XXXX the revision number
  T
  *)
  // C o n s t r u c t   f i l e n a m e .
  fn := '';
  fn := fn + 'Session'+ IntToStr(AppData.qrySession.FieldByName('SessionID').AsInteger);
  fn := fn + '_Event'+ IntToStr(AppData.qryEvent.FieldByName('EventNum').AsInteger);
  fn := fn + '_Heat' + IntToStr(AppData.qryHeat.FieldByName('HeatNum').AsInteger);
  fn := fn + '_Race' + IntToStr(raceNumber) + '.JSON';
  fn := IncludeTrailingPathDelimiter(Settings.ReConstruct) + fn;
  { In case the file already exists, the current file contents will be
  completely replaced with the new. If the named file cannot be created
  or opened, SaveToFile raises an EFCreateError exception}
  try
    begin
      X.SaveTo(fn);
      result := true;
    end;
  except on E: Exception do
  end;
end;

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

function GetMaxSplitTime(aID: integer; aEventType: scmEventType): TDateTime;
var
  v: variant;
  SQL: string;
begin
  result := 0;
  if aID = 0 then exit;
  SQL := '';
  case aEventType of
    etUnknown:
      exit;
    etINDV:
    begin
      if not AppData.qryINDV.IsEmpty then
        SQL := '''
        SELECT MAX(SplitTime) AS MaxSplitTime
        FROM SwimClubMeet.dbo.Entrant
        INNER JOIN SwimClubMeet.dbo.Split ON Entrant.EntrantID = Split.EntrantID
        WHERE Entrant.EntrantID = :ID;
        ''';
      end;
    etTEAM:
    begin
      if not AppData.qryTEAM.IsEmpty then
        SQL := '''
        SELECT MAX(SplitTime) AS MaxSplitTime
        FROM SwimClubMeet.dbo.Team
        INNER JOIN SwimClubMeet.dbo.TeamSplit ON Team.TeamID = TeamSplit.TeamID
        WHERE Team.TeamID = :ID;
        ''';
      end;
  end;
  if not SQL.IsEmpty then
  begin
    try
      v := SCM.scmConnection.ExecSQLScalar(SQL, [aID]);
      if VarIsNull(v) or VarIsEmpty(v) or (v = 0)  then
        exit; // No valid result found
      result := v; // Assign the result
    except
      on E: Exception do
      begin
        // Log or handle the exception as needed
        raise Exception.Create('Error retrieving MaxSplitTime: ' + E.Message);
      end;
    end;

  end
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
  laneValue, vtime: Variant;
  dt: TDateTime;
  fs: TFormatSettings;
  sec: integer;
  splitObj: ISuperObject;
  ID, LenOfPool, accDist: integer;
  laneIsEmpty: boolean;
begin
  if ADataSet.IsEmpty then exit;
  LenOfPool := AppData.qrySwimClub.FieldByName('LenOfPool').AsInteger;

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
      LaneObj := SO();

      // lane data
      laneValue := ADataSet.FieldByName('Lane').AsVariant;
      if not VarIsNull(laneValue) then
        LaneObj.I['lane'] := laneValue
      else
        // SCM will always return a lane number.
        // SCM uses lane numbers 1 to TotalNumOfLanes in swimming pool
        // Safe to assign Dolphin Timing File with zero lane number.
        // Does indicates a error but this code line will never be reached.
        LaneObj.I['lane'] := 0; // SAFE...

      laneIsEmpty := true;
      if aEventType = etINDV then
        laneIsEmpty := ADataSet.FieldByName('MemberID').IsNull
      else if aEventType = etTEAM then
        laneIsEmpty := ADataSet.FieldByName('TeamID').IsNull;

      if laneIsEmpty then
      begin
        LaneObj.B['isEmpty'] := true;
        LaneObj.Null['finalTime'] := jNull; // Assign JSON null if both are missing
        LaneObj.Null['padTime'] := jNull;
        LaneObj.Null['timer1'] := jNull;
        LaneObj.Null['timer2'] := jNull;
        LaneObj.Null['timer3'] := jNull;
      end
      else
      begin
        LaneObj.B['isEmpty'] := false;
        vtime := ADataSet.FieldByName('RaceTime').AsVariant;
        // P A D   T I M E  - S P L I T T I M E S .
        dt := 0;
        if aEventType = scmEventType.etINDV then
          dt := GetMaxSplitTime(ADataSet.FieldByName('EntrantID').AsInteger, aEventType);
        if aEventType = scmEventType.etTeam then
          dt := GetMaxSplitTime(ADataSet.FieldByName('TeamID').AsInteger, aEventType);
        // T I M E K E E P E R .
        // not timekeeper 'Time-Drop' given for swimmer in lane.
        if VarIsNull(vtime) or VarIsEmpty(vtime) then
        begin
          if dt<> 0 then
            // use padtime as final time
            LaneObj.I['finalTime'] := ConverDateTimeTo100thSeconds(dt)
          else
            LaneObj.Null['finalTime'] := jNull;

          LaneObj.Null['padTime'] := jNull;
          LaneObj.Null['timer1'] := jNull;
        end
        else
        begin
          // in 1/100th of seconds
          sec := ConverDateTimeTo100thSeconds(ADataSet.FieldByName('RaceTime').AsDateTime);
          // Settings : use padtime instead of racetime - else ...
          if Settings.CalcRTMethod = 3 then
            LaneObj.I['finalTime'] := ConverDateTimeTo100thSeconds(dt)
          else
            LaneObj.I['finalTime'] := sec;
          LaneObj.I['timer1'] := sec;
        end;
        // only present when using pads
        if (dt <> 0) then
          LaneObj.I['padTime'] := ConverDateTimeTo100thSeconds(dt)
        else
          LaneObj.Null['padTime'] := jNull;


{TODO -oBSA -cGeneral : Add additional debug information to 'Results' file.}
{$IFDEF DEBUG}
        // calculate a re-construction race-time for timekeeper 2 and 3
        LaneObj.Null['timer2'] := jNull;
        LaneObj.Null['timer3'] := jNull;
{$ELSE }
        // not used in re-construct...
        LaneObj.Null['timer2'] := jNull;
        LaneObj.Null['timer3'] := jNull;
{$ENDIF}


      end;

      LaneObj.B['isDq'] := false;  // for relay judging platform
      Add(LaneObj);



      // --- SPLITS --- (Simplified the logic slightly)
      With LaneObj.A['Splits'] do
      begin
          AppData.qrySplit.Close;
          AppData.qrySplit.ParamByName('EVENTTYPEID').AsInteger := Ord(aEventType);

          // Determine ID based on event type only if the lane is NOT empty
          ID := 0;
          if not laneIsEmpty then
          begin
              if aEventType = etINDV then
              begin
                  ID := ADataSet.FieldByName('EntrantID').AsInteger;
                  AppData.qrySplit.ParamByName('ID').AsInteger := ID;
              end
              else if aEventType = etTEAM then
              begin
                  ID := ADataSet.FieldByName('TeamID').AsInteger;
                  AppData.qrySplit.ParamByName('ID').AsInteger := ID;
              end;

              // Only query splits if we have a valid ID
              if ID > 0 then // Or whatever condition indicates a valid ID
              begin
                  AppData.qrySplit.Prepare; // Prepare only if needed
                  AppData.qrySplit.Open;
                  if AppData.qrySplit.Active and not AppData.qrySplit.IsEmpty then // Check if query returned rows
                  begin
                      accDist := 0; // Start accumulated distance at 0
                      AppData.qrySplit.First;
                      while not AppData.qrySplit.Eof do
                      begin
                          vtime := AppData.qrySplit.FieldByName('SplitTime').AsVariant;
                          // Process only if SplitTime is not null/empty/zero
                          if not (VarIsNull(vtime) or VarIsEmpty(vtime) or (VarIsType(vtime, varDate) and (TDateTime(vtime)=0))) then
                          begin
                              splitObj := SO();
                              accDist := accDist + LenOfPool; // Increment distance *before* adding
                              splitObj.I['distance'] := accDist;
                              splitObj.I['time'] := ConverDateTimeTo100thSeconds(TDateTime(vtime)); // Use the valid vtime
                              Add(splitObj); // Add to LaneObj.A['Splits']
                          end;
                          // Always move next, even if split time was invalid, to avoid infinite loop
                          AppData.qrySplit.Next;
                      end; // while not Eof
                  end; // if Active and not IsEmpty
              end; // if ID > 0
          end; // if not laneIsEmpty
      end; // With LaneObj.A['Splits']

      ADataSet.Next;
    end;
  end;
end;


procedure ReConstructHeat(aEventType: scmEventType);
var
dt: TDateTime;
begin
  AppData.qryHeat.ApplyMaster;
  if AppData.qryHeat.IsEmpty then exit;
  AppData.qryHeat.first;
  while not AppData.qryHeat.eof do
  begin

      // Create the main SuperObject
    X := SO();
    // SESSION DATA
    X.S['type'] := 'Results';
    X.S['createdAt'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now, AFormatSettings);
    X.S['protocolVersion'] := '1.1.0';
    X.I['sessionNumber'] := AppData.qrySession.FieldByName('SessionID').AsInteger;
    dt := AppData.qrySession.FieldByName('SessionStart').AsDateTime;
    X.S['startTime'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', dt, AFormatSettings);

    // EVENT DATA
    X.I['eventID'] := AppData.qryEvent.FieldByName('EventID').AsInteger;
    X.I['eventNumber'] := AppData.qryEvent.FieldByName('EventNum').AsInteger;

    // HEAT DATA
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
    // write out the TSuperObject to a JSON Time-Drops 'Results' file
    SaveToTimeDropResultFile;
    // write/update 'Timing System Status' }
    BuildAndSaveTimingSystemStatus(Settings.ReConstruct,
      AppData.qrySession.FieldByName('SessionID').AsInteger, X.I['heatNumber'],
      X.I['eventNumber']);

    AppData.qryHeat.Next
  end;
end;

procedure ReConstructEvent(SessionID: integer);
var
aEventType: scmEventType;
begin
  AppData.qryEvent.ApplyMaster;
  if AppData.qryEvent.IsEmpty then exit;
  AppData.qryEvent.first;
  while not AppData.qryEvent.eof do
  begin

    AppData.qryDistance.ApplyMaster;
    aEventType := scmEventType(AppData.qryDistance.FieldByName('EventTypeID').AsInteger);

    // R e - c o n s t r u c t   H E A T .
    ReConstructHeat(aEventType);
    AppData.qryEvent.next;
  end;
end;

procedure ReConstructSession(SessionID: integer);
var
  found: boolean;
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
  found := true;
  // check current session
  if AppData.qrySession.FieldByName('SessionID').AsInteger <> SessionID then
    found := AppData.LocateSCMSessionID(SessionID);

  if found then
  begin
    ReConstructEvent(SessionID);
  end;


end;





end.
