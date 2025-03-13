/*
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
*/
DECLARE @SessionID INT = 100; -- SessionID of the session to get swimmers for

SELECT DISTINCT
		 [Member].[MemberID] as swimmerId
		--,[MembershipNum]
		--,[MembershipStr]
		--,[FirstName]
		--,[MiddleInitial]
		--,[LastName]
        , CONCAT([FirstName], ' ', [LastName]) as swimmerName
        , Gender.Caption as swimmerGender
        , dbo.SwimmerAge(dbo.[Session].SessionStart, Member.DOB) as swimmerAge
        , '0' as swimmerTeamId
		--,[DOB]
		--,[RegisterNum]
		--,[IsArchived]
		--,[RegisterStr]
		--,[IsActive]
		--,[IsSwimmer]
		--,[Email]
		--,[EnableEmailOut]
		--,[Member].[GenderID]
		--,[Member].[SwimClubID]
		--,[CreatedOn]
		--,[ArchivedOn]
		--,[EnableEmailNomineeForm]
		--,[EnableEmailSessionReport]
		--,[HouseID]
		--,[TAGS]
FROM [SwimClubMeet].[dbo].[Member] 
LEFT JOIN [SwimClubMeet].[dbo].[Gender] ON [Member].[GenderID] = [Gender].[GenderID]
INNER JOIN dbo.Entrant ON Member.MemberID = Entrant.MemberID
INNER JOIN dbo.HeatIndividual ON Entrant.HeatID = HeatIndividual.HeatID
INNER JOIN dbo.Event ON HeatIndividual.EventID = Event.EventID
INNER JOIN dbo.[Session] ON Event.SessionID = [Session].SessionID
WHERE Entrant.MemberID IS NOT NULL AND Session.SessionID = @SessionID -- AND Member.IsActive = 1 AND Member.IsSwimmer = 1
ORDER BY [Member].[MemberID] ASC