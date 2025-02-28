object DataDebug: TDataDebug
  Left = 0
  Top = 0
  Caption = 'DataDebug'
  ClientHeight = 635
  ClientWidth = 971
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  TextHeight = 17
  object pgcntrlData: TPageControl
    Left = 0
    Top = 0
    Width = 971
    Height = 635
    ActivePage = grid
    Align = alClient
    TabOrder = 0
    object grid: TTabSheet
      Caption = 'Session'
      object dbgridSession: TDBGrid
        Left = 0
        Top = 0
        Width = 963
        Height = 603
        Align = alClient
        DataSource = DTData.dsDTSession
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object tabsheetEvent: TTabSheet
      Caption = 'Event'
      ImageIndex = 1
      object dbgridEvent: TDBGrid
        Left = 0
        Top = 0
        Width = 963
        Height = 605
        Align = alClient
        DataSource = DTData.dsDTEvent
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object tabsheetHeat: TTabSheet
      Caption = 'Heat'
      ImageIndex = 2
      object dbgridHeat: TDBGrid
        Left = 0
        Top = 0
        Width = 963
        Height = 605
        Align = alClient
        DataSource = DTData.dsDTHeat
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object tabsheetEntrant: TTabSheet
      Caption = 'Entrant'
      ImageIndex = 3
      object dbgridEntrant: TDBGrid
        Left = 0
        Top = 0
        Width = 963
        Height = 605
        Align = alClient
        DataSource = DTData.dsDTEntrant
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object tabsheetNoodle: TTabSheet
      Caption = 'Noodle'
      ImageIndex = 4
      object dbgridNoodle: TDBGrid
        Left = 0
        Top = 0
        Width = 963
        Height = 603
        Align = alClient
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
end
