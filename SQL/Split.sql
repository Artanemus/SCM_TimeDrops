USE SwimClubMeet;

DECLARE @ID INT;
DECLARE @EventTypeID INT;

SET @ID = 89; --:ID;
SET @EventTypeID = 1; --:EVENTTYPEID;

IF @EventTypeID = 1
BEGIN
SELECT Split.SplitID,
    SplitTime 
FROM SwimClubMeet.dbo.Entrant
LEFT JOIN Split ON Entrant.EntrantID = Split.EntrantID
WHERE Entrant.EntrantID = @ID
ORDER BY SplitID ASC;
END

ELSE
BEGIN
SELECT TeamSplit.TeamSplitID,
    SplitTime 
FROM SwimClubMeet.dbo.Team
LEFT JOIN TeamSplit ON Team.TeamID = TeamSplit.TeamID
WHERE Team.TeamID = @ID
ORDER BY TeamSplitID ASC;
END