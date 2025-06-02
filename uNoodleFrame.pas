unit uNoodleFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  System.Generics.Collections, Vcl.VirtualImage, System.Math,
  dmIMG, uNoodle, System.Types, Vcl.StdCtrls, SCMDefines, Vcl.Menus,
  System.Actions, Vcl.ActnList, uNoodleData; // , dmSCM, Data.DB, dmTDS;

type
  // State for dragging operations
  TNoodleDragState = (ndsIdle, ndsDraggingNew, ndsDraggingExistingHandle);

type
  // Record to hold info about a potential connection point
  THotSpot = record
    RectF: TRect;
    Bank: Integer; // 0 = SCM :: 1 = TDS.
    Lane: Integer; // 1 to SwimClubMeet.dbo.SwimClub.NumOfLanes.
    class operator Equal(a, b: THotSpot): Boolean;
    class operator Assign(var a: THotSpot; const [ref] b: THotSpot);
    function GetCnvRect(): TRect;
    property Rect: TRect read GetCnvRect;
  end;

type
  TNoodleFrame = class(TFrame)
    actDeleteNoodle: TAction;
    ActnList: TActionList;
    DeleteNoodle: TMenuItem;
    pbNoodles: TPaintBox;
    pumenuNoodle: TPopupMenu;
    procedure actDeleteNoodleExecute(Sender: TObject);
    procedure actDeleteNoodleUpdate(Sender: TObject);
    procedure pbNoodlesMouseDown(Sender: TObject; Button: TMouseButton; Shift:
      TShiftState; X, Y: Integer);
    procedure pbNoodlesMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure pbNoodlesMouseUp(Sender: TObject; Button: TMouseButton; Shift:
      TShiftState; X, Y: Integer);
    procedure pbNoodlesPaint(Sender: TObject);
  private
    FDefaultRowHeight: Integer;
    FMousePoint: TPoint;
    FDragHandlePtr: TNoodleHandleP;
    FDragAnchor: TNoodleHandle;
    FDragNoodle: TNoodle;
    FDragState: TNoodleDragState;
    FDragColor: TColor;
    FHandleColor: TColor;
    FHotSpots: Array of THotSpot; // HotSpots *****************
    FHotSpotAnchour: THotSpot;
    FixedRowHeight: Integer; // assigned TMS TAdvDBGrid row height.
    FNoodleColor: TColor;
    FNoodles: TObjectList<TNoodle>; // Noodles *****************
    FRopeColor: TColor;
    FRopeThickness: Integer;
    FSelectedHandleColor: TColor;
    FSelectedNoodleColor: TColor;
    FSelectedNoodle: TNoodle;
    FSelectedRopeColor: TColor;
    FNumberOfLanes: Integer;
    procedure InitializeHotSpots;
    procedure ClearLinkSelection;
    procedure DrawNoodleHandle(ACanvas: TCanvas; P: TPoint; AColor: TColor;
      ARadius: Integer);
    procedure DrawNoodleLink(ACanvas: TCanvas; P0, P1: TPointF; AColor: TColor;
      AThickness: Integer; ASelected: Boolean);
    procedure DrawQuadraticBezierCurve(ACanvas: TCanvas; P0, P1, P2: TPoint;
      NumSegments: Integer);

    procedure TryGetHandlePtrAtPoint(P: TPoint; out AHandlePtr: TNoodleHandleP);


    function GetSelectNoodle: TNoodle;
    procedure SetSelectNoodle(ALink: TNoodle);

    function TryHitTestNoodleOrHandlePtr(P: TPoint; var Noodle: TNoodle; out
      HandlePtr: TNoodleHandleP): Boolean; overload;

    function TryHitTestHotSpot(P: TPoint; out HotSpot: THotSpot): Boolean;

protected
    procedure MSG_UpdateUINOODLES(var Msg: TMessage); message SCM_UPDATE_NOODLES;


  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property SelectedNoodle: TNoodle read GetSelectNoodle;
  end;

var
  NoodleFrame: TNoodleFrame;

  FPreviewHitTolerance: Integer = 5; // Pixels tolerance for hitting HotSpots.

