object InfoClearRescanResults: TInfoClearRescanResults
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Clear and re-scan TimeDrops results.'
  ClientHeight = 504
  ClientWidth = 526
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  TextHeight = 21
  object pnlBody: TPanel
    Left = 0
    Top = 0
    Width = 526
    Height = 447
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
      Width = 526
      Height = 447
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      Lines.Strings = (
        
          '**Instructions for Clear grid and Re-Scan TimeDrops meets folder' +
          '**'
        ''
        '1. **Clear** '
        '   - The TimeDrops grid will be emptied of results.'
        
          '   - Work done in the TimeDrops grid will be lost. Such as patch' +
          'ing, race-'
        'time type selection, user Race-Time entry, etc.'
        
          '   - Any posted racetimes, made to SwimClubMeet, will remain int' +
          'act.'
        
          '   - There is no undo. (HINT: use '#39#39'Save SCM-DT Session'#39#39' to sto' +
          're all work '
        'prior to calling here.)'
        ''
        '2. **Re-Scan**  '
        '  - The Time-Drops meets folder will be re-scanned.'
        
          '  - A valid '#39'meets'#39' folder must exists with TimeDrops JSON resul' +
          't files,'
        'else your grid will appear empty.'
        
          '  - After the re-scan the grid will be repopulated with '#39'results' +
          #39'.'
        
          '  - A dialogue will appear to say the clear and re-scan has been' +
          ' done.'
        ''
        '3. **Next Steps**  '
        '   - Select OK to start the clear and re-scan process.')
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 447
    Width = 526
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
      Caption = 'OK'
      TabOrder = 1
      OnClick = btnOkClick
    end
    object chkbHideInfoBox: TCheckBox
      Left = 0
      Top = 17
      Width = 249
      Height = 26
      Caption = 'Don'#39't show this info box again.'
      TabOrder = 2
    end
  end
end
