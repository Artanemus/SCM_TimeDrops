unit uNoodle;

interface

uses
  System.Classes, Vcl.Controls, System.Types, System.SysUtils,
  System.Math, Vcl.Graphics, Vcl.Forms, SCMDefines;

type
  // Record to hold info about the connection point (or handle).
  TNoodleHandle = record
    RectF: TRectF;
    Bank: integer;  // Bank 0 = SCM : Bank 1 = TDS.
    Lane: integer;  // 1 to SwimClubMeet.dbo.SwimClub.NumOfLanes.

    //  Following identifiers are used to load Noodles....
    { Possible heatID's - dependant on Bank...
     - (SCM) SwimClubMeet.dbo.HeatIndividual.HeatID.
     - (TDS) dmTDS.tblmHeat.HeatID.
     }
    HeatID: integer;
    { Possible LaneID's - dependant on Bank...
     - (SCM - EventTypeID = 1) SwimClubMeet.dbo.Entrant.Lane.
     - (SCM - EventTypeID = 2) SwimClubMeet.dbo.Team.Lane.
     - (TDS) dmTDS.tblmLane.LaneID.
     }
    LaneID: Integer;

  private
    function GetIsValid: boolean;

  public
    procedure Clear;
    property IsValid: boolean read GetIsValid;
    class operator Equal(a, b: TNoodleHandle): Boolean;
  end;

TNoodleHandleP = ^TNoodleHandle;


type
  TNoodle = class
  private
    FIsSelected: Boolean;
    // SCM - index 0 (Bank 0), TDS - index 1 (Bank 1)...
    FNoodleHandles: array[0..1] of TNoodleHandle;
    FUserData: TObject;
  public
    constructor Create(); overload;
    constructor Create(RectBank0, RectBank1: TRectF); overload;
    destructor Destroy; override;
    function GetHandlePtr(Bank: integer): TNoodleHandleP;
    procedure GetOtherHandle(const AHandle: TNoodleHandle; out BHandle:
        TNoodleHandle);
//    procedure GetOtherHandlePtr(const AHandle: TNoodleHandle; var BHandlePtr:
//        TNoodleHandleP);
    function HasValidHandles: Boolean;
    function IsPointOnHandle(P: TPointF; out Handle: TNoodleHandle): Boolean;overload;
    // Checks to see if the point is near too either of the two link's handles.
    // if so then the function returns a pointer to the handle
    // else HandlePtr = nil.
    function IsPointOnHandle(P: TPointF; var HandlePtr: TNoodleHandleP): Boolean;overload;
    // Function to check if a point is near this link's line.
    function IsPointOnRope(P: TPointF): Boolean;

    // Function to check if a point is near this link's line or handles
    function IsPointOnRopeOrHandle(P: TPointF; out Handle: TNoodleHandle): Boolean; overload;
    function IsPointOnRopeOrHandle(P: TPointF; var HandlePtr: TNoodleHandleP): Boolean; overload;

    property IsSelected: Boolean read FIsSelected write FIsSelected;

    property UserData: TObject read FUserData write FUserData;
  end;

  // Helper function. Return ROUNDED TRect.
  function TRectFToTRect(const ARectF: TRectF): TRect;
  function TPointFToTPoint(const APointF: TPointF): TPoint;


var
  FHitTolerance: Integer = 12; // Pixels tolerance for hitting handles.
  FLineTolerance: Integer = 5; // Pixels tolerance for hitting lines.
  FHandleRadius: Integer = 8;

implementation







function IsValidPointF(const P: TPointF): Boolean;
begin
  Result := not ((P.X = 0) and (P.Y = 0));
end;

class operator TNoodleHandle.Equal(a, b: TNoodleHandle): Boolean;
var
  dist: Single;
  ac, bc: TPointF;
begin
  ac := a.RectF.CenterPoint;
  bc := b.RectF.CenterPoint;
  dist := ac.Distance(bc);
// Consider them equal if the distance is within the global FHandleRadius tolerance
  Result := dist <= FHitTolerance;
end;

function TNoodleHandle.GetIsValid: boolean;
begin
  if RectF.IsEmpty then  result := false else result := true;
