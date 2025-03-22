
--USE SwimClubMeet;
--GO

DECLARE @EventID as INTEGER;
SET @EventID = 100;


SELECT MIN(dbo.SwimmerAge(SessionStart, [dbo].[Member].DOB)) AS Age
FROM [SwimClubMeet].[dbo].[Event]
    JOIN [Session] ON [Event].[SessionID] = [Session].[SessionID]
    JOIN SwimClub ON [Session].[SwimClubID] = SwimClub.SwimClubID
    INNER JOIN [dbo].[HeatIndividual] ON [Event].[EventID] = [HeatIndividual].[EventID]
    INNER JOIN [Entrant] ON [HeatIndividual].[HeatID] = [Entrant].[HeatID]
    INNER JOIN [dbo].[Member] ON [Entrant].[MemberID] = [Member].[MemberID]
WHERE [Event].[EventID] = @EventID;

/*
SELECT MAX(dbo.SwimmerAge(SessionStart, [dbo].[Member].DOB)) AS Age
FROM [SwimClubMeet].[dbo].[Event]
    JOIN [Session] ON [Event].[SessionID] = [Session].[SessionID]
    JOIN SwimClub ON [Session].[SwimClubID] = SwimClub.SwimClubID
    INNER JOIN [dbo].[HeatIndividual] ON [Event].[EventID] = [HeatIndividual].[EventID]
    INNER JOIN [Team] ON [HeatIndividual].[HeatID] = [Team].[HeatID]
    INNER JOIN [TeamEntrant] ON [Team].TeamID = [TeamEntrant].[TeamID]
    INNER JOIN [dbo].[Member] ON [TeamEntrant].[MemberID] = [Member].[MemberID]
WHERE [Event].[EventID] = @EventID;
*/