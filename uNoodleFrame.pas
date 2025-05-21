unit uNoodleFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  System.Generics.Collections, Vcl.VirtualImage, System.Math,
  dmIMG, uNoodleLink, System.Types, Vcl.StdCtrls;

type
  // State for dragging operations
  TNoodleDragState = (ndsIdle, ndsDraggingNew, ndsDraggingExistingHandle);

type
  TNoodleFrame = class(TFrame)
    pbNoodles: TPaintBox;
    procedure pbNoodlesMouseDown(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
    procedure pbNoodlesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pbNoodlesMouseUp(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
    procedure pbNoodlesPaint(Sender: TObject);
  private
    DefaultRowHeight: integer; // identical to SCM TMS TAdvDBGrid.
    FDestDotColumn: Integer;
    { Private declarations }
    FDragCurrentPoint: TPoint; // Current mouse position during drag (PaintBox coords)
    FDraggingHandle: TNoodleHandle; // Which handle of FDraggingLink is being dragged.
    FDraggingLink: TNoodleLink; // The existing link being dragged (if ndsDraggingExistingHandle)
    FDragStartHandle: TNoodleHandle;
    FDragStartPoint: TPoint; // Point where drag started (PaintBox coords)
    FDragStartRect: TRect;
    FDragState: TNoodleDragState;
    FHandleColor: TColor;
    FHotSpots: Array of TRect;
    FixedRowHeight: integer;   // identical to SCM TMS TAdvDBGrid.
    FNoodles: TObjectList<TNoodleLink>; // Noodles
    FRopeColor: TColor;
    FRopeThickness: Integer;
    // Configuration
    FSelectedLink: TNoodleLink;
    FSelectedRopeColor: TColor;
    FSourceDotColumn: Integer;
    NumberOfLanes: integer;
//    function HitTest(ANoodleHandle: TNoodleHandle; out HitLink:
//        TNoodleLink): Boolean; overload;
    procedure  CreateHotSpots;
    procedure DeselectAllLinks;
    procedure DrawHandle(ACanvas: TCanvas; P: TPoint; AColor: TColor; ARadius: Integer);
    // Helper methods
    procedure DrawNoodle(ACanvas: TCanvas; P0, P1: TPointF; AColor: TColor; AThickness: Integer; ASelected: Boolean);
    procedure DrawQuadraticBezier(ACanvas: TCanvas; P0, P1, P2: TPoint; NumSegments: Integer); // Adapted for TPoint
    function FindNoodleHandleAtHotSpot(P: TPoint; out ANoodleHandle:
        TNoodleHandle): Boolean;
    function HitTest(P: TPoint; out HitLink: TNoodleLink; out HitHandle:
        TNoodleHandle): Boolean; overload;
    function HitTestHotSpot(P: TPoint; out ARect: TRect; out index: integer):
        boolean;
    procedure SelectLink(ALink: TNoodleLink);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DeleteSelectedLink;
    { Public declarations }
    property DestDotColumn: Integer read FDestDotColumn write FDestDotColumn default 0;
    property SelectedLink: TNoodleLink read fSelectedLink;
    // *** Define your dot columns here (make consistent with NoodleLinkUnit) ***
    property SourceDotColumn: Integer read FSourceDotColumn write FSourceDotColumn default 1;
  end;

var
  NoodleFrame: TNoodleFrame;

implementation

{$R *.dfm}

//uses frmMain;

procedure  TNoodleFrame.CreateHotSpots;
var
I, J: integer;
ARect: TRect;
begin
  SetLength(FHotSpots, (NumberOfLanes*2));
  for i:=0 to NumberOfLanes-1 do
  begin
    ARect.Top := FixedRowHeight + (i*DefaultRowHeight);
    Arect.Left := 0;
    ARect.Height := DefaultRowHeight;
    ARect.Width := DefaultRowHeight;
    FHotSpots[i] := ARect;
  end;
  for J:=0 to NumberOfLanes-1 do
  begin
    ARect.Top := FixedRowHeight + (j*DefaultRowHeight);
    Arect.Left := Width - DefaultRowHeight;
    ARect.Height := DefaultRowHeight;
    ARect.Width := DefaultRowHeight;
    FHotSpots[i+J] := ARect;
  end;
end;

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
  // Ensure PaintBox is on top and covers the grid areas
  pbNoodles.BringToFront;

  // NOODLE INITIALISATION. END.
  // ---------------------------------------------------------------------

    FixedRowHeight:= 34;   // identical to SCM TMS TAdvDBGrid.
    DefaultRowHeight:= 46; // identical to SCM TMS TAdvDBGrid.
    NumberOfLanes:= 10;  // dbo.SwimClubMeet.SwimClub.NumOfLanes.

    CreateHotSpots;

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

procedure TNoodleFrame.DrawNoodle(ACanvas: TCanvas; P0, P1: TPointF; AColor: TColor;
  AThickness: Integer; ASelected: Boolean);
var
  P_Control, A, B: TPoint;
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

  A.X := ROUND(P0.X);
  A.Y := ROUND(P0.Y);
  B.X := ROUND(P1.X);
  B.Y := ROUND(P1.Y);

  // Draw the Bezier curve
  DrawQuadraticBezier(ACanvas, A, P_Control, B, 30); // 30 segments

  // Draw handles if selected
  if ASelected then
  begin
    DrawHandle(ACanvas, A, FHandleColor, FHandleRadius);
    DrawHandle(ACanvas, B, FHandleColor, FHandleRadius);
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

function TNoodleFrame.FindNoodleHandleAtHotSpot(P: TPoint; out ANoodleHandle:
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
  ANoodleHandle.SetEmpty;
  HandleRadiusSq := FHandleRadius * FHandleRadius; // margin of acceptance.
  for HotSpot in FHotSpots do
  begin
    if HotSpot.IsEmpty then continue;
    CenterF := HotSpot.CenterPoint;
    DistSqF := (P.X - CenterF.X) * (P.X - CenterF.X) + (P.Y - CenterF.Y) * (P.Y - CenterF.Y);
    if DistSqF <= HandleRadiusSq then
    begin
      if HitTest(HotSpot.CenterPoint, ALink, AHandle) then
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


function TNoodleFrame.HitTest(P: TPoint; out HitLink: TNoodleLink; out
    HitHandle: TNoodleHandle): Boolean;
var
  Link: TNoodleLink;
  ANoodleHandle: TNoodleHandle;
  i: Integer;
begin
  Result := False;
  HitLink := nil;
  HitHandle.SetEmpty; // Assign an empty HitHandle...

  // Iterate through the Noodles
  for i := 0 to FNoodles.Count - 1 do
  begin
    Link := FNoodles[i]; // Get the link at the current index
    if Link.HitTest(P, ANoodleHandle) then
    begin
      Result := True;
      HitLink := Link;
      // point must be located on a noddle handle for assignment.
      // else point is located on link's connection line.
      if ANoodleHandle.IsValid then
        HitHandle := ANoodleHandle;
      Exit; // Exit as soon as a match is found
    end;
  end;

end;


function TNoodleFrame.HitTestHotSpot(P: TPoint; out ARect: TRect; out index:
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
  ClickedPoint: TPoint;
  HitLink: TNoodleLink;
  HitHandle: TNoodleHandle;
  HitConnPoint: TNoodleHandle;
  ARect: TRect;
  index: integer;
begin
  if Button <> mbLeft then Exit;

  ClickedPoint := Point(X, Y);
  DeselectAllLinks; // Deselect previous link first

  // 1. Check if clicking on an NoodleHandle
  if HitTest(ClickedPoint, HitLink, HitHandle) then
  // HitTest returns lepSource for line hit, lepDestination or lepSource for specific handle
  begin
    if HitHandle.IsValid then
    begin
      // Check the exact position again to confirm it's a handle
      if System.Math.Hypot(ClickedPoint.X - HitHandle.CenterF.X,
                          ClickedPoint.Y - HitHandle.CenterF.Y) <= FHandleRadius then
      begin
        FDragState := ndsDraggingExistingHandle;
        FDraggingLink := HitLink; // Store the link being dragged.
        FDraggingHandle := HitHandle; // Store which handle is grabbed.
        FDragStartPoint := ClickedPoint;
        FDragCurrentPoint := ClickedPoint;
        SelectLink(HitLink); // Select the link visually
        pbNoodles.Invalidate;
        Exit; // Don't check for other things
      end;
    end;
  end;


  // 2. Check if clicking on an existing link's LINE (not handles)
  if HitTest(ClickedPoint, HitLink, HitHandle) then // HitHandle will be default if line is hit
  begin
    SelectLink(HitLink);
    pbNoodles.Invalidate;
    // Don't start drag, just select
    Exit;
  end;

  // 3. Check if clicking on a HotSpot
  if HitTestHotSpot(ClickedPoint, ARect, index) then
  begin
    FDragState := ndsDraggingNew;
    FDragStartPoint := ARect.CenterPoint;
    FDragStartRect := ARect;
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
  // Add hover effects here if desired (check HitTest/FindNoodleHandleAtHotSpot)
end;

procedure TNoodleFrame.pbNoodlesPaint(Sender: TObject);
var
  Link: TNoodleLink;
  P0, P1: TPointF;
  Spot: TPoint;
  HotSpot: TRect;
  Canvas: TCanvas;
  AColor: TColor;
  BitMap: TBitMap;
  deflate: integer;
  LText: String;
begin
  Canvas := (Sender as TPaintBox).Canvas;
  Canvas.Brush.Style := bsClear; // Make background transparent (won't erase grids)

  // draw the under lining HotSpots
  for HotSpot in FHotSpots do
  begin
    deflate := ((DefaultRowHeight - IMG.vimglistDTGrid.Height) DIV 2);
    HotSpot.inflate(-deflate, -deflate);
//    IMG.ImgcolDT.Draw(Canvas, HotSpot, 'EvBlue', true);
    IMG.vimglistDTGrid.Draw(Canvas, HotSpot.Left, HotSpot.Top, 'EvBlue', true);
  end;

  // 1. Draw all existing noodles
  for Link in FNoodles do
  begin
    if (not Link.NoodleHandleStart.IsValid) or (not Link.NoodleHandleEnd.IsValid) then continue;

    P0 := Link.NoodleHandleStart.CenterF;
    P1 := Link.NoodleHandleEnd.CenterF;;

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
    P0 := FDragStartPoint;
    P1 := FDragCurrentPoint;
    DrawNoodle(Canvas, P0, P1, clLime, FRopeThickness, False);
    Spot := FDragStartPoint;
    Spot.X := Spot.X - (IMG.vimglistDTGrid.Height DIV 2);
    Spot.Y := Spot.Y - (IMG.vimglistDTGrid.Height DIV 2);
    IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'DotCircle', true);
  end
  else if FDragState = ndsDraggingExistingHandle then
  begin
    // Draw from fixed end to current mouse pos
    var FixedEndPos: TPoint;
    if FDraggingHandle.PointType = lptA then // Dragging source handle
      FixedEndPos := ConvertTPointFToTPoint(FDraggingLink.NoodleHandleStart.CenterF)
    else // Dragging destination handle
      FixedEndPos := ConvertTPointFToTPoint(FDraggingLink.NoodleHandleEnd.CenterF);

    DrawNoodle(Canvas, FixedEndPos, FDragCurrentPoint, clLime, FRopeThickness, False);
  end;
end;

procedure TNoodleFrame.pbNoodlesMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
var
  EndPoint: TPoint;
  EndHandle, HitHandle: TNoodleHandle;
  NewLink, NoodleLink: TNoodleLink;
  ExistingLink: TNoodleLink;
begin
  if Button <> mbLeft then Exit;

  EndPoint := Point(X, Y);

  if FDragState = ndsDraggingNew then
  begin

    for NoodleLink in FNoodles do
    begin
      { // Check if dropped on a valid connection point }
      if NoodleLink.HitTestNoodle(EndPoint, HitHandle) then
      begin
        // --- Validation: Prevent linking same handle ---
        if (FDragStartHandle = HitHandle) then
        begin
           // Dropped on same starting handle ...
        end
        // --- Validation: prevent linking TDS to TDS or SCM to SCM) ---
        else if FDragStartHandle.PointType = HitHandle.PointType  then
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
              if (ExistingLink.NoodleHandleStart = HitHandle) or  (ExistingLink.NoodleHandleEnd = HitHandle) then
              begin
                  IsDuplicate := True;
                  Break;
              end;
          end;

          if not IsDuplicate then
          begin
              // Create the new link
              NewLink := TNoodleLink.Create(FDragStartHandle.ARectF, EndHandle.ARectF);
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

      end;
    end;

    if FindNoodleHandleAtHotSpot(EndPoint, EndHandle) then
    begin
      // --- Validation: Prevent linking dot to itself or same grid row ---
      if (EndHandle.CenterF = FDragStartHandle.CenterF) then
      begin
         // Dropped on same start point, cancel
      end

      // --- Add more validation if needed
      // (e.g., prevent linking lptA to lptA) ---
      else if EndHandle.PointType = FDragStartHandle.PointType then
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
            if ((ExistingLink.NoodleHandleStart.CenterF = FDragStartHandle.CenterF) and
                (ExistingLink.NoodleHandleEnd.CenterF = EndHandle.CenterF)) or
               ((ExistingLink.NoodleHandleStart.CenterF = EndHandle.CenterF)  and
                (ExistingLink.NoodleHandleEnd.CenterF = FDragStartHandle.CenterF)) then
            begin
                IsDuplicate := True;
                Break;
            end;
        end;

        if not IsDuplicate then
        begin
            // Create the new link
            NewLink := TNoodleLink.Create(FDragStartHandle.ARectF, EndHandle.ARectF);
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
      if FindNoodleHandleAtHotSpot(EndPoint, EndHandle) then
      begin
          // Validation: Prevent linking to self, etc.
          var IsValidTarget := True;
          var OriginalHandleA, OriginalHandleB: TNoodleHandle;

          OriginalHandleA := FDraggingLink.NoodleHandleStart;
          OriginalHandleB := FDraggingLink.NoodleHandleEnd;


          if FDraggingHandle.PointType = lptA then // We are changing the Source endpoint
          begin
              // Check if new source is same as original destination
              if (EndHandle.CenterF = OriginalHandleB.CenterF) then
                 IsValidTarget := False;
              // Add other checks (e.g., prevent same grid connection if needed)
              // if EndHandle.Grid = OriginalHandleB then IsValidTarget := False;

              // Check for duplicate link with the new source
               for ExistingLink in FNoodles do
               begin
                   if ExistingLink = FDraggingLink then Continue; // Skip self
                   if ((ExistingLink.NoodleHandleStart.CenterF = EndHandle.CenterF)  and
                       (ExistingLink.NoodleHandleEnd.CenterF = OriginalHandleA.CenterF) ) or
                      ((ExistingLink.NoodleHandleStart.CenterF = OriginalHandleB.CenterF)  and
                       (ExistingLink.NoodleHandleEnd.CenterF = EndHandle.CenterF) ) then
                   begin
                       IsValidTarget := False;
                       ShowMessage('This modification would create a duplicate link.');
                       Break;
                   end;
               end;

              if IsValidTarget then
              begin
//                  FDraggingLink := FindNoodLinkAt(EndHandle);
                  // Optional: Trigger OnLinkChanged event
              end;
          end
          else // We are changing the Destination endpoint (FDraggingHandle = lepDestination)
          begin
              // Check if new destination is same as original source
              if (EndHandle.CenterF = OriginalHandleA.CenterF) then
                 IsValidTarget := False;
              // Add other checks
              // if EndHandle.Grid = OriginalHandleA then IsValidTarget := False;

               // Check for duplicate link with the new destination
               for ExistingLink in FNoodles do
               begin
                   if ExistingLink = FDraggingLink then Continue; // Skip self
//                   if ((ExistingLink.SourceGrid = OriginalHandleA) and (ExistingLink.SourceRow = OriginalSourceRow) and
//                       (ExistingLink.DestGrid = EndHandle.Grid) and (ExistingLink.DestRow = EndHandle.Row)) or
//                      ((ExistingLink.SourceGrid = EndHandle.Grid) and (ExistingLink.SourceRow = EndHandle.Row) and
//                       (ExistingLink.DestGrid = OriginalHandleA) and (ExistingLink.DestRow = OriginalSourceRow)) then
                   begin
                       IsValidTarget := False;
                       ShowMessage('This modification would create a duplicate link.');
                       Break;
                   end;
               end;


              if IsValidTarget then
              begin
//                  FDraggingLink := FindNoodLinkAt(EndHandle);
                  // Optional: Trigger OnLinkChanged event
              end;
          end;
      end; // else: Dropped on empty space, snap back (implicitly handled by redraw)

      FDragState := ndsIdle;
      FDraggingLink := nil; // Clear the link being dragged
      pbNoodles.Invalidate; // Redraw final state
  end;

end;


end.
