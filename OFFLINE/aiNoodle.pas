unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  AdvDBGrid, // TMS Grid Unit
  Generics.Collections, // For TObjectList
  NoodleLinkUnit, // Our new unit
  System.Math; // For Hypot, Power etc.

type
  // State for dragging operations
  TNoodleDragState = (ndsIdle, ndsDraggingNew, ndsDraggingExistingHandle);

  TForm1 = class(TForm)
    AdvDBGrid1: TAdvDBGrid;
    AdvDBGrid2: TAdvDBGrid;
    PaintBoxNoodles: TPaintBox;
    // Add Buttons or other controls as needed
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxNoodlesPaint(Sender: TObject);
    procedure PaintBoxNoodlesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxNoodlesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxNoodlesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AdvDBGridScroll(Sender: TObject); // Event handler for OnScroll
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FNoodles: TObjectList<TNoodleLink>;
    FDragState: TNoodleDragState;
    FDragStartPoint: TPoint; // Point where drag started (PaintBox coords)
    FDragCurrentPoint: TPoint; // Current mouse position during drag (PaintBox coords)
    FDragStartConnPoint: TNoodleConnectionPoint; // Info about the dot where drag started
    FDraggingLink: TNoodleLink; // The existing link being dragged (if ndsDraggingExistingHandle)
    FDraggingHandle: TLinkEndPointType; // Which handle of FDraggingLink is being dragged
    FSelectedLink: TNoodleLink;

    // Configuration
    FSagFactor: Single;
    FRopeColor: TColor;
    FSelectedRopeColor: TColor;
    FRopeThickness: Integer;
    FHandleColor: TColor;
    FHandleRadius: Integer;
    FHitTolerance: Integer; // Pixels tolerance for hitting lines/handles

    // Helper methods
    procedure DrawNoodle(ACanvas: TCanvas; P0, P1: TPoint; AColor: TColor; AThickness: Integer; ASelected: Boolean);
    procedure DrawQuadraticBezier(ACanvas: TCanvas; P0, P1, P2: TPoint; NumSegments: Integer); // Adapted for TPoint
    procedure DrawHandle(ACanvas: TCanvas; P: TPoint; AColor: TColor; ARadius: Integer);
    function FindConnectionPointAt(P: TPoint; out ConnPoint: TNoodleConnectionPoint): Boolean; // Find grid dot under point P
    function FindLinkAt(P: TPoint; out HitLink: TNoodleLink; out HitHandle: TLinkEndPointType): Boolean; // Find link/handle under point P
    procedure SelectLink(ALink: TNoodleLink);
    procedure DeselectAllLinks;
    procedure DeleteSelectedLink;
    procedure UpdatePaintBoxBounds; // Keep PaintBox over grids

  public
    { Public declarations }
    // *** Define your dot columns here (make consistent with NoodleLinkUnit) ***
    property SourceDotColumn: Integer read FSourceDotColumn write FSourceDotColumn default 1;
    property DestDotColumn: Integer read FDestDotColumn write FDestDotColumn default 0;
  private
    FSourceDotColumn: Integer;
    FDestDotColumn: Integer;

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses NoodleLinkUnit; // Make sure it's here too

// --- Form Implementation ---

procedure TForm1.FormCreate(Sender: TObject);
begin
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
  FSourceDotColumn := 1; // Example: Column index for dots in AdvDBGrid1
  FDestDotColumn := 0;   // Example: Column index for dots in AdvDBGrid2

  // Ensure PaintBox is on top and covers the grid areas
  PaintBoxNoodles.BringToFront;
  UpdatePaintBoxBounds; // Initial positioning

  // Hook grid scroll events to repaint noodles
  AdvDBGrid1.OnScroll := AdvDBGridScroll;
  AdvDBGrid2.OnScroll := AdvDBGridScroll;

  // Allow the form to receive KeyDown events even if PaintBox has focus
  Self.KeyPreview := True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FNoodles.Free;
end;

