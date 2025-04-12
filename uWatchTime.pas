unit uWatchTime;

interface

uses vcl.ComCtrls, Math, System.Types, System.IOUtils,
  Windows, System.Classes,System.StrUtils, SysUtils, Data.DB,
  System.Variants,
  System.DateUtils,
  uAppUtils;
type

  TWatchTime = class(TObject)
  private
    Times: array[1..3] of variant; // Array to store the times (as Variants).
    Indices: array[1..3] of Integer; // Array to store the original indices
    DevOk: array[1..2] of boolean; // Array to store min-mid, mid-max deviations
    fAcceptedDeviation, fAccptDevMsec: double;
    fCalcRTMethod: integer;
    fCalcRT: variant;

    function LaneIsEmpty: boolean;
    function IsValidWatchTime(ATime: variant): boolean;
    function CalcAvgWatchTime(): variant;
    function CalcRaceTime: Variant;
    procedure SortWatchTimes();
    procedure CheckDeviation();
    procedure LoadFromSettings();
    procedure AssignDataWTToLane(flds: TFields);
    procedure AssignDataLaneToWT(flds: TFields);
    procedure CalcAutoWatchTimeLane(aLaneID: integer);
    procedure CalcAutoWatchTimeHeat(aHeatID: integer);
    procedure CalcAutoWatchTimeEvent(aEventID: integer);
    procedure CalcAutoWatchTimeSession(aSessionID: integer);

  protected

  public
    constructor Create();
    destructor Destroy; override;

    procedure ProcessHeat(aHeatID: integer);

  end;

implementation

uses dmAppData, tdSetting;



{ TWatchTime }

function TWatchTime.CalcAvgWatchTime: variant;
var
  I, C: Integer;
  t: variant;
begin
  t := 0;
  c := 0;
  for I := 1 to 3 do
  begin
    if IsValidWatchTime(Times[I]) then
    begin
      t := t + Times[I];
      inc(c);
    end;
  end;
  if c > 0 then
    result := t / c
  else
    result := 0;
end;

function TWatchTime.CalcRaceTime: Variant;
var
I, count: integer;

begin

  {
  RULES USED BY DOLPHIN TIMING METHOD. (DEFAULT).
- A. If there is one watch per lane, that time will also be placed in
  'racetime'.

- B. If there are two watches for a given lane, the average will be
  computed and placed in 'racetime'.

- C. If there are 3 watch times for a given lane, the middle time will be
  placed in 'racetime'.

  CASE B. NOTE:
  If there is more than the 'Accepted Deviation' difference between the
  two watch times, the average result time will NOT be computed and
  warning icons will show for both watch times in this lane.
  The 'RaceTime' will be empty.
  Switch to manaul mode and select which time to use.
  You are permitted to select both - in which case a average of the
  two watch times is used in 'racetime' .

  }
  {
    RULES USED BY SWIMCLUBMEET METHOD.
    The average is always used - for 2x or 3x watch-times.
    Deviation between 3xwatch-times is always checked and swimclubmeet may
    concluded that all watch-times should be dropped!
  }

  result := null;  // null uses system.variants.
  count := 0;
  for I := 1 to 3 do
    if IsValidWatchTime(Times[I]) then inc(count);

  case count of
  0:
    ;
  1:
    BEGIN
      for I := 1 to 3 do
        if IsValidWatchTime(Times[I]) then
        begin
          result := Times[I]; // NOTE: deviation is ignored.
          break;
        end;
    END;
  2:
    // if deviation is within accepted value.
    if DevOk[1] then
      result := CalcAvgWatchTime;
  3:
    BEGIN
      // DOLPHIN TIMING RULES - use mid watch-time.
      if (fCalcRTMethod = 0) then
      begin
        if IsValidWatchTime(Times[2]) then
          // The middle time is the second element in the sorted array
          result := times[2];
      end
      // SwimClubMeet RULES - assert deviation and find use average.
      else
      begin
        if DevOk[1] and DevOk[2] then
          result := CalcAvgWatchTime
        else if DevOk[1] then
          result := (Times[1]+Times[2])/2.0
        else if DevOk[2] then
          result := (Times[2]+Times[3])/2.0;
      end;
    END
  END;

