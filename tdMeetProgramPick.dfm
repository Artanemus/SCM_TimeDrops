object MeetProgramPick: TMeetProgramPick
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Export Time Drops Meet Program...'
  ClientHeight = 329
  ClientWidth = 655
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 21
  object pnlFooter: TPanel
    Left = 0
    Top = 272
    Width = 655
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOk: TButton
      Left = 281
      Top = 6
      Width = 187
      Height = 33
      Caption = 'Export Meet Program'
      Default = True
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 187
      Top = 6
      Width = 88
      Height = 33
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 0
    Width = 655
    Height = 272
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object lblEventCSV: TLabel
      Left = 3
      Top = 33
      Width = 98
      Height = 21
      Caption = 'Export folder...'
    end
    object vimgInfo1: TVirtualImage
      Left = 622
      Top = 60
      Width = 28
      Height = 29
      ImageCollection = IMG.imgcolDT
      ImageWidth = 0
      ImageHeight = 0
      ImageIndex = 77
      ImageName = 'info'
      OnMouseEnter = vimgInfo1MouseEnter
      OnMouseLeave = vimgInfo1MouseLeave
    end
    object vimgInfo2: TVirtualImage
      Left = 239
      Top = 131
      Width = 28
      Height = 28
      ImageCollection = IMG.imgcolDT
      ImageWidth = 0
      ImageHeight = 0
      ImageIndex = 77
      ImageName = 'info'
      OnMouseEnter = vimgInfo2MouseEnter
      OnMouseLeave = vimgInfo2MouseLeave
    end
    object btnedtMeetProgram: TButtonedEdit
      Left = 3
      Top = 60
      Width = 613
      Height = 29
      Images = IMG.vimglistDTGrid
      RightButton.ImageIndex = 1
      RightButton.ImageName = 'Folders'
      RightButton.Visible = True
      TabOrder = 0
      Text = 'c:\TimeDrops\Meets\'
      OnRightButtonClick = btnedtMeetProgramRightButtonClick
    end
    object rgrpMeetProgramType: TRadioGroup
      Left = 3
      Top = 120
      Width = 230
      Height = 113
      Caption = 'Select type...'
      ItemIndex = 0
      Items.Strings = (
        'Basic Meet Program'
        'Detailed Meet Program')
      TabOrder = 1
    end
  end
  object BrowseFolderDlg: TFileOpenDialog
    DefaultExtension = '.JSON'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'JSON files '
        FileMask = '*.JSON'
      end
      item
        DisplayName = 'All Files'
        FileMask = '*.*'
      end>
    OkButtonLabel = 'Select Folder'
    Options = [fdoPickFolders, fdoDontAddToRecent]
    Title = 'Select Time Drops'#39#39' "Meet Program" folder.'
    Left = 364
    Top = 19
  end
  object BalloonHint1: TBalloonHint
    Left = 448
    Top = 17
  end
end