// Keep the paintbox positioned over the relevant grid columns
procedure TForm1.UpdatePaintBoxBounds;
var
  Rect1, Rect2, UnionRect: TRect;
  P1, P2, P3, P4: TPoint;
begin
  // Get screen coordinates of the top-left/bottom-right of the dot columns
  P1 := GetGridDotPosition(AdvDBGrid1, AdvDBGrid1.FixedRows, FSourceDotColumn, Self); // Top-left of grid1 col
  P2 := GetGridDotPosition(AdvDBGrid1, AdvDBGrid1.RowCount - 1, FSourceDotColumn, Self); // Bottom-left of grid1 col
  P3 := GetGridDotPosition(AdvDBGrid2, AdvDBGrid2.FixedRows, FDestDotColumn, Self); // Top-right of grid2 col
  P4 := GetGridDotPosition(AdvDBGrid2, AdvDBGrid2.RowCount - 1, FDestDotColumn, Self); // Bottom-right of grid2 col

  if (P1.X = -1) or (P2.X = -1) or (P3.X = -1) or (P4.X = -1) then
  begin
     // Fallback if grids are empty or something is wrong - cover grids roughly
     Rect1 := AdvDBGrid1.BoundsRect;
     Rect2 := AdvDBGrid2.BoundsRect;
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
  PaintBoxNoodles.SetBounds(UnionRect.Left, UnionRect.Top,
                           UnionRect.Right - UnionRect.Left,
                           UnionRect.Bottom - UnionRect.Top);
  PaintBoxNoodles.Invalidate; // Redraw after moving/resizing
end;

procedure TForm1.FormResize(Sender: TObject);
begin
   UpdatePaintBoxBounds; // Reposition paintbox when form resizes
end;


// Trigger repaint when grids scroll
procedure TForm1.AdvDBGridScroll(Sender: TObject);
begin
  PaintBoxNoodles.Invalidate;
end;

// --- Drawing Logic ---

procedure TForm1.PaintBoxNoodlesPaint(Sender: TObject);
var
  Link: TNoodleLink;
  P0, P1: TPoint;
  Canvas: TCanvas;
begin
  Canvas := (Sender as TPaintBox).Canvas;
  Canvas.Brush.Style := bsClear; // Make background transparent (won't erase grids)

  // 1. Draw all existing noodles
  for Link in FNoodles do
  begin
    P0 := Link.GetEndPointPosition(lepSource, PaintBoxNoodles);
    P1 := Link.GetEndPointPosition(lepDestination, PaintBoxNoodles);

    // Only draw if both endpoints are valid (visible/exist)
    if (P0.X <> -1) and (P1.X <> -1) then
    begin
      DrawNoodle(Canvas, P0, P1,
                 iff(Link.IsSelected, FSelectedRopeColor, FRopeColor),
                 FRopeThickness, Link.IsSelected);
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
      FixedEndPos := FDraggingLink.GetEndPointPosition(lepDestination, PaintBoxNoodles)
    else // Dragging destination handle
      FixedEndPos := FDraggingLink.GetEndPointPosition(lepSource, PaintBoxNoodles);

    DrawNoodle(Canvas, FixedEndPos, FDragCurrentPoint, clLime, FRopeThickness, False);
  end;
end;

procedure TForm1.DrawNoodle(ACanvas: TCanvas; P0, P1: TPoint; AColor: TColor; AThickness: Integer; ASelected: Boolean);
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

