object ScanOptions: TScanOptions
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Time Drops Scan.'
  ClientHeight = 306
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  TextHeight = 21
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 360
    Height = 97
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblHeader: TLabel
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 340
      Height = 77
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alClient
      Alignment = taCenter
      Caption = 
        'Scan for '#39'results'#39' files in the TimeDrops the '#39'meets'#39' folder. Se' +
        'arch for modified or new '#39'results'#39' files.'
      Layout = tlCenter
      WordWrap = True
      ExplicitWidth = 300
      ExplicitHeight = 63
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 97
    Width = 360
    Height = 160
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 240
    ExplicitTop = 232
    ExplicitWidth = 185
    ExplicitHeight = 41
    object lblSessionID: TLabel
      Left = 173
      Top = 120
      Width = 72
      Height = 21
      Alignment = taRightJustify
      Caption = 'Session ID'
    end
    object rgrpScanOptions: TRadioGroup
      Left = 43
      Top = 6
      Width = 273
      Height = 105
      Caption = 'Scan options ...'
      ItemIndex = 0
      Items.Strings = (
        'Scan ALL.'
        'Scan for a specific session.')
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object edtSessionID: TEdit
      Left = 251
      Top = 117
      Width = 65
      Height = 29
      NumbersOnly = True
      TabOrder = 1
      Text = '9999'
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 257
    Width = 360
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = 392
    ExplicitWidth = 624
    object btnOk: TButton
      Left = 183
      Top = 8
      Width = 83
      Height = 33
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 94
      Top = 8
      Width = 83
      Height = 33
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
