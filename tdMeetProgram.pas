unit tdMeetProgram;

interface

uses
  system.IOUtils,
  system.SysUtils, system.Types, system.UITypes, system.Classes,
  system.Variants, VCL.Controls, system.DateUtils,
  XSuperJSON, XSuperObject, dmAppData,
  FireDAC.Stan.Param, dmSCM;

function BuildAndSaveMeetProgram(AFileName: TFileName): boolean;

//var
  {TODO -oBSA -cGeneral : use persistent variable?}
  // RACE_NUMBER: integer = 0;

implementation

uses
  Math;

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

function BuildAndSaveMeetProgram(AFileName: TFileName): boolean;
var
  X: ISuperObject;
  AFormatSettings: TFormatSettings;
  dt: TDateTime;
  j, NumOfHeats, EventTypeID: Integer;
  SessObj, EventObj, RaceObj, LaneObj, PoolObj, swimmerObj: ISuperObject;
  genderStr: string;
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
    {
      My DB Model is structured...
        SwimClub-Session-Event-Heat-etc.
      It doesn't have...
        SwimClub-Meet-Session-Event-Heat-etc.
      Meets run on multi-days and contain multi-sessions!
      Sessions only run single days!
    }
    dt := DateOf(AppData.qrySession.FieldByName('SessionStart').AsDateTime);
    // Name of the meet as assigned by the user
    S['meetName'] := AppData.qrySession.FieldByName('Caption').AsString;
    // Data format version, must be 1
    I['meetProgramVersion'] := 1;
    // Date/Time the program was last updated, in ISO 8601 UTC format
    S['meetProgramDateTime'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now, AFormatSettings);
    // name of the team or organization hosting the meet
    S['meetHostTeamName'] := AppData.qrySwimClub.FieldByName('Caption').AsString;
    { Use Session start TDateTime.     }
    // First day of the meet, in ISO 8601 DAY ONLY format (e.g. "2023-07-31")
    S['meetStartDate'] := FormatDateTime('yyyy-mm-dd', dt, AFormatSettings);
    { DB ver 1.1.5.3 doesn't contain a SessionEndDate }
    // Last day of the meet, in ISO 8601 DAY ONLY format (e.g. "2023-07-31")
    S['meetEndDate'] := FormatDateTime('yyyy-mm-dd', dt, AFormatSettings);

    with A['meetEvents']do
    begin
      AppData.qryEvent.ApplyMaster;
      AppData.qryEvent.First;
      while not AppData.qryEvent.Eof do
      begin
        EventObj := SO();
        EventObj.S['eventId'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
        // number of the event, e.g. "3" or "4A"
        EventObj.S['eventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventNum').AsInteger);
        {
          1 -> Free 2 -> Back 3 -> Breast 4 -> Fly 5 -> Medley
          In my table dbo.Stroke - BS preceeds BK. Don't ask me why.
          j := AppData.qryEvent.FieldByName('StrokeID').AsInteger;
          I could switch - if (j = 3) then j := 4 else if (j = 4) then j:= 3;
        }
        // Stroke code
        EventObj.I['eventStrokeCode'] := AppData.qryEvent.FieldByName('StrokeID').AsInteger;
        {
          Freeform description of the stroke, can be used for localization.
          As I can localize my non-standard stroke identity - a switch statement
          isn't needed.
        }
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
        { M", "F", or "X" or any other category designation.
          TODO: call dtUtils.EventGender to obtain correct gender assignment. }

        genderStr := GetGenderTypeStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
        // Gender
        EventObj.S['eventGender'] := genderStr;
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
            RaceObj.S['raceEventId'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
            RaceObj.S['raceEventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventNum').AsInteger);
            {
              IMPORTANT: the race number defines the order of races at the meet
              irrespective of the event number and heat number
              therefore it is possible to have preliminaries and finals out of order
            }
            // Calculate a unique racenumber? (unique for this session only).
                j := AppData.qryEvent.FieldByName('EventNum').AsInteger * 100 +
                    AppData.qryHeat.FieldByName('HeatNum').AsInteger;
                RaceObj.I['raceNumber'] := j;

            {
            // Use persisent variable ... store in JSON init file?
            Inc(RACE_NUMBER);
            RaceObj.I['raceNumber'] := RACE_NUMBER;
            }

            { TODO JOIN dbo.HeatType on AppData.qryHeat for correct assignment.
              RaceObj.S['raceHeatType'] :=
              AppData.qryHeatType.FieldByName('Caption').AsString;   }
            // for Prelims, Finals, Swimoffs etc.
            RaceObj.S['raceHeatType'] := 'Prelims';
            //  HEAT IDENTIFICATION.
            RaceObj.I['raceHeatId'] := AppData.qryHeat.FieldByName('HeatID').AsInteger;
            { The order of heats can be changed by the user ..
              Using the heat number as ID will result in errors. }
            // NUMBER OF THE HEAT
            RaceObj.I['raceHeatNumber'] := AppData.qryHeat.FieldByName('HeatNum').AsInteger;
            RaceObj.I['raceTotalHeats'] := NumOfHeats;
            Add(RaceObj);

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
                  LaneObj.S['laneEventId'] := IntToStr(AppData.qryEvent.FieldByName('EventID').AsInteger);
                  LaneObj.S['laneEventNumber'] := IntToStr(AppData.qryEvent.FieldByName('EventNum').AsInteger);

                  {TODO: Convert TTB - TDataTime to fraction of seconds ...}
                  dt := TimeOf(AppData.qryINDV.FieldByName('TTB').AsDateTime);
                  // seed time in 1/100 of a second.
                  var seedTimeInCentiseconds: integer;
                  seedTimeInCentiseconds := MilliSecondOfTheDay(dt) div 10;
                  // Assign to laneSeedTime
                  LaneObj.I['laneSeedTime'] := seedTimeInCentiseconds;

                  (*
                  // In seconds + fraction of seconds - rounded to 1/100 of a second.
                  var totalSeconds: Double;
                  // Convert TTime to milliseconds.
                  totalSeconds := MilliSecondOfTheDay(dt) / 1000;
                  // Round to 1/100 of a second.
                  totalSeconds := RoundTo(totalSeconds, -2);
                  // Assign to laneSeedTime
                  LaneObj.F['laneSeedTime'] := totalSeconds;
                  *)

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
                  LaneObj.F['laneSeedTime'] := 0;
                  if not AppData.qryTEAM.FieldByName('MemberID').IsNull then
                    LaneObj.S['laneSwimmerId'] := IntToStr(AppData.qryTEAM.FieldByName('MemberID').AsInteger)
                  else
                    LaneObj.S['laneSwimmerId'] := '';
                  LaneObj.S['laneTeamId'] := IntToStr(AppData.qryTEAM.FieldByName('TeamID').AsInteger);
                  Add(LaneObj);
                  AppData.qryTEAM.Next;
                end;
              end;
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

    with A['meetSwimmer'] do
    begin
      // DISTINCT list of Entrants nominating to swim event(s)...
      AppData.qrySwimmer.Close;
      AppData.qrySwimmer.ParamByName('SESSIONID').AsInteger :=
        AppData.qrySession.FieldByName('SessionID').AsInteger;
      AppData.qrySwimmer.Prepare;
      AppData.qrySwimmer.Open;
      if AppData.qrySwimmer.Active then
      begin
        AppData.qrySwimmer.First;
        while not AppData.qrySwimmer.Eof do
        begin
          swimmerObj := SO();
          // unique id of each swimmer (not necessarily globally unique, but must be unique within the meet
          swimmerObj.I['swimmerId'] := AppData.qrySwimmer.FieldByName('swimmerId').AsInteger;
          // name of swimmer in the preferred order (first last or last, first)
          swimmerObj.S['swimmerName'] := AppData.qrySwimmer.FieldByName('swimmerName').AsString;
          swimmerObj.S['swimmerGender'] := AppData.qrySwimmer.FieldByName('swimmerGender').AsString;
          // per age up date
          swimmerObj.I['swimmerAge'] := AppData.qrySwimmer.FieldByName('swimmerAge').AsInteger;
          {TODO -oBSA -cGeneral : query team assignment}
          // What if swimmer is assigned to multi-teams?
          // references list of teams
          swimmerObj.S['swimmerTeamID'] := AppData.qrySwimmer.FieldByName('swimmerTeamID').AsString;
        end;
      end;
    end;

  end;
  X.SaveTo(AFileName);
  Result := True;
end;

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

  // A R R A Y S .. -----------------------------
  val meetEvents: List<Event>, // list of events for the entire meet (see class Event
  below)
  val meetSessions: List<Session>, // list of Sessions for the meet, must contain at least
  one active session, see class Session below
  val meetTeams: List<Team>, // list of teams participating in the meet see class Team
  below
  val meetSwimmers: List<Swimmer>, // list of swimmers participating in the meet, see class
  Swimmer below
  // --------------------------------------------

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

  // A R R A Y S .. -----------------------------
  val raceLanes: List<Lane>,
  // --------------------------------------------

  )

  @Keep
  data class Lane(
  val laneNumber: Int, // number of the lane, starting at 0 or 1 depending on the pool
  setup
  val isEmpty: Boolean, // lane is seeded empty, all other values should be null
  val laneEventNumber: String? = null, // for the purpose of combining events, each lane
  has it's own event number
  val laneSeedTime: Int? = null, // seed time in 1/100 of a second
  val laneSwimmerId: String? = null,
  // nullable type, will be null in relay events and have a value in individual events

  val laneRelayTeamName: String? = null,
  // used in relay events - something like "RSM A" - OR - just "A" and then combine with the team name/abbreviation

  val laneRelaySwimmerIds: List<String?>? = null,
  // for relay events - list of swimmers in this relay - null for individual events

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
