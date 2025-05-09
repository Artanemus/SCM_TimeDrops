object ReportsSCM: TReportsSCM
  Height = 480
  Width = 640
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
    Left = 416
    Top = 64
    Datasets = <
      item
        DataSet = frxDBSession
        DataSetName = 'frxSession'
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
        Height = 38.500000000000000000
        Top = 18.897650000000000000
        Width = 740.409927000000000000
        object frxSwimClubCaption: TfrxMemoView
          IndexTag = 1
          AllowVectorExport = True
          Left = 73.500000000000000000
          Top = 19.102350000000000000
          Width = 400.630180000000000000
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
          Left = 74.000000000000000000
          Top = -0.397650000000000000
          Width = 400.630180000000000000
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
          Left = 546.500000000000000000
          Top = 1.602350000000000000
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
          Top = 3.602350000000000000
          Width = 67.370130000000000000
          Height = 32.897650000000000000
          DataField = 'SessionID'
          DataSet = frxDBSession
          DataSetName = 'frxSession'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = []
          HAlign = haCenter
          Memo.UTF8W = (
            '[frxSession."SessionID"]')
          ParentFont = False
          VAlign = vaCenter
        end
      end
    end
  end
  object frxDBSession: TfrxDBDataset
    UserName = 'frxSession'
    CloseDataSource = False
    DataSet = SCM.qrySession
    BCDToCurrency = False
    Left = 400
    Top = 160
  end
  object frxDBSwimClub: TfrxDBDataset
    UserName = 'frxSwimClub'
    CloseDataSource = False
    DataSet = SCM.qrySwimClub
    BCDToCurrency = False
    Left = 400
    Top = 208
  end
end
