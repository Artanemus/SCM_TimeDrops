unit tdMeetProgram;

interface

uses
  system.IOUtils,
  system.SysUtils, system.Types, system.UITypes, system.Classes,
  system.Variants, VCL.Controls, system.DateUtils,
  XSuperJSON, XSuperObject, dmAppData;

function BuildAndSaveMeetProgram(AFileName: TFileName): boolean;

implementation

function BuildAndSaveMeetProgram(AFileName: TFileName): boolean;
var
  X: ISuperObject;
  AFormatSettings: TFormatSettings;
  dt: TDateTime;
  j, NumOfHeats, EventTypeID: Integer;
  SessObj, EventObj, RaceObj, LaneObj, PoolObj: ISuperObject;
begin
  AFormatSettings := TFormatSettings.Create;
  AFormatSettings.DateSeparator := '-';
  AFormatSettings.TimeSeparator := ':';
  AFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  AFormatSettings.LongTimeFormat := 'hh:nn:ss';

  // Create the main SuperObject
  X := SO();
  X.S['type'] := 'MeetProgramJson';

  with X.O['Meet'] {Auto Create} do
  begin
    dt := DateOf(AppData.qrySession.FieldByName('SessionStart').AsDateTime);
    // Name of the meet as assigned by the user
    S['meetName'] := AppData.qrySession.FieldByName('Caption').AsString;
    // Data format version, must be 1
    I['meetProgramVersion'] := 1;
    // Date/Time the program was last updated, in ISO 8601 UTC format
    S['meetProgramDateTime'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now, AFormatSettings);
    // name of the team or organization hosting the meet
    S['meetHostTeamName'] := AppData.qrySwimClub.FieldByName('Caption').AsString;
    // First day of the meet, in ISO 8601 DAY ONLY format (e.g. "2023-07-31")
    S['meetStartDate'] := FormatDateTime('yyyy-mm-dd', dt, AFormatSettings);
    // Last day of the meet, in ISO 8601 DAY ONLY format (e.g. "2023-07-31")
    S['meetEndDate'] := FormatDateTime('yyyy-mm-dd', dt, AFormatSettings);

    with A['meetEvents']do
    begin
      AppData.qryEvent.ApplyMaster;
      AppData.qryEvent.First;
      while not AppData.qryEvent.Eof do
      begin
        EventObj := SO();
        // number of the event, e.g. "3" or "4A"
        EventObj.S['eventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
        // Stroke code
        EventObj.I['eventStrokeCode'] := AppData.qryEvent.FieldByName('StrokeID').AsInteger;
        // Stroke description
        EventObj.S['eventStroke'] := AppData.qryStroke.FieldByName('Caption').AsString;
        // Relay or not
        if AppData.qryDistance.FieldByName('EventTypeID').AsInteger = 1 then
        begin
          EventObj.B['eventIsRelay'] := false;
          EventObj.I['eventRelaylegs'] := 0;
          EventObj.I['eventDistance'] := AppData.qryDistance.FieldByName('Meters').AsInteger;
        end
        else
        begin
          EventObj.B['eventIsRelay'] := true;
          EventObj.I['eventRelaylegs'] := 4;
          EventObj.I['eventDistance'] := AppData.qryDistance.FieldByName('Meters').AsInteger;
        end;
        // Gender
        EventObj.S['eventGender'] := 'X';
        // Ages
        EventObj.I['eventMinAge'] := 0;
        EventObj.I['eventMaxAge'] := 0;
        // Description
        EventObj.S['eventDescription'] := AppData.qryEvent.FieldByName('Caption').AsString;
        EventObj.S['eventShortLabel'] := '';
        EventObj.S['eventFullLabel'] := '';

        // Records
        with EventObj.A['eventRecords'].O[0] {Auto Create} do
        begin
          // Add record fields here if any
        end;
        // Standards
        with EventObj.A['eventStandards'].O[0] {Auto Create} do
        begin
          // Add standard fields here if any
        end;
        Add(EventObj);
        AppData.qryEvent.Next;
      end;
    end;

    // ONLY ONE SESSION -
    with A['meetSessions'] do
    begin
      SessObj := SO();
      SessObj.I['sessionNumber'] := 1;
      SessObj.S['sessionId'] := IntToStr(AppData.qrySession.FieldByName('SessionID').AsInteger);
      SessObj.S['sessionName'] := AppData.qrySession.FieldByName('Caption').AsString;
      dt := AppData.qrySession.FieldByName('SessionStart').AsDateTime;
      SessObj.S['sessionBeginAt'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', dt, AFormatSettings);
      // db v1.1.5.3 doesn't have field SessionEnd - Calculate a session end time.
      dt := IncHour(dt,2);
      SessObj.S['sessionEndAt'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', dt, AFormatSettings);
      SessObj.B['sessionIsCurrent'] :=  true;
      with SessObj.A['sessionRaces'] do
      begin
        AppData.qryEvent.First;
        while not AppData.qryEvent.Eof do
        begin
          AppData.qryDistance.ApplyMaster;
          EventTypeID := AppData.qryDistance.FieldByName('EventTypeID').AsInteger;
          AppData.qryHeat.ApplyMaster;
          AppData.qryHeat.Last;
          NumOfHeats := AppData.qryHeat.RecordCount;
          AppData.qryHeat.First;
          while not AppData.qryHeat.Eof do
          begin
            RaceObj := SO();
            RaceObj.S['raceEventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
            j := AppData.qryEvent.FieldByName('EventNum').AsInteger * 100 + AppData.qryHeat.FieldByName('HeatNum').AsInteger;
            RaceObj.I['raceNumber'] := j;
            RaceObj.S['raceHeatType'] := 'Prelims';
            // NUMBER OF THE HEAT - not dbo.HeatIndividual.HeatID
            RaceObj.I['raceHeatNumber'] := AppData.qryHeat.FieldByName('HeatNum').AsInteger;
            RaceObj.I['raceTotalHeats'] := NumOfHeats;

            with RaceObj.A['raceLanes'] do
            begin
              // Individual event
              if EventTypeID = 1 then
              begin
                AppData.qryINDV.ApplyMaster;
                AppData.qryINDV.First;
                while not AppData.qryINDV.Eof do
                begin
                  LaneObj := SO();
                  LaneObj.I['laneNumber'] := AppData.qryINDV.FieldByName('Lane').AsInteger;
                  LaneObj.B['isEmpty'] := AppData.qryINDV.FieldByName('MemberID').IsNull;
                  LaneObj.S['laneEventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
                  if not AppData.qryINDV.FieldByName('MemberID').IsNull then
                    LaneObj.S['laneSwimmerId'] := IntToStr(AppData.qryINDV.FieldByName('MemberID').AsInteger)
                  else
                    LaneObj.S['laneSwimmerId'] := '';
                  LaneObj.S['laneTeamId'] := '';
                  Add(LaneObj);
                  AppData.qryINDV.Next;
                end;
              end
              // Team event
              else if EventTypeID = 2 then
              begin
                AppData.qryTEAM.ApplyMaster;
                AppData.qryTEAM.First;
                while not AppData.qryTEAM.Eof do
                begin
                  LaneObj := SO();
                  LaneObj.I['laneNumber'] := AppData.qryTEAM.FieldByName('Lane').AsInteger;
                  LaneObj.B['isEmpty'] := AppData.qryTEAM.FieldByName('MemberID').IsNull;
                  LaneObj.S['laneEventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
                  if not AppData.qryTEAM.FieldByName('MemberID').IsNull then
                    LaneObj.S['laneSwimmerId'] := IntToStr(AppData.qryTEAM.FieldByName('MemberID').AsInteger)
                  else
                    LaneObj.S['laneSwimmerId'] := '';
                  LaneObj.S['laneTeamId'] := IntToStr(AppData.qryTEAM.FieldByName('TeamID').AsInteger);
                  Add(LaneObj);
                  AppData.qryTEAM.Next;
                end;
              end;
              Add(RaceObj);
            end;
            AppData.qryHeat.Next;
          end;
          AppData.qryEvent.Next;
        end;
        // specification for the pool this session is run in
        with SessObj.A['sessionPool'] do
        begin
          PoolObj := SO();
          PoolObj.I['poolNumberOfLanes'] := AppData.qrySwimClub.FieldByName('NumOfLanes').AsInteger;
          j := AppData.qrySwimClub.FieldByName('PoolTypeID').AsInteger;
          case j of
            1: PoolObj.S['poolCourse'] :=  'SCM';
            2: PoolObj.S['poolCourse'] :=  'LCM';
            3: PoolObj.S['poolCourse'] :=  'SCY';
            4: PoolObj.S['poolCourse'] :=  'LCY';
          end;
          PoolObj.I['poolFirstLaneNumber'] := 1;
          Add(PoolObj);
        end;
      end;
      Add(SessObj);
    end;

  end;
  X.SaveTo(AFileName);
  Result := True;
end;



{
function BuildAndSaveMeetProgram(AFileName: TFileName): boolean;
var
  X: ISuperObject;
  AFormatSettings: TFormatSettings;
  dt: TDateTime;
  j, NumOfHeats: Integer;
begin
  AFormatSettings := TFormatSettings.Create;
  AFormatSettings.DateSeparator := '-';
  AFormatSettings.TimeSeparator := ':';
  AFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  AFormatSettings.LongTimeFormat := 'hh:nn:ss';

  // Initialize as an empty SuperObject
  X := SO();
  // Set the type property
  X.S['type'] := 'MeetProgramJson';

  with X.A['Meet'].O[0]  do
  begin
    dt := DateOf(AppData.qrySession.FieldByName('SessionStart').AsDateTime);
    // Name of the meet as assigned by the user
    // S['meetName'] := DateToStr(dt);  // LOCALE_SSHORTDATE?
    // ALTERNATIVE - SESSION CAPTION.
    S['meetName'] := AppData.qrySession.FieldByName('Caption').AsString;
    // Data format version, must be 1
    I['meetProgramVersion'] := 1;
    // Date/Time the program was last updated, in ISO 8601 UTC format
    S['meetProgramDateTime'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now, AFormatSettings);
    // name of the team or organization hosting the meet
    S['meetHostTeamName'] := AppData.qrySwimClub.FieldByName('Caption').AsString;
    // First day of the meet, in ISO 8061 DAY ONLY format (e.g. "2023‐07‐31")
    S['meetStartDate'] := FormatDateTime('yyyy-mm-dd', dt, AFormatSettings);
    // Last day of the meet, in ISO 8061 DAY ONLY format (e.g. "2023‐07‐31")
    S['meetEndDate'] := FormatDateTime('yyyy-mm-dd', dt, AFormatSettings);

    with X.O['meetEvents'] do
    begin
      AppData.qryEvent.First;
      while not AppData.qryEvent.Eof do
      begin
        with X.A['Events'].o[0]  do
        begin
          // number of the event, e.g. "3" or "4A"
          S['eventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventNum').AsInteger);
          // 1 -> Free 2 -> Back 3 -> Breast 4 -> Fly 5 -> Medley
          // In my table dbo.Stroke - BS preceeds BK. Don't ask me why.
          //  j := AppData.qryEvent.FieldByName('StrokeID').AsInteger;
          //  if (j = 3) then j := 4 else if (j = 4) then j:= 3;

          I['eventStrokeCode'] := AppData.qryEvent.FieldByName('StrokeID').AsInteger;
          // Freeform description of the stroke, can be used for localization.
          // As I can localize my erronous stroke identity - it can be ignored.
          S['eventStroke'] := AppData.qryStroke.FieldByName('Caption').AsString;
          // true for relays
          if AppData.qryDistance.FieldByName('EventTypeID').AsInteger = 1 then
          begin
            B['eventIsRelay'] := false;
            // the number of swimmers in a relay, typically 4
            I['eventRelaylegs'] := 0;
            // in meter or yard depending on pool course. For relays, specify total distance,
            I['eventDistance'] := AppData.qryDistance.FieldByName('Meters').AsInteger;
          end
          else
          begin
            B['eventIsRelay'] := true;
            // the number of swimmers in a relay, typically 4
            I['eventRelaylegs'] := 4;
            // in meter or yard depending on pool course. For relays, specify total distance,
            I['eventDistance'] := AppData.qryDistance.FieldByName('Meters').AsInteger;
          end;
          // "M", "F", or "X" or any other category designation
          // TODO: call dtUtils.EventGender.
          S['eventGender'] := 'X';
          // minimum age for event, specify 0 for "&under" or open events
          I['eventMinAge'] := 0;
          // maximum age for event, specify 0 for "&over" or open events
          I['eventMaxAge'] := 0;
          // description is basically a duplication of all the previous information - might still be useful
          S['eventDescription'] := AppData.qryEvent.FieldByName('Caption').AsString;
          S['eventShortLabel'] := '';
          S['eventFullLabel'] := '';

          // list of records applicable to this event. can be empty
          with X.A['eventRecords'].o[0]   do
          begin

          end;
          // list of time standards applicable to this event. can be empty
          with X.A['eventStandards'].o[0]  do
          begin

          end;
        end;
        AppData.qryEvent.Next;
      end;
    end;


    // ONLY ONE SESSION -
    with X.A['meetSessions'].O[0]  do
    begin
      // number of the session within the meet
      I['sessionNumber'] := 1;
      // identifier of the session - results files will be tagged with this identifier
      S['sessionId'] := IntToStr(AppData.qrySession.FieldByName('SessionID').AsInteger);
      // name of the session, e.g. "Saturday Prelims" - required.
      S['sessionName'] := AppData.qrySession.FieldByName('Caption').AsString;
      // DateTime of the expected start of the session in ISO 8601 zoned time, e.g. "2023‐08‐01T05:32:29−07:00"
      S['sessionBeginAt'] := FormatDateTime('yyyy-mm-dd"T"', dt, AFormatSettings);
      // DateTime of the anticipated end of the session in ISO 8601 zoned time
      S['sessionEndAt'] := FormatDateTime('yyyy-mm-dd"T"', dt, AFormatSettings);

      with X.O['sessionRaces'] do
      begin
//        List<Race>, // List of Races scheduled for this session, see class Race below.
        AppData.qryEvent.First;
        while not AppData.qryEvent.Eof do
        begin
          AppData.qryHeat.Last;
          NumOfHeats := AppData.qryHeat.RecordCount;
          AppData.qryHeat.First;
          while not AppData.qryHeat.Eof do
            begin

              // Commonly called a heat - Race is slightly different as it defines
              //    the specific order of races in the program
              //  IMPORTANT: the race number defines the order of races at the
              //    meet irrespective of the event number and heat number ...
              //    therefore it is possible to have preliminaries and finals
              //    out of order

              with X.A['Race'].O[0] do
              begin
                S['raceEventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
                // race number as generated by the program - actual race number for
                // the results can be different due to false starts etc.
                // The List of races in the session should be
                // strictly monotonic with respect to the race number
                j := AppData.qryEvent.FieldByName('EventNum').AsInteger * 100;
                j := j + AppData.qryHeat.FieldByName('HeatNum').AsInteger;
                I['raceNumber'] := j;
                // for Prelims, Finals, Swimoffs etc.
                // TODO JOIN dbo.HeatType
                // S['raceHeatType'] := AppData.qryHeatType.FieldByName('Caption').AsString;
                S['raceHeatType'] := 'Prelims';
                // number of the heat
                I['raceHeatNumber'] := AppData.qryHeat.FieldByName('HeatID').AsInteger;
                // this is strictly for display, e.g. "Heat 1 of 3"
                I['raceTotalHeats'] := NumOfHeats;
                with X.O['raceLanes'] do
                begin
                  // I N D I V I D U A L   E V E N T .
                  if AppData.qryEvent.FieldByName('EventTypeID').AsInteger = 1 then
                  begin
                    while not AppData.qryINDV.Eof do
                    begin
                      with X.A['Race'].O[0] do
                      begin
                        // number of the lane, starting at 0 or 1 depending on the pool setup
                        I['laneNumber'] :=  AppData.qryINDV.FieldByName('Lane').AsInteger;
                        // lane is seeded empty, all other values should be null
                        if AppData.qryINDV.FieldByName('MemberID').IsNull then
                          B['isEmpty'] := true
                        else
                          B['isEmpty'] := false;
                        // for the purpose of combining events, each lane  has it's own event number
                        // SHOULDN'T THIS BE HEAT NUMBER ?
                        S['laneEventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
                        // seed time in 1/100 of a second.
                       // TODO: locate conversion tool
                       // I['laneSeedTime'] :=  CnvTimeToSeconds(TimeOf(AppData.qryINDV.FieldByName('TimeToBeat').AsDateTime));
                        // nullable type, will be null in relay events and have a value in individual events
                        if AppData.qryINDV.FieldByName('MemberID').IsNull then
                          S['laneSwimmerId'] := ''
                        else
                          S['laneSwimmerId'] := IntToStr(AppData.qryINDV.FieldByName('MemberID').AsInteger) ;
                        // used in relay events - something like "RSM A" - OR - just "A" and then combine with the team name/abbreviation
                        // TODO JOIN TEAM NAME ON ....
                        // S['laneRelayTeamName'] := AppData.qryTeamName.FieldByName('Caption').AsString;

                        // for relay events - list of swimmers in this relay - null for individual events
                        // TODO JOIN TEAM ENTRANT ON ....
                        with X.O['laneRelaySwimmerIds'] do
                        begin
                        // val X.O['laneRelaySwimmerIds'] := List<String?>? = null,
                        end;
                        // Team association of this entry
                        S['laneTeamId'] := '' ;
                      end;
                      AppData.qryINDV.Next;
                    end;
                  end;
                  // T E A M   E V E N T .
                  if AppData.qryEvent.FieldByName('EventTypeID').AsInteger = 2 then
                  begin
                    while not AppData.qryTEAM.Eof do
                    begin
                      with X.A['Race'].O[0] do
                      begin
                        // number of the lane, starting at 0 or 1 depending on the pool setup
                        I['laneNumber'] :=  AppData.qryTEAM.FieldByName('Lane').AsInteger;
                        // lane is seeded empty, all other values should be null
                        if AppData.qryTEAM.FieldByName('MemberID').IsNull then
                          B['isEmpty'] := true
                        else
                          B['isEmpty'] := false;
                        // for the purpose of combining events, each lane  has it's own event number
                        // SHOULDN'T THIS BE HEAT NUMBER ?
                        S['laneEventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
                        // seed time in 1/100 of a second.
                        // TODO: locate conversion tool
                        // I['laneSeedTime'] :=  CnvTimeToSeconds(TimeOf(AppData.qryTEAM.FieldByName('TimeToBeat').AsDateTime));
                        // nullable type, will be null in relay events and have a value in individual events
                        if AppData.qryTEAM.FieldByName('MemberID').IsNull then
                          S['laneSwimmerId'] := ''
                        else
                          S['laneSwimmerId'] := IntToStr(AppData.qryTEAM.FieldByName('MemberID').AsInteger) ;
                        // used in relay events - something like "RSM A" - OR - just "A" and then combine with the team name/abbreviation
                        // TODO JOIN TEAM NAME ON ....
                        // S['laneRelayTeamName'] := AppData.qryTeamName.FieldByName('Caption').AsString;

                        // for relay events - list of swimmers in this relay - null for individual events
                        // TODO JOIN TEAM ENTRANT ON ....
                        with X.O['laneRelaySwimmerIds'] do
                        begin
                        //val X.O['laneRelaySwimmerIds'] := List<String?>? = null,
                        end;
                        // Team association of this entry
                        S['laneTeamId'] := IntToStr(AppData.qryTEAM.FieldByName('TeamID').AsInteger) ;
                      end;
                      AppData.qryTEAM.Next;
                    end;
                  end;

                end;
              end;
              AppData.qryHeat.Next;
            end;
            AppData.qryEvent.Next;
          end;

      end;
      // specification for the pool this session is run in
      with X.O['sessionPool'] do
      begin
        with X.A['Pool'].O[0] do
        begin
          // number of lanes used for this meet
          I['poolNumberOfLanes'] := AppData.qrySwimClub.FieldByName('NumOfLanes').AsInteger;

          // LCM, SCM, or SCY
          //TODO - pull ABREV from table dbo.PoolType
          j := AppData.qrySwimClub.FieldByName('PoolTypeID').AsInteger;
          case j of
            1: S['poolCourse'] :=  'SCM';
            2: S['poolCourse'] :=  'LCM';
            3: S['poolCourse'] :=  'SCY';
            4: S['poolCourse'] :=  'LCY';
          end;
          // index of the fist lane, usually 0 or 1
          I['poolFirstLaneNumber'] := 1;
        end;
      end;
      // Each meet must have exactly one current session
      B['sessionIsCurrent'] :=  true;
    end;
  end;

  X.SaveTo(AFileName);

//  X.SaveTo('c:\TIMEDROPS\MEETS\TestSessionProgram.JSON');

end;





{
  X.S['name'] := 'Onur YILDIZ';
  X.B['vip'] := true;
  with X.A['telephones'] do
  begin
   Add('000000000');
   Add('111111111111');
  end;
  X.I['age'] := 24;
  X.F['size'] := 1.72;
  with X.A['adresses'].O[0]  do  // autocreate
  begin
    S['adress'] := 'blabla';
    S['city'] := 'Antalya';
    I['pc'] := 7160;
  end;
  // or
  X.A['adresses'].O[1].S['adress'] := 'blabla';
  X.A['adresses'].O[1].S['city'] := 'Adana';
  X.A['adresses'].O[1].I['pc'] := 1170;

}


{
@Keep
class MeetProgramJson {
@Keep
data class Meet(
val meetName: String, // Name of the meet as assigned by the user
val meetProgramVersion: Int = 1, // Data format version, must be 1
val meetProgramDateTime: String, // Date/Time the program was last updated, in ISO 8601
UTC format
val meetHostTeamName: String, // name of the team or organization hosting the meet
val meetStartDate: String, // First day of the meet, in ISO 8061 DAY ONLY format (e.g.
"2023‐07‐31")
val meetEndDate: String?, // Last day of the meet, in ISO 8061 DAY ONLY format (e.g.
"2023‐07‐31")
val meetEvents: List<Event>, // list of events for the entire meet (see class Event
below)
val meetSessions: List<Session>, // list of Sessions for the meet, must contain at least
one active session, see class Session below
val meetTeams: List<Team>, // list of teams participating in the meet see class Team
below
val meetSwimmers: List<Swimmer>, // list of swimmers participating in the meet, see class
Swimmer below
)
@Keep
data class Pool (
val poolNumberOfLanes: Int, // number of lanes used for this meet
val poolCourse: String, // LCM, SCM, or SCY
val poolFirstLaneNumber: Int, // index of the fist lane, usually 0 or 1
)
@Keep
data class Team (
val teamId: String, // unique identifier for the team
val teamAbbreviation: String, // 3-5 character abbreviation for the team (for display on
the scoreboard) - required
val teamShortName: String, // Short name of the team (required)
val teamFullName: String?, // Long name of the team (optional)
val teamMascot: String?, // team mascot, e.g. "Penguins", optional
)
@Keep
data class Session(
val sessionNumber: Int, // number of the session within the meet
val sessionId: String, // identifier of the session - results files will be tagged with
this identifier
val sessionName: String?, // name of the session, e.g. "Saturday Prelims" - required
val sessionBeginAt: String, // DateTime of the expected start of the session in ISO 8601
zoned time, e.g. "2023‐08‐01T05:32:29−07:00"
val sessionEndAt: String, // DateTime of the anticipated end of the session in ISO 8601
zoned time
val sessionRaces: List<Race>, // List of Races scheduled for this session, see class Race
below
val sessionPool: Pool, // specification for the pool this session is run in
val sessionIsCurrent: Boolean, // Each meet must have exactly one current session
)
@Keep
data class Event (
val eventNumber: String, // number of the event, e.g. "3" or "4A"
val eventStrokeCode: Int, // 1 -> Free 2 -> Back 3 -> Breast 4 -> Fly 5 -> Medley
val eventStroke: String?, // Freeform description of the stroke, can be used for
localization
val eventIsRelay: Boolean, // true for relays
val eventRelaylegs: Int?, // the number of swimmers in a relay, typically 4
val eventDistance: Int, // in meter or yard depending on pool course. For relays, specify
total distance,
val eventGender: String, // "M", "F", or "X" or any other category designation
val eventMinAge: Int, // minimum age for event, specify 0 for "&under" or open events
val eventMaxAge: Int, // maximum age for event, specify 0 for "&over" or open events
val eventDescription: String?, // description is basically a duplication of all the
previous information - might still be useful
val eventShortLabel: String?,
val eventFullLabel: String?,
val eventRecords: List<Record>, // list of records applicable to this event. can be empty
val eventStandards: List<Standard>, // list of time standards applicable to this event.
can be empty
)
@Keep
data class Record(
val recordCompletedDate: String?, // Date current record was set in ISO 8601 Date Only
format (e.g. "2012-03-16")
val recordSetName: String, // name of record, e.g. "Team Record"
val recordSetCode: String, // 1-character tag for the record, e.g. "T"
val recordTimeInt: Int, // all times are encoded in 1/100th of seconds,
val recordHolderName: String?,
val recordHolderTeam: String?,
val recordEligibleTeamIds: List<String>, // list of teams which are eligible for this
record
)
@Keep
data class StandardTier(
val tierName: String, // name of the tier, e.g. "Gold", "Silver", etc.
val tierCode: String, // 1-character tag for the standard on the Scoreboard, e.g. "G", S"
val tierTime: Int, // in 1/100 of a second
val tierEligibleTeamIds: List<String>,
)
@Keep
data class Standard(
val standardName: String, // name of the Standard, e.g. "Motivational"
val standardTiers: List<StandardTier>,
)
@Keep
data class Race( // commonly called a heat - Race is slightly different as it defines the
specific order of races in the program
// IMPORTANT: the race number defines the order of races at the meet irrespective of the
event number and heat number
// therefore it is possible to have preliminaries and finals out of order
val raceEventNumber: String?,
val raceNumber: Int, // race number as generated by the program - actual race number for
the results can be different due to false starts etc. The List of races in the session should be
strictly monotonic with respect to the race number
val raceHeatType: String, // for Prelims, Finals, Swimoffs etc.
val raceHeatNumber: Int, // number of the heat
val raceTotalHeats: Int, // this is strictly for display, e.g. "Heat 1 of 3"
val raceLanes: List<Lane>,
)
@Keep
data class Lane(
val laneNumber: Int, // number of the lane, starting at 0 or 1 depending on the pool
setup
val isEmpty: Boolean, // lane is seeded empty, all other values should be null
val laneEventNumber: String? = null, // for the purpose of combining events, each lane
has it's own event number
val laneSeedTime: Int? = null, // seed time in 1/100 of a second
val laneSwimmerId: String? = null, // nullable type, will be null in relay events and
have a value in individual events
val laneRelayTeamName: String? = null, // used in relay events - something like "RSM A" -
OR - just "A" and then combine with the team name/abbreviation
val laneRelaySwimmerIds: List<String?>? = null, // for relay events - list of swimmers in
this relay - null for individual events
val laneTeamId: String? = null, // Team association of this entry
)
@Keep
data class Swimmer(
val swimmerId: String?, // unique id of each swimmer (not necessarily globally unique,
but must be unique within the meet
val swimmerName: String?, // name of swimmer in the preferred order (first last or last,
first)
val swimmerGender: String?,
val swimmerAge: Int?, // per age up date
val swimmerTeamId: String?, // references list of teams
)
}





end.
