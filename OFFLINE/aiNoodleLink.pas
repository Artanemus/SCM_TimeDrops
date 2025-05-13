unit NoodleLinkUnit; // Save as NoodleLinkUnit.pas

interface

uses
  System.Classes, Vcl.Controls, AdvDBGrid; // Assuming TMS Grid unit name

type
  TLinkEndPointType = (lepSource, lepDestination);

  // Record to hold info about a potential connection point
  TNoodleConnectionPoint = record
    Grid: TAdvDBGrid;
    Row: Integer;
    IsValid: Boolean;
    Position: TPoint; // Position relative to the PaintBox canvas
  end;

  TNoodleLink = class
  private
    FSourceGrid: TAdvDBGrid;
    FSourceRow: Integer;
    FDestGrid: TAdvDBGrid;
    FDestRow: Integer;
    FIsSelected: Boolean;
    FSelectedHandle: TLinkEndPointType; // Indicates if source or dest handle is grabbed
    FUserData: TObject; // Optional user data
  public
    constructor Create(ASourceGrid: TAdvDBGrid; ASourceRow: Integer;
                       ADestGrid: TAdvDBGrid; ADestRow: Integer);
    destructor Destroy; override;

    // Function to check if a point is near this link's line or handles
    function HitTest(P: TPoint; PaintBox: TWinControl; SagFactor: Single; LineTolerance, HandleRadius: Integer; out HitHandle: TLinkEndPointType): Boolean;
    function GetEndPointPosition(EndPointType: TLinkEndPointType; PaintBox: TWinControl): TPoint; // Returns point relative to PaintBox

    property SourceGrid: TAdvDBGrid read FSourceGrid write FSourceGrid;
    property SourceRow: Integer read FSourceRow write FSourceRow;
    property DestGrid: TAdvDBGrid read FDestGrid write FDestGrid;
    property DestRow: Integer read FDestRow write FDestRow;
    property IsSelected: Boolean read FIsSelected write FIsSelected;
    property SelectedHandle: TLinkEndPointType read FSelectedHandle write FSelectedHandle; // Use HitTest to set this
    property UserData: TObject read FUserData write FUserData;
  end;

implementation

uses
  System.SysUtils, System.Math, Vcl.Graphics, Vcl.Forms;

// --- Helper Function (Consider moving to a common utility unit or the form) ---

// Gets the center point of the logical 'dot' cell for a given grid/row,
// returning coordinates relative to the PaintBox.
function GetGridDotPosition(AGrid: TAdvDBGrid; ARow: Integer; ADotColumn: Integer; APaintBox: TWinControl): TPoint;
var
  CellRect: TRect;
  GridScreenPos, PaintBoxScreenPos: TPoint;
begin
  Result := Point(-1, -1); // Default invalid point
  if (AGrid = nil) or (APaintBox = nil) or (ARow < AGrid.FixedRows) or (ARow >= AGrid.RowCount) then
    Exit;

  try
    // Get the rectangle of the cell in grid client coordinates
    CellRect := AGrid.CellRect(ADotColumn, ARow);

    // Calculate center of the cell
    Result.X := CellRect.Left + (CellRect.Right - CellRect.Left) div 2;
    Result.Y := CellRect.Top + (CellRect.Bottom - CellRect.Top) div 2;

    // Convert grid client coordinates to screen coordinates
    GridScreenPos := AGrid.ClientToScreen(Result);

    // Convert screen coordinates to PaintBox client coordinates
    Result := APaintBox.ScreenToClient(GridScreenPos);

  except
    // Handle potential exceptions if grid/row is invalid during access
    Result := Point(-1, -1);
  end;
end;


// --- TNoodleLink Implementation ---

constructor TNoodleLink.Create(ASourceGrid: TAdvDBGrid; ASourceRow: Integer;
  ADestGrid: TAdvDBGrid; ADestRow: Integer);
begin
  inherited Create;
  FSourceGrid := ASourceGrid;
  FSourceRow := ASourceRow;
  FDestGrid := ADestGrid;
  FDestRow := ADestRow;
  FIsSelected := False;
  FSelectedHandle := lepSource; // Default, doesn't mean much until hit tested
end;

destructor TNoodleLink.Destroy;
begin
  // Free UserData if assigned and owned, or handle externally
  inherited Destroy;
end;

