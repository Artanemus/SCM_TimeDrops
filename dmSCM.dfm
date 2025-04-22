object SCM: TSCM
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 480
  Width = 640
  object tblSwimClub: TFDTable
    ActiveStoredUsage = [auDesignTime]
    TableName = 'SwimClubMeet.dbo.SwimClub'
    Left = 56
    Top = 160
  end
  object dsSwimClub: TDataSource
    DataSet = tblSwimClub
    Left = 152
    Top = 160
  end
  object qrySCMSystem: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    SQL.Strings = (
      'SELECT * FROM SCMSystem WHERE SCMSystemID = 1;')
    Left = 56
    Top = 224
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
end
