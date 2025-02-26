object SCM: TSCM
  Height = 480
  Width = 640
  object scmConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=MSSQL_SwimClubMeet')
    Connected = True
    LoginPrompt = False
    Left = 136
    Top = 24
  end
  object tblSwimClub: TFDTable
    ActiveStoredUsage = [auDesignTime]
    Connection = scmConnection
    TableName = 'SwimClubMeet.dbo.SwimClub'
    Left = 112
    Top = 96
  end
  object dsSwimClub: TDataSource
    DataSet = tblSwimClub
    Left = 208
    Top = 96
  end
  object qrySCMSystem: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Connection = scmConnection
    SQL.Strings = (
      'SELECT * FROM SCMSystem WHERE SCMSystemID = 1;')
    Left = 112
    Top = 160
  end
end