function TNoodleLink.GetEndPointPosition(EndPointType: TLinkEndPointType; PaintBox: TWinControl): TPoint;
var
  Grid: TAdvDBGrid;
  Row: Integer;
  Col: Integer; // Need to know which column the dot is in for each grid
begin
  // *** Define your dot columns here ***
  const
    cSourceDotCol = 1; // Example: Dot is in column 1 of the source grid
    cDestDotCol = 0;   // Example: Dot is in column 0 of the destination grid

  if EndPointType = lepSource then
  begin
    Grid := FSourceGrid;
    Row := FSourceRow;
    Col := cSourceDotCol; // Use the source grid's dot column
     if FSourceGrid.Name = 'AdvDBGrid2' then Col := cDestDotCol; // Adjust if source can be grid2
  end
  else // lepDestination
  begin
    Grid := FDestGrid;
    Row := FDestRow;
    Col := cDestDotCol; // Use the destination grid's dot column
     if FDestGrid.Name = 'AdvDBGrid1' then Col := cSourceDotCol; // Adjust if dest can be grid1
 end;

  Result := GetGridDotPosition(Grid, Row, Col, PaintBox);
end;

function TNoodleLink.HitTest(P: TPoint; PaintBox: TWinControl; SagFactor: Single; LineTolerance, HandleRadius: Integer; out HitHandle: TLinkEndPointType): Boolean;
var
  P0, P1, PControl, pt: TPoint;
  DistSq, HandleRadiusSq: Int64; // Use Int64 for squared distances
  i: Integer;
  t: Single;
  NearestDistSq: Double;
  TempHitHandle: TLinkEndPointType;
  // Bezier segment approximation parameters
  const NumSegments = 20; // Fewer segments for faster hit testing needed? Adjust.
begin
  Result := False;
  HitHandle := lepSource; // Default
  HandleRadiusSq := HandleRadius * HandleRadius;

  P0 := GetEndPointPosition(lepSource, PaintBox);
  P1 := GetEndPointPosition(lepDestination, PaintBox);

  // Check if point is near start handle
  DistSq := Int64(P.X - P0.X) * (P.X - P0.X) + Int64(P.Y - P0.Y) * (P.Y - P0.Y);
  if DistSq <= HandleRadiusSq then
  begin
    Result := True;
    HitHandle := lepSource;
    Exit;
  end;

  // Check if point is near end handle
  DistSq := Int64(P.X - P1.X) * (P.X - P1.X) + Int64(P.Y - P1.Y) * (P.Y - P1.Y);
  if DistSq <= HandleRadiusSq then
  begin
    Result := True;
    HitHandle := lepDestination;
    Exit;
  end;

  // --- More complex: Check if point is near the Bezier curve ---
  // Approximate the curve with line segments and check distance to segments.
  // This is simpler than precise Bezier distance calculation.

  // Calculate control point (simplified version from your code)
  var MidPointX := (P0.X + P1.X) / 2;
  var MidPointY := (P0.Y + P1.Y) / 2;
  var Distance := System.Math.Hypot(P1.X - P0.X, P1.Y - P0.Y);
  var ActualSag := 0.0;
   if Distance > 10 then ActualSag := Distance * SagFactor;

  PControl.X := Round(MidPointX);
  PControl.Y := Round(MidPointY + ActualSag); // Simple vertical sag

  // Iterate through Bezier segments
  NearestDistSq := MaxInt64; // Find minimum distance squared
  var ptPrev := P0;

  for i := 1 to NumSegments do
  begin
    t := i / NumSegments;
    // Quadratic Bezier formula
    pt.X := Round(Power(1 - t, 2) * P0.X + 2 * (1 - t) * t * PControl.X + Power(t, 2) * P1.X);
    pt.Y := Round(Power(1 - t, 2) * P0.Y + 2 * (1 - t) * t * PControl.Y + Power(t, 2) * P1.Y);

    // Calculate squared distance from point P to the line segment ptPrev -> pt
    // (Using DistancePointSegmentSq function - implementation below)
    var SegDistSq := DistancePointSegmentSq(P, ptPrev, pt);
    if SegDistSq < NearestDistSq then
    begin
        NearestDistSq := SegDistSq;
    end;

    ptPrev := pt;
  end;

  if NearestDistSq <= (LineTolerance * LineTolerance) then
  begin
    Result := True;
    // HitHandle remains the default (lepSource), signifies hitting the line not a specific handle
  end;
end;