end;


function TPointFToTPoint(const APointF: TPointF): TPoint;
begin
  Result := TPoint.Create(
    Round(APointF.X),
    Round(APointF.Y));
end;


function TRectFToTRect(const ARectF: TRectF): TRect;
begin
  Result := TRect.Create(
    Round(ARectF.Left),
    Round(ARectF.Top),
    Round(ARectF.Right),
    Round(ARectF.Bottom)
  );
end;

// --- Helper Function: Squared distance from Point C to Line Segment AB ---
function SquareDistanceToSegment(const C, A, B: TPointF): Double;
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

constructor TNoodle.Create;
begin
  inherited Create;
  // Initialize handle A
  FNoodleHandles[0].RectF := TRectF.Empty;
  // Initialize handle B
  FNoodleHandles[1].RectF := TRectF.Empty;
  FIsSelected := False;
end;

// Gets the center point of given rectF.
(*
  function TNoodle.GetCenterPoint(ARect: TRectF): TPointF;
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
*)

// --- TNoodle Implementation ---

constructor TNoodle.Create(RectBank0, RectBank1: TRectF);
begin
  inherited Create;
  if not RectBank0.IsEmpty then
    FNoodleHandles[0].RectF := RectBank0 else FNoodleHandles[0].Clear;
  if not RectBank1.IsEmpty then
    FNoodleHandles[1].RectF := RectBank1 else FNoodleHandles[1].Clear;
end;

destructor TNoodle.Destroy;
begin
  // Free UserData if assigned and owned, or handle externally
  inherited Destroy;
end;

function TNoodle.GetHandlePtr(Bank: integer): TNoodleHandleP;
begin
  if Bank in [0..1] then
    result := @FNoodleHandles[Bank]
  else
    result := nil;
end;

//function TNoodle.GetHandle(ALinkPointType: TLinkPointType): TNoodleHandle;
//begin
//  Result := FNoodleHandles[Ord(ALinkPointType)];
//end;

//function TNoodle.GetHandleCenter(ALinkPointType: TLinkPointType): TPointF;
//var
//  ARect: TRectF;
//begin
//  Result := TPointF.Zero;
//  if not FNoodleHandles[Ord(ALinkPointType)].IsValid then
//    Exit;
//  ARect := FNoodleHandles[Ord(ALinkPointType)].ARectF;
//  Result := GetCenterPoint(ARect);
//end;

procedure TNoodle.GetOtherHandle(const AHandle: TNoodleHandle; out BHandle:
    TNoodleHandle);
begin
  if FNoodleHandles[0] = AHandle then
    BHandle := FNoodleHandles[1]
  else
    BHandle := FNoodleHandles[0];
end;

(*
procedure TNoodle.GetOtherHandlePtr(const AHandle: TNoodleHandle; var
    BHandlePtr: TNoodleHandleP);
begin
  if FNoodleHandles[0] = AHandle then
    BHandlePtr := @FNoodleHandles[1]
  else
    BHandlePtr := @FNoodleHandles[0];
end;
*)

function TNoodle.HasValidHandles: Boolean;
begin
  if FNoodleHandles[0].RectF.IsEmpty or FNoodleHandles[1].RectF.IsEmpty then
  result := false else result := true;
end;

function TNoodle.IsPointOnHandle(P: TPointF;  out Handle: TNoodleHandle): Boolean;
var
HandlePtr: TNoodleHandleP;
begin
  Handle.RectF := TRectF.Empty; // Assign invalid handle.
  HandlePtr := nil; // Assign an empty HitHandle...
  result := false;
  if IsPointOnHandle(P, HandlePtr) then
  begin
    Handle := HandlePtr^;
    result := true;
  end;
end;

function TNoodle.IsPointOnHandle(P: TPointF; var HandlePtr: TNoodleHandleP): Boolean;
var
  P0, P1: TPointF;
  DistSq, HandleRadiusSq: Double;