implementation

{$R *.dfm}


constructor TNoodleFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); // Call the inherited constructor

  if not Assigned(NoodleData) then NoodleData := TNoodleData.Create();

  FNoodles := TObjectList<TNoodle>.Create(True); // True = OwnsObjects
  FDragState := ndsIdle;
  FSelectedNoodle := nil;
  FDragNoodle := nil;

  // --- Configure COLORS ---
  FDragColor := clBlack;
  FRopeColor := clLtGray;
  FHandleColor := clLtGray;
  FNoodleColor := clLtGray;

  FSelectedRopeColor := clHighlight;
  FSelectedHandleColor := clHighlight;
  FSelectedNoodleColor := clHighlight;

  FRopeThickness := 4;
  // ASSERT : Ensure PaintBox is on top and covers the grid areas
  pbNoodles.BringToFront;

  FixedRowHeight := 34; // identical to SCM TMS TAdvDBGrid.
  FDefaultRowHeight := 46; // identical to SCM TMS TAdvDBGrid.
  FNumberOfLanes := 10; // dbo.SwimClubMeet.SwimClub.NumOfLanes.

  InitializeHotSpots; // draw DOTS in left and right coloumns.

end;

destructor TNoodleFrame.Destroy;
begin
  SetLength(FHotSpots, 0); // Explicitly clear the dynamic array
  FNoodles.Free; // release noodle collection.
  if Assigned(NoodleData) then FreeAndNil(NoodleData);

  inherited Destroy; // Call the inherited destructor
end;

procedure TNoodleFrame.actDeleteNoodleExecute(Sender: TObject);
var
  ALink: TNoodle;
begin
  // delete the noodle
  for ALink in FNoodles do
  begin
    if ALink.IsSelected then
    begin
      FNoodles.Remove(ALink);
      // This will free the object - if OwnsObjects is True
      FSelectedNoodle := nil; // Clear the selected link
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
    if FSelectedNoodle <> nil then
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
  I, J, indx: Integer;
  ARect: TRect;
begin
  SetLength(FHotSpots, (FNumberOfLanes * 2));

  indx := FNumberOfLanes;
  for I := 0 to FNumberOfLanes - 1 do
  begin
    ARect.Top := FixedRowHeight + (I * FDefaultRowHeight);
    ARect.Left := 0;
    ARect.Height := FDefaultRowHeight;
    ARect.Width := FDefaultRowHeight;
    FHotSpots[I].RectF := ARect;
    FHotSpots[I].Bank := 0;
    FHotSpots[I].Lane := (I + 1);
  end;

  for J := 0 to FNumberOfLanes - 1 do
  begin
    ARect.Top := FixedRowHeight + (J * FDefaultRowHeight);
    ARect.Left := Width - FDefaultRowHeight;
    ARect.Height := FDefaultRowHeight;
    ARect.Width := FDefaultRowHeight;
    FHotSpots[indx + J].RectF := ARect;
    FHotSpots[indx + J].Bank := 1;
    FHotSpots[indx + J].Lane := (J + 1);
  end;
end;

procedure TNoodleFrame.MSG_UpdateUINOODLES(var Msg: TMessage);
var
  Noodle: TNoodle;
  Lane: integer;
  HandlePtr: TNoodleHandleP;
  RectF: TRectF;
begin
  // CLEAR THE NOODLES???
//  FNoodles.Free;

  // Also iterate just in case state is inconsistent
  // ITERATE ACROSS THE DATA RECORDS IN TDS.tblmNoodles.
(*
    for Noodle in FNoodles do
    begin
      if Assigned(NoodleData) then
      begin
        NoodleData.UpdateNData(Noodle);
        //Assign HotSpot;
        HandlePtr := Noodle.GetHandlePtr(0);
        HandlePtr.RectF := GetHotSpot(HandlePtr.Bank, HandlePtr.Lane);
        Noodle.IsSelected := false;
      end;
    end;
*)

  FSelectedNoodle := nil; // Ensure this is cleared
end;

procedure TNoodleFrame.ClearLinkSelection;
var
  Noodle: TNoodle;
