unit uNoodleFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  System.Generics.Collections, Vcl.VirtualImage, System.Math,
  dmIMG, uNoodleLink, System.Types, Vcl.StdCtrls, SCMDefines, Vcl.Menus,
  System.Actions, Vcl.ActnList;

type
  // State for dragging operations
  TNoodleDragState = (ndsIdle, ndsDraggingNew, ndsDraggingExistingHandle);

type
  TNoodleFrame = class(TFrame)
    actDeleteNoodle: TAction;
    actnList: TActionList;
    DeleteNoodle: TMenuItem;
    pbNoodles: TPaintBox;
    pumenuNoodle: TPopupMenu;
    procedure actDeleteNoodleExecute(Sender: TObject);
    procedure actDeleteNoodleUpdate(Sender: TObject);
    procedure pbNoodlesMouseDown(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
    procedure pbNoodlesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pbNoodlesMouseUp(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
    procedure pbNoodlesPaint(Sender: TObject);
  private
    FDefaultRowHeight: integer;
    FMousePoint: TPoint;

    FDragHandle: TNoodleHandle;
    FDragAnchoured: TNoodleHandle;
    FDragLink: TNoodleLink;

    FDragState: TNoodleDragState;
    FDragColor: TColor;
    FHandleColor: TColor;
    FHotSpots: Array of TRect;
    FHotSpotStartIndex: integer;
    FHotSpotStartRect: TRect;
    FixedRowHeight: integer;   // identical to SCM TMS TAdvDBGrid.
    FLinkColor: TColor;
    FNoodles: TObjectList<TNoodleLink>; // Noodles
    FRopeColor: TColor;
    FRopeThickness: Integer;
    FSelectedHandleColor: TColor;
    FSelectedLinkColor: TColor;
    FSelectedLink: TNoodleLink;
    FSelectedRopeColor: TColor;
    FNumberOfLanes: integer;
    procedure InitializeHotSpots;
    procedure ClearLinkSelection;
    procedure DrawNoodleHandle(ACanvas: TCanvas; P: TPoint; AColor: TColor;
        ARadius: Integer);
    procedure DrawNoodleLink(ACanvas: TCanvas; P0, P1: TPointF; AColor: TColor;
        AThickness: Integer; ASelected: Boolean);
    procedure DrawQuadraticBezierCurve(ACanvas: TCanvas; P0, P1, P2: TPoint;
        NumSegments: Integer);
    function TryGetHandleAtHotSpot(P: TPoint; out ANoodleHandle: TNoodleHandle):
        Boolean;
    procedure TryGetHandlePtrAtPoint(P: TPoint; out AHandlePtr: TNoodleHandleP);
    function SelectNoodleLink: TNoodleLink; overload;
    function TryHitTestNoodle(P: TPoint; out HitLink: TNoodleLink; out HitHandle:
        TNoodleHandle): Boolean; overload;
    function TryHitTestHotSpot(P: TPoint; out ARect: TRect; out index: integer):
        boolean;
    procedure SelectNoodleLink(ALink: TNoodleLink); overload;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property SelectedLink: TNoodleLink read SelectNoodleLink;
  end;


var
  NoodleFrame: TNoodleFrame;

  FPreviewHitTolerance: Integer = 5; // Pixels tolerance for hitting HotSpots.


implementation

{$R *.dfm}


constructor TNoodleFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); // Call the inherited constructor

  FNoodles := TObjectList<TNoodleLink>.Create(True); // True = OwnsObjects
  FDragState := ndsIdle;
  FSelectedLink := nil;
  FDragLink := nil;

  // --- Configure COLORS ---
  FDragColor := clBlack;
  FRopeColor := clLtGray;
  FHandleColor := clLtGray;
  FLinkColor := clLtGray;

  FSelectedRopeColor := clHighlight;
  FSelectedHandleColor := clHighlight;
  FSelectedLinkColor := clHighlight;

  FRopeThickness := 4;
  // ASSERT : Ensure PaintBox is on top and covers the grid areas
  pbNoodles.BringToFront;

  FixedRowHeight:= 34;   // identical to SCM TMS TAdvDBGrid.
  FDefaultRowHeight:= 46; // identical to SCM TMS TAdvDBGrid.
  FNumberOfLanes:= 10;  // dbo.SwimClubMeet.SwimClub.NumOfLanes.

  InitializeHotSpots; // draw DOTS in left and right coloumns.

end;

destructor TNoodleFrame.Destroy;
begin
  fNoodles.Free;  // release noodle collection.
  // Custom cleanup code here
  inherited Destroy; // Call the inherited destructor
end;

procedure TNoodleFrame.actDeleteNoodleExecute(Sender: TObject);
var
  ALink: TNoodleLink;
begin
  // delete the noodle
  for ALink in FNoodles do
  begin
    if ALink.IsSelected then
    begin
      FNoodles.Remove(ALink); // This will free the object - if OwnsObjects is True
      FSelectedLink := nil; // Clear the selected link
      pbNoodles.Invalidate; // Redraw without the deleted link
      // Optional: Trigger OnLinkDeleted event
      // if Assigned(FOnLinkDeleted) then FOnLinkDeleted(Self, LinkToDelete);
      break;
    end;
  end;
end;

procedure TNoodleFrame.actDeleteNoodleUpdate(Sender: TObject);
begin
  // if cursor position is over a noodle.
  // if the noodle at the cursor position is selected.
  // if the array fNoodles is not empty.
  if FNoodles.Count > 0 then
  begin
    if FSelectedLink <> nil then
    begin
      if not TAction(Sender).Enabled then
        TAction(Sender).Enabled := True;
    end
    else
    begin
      if TAction(Sender).Enabled then
        TAction(Sender).Enabled := false;
    end;
  end
  else
  begin
    if TAction(Sender).Enabled then
      TAction(Sender).Enabled := false;
  end;
end;

procedure TNoodleFrame.InitializeHotSpots;
var
I, J, indx: integer;
ARect: TRect;
begin
  SetLength(FHotSpots, (FNumberOfLanes*2));
  indx := FNumberOfLanes;
  for i:=0 to FNumberOfLanes-1 do
  begin
    ARect.Top := FixedRowHeight + (i*FDefaultRowHeight);
    Arect.Left := 0;
    ARect.Height := FDefaultRowHeight;
    ARect.Width := FDefaultRowHeight;
    FHotSpots[i] := ARect;
  end;
  for J:=0 to FNumberOfLanes-1 do
  begin
    ARect.Top := FixedRowHeight + (j*FDefaultRowHeight);
    Arect.Left := Width - FDefaultRowHeight;
    ARect.Height := FDefaultRowHeight;
    ARect.Width := FDefaultRowHeight;
    FHotSpots[indx+J] := ARect;
  end;
end;

procedure TNoodleFrame.ClearLinkSelection;
var
  Link: TNoodleLink;
begin
  // Also iterate just in case state is inconsistent
  for Link in FNoodles do
    Link.IsSelected := False;
  FSelectedLink := nil; // Ensure this is cleared
end;

procedure TNoodleFrame.DrawNoodleHandle(ACanvas: TCanvas; P: TPoint; AColor:
    TColor; ARadius: Integer);
begin
  ACanvas.Brush.Color := AColor;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Pen.Color := clBlack; // Optional outline
  ACanvas.Pen.Width := 1;
  ACanvas.Ellipse(P.X - ARadius, P.Y - ARadius, P.X + ARadius + 1, P.Y + ARadius + 1);
  ACanvas.Brush.Style := bsClear; // Reset brush
end;

procedure TNoodleFrame.DrawNoodleLink(ACanvas: TCanvas; P0, P1: TPointF;
    AColor: TColor; AThickness: Integer; ASelected: Boolean);
var
  P_Control, A, B: TPoint;
  MidPointX, MidPointY, Distance, ActualSag: Double;
begin
  // Calculate control point for Bezier
  MidPointX := (P0.X + P1.X) / 2;
  MidPointY := (P0.Y + P1.Y) / 2;
  Distance := System.Math.Hypot(P1.X - P0.X, P1.Y - P0.Y);

  ActualSag := 0.0;
  if Distance > 10 then ActualSag := Distance * scmSagFactor;

  P_Control.X := Round(MidPointX);
  P_Control.Y := Round(MidPointY + ActualSag); // Simple vertical sag

  // Setup pen
  ACanvas.Pen.Color := AColor;
  ACanvas.Pen.Width := AThickness;
  ACanvas.Pen.Style := psSolid;

  A.X := ROUND(P0.X);
  A.Y := ROUND(P0.Y);
  B.X := ROUND(P1.X);
  B.Y := ROUND(P1.Y);

  // Draw the Bezier curve
  DrawQuadraticBezierCurve(ACanvas, A, P_Control, B, 30); // 30 segments

  // Draw DOTS for handles.
  if ASelected then
  begin
    DrawNoodleHandle(ACanvas, A, FSelectedHandleColor, FHandleRadius);
    DrawNoodleHandle(ACanvas, B, FSelectedHandleColor, FHandleRadius);
  end
  else
  begin
    DrawNoodleHandle(ACanvas, A, FHandleColor, FHandleRadius);
    DrawNoodleHandle(ACanvas, B, FHandleColor, FHandleRadius);
  end;
end;

procedure TNoodleFrame.DrawQuadraticBezierCurve(ACanvas: TCanvas; P0, P1, P2:
    TPoint; NumSegments: Integer);
var
  i: Integer;
  t: Single;
  pt: TPoint;
begin
  if NumSegments < 1 then NumSegments := 1;
  ACanvas.MoveTo(P0.X, P0.Y);

  for i := 1 to NumSegments do
  begin
    t := i / NumSegments;
    // Quadratic Bezier formula: B(t) = (1-t)^2 * P0 + 2*(1-t)*t * P1 + t^2 * P2
    pt.X := Round(Power(1 - t, 2) * P0.X + 2 * (1 - t) * t * P1.X + Power(t, 2) * P2.X);
    pt.Y := Round(Power(1 - t, 2) * P0.Y + 2 * (1 - t) * t * P1.Y + Power(t, 2) * P2.Y);
    ACanvas.LineTo(pt.X, pt.Y);
  end;
end;

procedure TNoodleFrame.TryGetHandlePtrAtPoint(P: TPoint; out AHandlePtr:
    TNoodleHandleP);
var
  I: Integer;
  Link: TNoodleLink;
  PFloat: TPointF;
begin
  AHandlePtr := nil;
  PFloat := TPointF.Create(P.X, P.Y);
  for I := 0 to FNoodles.Count - 1 do
  begin
    Link := FNoodles[I];
    Link.FindHandlePtrAtPoint(PFloat, AHandlePtr); // <-- Pass as var/out
    if AHandlePtr <> nil then
      Exit;
  end;
end;

function TNoodleFrame.TryGetHandleAtHotSpot(P: TPoint; out ANoodleHandle:
    TNoodleHandle): Boolean;
var
  HandleRadiusSq: Int64;
//  DistSq: Int64;
  CenterF: TPointF;
  DistSqF: Double;
  HotSpot: TRect;
  AHandle: TNoodleHandle;
  ALink: TNoodleLink;
begin
  Result := False;
  ANoodleHandle.Clear;
  HandleRadiusSq := FHandleRadius * FHandleRadius; // margin of acceptance.
  for HotSpot in FHotSpots do
  begin
    if HotSpot.IsEmpty then continue;
    CenterF := HotSpot.CenterPoint;
    DistSqF := (P.X - CenterF.X) * (P.X - CenterF.X) + (P.Y - CenterF.Y) * (P.Y - CenterF.Y);
    if DistSqF <= HandleRadiusSq then
    begin
      if TryHitTestNoodle(HotSpot.CenterPoint, ALink, AHandle) then
      begin
        if AHandle.IsValid then
        begin
          ANoodleHandle := AHandle;
          Result := True;
          Exit; // Found a noodle handle within margin of acceptance.
        end;
      end;
    end;
  end;
end;

function TNoodleFrame.SelectNoodleLink: TNoodleLink;
var
  Link: TNoodleLink;
begin
  result := nil;
  // Also iterate just in case state is inconsistent
  for Link in FNoodles do
  begin
    if Link.IsSelected then
    begin
      result := Link;
      exit;
    end;
  end;
end;

function TNoodleFrame.TryHitTestNoodle(P: TPoint; out HitLink: TNoodleLink; out
    HitHandle: TNoodleHandle): Boolean;
var
  Link: TNoodleLink;
  ANoodleHandle: TNoodleHandle;
  i: Integer;
begin
  Result := False;
  HitLink := nil;
  HitHandle.Clear; // Assign an empty HitHandle...

  // Iterate through the Noodles
  for i := 0 to FNoodles.Count - 1 do
  begin
    Link := FNoodles[i]; // Get the link at the current index
    if Link.IsPointOnLinkOrHandle(P, ANoodleHandle) then
    begin
      Result := True;
      HitLink := Link;
      // point must be located on a noddle handle for assignment.
      // else point is located on link's connection line.
      if ANoodleHandle.IsValid then
      begin
        HitHandle := ANoodleHandle;
        FSelectedLink := HitLink;
      end;
      Exit; // Exit as soon as a match is found
    end;
  end;
end;

function TNoodleFrame.TryHitTestHotSpot(P: TPoint; out ARect: TRect; out index:
    integer): boolean;
var
I: integer;
begin
  result := false;
  for I := Low(FHotSpots)  to High(FHotSpots) do
  begin
    if FHotSpots[I].Contains(P) then
    begin
      ARect := FHotSpots[I];
      index := I;
      result := true;
      exit;
    end;
  end;
end;

procedure TNoodleFrame.pbNoodlesMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
var
  HitLink: TNoodleLink;
  HitHandle: TNoodleHandle;
  ARect: TRect;
  index: integer;
begin
  if Button <> mbLeft then Exit;

  FMousePoint := Point(X, Y);
  ClearLinkSelection; // Deselect previous link first

  // 1. Check if clicking on an NoodleHandle
  if TryHitTestNoodle(FMousePoint, HitLink, HitHandle) then
  // TryHitTestNoodle returns lepSource for line hit, lepDestination or lepSource for specific handle
  begin
    if HitHandle.IsValid then
    begin
      FDragState := ndsDraggingExistingHandle;
      FDragLink := HitLink; // Store the link being dragged.
      FDragHandle := HitHandle; // Store which handle has been clicked.
      HitLink.GetOtherHandle(HitHandle, FDragAnchoured); // Assign Anchour Handle.
      SelectNoodleLink(HitLink); // Select the link visually
      pbNoodles.Invalidate;
      Exit; // Don't check for other things
    end
    else
    begin
      // 2. Clicked on an existing link's LINE (not handles)
      SelectNoodleLink(HitLink);
      pbNoodles.Invalidate;
      // Don't start drag, just select
      Exit;
    end;
  end;

  // 3. Check if clicking on a HotSpot
  if TryHitTestHotSpot(FMousePoint, ARect, index) then
  begin
    FDragState := ndsDraggingNew;
    FHotSpotStartRect := ARect;
    FHotSpotStartIndex := index;
    pbNoodles.Invalidate; // Show drag preview
    Exit;
  end;

  // 4. Clicked on empty space
  ClearLinkSelection; // Already done, but good practice
  pbNoodles.Invalidate; // Redraw without selection

end;

procedure TNoodleFrame.pbNoodlesMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
begin
  if FDragState <> ndsIdle then
  begin
    FMousePoint := Point(X, Y);
    pbNoodles.Invalidate; // Redraw preview line
  end;
  // Add hover effects here if desired (check TryHitTestNoodle/FindNoodleHandleAtHotSpot)
end;

procedure TNoodleFrame.pbNoodlesMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
var
  EndPoint, P0, P1: TPoint;
  NewLink: TNoodleLink;
  ExistingLink: TNoodleLink;
  FHotSpotRect: TRect;
  FHotSpotIndex: integer;
  IsDuplicate: boolean;
begin
  if Button <> mbLeft then Exit;
  EndPoint := Point(X, Y);

  if FDragState = ndsDraggingNew then
  begin
    // CHECKS
    // --- Validation: Prevent linking dot to itself or same grid row ---
    if TryHitTestHotSpot(FMousePoint, FHotSpotRect, FHotSpotIndex) then
    begin
      // released button over starting hotspot - exit...
      if (FHotSpotIndex = FHotSpotStartIndex) then
      begin
        FDragState := ndsIdle;
        pbNoodles.Invalidate; // Redraw final state
        exit;
      end;
      //  - illegal patch - Dragging onto the same side.
      P0 := FHotSpotStartRect.CenterPoint;
      P1 := FHotSpotRect.CenterPoint;
      if (ROUND(P1.X) = ROUND(P0.X)) then
      begin
        FDragState := ndsIdle;
        pbNoodles.Invalidate; // Redraw final state
        exit;
      end;
      // before creating link - Check if this will be a duplicate link.
      IsDuplicate := false;
      for ExistingLink in FNoodles do
      begin
          // Check both directions
          if (ExistingLink.NoodleHandleStart.CenterF = P0) or
              (ExistingLink.NoodleHandleEnd.CenterF = P1) or
             (ExistingLink.NoodleHandleStart.CenterF = P1)  or
              (ExistingLink.NoodleHandleEnd.CenterF = P0) then
          begin
              IsDuplicate := True;
              Break;
          end;
      end;

      if not IsDuplicate then
      begin
        // Create the new link
        NewLink := TNoodleLink.Create(FHotSpotStartRect, FHotSpotRect);
        FNoodles.Add(NewLink);
        SelectNoodleLink(NewLink); // DeSelect all then Select the newly created link
        // Optional: Trigger an OnLinkCreated event here
        // if Assigned(FOnLinkCreated) then FOnLinkCreated(Self, NewLink);
        FDragState := ndsIdle;
        pbNoodles.Invalidate; // Redraw final state
        exit;
      end
      else
      begin
        FDragState := ndsIdle;
        pbNoodles.Invalidate; // Redraw final state
        exit;
      end;
    end;

    FDragState := ndsIdle;
    pbNoodles.Invalidate; // Redraw final state
  end;

  if FDragState = ndsDraggingExistingHandle then
  begin
    var AHandlePtr: TNoodleHandleP;
    // QUICK TEST - is it dropped over a HotSpot = valid drop zone.
    if TryHitTestHotSpot(FMousePoint, FHotSpotRect, FHotSpotIndex) then
    begin
      TryGetHandlePtrAtPoint(FMousePoint, AHandlePtr);
      if AHandlePtr = nil then
      begin
        FDragLink.GetOtherHandlePtr(FDragAnchoured, AHandlePtr);
        // Go modify the active Noodle's handle...
        AHandlePtr.ARectF := TRectF.Create(FHotSpotRect);
        AHandlePtr.IsValid := true;
        AHandlePtr.CenterF := FHotSpotRect.CenterPoint;
        FDragLink.IsSelected := true;
        FDragState := ndsIdle;
        FDragLink := nil; // Clear the link being dragged.
        pbNoodles.Invalidate; // Redraw final state
      end;
    end;
  end;
end;

procedure TNoodleFrame.pbNoodlesPaint(Sender: TObject);
var
  Link: TNoodleLink;
  P0, P1: TPointF;
  Spot: TPoint;
  HotSpot: TRect;
  Canvas: TCanvas;
  AColor: TColor;
//  BitMap: TBitMap;
  deflate, indx: integer;
//  LText: String;
begin
  Canvas := (Sender as TPaintBox).Canvas;
  Canvas.Brush.Style := bsClear; // Make background transparent (won't erase grids)

  // draw the under lining HotSpots
  for HotSpot in FHotSpots do
  begin
    deflate := ((FDefaultRowHeight - IMG.vimglistDTGrid.Height) DIV 2);
    HotSpot.inflate(-deflate, -deflate);
    IMG.vimglistDTGrid.Draw(Canvas, HotSpot.Left, HotSpot.Top, 'EvBlue', true);
  end;

  // 1. Draw all existing noodles
  for Link in FNoodles do
  begin
    // Only draw if both endpoints are valid.
    if (not Link.NoodleHandleStart.IsValid) or (not Link.NoodleHandleEnd.IsValid) then continue;
    P0 := Link.NoodleHandleStart.CenterF;
    P1 := Link.NoodleHandleEnd.CenterF;;
    // ASSERT : Only draw if both endpoints are valid.
    if (P0.IsZero or P1.IsZero) then continue;
    if Link.IsSelected then
      AColor := FSelectedLinkColor else  AColor := FLinkColor;
    DrawNoodleLink(Canvas, P0, P1, AColor, FRopeThickness, Link.IsSelected);
  end;

  // 2. DRAWPREVIEW LINE AND START AND END ICONS.
  if FDragState = ndsDraggingNew then
  begin
    // Draw from start dot to current mouse pos
    P0 := FHotSpotStartRect.CenterPoint;
    P1 := FMousePoint;
    DrawNoodleLink(Canvas, P0, P1, clBlack, FRopeThickness, False);
    // Draw the preview startpoint ...
    Spot := FHotSpotStartRect.CenterPoint;
    Spot.X := Spot.X - (IMG.vimglistDTGrid.Height DIV 2);
    Spot.Y := Spot.Y - (IMG.vimglistDTGrid.Height DIV 2);
    IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'DotCircle', true);
    // if the current point is hovering over a HotSpot - then show
    // the 'dragging' preview endpoint ...
    // this indicates to the user - a possible snap available
    if TryHitTestHotSpot(FMousePoint, HotSpot, indx) then
    begin
      // TEST :still dragging over starting hotspot?
      if (indx <> FHotSpotStartIndex) then
      begin
        Spot := FMousePoint;
        Spot.X := Spot.X - (IMG.vimglistDTGrid.Height DIV 2);
        Spot.Y := Spot.Y - (IMG.vimglistDTGrid.Height DIV 2);
        IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'DotCircle', true);
        // dragging preview onto the same side - illegal patch.
        // flag with icon.
        if (HotSpot.CenterPoint.X = P0.X) then
          IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'ActiveRTNone', true);
        end;
    end;
  end;

  if FDragState = ndsDraggingExistingHandle then
  begin
        // Draw from start dot to current mouse pos
    P0 := FDragAnchoured.CenterF;
    P1 := FMousePoint;

    DrawNoodleLink(Canvas, P0, P1, clLime, FRopeThickness, False);
    // if the current point is hovering over a HotSpot - then show
    // the 'dragging' preview endpoint ...
    // this indicates to the user - a possible snap available
    if TryHitTestHotSpot(FMousePoint, HotSpot, indx) then
    begin
      // still dragging over FDragStartPoint ...
      if (true) then
      begin
        Spot := FMousePoint;
        Spot.X := Spot.X - (IMG.vimglistDTGrid.Height DIV 2);
        Spot.Y := Spot.Y - (IMG.vimglistDTGrid.Height DIV 2);
        IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'DotCircle', true);
        // dragging preview onto the same side - illegal patch.
        // flag with icon.
        if (HotSpot.CenterPoint.X = P0.X) then
          IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'ActiveRTNone', true);
      end;
    end;
  end;

end;

procedure TNoodleFrame.SelectNoodleLink(ALink: TNoodleLink);
begin
  ClearLinkSelection; // Ensure only one is selected
  if ALink <> nil then
  begin
    ALink.IsSelected := True;
    FSelectedLink := ALink;
  end;
end;



end.