// --- Helper for HitTest: Squared distance from Point C to Line Segment AB ---
function DistancePointSegmentSq(C, A, B: TPoint): Double;
var
  L2, t, Det: Double;
  ProjX, ProjY: Double;
begin
  L2 := Int64(B.X - A.X)*(B.X - A.X) + Int64(B.Y - A.Y)*(B.Y - A.Y); // Squared length of AB
  if L2 = 0.0 then // A and B are the same point
    Result := Int64(C.X - A.X)*(C.X - A.X) + Int64(C.Y - A.Y)*(C.Y - A.Y)
  else
  begin
    // Project C onto the line defined by A and B
    // t = [(C - A) dot (B - A)] / |B - A|^2
    t := ((C.X - A.X) * (B.X - A.X) + (C.Y - A.Y) * (B.Y - A.Y)) / L2;
    t := Max(0, Min(1, t)); // Clamp t to the range [0, 1] for the segment

    // Projection point P = A + t * (B - A)
    ProjX := A.X + t * (B.X - A.X);
    ProjY := A.Y + t * (B.Y - A.Y);

    // Squared distance from C to projection point P
    Result := Int64(C.X - ProjX)*(C.X - ProjX) + Int64(C.Y - ProjY)*(C.Y - ProjY);
  end;
end;

// Add this inside the 'implementation' section of NoodleLinkUnit.pas

uses System.Math; // Make sure System.Math is in the implementation uses clause

// --- Helper Function: Squared distance from Point C to Line Segment AB ---
function DistancePointSegmentSq(const C, A, B: TPoint): Double;
var
  L2, t: Double;
  ProjX, ProjY: Double;
  dx_BA, dy_BA : Integer; // Vector B-A
  dx_CA, dy_CA : Integer; // Vector C-A
  dotProduct: Int64;
begin
  // Calculate squared length of the segment AB
  dx_BA := B.X - A.X;
  dy_BA := B.Y - A.Y;
  L2 := Int64(dx_BA)*dx_BA + Int64(dy_BA)*dy_BA; // Use Int64 to avoid overflow

  if L2 = 0.0 then // A and B are the same point
  begin
    // Squared distance from C to A
    dx_CA := C.X - A.X;
    dy_CA := C.Y - A.Y;
    Result := Int64(dx_CA)*dx_CA + Int64(dy_CA)*dy_CA;
  end
  else
  begin
    // Project C onto the *line* defined by A and B
    // Calculate t = dot(C - A, B - A) / |B - A|^2
    dx_CA := C.X - A.X;
    dy_CA := C.Y - A.Y;
    dotProduct := Int64(dx_CA)*dx_BA + Int64(dy_CA)*dy_BA; // Use Int64

    // Clamp t to the range [0, 1] to ensure the projection point
    // considered is within the segment AB.
    // t < 0 means C projects behind A, closest point on segment is A.
    // t > 1 means C projects beyond B, closest point on segment is B.
    // 0 <= t <= 1 means C projects onto the segment itself.
    t := Max(0.0, Min(1.0, dotProduct / L2));

    // Calculate the projection point (closest point on the segment)
    // Proj = A + t * (B - A)
    ProjX := A.X + t * dx_BA;
    ProjY := A.Y + t * dy_BA;

    // Calculate the squared distance from C to the projection point
    Result := Power(C.X - ProjX, 2) + Power(C.Y - ProjY, 2);
    // Alternative using Int64 temporarily for precision if needed, but result is Double:
    // var dx_CP := C.X - ProjX;
    // var dy_CP := C.Y - ProjY;
    // Result := dx_CP*dx_CP + dy_CP*dy_CP;
  end;
end;

// --- Rest of the TNoodleLink implementation follows ---

function TNoodleLink.HitTest(P: TPoint; PaintBox: TWinControl; SagFactor: Single; LineTolerance, HandleRadius: Integer; out HitHandle: TLinkEndPointType): Boolean;
var
  // ... other declarations ...
  NearestDistSq: Double; // This variable is a Double
  // ...
begin
  // ...
  // Iterate through Bezier segments
  // NearestDistSq := MaxInt64; // << OLD Line
  NearestDistSq := System.Math.MaxDouble; // << CORRECTED Line: Use MaxDouble for a Double variable
  // Or, if System.Math is unambiguously in scope, just:
  // NearestDistSq := MaxDouble;

  var ptPrev := P0;
  // ... rest of the function
end;


end. // End of NoodleLinkUnit