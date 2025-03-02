object TreeViewData: TTreeViewData
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'QUICK SELECT...'
  ClientHeight = 620
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  TextHeight = 21
  object TV: TTreeView
    Left = 0
    Top = 0
    Width = 492
    Height = 563
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    HideSelection = False
    Images = AppData.vimglistTreeView
    Indent = 30
    ParentFont = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    OnDblClick = TVDblClick
    Items.NodeData = {
      070200000009540054007200650065004E006F00640065002F00000000000000
      00000000FFFFFFFFFFFFFFFF0000000000000000000200000001085300650073
      00730069006F006E0031000000310000000000000000000000FFFFFFFFFFFFFF
      FF000000000000000000000000000109460069006C0065004E0061006D006500
      31000000310000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      00000000000109460069006C0065004E0061006D006500320000002F00000000
      00000000000000FFFFFFFFFFFFFFFF0000000000000000000200000001085300
      65007300730069006F006E0032000000310000000000000000000000FFFFFFFF
      FFFFFFFF000000000000000000000000000109460069006C0065004E0061006D
      00650033000000310000000000000000000000FFFFFFFFFFFFFFFF0000000000
      00000000000000000109460069006C0065004E0061006D0065003400}
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 563
    Width = 492
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      492
      57)
    object btnClose: TButton
      Left = 391
      Top = 12
      Width = 100
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnCloseClick
    end
    object btnCancel: TButton
      Left = 285
      Top = 12
      Width = 100
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
