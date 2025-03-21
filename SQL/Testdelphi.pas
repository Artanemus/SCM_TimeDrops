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
