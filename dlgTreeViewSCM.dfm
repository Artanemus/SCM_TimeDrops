object TreeViewSCM: TTreeViewSCM
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'QUICK SELECT...'
  ClientHeight = 598
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  TextHeight = 21
  object TV: TTreeView
    Left = 0
    Top = 0
    Width = 492
    Height = 541
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    HideSelection = False
    Images = DTData.vimglistTreeView
    Indent = 30
    ParentFont = False
    ReadOnly = True
    RowSelect = True
    StateImages = DTData.vimglistStateImages
    TabOrder = 0
    OnDblClick = TVDblClick
    Items.NodeData = {
      070300000009540054007200650065004E006F00640065002D00000002000000
      0000000004000000FFFFFFFF0000000000000000000300000001074500760065
      006E0074002000310000002B000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFF000000000000000000010648006500610074002000310000002B000000
      0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000010648
      006500610074002000320000002B0000000000000000000000FFFFFFFFFFFFFF
      FF00000000000000000000000000010648006500610074002000330000002D00
      00000100000001000000FFFFFFFFFFFFFFFF0100000000000000000100000001
      074500760065006E0074002000320000002B000000FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF0000000000000000000106480065006100740020003100
      00002D0000000300000003000000FFFFFFFFFFFFFFFF03000000000000000000
      00000001074500760065006E00740020003300}
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 541
    Width = 492
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      492
      57)
    object btnClose: TButton
      Left = 392
      Top = 11
      Width = 100
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnCloseClick
    end
    object btnCancel: TButton
      Left = 286
      Top = 11
      Width = 100
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object qryEvent: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Connection = SCM.scmConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'DECLARE @SessionID int;'
      'SET @SessionID = :SESSIONID;'
      ''
      'SELECT [EventID]'
      '    , SUBSTRING(CONCAT ('
      '            '#39'Event '#39
      '            , [EventNum]'
      '            , '#39'  '#39
      '            , [Distance].[Caption]'
      '            , '#39' '#39
      '            , [Stroke].[Caption]'
      '            , '#39' '#39
      '            , [Event].[Caption]'
      '            ), 1, 50) AS [EventCaption]'
      '    , [EventNum]'
      '    --, [Event].[Caption]'
      '    , [SessionID]'
      '    --, [RallyOpenDT]'
      '    , [Event].[StrokeID]'
      '    --, [RallyCloseDT]'
      '    , [Event].[DistanceID]'
      '    --, [OpenDT]'
      '    , [EventStatusID]'
      '--, [CloseDT]'
      '--, [ScheduleDT]'
      '    , [Distance].[EventTypeID]'
      ''
      'FROM [SwimClubMeet].[dbo].[Event]'
      'INNER JOIN [SwimClubMeet].[dbo].[Stroke]'
      '    ON [Event].[StrokeID] = [Stroke].[StrokeID]'
      'INNER JOIN [SwimClubMeet].[dbo].[Distance]'
      '    ON [Event].[DistanceID] = [Distance].[DistanceID]'
      'WHERE SessionID = @SessionID'
      'ORDER BY [EventNum];')
    Left = 136
    Top = 248
    ParamData = <
      item
        Name = 'SESSIONID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 1
      end>
  end
  object qryHeat: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    IndexFieldNames = 'EventID'
    MasterSource = dsEvent
    MasterFields = 'EventID'
    DetailFields = 'EventID'
    Connection = SCM.scmConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    UpdateOptions.UpdateTableName = 'SwimClubMeet.dbo.HeatIndividual'
    SQL.Strings = (
      'SELECT [HeatID]'
      '    , [HeatNum]'
      '    , CONCAT ('
      '        [HeatType].[Caption]'
      '        , '#39' '#39
      '        , [HeatNum]'
      '        ) AS [HeatCaption]'
      '    --, [HeatIndividual].[Caption]'
      '    , [EventID]'
      '    --, [ScheduleDT]'
      '    --, [RallyOpenDT]'
      '    , [HeatIndividual].[HeatTypeID]'
      '    --, [RallyCloseDT]'
      '    , [HeatStatusID]'
      '--, [OpenDT]'
      '--, [CloseDT]'
      'FROM [SwimClubMeet].[dbo].[HeatIndividual]'
      'INNER JOIN [SwimClubMeet].[dbo].[HeatType]'
      '    ON [HeatIndividual].[HeatTypeID] = [HeatType].[HeatTypeID]'
      'ORDER BY [HeatNum] ASC')
    Left = 136
    Top = 320
  end
  object dsEvent: TDataSource
    DataSet = qryEvent
    Left = 224
    Top = 248
  end
  object dsHeat: TDataSource
    DataSet = qryHeat
    Left = 224
    Top = 320
  end
end
