object ReportsSCM: TReportsSCM
  OnCreate = DataModuleCreate
  Height = 328
  Width = 310
  object frxReportSCM: TfrxReport
    Version = '6.6.11'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick, pbCopy, pbSelection]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 45786.562017835600000000
    ReportOptions.LastChange = 45786.562017835600000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 160
    Top = 24
    Datasets = <
      item
        DataSet = frxDBDistance
        DataSetName = 'frxDistance'
      end
      item
        DataSet = frxDBEvent
        DataSetName = 'frxEvent'
      end
      item
        DataSet = frxDBEventStatus
        DataSetName = 'frxEventStatus'
      end
      item
        DataSet = frxDBEventType
        DataSetName = 'frxEventType'
      end
      item
        DataSet = frxDBSession
        DataSetName = 'frxSession'
      end
      item
        DataSet = frxDBStroke
        DataSetName = 'frxStroke'
      end
      item
        DataSet = frxDBSwimClub
        DataSetName = 'frxSwimClub'
      end>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 215.900000000000000000
      PaperHeight = 279.400000000000000000
      PaperSize = 1
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
      Frame.Typ = []
      MirrorMode = []
      object PageHeader1: TfrxPageHeader
        FillType = ftBrush
        Frame.Typ = []
        Height = 43.500000000000000000
        Top = 18.897650000000000000
        Width = 740.409927000000000000
        object frxSwimClubCaption: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 76.000000000000000000
          Top = 15.500000000000000000
          Width = 242.630180000000000000
          Height = 18.897650000000000000
          DataField = 'NickName'
          DataSet = frxDBSwimClub
          DataSetName = 'frxSwimClub'
          Frame.Typ = []
          Memo.UTF8W = (
            '[frxSwimClub."NickName"]')
        end
        object frxSwimClubCaption1: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 75.500000000000000000
          Width = 242.630180000000000000
          Height = 18.897650000000000000
          DataField = 'Caption'
          DataSet = frxDBSwimClub
          DataSetName = 'frxSwimClub'
          Frame.Typ = []
          Memo.UTF8W = (
            '[frxSwimClub."Caption"]')
        end
        object frxSessionSessionStart: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 546.000000000000000000
          Width = 192.626160000000000000
          Height = 18.897650000000000000
          DataField = 'SessionStart'
          DataSet = frxDBSession
          DataSetName = 'frxSession'
          DisplayFormat.FormatStr = 'mmmm dd, yyyy'
          DisplayFormat.Kind = fkDateTime
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          HAlign = haRight
          Memo.UTF8W = (
            '[frxSession."SessionStart"]')
          ParentFont = False
        end
        object frxSessionSessionID: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 4.500000000000000000
          Width = 67.370130000000000000
          Height = 23.118120000000000000
          DataField = 'SessionID'
          DataSet = frxDBSession
          DataSetName = 'frxSession'
          DisplayFormat.FormatStr = '0000'
          DisplayFormat.Kind = fkNumeric
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -24
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          HAlign = haCenter
          Memo.UTF8W = (
            '[frxSession."SessionID"]')
          ParentFont = False
        end
        object Memo1: TfrxMemoView
          AllowVectorExport = True
          Left = 4.500000000000000000
          Top = 23.000000000000000000
          Width = 67.488250000000000000
          Height = 13.897650000000000000
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          HAlign = haCenter
          Memo.UTF8W = (
            'Session ID')
          ParentFont = False
          VAlign = vaCenter
        end
        object Line1: TfrxLineView
          Align = baCenter
          AllowVectorExport = True
          Left = -0.295036500000000000
          Top = 42.500000000000000000
          Width = 741.000000000000000000
          Color = clBlack
          Frame.Typ = [ftTop]
          Frame.Width = 2.000000000000000000
        end
        object Memo9: TfrxMemoView
          AllowVectorExport = True
          Left = 316.710838500000000000
          Top = 10.102350000000000000
          Width = 106.988250000000000000
          Height = 18.897650000000000000
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          Frame.Typ = []
          HAlign = haCenter
          Memo.UTF8W = (
            'Event Report')
          ParentFont = False
        end
      end
      object GroupHeader1: TfrxGroupHeader
        FillType = ftBrush
        Fill.BackColor = 15461355
        Frame.Typ = []
        Height = 28.736240000000000000
        Top = 124.724490000000000000
        Width = 740.409927000000000000
        Condition = 'frxEvent."SessionID"'
        object Memo2: TfrxMemoView
          AllowVectorExport = True
          Left = 2.500000000000000000
          Width = 74.988250000000000000
          Height = 24.397650000000000000
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          HAlign = haCenter
          Memo.UTF8W = (
            'Event '
            'Number')
          ParentFont = False
        end
        object Memo3: TfrxMemoView
          AllowVectorExport = True
          Left = 270.500000000000000000
          Top = 5.161410000000000000
          Width = 193.488250000000000000
          Height = 14.397650000000000000
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          Memo.UTF8W = (
            'Event Description')
          ParentFont = False
        end
        object Memo4: TfrxMemoView
          AllowVectorExport = True
          Left = 540.000000000000000000
          Top = 3.936920000000000000
          Width = 64.488250000000000000
          Height = 18.897650000000000000
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          Memo.UTF8W = (
            'Status')
          ParentFont = False
        end
        object Memo5: TfrxMemoView
          AllowVectorExport = True
          Left = 606.000000000000000000
          Top = 3.936920000000000000
          Width = 64.488250000000000000
          Height = 18.897650000000000000
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          Memo.UTF8W = (
            'Event Type')
          ParentFont = False
        end
        object Memo6: TfrxMemoView
          AllowVectorExport = True
          Left = 672.500000000000000000
          Top = 3.936920000000000000
          Width = 64.488250000000000000
          Height = 18.897650000000000000
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          Memo.UTF8W = (
            'Scheduled')
          ParentFont = False
        end
        object Memo7: TfrxMemoView
          AllowVectorExport = True
          Left = 137.000000000000000000
          Top = 4.936920000000000000
          Width = 64.488250000000000000
          Height = 18.897650000000000000
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          Memo.UTF8W = (
            'Stroke')
          ParentFont = False
        end
        object Memo8: TfrxMemoView
          AllowVectorExport = True
          Left = 79.000000000000000000
          Top = 4.936920000000000000
          Width = 64.488250000000000000
          Height = 18.897650000000000000
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          Memo.UTF8W = (
            'Dist.')
          ParentFont = False
        end
        object Line2: TfrxLineView
          Align = baBottom
          AllowVectorExport = True
          Left = -0.295036500000000000
          Top = 28.736240000000000000
          Width = 741.000000000000000000
          Color = clBlack
          Frame.Typ = [ftTop]
          Frame.Width = 2.000000000000000000
        end
      end
      object MasterData1: TfrxMasterData
        FillType = ftBrush
        Frame.Typ = []
        Height = 22.677180000000000000
        Top = 177.637910000000000000
        Width = 740.409927000000000000
        DataSet = frxDBEvent
        DataSetName = 'frxEvent'
        RowCount = 0
        object frxEventEventNum: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 2.500000000000000000
          Top = 2.539270000000000000
          Width = 75.370130000000000000
          Height = 18.897650000000000000
          DataField = 'EventNum'
          DataSet = frxDBEvent
          DataSetName = 'frxEvent'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          Frame.Typ = []
          HAlign = haCenter
          Memo.UTF8W = (
            '[frxEvent."EventNum"]')
          ParentFont = False
        end
        object frxEventCaption: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 268.000000000000000000
          Top = 2.039270000000000000
          Width = 269.630180000000000000
          Height = 18.897650000000000000
          DataField = 'Caption'
          DataSet = frxDBEvent
          DataSetName = 'frxEvent'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          Memo.UTF8W = (
            '[frxEvent."Caption"]')
          ParentFont = False
        end
        object frxDistanceCaption: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 79.000000000000000000
          Top = 2.539270000000000000
          Width = 56.630180000000000000
          Height = 18.897650000000000000
          DataField = 'Caption'
          DataSet = frxDBDistance
          DataSetName = 'frxDistance'
          Frame.Typ = []
          Memo.UTF8W = (
            '[frxDistance."Caption"]')
        end
        object frxStrokeCaption: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 137.000000000000000000
          Top = 2.039270000000000000
          Width = 130.130180000000000000
          Height = 18.897650000000000000
          DataField = 'Caption'
          DataSet = frxDBStroke
          DataSetName = 'frxStroke'
          Frame.Typ = []
          Memo.UTF8W = (
            '[frxStroke."Caption"]')
        end
        object frxEventTypeCaption: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 605.000000000000000000
          Top = 1.141620000000000000
          Width = 65.130180000000000000
          Height = 18.897650000000000000
          DataField = 'Caption'
          DataSet = frxDBEventType
          DataSetName = 'frxEventType'
          Frame.Typ = []
          Memo.UTF8W = (
            '[frxEventType."Caption"]')
        end
        object frxEventStatusCaption: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 540.000000000000000000
          Top = 1.141620000000000000
          Width = 63.130180000000000000
          Height = 18.897650000000000000
          DataField = 'Caption'
          DataSet = frxDBEventStatus
          DataSetName = 'frxEventStatus'
          Frame.Typ = []
          Memo.UTF8W = (
            '[frxEventStatus."Caption"]')
        end
      end
      object PageFooter1: TfrxPageFooter
        FillType = ftBrush
        Frame.Typ = []
        Height = 22.677180000000000000
        Top = 260.787570000000000000
        Width = 740.409927000000000000
        object Date: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 2.500000000000000000
          Top = 0.491960000000000000
          Width = 135.870130000000000000
          Height = 18.897650000000000000
          Frame.Typ = []
          Memo.UTF8W = (
            'Printed on: [Date]')
        end
      end
    end
  end
  object frxDBSession: TfrxDBDataset
    UserName = 'frxSession'
    CloseDataSource = False
    DataSet = SCM.qrySession
    BCDToCurrency = False
    Left = 32
    Top = 72
  end
  object frxDBSwimClub: TfrxDBDataset
    UserName = 'frxSwimClub'
    CloseDataSource = False
    DataSet = SCM.qrySwimClub
    BCDToCurrency = False
    Left = 32
    Top = 16
  end
  object frxDBEvent: TfrxDBDataset
    UserName = 'frxEvent'
    CloseDataSource = False
    DataSet = SCM.qryEvent
    BCDToCurrency = False
    Left = 32
    Top = 128
  end
  object frxDBDistance: TfrxDBDataset
    UserName = 'frxDistance'
    CloseDataSource = False
    DataSet = SCM.qryDistance
    BCDToCurrency = False
    Left = 112
    Top = 128
  end
  object frxDBStroke: TfrxDBDataset
    UserName = 'frxStroke'
    CloseDataSource = False
    DataSet = SCM.qryStroke
    BCDToCurrency = False
    Left = 184
    Top = 128
  end
  object qryEventType: TFDQuery
    Active = True
    IndexFieldNames = 'EventTypeID'
    MasterSource = SCM.dsDistance
    MasterFields = 'EventTypeID'
    DetailFields = 'EventTypeID'
    Connection = SCM.TestFDConnection
    SQL.Strings = (
      'SELECT '
      'EventTypeID,'
      'Caption,'
      'CaptionShort,'
      'ABREV '
      'FROM EventType')
    Left = 32
    Top = 192
  end
  object frxDBEventType: TfrxDBDataset
    UserName = 'frxEventType'
    CloseDataSource = False
    DataSet = qryEventType
    BCDToCurrency = False
    Left = 144
    Top = 192
  end
  object qryEventStatus: TFDQuery
    Active = True
    IndexFieldNames = 'EventStatusID'
    MasterSource = SCM.dsEvent
    MasterFields = 'EventStatusID'
    DetailFields = 'EventStatusID'
    Connection = SCM.TestFDConnection
    SQL.Strings = (
      'Select'
      'EventStatusID,'
      'Caption'
      'FROM eventStatus')
    Left = 32
    Top = 256
  end
  object frxDBEventStatus: TfrxDBDataset
    UserName = 'frxEventStatus'
    CloseDataSource = False
    DataSet = qryEventStatus
    BCDToCurrency = False
    Left = 144
    Top = 256
  end
end