begin
  // Also iterate just in case state is inconsistent
  for Noodle in FNoodles do
    Noodle.IsSelected := false;
  FSelectedNoodle := nil; // Ensure this is cleared
end;

procedure TNoodleFrame.DrawNoodleHandle(ACanvas: TCanvas; P: TPoint; AColor:
  TColor; ARadius: Integer);
begin
  ACanvas.Brush.Color := AColor;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Pen.Color := clBlack; // Optional outline
  ACanvas.Pen.Width := 1;
  ACanvas.Ellipse(P.X - ARadius, P.Y - ARadius, P.X + ARadius + 1,
    P.Y + ARadius + 1);
  ACanvas.Brush.Style := bsClear; // Reset brush
end;

procedure TNoodleFrame.DrawNoodleLink(ACanvas: TCanvas; P0, P1: TPointF;
  AColor: TColor; AThickness: Integer; ASelected: Boolean);
var
  P_Control, a, b: TPoint;
  MidPointX, MidPointY, Distance, ActualSag: Double;
begin
  // Calculate control point for Bezier
  MidPointX := (P0.X + P1.X) / 2;
  MidPointY := (P0.Y + P1.Y) / 2;
  Distance := System.Math.Hypot(P1.X - P0.X, P1.Y - P0.Y);

  ActualSag := 0.0;
  if Distance > 10 then
    ActualSag := Distance * scmSagFactor;

  P_Control.X := Round(MidPointX);
  P_Control.Y := Round(MidPointY + ActualSag); // Simple vertical sag

  // Setup pen
  ACanvas.Pen.Color := AColor;
  ACanvas.Pen.Width := AThickness;
  ACanvas.Pen.Style := psSolid;

  a.X := Round(P0.X);
  a.Y := Round(P0.Y);
  b.X := Round(P1.X);
  b.Y := Round(P1.Y);

  // Draw the Bezier curve
  DrawQuadraticBezierCurve(ACanvas, a, P_Control, b, 30); // 30 segments

  // Draw DOTS for handles.
  if ASelected then
  begin
    DrawNoodleHandle(ACanvas, a, FSelectedHandleColor, FHandleRadius);
    DrawNoodleHandle(ACanvas, b, FSelectedHandleColor, FHandleRadius);
  end
  else
  begin
    DrawNoodleHandle(ACanvas, a, FHandleColor, FHandleRadius);
    DrawNoodleHandle(ACanvas, b, FHandleColor, FHandleRadius);
  end;
end;

procedure TNoodleFrame.DrawQuadraticBezierCurve(ACanvas: TCanvas; P0, P1, P2:
  TPoint; NumSegments: Integer);
var
  I: Integer;
  t: Single;
  pt: TPoint;
begin
  if NumSegments < 1 then
    NumSegments := 1;
  ACanvas.MoveTo(P0.X, P0.Y);

  for I := 1 to NumSegments do
  begin
    t := I / NumSegments;
    // Quadratic Bezier formula: B(t) = (1-t)^2 * P0 + 2*(1-t)*t * P1 + t^2 * P2
    pt.X := Round(Power(1 - t, 2) * P0.X + 2 * (1 - t) * t * P1.X + Power(t,
      2) * P2.X);
    pt.Y := Round(Power(1 - t, 2) * P0.Y + 2 * (1 - t) * t * P1.Y + Power(t,
      2) * P2.Y);
    ACanvas.LineTo(pt.X, pt.Y);
  end;
end;

procedure TNoodleFrame.TryGetHandlePtrAtPoint(P: TPoint; out AHandlePtr:
  TNoodleHandleP);
var
  I: Integer;
  Noodle: TNoodle;
  PFloat: TPointF;
begin
  AHandlePtr := nil;
  PFloat := P; // TPointF.Create(P.X, P.Y);
  for I := 0 to FNoodles.Count - 1 do
  begin
    Noodle := FNoodles[I];
    Noodle.IsPointOnHandle(PFloat, AHandlePtr); // <-- Pass as var/out
    if AHandlePtr <> nil then
      Exit;
  end;
end;

function TNoodleFrame.GetSelectNoodle: TNoodle;
var
  Noodle: TNoodle;
