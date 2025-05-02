object InfoScanResults: TInfoScanResults
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Scan the TimeDrops meets folder...'
  ClientHeight = 305
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  TextHeight = 21
  object pnlBody: TPanel
    Left = 0
    Top = 0
    Width = 525
    Height = 248
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object chkbDoShowAgain: TCheckBox
      Left = 10
      Top = 406
      Width = 303
      Height = 21
      Caption = 'Don'#39't show this info dialogue again.'
      TabOrder = 0
    end
    object RichEditInfo: TRichEdit
      Left = 0
      Top = 0
      Width = 525
      Height = 248
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      Lines.Strings = (
        '**Instructions for Scan the TimeDrops meets folder.**'
        ''
        '1. **Scan**'
        '   - The Time-Drops meets folder will be scanned.'
        '   - Any new '#39'results'#39' not in the Time-Drops grid will be added.'
        
          '   - Any updated '#39'results'#39' will be handled safely and lane data ' +
          'updated.'
        '   - A scan can be considered a '#39'Refresh'#39'.'
        ''
        '3. **Next Steps**  '
        '   - Select OK to start the scan process.')
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 248
    Width = 525
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnCancel: TButton
      Left = 321
      Top = 11
      Width = 98
      Height = 36
      Caption = 'Cancel'
      TabOrder = 0
      OnClick = btnCancelClick
    end
    object btnOk: TButton
      Left = 425
      Top = 10
      Width = 98
      Height = 36
      Caption = 'SCAN'
      TabOrder = 1
      OnClick = btnOkClick
    end
    object chkbHideInfoBox: TCheckBox
      Left = 0
      Top = 17
      Width = 249
      Height = 26
      Caption = 'Hide extended info and help.'
      TabOrder = 2
    end
  end
end
