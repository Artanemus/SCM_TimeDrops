unit uNoodleLink;

interface

uses
  System.Classes, Vcl.Controls, System.Types, System.SysUtils,
  System.Math, Vcl.Graphics, Vcl.Forms;

type
  TLinkPointType = (lptA, lptB);

  // Record to hold info about a potential connection point
  TNoodleConnectionPoint = record
    PointType: TLinkPointType;
    ARectF: TRectF;
    IsValid: Boolean;
    CenterF: TPointF;
  end;

type
  TNoodleLink = class
  private

    FHandles: Array[0..1] of TNoodleConnectionPoint; // 0 = A, 1 = B
    
    FIsSelected: Boolean;
    FSelectedHandle: TLinkPointType; // Indicates if A or B handle is grabbed.
    FUserData: TObject;
    FDestRow: Integer;
    FSourceRow: Integer;
  public
    constructor Create(RectA: TRectF; RectB: TRectF);
    destructor Destroy; override;
    // Function to check if a point is near this link's line or handles
    function HitTest(P: TPointF; SagFactor: Single; LineTolerance, HandleRadius: Integer; out HitHandle: TLinkPointType): Boolean;
    function GetLinkPoint(ALinkPointType: TLinkPointType): TPointF;
    function GetHandle(ALinkPointType: TLinkPointType): TNoodleConnectionPoint;
    property IsSelected: Boolean read FIsSelected write FIsSelected;
    property SelectedHandle: TLinkPointType read FSelectedHandle write FSelectedHandle; // Use HitTest to set this
    property UserData: TObject read FUserData write FUserData;
  end;

  function GetCenterPoint(ARect: TRectF): TPointF;
  function ConvertTRectFToTRect(const ARectF: TRectF): TRect;

implementation

function ConvertTRectFToTRect(const ARectF: TRectF): TRect;
begin
  Result := TRect.Create(
    Round(ARectF.Left),
    Round(ARectF.Top),
    Round(ARectF.Right),
    Round(ARectF.Bottom)
  );
end;

// --- Helper Function: Squared distance from Point C to Line Segment AB ---
function DistancePointSegmentSq(const C, A, B: TPointF): Double;
var
  L2, t: Double;
  ProjX, ProjY: Double;
  dx_BA, dy_BA : Double; // Vector B-A
  dx_CA, dy_CA : Double; // Vector C-A
  dotProduct: Double;
begin
  // Calculate squared length of the segment AB
  dx_BA := B.X - A.X;
  dy_BA := B.Y - A.Y;
  L2 := (dx_BA)*dx_BA + (dy_BA)*dy_BA; // Use Int64 to avoid overflow

  if L2 = 0.0 then // A and B are the same point
  begin
    // Squared distance from C to A
    dx_CA := C.X - A.X;
    dy_CA := C.Y - A.Y;
    Result := (dx_CA)*dx_CA + (dy_CA)*dy_CA;
  end
  else
  begin
    // Project C onto the *line* defined by A and B
    // Calculate t = dot(C - A, B - A) / |B - A|^2
    dx_CA := C.X - A.X;
    dy_CA := C.Y - A.Y;
    dotProduct := (dx_CA)*dx_BA + (dy_CA)*dy_BA; // Use Int64

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

// Gets the center point of given rectF.
function GetCenterPoint(ARect: TRectF): TPointF;
var
  ScreenPos, PaintBoxScreenPos: TPointF;
begin
  Result := TPointF.Zero; // Default invalid point
  if (ARect = TRectF.Empty) then Exit;
  try
    // Calculate center of the cell
    Result.X := ARect.Left + (ARect.Right - ARect.Left) / 2;
    Result.Y := ARect.Top + (ARect.Bottom - ARect.Top) / 2;
  except
    // Handle potential exceptions
    Result := TPointF.Zero;
  end;
end;

// --- TNoodleLink Implementation ---

constructor TNoodleLink.Create(RectA: TRectF; RectB: TRectF);
begin
  inherited Create;

  // Initialize handle A
  FHandles[0].PointType := lptA;
  FHandles[0].ARectF := RectA;
  FHandles[0].IsValid := not RectA.IsEmpty;
  FHandles[0].CenterF := GetCenterPoint(RectA);

  // Initialize handle B
  FHandles[1].PointType := lptB;
  FHandles[1].ARectF := RectB;
  FHandles[1].IsValid := not RectB.IsEmpty;
  FHandles[1].CenterF := GetCenterPoint(RectB);

  FIsSelected := False;
  FSelectedHandle := lptA; // Default, doesn't mean much until hit tested.
end;

destructor TNoodleLink.Destroy;
begin
  // Free UserData if assigned and owned, or handle externally
  inherited Destroy;
end;

function TNoodleLink.GetHandle(ALinkPointType: TLinkPointType): TNoodleConnectionPoint;
begin
  Result := FHandles[Ord(ALinkPointType)];
end;

function TNoodleLink.GetLinkPoint(ALinkPointType: TLinkPointType): TPointF;
var
  ARect: TRectF;
begin
  Result := TPointF.Zero;
  if not FHandles[Ord(ALinkPointType)].IsValid then
    Exit;
  ARect := FHandles[Ord(ALinkPointType)].ARectF;
  Result := GetCenterPoint(ARect);
end;

function TNoodleLink.HitTest(P: TPointF; SagFactor: Single; LineTolerance,
  HandleRadius: Integer; out HitHandle: TLinkPointType): Boolean;
var
  P0, P1, PControl, pt: TPointF;
  DistSq, HandleRadiusSq: Double; // Use Int64 for squared distances
  i: Integer;
  t: Single;
  NearestDistSq: Double;
  // Bezier segment approximation parameters
const
  NumSegments = 20; // Fewer segments for faster hit testing needed? Adjust.
begin
  Result := False;
  HitHandle := lptA; // Default
  HandleRadiusSq := HandleRadius * HandleRadius;

  P0 := GetLinkPoint(lptA);
  P1 := GetLinkPoint(lptB);

  // Check if point is near start handle
  DistSq := (P.X - P0.X) * (P.X - P0.X) + (P.Y - P0.Y) * (P.Y - P0.Y);
  if DistSq <= HandleRadiusSq then
  begin
    Result := True;
    HitHandle := lptA;
    Exit;
  end;

  // Check if point is near end handle
  DistSq := (P.X - P1.X) * (P.X - P1.X) + (P.Y - P1.Y) * (P.Y - P1.Y);
  if DistSq <= HandleRadiusSq then
  begin
    Result := True;
    HitHandle := lptB;
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
  if Distance > 10 then
    ActualSag := Distance * SagFactor;

  PControl.X := Round(MidPointX);
  PControl.Y := Round(MidPointY + ActualSag); // Simple vertical sag

  // Iterate through Bezier segments
  NearestDistSq := System.Math.MaxDouble; // Find minimum distance squared
  var ptPrev := P0;

  for i := 1 to NumSegments do
  begin
    t := i / NumSegments;
    // Quadratic Bezier formula
    pt.X := Round(Power(1 - t, 2) * P0.X + 2 * (1 - t) * t * PControl.X +
      Power(t, 2) * P1.X);
    pt.Y := Round(Power(1 - t, 2) * P0.Y + 2 * (1 - t) * t * PControl.Y +
      Power(t, 2) * P1.Y);

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
    // HitHandle remains the default (lptA), signifies hitting the line not a specific handle
  end;
end;

end. 