begin
  result := nil;
  // Also iterate just in case state is inconsistent
  for Noodle in FNoodles do
  begin
    if Noodle.IsSelected then
    begin
      result := Noodle;
      Exit;
    end;
  end;
end;

function TNoodleFrame.TryHitTestNoodleOrHandlePtr(P: TPoint; var Noodle:
  TNoodle; out HandlePtr: TNoodleHandleP): Boolean;
var
  I: Integer;
begin
  result := false;
  Noodle := nil;
  HandlePtr := nil;

  // Iterate through the Noodles
  for I := 0 to FNoodles.Count - 1 do
  begin
    Noodle := FNoodles[I]; // Get the link at the current index
    if Noodle.IsPointOnRopeOrHandle(P, HandlePtr) then
    begin
      result := True;
      Exit; // Exit as soon as a match is found
    end;
  end;
end;

function TNoodleFrame.TryHitTestHotSpot(P: TPoint;
  out HotSpot: THotSpot): Boolean;
var
  I: Integer;
begin
  result := false;
  for I := Low(FHotSpots) to High(FHotSpots) do
  begin
    if FHotSpots[I].RectF.Contains(P) then
    begin
      HotSpot := FHotSpots[I];
      result := True;
      Exit;
    end;
  end;
end;

procedure TNoodleFrame.pbNoodlesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  HitNoodle: TNoodle;
  HotSpot: THotSpot;
begin
  if Button <> mbLeft then
    Exit;

  FMousePoint := Point(X, Y);
  ClearLinkSelection; // Deselect previous link first
  FDragHandlePtr := nil;
  FDragNoodle := nil;

  // 1. Check if clicking on an NoodleHandle
  if TryHitTestNoodleOrHandlePtr(FMousePoint, HitNoodle, FDragHandlePtr) then
  begin
    if Assigned(FDragHandlePtr) then
    begin
      FDragState := ndsDraggingExistingHandle;
      FDragNoodle := HitNoodle; // Store the link being dragged.
      HitNoodle.GetOtherHandle(FDragHandlePtr^, FDragAnchor);
      // Assign Anchour Handle.
      SetSelectNoodle(HitNoodle); // Select the link visually.
      pbNoodles.Invalidate;
      Exit; // Don't check for other things
    end
    else
    begin
      // 2. Clicked on an existing link's LINE (not handles)
      SetSelectNoodle(HitNoodle);
      pbNoodles.Invalidate;
      // Don't start drag, just select
      Exit;
    end;
  end;

  // 3. Check if clicking on a HotSpot
  if TryHitTestHotSpot(FMousePoint, HotSpot) then
  begin
    FDragState := ndsDraggingNew;
    FHotSpotAnchour := HotSpot;
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
  // Add hover effects here if desired (check TryHitTestNoodleOrHandlePtr/FindNoodleHandleAtHotSpot)
end;

(*
  procedure TNoodleFrame.AssignDataSCM(HandlePtr: TNoodleHandleP);
  begin
  if SCM.DataIsActive and (SCM.qryHeat.IsEmpty = false) then
  begin
  HandlePtr.HeatID := SCM.qryHeat.FieldByName('HeatID').AsInteger;
  if SCM.qryDistance.FieldByName('EventTypeID').AsInteger =
  ORD(scmEventType.etINDV) then
  HandlePtr.SourceID := SCM.qryINDV.FieldByName('EntrantID').AsInteger
  else
  HandlePtr.SourceID := SCM.qryTEAM.FieldByName('TeamID').AsInteger;
  end
  else
  begin
  HandlePtr.HeatID := 0;
  HandlePtr.SourceID := 0;
  end;
  end;
*)

(*
  procedure TNoodleFrame.AssignDataTDS(HandlePtr: TNoodleHandleP);
  begin
  if TDS.DataIsActive and (TDS.tblmHeat.IsEmpty = false) then
  begin
  HandlePtr.HeatID := TDS.tblmHeat.FieldByName('HeatID').AsInteger;
  HandlePtr.SourceID := TDS.tblmLane.FieldByName('LaneID').AsInteger;
  end
  else
  begin
  HandlePtr.HeatID := 0;
  HandlePtr.SourceID := 0;
  end;
  end;
*)

