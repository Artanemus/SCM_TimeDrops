object FDExplorer: TFDExplorer
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FireDAC'#39's Explorer Application.'
  ClientHeight = 456
  ClientWidth = 598
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
    Width = 598
    Height = 399
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 289
    object memoInfo: TMemo
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 592
      Height = 393
      Align = alClient
      EditMargins.Left = 10
      EditMargins.Right = 10
      Lines.Strings = (
        'Press Ok to start the stand-alone FireDAC'#39's Connection Explorer.'
        ''
        'To modify the SCM_TimeDrops FDConnectionDef.ini file,'
        
          '1. Once the app is running, press the '#39'Open ConnDef File'#39'  butto' +
          'n and ...'
        '2. Enter into the filename editbox ...'
        '          %AppData%\Artanemus\SCM'
        
          '   (Or browse to the user'#39's appdata folder. AppData is a hidden ' +
          'system file.'
        '    Full path: %SYSTEMDRIVE%\Users\%USERNAME%\AppData\Roaming'
        '\Artanemus\SCM)'
        '3. Select file FDConnectionDefs.ini'
        '4. Press Open.'
        
          '5. You will see the available connection definitions. Select MSS' +
          'QL_SwimClubMeet.'
        ''
        
          'Here you can modify, delete and create connection parameters. Sa' +
          've your '
        'changes and test the connection.')
      ReadOnly = True
      TabOrder = 0
      ExplicitLeft = 0
      ExplicitTop = 8
      ExplicitWidth = 578
      ExplicitHeight = 410
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 399
    Width = 598
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 289
    object btnOk: TButton
      Left = 302
      Top = 12
      Width = 89
      Height = 33
      Caption = 'Ok'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 207
      Top = 12
      Width = 89
      Height = 33
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