// Your Bezier drawing function adapted for TPoint
procedure TForm1.DrawQuadraticBezier(ACanvas: TCanvas; P0, P1, P2: TPoint;
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

procedure TForm1.DrawHandle(ACanvas: TCanvas; P: TPoint; AColor: TColor; ARadius: Integer);
begin
  ACanvas.Brush.Color := AColor;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Pen.Color := clBlack; // Optional outline
  ACanvas.Pen.Width := 1;
  ACanvas.Ellipse(P.X - ARadius, P.Y - ARadius, P.X + ARadius + 1, P.Y + ARadius + 1);
  ACanvas.Brush.Style := bsClear; // Reset brush
end;

// --- Interaction Logic ---

procedure TForm1.PaintBoxNoodlesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ClickedPoint: TPoint;
  HitLink: TNoodleLink;
  HitHandle: TLinkEndPointType;
  HitConnPoint: TNoodleConnectionPoint;
begin
  if Button <> mbLeft then Exit;

  ClickedPoint := Point(X, Y);
  DeselectAllLinks; // Deselect previous link first

  // 1. Check if clicking on an existing link's HANDLE
  if FindLinkAt(ClickedPoint, HitLink, HitHandle) and (HitHandle <> lepSource) then // HitTest returns lepSource for line hit, lepDestination or lepSource for specific handle
  begin
     // Check the exact position again to confirm it's a handle
     if System.Math.Hypot(ClickedPoint.X - HitLink.GetEndPointPosition(HitHandle, PaintBoxNoodles).X,
                          ClickedPoint.Y - HitLink.GetEndPointPosition(HitHandle, PaintBoxNoodles).Y) <= FHandleRadius then
     begin
        FDragState := ndsDraggingExistingHandle;
        FDraggingLink := HitLink; // Store the link being dragged
        FDraggingHandle := HitHandle; // Store which handle is grabbed
        FDragStartPoint := ClickedPoint;
        FDragCurrentPoint := ClickedPoint;
        SelectLink(HitLink); // Select the link visually
        PaintBoxNoodles.Invalidate;
        Exit; // Don't check for other things
     end;
  end;


  // 2. Check if clicking on an existing link's LINE (not handles)
  if FindLinkAt(ClickedPoint, HitLink, HitHandle) then // HitHandle will be default if line is hit
  begin
    SelectLink(HitLink);
    PaintBoxNoodles.Invalidate;
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
    PaintBoxNoodles.Invalidate; // Show drag preview
    Exit;
  end;

  // 4. Clicked on empty space
  DeselectAllLinks; // Already done, but good practice
  PaintBoxNoodles.Invalidate; // Redraw without selection

end;

procedure TForm1.PaintBoxNoodlesMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if FDragState <> ndsIdle then
  begin
    FDragCurrentPoint := Point(X, Y);
    PaintBoxNoodles.Invalidate; // Redraw preview line
  end;
  // Add hover effects here if desired (check FindLinkAt/FindConnectionPointAt)
end;

procedure TForm1.PaintBoxNoodlesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  EndPoint: TPoint;
  EndConnPoint: TNoodleConnectionPoint;
  NewLink: TNoodleLink;
  ExistingLink: TNoodleLink;
  SourceGrid, DestGrid : TAdvDBGrid;
  SourceRow, DestRow : Integer;
begin
  if Button <> mbLeft then Exit;

  EndPoint := Point(X, Y);

  if FDragState = ndsDraggingNew then
  { // Check if dropped on a valid connection point }
  if FindConnectionPointAt(EndPoint, EndConnPoint) then
  begin
    // --- Validation: Prevent linking dot to itself or same grid row ---
    if (EndConnPoint.Grid = FDragStartConnPoint.Grid) and (EndConnPoint.Row = FDragStartConnPoint.Row) then
    begin
       // Dropped on same start point, cancel
    end
    // --- Add more validation if needed (e.g., prevent linking Grid1 to Grid1) ---
    // else if EndConnPoint.Grid = FDragStartConnPoint.Grid then
    // begin
    //    // Linking within the same grid - cancel if not allowed
    // end
    else
    begin
      // --- Check for duplicate link ---
      var IsDuplicate := False;
      for ExistingLink in FNoodles do
      begin
          // Check both directions
          if ((ExistingLink.SourceGrid = FDragStartConnPoint.Grid) and (ExistingLink.SourceRow = FDragStartConnPoint.Row) and
              (ExistingLink.DestGrid = EndConnPoint.Grid) and (ExistingLink.DestRow = EndConnPoint.Row)) or
             ((ExistingLink.SourceGrid = EndConnPoint.Grid) and (ExistingLink.SourceRow = EndConnPoint.Row) and
              (ExistingLink.DestGrid = FDragStartConnPoint.Grid) and (ExistingLink.DestRow = FDragStartConnPoint.Row)) then
          begin
              IsDuplicate := True;
              Break;
          end;
      end;

      if not IsDuplicate then
      begin
          // Create the new link
          NewLink := TNoodleLink.Create(FDragStartConnPoint.Grid, FDragStartConnPoint.Row,
                                        EndConnPoint.Grid, EndConnPoint.Row);
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
  PaintBoxNoodles.Invalidate; // Redraw final state

  else if FDragState = ndsDraggingExistingHandle then
  begin
      // Check if dropped on a valid connection point
      if FindConnectionPointAt(EndPoint, EndConnPoint) then
      begin
          // Validation: Prevent linking to self, etc.
          var IsValidTarget := True;
          var OriginalSourceGrid, OriginalDestGrid: TAdvDBGrid;
          var OriginalSourceRow, OriginalDestRow: Integer;

          OriginalSourceGrid := FDraggingLink.SourceGrid;
          OriginalSourceRow := FDraggingLink.SourceRow;
          OriginalDestGrid := FDraggingLink.DestGrid;
          OriginalDestRow := FDraggingLink.DestRow;


          if FDraggingHandle = lepSource then // We are changing the Source endpoint
          begin
              // Check if new source is same as original destination
              if (EndConnPoint.Grid = OriginalDestGrid) and (EndConnPoint.Row = OriginalDestRow) then
                 IsValidTarget := False;
              // Add other checks (e.g., prevent same grid connection if needed)
              // if EndConnPoint.Grid = OriginalDestGrid then IsValidTarget := False;

              // Check for duplicate link with the new source
               for ExistingLink in FNoodles do
               begin
                   if ExistingLink = FDraggingLink then Continue; // Skip self
                   if ((ExistingLink.SourceGrid = EndConnPoint.Grid) and (ExistingLink.SourceRow = EndConnPoint.Row) and
                       (ExistingLink.DestGrid = OriginalDestGrid) and (ExistingLink.DestRow = OriginalDestRow)) or
                      ((ExistingLink.SourceGrid = OriginalDestGrid) and (ExistingLink.SourceRow = OriginalDestRow) and
                       (ExistingLink.DestGrid = EndConnPoint.Grid) and (ExistingLink.DestRow = EndConnPoint.Row)) then
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
              if (EndConnPoint.Grid = OriginalSourceGrid) and (EndConnPoint.Row = OriginalSourceRow) then
                 IsValidTarget := False;
              // Add other checks
              // if EndConnPoint.Grid = OriginalSourceGrid then IsValidTarget := False;

               // Check for duplicate link with the new destination
               for ExistingLink in FNoodles do
               begin
                   if ExistingLink = FDraggingLink then Continue; // Skip self
                   if ((ExistingLink.SourceGrid = OriginalSourceGrid) and (ExistingLink.SourceRow = OriginalSourceRow) and
                       (ExistingLink.DestGrid = EndConnPoint.Grid) and (ExistingLink.DestRow = EndConnPoint.Row)) or
                      ((ExistingLink.SourceGrid = EndConnPoint.Grid) and (ExistingLink.SourceRow = EndConnPoint.Row) and
                       (ExistingLink.DestGrid = OriginalSourceGrid) and (ExistingLink.DestRow = OriginalSourceRow)) then
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
      PaintBoxNoodles.Invalidate; // Redraw final state
  end;
end;

// --- Helper Functions ---

// Find which grid/row dot is under the given point (PaintBox coordinates)
function TForm1.FindConnectionPointAt(P: TPoint; out ConnPoint: TNoodleConnectionPoint): Boolean;
var
  Grid: TAdvDBGrid;
  Row: Integer;
  DotPos: TPoint;
  DotCol: Integer;
  HandleRadiusSq: Integer;
  DistSq: Int64;
  GridsToCheck: array[0..1] of TAdvDBGrid;
begin
  Result := False;
  ConnPoint.IsValid := False;
  HandleRadiusSq := FHandleRadius * FHandleRadius;
  GridsToCheck[0] := AdvDBGrid1;
  GridsToCheck[1] := AdvDBGrid2;

  for Grid in GridsToCheck do
  begin
    // Determine which column index to use for this grid
    if Grid = AdvDBGrid1 then
       DotCol := FSourceDotColumn // Use SourceDotColumn for AdvDBGrid1
    else
       DotCol := FDestDotColumn;  // Use DestDotColumn for AdvDBGrid2


    // Iterate through VISIBLE rows only for efficiency
    for Row := Grid.FixedRows to Grid.RowCount - 1 do // Check actual rows
    begin
       // Check if row is visible (might need grid-specific function if available,
       // otherwise CellRect might work even if partially scrolled out)
       // For now, assume CellRect works correctly for rows partially in view.

      DotPos := GetGridDotPosition(Grid, Row, DotCol, PaintBoxNoodles);
      if DotPos.X = -1 then Continue; // Skip invalid/invisible rows

      DistSq := Int64(P.X - DotPos.X) * (P.X - DotPos.X) + Int64(P.Y - DotPos.Y) * (P.Y - DotPos.Y);

      if DistSq <= HandleRadiusSq then
      begin
        ConnPoint.Grid := Grid;
        ConnPoint.Row := Row;
        ConnPoint.Position := DotPos; // Store the calculated position
        ConnPoint.IsValid := True;
        Result := True;
        Exit; // Found the first one
      end;
    end;
  end;
end;

// Find which link/handle is under the given point (PaintBox coordinates)
function TForm1.FindLinkAt(P: TPoint; out HitLink: TNoodleLink; out HitHandle: TLinkEndPointType): Boolean;
var
  Link: TNoodleLink;
  TempHandle: TLinkEndPointType;
begin
  Result := False;
  HitLink := nil;
  HitHandle := lepSource; // Default

  // Iterate backwards so topmost links are checked first
  for Link in FNoodles.Reverse do
  begin
    if Link.HitTest(P, PaintBoxNoodles, FSagFactor, FHitTolerance, FHandleRadius, TempHandle) then
    {
      Result := True;
      HitLink := Link;
      HitHandle := TempHandle;
      Exit;
    }
  end;
end;

procedure TForm1.SelectLink(ALink: TNoodleLink);
begin
  DeselectAllLinks; // Ensure only one is selected
  if ALink <> nil then
  begin
    ALink.IsSelected := True;
    FSelectedLink := ALink;
  end;
end;

procedure TForm1.DeselectAllLinks;
var
  Link: TNoodleLink;
begin
  if FSelectedLink <> nil then
  {
    FSelectedLink.IsSelected := False;
    FSelectedLink := nil;
  }
// Also iterate just in case state is inconsistent
for Link in FNoodles do
    Link.IsSelected := False;
  FSelectedLink := nil; // Ensure this is cleared

end;

procedure TForm1.DeleteSelectedLink;
begin
  if FSelectedLink <> nil then
  {
    var LinkToDelete := FSelectedLink;
    DeselectAllLinks; // Deselect first
    FNoodles.Remove(LinkToDelete); // TObjectList will Free it
    // Optional: Trigger OnLinkDeleted event
    // if Assigned(FOnLinkDeleted) then FOnLinkDeleted(Self, LinkToDelete);
    PaintBoxNoodles.Invalidate; // Redraw without the deleted link
  }
end;

// --- Keyboard Handling ---

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  {
    if FSelectedLink <> nil then
    {
      DeleteSelectedLink;
      Key := 0; // Mark key as handled
    }
  }
end;

end.