procedure TNoodleFrame.pbNoodlesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Noodle: TNoodle;
  HandlePtr: TNoodleHandleP;
  HotSpot: THotSpot;
  IsDuplicate: Boolean;

  procedure AssignBank0Handle(Noodle: TNoodle);
  begin
    // Handle to bank 0 - Anchored hotspot...
    HandlePtr := Noodle.GetHandlePtr(0);
    // HandlePtr.Bank ... syntactic sugar, readability, common practice.
    // HandlePtr^.Bank ... more explicit and correct.
    HandlePtr.Bank := FHotSpotAnchour.Bank;
    HandlePtr.Lane := FHotSpotAnchour.Lane;
    NoodleData.UpdateNData(Noodle);
  end;

  procedure AssignBank1Handle(Noodle: TNoodle);
  begin
    // Handle to bank 1 - MousePoint over hotspot...
    HandlePtr := Noodle.GetHandlePtr(1);
    HandlePtr.Bank := HotSpot.Bank;
    HandlePtr.Lane := HotSpot.Lane;
    NoodleData.UpdateNData(Noodle);
  end;

begin
  if Button <> mbLeft then
    Exit;

  case FDragState of
    ndsDraggingNew:
      begin
        // CHECKS ...
        // --- Validation: Prevent linking dot to itself or same grid row ---
        if TryHitTestHotSpot(FMousePoint, HotSpot) then
        begin
          // released button over same bank as anchour - illegal ...
          if (HotSpot.Bank = FHotSpotAnchour.Bank) then
          begin
            FDragState := ndsIdle;
            pbNoodles.Invalidate; // Redraw final state
            Exit;
          end;
          // CHECKS : before creating link - Check if this will be a duplicate link.
          IsDuplicate := false;
          for Noodle in FNoodles do
          begin
            // For each existing Noodle in the FNoodles list:
            // Is the target drop HotSpot already an active handle?
            if Noodle.IsPointOnHandle(HotSpot.Rect.CenterPoint, HandlePtr) then
            begin
              IsDuplicate := True;
              break;
            end;
          end;

          if not IsDuplicate then
          begin
            // Create the new link
            Noodle := TNoodle.Create(FHotSpotAnchour.RectF, HotSpot.RectF);
            FNoodles.Add(Noodle);

            // Important  : Assign correct bank .
            if FHotSpotAnchour.Bank = 0 then
              AssignBank0Handle(Noodle)
            else
              AssignBank1Handle(Noodle);

            if HotSpot.Bank = 0 then
              AssignBank0Handle(Noodle)
            else
              AssignBank1Handle(Noodle);

            SetSelectNoodle(Noodle); // Select the newly created link

            // Optional: Trigger an OnLinkCreated event here
            // if Assigned(FOnLinkCreated) then FOnLinkCreated(Self, Noodle);

          end;
          FDragState := ndsIdle;
          pbNoodles.Invalidate; // Redraw final state
          Exit;
        end;
      end;

    ndsDraggingExistingHandle:
      begin
        // QUICK TEST - is it dropped over a HotSpot = valid drop zone.
        if TryHitTestHotSpot(FMousePoint, HotSpot) then
        begin
          // CHECK: can drop on the same bank - illegal.
          if HotSpot.Bank = FDragAnchor.Bank then
          begin
            FDragState := ndsIdle;
            pbNoodles.Invalidate; // Redraw final state
            Exit;
          end;

          TryGetHandlePtrAtPoint(HotSpot.Rect.CenterPoint, HandlePtr);
          // CHECK: A noodle handle already occupies this HotSpot.
          if Assigned(HandlePtr) then // safe to drop.
          begin
            FDragState := ndsIdle;
            pbNoodles.Invalidate; // Redraw final state
            Exit;
          end;

          if Assigned(FDragHandlePtr) then // ASSERT.
          begin
            // Go modify the active Noodle's handle...
            FDragHandlePtr.RectF := TRectF.Create(HotSpot.RectF);
            FDragHandlePtr.Bank := HotSpot.Bank;
            // Note: Bank doesn't need an update.
            FDragHandlePtr.Lane := HotSpot.Lane;
            NoodleData.UpdateNData(FDragNoodle);
          end;

          FDragState := ndsIdle;
          FDragNoodle := nil; // Clear the link being dragged.
          pbNoodles.Invalidate; // Redraw final state
        end
      end;

    ndsIdle:
      begin
        // not context.
      end;

  end; // end of case.

  FDragState := ndsIdle;
  pbNoodles.Invalidate; // Redraw final state

