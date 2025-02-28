unit tdMeetPrg;

interface

uses XSuperJSON, XSuperObject, dmAppData, system.DateUtils;

implementation

// foo
var
  X: ISuperObject;
begin
  X := SO;

  with X.A['Meet'].O[0] {Auto Create} do
  begin
    S['meetName'] := AppData.tblmSession.FieldByName('SessionStart').AsString;
    I['meetProgramVersion'] := 1;
    S['meetProgramDateTime'] := FormatDateStr(Now);

    with X.A['meetSessions'].O[0] {Auto Create} do
    begin

    end;
    with X.A['meetEvents'].O[0] {Auto Create} do
    begin

    end;



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