end;

procedure TWatchTime.AssignDataLaneToWT(flds: TFields);
var
I: integer;
dt: TDateTime;
fld: TField;
begin
  fld := flds.FindField('Time1');
  if Assigned(fld) and (not fld.IsNull) then
  begin
    dt := fld.AsDateTime;
    I := ConverDateTimeToCentiSeconds(dt);
    Times[1] := I;
  end else Times[1] := null;

  fld := flds.FindField('Time2');
  if Assigned(fld) and (not fld.IsNull) then
  begin
    dt := fld.AsDateTime;
    I := ConverDateTimeToCentiSeconds(dt);
    Times[2] := I;
  end else Times[2] := null;

  fld := flds.FindField('Time3');
  if Assigned(fld) and (not fld.IsNull) then
  begin
    dt := fld.AsDateTime;
    I := ConverDateTimeToCentiSeconds(dt);
    Times[3] := I;
  end else Times[3] := null;

  Indices[1] := 1;
  Indices[2] := 2;
  Indices[3] := 3;

  DevOk[1] := false;
  DevOk[2] := false;

end;

procedure TWatchTime.AssignDataWTToLane(flds: TFields);
var
  indx: integer;
  fld: TField;

  function findIndx(luIndx: integer): integer;
  begin
    var j: integer;
    result := 1;
    // locate the correct index
    for j := 1 to 3 do
    begin
      if Indices[j] = luIndx then
      begin
          result := j;
          break;
      end;
    end;
  end;

begin
 if flds.DataSet.State in [dsEdit] then
 begin
    fld := flds.FindField('LaneIsEmpty');
    if Assigned(fld) then  fld.AsBoolean := LaneIsEmpty;

    // Array Times has been sorted .. indices points to the correct
    // array item to assign.
    // ------------------------------------------------------------
    fld := flds.FindField('T1A');
    if Assigned(fld) then
    begin
      indx := findIndx(1);
      fld.AsBoolean := IsValidWatchTime(Times[indx]);
    end;

    fld := flds.FindField('T2A');
    if Assigned(fld) then
    begin
      indx := findIndx(2);
      fld.AsBoolean := IsValidWatchTime(Times[indx]);
    end;

    fld := flds.FindField('T3A');
    if Assigned(fld) then
    begin
      indx := findIndx(3);
      fld.AsBoolean := IsValidWatchTime(Times[indx]);
    end;

    fld := flds.FindField('TDev1');
    if Assigned(fld) then  fld.AsBoolean := DevOk[1];

    fld := flds.FindField('TDev2');
    if Assigned(fld) then  fld.AsBoolean := DevOk[2];

    fld := flds.FindField('RaceTimeA');
    if Assigned(fld) then
    begin
      if VarIsNull(fCalcRT) then
        fld.Clear
      else
        fld.AsDateTime := ConvertCentiSecondsToDateTime(fCalcRT); // the auto-calculated racetime.
    end;

 end;

end;

procedure TWatchTime.CalcAutoWatchTimeEvent(aEventID: integer);
var
found: boolean;
begin
  if appData.tblmEvent.FieldByName('EventID').AsInteger <> aEventID then
    found := appData.LocateTEventID(aEventID)
  else
    found := true;

  if found then
  begin
    appData.tblmHeat.ApplyMaster;
    while not appData.tblmHeat.Eof do
    begin
      if appData.tblmHeat.FieldByName('EventID').AsInteger = aEventID then
        CalcAutoWatchTimeHeat(appData.tblmHeat.FieldByName('HeatID').AsInteger);
      appData.tblmHeat.Next;
    end;
  end;
end;

