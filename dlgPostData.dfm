object PostData: TPostData
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Post Data ...'
  ClientHeight = 289
  ClientWidth = 471
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  RoundedCorners = rcOn
  OnKeyDown = FormKeyDown
  TextHeight = 21
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 471
    Height = 49
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object vimgPostData: TVirtualImage
      Left = 56
      Top = 1
      Width = 48
      Height = 48
      ImageCollection = AppData.imgcolDT
      ImageWidth = 0
      ImageHeight = 0
      ImageIndex = 73
      ImageName = 'PostDTData'
    end
    object lblHeaderTitle: TLabel
      Left = 110
      Top = 14
      Width = 280
      Height = 21
      Caption = 'Post Time-Drops data to SwimClubMeet.'
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 49
    Width = 471
    Height = 165
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object rgrpSelection: TRadioGroup
      Left = 67
      Top = 27
      Width = 337
      Height = 111
      Caption = 'Items to post ...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'Post ALL.'
        'Post selected lanes.')
      ParentFont = False
      TabOrder = 0
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 214
    Width = 471
    Height = 75
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnCancel: TButton
      Left = 132
      Top = 19
      Width = 101
      Height = 37
      Caption = 'Cancel'
      Default = True
      TabOrder = 0
      OnClick = btnCancelClick
    end
    object btnOk: TButton
      Left = 239
      Top = 19
      Width = 101
      Height = 37
      Caption = 'POST'
      TabOrder = 1
      OnClick = btnOkClick
    end
  end
end
