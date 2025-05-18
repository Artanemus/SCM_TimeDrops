object NoodleFrame: TNoodleFrame
  Left = 0
  Top = 0
  Width = 185
  Height = 648
  TabOrder = 0
  object pbNoodles: TPaintBox
    Left = 0
    Top = 0
    Width = 185
    Height = 648
    Align = alClient
    Color = clBtnFace
    ParentColor = False
    OnMouseDown = pbNoodlesMouseDown
    OnMouseMove = pbNoodlesMouseMove
    OnMouseUp = pbNoodlesMouseUp
    OnPaint = pbNoodlesPaint
    ExplicitWidth = 144
    ExplicitHeight = 581
  end
  object vimgDL1: TVirtualImage
    Left = 70
    Top = 564
    Width = 30
    Height = 30
    ImageCollection = IMG.imgcolDT
    ImageWidth = 0
    ImageHeight = 0
    ImageIndex = 14
    ImageName = 'EvBlue'
  end
end