procedure TWatchTime.CalcAutoWatchTimeHeat(aHeatID: integer);
var
found: boolean;
begin
  if appData.tblmHeat.FieldByName('HeatID').AsInteger <> aHeatID then
    found := appData.LocateTHeatID(aHeatID)
  else
    found := true;

  if found then
  begin
    appData.tblmLane.ApplyMaster;
    while not appData.tblmLane.Eof do
    begin
      if appData.tblmLane.FieldByName('HeatID').AsInteger = aHeatID then
        CalcAutoWatchTimeLane(appData.tblmLane.FieldByName('LaneID').AsInteger);
      appData.tblmLane.Next;
    end;
  end;
end;

procedure TWatchTime.CalcAutoWatchTimeLane(aLaneID: integer);
var
found: boolean;
begin

  if appData.tblmLane.FieldByName('LaneID').AsInteger <> aLaneID then
    found := appData.LocateTLaneID(aLaneID)
  else
    found := true;

  if found then
  begin
    AssignDataLaneToWT(appData.tblmLane.Fields);  // READ from lane.
    LoadFromSettings; // loads the accepted deviation gap for watch times.
    fAccptDevMsec := fAcceptedDeviation * 1000;
    SortWatchTimes;  // bubble sort - fastest watch-time comes first in stack.
    CheckDeviation;  // test if time-keeper's times pass acceptable deviation.
    fCalcRT := CalcRaceTime; // calculate the auto- racetime.
    try
      appData.tblmLane.Edit;
      AssignDataWTToLane(appData.tblmLane.Fields); // WRITE to lane.
      appData.tblmLane.Post;
    except on E: Exception do
        appData.tblmLane.Cancel;
    end;
  end;

end;

procedure TWatchTime.CalcAutoWatchTimeSession(aSessionID: integer);
var
found: boolean;
begin
  if appData.tblmSession.FieldByName('SessionID').AsInteger <> aSessionID then
    found := appData.LocateTSessionID(aSessionID)
  else
    found := true;

  if found then
  begin
    appData.tblmEvent.ApplyMaster;
    while not appData.tblmEvent.Eof do
    begin
      if appData.tblmEvent.FieldByName('SessionID').AsInteger = aSessionID then
        CalcAutoWatchTimeEvent(appData.tblmEvent.FieldByName('EventID').AsInteger);
      appData.tblmEvent.Next;
    end;
  end;
end;

procedure TWatchTime.CheckDeviation;
var
I, j, count: integer;
t1, t2: TTime;
GapA, GapB: double;
begin
  // prior to calling here call SortWatchTimes ... ValidWatchTimes ...
  count := 0;
  // reset accepted deviation state;
  for I := 1 to 3 do
    if IsValidWatchTime(Times[I]) then inc(count);

  DevOk[1] := false;
  DevOk[2] := false;

  case count of
  0, 1: // LANE IS EMPTY or Single watch time.
  begin
    DevOk[1] := true; // there is no deviation gap to calculate.
    DevOk[2] := true;
  end;
  2:
    BEGIN
      j := 0;
      t1:=0;
      DevOk[2] := true;
      // Loop through array to find the 2 valid watch times.
      for I := 1 to 3 do
      begin
        if IsValidWatchTime(Times[I]) then
        begin
          if j = 0 then
          begin
            t1 := TimeOf(Times[I]);
          end
          else if j = 1 then
          begin
            t2 := TimeOf(Times[I]);
            // Calculate deviation between the two valid times
            GapA := MilliSecondsBetween(t1, t2);
            // Check if the deviation is acceptable
            if GapA <= fAccptDevMsec then
              DevOk[1] := true;
            break;
          end;
          Inc(j);
        end;
      end;
    END;

    3:
    BEGIN
      { Dolphin Timing doesn't consider check deviation on 3xwatch-times
        and instead picks the middle watch time.
      }
      if (fCalcRTMethod = 0) then
      Begin
      End;
      if (fCalcRTMethod = 1) then
      Begin
        // Calculate deviation between the two valid times
        GapA := MilliSecondsBetween(Times[2], Times[1]);
        // Calculate deviation between the two valid times
        GapB := MilliSecondsBetween(Times[3],Times[2]);

        // Check if the deviation is acceptable
        if (GapA > fAccptDevMsec) AND (GapB > fAccptDevMsec) then
        begin
          // Both deviations exceed the limit. Ambiguous issue.
          ;
        end
        else
        begin
          if (GapA <= fAccptDevMsec) then
            // If false - likely issue with MinTime index
            DevOk[1] := true;
          if (GapB <= fAccptDevMsec) then
            // If false - likely issue with MaxTime index
            DevOk[2] := true;
        end;
      End;
    END;
  end;
