unit uNoodleLink;

interface

uses
  System.Classes, Vcl.Controls, System.Types, System.SysUtils,
  System.Math, Vcl.Graphics, Vcl.Forms;


type
  TLinkPointType = (lptA, lptB, lptNone);

type
  // Record to hold info about a potential connection point
  TNoodleHandle = record
    PointType: TLinkPointType;
    ARectF: TRectF;
    IsValid: Boolean;
    CenterF: TPointF;
    procedure SetEmpty();
    class operator Equal(a, b: TNoodleHandle): Boolean;
  end;

type
  TNoodleLink = class
  private
    FNoodleHandles: array[0..1] of TNoodleHandle;
    FIsSelected: Boolean;
    FSelectedHandle: TLinkPointType; // Indicates if A or B handle is grabbed.
    FUserData: TObject;
  function GetCenterPoint(ARect: TRectF): TPointF;

  public
    constructor Create(); overload;
    constructor Create(RectA: TRectF; RectB: TRectF); overload;
    destructor Destroy; override;
    // Function to check if a point is near this link's line or handles
    function HitTest(P: TPointF; out HitHandle: TNoodleHandle): Boolean;
    function HitTestNoodle(P: TPointF; out HitHandle: TNoodleHandle): Boolean;
    // Get details for a specific end of the noodle.
    function GetNoodleHandleCenter(ALinkPointType: TLinkPointType): TPointF;
    function GetNoodleHandle(ALinkPointType: TLinkPointType): TNoodleHandle;


    // Does the noodle have this handle.
//    function TestForNoodleHandle(ANoodleHandle: TNoodleHandle): boolean;


    property IsSelected: Boolean read FIsSelected write FIsSelected;
    property SelectedHandle: TLinkPointType read FSelectedHandle write
      FSelectedHandle; // Use HitTest to set this
    property NoodleHandleStart: TNoodleHandle read FNoodleHandles[0];
    property NoodleHandleEnd: TNoodleHandle read FNoodleHandles[1];
    property UserData: TObject read FUserData write FUserData;
  end;

  // Helper function. Return ROUNDED TRect.
  function ConvertTRectFToTRect(const ARectF: TRectF): TRect;
  function ConvertTPointFToTPoint(const APointF: TPointF): TPoint;

var
  FHitTolerance: Integer = 5; // Pixels tolerance for hitting handles.
  FLineTolerance: Integer = 5; // Pixels tolerance for hitting lines.
  FHandleRadius: Integer = 4; //
  FSagFactor: Single = 0.5;

implementation

function IsValidPointF(const P: TPointF): Boolean;
begin
  Result := not ((P.X = 0) and (P.Y = 0));
end;

class operator TNoodleHandle.Equal(a, b: TNoodleHandle): Boolean;
var
  dist: Single;
begin
// IMPORTANT : CenterF must be assigned when ARectF is assigned.
// Calculate the distance between the centers of the two handles
  dist := a.CenterF.Distance(b.CenterF);
// Consider them equal if the distance is within the global FHandleRadius tolerance
  Result := dist <= FHitTolerance;
end;

function ConvertTPointFToTPoint(const APointF: TPointF): TPoint;
begin
  Result := TPoint.Create(
    Round(APointF.X),
    Round(APointF.Y));
end;


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
function TNoodleLink.GetCenterPoint(ARect: TRectF): TPointF;
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
  FNoodleHandles[0].PointType := lptA;
  FNoodleHandles[0].IsValid := not RectA.IsEmpty;
  if not RectA.IsEmpty then
  begin
    FNoodleHandles[0].ARectF := RectA;
    FNoodleHandles[0].CenterF := GetCenterPoint(RectA);
  end;
  // Initialize handle B
  FNoodleHandles[1].PointType := lptB;
  FNoodleHandles[1].IsValid := not RectB.IsEmpty;
  if not RectB.IsEmpty then
  begin
    FNoodleHandles[1].ARectF := RectB;
    FNoodleHandles[1].CenterF := GetCenterPoint(RectB);
  end;
end;

constructor TNoodleLink.Create;
begin
  inherited Create;
  // Initialize handle A
  FNoodleHandles[0].PointType := lptNone;
  FNoodleHandles[0].ARectF := TRectF.Empty;
  FNoodleHandles[0].IsValid := false;
  FNoodleHandles[0].CenterF := TPointF.Zero;

  // Initialize handle B
  FNoodleHandles[1].PointType := lptB;
  FNoodleHandles[1].ARectF := TRectF.Empty;
  FNoodleHandles[1].IsValid := false;
  FNoodleHandles[1].CenterF := TPointF.Zero;

  FIsSelected := False;
  FSelectedHandle := lptNone; // Default, doesn't mean much until hit tested.
