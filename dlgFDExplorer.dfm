object FDExplorer: TFDExplorer
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FireDAC'#39's Explorer Application.'
  ClientHeight = 346
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
    Height = 289
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 624
    ExplicitHeight = 382
    object lblBodyText2: TLabel
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 578
      Height = 269
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alClient
      AutoSize = False
      Caption = 
        'Press Ok to start the stand-alone FireDAC'#39's Connection Explorer.' +
        ' '#13#10#13#10'To modify the SCM_TimeDrops FDConnectionDef.ini file, '#13#10'1. ' +
        'Once the app is running, press the '#39'Open ConnDef File'#39'  button a' +
        'nd ...'#13#10'2. Paste into the  filename editbox ... '#13#10'          %App' +
        'Data%\Artanemus\SCM\FDConnectionDefs.ini'#13#10'   (Or browse to the u' +
        'ser'#39's appdata folder. By default this is a hidden system file.'#13#10 +
        '    %SYSTEMDRIVE%\Users\%USERNAME%\AppData\Roaming\Artanemus\SCM' +
        ')'#13#10'3. Press Open.'#13#10'4. You will see the available connection defi' +
        'nitions. Select MSSQL_SwimClubMeet.'#13#10#13#10'Here you can modify, dele' +
        'te and create connection parameters. Save your changes and test ' +
        'the connection.'
      WordWrap = True
      ExplicitWidth = 604
      ExplicitHeight = 311
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 289
    Width = 598
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 382
    ExplicitWidth = 624
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