end;



constructor TWatchTime.Create();
begin
  inherited Create;
  Times[1] := null;
  Times[2] := null;
  Times[3] := null;
  Indices[1] := 1;
  Indices[2] := 2;
  Indices[3] := 3;
  DevOk[1] := false;
  DevOk[2] := false;
  fAcceptedDeviation := 0;
  fCalcRT := null;
end;

destructor TWatchTime.Destroy;
begin
  // Clean - up .
  inherited;
end;

function TWatchTime.IsValidWatchTime(ATime: variant): boolean;
begin
  result := false;
  if VarIsEmpty(ATime) then exit;
  if VarIsNull(ATime) then exit;
  if (ATime = 0) then exit;
  result := true;
end;

function TWatchTime.LaneIsEmpty: boolean;
var
I: integer;
begin
  result := true;
  for I := 1 to 3 do
    if IsValidWatchTime(Times[I]) then
    begin
      result := false;
      break;
    end;
end;

procedure TWatchTime.LoadFromSettings;
begin
  if Settings <> nil then
  begin
    fAcceptedDeviation := Settings.AcceptedDeviation;
    fCalcRTMethod := Settings.CalcRTMethod;
  end
  else
  begin
    fAcceptedDeviation := 0.3;
    fCalcRTMethod := 0; // default - Dolphin Timing Method.
  end;
end;

procedure TWatchTime.ProcessHeat(aHeatID: integer);
begin
    // Calculate the Auto-RaceTime for the lane.....

    CalcAutoWatchTimeHeat(aHeatID);

      // much safer method to find.
      // locate the JSON heat placed into tblmHeat
      (*
      appData.tblmSession.ApplyMaster; // Redundant?
      if appData.LocateTSessionID(SessionID) then
      begin
        appData.tblmEvent.ApplyMaster; // Redundant?
        if appData.LocateTEventNum(SessionID, EventNum) then
        begin
          appData.tblmHeat.ApplyMaster; // Redundant?
          if appData.LocateTHeatNum(appData.tblmEvent.FieldByName('EventID').AsInteger, HeatNum) then
          begin
            // Calculate the Auto-RaceTime for the lane.....
            aWatchTime := TWatchTime.Create();
            aWatchTime.CalcAutoWatchTimeHeat(appData.tblmHeat.FieldByName('HeatID').AsInteger);
            aWatchTime.free;
          end;
        end;
      end;
      *)
      (*
      // quick access but dependant on Time-Drops to assign unique PK - RaceNum
      else
      begin
        appData.tblmHeat.ApplyMaster; // Redundant?
        if appData.LocateTRaceNum(RaceNum) then
        begin
          // Calculate the Auto-RaceTime for the lane.....
          aWatchTime := TWatchTime.Create();
          aWatchTime.CalcAutoWatchTimeHeat(appData.tblmHeat.FieldByName('HeatID').AsInteger);
          aWatchTime.free;
        end;
      end;
      *)
end;

procedure TWatchTime.SortWatchTimes;
var
I, J: integer;
TempTime: Variant;
TempIndex: integer;
begin
  // Sort the Times array and keep the Indices array in sync
  for i := 1 to 2 do
  begin
    for j := i + 1 to 3 do
    begin
      if Times[i] > Times[j] then
      begin
        // Swap Times
        TempTime := Times[i];
        Times[i] := Times[j];
        Times[j] := TempTime;
        // Swap corresponding Indices
        TempIndex := Indices[i];
        Indices[i] := Indices[j];
        Indices[j] := TempIndex;
      end;
    end;
  end;
end;


end.
