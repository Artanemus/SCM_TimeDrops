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
    OnMouseDown = pbNoodlesMouseDown
    OnMouseMove = pbNoodlesMouseMove
    OnMouseUp = pbNoodlesMouseUp
    OnPaint = pbNoodlesPaint
    ExplicitWidth = 144
    ExplicitHeight = 581
  end
end
