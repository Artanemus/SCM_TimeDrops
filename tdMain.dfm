object Main: TMain
  Left = 0
  Top = 0
  Caption = 'SwimClubMeet - Time Drops'
  ClientHeight = 441
  ClientWidth = 521
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 21
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 521
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = 'SWIMCLUBMEET - TIME DROPS'
    TabOrder = 0
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 392
    Width = 521
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnExit: TButton
      Left = 218
      Top = 10
      Width = 85
      Height = 28
      Caption = 'Exit'
      TabOrder = 0
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 41
    Width = 521
    Height = 351
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object sbtnBoot: TSpeedButton
      Left = 56
      Top = 88
      Width = 145
      Height = 97
      Caption = 'Boot'
      Layout = blGlyphTop
    end
    object sbtnBuildXMLCreate: TSpeedButton
      Left = 288
      Top = 88
      Width = 145
      Height = 97
      Caption = 'Build XML Data'
      Layout = blGlyphTop
    end
  end
end
