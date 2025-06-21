object NoodleInfo: TNoodleInfo
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Noodle Details ...'
  ClientHeight = 178
  ClientWidth = 209
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object pnlFooter: TPanel
    Left = 0
    Top = 135
    Width = 209
    Height = 43
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 125
    ExplicitWidth = 225
    object btnOk: TButton
      Left = 67
      Top = 6
      Width = 75
      Height = 33
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnOkClick
    end
  end
  object rpnlDetail: TRelativePanel
    Left = 0
    Top = 33
    Width = 209
    Height = 102
    ControlCollection = <
      item
        Control = pnlSCM
        AlignBottomWithPanel = True
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = True
        AlignRightWithPanel = False
        AlignTopWithPanel = True
        AlignVerticalCenterWithPanel = False
      end
      item
        Control = pnlTDS
        AlignBottomWithPanel = True
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = False
        AlignRightWithPanel = False
        AlignTopWithPanel = True
        AlignVerticalCenterWithPanel = False
        RightOf = pnlSCM
      end>
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 96
    ExplicitTop = 224
    ExplicitWidth = 185
    ExplicitHeight = 41
    DesignSize = (
      209
      102)
    object pnlSCM: TPanel
      Left = 0
      Top = 0
      Width = 105
      Height = 102
      BevelOuter = bvNone
      TabOrder = 0
      object lblSCMSess: TLabel
        Left = 0
        Top = 16
        Width = 42
        Height = 15
        Alignment = taRightJustify
        Caption = 'Session:'
      end
      object lblSCMEv: TLabel
        Left = 10
        Top = 37
        Width = 32
        Height = 15
        Alignment = taRightJustify
        Caption = 'Event:'
      end
      object lblSCMHt: TLabel
        Left = 14
        Top = 58
        Width = 28
        Height = 15
        Alignment = taRightJustify
        Caption = 'Heat:'
      end
      object lblSCML: TLabel
        Left = 14
        Top = 79
        Width = 28
        Height = 15
        Alignment = taRightJustify
        Caption = 'Lane:'
      end
      object lbl1: TLabel
        Left = 48
        Top = 16
        Width = 34
        Height = 15
        Caption = 'Label1'
      end
      object lbl2: TLabel
        Left = 48
        Top = 37
        Width = 34
        Height = 15
        Caption = 'Label2'
      end
      object lbl3: TLabel
        Left = 48
        Top = 58
        Width = 34
        Height = 15
        Caption = 'Label3'
      end
      object lbl4: TLabel
        Left = 48
        Top = 79
        Width = 34
        Height = 15
        Caption = 'Label4'
      end
    end
    object pnlTDS: TPanel
      Left = 105
      Top = 0
      Width = 105
      Height = 102
      Anchors = []
      BevelOuter = bvNone
      TabOrder = 1
      object lblTDSSess: TLabel
        Left = 0
        Top = 16
        Width = 42
        Height = 15
        Alignment = taRightJustify
        Caption = 'Session:'
      end
      object lblTDSEv: TLabel
        Left = 10
        Top = 37
        Width = 32
        Height = 15
        Alignment = taRightJustify
        Caption = 'Event:'
      end
      object lblTDSHt: TLabel
        Left = 14
        Top = 58
        Width = 28
        Height = 15
        Alignment = taRightJustify
        Caption = 'Heat:'
      end
      object lblTDSL: TLabel
        Left = 14
        Top = 79
        Width = 28
        Height = 15
        Alignment = taRightJustify
        Caption = 'Lane:'
      end
      object lbl5: TLabel
        Left = 48
        Top = 16
        Width = 34
        Height = 15
        Caption = 'Label5'
      end
      object lbl6: TLabel
        Left = 48
        Top = 37
        Width = 34
        Height = 15
        Caption = 'Label6'
      end
      object lbl7: TLabel
        Left = 48
        Top = 58
        Width = 34
        Height = 15
        Caption = 'Label7'
      end
      object lbl8: TLabel
        Left = 48
        Top = 79
        Width = 34
        Height = 15
        Caption = 'Label8'
      end
    end
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 209
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 258
    object lblH1: TLabel
      Left = 0
      Top = 12
      Width = 81
      Height = 15
      Caption = 'SwimClubMeet'
    end
    object lblH2: TLabel
      Left = 119
      Top = 12
      Width = 57
      Height = 15
      Caption = 'TimeDrops'
    end
  end
end
