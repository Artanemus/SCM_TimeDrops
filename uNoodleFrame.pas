unit uNoodleFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  System.Generics.Collections, Vcl.VirtualImage, System.Math,
//  BaseGrid, AdvGrid, DBAdvGrid,
  dmIMG, uNoodleLink, System.Types;

type
  // State for dragging operations
  TNoodleDragState = (ndsIdle, ndsDraggingNew, ndsDraggingExistingHandle);

type
  TNoodleFrame = class(TFrame)
    pbNoodles: TPaintBox;
    vimgDL1: TVirtualImage;
    procedure pbNoodlesMouseDown(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
    procedure pbNoodlesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pbNoodlesMouseUp(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
    procedure pbNoodlesPaint(Sender: TObject);
  private
    { Private declarations }
    FDragCurrentPoint: TPoint; // Current mouse position during drag (PaintBox coords)
    FDraggingHandle: TLinkPointType; // Which handle of FDraggingLink is being dragged
    FDraggingLink: TNoodleLink; // The existing link being dragged (if ndsDraggingExistingHandle)
    FDragStartConnPoint: TNoodleConnectionPoint; // Info about the dot where drag started
    FDragStartPoint: TPoint; // Point where drag started (PaintBox coords)
    FDragState: TNoodleDragState;
    FHandleColor: TColor;
    FHandleRadius: Integer;
    FHitTolerance: Integer; // Pixels tolerance for hitting lines/handles

    FNoodles: TObjectList<TNoodleLink>; // Noodles
    FConnectionPoints: Array[0..19] of TNoodleConnectionPoint;

    FRopeColor: TColor;
    FRopeThickness: Integer;
    // Configuration
    FSagFactor: Single;
    FSelectedLink: TNoodleLink;
    FSelectedRopeColor: TColor;

    FSourceDotColumn: Integer;
    FDestDotColumn: Integer;

    // Helper methods
    procedure DrawNoodle(ACanvas: TCanvas; P0, P1: TPoint; AColor: TColor; AThickness: Integer; ASelected: Boolean);
    procedure DrawQuadraticBezier(ACanvas: TCanvas; P0, P1, P2: TPoint; NumSegments: Integer); // Adapted for TPoint
    function FindConnectionPointAt(P: TPoint; out ConnPoint: TNoodleConnectionPoint): Boolean; // Find grid dot under point P
    function FindLinkAt(P: TPoint; out HitLink: TNoodleLink; out HitHandle: TLinkPointType): Boolean; // Find link/handle under point P
    procedure SelectLink(ALink: TNoodleLink);
    procedure DeselectAllLinks;
    procedure DrawHandle(ACanvas: TCanvas; P: TPoint; AColor: TColor; ARadius: Integer);


  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure UpdatePaintBoxBounds(gridSource, gridDest: TRect);
    procedure DeleteSelectedLink;

    { Public declarations }
    property DestDotColumn: Integer read FDestDotColumn write FDestDotColumn default 0;
    // *** Define your dot columns here (make consistent with NoodleLinkUnit) ***
    property SourceDotColumn: Integer read FSourceDotColumn write FSourceDotColumn default 1;
    property SelectedLink: TNoodleLink read fSelectedLink;


  end;

var
  NoodleFrame: TNoodleFrame;

implementation

{$R *.dfm}

uses frmMain;

constructor TNoodleFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); // Call the inherited constructor
  // Custom initialization code here
  // ---------------------------------------------------------------------
  // NOODLE INITIALISATION. BEGIN ...
  FNoodles := TObjectList<TNoodleLink>.Create(True); // True = OwnsObjects
  FDragState := ndsIdle;
  FSelectedLink := nil;
  FDraggingLink := nil;

  // --- Configure Appearance ---
  FSagFactor := 0.2;  // 20% sag relative to distance
  FRopeColor := clGray;
  FSelectedRopeColor := clHighlight;
  FRopeThickness := 2;
  FHandleColor := clRed;
  FHandleRadius := 4; // Size of the selection handles
  FHitTolerance := 5; // Click within 5 pixels to hit

  // Define dot columns
  FSourceDotColumn := 6; // Example: Column index for dots in AdvDBGrid1
  FDestDotColumn := 1;   // Example: Column index for dots in AdvDBGrid2

  // Ensure PaintBox is on top and covers the grid areas
  pbNoodles.BringToFront;

//  UpdatePaintBoxBounds; // Initial positioning

  // Hook grid scroll events to repaint noodles
//  scmGrid.OnScroll := AdvDBGridScroll;
//  tdsBGrid.OnScroll := AdvDBGridScroll;

  // NOODLE INITIALISATION. END.
  // ---------------------------------------------------------------------
end;

destructor TNoodleFrame.Destroy;
begin
  fNoodles.Free;  // release noodle collection.
  // Custom cleanup code here
  inherited Destroy; // Call the inherited destructor
end;

procedure TNoodleFrame.SelectLink(ALink: TNoodleLink);
begin
  DeselectAllLinks; // Ensure only one is selected
  if ALink <> nil then
  begin
    ALink.IsSelected := True;
    FSelectedLink := ALink;
  end;
end;

procedure TNoodleFrame.DeleteSelectedLink;
begin
  if FSelectedLink <> nil then
  begin
    var LinkToDelete := FSelectedLink;
    DeselectAllLinks; // Deselect first
    FNoodles.Remove(LinkToDelete); // TObjectList will Free it
    // Optional: Trigger OnLinkDeleted event
    // if Assigned(FOnLinkDeleted) then FOnLinkDeleted(Self, LinkToDelete);
    pbNoodles.Invalidate; // Redraw without the deleted link
  end;
end;

procedure TNoodleFrame.DeselectAllLinks;
var
  Link: TNoodleLink;
begin
  if FSelectedLink <> nil then
  begin
    FSelectedLink.IsSelected := False;
    FSelectedLink := nil;
  end;
  // Also iterate just in case state is inconsistent
  for Link in FNoodles do
    Link.IsSelected := False;
  FSelectedLink := nil; // Ensure this is cleared
end;

procedure TNoodleFrame.DrawHandle(ACanvas: TCanvas; P: TPoint; AColor: TColor;
  ARadius: Integer);
begin
  ACanvas.Brush.Color := AColor;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Pen.Color := clBlack; // Optional outline
  ACanvas.Pen.Width := 1;
  ACanvas.Ellipse(P.X - ARadius, P.Y - ARadius, P.X + ARadius + 1, P.Y + ARadius + 1);
  ACanvas.Brush.Style := bsClear; // Reset brush
end;

procedure TNoodleFrame.DrawNoodle(ACanvas: TCanvas; P0, P1: TPoint; AColor: TColor;
  AThickness: Integer; ASelected: Boolean);
var
  P_Control: TPoint;
  MidPointX, MidPointY, Distance, ActualSag: Double;
begin
  // Calculate control point for Bezier
  MidPointX := (P0.X + P1.X) / 2;
  MidPointY := (P0.Y + P1.Y) / 2;
  Distance := System.Math.Hypot(P1.X - P0.X, P1.Y - P0.Y);

  ActualSag := 0.0;
  if Distance > 10 then ActualSag := Distance * FSagFactor;

  P_Control.X := Round(MidPointX);
  P_Control.Y := Round(MidPointY + ActualSag); // Simple vertical sag

  // Setup pen
  ACanvas.Pen.Color := AColor;
  ACanvas.Pen.Width := AThickness;
  ACanvas.Pen.Style := psSolid;

  // Draw the Bezier curve
  DrawQuadraticBezier(ACanvas, P0, P_Control, P1, 30); // 30 segments

  // Draw handles if selected
  if ASelected then
  begin
    DrawHandle(ACanvas, P0, FHandleColor, FHandleRadius);
    DrawHandle(ACanvas, P1, FHandleColor, FHandleRadius);
  end;
end;

procedure TNoodleFrame.DrawQuadraticBezier(ACanvas: TCanvas; P0, P1, P2: TPoint;
  NumSegments: Integer);
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

function TNoodleFrame.FindConnectionPointAt(P: TPoint;
  out ConnPoint: TNoodleConnectionPoint): Boolean;
var
  HandleRadiusSq: Int64;
  DistSq: Int64;
  CenterF: TPointF;
  DistSqF: Double;
  CPoint: TNoodleConnectionPoint;
begin
  Result := False;
  ConnPoint.IsValid := False;
  HandleRadiusSq := FHandleRadius * FHandleRadius; // margin of acceptance.
  for CPoint in FConnectionPoints do
  begin
    if not CPoint.IsValid then continue;
    CenterF := CPoint.CenterF;
    DistSqF := (P.X - CenterF.X) * (P.X - CenterF.X) + (P.Y - CenterF.Y) * (P.Y - CenterF.Y);
    if DistSqF <= HandleRadiusSq then
    begin
      ConnPoint.CenterF := CPoint.CenterF; // Clone ConnectionPoint.
      ConnPoint.IsValid := True;
      ConnPoint.PointType := CPoint.PointType;
      ConnPoint.ARectF := CPoint.ARectF;
      Result := True;
      Exit; // Found a connection point within margin of acceptance.
    end;
  end;
end;

function TNoodleFrame.FindLinkAt(P: TPoint; out HitLink: TNoodleLink;
  out HitHandle: TLinkPointType): Boolean;
var
  Link: TNoodleLink;
  TempHandle: TLinkPointType;
  i: Integer;
begin
  Result := False;
  HitLink := nil;
  HitHandle := lptA; // Default

  // Iterate backwards through the TObjectList
  for i := FNoodles.Count - 1 downto 0 do
  begin
    Link := FNoodles[i]; // Get the link at the current index
    if Link.HitTest(P, FSagFactor, FHitTolerance, FHandleRadius, TempHandle) then
    begin
      Result := True;
      HitLink := Link;
      HitHandle := TempHandle;
      Exit; // Exit as soon as a match is found
    end;
  end;
end;


procedure TNoodleFrame.pbNoodlesMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
var
  ClickedPoint: TPoint;
  HitLink: TNoodleLink;
  HitHandle: TLinkPointType;
  HitConnPoint: TNoodleConnectionPoint;
begin
  if Button <> mbLeft then Exit;

  ClickedPoint := Point(X, Y);
  DeselectAllLinks; // Deselect previous link first

  // 1. Check if clicking on an existing link's HANDLE
  if FindLinkAt(ClickedPoint, HitLink, HitHandle) and (HitHandle <> lptA) then
  // HitTest returns lepSource for line hit, lepDestination or lepSource for specific handle
  begin
     // Check the exact position again to confirm it's a handle
     if System.Math.Hypot(ClickedPoint.X - HitLink.GetLinkPoint(HitHandle).X,
                          ClickedPoint.Y - HitLink.GetLinkPoint(HitHandle).Y) <= FHandleRadius then
     begin
        FDragState := ndsDraggingExistingHandle;
        FDraggingLink := HitLink; // Store the link being dragged
        FDraggingHandle := HitHandle; // Store which handle is grabbed
        FDragStartPoint := ClickedPoint;
        FDragCurrentPoint := ClickedPoint;
        SelectLink(HitLink); // Select the link visually
        pbNoodles.Invalidate;
        Exit; // Don't check for other things
     end;
  end;


  // 2. Check if clicking on an existing link's LINE (not handles)
  if FindLinkAt(ClickedPoint, HitLink, HitHandle) then // HitHandle will be default if line is hit
  begin
    SelectLink(HitLink);
    pbNoodles.Invalidate;
    // Don't start drag, just select
    Exit;
  end;

  // 3. Check if clicking on a connection point (a dot)
  if FindConnectionPointAt(ClickedPoint, HitConnPoint) then
  begin
    FDragState := ndsDraggingNew;
    FDragStartConnPoint := HitConnPoint; // Store grid/row/position of start
    FDragStartPoint := ClickedPoint;
    FDragCurrentPoint := ClickedPoint;
    pbNoodles.Invalidate; // Show drag preview
    Exit;
  end;

  // 4. Clicked on empty space
  DeselectAllLinks; // Already done, but good practice
  pbNoodles.Invalidate; // Redraw without selection

end;


procedure TNoodleFrame.pbNoodlesMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
begin
  if FDragState <> ndsIdle then
  begin
    FDragCurrentPoint := Point(X, Y);
    pbNoodles.Invalidate; // Redraw preview line
  end;
  // Add hover effects here if desired (check FindLinkAt/FindConnectionPointAt)
end;

procedure TNoodleFrame.pbNoodlesMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
var
  EndPoint: TPoint;
  EndConnPoint: TNoodleConnectionPoint;
  NewLink: TNoodleLink;
  ExistingLink: TNoodleLink;
begin
  if Button <> mbLeft then Exit;

  EndPoint := Point(X, Y);

  if FDragState = ndsDraggingNew then
  begin
  { // Check if dropped on a valid connection point }
    if FindConnectionPointAt(EndPoint, EndConnPoint) then
    begin
      // --- Validation: Prevent linking dot to itself or same grid row ---
      if (EndConnPoint.CenterF = FDragStartConnPoint.CenterF) then
      begin
         // Dropped on same start point, cancel
      end
      // --- Add more validation if needed
      // (e.g., prevent linking lptA to lptA) ---
      else if EndConnPoint.PointType = FDragStartConnPoint.PointType then
      begin
        // Linking identical point types if not allowed.
      end
      else
      begin
        // --- Check for duplicate link ---
        var IsDuplicate := False;
        for ExistingLink in FNoodles do
        begin
            // Check both directions
            if ((ExistingLink[0].CenterF = FDragStartConnPoint.CenterF) and
                (ExistingLink[1].CenterF = EndConnPoint.CenterF)) or
               ((ExistingLink[0].CenterF = EndConnPoint.CenterF)  and
                (ExistingLink[1].CenterF = FDragStartConnPoint.CenterF)) then
            begin
                IsDuplicate := True;
                Break;
            end;
        end;

        if not IsDuplicate then
        begin
            // Create the new link
            NewLink := TNoodleLink.Create(FDragStartConnPoint.ARectF, EndConnPoint.ARectF);
            FNoodles.Add(NewLink);
            SelectLink(NewLink); // Select the newly created link
            // Optional: Trigger an OnLinkCreated event here
            // if Assigned(FOnLinkCreated) then FOnLinkCreated(Self, NewLink);
        end
        else
        begin
            // Handle duplicate link (e.g., show message)
            ShowMessage('This link already exists.');
        end;

      end;
    end; // else: Dropped on empty space, cancel drag

    FDragState := ndsIdle;
    pbNoodles.Invalidate; // Redraw final state
  end

  else if FDragState = ndsDraggingExistingHandle then
  begin
      // Check if dropped on a valid connection point
      if FindConnectionPointAt(EndPoint, EndConnPoint) then
      begin
          // Validation: Prevent linking to self, etc.
          var IsValidTarget := True;
          var OriginalHandleA, OriginalHandleB: TNoodleConnectionPoint;

          OriginalHandleA := FDraggingLink.GetHandle(lptA);
          OriginalHandleB := FDraggingLink.GetHandle(lptB);


          if FDraggingHandle = lptA then // We are changing the Source endpoint
          begin
              // Check if new source is same as original destination
              if (EndConnPoint.CenterF = OriginalHandleB.CenterF) then
                 IsValidTarget := False;
              // Add other checks (e.g., prevent same grid connection if needed)
              // if EndConnPoint.Grid = OriginalHandleB then IsValidTarget := False;

              // Check for duplicate link with the new source
               for ExistingLink in FNoodles do
               begin
                   if ExistingLink = FDraggingLink then Continue; // Skip self
                   if ((ExistingLink.FHandles[0].CenterF = EndConnPoint.CenterF)  and
                       (ExistingLink.FHandles[1].CenterF = OriginalHandleA.CenterF) ) or
                      ((ExistingLink.FHandles[0] = OriginalHandleB.CenterF) ) and
                       (ExistingLink.FHandles[1] = EndConnPoint.CenterF) )) then
                   begin
                       IsValidTarget := False;
                       ShowMessage('This modification would create a duplicate link.');
                       Break;
                   end;
               end;

              if IsValidTarget then
              begin
                  FDraggingLink.SourceGrid := EndConnPoint.Grid;
                  FDraggingLink.SourceRow := EndConnPoint.Row;
                  // Optional: Trigger OnLinkChanged event
              end;
          end
          else // We are changing the Destination endpoint (FDraggingHandle = lepDestination)
          begin
              // Check if new destination is same as original source
              if (EndConnPoint.Grid = OriginalHandleA) and (EndConnPoint.Row = OriginalSourceRow) then
                 IsValidTarget := False;
              // Add other checks
              // if EndConnPoint.Grid = OriginalHandleA then IsValidTarget := False;

               // Check for duplicate link with the new destination
               for ExistingLink in FNoodles do
               begin
                   if ExistingLink = FDraggingLink then Continue; // Skip self
                   if ((ExistingLink.SourceGrid = OriginalHandleA) and (ExistingLink.SourceRow = OriginalSourceRow) and
                       (ExistingLink.DestGrid = EndConnPoint.Grid) and (ExistingLink.DestRow = EndConnPoint.Row)) or
                      ((ExistingLink.SourceGrid = EndConnPoint.Grid) and (ExistingLink.SourceRow = EndConnPoint.Row) and
                       (ExistingLink.DestGrid = OriginalHandleA) and (ExistingLink.DestRow = OriginalSourceRow)) then
                   begin
                       IsValidTarget := False;
                       ShowMessage('This modification would create a duplicate link.');
                       Break;
                   end;
               end;


              if IsValidTarget then
              begin
                  FDraggingLink.DestGrid := EndConnPoint.Grid;
                  FDraggingLink.DestRow := EndConnPoint.Row;
                  // Optional: Trigger OnLinkChanged event
              end;
          end;
      end; // else: Dropped on empty space, snap back (implicitly handled by redraw)

      FDragState := ndsIdle;
      FDraggingLink := nil; // Clear the link being dragged
      pbNoodles.Invalidate; // Redraw final state
  end;