end;

procedure TNoodleFrame.pbNoodlesPaint(Sender: TObject);
var
  Noodle: TNoodle;
  P0, P1: TPointF;
  Spot: TPoint;
  HotSpot: THotSpot;
  Rect: TRect;
  Canvas: TCanvas;
  AColor: TColor;
  deflate: Integer;
  HandlePtr: TNoodleHandleP;

  procedure DrawGridIcons();
  begin
    // if the current point is hovering over a HotSpot - then show
    // the 'dragging' preview endpoint ...
    // this indicates to the user - a possible snap available
    if TryHitTestHotSpot(FMousePoint, HotSpot) then
    begin
      Spot := FMousePoint;
      Spot.X := Spot.X - (IMG.vimglistDTGrid.Height DIV 2);
      Spot.Y := Spot.Y - (IMG.vimglistDTGrid.Height DIV 2);
      // still in close prox to anchour point...
      if ((HotSpot.Bank = FHotSpotAnchour.Bank) and
        (HotSpot.Lane = FHotSpotAnchour.Lane)) then
      begin
        // draw Default-BullsEye
        IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'DotCircle', True);
      end
      // TEST : dragging over same bank - illegal patch.
      else if (HotSpot.Bank <> FHotSpotAnchour.Bank) then
      begin
        // draw Default-BullsEye
        IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'DotCircle', True);
      end
      else
        // flag with Red-BullsEye
        IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'ActiveRTNone', True);
    end;
  end;

