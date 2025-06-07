object SCM: TSCM
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 697
  Width = 721
  object qrySCMSystem: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    SQL.Strings = (
      'SELECT * FROM SCMSystem WHERE SCMSystemID = 1;')
    Left = 416
    Top = 24
  end
  object scmFDManager: TFDManager
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    ActiveStoredUsage = [auDesignTime]
    Active = True
    Left = 56
    Top = 24
  end
  object qrySession: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Active = True
    IndexFieldNames = 'SwimClubID'
    MasterSource = dsSwimClub
    MasterFields = 'SwimClubID'
    DetailFields = 'SwimClubID'
    Connection = TestFDConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'SELECT [SessionID]'
      '      ,[Caption]'
      '      ,[SessionStart]'
      '      ,[ClosedDT]'
      '      ,[SwimClubID]'
      '      ,[SessionStatusID]'
      '  FROM [SwimClubMeet].[dbo].[Session];')
    Left = 56
    Top = 272
  end
  object qryEvent: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Active = True
    IndexFieldNames = 'SessionID'
    MasterSource = dsSession
    MasterFields = 'SessionID'
    DetailFields = 'SessionID'
    Connection = TestFDConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      ''
      'SELECT [EventID]'
      '      ,[EventNum]'
      '      ,[Caption]'
      '      ,[SessionID]'
      '      ,[RallyOpenDT]'
      '      ,[StrokeID]'
      '      ,[RallyCloseDT]'
      '      ,[DistanceID]'
      '      ,[OpenDT]'
      '      ,[EventStatusID]'
      '      ,[CloseDT]'
      '      ,[ScheduleDT]'
      '  FROM [SwimClubMeet].[dbo].[Event]'
      '  ORDEr BY [EventNum]')
    Left = 88
    Top = 336
  end
  object qryHeat: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Active = True
    AfterScroll = qryHeatAfterScroll
    IndexFieldNames = 'EventID'
    MasterSource = dsEvent
    MasterFields = 'EventID'
    DetailFields = 'EventID'
    Connection = TestFDConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'SELECT [HeatID]'
      '      ,[HeatNum]'
      '      ,[Caption]'
      '      ,[EventID]'
      '      ,[ScheduleDT]'
      '      ,[RallyOpenDT]'
      '      ,[HeatTypeID]'
      '      ,[RallyCloseDT]'
      '      ,[HeatStatusID]'
      '      ,[OpenDT]'
      '      ,[CloseDT]'
      '  FROM [SwimClubMeet].[dbo].[HeatIndividual]'
      '')
    Left = 120
    Top = 400
  end
  object qryINDV: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Active = True
    IndexFieldNames = 'HeatID'
    MasterSource = dsHeat
    MasterFields = 'HeatID'
    DetailFields = 'HeatID'
    Connection = TestFDConnection
    FormatOptions.AssignedValues = [fvFmtDisplayTime]
    FormatOptions.FmtDisplayTime = 'nn:ss.zzz'
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert]
    SQL.Strings = (
      'SELECT [EntrantID]'
      '      ,[Entrant].[MemberID]'
      '      ,[Lane]'
      '      ,[RaceTime]'
      '      ,[TimeToBeat]'
      '      ,[PersonalBest]'
      '      ,[IsDisqualified]'
      '      ,[IsScratched]'
      '      ,[HeatID]'
      '      ,[DisqualifyCodeID]'
      '      ,CONCAT('
      '       [Member].[FirstName]'
      '       , '#39' '#39
      '       , UPPER([Member].[LastName])'
      '      ) AS FName'
      '      '
      '      ,0 AS imgPatch '
      '  FROM [SwimClubMeet].[dbo].[Entrant]'
      
        '  LEFT JOIN [Member] ON [Entrant].[MemberID] = [Member].[MemberI' +
        'D]'
      '  ORDER BY [Lane]')
    Left = 176
    Top = 464
  end
  object qryTEAM: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Active = True
    IndexFieldNames = 'HeatID'
    MasterSource = dsHeat
    MasterFields = 'HeatID'
    DetailFields = 'HeatID'
    Connection = TestFDConnection
    FormatOptions.AssignedValues = [fvFmtDisplayTime]
    FormatOptions.FmtDisplayTime = 'nn:ss.zzz'
    SQL.Strings = (
      'SELECT [TeamID]'
      '      ,[Lane]'
      '      ,[RaceTime]'
      '      ,[TimeToBeat]'
      '      ,[IsDisqualified]'
      '      ,[IsScratched]'
      '      ,[DisqualifyCodeID]'
      '      ,[HeatID]'
      '      ,[TeamNameID]'
      '  FROM [SwimClubMeet].[dbo].[Team]'
      '  ORDEr BY [Lane]')
    Left = 288
    Top = 464
  end
  object qryTEAMEntrant: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Active = True
    IndexFieldNames = 'TeamID'
    MasterSource = dsTEAM
    MasterFields = 'TeamID'
    DetailFields = 'TeamID'
    Connection = TestFDConnection
    SQL.Strings = (
      'SELECT [TeamEntrantID]'
      '      ,[MemberID]'
      '      ,[Lane]'
      '      ,[RaceTime]'
      '      ,[TimeToBeat]'
      '      ,[StrokeID]'
      '      ,[PersonalBest]'
      '      ,[TeamID]'
      '      ,[IsDisqualified]'
      '      ,[DisqualifyCodeID]'
      '      ,[IsScratched]'
      '  FROM [SwimClubMeet].[dbo].[TeamEntrant]'
      '  ORDEr BY [Lane]')
    Left = 368
    Top = 536
  end
  object dsSession: TDataSource
    DataSet = qrySession
    Left = 112
    Top = 272
  end
  object dsEvent: TDataSource
    DataSet = qryEvent
    Left = 144
    Top = 336
  end
  object dsHeat: TDataSource
    DataSet = qryHeat
    Left = 176
    Top = 400
  end
  object dsINDV: TDataSource
    DataSet = qryINDV
    Left = 232
    Top = 464
  end
  object dsTEAM: TDataSource
    DataSet = qryTEAM
    Left = 344
    Top = 464
  end
  object dsTEAMEntrant: TDataSource
    DataSet = qryTEAMEntrant
    Left = 464
    Top = 536
  end
  object qryNearestSessionID: TFDQuery
    SQL.Strings = (
      'DECLARE @LocateDate DATETIME = GETDATE();'
      'SET @LocateDate = :ADATE;'
      ''
      '-- Get nearest upcoming session'
      'WITH NearestUpcoming AS ('
      '    SELECT TOP 1'
      '        [SessionID]--,'
      '        --[Caption],'
      '        --[SessionStart],'
      '        --[ClosedDT],'
      '        --[SwimClubID],'
      '        --[SessionStatusID]'
      '    FROM '
      '        [dbo].[Session]'
      '    WHERE '
      '        [SessionStart] >= @LocateDate'
      '    ORDER BY '
      '        [SessionStart] ASC'
      '),'
      '-- Get most recent past session if no upcoming session is found'
      'MostRecentPast AS ('
      '    SELECT TOP 1'
      '        [SessionID]--,'
      '        --[Caption],'
      '        --[SessionStart],'
      '        --[ClosedDT],'
      '        --[SwimClubID],'
      '        --[SessionStatusID]'
      '    FROM '
      '        [dbo].[Session]'
      '    WHERE '
      '        [SessionStart] < @LocateDate'
      '    ORDER BY '
      '        [SessionStart] DESC'
      ')'
      '-- Combine both queries and return the nearest session'
      'SELECT * FROM NearestUpcoming'
      'UNION ALL'
      'SELECT * FROM MostRecentPast'
      'WHERE NOT EXISTS (SELECT 1 FROM NearestUpcoming);'
      ''
      '')
    Left = 520
    Top = 24
    ParamData = <
      item
        Name = 'ADATE'
        DataType = ftDateTime
        ParamType = ptInput
        Value = Null
      end>
  end
  object qryDistance: TFDQuery
    Active = True
    IndexFieldNames = 'DistanceID'
    MasterSource = dsEvent
    MasterFields = 'DistanceID'
    DetailFields = 'DistanceID'
    Connection = TestFDConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      '      SELECT [DistanceID]'
      '      ,[Caption]'
      '      ,[Meters]'
      '      ,[ABREV]'
      '      ,[EventTypeID]'
      '  FROM [dbo].[Distance]')
    Left = 232
    Top = 400
  end
  object qryStroke: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Active = True
    IndexFieldNames = 'StrokeID'
    MasterSource = dsEvent
    MasterFields = 'StrokeID'
    DetailFields = 'StrokeID'
    Connection = TestFDConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'SELECT [StrokeID]'
      '      ,[Caption]'
      '  FROM [dbo].[Stroke]'
      '')
    Left = 296
    Top = 400
  end
  object qryListSwimmers: TFDQuery
    SQL.Strings = (
      '/*'
      '  @Keep'
      '  data class Swimmer('
      
        '  val swimmerId: String?, // unique id of each swimmer (not nece' +
        'ssarily globally unique,'
      '  but must be unique within the meet'
      
        '  val swimmerName: String?, // name of swimmer in the preferred ' +
        'order (first last or last,'
      '  first)'
      '  val swimmerGender: String?,'
      '  val swimmerAge: Int?, // per age up date'
      '  val swimmerTeamId: String?, // references list of teams'
      '  )'
      '*/'
      
        'DECLARE @SessionID INT; -- SessionID of the session to get swimm' +
        'ers for'
      ''
      'SET @SessionID = :SESSIONID;'
      ''
      'SELECT DISTINCT'
      #9#9' [Member].[MemberID] as swimmerId'
      #9#9'--,[MembershipNum]'
      #9#9'--,[MembershipStr]'
      #9#9'--,[FirstName]'
      #9#9'--,[MiddleInitial]'
      #9#9'--,[LastName]'
      '        , CONCAT([FirstName], '#39' '#39', [LastName]) as swimmerName'
      '        , Gender.Caption as swimmerGender'
      
        '        , dbo.SwimmerAge(dbo.[Session].SessionStart, Member.DOB)' +
        ' as swimmerAge'
      '        , '#39'0'#39' as swimmerTeamId'
      #9#9'--,[DOB]'
      #9#9'--,[RegisterNum]'
      #9#9'--,[IsArchived]'
      #9#9'--,[RegisterStr]'
      #9#9'--,[IsActive]'
      #9#9'--,[IsSwimmer]'
      #9#9'--,[Email]'
      #9#9'--,[EnableEmailOut]'
      #9#9'--,[Member].[GenderID]'
      #9#9'--,[Member].[SwimClubID]'
      #9#9'--,[CreatedOn]'
      #9#9'--,[ArchivedOn]'
      #9#9'--,[EnableEmailNomineeForm]'
      #9#9'--,[EnableEmailSessionReport]'
      #9#9'--,[HouseID]'
      #9#9'--,[TAGS]'
      'FROM [SwimClubMeet].[dbo].[Member] '
      
        'LEFT JOIN [SwimClubMeet].[dbo].[Gender] ON [Member].[GenderID] =' +
        ' [Gender].[GenderID]'
      'INNER JOIN dbo.Entrant ON Member.MemberID = Entrant.MemberID'
      
        'INNER JOIN dbo.HeatIndividual ON Entrant.HeatID = HeatIndividual' +
        '.HeatID'
      'INNER JOIN dbo.Event ON HeatIndividual.EventID = Event.EventID'
      
        'INNER JOIN dbo.[Session] ON Event.SessionID = [Session].SessionI' +
        'D'
      
        'WHERE Entrant.MemberID IS NOT NULL AND Session.SessionID = @Sess' +
        'ionID -- AND Member.IsActive = 1 AND Member.IsSwimmer = 1'
      'ORDER BY [Member].[MemberID] ASC')
    Left = 528
    Top = 96
    ParamData = <
      item
        Name = 'SESSIONID'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
  object qrySplit: TFDQuery
    SQL.Strings = (
      'DECLARE @ID INT;'
      'DECLARE @EventTypeID INT;'
      ''
      'SET @ID = :ID;'
      'SET @EventTypeID = :EVENTTYPEID;'
      ''
      'IF @EventTypeID = 1'
      'BEGIN'
      'SELECT Split.SplitID,'
      '    SplitTime '
      'FROM SwimClubMeet.dbo.Entrant'
      'LEFT JOIN Split ON Entrant.EntrantID = Split.EntrantID'
      'WHERE Entrant.EntrantID = @ID'
      'ORDER BY SplitID ASC;'
      'END'
      ''
      'ELSE'
      'BEGIN'
      'SELECT TeamSplit.TeamSplitID,'
      '    SplitTime '
      'FROM SwimClubMeet.dbo.Team'
      'LEFT JOIN TeamSplit ON Team.TeamID = TeamSplit.TeamID'
      'WHERE Team.TeamID = @ID'
      'ORDER BY TeamSplitID ASC;'
      'END')
    Left = 608
    Top = 96
    ParamData = <
      item
        Name = 'ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 1
      end
      item
        Name = 'EVENTTYPEID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 1
      end>
  end
  object qryListTeams: TFDQuery
    SQL.Strings = (
      'DECLARE @SessionID INT;'
      'SET @SessionID = :SESSIONID;'
      ''
      'SELECT DISTINCT [TeamName].TeamNameID as teamID'
      ', TeamName.Caption as teamFullName '
      ', TeamName.CaptionShort as teamShortName'
      ', TeamName.ABREV as teamAbbreviation'
      ','#39#39' as teamMascot'
      ''
      'FROM [SwimClubMeet].[dbo].[TeamName] '
      
        'LEFT JOIN [dbo].[Team] ON [TeamName].[TeamNameID] = [Team].[Team' +
        'NameID]'
      
        'INNER JOIN dbo.HeatIndividual ON Team.HeatID = HeatIndividual.He' +
        'atID'
      'INNER JOIN dbo.Event ON HeatIndividual.EventID = Event.EventID'
      
        'INNER JOIN dbo.[Session] ON Event.SessionID = [Session].SessionI' +
        'D'
      
        'WHERE Team.TeamNameID IS NOT NULL AND Session.SessionID = @Sessi' +
        'onID '
      'ORDER BY [TeamName].[TeamNameID] ASC')
    Left = 416
    Top = 96
    ParamData = <
      item
        Name = 'SESSIONID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 0
      end>
  end
  object qrySwimClub: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Active = True
    IndexFieldNames = 'SwimClubID'
    DetailFields = 'SwimClubID'
    Connection = TestFDConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'SELECT [SwimClubID]'
      '      ,[NickName]'
      '      ,[Caption]'
      '      ,[Email]'
      '      ,[ContactNum]'
      '      ,[WebSite]'
      '      ,[HeatAlgorithm]'
      '      ,[EnableTeamEvents]'
      '      ,[EnableSwimOThon]'
      '      ,[EnableExtHeatTypes]'
      '      ,[EnableMembershipStr]'
      '      ,[EnableSimpleDisqualification]'
      '      ,[NumOfLanes]'
      '      ,[LenOfPool]'
      '      ,[StartOfSwimSeason]'
      '      ,[CreatedOn]'
      '      ,[LogoDir]'
      '      ,[LogoImg]'
      '      ,[LogoType]'
      '      ,[PoolTypeID]'
      '      ,[SwimClubTypeID]'
      '  FROM [dbo].[SwimClub]')
    Left = 48
    Top = 200
  end
  object dsSwimClub: TDataSource
    DataSet = qrySwimClub
    Left = 120
    Top = 200
  end
  object TestFDConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=MSSQL_SwimClubMeet')
    Connected = True
    LoginPrompt = False
    Left = 120
    Top = 112
  end
  object dsDistance: TDataSource
    DataSet = qryDistance
    Left = 416
    Top = 400
  end
end
