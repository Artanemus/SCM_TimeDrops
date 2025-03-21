
/*
SELECT Count(HeatID) AS SplitCount
FROM SwimClubMeet.dbo.Entrant
INNER JOIN SwimClubMeet.dbo.Split ON Entrant.EntrantID = Split.EntrantID
WHERE Entrant.EntrantID = 100;

SELECT MAX(SplitTime) AS MaxSplitTime
FROM SwimClubMeet.dbo.Entrant
INNER JOIN SwimClubMeet.dbo.Split ON Entrant.EntrantID = Split.EntrantID
WHERE Entrant.EntrantID = 100;

SELECT Count(HeatID) AS SplitCount
FROM SwimClubMeet.dbo.Team
INNER JOIN SwimClubMeet.dbo.TeamSplit ON Team.TeamID = TeamSplit.TeamID
WHERE Team.TeamID = 100;
*/

SELECT MAX(SplitTime) AS SplitCount
FROM SwimClubMeet.dbo.Team
INNER JOIN SwimClubMeet.dbo.TeamSplit ON Team.TeamID = TeamSplit.TeamID
WHERE Team.TeamID = 100;