end;

procedure TNoodleFrame.pbNoodlesPaint(Sender: TObject);
var
  Link: TNoodleLink;
  P0, P1: TPoint;
  Canvas: TCanvas;
  AColor: TColor;
begin
  Canvas := (Sender as TPaintBox).Canvas;
  Canvas.Brush.Style := bsClear; // Make background transparent (won't erase grids)

  // 1. Draw all existing noodles
  for Link in FNoodles do
  begin
    P0 := Link.GetEndPointPosition(lepSource, pbNoodles);
    P1 := Link.GetEndPointPosition(lepDestination, pbNoodles);

    // Only draw if both endpoints are valid (visible/exist)
    if (P0.X <> -1) and (P1.X <> -1) then
    begin
      if Link.IsSelected then
        AColor := FSelectedRopeColor else  AColor := FRopeColor;
      DrawNoodle(Canvas, P0, P1,AColor, FRopeThickness, Link.IsSelected);
    end;
  end;

  // 2. Draw dragging preview line (if any)
  if FDragState = ndsDraggingNew then
  begin
    // Draw from start dot to current mouse pos
    DrawNoodle(Canvas, FDragStartConnPoint.Position, FDragCurrentPoint, clLime, FRopeThickness, False);
  end
  else if FDragState = ndsDraggingExistingHandle then
  begin
    // Draw from fixed end to current mouse pos
    var FixedEndPos: TPoint;
    if FDraggingHandle = lepSource then // Dragging source handle
      FixedEndPos := FDraggingLink.GetEndPointPosition(lepDestination, pbNoodles)
    else // Dragging destination handle
      FixedEndPos := FDraggingLink.GetEndPointPosition(lepSource, pbNoodles);

    DrawNoodle(Canvas, FixedEndPos, FDragCurrentPoint, clLime, FRopeThickness, False);
  end;
