object ReConstructDlg: TReConstructDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'ReConstruct & Export Time-Drops Results.'
  ClientHeight = 202
  ClientWidth = 658
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 21
  object pnlFooter: TPanel
    Left = 0
    Top = 145
    Width = 658
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 272
    ExplicitWidth = 655
    object btnOk: TButton
      Left = 256
      Top = 6
      Width = 240
      Height = 33
      Caption = 'Re-Construct && Export Results'
      Default = True
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 162
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
    Width = 658
    Height = 145
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 655
    ExplicitHeight = 272
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
      ImageCollection = AppData.imgcolDT
      ImageWidth = 0
      ImageHeight = 0
      ImageIndex = 77
      ImageName = 'info'
      OnMouseEnter = vimgInfo1MouseEnter
      OnMouseLeave = vimgInfo1MouseLeave
    end
    object btnedtExportFolder: TButtonedEdit
      Left = 3
      Top = 60
      Width = 613
      Height = 29
      Images = AppData.vimglistDTGrid
      RightButton.ImageIndex = 1
      RightButton.ImageName = 'Folders'
      RightButton.Visible = True
      TabOrder = 0
      Text = 'c:\TimeDrops\Meets\'
      OnClick = btnedtExportFolderClick
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
    Left = 456
    Top = 17
  end
end
