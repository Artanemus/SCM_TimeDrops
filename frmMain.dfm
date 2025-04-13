object Main: TMain
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'SwimClubMeet - TimeDrops'
  ClientHeight = 833
  ClientWidth = 1444
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  TextHeight = 21
  object actnMenuBar: TActionMainMenuBar
    Left = 0
    Top = 0
    Width = 1444
    Height = 25
    UseSystemFont = False
    ActionManager = actnManager
    Caption = 'actnMenuBar'
    Color = clMenuBar
    ColorMap.DisabledFontColor = 7171437
    ColorMap.HighlightColor = clWhite
    ColorMap.BtnSelectedFont = clBlack
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Spacing = 0
  end
  object rpnlBody: TRelativePanel
    Left = 0
    Top = 25
    Width = 1444
    Height = 773
    ControlCollection = <
      item
        Control = pnlTool1
        AlignBottomWithPanel = True
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = True
        AlignRightWithPanel = False
        AlignTopWithPanel = True
        AlignVerticalCenterWithPanel = False
      end
      item
        Control = pnlSCM
        AlignBottomWithPanel = True
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = False
        AlignRightWithPanel = False
        AlignTopWithPanel = True
        AlignVerticalCenterWithPanel = False
        RightOf = pnlTool1
      end
      item
        Control = pnlDT
        AlignBottomWithPanel = True
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = False
        AlignRightWithPanel = False
        AlignTopWithPanel = True
        AlignVerticalCenterWithPanel = False
        RightOf = pnlSCM
      end
      item
        Control = pnlTool2
        AlignBottomWithPanel = True
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = False
        AlignRightWithPanel = False
        AlignTopWithPanel = True
        AlignVerticalCenterWithPanel = False
        RightOf = pnlDT
      end>
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      1444
      773)
    object pnlTool1: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 144
      Height = 767
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 0
      object vimgHeatNum: TVirtualImage
        Left = 24
        Top = 181
        Width = 50
        Height = 50
        ImageCollection = AppData.imgcolDT
        ImageWidth = 0
        ImageHeight = 0
        ImageIndex = 14
        ImageName = 'EvBlue'
      end
      object vimgHeatStatus: TVirtualImage
        Left = 80
        Top = 181
        Width = 50
        Height = 50
        Hint = 'Heat status. (Open, raced, closed.)'
        ImageCollection = AppData.imgcolDT
        ImageWidth = 0
        ImageHeight = 0
        ImageIndex = 10
        ImageName = 'HeatOpen'
        ParentShowHint = False
        ShowHint = True
      end
      object vimgRelayBug: TVirtualImage
        Left = 24
        Top = 125
        Width = 50
        Height = 50
        ImageCollection = AppData.imgcolDT
        ImageWidth = 0
        ImageHeight = 0
        ImageIndex = 13
        ImageName = 'RELAY_DOT'
      end
      object vimgStrokeBug: TVirtualImage
        Left = 80
        Top = 125
        Width = 50
        Height = 50
        ImageCollection = AppData.imgcolDT
        ImageWidth = 0
        ImageHeight = 0
        ImageIndex = 0
        ImageName = 'StrokeFS'
      end
      object lblMeters: TLabel
        Left = 9
        Top = 131
        Width = 71
        Height = 37
        Alignment = taRightJustify
        Caption = '400M'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -27
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object lblHeatNum: TLabel
        Left = 24
        Top = 181
        Width = 50
        Height = 45
        Alignment = taCenter
        AutoSize = False
        Caption = 'H0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -32
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object lblMetersRelay: TLabel
        Left = 34
        Top = 88
        Width = 96
        Height = 37
        Alignment = taRightJustify
        Caption = '4x100M'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -27
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
        Transparent = True
        Visible = False
      end
      object lblSessionStart: TLabel
        Left = 1
        Top = 644
        Width = 143
        Height = 59
        Alignment = taCenter
        AutoSize = False
        Caption = 'SESSION'#13#10'DD/MM/YYYY'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -21
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
      object sbtnSyncSCMtoDT: TSpeedButton
        Left = 16
        Top = 266
        Width = 128
        Height = 41
        Hint = 
          'Syncronize SwimClubMeet to DT.'#13#10'(Must have the same session numb' +
          'er.)'
        Caption = 'SYNC'
        Images = AppData.vimglistMenu
        Layout = blGlyphRight
        ParentShowHint = False
        ShowHint = True
        OnClick = actnSyncSCMExecute
      end
      object sbtnRefreshSCM: TSpeedButton
        Left = 16
        Top = 313
        Width = 128
        Height = 41
        Hint = 
          'If changes have occurred (new events, heats, etc)'#13#10'pressing this' +
          ' button will re-sync to the SCM database.'
        Caption = 'REFRESH'
        Images = AppData.vimglistMenu
        Layout = blGlyphRight
        ParentShowHint = False
        ShowHint = True
        OnClick = actnRefreshExecute
      end
      object ShapeSpaceerSCM: TShape
        AlignWithMargins = True
        Left = 9
        Top = 253
        Width = 121
        Height = 4
        Margins.Top = 6
        Margins.Bottom = 6
        Brush.Color = clTomato
      end
    end
    object pnlSCM: TPanel
      AlignWithMargins = True
      Left = 153
      Top = 3
      Width = 525
      Height = 767
      BevelOuter = bvNone
      Color = 5988209
      ParentBackground = False
      TabOrder = 1
      object lblEventDetails: TLabel
        Left = 0
        Top = 28
        Width = 497
        Height = 64
        Hint = 
          'Session : Event : Distance+Stroke : Heat.'#13#10'2nd line - Event Desc' +
          'ription. '
        Alignment = taCenter
        AutoSize = False
        Caption = 'EVENT 1 : 50M Freestyle'#13#10'Boys under 10y'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Layout = tlCenter
        WordWrap = True
      end
      object btnNextEvent: TButton
        Left = 0
        Top = 683
        Width = 498
        Height = 50
        Hint = 
          'LMB Move to next record (heat, event, session)'#13#10'CNTRL+LMB Move t' +
          'o next EVENT.'#13#10'Use File menu to load SESSION.'
        Caption = 'NEXT'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = btnNextEventClick
      end
      object btnPrevEvent: TButton
        Left = 0
        Top = 98
        Width = 434
        Height = 50
        Hint = 
          'LMB Move to previous record (heat, event, session)'#13#10'CNTRL+LMB Mo' +
          've to previous EVENT.'#13#10'Use File menu to load SESSION.'
        Caption = 'PREVIOUS'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnPrevEventClick
      end
      object scmGrid: TDBAdvGrid
        Left = 0
        Top = 154
        Width = 498
        Height = 523
        Cursor = crDefault
        BevelInner = bvNone
        BevelKind = bkFlat
        BevelOuter = bvNone
        Color = 6445643
        ColCount = 7
        Ctl3D = True
        DefaultRowHeight = 46
        DrawingStyle = gdsClassic
        FixedColor = 3880234
        RowCount = 5
        FixedRows = 1
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        GradientStartColor = 6445643
        Options = [goFixedHorzLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
        ParentCtl3D = False
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 2
        StyleElements = [seFont, seBorder]
        HoverRowCells = [hcNormal, hcSelected]
        OnGetDisplText = scmGridGetDisplText
        ActiveCellFont.Charset = DEFAULT_CHARSET
        ActiveCellFont.Color = 4474440
        ActiveCellFont.Height = -16
        ActiveCellFont.Name = 'Segoe UI'
        ActiveCellFont.Style = [fsBold]
        ActiveCellColor = 11565130
        ActiveCellColorTo = 11565130
        BorderColor = 11250603
        ControlLook.FixedGradientFrom = 3880234
        ControlLook.FixedGradientTo = 3880234
        ControlLook.FixedGradientMirrorFrom = 3880234
        ControlLook.FixedGradientMirrorTo = 3880234
        ControlLook.FixedGradientHoverFrom = clGray
        ControlLook.FixedGradientHoverTo = clWhite
        ControlLook.FixedGradientHoverMirrorFrom = clWhite
        ControlLook.FixedGradientHoverMirrorTo = clWhite
        ControlLook.FixedGradientHoverBorder = 11645361
        ControlLook.FixedGradientDownFrom = clWhite
        ControlLook.FixedGradientDownTo = clWhite
        ControlLook.FixedGradientDownMirrorFrom = clWhite
        ControlLook.FixedGradientDownMirrorTo = clWhite
        ControlLook.FixedGradientDownBorder = 11250603
        ControlLook.DropDownHeader.Font.Charset = DEFAULT_CHARSET
        ControlLook.DropDownHeader.Font.Color = clWindowText
        ControlLook.DropDownHeader.Font.Height = -12
        ControlLook.DropDownHeader.Font.Name = 'Tahoma'
        ControlLook.DropDownHeader.Font.Style = []
        ControlLook.DropDownHeader.Visible = True
        ControlLook.DropDownHeader.Buttons = <>
        ControlLook.DropDownFooter.Font.Charset = DEFAULT_CHARSET
        ControlLook.DropDownFooter.Font.Color = clWindowText
        ControlLook.DropDownFooter.Font.Height = -12
        ControlLook.DropDownFooter.Font.Name = 'Segoe UI'
        ControlLook.DropDownFooter.Font.Style = []
        ControlLook.DropDownFooter.Visible = True
        ControlLook.DropDownFooter.Buttons = <>
        Filter = <>
        FilterDropDown.Font.Charset = DEFAULT_CHARSET
        FilterDropDown.Font.Color = clWindowText
        FilterDropDown.Font.Height = -12
        FilterDropDown.Font.Name = 'Segoe UI'
        FilterDropDown.Font.Style = []
        FilterDropDown.TextChecked = 'Checked'
        FilterDropDown.TextUnChecked = 'Unchecked'
        FilterDropDownClear = '(All)'
        FilterEdit.TypeNames.Strings = (
          'Starts with'
          'Ends with'
          'Contains'
          'Not contains'
          'Equal'
          'Not equal'
          'Larger than'
          'Smaller than'
          'Clear')
        FixedColWidth = 20
        FixedRowHeight = 34
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindow
        FixedFont.Height = -16
        FixedFont.Name = 'Segoe UI Semibold'
        FixedFont.Style = [fsBold]
        FloatFormat = '%.2f'
        HoverButtons.Buttons = <>
        HoverButtons.Position = hbLeftFromColumnLeft
        HTMLSettings.ImageFolder = 'images'
        HTMLSettings.ImageBaseName = 'img'
        Look = glCustom
        PrintSettings.DateFormat = 'dd/mm/yyyy'
        PrintSettings.Font.Charset = DEFAULT_CHARSET
        PrintSettings.Font.Color = clWindowText
        PrintSettings.Font.Height = -12
        PrintSettings.Font.Name = 'Segoe UI'
        PrintSettings.Font.Style = []
        PrintSettings.FixedFont.Charset = DEFAULT_CHARSET
        PrintSettings.FixedFont.Color = clWindowText
        PrintSettings.FixedFont.Height = -12
        PrintSettings.FixedFont.Name = 'Segoe UI'
        PrintSettings.FixedFont.Style = []
        PrintSettings.HeaderFont.Charset = DEFAULT_CHARSET
        PrintSettings.HeaderFont.Color = clWindowText
        PrintSettings.HeaderFont.Height = -12
        PrintSettings.HeaderFont.Name = 'Segoe UI'
        PrintSettings.HeaderFont.Style = []
        PrintSettings.FooterFont.Charset = DEFAULT_CHARSET
        PrintSettings.FooterFont.Color = clWindowText
        PrintSettings.FooterFont.Height = -12
        PrintSettings.FooterFont.Name = 'Segoe UI'
        PrintSettings.FooterFont.Style = []
        PrintSettings.PageNumSep = '/'
        SearchFooter.ColorTo = clWhite
        SearchFooter.FindNextCaption = 'Find &next'
        SearchFooter.FindPrevCaption = 'Find &previous'
        SearchFooter.Font.Charset = DEFAULT_CHARSET
        SearchFooter.Font.Color = clWindowText
        SearchFooter.Font.Height = -12
        SearchFooter.Font.Name = 'Segoe UI'
        SearchFooter.Font.Style = []
        SearchFooter.HighLightCaption = 'Highlight'
        SearchFooter.HintClose = 'Close'
        SearchFooter.HintFindNext = 'Find next occurrence'
        SearchFooter.HintFindPrev = 'Find previous occurrence'
        SearchFooter.HintHighlight = 'Highlight occurrences'
        SearchFooter.MatchCaseCaption = 'Match case'
        SearchFooter.ResultFormat = '(%d of %d)'
        SelectionColor = 12228474
        SelectionTextColor = clWindowText
        SortSettings.DefaultFormat = ssAutomatic
        SortSettings.HeaderColor = clWhite
        SortSettings.HeaderColorTo = clWhite
        SortSettings.HeaderMirrorColor = clWhite
        SortSettings.HeaderMirrorColorTo = clWhite
        Version = '2.5.1.3'
        AutoCreateColumns = False
        AutoRemoveColumns = False
        Columns = <
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 20
          end
          item
            Alignment = taCenter
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'Lane'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = 'Lane'
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 44
          end
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'TimeToBeat'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = 'TTB'
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 0
          end
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'PersonalBest'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = 'PB'
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 0
          end
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'MemberID'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = 'Entrant'
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            HeaderAlignment = taCenter
            HTMLTemplate = 
              '<P align="center"><FONT face="Arial">  <B><#FName></B><BR> TTB: ' +
              '<#TimeToBeat>      PB: <#PersonalBest></FONT></P> '
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -16
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 300
          end
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'RaceTime'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI Semibold'
            Font.Style = []
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 90
          end
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            DataImageField = True
            FieldName = 'imgPatch'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = ' '
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            Images = AppData.vimglistDTGrid
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clBlack
            PrintFont.Height = -16
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 34
          end>
        DataSource = AppData.dsINDV
        InvalidPicture.Data = {
          055449636F6E0000010001002020200000000000A81000001600000028000000
          2000000040000000010020000000000000100000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000006A6A6B256A6A6B606A6A6B946A6A6BC06A6A6BE1
          6A6A6BF86A6A6BF86A6A6BE16A6A6BC06A6A6B946A6A6B606A6A6B2500000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000006A6A6B407575769E787879F19F9F9FF6C0C0C0FDDADADAFFEDEDEEFF
          FBFBFBFFFBFBFBFFEDEDEEFFDADADAFFC0C0C0FD9F9F9FF6787879F17575769E
          6A6A6B4000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000006A6A6B22
          7C7C7C98888889F0BDBDBDFCE9E9EBFED9D9E9FEB5B5DDFE8B8BCDFE595AB7FF
          3739A8FF2B2CA4FF4A49B1FF7171C1FFA1A2D7FFD3D3E8FFEAEAEBFEBEBEBFFC
          888889F07C7C7C986A6A6B220000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000006A6A6B43838383D8
          B7B7B8FAECECEFFEC0C0DFFF7977C4FF2221A0FF12129BFF1010A4FF0C0CA8FF
          0A0AACFF0A0AB4FF0A0AB9FF0D0DBEFF0F0FB1FF1111A6FF5656B8FFAEADDCFF
          ECECEFFEB7B7B8FA838383D86A6A6B4300000000000000000000000000000000
          00000000000000000000000000000000000000006A6A6B4E878788EAD3D3D3FE
          CACAE8FF4443B0FF171799FF11119CFF0C0C98FF0B0B9BFF0B0BA0FF0A0AA6FF
          0909ACFF0909B2FF0808BAFF0707BFFF0B09C8FF0D0DCEFF1111CCFF1010AFFF
          4A49B2FFCFCFEBFFD3D3D3FE878788EA6A6A6B4E000000000000000000000000
          000000000000000000000000000000006A6A6B43878788EAE1E1E1FFA8A8DAFF
          2323A0FF15159CFF0D0D92FF0C0C95FF0C0C99FF0B0B9EFF0B0BA0FF0A0AA6FF
          0909ACFF0909B2FF0808B8FF0808BCFF0808C3FF0C0CC9FF0C0CD0FF0D0DD6FF
          1313CFFF2222A9FFAFAFDEFFE1E1E1FF878788EA6A6A6B430000000000000000
          0000000000000000000000006A6A6B22838383D8D3D3D3FEA8A8D9FF2020A4FF
          13139BFF0C0C92FF0C0C95FF0C0C97FF0C0C99FF0B0B9EFF0B0BA0FF0A0AA4FF
          0A0AA9FF0909B0FF0808B4FF0808BBFF0707C0FF0A0AC6FF0909CCFF0C0CD3FF
          0D0DD8FF1313D3FF1A1AA8FFAEADDEFFD4D4D4FE838383D86A6A6B2200000000
          0000000000000000000000007C7C7C98B7B7B8FACACAE8FF2524A3FF13139FFF
          0C0C97FF0C0C95FF0C0C95FF0C0C91FF0C0C95FF0B0B9EFF0B0BA0FF0A0AA4FF
          0A0AA8FF0909ADFF0909B2FF0808B8FF0808BCFF0707C0FF0808BCFF0707C5FF
          0C0CD3FF0D0DD7FF1212D1FF2020A7FFCDCDEBFFB8B8B9FA7C7C7C9800000000
          00000000000000006A6A6B40888889F0ECECEFFE4545B1FF1616A4FF0B0B9BFF
          0C0C99FF0C0C96FF3333A2FFB9B9D0FF393A9BFF0C0C95FF0B0BA1FF0A0AA4FF
          0A0AA7FF0A0AABFF0909B0FF0808B4FF0808B7FF2F2FC2FFAEAEE2FF4B4BBFFF
          0707BEFF0B0BD1FF0C0CD3FF1413CCFF4848B1FFECECEFFE888889F06A6A6B40
          00000000000000007575769EBFBFBFFD9B9BD5FF1C1CA6FF0C0CA1FF0B0B9FFF
          0B0B9AFF3535A7FFB5B5BEFFE6E6DFFFEDEDEFFF3C3C9CFF0C0C97FF0A0AA4FF
          0A0AA6FF0A0AA9FF0909ADFF0909B0FF2626B5FFCECEDEFFFFFFFBFFEEEEF1FF
          4848BAFF0808BCFF0A0ACDFF0B0BCEFF1111ABFFBEC0E0FFBFC0BFFD7575769E
          000000006A6A6B25787879F1E3E3E5FE4646B2FF1414A8FF0A0AA4FF0B0BA0FF
          2121A9FFBDBDCAFFD0D0C8FFC5C5C5FFE3E3E1FFEDEDEFFF3E3E9EFF0C0C98FF
          0A0AA6FF0A0AA8FF0A0AA9FF2B2BB0FFC0C0CDFFEAEAE2FFEBEBEBFFFEFEF8FF
          EDEDEEFF2828BDFF0707C4FF0809C7FF0F0FC4FF8788CBFFEBEBECFE79797AF1
          6A6A6B256A6A6B609D9E9DF6D6D7E4FF3A3AB3FF1212ADFF0A0AA8FF0A0AA4FF
          1313AAFFABABCFFFD6D6CBFFCACACAFFC6C6C6FFE4E4E0FFEEEEEFFF3F3FA0FF
          0C0C99FF0A0AA6FF2828ABFFB2B2BFFFD8D8CEFFD6D6D8FFE0E0E0FFF6F5EDFF
          D1D1EDFF1E1CC0FF0707BEFF0707BFFF0707C0FF2120AAFFD3D5E9FE9FA0A0F6
          6A6A6B606A6A6B94BDBDBDFBBABBDCFF3A39B7FF2F2FB8FF0909ADFF0A0AA9FF
          0A0AA6FF1515ACFFADADCFFFD6D6CBFFCBCBCAFFC6C6C6FFE4E4E1FFEEEEEFFF
          3838A1FF2222A2FFACABB8FFC8C8C0FFC7C7C8FFCDCDCDFFE1E1D9FFC8CAE1FF
          2424BCFF0808B4FF0808B9FF0808BAFF0808BBFF0F0EABFFA1A2D5FEC0C0C0FC
          6A6A6B946A6A6BC0D9D8D7FE9999D1FF3838BBFF3636BCFF2C2CB7FF0909ADFF
          0A0AA9FF0A0AA4FF1C1CAFFFB1B1CFFFD6D6CBFFCCCCCBFFC7C7C7FFE4E4E1FF
          ECECEEFFACACB7FFC2C2BCFFBEBEBFFFC0C0C0FFCFCFC6FFC1C1D5FF2727B8FF
          0909ACFF0909B2FF0909B2FF0909B4FF0808B4FF0E0EB5FF6E6EBFFFD9D9D9FE
          6A6A6BC06A6A6BE1EBEAEBFF7D7CC7FF3838BFFF3434BEFF3536BEFF2A2AB8FF
          0909B0FF0909ACFF0A0AA8FF1C1CB1FFB2B2D0FFD7D7CCFFCBCBCBFFC7C7C8FF
          C8C8C3FFC6C6C3FFBFBFC1FFBDBDBDFFC5C5BCFFB8B8CEFF2929B5FF0A0AA8FF
          0909ACFF0909ADFF0909AFFF0909AFFF0909AFFF0C0CB0FF4747AFFFECECEDFF
          6A6A6BE16A6A6BF8F9F9F9FF6666C1FF3838C4FF3535C2FF3434C0FF3535BEFF
          3030BCFF1313B4FF0909ADFF0A0AA8FF1E1EB3FFAAAAD0FFD3D3CDFFCCCCCCFF
          C8C8C8FFC3C3C3FFC2C2C1FFC4C4BFFFB2B2CBFF2B2BB4FF0A0AA4FF0A0AA8FF
          0A0AA8FF0A0AA9FF0A0AA9FF0A0AA9FF0A0AA9FF0B0BA9FF3131A6FFFAFAFAFF
          6A6A6BF86A6A6BF8FBFBFBFF5959BEFF3B3BCAFF3A3AC8FF3737C4FF3535C2FF
          3636C0FF3636BEFF2323B8FF0909B1FF0A0AA7FF4949BEFFD6D6D4FFD3D3D1FF
          CDCDCDFFC8C8C8FFC4C4C3FFEDEDEDFF5F5FB3FF0C0C98FF0A0AA7FF0A0AA6FF
          0A0AA6FF0A0AA6FF0A0AA4FF0A0AA6FF0A0AA4FF0B0BA4FF2D2DA6FFFBFBFBFF
          6A6A6BF86A6A6BE1EDEDEEFF7F80CBFF4041CCFF3C3CCAFF3A3AC8FF383AC8FF
          3838C4FF3636C2FF3939C0FF2123B7FF4A4AC2FFCBCBDEFFE0E0DCFFD6D6D6FF
          D2D2D3FFCDCDCEFFC9C9C9FFE2E2E1FFF1F1F2FF4242A3FF0C0C99FF0A0AA4FF
          0A0AA4FF0A0AA4FF0B0BA3FF0B0BA3FF0B0BA1FF0E0EA1FF4443B0FFEDEDEEFF
          6A6A6BE16A6A6BC0DADADAFF9C9BD5FE4949CDFF3E3DD0FF3C3DCEFF3C3CCAFF
          3A3AC8FF3B39C7FF2828BDFF5C5CCCFFE5E5EDFFF4F4EDFFE5E5E6FFDEDEDEFF
          DCDCD9FFD9D9D3FFCDCDCDFFC8C8C8FFE5E5E1FFF1F1F3FF3F3FA0FF0C0C99FF
          0A0AA4FF0B0BA1FF0B0BA0FF0B0BA0FF0B0B9FFF1313A2FF6B6BC0FFDADADAFF
          6A6A6BC06A6A6B94C0C0C0FDBDBAE1FE5655CFFF4141D4FF3F3FD2FF3F3FCEFF
          3D3DCCFF2C2AC3FF5E5ED3FFEBEBF6FFFFFFFAFFF1F1F1FFEDEDEEFFF0F0E9FF
          D2D2E6FFBDBDD6FFDADAD3FFCFCFCFFFC9C9CAFFE5E5E2FFF1F1F3FF3A3AA0FF
          0C0C98FF0B0BA3FF0B0B9FFF0B0B9EFF0B0B9EFF1C1CA4FF9C9CD3FFC1C1C1FD
          6A6A6B946A6A6B609F9F9FF6DAD9EAFF6B6BCFFF4444D7FF4143D6FF4242D3FF
          3434CDFF6464DBFFEFEFFFFFFFFFFFFFFCFCFCFFF6F6F6FFFCFCF4FFE2E1F0FF
          5050CCFF4040C1FFC3C3DBFFE1E1D8FFD4D4D5FFCFCFCFFFE8E8E5FFF2F2F4FF
          4040A2FF0C0C99FF0F0FA2FF0F0FA0FF0F0F9DFF302FA9FFD1D1E8FEA0A0A0F6
          6A6A6B606A6A6B25787879F1E9E9EBFEA7A7DAFF6060DBFF4547DBFF3C3CD6FF
          5857DEFFF2F2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE8E8F8FF5B5BD4FF
          2828BDFF2A2BBDFF4949C5FFC3C3DBFFE4E4DAFFD5D5D5FFCECED0FFE8E8E5FF
          F4F4F4FF4949AFFF2121A6FF2A2AA6FF2C2BA9FF5557B8FFEAEAECFE787879F1
          6A6A6B25000000007575769EBEBEBEFDC9CAE6FF7A79DBFF4C4CDFFF4141DBFF
          5757E0FFEAEAFFFFFFFFFFFFFFFFFFFFFFFFFFFFE8E7FFFF5B5BD7FF2E2EC6FF
          3E3EC9FF3A3AC5FF2C2EC1FF4A49C8FFC2C2DDFFE3E3DAFFD5D5D4FFDADAD3FF
          CACBD9FF4747BBFF2525ADFF2C2BACFF3332AEFFA5A4D8FFBFBFBFFD7575769E
          00000000000000006A6A6B40888889F0ECECEFFE9696D6FF7B7BE3FF4D4BE0FF
          4141DBFF5F5FE6FFE7E7FFFFFFFFFFFFE9E9FFFF5A5ADCFF3333CAFF4242CFFF
          4040CBFF3D3DC9FF3D3EC8FF3030C2FF4848C9FFC0C0DDFFECEEDEFFD0D0E0FF
          5554C7FF2828B3FF3232B4FF3434B1FF5453B7FFECECEFFE888889F06A6A6B40
          0000000000000000000000007C7C7C98B7B7B8FAD0D0ECFF8F8FDBFF6868E3FF
          4E4EE2FF3E40DBFF6565E9FFB2B2F7FF6565E4FF393BD2FF4646D7FF4343D4FF
          4343D1FF4242CFFF4040CBFF3F3FCAFF3333C4FF4E4ECBFF9E9EE2FF5C5BCFFF
          292ABAFF3636BCFF3938B8FF3F3EB1FFCBCBE9FFB7B7B8FA7C7C7C9800000000
          0000000000000000000000006A6A6B22838383D8D3D3D3FEB5B5E2FF9E9EE4FF
          6766E2FF4E50E6FF4646E0FF3D3DDAFF4444DCFF4B4BDCFF4848DBFF4847D9FF
          4646D5FF4443D3FF4343D1FF4242CFFF4143CDFF3A3AC8FF312FC5FF3535C3FF
          3C3CC3FF3D3DBEFF403FB5FFACACDCFFD3D3D3FE838383D86A6A6B2200000000
          000000000000000000000000000000006A6A6B43878788EAE1E1E1FFB5B5E2FF
          A7A6E4FF7877E5FF5151E5FF4F4FE4FF4E4EE2FF4D4DE0FF4C4CDEFF4B4BDCFF
          4949DBFF4848D7FF4747D5FF4545D3FF4545D1FF4343CFFF4242CCFF3F3FCBFF
          4343C2FF4645B6FFADADDCFFE1E1E1FF878788EA6A6A6B430000000000000000
          00000000000000000000000000000000000000006A6A6B4E878788EAD3D3D3FE
          D0D0ECFFAAA9DFFFA2A2ECFF6565E3FF5151E6FF4F4FE4FF4F4DE4FF4D4DE0FF
          4D4DDFFF4D4DDCFF4C49DBFF4A4AD8FF4749D6FF4747D4FF4949CBFF4B4BC3FF
          8E8ED0FFCDCCE8FFD3D3D3FE878788EA6A6A6B4E000000000000000000000000
          0000000000000000000000000000000000000000000000006A6A6B43838383D8
          B7B7B8FAECECEFFEC3C2E5FFADAEE1FF9E9DE8FF6F6FE0FF5C5CE1FF5452E2FF
          5051E1FF4F4FDFFF4F4FDBFF5150D6FF5151CFFF5F5FC8FFA1A1D3FEC7C8E0FE
          E4E4E7FEB7B7B8FA838383D86A6A6B4300000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000006A6A6B22
          7C7C7C98888889F0BFBFBFFDEBEBECFED8D9EBFEBDBDE4FEA8A7DCFF9695D7FF
          8886D4FF7F7DCEFF8C8BD2FFA1A2D9FFC0BEE1FED9D9EAFEEAEAECFEBFBFBFFD
          888889F07C7C7C986A6A6B220000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000006A6A6B407575769E787879F19F9F9FF6C0C0C0FDDADADAFFEDEDEEFF
          FBFBFBFFFBFBFBFFEDEDEEFFDADADAFFC0C0C0FD9F9F9FF6787879F17575769E
          6A6A6B4000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000006A6A6B256A6A6B606A6A6B946A6A6BC06A6A6BE1
          6A6A6BF86A6A6BF86A6A6BE16A6A6BC06A6A6B946A6A6B606A6A6B2500000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000FFC003FFFF0000FFFC00003FF800001FF000000FE0000007C0000003
          C000000380000001800000010000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000080000001
          80000001C0000003C0000003E0000007F000000FF800001FFC00003FFF0000FF
          FFC003FF}
        ShowUnicode = False
        ColWidths = (
          20
          44
          0
          0
          300
          90
          34)
        RowHeights = (
          34
          46
          46
          46
          46)
      end
      object btnPickSCMTreeView: TButton
        Left = 440
        Top = 98
        Width = 58
        Height = 50
        Hint = 
          'Tree-View. Quick access and browse for event and heat.'#13#10'Also dis' +
          'plays event and heat status. (Open, raced, closed.)'
        DisabledImages = AppData.vimglistDTEvent
        ImageIndex = 10
        ImageName = 'TreeView_W'
        Images = AppData.vimglistDTEvent
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnClick = btnPickSCMTreeViewClick
      end
    end
    object pnlDT: TPanel
      AlignWithMargins = True
      Left = 684
      Top = 3
      Width = 613
      Height = 767
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 2
      object dbtxtDTFileName: TDBText
        Left = 16
        Top = 19
        Width = 553
        Height = 31
        Alignment = taCenter
        DataField = 'FileName'
        DataSource = AppData.dsmHeat
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object lblEventDetailsTD: TLabel
        Left = 16
        Top = 42
        Width = 597
        Height = 36
        Hint = 
          'Dolphin Timing Filename. (DO3, DO4)'#13#10'2nd line - Session : Event ' +
          ':: Heat.'
        Alignment = taCenter
        AutoSize = False
        Caption = 'Session - Event - Heat'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Layout = tlCenter
      end
      object lblKeyBoardInfo: TLabel
        Left = 16
        Top = 72
        Width = 597
        Height = 17
        Alignment = taCenter
        AutoSize = False
        Caption = 
          'CTRL+LMB select single     SHIFT+LMB select range     ALT-LMB mo' +
          'dify cell.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object btnPrevDTFile: TButton
        Left = 15
        Top = 99
        Width = 534
        Height = 49
        Hint = 
          'LMB Move to previous record (heat, event, session)'#13#10'CNTRL+LMB Mo' +
          've to previous EVENT.'#13#10'SHIFT+CNTRL+LMB Move to previous SESSION.'
        Caption = 'PREVIOUS'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnPrevDTFileClick
      end
      object btnNextDTFile: TButton
        Left = 16
        Top = 683
        Width = 597
        Height = 50
        Hint = 
          'LMB Move to next record (heat, event, session)'#13#10'CNTRL+LMB Move t' +
          'o next EVENT.'#13#10'SHIFT+CNTRL+LMB Move to next SESSION.'
        Caption = 'NEXT'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = btnNextDTFileClick
      end
      object dtGrid: TDBAdvGrid
        Left = 16
        Top = 154
        Width = 597
        Height = 523
        Cursor = crDefault
        BevelInner = bvNone
        BevelKind = bkFlat
        BevelOuter = bvNone
        Color = 6445643
        ColCount = 8
        Ctl3D = True
        DefaultRowHeight = 46
        DrawingStyle = gdsClassic
        FixedColor = 3880234
        RowCount = 2
        FixedRows = 1
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        GradientStartColor = 6445643
        Options = [goFixedHorzLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
        ParentCtl3D = False
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 2
        StyleElements = [seFont, seBorder]
        HoverRowCells = [hcNormal, hcSelected]
        OnClickCell = dtGridClickCell
        ActiveCellFont.Charset = DEFAULT_CHARSET
        ActiveCellFont.Color = 4474440
        ActiveCellFont.Height = -16
        ActiveCellFont.Name = 'Segoe UI'
        ActiveCellFont.Style = [fsBold]
        ActiveCellColor = 11565130
        ActiveCellColorTo = 11565130
        BorderColor = 11250603
        ControlLook.FixedGradientFrom = 3880234
        ControlLook.FixedGradientTo = 3880234
        ControlLook.FixedGradientMirrorFrom = 3880234
        ControlLook.FixedGradientMirrorTo = 3880234
        ControlLook.FixedGradientHoverFrom = clGray
        ControlLook.FixedGradientHoverTo = clWhite
        ControlLook.FixedGradientHoverMirrorFrom = clWhite
        ControlLook.FixedGradientHoverMirrorTo = clWhite
        ControlLook.FixedGradientHoverBorder = 11645361
        ControlLook.FixedGradientDownFrom = clWhite
        ControlLook.FixedGradientDownTo = clWhite
        ControlLook.FixedGradientDownMirrorFrom = clWhite
        ControlLook.FixedGradientDownMirrorTo = clWhite
        ControlLook.FixedGradientDownBorder = 11250603
        ControlLook.DropDownHeader.Font.Charset = DEFAULT_CHARSET
        ControlLook.DropDownHeader.Font.Color = clWindowText
        ControlLook.DropDownHeader.Font.Height = -12
        ControlLook.DropDownHeader.Font.Name = 'Tahoma'
        ControlLook.DropDownHeader.Font.Style = []
        ControlLook.DropDownHeader.Visible = True
        ControlLook.DropDownHeader.Buttons = <>
        ControlLook.DropDownFooter.Font.Charset = DEFAULT_CHARSET
        ControlLook.DropDownFooter.Font.Color = clWindowText
        ControlLook.DropDownFooter.Font.Height = -12
        ControlLook.DropDownFooter.Font.Name = 'Segoe UI'
        ControlLook.DropDownFooter.Font.Style = []
        ControlLook.DropDownFooter.Visible = True
        ControlLook.DropDownFooter.Buttons = <>
        Filter = <>
        FilterDropDown.Font.Charset = DEFAULT_CHARSET
        FilterDropDown.Font.Color = clWindowText
        FilterDropDown.Font.Height = -12
        FilterDropDown.Font.Name = 'Segoe UI'
        FilterDropDown.Font.Style = []
        FilterDropDown.TextChecked = 'Checked'
        FilterDropDown.TextUnChecked = 'Unchecked'
        FilterDropDownClear = '(All)'
        FilterEdit.TypeNames.Strings = (
          'Starts with'
          'Ends with'
          'Contains'
          'Not contains'
          'Equal'
          'Not equal'
          'Larger than'
          'Smaller than'
          'Clear')
        FixedColWidth = 20
        FixedRowHeight = 34
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindow
        FixedFont.Height = -16
        FixedFont.Name = 'Segoe UI Semibold'
        FixedFont.Style = [fsBold]
        FloatFormat = '%.2f'
        GridImages = AppData.vimglistDTCell
        HoverButtons.Buttons = <>
        HoverButtons.Position = hbLeftFromColumnLeft
        HTMLSettings.ImageFolder = 'images'
        HTMLSettings.ImageBaseName = 'img'
        Look = glCustom
        MouseActions.DisjunctRowSelect = True
        PrintSettings.DateFormat = 'dd/mm/yyyy'
        PrintSettings.Font.Charset = DEFAULT_CHARSET
        PrintSettings.Font.Color = clWindowText
        PrintSettings.Font.Height = -12
        PrintSettings.Font.Name = 'Segoe UI'
        PrintSettings.Font.Style = []
        PrintSettings.FixedFont.Charset = DEFAULT_CHARSET
        PrintSettings.FixedFont.Color = clWindowText
        PrintSettings.FixedFont.Height = -12
        PrintSettings.FixedFont.Name = 'Segoe UI'
        PrintSettings.FixedFont.Style = []
        PrintSettings.HeaderFont.Charset = DEFAULT_CHARSET
        PrintSettings.HeaderFont.Color = clWindowText
        PrintSettings.HeaderFont.Height = -12
        PrintSettings.HeaderFont.Name = 'Segoe UI'
        PrintSettings.HeaderFont.Style = []
        PrintSettings.FooterFont.Charset = DEFAULT_CHARSET
        PrintSettings.FooterFont.Color = clWindowText
        PrintSettings.FooterFont.Height = -12
        PrintSettings.FooterFont.Name = 'Segoe UI'
        PrintSettings.FooterFont.Style = []
        PrintSettings.PageNumSep = '/'
        SearchFooter.ColorTo = clWhite
        SearchFooter.FindNextCaption = 'Find &next'
        SearchFooter.FindPrevCaption = 'Find &previous'
        SearchFooter.Font.Charset = DEFAULT_CHARSET
        SearchFooter.Font.Color = clWindowText
        SearchFooter.Font.Height = -12
        SearchFooter.Font.Name = 'Segoe UI'
        SearchFooter.Font.Style = []
        SearchFooter.HighLightCaption = 'Highlight'
        SearchFooter.HintClose = 'Close'
        SearchFooter.HintFindNext = 'Find next occurrence'
        SearchFooter.HintFindPrev = 'Find previous occurrence'
        SearchFooter.HintHighlight = 'Highlight occurrences'
        SearchFooter.MatchCaseCaption = 'Match case'
        SearchFooter.ResultFormat = '(%d of %d)'
        SelectionColor = 12228474
        SelectionTextColor = clWindowText
        SortSettings.DefaultFormat = ssAutomatic
        SortSettings.HeaderColor = clWhite
        SortSettings.HeaderColorTo = clWhite
        SortSettings.HeaderMirrorColor = clWhite
        SortSettings.HeaderMirrorColorTo = clWhite
        VAlignment = vtaCenter
        Version = '2.5.1.3'
        AutoCreateColumns = False
        AutoRemoveColumns = False
        Columns = <
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = 3881787
            HeaderFont.Height = -12
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 20
          end
          item
            Alignment = taRightJustify
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            DataImageField = True
            FieldName = 'imgPatch'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = ' '
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            Images = AppData.vimglistDTGrid
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 34
          end
          item
            Alignment = taRightJustify
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'Lane'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            HeaderAlignment = taCenter
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 44
          end
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'Time1'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = 'Timer A'
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            HeaderAlignment = taCenter
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 94
          end
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'Time2'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = 'Timer B'
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            HeaderAlignment = taCenter
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 94
          end
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'Time3'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = 'Timer C'
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            HeaderAlignment = taCenter
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -12
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 94
          end
          item
            Alignment = taRightJustify
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            DataImageField = True
            FieldName = 'imgActiveRT'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = ' '
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -13
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            HeaderAlignment = taCenter
            Images = AppData.vimglistDTGrid
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -16
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 64
          end
          item
            Borders = []
            BorderPen.Color = clSilver
            ButtonHeight = 18
            CheckFalse = 'N'
            CheckTrue = 'Y'
            Color = 6445643
            FieldName = 'RaceTime'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindow
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            Header = 'RaceTime'
            HeaderFont.Charset = DEFAULT_CHARSET
            HeaderFont.Color = clWindow
            HeaderFont.Height = -16
            HeaderFont.Name = 'Segoe UI'
            HeaderFont.Style = []
            HeaderAlignment = taCenter
            PrintBorders = [cbTop, cbLeft, cbRight, cbBottom]
            PrintFont.Charset = DEFAULT_CHARSET
            PrintFont.Color = clWindowText
            PrintFont.Height = -16
            PrintFont.Name = 'Segoe UI'
            PrintFont.Style = []
            Width = 120
          end>
        DataSource = AppData.dsmLane
        InvalidPicture.Data = {
          055449636F6E0000010001002020200000000000A81000001600000028000000
          2000000040000000010020000000000000100000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000006A6A6B256A6A6B606A6A6B946A6A6BC06A6A6BE1
          6A6A6BF86A6A6BF86A6A6BE16A6A6BC06A6A6B946A6A6B606A6A6B2500000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000006A6A6B407575769E787879F19F9F9FF6C0C0C0FDDADADAFFEDEDEEFF
          FBFBFBFFFBFBFBFFEDEDEEFFDADADAFFC0C0C0FD9F9F9FF6787879F17575769E
          6A6A6B4000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000006A6A6B22
          7C7C7C98888889F0BDBDBDFCE9E9EBFED9D9E9FEB5B5DDFE8B8BCDFE595AB7FF
          3739A8FF2B2CA4FF4A49B1FF7171C1FFA1A2D7FFD3D3E8FFEAEAEBFEBEBEBFFC
          888889F07C7C7C986A6A6B220000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000006A6A6B43838383D8
          B7B7B8FAECECEFFEC0C0DFFF7977C4FF2221A0FF12129BFF1010A4FF0C0CA8FF
          0A0AACFF0A0AB4FF0A0AB9FF0D0DBEFF0F0FB1FF1111A6FF5656B8FFAEADDCFF
          ECECEFFEB7B7B8FA838383D86A6A6B4300000000000000000000000000000000
          00000000000000000000000000000000000000006A6A6B4E878788EAD3D3D3FE
          CACAE8FF4443B0FF171799FF11119CFF0C0C98FF0B0B9BFF0B0BA0FF0A0AA6FF
          0909ACFF0909B2FF0808BAFF0707BFFF0B09C8FF0D0DCEFF1111CCFF1010AFFF
          4A49B2FFCFCFEBFFD3D3D3FE878788EA6A6A6B4E000000000000000000000000
          000000000000000000000000000000006A6A6B43878788EAE1E1E1FFA8A8DAFF
          2323A0FF15159CFF0D0D92FF0C0C95FF0C0C99FF0B0B9EFF0B0BA0FF0A0AA6FF
          0909ACFF0909B2FF0808B8FF0808BCFF0808C3FF0C0CC9FF0C0CD0FF0D0DD6FF
          1313CFFF2222A9FFAFAFDEFFE1E1E1FF878788EA6A6A6B430000000000000000
          0000000000000000000000006A6A6B22838383D8D3D3D3FEA8A8D9FF2020A4FF
          13139BFF0C0C92FF0C0C95FF0C0C97FF0C0C99FF0B0B9EFF0B0BA0FF0A0AA4FF
          0A0AA9FF0909B0FF0808B4FF0808BBFF0707C0FF0A0AC6FF0909CCFF0C0CD3FF
          0D0DD8FF1313D3FF1A1AA8FFAEADDEFFD4D4D4FE838383D86A6A6B2200000000
          0000000000000000000000007C7C7C98B7B7B8FACACAE8FF2524A3FF13139FFF
          0C0C97FF0C0C95FF0C0C95FF0C0C91FF0C0C95FF0B0B9EFF0B0BA0FF0A0AA4FF
          0A0AA8FF0909ADFF0909B2FF0808B8FF0808BCFF0707C0FF0808BCFF0707C5FF
          0C0CD3FF0D0DD7FF1212D1FF2020A7FFCDCDEBFFB8B8B9FA7C7C7C9800000000
          00000000000000006A6A6B40888889F0ECECEFFE4545B1FF1616A4FF0B0B9BFF
          0C0C99FF0C0C96FF3333A2FFB9B9D0FF393A9BFF0C0C95FF0B0BA1FF0A0AA4FF
          0A0AA7FF0A0AABFF0909B0FF0808B4FF0808B7FF2F2FC2FFAEAEE2FF4B4BBFFF
          0707BEFF0B0BD1FF0C0CD3FF1413CCFF4848B1FFECECEFFE888889F06A6A6B40
          00000000000000007575769EBFBFBFFD9B9BD5FF1C1CA6FF0C0CA1FF0B0B9FFF
          0B0B9AFF3535A7FFB5B5BEFFE6E6DFFFEDEDEFFF3C3C9CFF0C0C97FF0A0AA4FF
          0A0AA6FF0A0AA9FF0909ADFF0909B0FF2626B5FFCECEDEFFFFFFFBFFEEEEF1FF
          4848BAFF0808BCFF0A0ACDFF0B0BCEFF1111ABFFBEC0E0FFBFC0BFFD7575769E
          000000006A6A6B25787879F1E3E3E5FE4646B2FF1414A8FF0A0AA4FF0B0BA0FF
          2121A9FFBDBDCAFFD0D0C8FFC5C5C5FFE3E3E1FFEDEDEFFF3E3E9EFF0C0C98FF
          0A0AA6FF0A0AA8FF0A0AA9FF2B2BB0FFC0C0CDFFEAEAE2FFEBEBEBFFFEFEF8FF
          EDEDEEFF2828BDFF0707C4FF0809C7FF0F0FC4FF8788CBFFEBEBECFE79797AF1
          6A6A6B256A6A6B609D9E9DF6D6D7E4FF3A3AB3FF1212ADFF0A0AA8FF0A0AA4FF
          1313AAFFABABCFFFD6D6CBFFCACACAFFC6C6C6FFE4E4E0FFEEEEEFFF3F3FA0FF
          0C0C99FF0A0AA6FF2828ABFFB2B2BFFFD8D8CEFFD6D6D8FFE0E0E0FFF6F5EDFF
          D1D1EDFF1E1CC0FF0707BEFF0707BFFF0707C0FF2120AAFFD3D5E9FE9FA0A0F6
          6A6A6B606A6A6B94BDBDBDFBBABBDCFF3A39B7FF2F2FB8FF0909ADFF0A0AA9FF
          0A0AA6FF1515ACFFADADCFFFD6D6CBFFCBCBCAFFC6C6C6FFE4E4E1FFEEEEEFFF
          3838A1FF2222A2FFACABB8FFC8C8C0FFC7C7C8FFCDCDCDFFE1E1D9FFC8CAE1FF
          2424BCFF0808B4FF0808B9FF0808BAFF0808BBFF0F0EABFFA1A2D5FEC0C0C0FC
          6A6A6B946A6A6BC0D9D8D7FE9999D1FF3838BBFF3636BCFF2C2CB7FF0909ADFF
          0A0AA9FF0A0AA4FF1C1CAFFFB1B1CFFFD6D6CBFFCCCCCBFFC7C7C7FFE4E4E1FF
          ECECEEFFACACB7FFC2C2BCFFBEBEBFFFC0C0C0FFCFCFC6FFC1C1D5FF2727B8FF
          0909ACFF0909B2FF0909B2FF0909B4FF0808B4FF0E0EB5FF6E6EBFFFD9D9D9FE
          6A6A6BC06A6A6BE1EBEAEBFF7D7CC7FF3838BFFF3434BEFF3536BEFF2A2AB8FF
          0909B0FF0909ACFF0A0AA8FF1C1CB1FFB2B2D0FFD7D7CCFFCBCBCBFFC7C7C8FF
          C8C8C3FFC6C6C3FFBFBFC1FFBDBDBDFFC5C5BCFFB8B8CEFF2929B5FF0A0AA8FF
          0909ACFF0909ADFF0909AFFF0909AFFF0909AFFF0C0CB0FF4747AFFFECECEDFF
          6A6A6BE16A6A6BF8F9F9F9FF6666C1FF3838C4FF3535C2FF3434C0FF3535BEFF
          3030BCFF1313B4FF0909ADFF0A0AA8FF1E1EB3FFAAAAD0FFD3D3CDFFCCCCCCFF
          C8C8C8FFC3C3C3FFC2C2C1FFC4C4BFFFB2B2CBFF2B2BB4FF0A0AA4FF0A0AA8FF
          0A0AA8FF0A0AA9FF0A0AA9FF0A0AA9FF0A0AA9FF0B0BA9FF3131A6FFFAFAFAFF
          6A6A6BF86A6A6BF8FBFBFBFF5959BEFF3B3BCAFF3A3AC8FF3737C4FF3535C2FF
          3636C0FF3636BEFF2323B8FF0909B1FF0A0AA7FF4949BEFFD6D6D4FFD3D3D1FF
          CDCDCDFFC8C8C8FFC4C4C3FFEDEDEDFF5F5FB3FF0C0C98FF0A0AA7FF0A0AA6FF
          0A0AA6FF0A0AA6FF0A0AA4FF0A0AA6FF0A0AA4FF0B0BA4FF2D2DA6FFFBFBFBFF
          6A6A6BF86A6A6BE1EDEDEEFF7F80CBFF4041CCFF3C3CCAFF3A3AC8FF383AC8FF
          3838C4FF3636C2FF3939C0FF2123B7FF4A4AC2FFCBCBDEFFE0E0DCFFD6D6D6FF
          D2D2D3FFCDCDCEFFC9C9C9FFE2E2E1FFF1F1F2FF4242A3FF0C0C99FF0A0AA4FF
          0A0AA4FF0A0AA4FF0B0BA3FF0B0BA3FF0B0BA1FF0E0EA1FF4443B0FFEDEDEEFF
          6A6A6BE16A6A6BC0DADADAFF9C9BD5FE4949CDFF3E3DD0FF3C3DCEFF3C3CCAFF
          3A3AC8FF3B39C7FF2828BDFF5C5CCCFFE5E5EDFFF4F4EDFFE5E5E6FFDEDEDEFF
          DCDCD9FFD9D9D3FFCDCDCDFFC8C8C8FFE5E5E1FFF1F1F3FF3F3FA0FF0C0C99FF
          0A0AA4FF0B0BA1FF0B0BA0FF0B0BA0FF0B0B9FFF1313A2FF6B6BC0FFDADADAFF
          6A6A6BC06A6A6B94C0C0C0FDBDBAE1FE5655CFFF4141D4FF3F3FD2FF3F3FCEFF
          3D3DCCFF2C2AC3FF5E5ED3FFEBEBF6FFFFFFFAFFF1F1F1FFEDEDEEFFF0F0E9FF
          D2D2E6FFBDBDD6FFDADAD3FFCFCFCFFFC9C9CAFFE5E5E2FFF1F1F3FF3A3AA0FF
          0C0C98FF0B0BA3FF0B0B9FFF0B0B9EFF0B0B9EFF1C1CA4FF9C9CD3FFC1C1C1FD
          6A6A6B946A6A6B609F9F9FF6DAD9EAFF6B6BCFFF4444D7FF4143D6FF4242D3FF
          3434CDFF6464DBFFEFEFFFFFFFFFFFFFFCFCFCFFF6F6F6FFFCFCF4FFE2E1F0FF
          5050CCFF4040C1FFC3C3DBFFE1E1D8FFD4D4D5FFCFCFCFFFE8E8E5FFF2F2F4FF
          4040A2FF0C0C99FF0F0FA2FF0F0FA0FF0F0F9DFF302FA9FFD1D1E8FEA0A0A0F6
          6A6A6B606A6A6B25787879F1E9E9EBFEA7A7DAFF6060DBFF4547DBFF3C3CD6FF
          5857DEFFF2F2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE8E8F8FF5B5BD4FF
          2828BDFF2A2BBDFF4949C5FFC3C3DBFFE4E4DAFFD5D5D5FFCECED0FFE8E8E5FF
          F4F4F4FF4949AFFF2121A6FF2A2AA6FF2C2BA9FF5557B8FFEAEAECFE787879F1
          6A6A6B25000000007575769EBEBEBEFDC9CAE6FF7A79DBFF4C4CDFFF4141DBFF
          5757E0FFEAEAFFFFFFFFFFFFFFFFFFFFFFFFFFFFE8E7FFFF5B5BD7FF2E2EC6FF
          3E3EC9FF3A3AC5FF2C2EC1FF4A49C8FFC2C2DDFFE3E3DAFFD5D5D4FFDADAD3FF
          CACBD9FF4747BBFF2525ADFF2C2BACFF3332AEFFA5A4D8FFBFBFBFFD7575769E
          00000000000000006A6A6B40888889F0ECECEFFE9696D6FF7B7BE3FF4D4BE0FF
          4141DBFF5F5FE6FFE7E7FFFFFFFFFFFFE9E9FFFF5A5ADCFF3333CAFF4242CFFF
          4040CBFF3D3DC9FF3D3EC8FF3030C2FF4848C9FFC0C0DDFFECEEDEFFD0D0E0FF
          5554C7FF2828B3FF3232B4FF3434B1FF5453B7FFECECEFFE888889F06A6A6B40
          0000000000000000000000007C7C7C98B7B7B8FAD0D0ECFF8F8FDBFF6868E3FF
          4E4EE2FF3E40DBFF6565E9FFB2B2F7FF6565E4FF393BD2FF4646D7FF4343D4FF
          4343D1FF4242CFFF4040CBFF3F3FCAFF3333C4FF4E4ECBFF9E9EE2FF5C5BCFFF
          292ABAFF3636BCFF3938B8FF3F3EB1FFCBCBE9FFB7B7B8FA7C7C7C9800000000
          0000000000000000000000006A6A6B22838383D8D3D3D3FEB5B5E2FF9E9EE4FF
          6766E2FF4E50E6FF4646E0FF3D3DDAFF4444DCFF4B4BDCFF4848DBFF4847D9FF
          4646D5FF4443D3FF4343D1FF4242CFFF4143CDFF3A3AC8FF312FC5FF3535C3FF
          3C3CC3FF3D3DBEFF403FB5FFACACDCFFD3D3D3FE838383D86A6A6B2200000000
          000000000000000000000000000000006A6A6B43878788EAE1E1E1FFB5B5E2FF
          A7A6E4FF7877E5FF5151E5FF4F4FE4FF4E4EE2FF4D4DE0FF4C4CDEFF4B4BDCFF
          4949DBFF4848D7FF4747D5FF4545D3FF4545D1FF4343CFFF4242CCFF3F3FCBFF
          4343C2FF4645B6FFADADDCFFE1E1E1FF878788EA6A6A6B430000000000000000
          00000000000000000000000000000000000000006A6A6B4E878788EAD3D3D3FE
          D0D0ECFFAAA9DFFFA2A2ECFF6565E3FF5151E6FF4F4FE4FF4F4DE4FF4D4DE0FF
          4D4DDFFF4D4DDCFF4C49DBFF4A4AD8FF4749D6FF4747D4FF4949CBFF4B4BC3FF
          8E8ED0FFCDCCE8FFD3D3D3FE878788EA6A6A6B4E000000000000000000000000
          0000000000000000000000000000000000000000000000006A6A6B43838383D8
          B7B7B8FAECECEFFEC3C2E5FFADAEE1FF9E9DE8FF6F6FE0FF5C5CE1FF5452E2FF
          5051E1FF4F4FDFFF4F4FDBFF5150D6FF5151CFFF5F5FC8FFA1A1D3FEC7C8E0FE
          E4E4E7FEB7B7B8FA838383D86A6A6B4300000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000006A6A6B22
          7C7C7C98888889F0BFBFBFFDEBEBECFED8D9EBFEBDBDE4FEA8A7DCFF9695D7FF
          8886D4FF7F7DCEFF8C8BD2FFA1A2D9FFC0BEE1FED9D9EAFEEAEAECFEBFBFBFFD
          888889F07C7C7C986A6A6B220000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000006A6A6B407575769E787879F19F9F9FF6C0C0C0FDDADADAFFEDEDEEFF
          FBFBFBFFFBFBFBFFEDEDEEFFDADADAFFC0C0C0FD9F9F9FF6787879F17575769E
          6A6A6B4000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000006A6A6B256A6A6B606A6A6B946A6A6BC06A6A6BE1
          6A6A6BF86A6A6BF86A6A6BE16A6A6BC06A6A6B946A6A6B606A6A6B2500000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000FFC003FFFF0000FFFC00003FF800001FF000000FE0000007C0000003
          C000000380000001800000010000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000080000001
          80000001C0000003C0000003E0000007F000000FF800001FFC00003FFF0000FF
          FFC003FF}
        ShowUnicode = False
        ColWidths = (
          20
          34
          44
          94
          94
          94
          64
          120)
        RowHeights = (
          34
          46)
      end
      object pBar: TProgressBar
        Left = 15
        Top = 739
        Width = 598
        Height = 9
        Position = 50
        BarColor = clChartreuse
        BackgroundColor = clBtnText
        Step = 2
        TabOrder = 3
        Visible = False
        StyleElements = []
      end
      object btnPickDTTreeView: TButton
        Left = 555
        Top = 98
        Width = 58
        Height = 50
        Hint = 'Tree-View. Quick access and browse for session, event and heat.'
        DisabledImages = AppData.vimglistDTEvent
        ImageIndex = 10
        ImageName = 'TreeView_W'
        Images = AppData.vimglistDTEvent
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnClick = btnPickDTTreeViewClick
      end
    end
    object pnlTool2: TPanel
      AlignWithMargins = True
      Left = 1303
      Top = 3
      Width = 144
      Height = 767
      Anchors = []
      BevelOuter = bvNone
      Color = clDimgray
      ParentBackground = False
      TabOrder = 3
      object stackpnlTool2: TStackPanel
        Left = 0
        Top = 84
        Width = 144
        Height = 269
        BevelOuter = bvNone
        ControlCollection = <
          item
            Control = sbtnSyncDTtoSCM
            HorizontalPositioning = sphpLeft
          end
          item
            Control = spbtnPost
            HorizontalPositioning = sphpLeft
          end
          item
            Control = sbtnAutoPatch
            HorizontalPositioning = sphpLeft
          end
          item
            Control = ShapeSpacer
          end
          item
            Control = btnDataDebug
          end>
        HorizontalPositioning = sphpCenter
        Spacing = 4
        TabOrder = 0
        object sbtnSyncDTtoSCM: TSpeedButton
          Left = 0
          Top = 0
          Width = 128
          Height = 41
          Hint = 'Syncronize Dolphin Timing to SCM.'
          Caption = 'SYNC'
          Images = AppData.vimglistMenu
          ParentShowHint = False
          ShowHint = True
          OnClick = actnSyncTDExecute
        end
        object spbtnPost: TSpeedButton
          Left = 0
          Top = 45
          Width = 128
          Height = 41
          Hint = 'Post the DT '#39'Race-Times'#39' to the SCM heat.'
          Caption = 'POST'
          Images = AppData.vimglistMenu
          ParentShowHint = False
          ShowHint = True
          OnClick = actnPostExecute
        end
        object sbtnAutoPatch: TSpeedButton
          Left = 0
          Top = 90
          Width = 128
          Height = 41
          Hint = 'Auto-Patch lanes and enable manual patching.'
          Caption = 'PATCH'
          ImageIndex = 14
          ImageName = 'AutoPatch'
          Images = AppData.vimglistMenu
          Enabled = False
          ParentShowHint = False
          ShowHint = True
        end
        object ShapeSpacer: TShape
          AlignWithMargins = True
          Left = 11
          Top = 141
          Width = 121
          Height = 4
          Margins.Top = 6
          Margins.Bottom = 6
          Brush.Color = clTomato
        end
        object btnDataDebug: TButton
          Left = 17
          Top = 155
          Width = 109
          Height = 40
          Caption = 'Data Debug'
          TabOrder = 0
          OnClick = btnDataDebugClick
        end
      end
    end
  end
  object StatBar: TStatusBar
    Left = 0
    Top = 798
    Width = 1444
    Height = 35
    Hint = 'Check here for information, messages and warnings.'
    Panels = <>
    ParentShowHint = False
    ShowHint = True
    SimplePanel = True
    SimpleText = 'Check here for information and messages.'
    StyleElements = [seClient, seBorder]
  end
  object FileSaveDlgMeetProgram: TFileSaveDialog
    DefaultExtension = '.json'
    DefaultFolder = 'c:\TimeDrops\Meets'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'JSON  (*.json)'
        FileMask = '*.json'
      end
      item
        DisplayName = 'Any file type (*.*)'
        FileMask = '*.*'
      end>
    OkButtonLabel = 'Save TD Meet Program file'
    Options = []
    Title = 'Create a Time Drops '#39'Meet Program'#39' file.'
    Left = 984
    Top = 480
  end
  object PickDTFolderDlg: TFileOpenDialog
    DefaultFolder = 'c:\Dolphin\Meets'
    FavoriteLinks = <>
    FileTypes = <>
    OkButtonLabel = 'Select DT folder'
    Options = [fdoPickFolders]
    Title = 'Select the Dolphin Timing folder.'
    Left = 984
    Top = 424
  end
  object DTAppendFile: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Dolphin Timing DO3 file.'
        FileMask = '*.DO3'
      end
      item
        DisplayName = 'Dolphin Timing DO4 file.'
        FileMask = '*.DO4'
      end
      item
        DisplayName = 'All Dolphin DO types.'
        FileMask = '*.DO*'
      end>
    FileTypeIndex = 3
    OkButtonLabel = 'Append DO file(s)'
    Options = [fdoStrictFileTypes, fdoAllowMultiSelect, fdoPathMustExist, fdoFileMustExist]
    Title = 'Append Dolphin Timing DO[3..4] files(s)...'
    Left = 983
    Top = 548
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 6000
    OnTimer = Timer1Timer
    Left = 1116
    Top = 374
  end
  object actnManager: TActionManager
    ActionBars = <
      item
        Items = <
          item
            Items = <
              item
                Action = actnRefresh
                Caption = '&Refresh'
                ImageIndex = 4
                ImageName = 'Sync'
              end
              item
                Caption = '-'
              end
              item
                Action = actnSelectSwimClub
                Caption = 'Sele&ct Swimming Club...'
                ImageIndex = 2
                ImageName = 'document_search'
              end
              item
                Action = actnSelectSession
                Caption = '&Select SwimClubMeet Session...'
                ImageIndex = 2
                ImageName = 'document_search'
              end
              item
                Caption = '-'
              end
              item
                Action = actnSaveSession
                Caption = 'S&ave SCM-TD Session ...'
                ImageIndex = 1
                ImageName = 'file_saveAlt'
              end
              item
                Action = actnLoadSession
                Caption = '&Load SCM-TD Session ...'
                ImageIndex = 0
                ImageName = 'file_open'
              end
              item
                Caption = '-'
              end
              item
                Items = <
                  item
                    Action = actnClearReScanMeets
                    Caption = '&Clear and re-scan TD meets folder ...'
                    ImageIndex = 10
                    ImageName = 'scan'
                  end
                  item
                    Action = actnImportAppendDO
                    Caption = '&Import Time Drops Result file(s) ...'
                    ImageIndex = 0
                    ImageName = 'file_open'
                  end>
                Caption = '&Import'
              end
              item
                Items = <
                  item
                    Action = actnExportMeetProgram
                    Caption = '&Export Time-Drops Meet Program ...'
                    ImageIndex = 1
                    ImageName = 'file_saveAlt'
                  end
                  item
                    Action = actnReConstructTDResultFiles
                    Caption = '&Re-construct and export Time-Drops Results ...'
                    ImageIndex = 9
                    ImageName = 'build'
                  end>
                Caption = '&Export'
              end>
            Caption = '&File'
          end
          item
            Items = <
              item
                Action = actnSyncTD
                Caption = '&Sync TD to SCM'
                ImageIndex = 11
                ImageName = 'arrow_back'
              end
              item
                Action = actnSyncSCM
                Caption = 'S&ync SCM to TD'
                ImageIndex = 15
                ImageName = 'arrow_forward'
              end
              item
                Action = actnPost
                Caption = 'P&OST'
                ImageIndex = 13
                ImageName = 'PostDTData'
              end
              item
                Caption = '-'
              end
              item
                Action = actnPreferences
                Caption = '&Preferences ...'
                ImageIndex = 3
                ImageName = 'Settings'
              end>
            Caption = '&Edit'
          end
          item
            Items = <
              item
                Action = actnReportSCMSession
                Caption = '&SwimClubMeet Session Report...'
                ImageIndex = 12
                ImageName = 'file_report'
              end
              item
                Action = actnReportSCMEvent
                Caption = 'S&wimClubMeet Event Report...'
                ImageIndex = 12
                ImageName = 'file_report'
              end
              item
                Action = actnReportTD
                Caption = '&Time Drops Report...'
                ImageIndex = 12
                ImageName = 'file_report'
              end>
            Caption = '&Reports'
          end
          item
            Items = <
              item
                Action = actnAbout
                Caption = '&About SCM TimeDrops ...'
                ImageIndex = 8
                ImageName = 'Help'
              end>
            Caption = '&Help'
          end>
        ActionBar = actnMenuBar
      end>
    Images = AppData.vimglistMenu
    Left = 984
    Top = 368
    StyleName = 'Platform Default'
    object actnRefresh: TAction
      Category = 'File'
      Caption = 'Refresh'
      ImageIndex = 4
      ImageName = 'Sync'
      OnExecute = actnRefreshExecute
    end
    object actnSelectSwimClub: TAction
      Category = 'File'
      Caption = 'Select Swimming Club...'
      Enabled = False
      ImageIndex = 2
      ImageName = 'document_search'
    end
    object actnSelectSession: TAction
      Category = 'File'
      Caption = 'Select SwimClubMeet Session...'
      ImageIndex = 2
      ImageName = 'document_search'
      OnExecute = actnSelectSessionExecute
    end
    object actnExportMeetProgram: TAction
      Category = 'Export'
      Caption = 'Export Time-Drops Meet Program ...'
      ImageIndex = 1
      ImageName = 'file_saveAlt'
      OnExecute = actnExportMeetProgramExecute
      OnUpdate = actnExportMeetProgramUpdate
    end
    object actnReConstructTDResultFiles: TAction
      Category = 'Export'
      Caption = 'Re-construct and export Time-Drops Results ...'
      ImageIndex = 9
      ImageName = 'build'
      OnExecute = actnReConstructTDResultFilesExecute
      OnUpdate = actnReConstructTDResultFilesUpdate
    end
    object actnPreferences: TAction
      Category = 'Edit'
      Caption = 'Preferences ...'
      ImageIndex = 3
      ImageName = 'Settings'
      OnExecute = actnPreferencesExecute
    end
    object actnImportAppendDO: TAction
      Category = 'Import'
      Caption = 'Import Time Drops Result file(s) ...'
      ImageIndex = 0
      ImageName = 'file_open'
      OnExecute = actnImportDTResultExecute
    end
    object actnClearReScanMeets: TAction
      Category = 'Import'
      Caption = 'Clear and re-scan TD meets folder ...'
      ImageIndex = 10
      ImageName = 'scan'
      OnExecute = actnClearReScanMeetsExecute
    end
    object actnSaveSession: TAction
      Category = 'File'
      Caption = 'Save SCM-TD Session ...'
      Enabled = False
      ImageIndex = 1
      ImageName = 'file_saveAlt'
    end
    object actnLoadSession: TAction
      Category = 'File'
      Caption = 'Load SCM-TD Session ...'
      Enabled = False
      ImageIndex = 0
      ImageName = 'file_open'
    end
    object actnAbout: TAction
      Category = 'Help'
      Caption = 'About SCM TimeDrops ...'
      ImageIndex = 8
      ImageName = 'Help'
    end
    object actnSyncTD: TAction
      Category = 'Edit'
      Caption = 'Sync TD to SCM'
      ImageIndex = 11
      ImageName = 'arrow_back'
      OnExecute = actnSyncTDExecute
    end
    object actnConnect: TAction
      Category = 'Edit'
      Caption = 'Connect'
      ImageIndex = 5
      ImageName = 'link'
    end
    object actnPost: TAction
      Category = 'Edit'
      Caption = 'POST'
      ImageIndex = 13
      ImageName = 'PostDTData'
      OnExecute = actnPostExecute
      OnUpdate = actnPostUpdate
    end
    object actnReportSCMSession: TAction
      Category = 'Reports'
      Caption = 'SwimClubMeet Session Report...'
      ImageIndex = 12
      ImageName = 'file_report'
    end
    object actnReportSCMEvent: TAction
      Category = 'Reports'
      Caption = 'SwimClubMeet Event Report...'
      ImageIndex = 12
      ImageName = 'file_report'
    end
    object actnReportTD: TAction
      Category = 'Reports'
      Caption = 'Time Drops Report...'
      ImageIndex = 12
      ImageName = 'file_report'
    end
    object actnSyncSCM: TAction
      Category = 'Edit'
      Caption = 'Sync SCM to TD'
      ImageIndex = 15
      ImageName = 'arrow_forward'
      OnExecute = actnSyncSCMExecute
    end
  end
end