end;


procedure TNoodleFrame.UpdatePaintBoxBounds(gridSource, gridDest: TRect);
var
  Rect1, Rect2, UnionRect: TRect;
  P1, P2, P3, P4: TPoint;
begin
  // Get screen coordinates of the top-left/bottom-right of the dot columns
  P1 := GetGridDotPosition(scmGrid, scmGrid.FixedRows, FSourceDotColumn, pbNoodles); // Top-left of grid1 col
  P2 := GetGridDotPosition(scmGrid, scmGrid.RowCount - 1, FSourceDotColumn, pbNoodles); // Bottom-left of grid1 col
  P3 := GetGridDotPosition(TDSGrid, TDSGrid.FixedRows, FDestDotColumn, pbNoodles); // Top-right of grid2 col
  P4 := GetGridDotPosition(TDSGrid, TDSGrid.RowCount - 1, FDestDotColumn, pbNoodles); // Bottom-right of grid2 col

  if (P1.X = -1) or (P2.X = -1) or (P3.X = -1) or (P4.X = -1) then
  begin
     // Fallback if grids are empty or something is wrong - cover grids roughly
     Rect1 := scmGrid.BoundsRect;
     Rect2 := TDSGrid.BoundsRect;
     UnionRect := Rect(Min(Rect1.Left, Rect2.Left), Min(Rect1.Top, Rect2.Top),
                       Max(Rect1.Right, Rect2.Right), Max(Rect1.Bottom, Rect2.Bottom));
  end else
  begin
     // Create a bounding box around the dot columns relative to the Form
     UnionRect.Left := Min(P1.X, P3.X) - FHandleRadius - 10; // Add some padding
     UnionRect.Top := Min(P1.Y, P3.Y) - FHandleRadius - 10;
     UnionRect.Right := Max(P2.X, P4.X) + FHandleRadius + 10;
     UnionRect.Bottom := Max(P2.Y, P4.Y) + FHandleRadius + 10;
  end;


  // Set PaintBox bounds (relative to its parent, the Form)
  pbNoodles.SetBounds(UnionRect.Left, UnionRect.Top,
                           UnionRect.Right - UnionRect.Left,
                           UnionRect.Bottom - UnionRect.Top);
  pbNoodles.Invalidate; // Redraw after moving/resizing
end;


end.