begin
  Result := False;
  HandlePtr := nil; // Assign an empty HitHandle...
  HandleRadiusSq := FHandleRadius * FHandleRadius;

  // Check if point is near [0] handle
  if FNoodleHandles[0].IsValid then
  begin
    P0 := FNoodleHandles[0].RectF.CenterPoint;
    DistSq := (P.X - P0.X) * (P.X - P0.X) + (P.Y - P0.Y) * (P.Y - P0.Y);
    if DistSq <= HandleRadiusSq then
    begin
      Result := True;
      HandlePtr := @FNoodleHandles[0];
      Exit;
    end;
  end;
  // Check if point is near [1] handle
  if FNoodleHandles[1].IsValid then
  begin
    P1 := FNoodleHandles[1].RectF.CenterPoint;
    DistSq := (P.X - P1.X) * (P.X - P1.X) + (P.Y - P1.Y) * (P.Y - P1.Y);
    if DistSq <= HandleRadiusSq then
    begin
      Result := True;
      HandlePtr := @FNoodleHandles[1];
      Exit;
    end;
  end;

end;

function TNoodle.IsPointOnRope(P: TPointF): Boolean;
var
  P0, P1, PControl, pt: TPointF;
  i: Integer;
  t: Single;
  NearestDistSq: Double;
begin
  result := false;
  NearestDistSq := MaxInt;

  If FNoodleHandles[0].RectF.IsEmpty or FNoodleHandles[1].RectF.IsEmpty then
    Exit;

  P0 := FNoodleHandles[0].RectF.CenterPoint;
  P1 := FNoodleHandles[1].RectF.CenterPoint;
  // ASSERT again...
  if IsValidPointF(P0) and IsValidPointF(P1) then
  begin
    // --- More complex: Check if point is near the Bezier curve ---
    // Approximate the curve with line segments and check distance to segments.
    // This is simpler than precise Bezier distance calculation.
    var MidPointX := (P0.X + P1.X) / 2;
    var MidPointY := (P0.Y + P1.Y) / 2;
    var Distance := System.Math.Hypot(P1.X - P0.X, P1.Y - P0.Y);
    var ActualSag := 0.0;
    if Distance > 10 then
      ActualSag := Distance * scmSagFactor;

    PControl.X := Round(MidPointX);
    PControl.Y := Round(MidPointY + ActualSag); // Simple vertical sag

    // Iterate through Bezier segments
    var ptPrev := P0;
    for i := 1 to scmNumOfSegments do
    begin
      t := i / scmNumOfSegments;
      // Quadratic Bezier formula
      pt.X := Round(Power(1 - t, 2) * P0.X + 2 * (1 - t) * t * PControl.X +
        Power(t, 2) * P1.X);
      pt.Y := Round(Power(1 - t, 2) * P0.Y + 2 * (1 - t) * t * PControl.Y +
        Power(t, 2) * P1.Y);

      // Calculate squared distance from point P to the line segment ptPrev -> pt
      // (Using SquareDistanceToSegment function - implementation below)

      var SegDistSq := SquareDistanceToSegment(P, ptPrev, pt);
      if SegDistSq < NearestDistSq then
      begin
        NearestDistSq := SegDistSq;
      end;
      ptPrev := pt;
    end;
  end;

  if NearestDistSq <= (FLineTolerance * FLineTolerance) then Result := True;

end;


function TNoodle.IsPointOnRopeOrHandle(P: TPointF;  out Handle: TNoodleHandle): Boolean;
begin
  Handle.RectF := TRectF.Empty; // Assign invalid handle.
  result := false;
  if IsPointOnRopeOrHandle(P, Handle) then
  begin
    result := true;
  end;
end;


function TNoodle.IsPointOnRopeOrHandle(P: TPointF; var HandlePtr: TNoodleHandleP): Boolean;
begin
  HandlePtr := nil; // Assign an empty HitHandle...
  if IsPointOnHandle(P, HandlePtr) then
  begin
    if Assigned(HandlePtr) then
    begin
      result := true;
      exit;
    end;
  end;
  result := IsPointOnRope(p);
end;


procedure TNoodleHandle.Clear;
begin
  // Assign an empty HitHandle...
  RectF := TRectF.Empty;
end;

end.
