object NoodleFrame: TNoodleFrame
  Left = 0
  Top = 0
  Width = 185
  Height = 648
  TabOrder = 0
  DesignSize = (
    185
    648)
  object pbNoodles: TPaintBox
    Left = 10
    Top = 17
    Width = 144
    Height = 581
    Anchors = []
    Color = clBtnFace
    ParentColor = False
    OnMouseDown = pbNoodlesMouseDown
    OnMouseMove = pbNoodlesMouseMove
    OnMouseUp = pbNoodlesMouseUp
    OnPaint = pbNoodlesPaint
    ExplicitLeft = 22
  end
  object vimgDL1: TVirtualImage
    Left = 22
    Top = 604
    Width = 30
    Height = 30
    ImageCollection = IMG.imgcolDT
    ImageWidth = 0
    ImageHeight = 0
    ImageIndex = 14
    ImageName = 'EvBlue'
  end
end
