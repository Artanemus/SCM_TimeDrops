object UserRaceTime: TUserRaceTime
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Enter a Race-Time ...'
  ClientHeight = 188
  ClientWidth = 307
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 21
  object pnlFooter: TPanel
    Left = 0
    Top = 123
    Width = 307
    Height = 65
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 0
    object btnOk: TButton
      Left = 157
      Top = 15
      Width = 106
      Height = 34
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 45
      Top = 15
      Width = 106
      Height = 34
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object rpnlBody: TRelativePanel
    Left = 0
    Top = 0
    Width = 307
    Height = 123
    ControlCollection = <
      item
        Control = edtRaceTimeUser
        AlignBottomWithPanel = False
        AlignHorizontalCenterWithPanel = True
        AlignLeftWithPanel = False
        AlignRightWithPanel = False
        AlignTopWithPanel = False
        AlignVerticalCenterWithPanel = True
      end
      item
        Control = lblErrMsg
        AlignBottomWithPanel = False
        AlignHorizontalCenterWithPanel = False
        AlignLeftWithPanel = False
        AlignRightWithPanel = False
        AlignTopWithPanel = False
        AlignVerticalCenterWithPanel = False
      end>
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      307
      123)
    object edtRaceTimeUser: TEdit
      Left = 69
      Top = 39
      Width = 169
      Height = 45
      Alignment = taCenter
      Anchors = []
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = '00:00.000'
    end
    object lblErrMsg: TLabel
      Left = 0
      Top = 96
      Width = 307
      Height = 21
      Alignment = taCenter
      Anchors = []
      AutoSize = False
      Caption = 'Enter the swimmers racetime.'
    end
  end
end
