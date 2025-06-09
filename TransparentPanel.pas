unit TransparentPanel;

interface

uses
  System.Classes, Vcl.Controls, Vcl.ExtCtrls, Winapi.Messages, Winapi.Windows, Vcl.Graphics, Vcl.Themes;

type
  TTransparentPanel = class(TCustomPanel)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property BorderStyle;
    property Caption;
    property Color;
    property Constraints;
    property Ctl3D;
    property UseDockManager default True;
    property DockSite;
    property DoubleBuffered;
    property DoubleBufferedMode;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FullRepaint;
    property Font;
    property Locked;
    property Padding;
    property ParentBiDiMode;
    property ParentBackground;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowCaption;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Touch;
    property VerticalAlignment;
    property Visible;
    property StyleElements;
    property StyleName;
    property OnAlignInsertBefore;
    property OnAlignPosition;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnGetSiteInfo;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TTransparentPanel]);
end;

{ TTransparentPanel }

constructor TTransparentPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone; // Remove any border
end;

procedure TTransparentPanel.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  // Make the panel transparent by setting the extended window style
  Params.ExStyle := Params.ExStyle or WS_EX_TRANSPARENT;
end;

procedure TTransparentPanel.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  // Prevent erasing the background to maintain transparency
  Message.Result := 1;
end;

procedure TTransparentPanel.Paint;
begin
  // Do nothing here to avoid painting the background
end;

end.