end;

destructor TNoodleLink.Destroy;
begin
  // Free UserData if assigned and owned, or handle externally
  inherited Destroy;
end;

function TNoodleLink.GetNoodleHandle(ALinkPointType: TLinkPointType):
    TNoodleHandle;
begin
  Result := FNoodleHandles[Ord(ALinkPointType)];
end;

function TNoodleLink.GetNoodleHandleCenter(ALinkPointType: TLinkPointType):
    TPointF;
var
  ARect: TRectF;
begin
  Result := TPointF.Zero;
  if not FNoodleHandles[Ord(ALinkPointType)].IsValid then
    Exit;
  ARect := FNoodleHandles[Ord(ALinkPointType)].ARectF;
  Result := GetCenterPoint(ARect);
end;

function TNoodleLink.HitTest(P: TPointF; out HitHandle: TNoodleHandle): Boolean;
var
  //  FLineTolerance, FHandleRadius: Integer;
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
  HitHandle.SetEmpty(); // Assign an empty HitHandle...
  P0 :=  TPointF.Zero;
  P1 :=  TPointF.Zero;
  HandleRadiusSq := FHandleRadius * FHandleRadius;
  NearestDistSq := System.Math.MaxDouble; // Find minimum distance squared.

  // Check if point is near [0] handle
  if FNoodleHandles[0].IsValid then
  begin
    P0 := FNoodleHandles[0].CenterF;
    DistSq := (P.X - P0.X) * (P.X - P0.X) + (P.Y - P0.Y) * (P.Y - P0.Y);
    if DistSq <= HandleRadiusSq then
    begin
      Result := True;
      HitHandle := FNoodleHandles[0];
      Exit;
    end;
  end;

  // Check if point is near [1] handle
  if FNoodleHandles[1].IsValid then
  begin
    P1 := FNoodleHandles[1].CenterF;
    DistSq := (P.X - P1.X) * (P.X - P1.X) + (P.Y - P1.Y) * (P.Y - P1.Y);
    if DistSq <= HandleRadiusSq then
    begin
      Result := True;
      HitHandle := FNoodleHandles[1];
      Exit;
    end;
  end;

  if not (FNoodleHandles[0].IsValid and FNoodleHandles[1].IsValid) then
    Exit(False);

  // --- More complex: Check if point is near the Bezier curve ---
  // Approximate the curve with line segments and check distance to segments.
  // This is simpler than precise Bezier distance calculation.
  if IsValidPointF(P0) and IsValidPointF(P1) then
  begin
    // Calculate control point (simplified version from your code)
    var MidPointX := (P0.X + P1.X) / 2;
    var MidPointY := (P0.Y + P1.Y) / 2;
    var Distance := System.Math.Hypot(P1.X - P0.X, P1.Y - P0.Y);
    var ActualSag := 0.0;
    if Distance > 10 then
      ActualSag := Distance * FSagFactor;

    PControl.X := Round(MidPointX);
    PControl.Y := Round(MidPointY + ActualSag); // Simple vertical sag

    // Iterate through Bezier segments
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
  end;

  if NearestDistSq <= (FLineTolerance * FLineTolerance) then
  begin
    Result := True;
  end;

end;

function TNoodleLink.HitTestNoodle(P: TPointF;
  out HitHandle: TNoodleHandle): Boolean;
var
  P0, P1: TPointF;
  DistSq, HandleRadiusSq: Double;
begin
  Result := False;
  HitHandle.SetEmpty(); // Assign an empty HitHandle...
  HandleRadiusSq := FHandleRadius * FHandleRadius;

  // Check if point is near [0] handle
  if FNoodleHandles[0].IsValid then
  begin
    P0 := FNoodleHandles[0].CenterF;
    DistSq := (P.X - P0.X) * (P.X - P0.X) + (P.Y - P0.Y) * (P.Y - P0.Y);
    if DistSq <= HandleRadiusSq then
    begin
      Result := True;
      HitHandle := FNoodleHandles[0];
      Exit;
    end;
  end;
  // Check if point is near [1] handle
  if FNoodleHandles[1].IsValid then
  begin
    P1 := FNoodleHandles[1].CenterF;
    DistSq := (P.X - P1.X) * (P.X - P1.X) + (P.Y - P1.Y) * (P.Y - P1.Y);
    if DistSq <= HandleRadiusSq then
    begin
      Result := True;
      HitHandle := FNoodleHandles[1];
      Exit;
    end;
  end;

end;



procedure TNoodleHandle.SetEmpty;
begin
  // Assign an empty HitHandle...
  PointType := lptNone;
  ARectF := TRectF.Empty;
  IsValid := false; // Assign as empty...
  CenterF := TPointf.Zero;
end;

end.