begin
  Canvas := (Sender as TPaintBox).Canvas;
  Canvas.Brush.Style := bsClear;
  // Make background transparent (won't erase grids)

  // draw the under lining HotSpots
  for HotSpot in FHotSpots do
  begin
    deflate := ((FDefaultRowHeight - IMG.vimglistDTGrid.Height) DIV 2);
    Rect := HotSpot.Rect; // conversion of THostSpot.RectF.
    Rect.inflate(-deflate, -deflate);
    IMG.vimglistDTGrid.Draw(Canvas, Round(Rect.Left), Round(Rect.Top),
      'EvBlue', True);
  end;

  // 1. Draw all existing noodles
  for Noodle in FNoodles do
  begin
    // Skip the Noodle when we are dragging.
    if (FDragState = ndsDraggingExistingHandle) and (Noodle = FDragNoodle) then
      continue;

    // ASSERT: Only draw if both endpoints are valid.
    if not Noodle.HasValidHandles then
      continue;

    HandlePtr := Noodle.GetHandlePtr(0);
    P0 := HandlePtr.RectF.CenterPoint;
    HandlePtr := Noodle.GetHandlePtr(1);
    P1 := HandlePtr.RectF.CenterPoint;

    if Noodle.IsSelected then
      AColor := FSelectedNoodleColor
    else
      AColor := FNoodleColor;
    DrawNoodleLink(Canvas, P0, P1, AColor, FRopeThickness, Noodle.IsSelected);
  end;

  // 2. DRAWPREVIEW LINE AND START AND END ICONS.
  if FDragState = ndsDraggingNew then
  begin
    // Draw noodle rope to current mouse pos (and ending dots).
    P0 := FHotSpotAnchour.RectF.CenterPoint;
    P1 := FMousePoint;
    DrawNoodleLink(Canvas, P0, P1, clBlack, FRopeThickness, false);
    // Draw the Default-BullsEye to anchour handle ...
    Spot := FHotSpotAnchour.RectF.CenterPoint;
    Spot.X := Spot.X - (IMG.vimglistDTGrid.Height DIV 2);
    Spot.Y := Spot.Y - (IMG.vimglistDTGrid.Height DIV 2);
    IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'DotCircle', True);

    DrawGridIcons;
  end;

  if FDragState = ndsDraggingExistingHandle then
  begin
    // Draw noodle rope to current mouse pos (and ending dots).
    P0 := FDragAnchor.RectF.CenterPoint;
    P1 := FMousePoint;
    Rect := HotSpot.Rect; // conversion of THostSpot.RectF.
    DrawNoodleLink(Canvas, P0, P1, FSelectedNoodleColor, FRopeThickness, false);

    // Draw the Default-BullsEye to dragging mouse ...
    Spot := FMousePoint;
    Spot.X := Spot.X - (IMG.vimglistDTGrid.Height DIV 2);
    Spot.Y := Spot.Y - (IMG.vimglistDTGrid.Height DIV 2);
    IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'DotCircle', True);

    // dropping onto itself..
    if FDragNoodle.IsPointOnHandle(FMousePoint, HandlePtr) then
    begin
      if HandlePtr.Bank = FDragAnchor.Bank then // flag with Red-BullsEye
        IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'ActiveRTNone', True);
    end;
    // dragging over another hotspot on the same bank.
    if TryHitTestHotSpot(FMousePoint, HotSpot) then
    begin
      if HotSpot.Bank = FDragAnchor.Bank then
        IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'ActiveRTNone', True);
    end;
    // dropping onto another noodle....
    if TryHitTestNoodleOrHandlePtr(FMousePoint, Noodle, HandlePtr) then
    begin
        ;
    end;

    // if TryHitTestHotSpot(FMousePoint, HotSpot) then
    // begin
    // // find the link and get the handle that's being dragged ..
    // if TryHitTestNoodleOrHandlePtr(FMousePoint, Noodle, HandlePtr) then
    // begin
    // if Assigned(HandlePtr) then  // found the drag handle
    // begin
    // var AnchorHandle: TNoodleHandle;
    // // get the anchor handle ...
    /// /          Noodle.GetOtherHandle(HandlePtr^, AnchorHandle);
    // // Dragging over the starting hotspot
    /// /          if (HotSpot.Lane = AnchorHandle.Lane)
    /// /            and (HotSpot.Bank = AnchorHandle.Bank) then exit; // done..
    //
    // // Same Bank - illegal. Display read bullsEye.
    // if (HotSpot.Bank = AnchorHandle.Bank) then
    // begin
    // Spot := FMousePoint;
    // Spot.X := Spot.X - (IMG.vimglistDTGrid.Height div 2);
    // Spot.Y := Spot.Y - (IMG.vimglistDTGrid.Height div 2);
    // // flag with Red-BullsEye
    // IMG.vimglistDTGrid.Draw(Canvas, Spot.X, Spot.Y, 'ActiveRTNone', true);
    // end;
    // end;
    // end;
    // end;
  end;
end;

procedure TNoodleFrame.SetSelectNoodle(ALink: TNoodle);
begin
  ClearLinkSelection; // Ensure only one is selected.
  if ALink <> nil then
  begin
    ALink.IsSelected := True;
    FSelectedNoodle := ALink;
  end;
end;

{ THotSpot }

class operator THotSpot.Assign(var a: THotSpot; const [ref] b: THotSpot);
begin
  a.RectF := b.RectF;
  a.Bank := b.Bank;
  a.Lane := b.Lane;
end;

class operator THotSpot.Equal(a, b: THotSpot): Boolean;
var
  dist: Single;
  ac, bc: TPointF;
begin
  // get the centers of the hotspots
  ac := a.RectF.CenterPoint;
  bc := b.RectF.CenterPoint;
  dist := ac.Distance(bc);
  // Consider them equal if the distance is within the global FHandleRadius tolerance.
  result := dist <= FHitTolerance;
end;

function THotSpot.GetCnvRect: TRect;
begin
  result := TRect.Create(
    Round(RectF.Left),
    Round(RectF.Top),
    Round(RectF.Right),
    Round(RectF.Bottom));
end;

end.
