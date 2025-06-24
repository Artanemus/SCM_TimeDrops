object NoodleFrame: TNoodleFrame
  Left = 0
  Top = 0
  Width = 150
  Height = 521
  TabOrder = 0
  object pbNoodles: TPaintBox
    Left = 0
    Top = 0
    Width = 150
    Height = 521
    Align = alClient
    Color = clBtnFace
    ParentColor = False
    PopupMenu = pumenuNoodle
    OnMouseDown = pbNoodlesMouseDown
    OnMouseMove = pbNoodlesMouseMove
    OnMouseUp = pbNoodlesMouseUp
    OnPaint = pbNoodlesPaint
    ExplicitWidth = 144
    ExplicitHeight = 581
  end
  object pumenuNoodle: TPopupMenu
    Left = 64
    Top = 336
    object DeleteNoodle: TMenuItem
      Action = actDeleteNoodle
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Noodledetails1: TMenuItem
      Action = actNoodleInfo
    end
  end
  object actnList: TActionList
    Left = 64
    Top = 440
    object actDeleteNoodle: TAction
      Category = 'Noodles'
      Caption = 'Delete Noodle'
      Enabled = False
      OnExecute = actDeleteNoodleExecute
      OnUpdate = actDeleteNoodleUpdate
    end
    object actDisableNoodle: TAction
      Category = 'Noodles'
      Caption = 'Disable Noodle'
      Enabled = False
    end
    object actDisablePatches: TAction
      Category = 'Noodles'
      AutoCheck = True
      Caption = 'Disable ALL Noodles'
      Enabled = False
    end
    object actNoodleInfo: TAction
      Category = 'Noodles'
      Caption = 'Noodle details ...'
      OnExecute = actNoodleInfoExecute
      OnUpdate = actNoodleInfoUpdate
    end
  end
end
