object SessionPicker: TSessionPicker
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  BorderWidth = 2
  Caption = 'Select the SwimClubMeet swimming session ...'
  ClientHeight = 482
  ClientWidth = 546
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 21
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 546
    Height = 65
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object dbtxtClubName: TDBText
      Left = 0
      Top = 7
      Width = 168
      Height = 21
      AutoSize = True
      DataField = 'Caption'
      DataSource = AppData.dsSwimClub
    end
    object dbtxtNickName: TDBText
      Left = 0
      Top = 34
      Width = 134
      Height = 21
      AutoSize = True
      DataField = 'NickName'
      DataSource = AppData.dsSwimClub
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 428
    Width = 546
    Height = 54
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 455
      Top = 6
      Width = 91
      Height = 35
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 350
      Top = 6
      Width = 91
      Height = 35
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      Visible = False
      OnClick = btnCancelClick
    end
    object btnSelectClub: TButton
      Left = 0
      Top = 9
      Width = 165
      Height = 35
      Caption = 'Select Swim Club'
      Enabled = False
      TabOrder = 2
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 65
    Width = 546
    Height = 363
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object dbgridSession: TDBGrid
      Left = 0
      Top = 0
      Width = 546
      Height = 363
      Align = alClient
      DataSource = AppData.dsSessionList
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -16
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnDblClick = dbgridSessionDblClick
      Columns = <
        item
          Expanded = False
          FieldName = 'SessionID'
          Title.Alignment = taCenter
          Title.Caption = 'ID'
          Width = 50
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'SessionStart'
          Title.Caption = 'Session Date.Time'
          Width = 150
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Caption'
          Title.Caption = 'Description'
          Width = 300
          Visible = True
        end>
    end
  end
end
