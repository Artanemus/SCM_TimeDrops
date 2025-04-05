unit tdResults;

interface

uses XSuperJSON, XSuperObject, dmAppData, System.Types, System.StrUtils;

  // Main Process entry points

  procedure ProcessDirectory(const ADirectory: string);
  procedure ProcessFile(const AFileName: string);
  procedure ProcessSession(AList: TStringDynArray; ASessionID: integer);


implementation
uses
  SysUtils, Classes, System.JSON, System.IOUtils, Windows,
  Vcl.Dialogs, DateUtils;

function StripNonNumeric(const AStr: string): string;
var
  Ch: Char;

begin
  Result := '';
  for Ch in AStr do
  begin
    if CharInSet(Ch, ['0'..'9']) then
      Result := Result + Ch;
  end;
end;


function Convert100thSecondsToDateTime(AHundredths: Integer): TDateTime;
var
  ms: Integer;
begin
  // Convert hundredths of a second to milliseconds
  ms := AHundredths * 10;

  // Create a TDateTime from the milliseconds since midnight
  Result := IncMilliSecond(0, ms);
end;


(*
        {
          "createdAt": "2023-07-31T17:53:00.042-07:00",
          "protocolVersion": "1.1.0",
          "sessionNumber": 123, // from program
          "sessionId": "67251", // from program
          "eventNumber": "1",
          "heatNumber": 2,
          "raceNumber": 2,
          "startTime": "2023-07-31T17:52:11.234-07:00",
          "lanes": [
            {
              "lane": 1,
              “finalTime”: 4883, // combination of the pad and button times. Meet Management program
              may prefer to calculate this time themselves
              "padTime": 4883, // only present when using pads
              "timer1": 4942, // in 1/100th of seconds
              "timer2": 4925,
              "timer3": 4904,
              "isEmpty": false, // lane declared empty by timing operator, may still have times in case of
              operator error
              "isDq": false, // for relay judging platform
              "splits": [
                {
                "distance": 25,
                "time": 1686
                }
              ]
              },
              …… more lanes to follow
            ]
          }
        }
*)




procedure ReadJsonFile(const FileName: string; SessionID, EventNum, HeatNum, RaceNum: integer);
var
  JSONObj, laneObject, splitObject: ISuperObject;
  lanesObj, splitsObj: ISuperArray;
  finalTimeValue: ISuperExpression;
  FileStream: TFileStream;
  laneValue, splitValue: ICast;
  aSessionID, aEventID, aEventNum, aHeatID, aHeatNum, laneNum: integer;
  fs: TFormatSettings;
  str, fldname: string;
  iter: integer;
  fCreationDT: TDateTime;
begin


  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    JSONObj := TSuperObject.ParseStream(FileStream, True);
    if Assigned(JSONObj) and (JSONObj.DataType = dtObject) then
    begin
      // Process the JSON object
      Writeln(JSONObj.AsJSon);
      if JSONObj.Contains('sessionId') then
      begin
        if not AppData.LocateTSessionID(JSONobj.I['sessionId']) then
        begin
          // add the newly discovered session
          AppData.tblmSession.Insert;
          // May help to track an approx session time.
          fCreationDT := Now;
          // wit: the start of recording of race data from TimeDrops.
          AppData.tblmSession.FieldByName('createdOn').AsDateTime := fCreationDT;
          // Primary Key
          AppData.tblmSession.FieldByName('sessionId').AsInteger := JSONobj.I['sessionId'];
          // Session Number.
          AppData.tblmSession.FieldByName('sessionNum').AsInteger := JSONobj.I['sessionNumber'];
          // Create a basic session caption.
          fs := TFormatSettings.Create;
          fs.DateSeparator := '_';
          fs.ShortDateFormat := 'yyyy-mm-dd';
          str := 'Session: ' + IntToStr(JSONobj.I['sessionId']) + ' Date: ' + DatetoStr(fCreationDT, fs);
          AppData.tblmSession.fieldbyName('Caption').AsString := str;
          AppData.tblmSession.Post;
        end;
      end;

      AppData.tblmEvent.ApplyMaster;
      if JSONObj.Contains('eventNumber') then
      begin
        if not AppData.LocateTEventNum(SessionID, JSONobj.I['eventNumber']) then
        begin
          AppData.tblmEvent.Insert;
          AppData.tblmEvent.FieldByName('EventNum').AsInteger := JSONobj.I['eventNumber'];
          // Calculate the Primary Key : IDENTIFIER.
          // ID isn't AutoInc. the primary key is calculated manually.
          AppData.tblmEvent.fieldbyName('EventID').AsInteger := AppData.MaxID_Event + 1;
          // master - detail. Also Index Field.
          AppData.tblmEvent.fieldbyName('SessionID').AsInteger := JSONobj.I['sessionId'];
          // CAPTION for Event :
          str := 'Event: ' +  IntToStr(JSONobj.I['eventNumber']);
          AppData.tblmEvent.fieldbyName('Caption').AsString := str;
          AppData.tblmEvent.Post;
        end;
      end;

      aEventID := AppData.tblmEvent.FieldByName('EventID').AsInteger;

      AppData.tblmHeat.ApplyMaster;
      if JSONObj.Contains('heatNumber') then
      begin
        if not AppData.LocateTHeatNum(aEventID, aHeatNum) then
        begin
          AppData.tblmHeat.Insert;
          AppData.tblmHeat.FieldByName('HeatNum').AsInteger := JSONobj.I['heatNumber'];
          // calculate the IDENTIFIER.
          // ID isn't AutoInc - calc manually.
          AppData.tblmHeat.fieldbyName('HeatID').AsInteger := AppData.MaxID_Heat() + 1;
          // master - detail.
          AppData.tblmHeat.fieldbyName('EventID').AsInteger := aEventID;
          // TIME STAMP.
          AppData.tblmHeat.fieldbyName('startTime').AsDateTime := ISO8601ToDate(JSONobj.S['startTime']);
          AppData.tblmHeat.fieldbyName('Caption').AsString := 'Heat: ' + IntToStr(JSONobj.I['heatNumber']);
          // A unique sequential number for each heat.
          AppData.tblmHeat.fieldbyName('RaceNum').AsInteger:= JSONobj.I['raceNumber'];;
          // Get the creation time of the specified file
          fCreationDT := TFile.GetCreationTime(FileName);
          // TimeStamp of TimeDrops Results file.
          AppData.tblmSession.fieldbyName('CreatedOn').AsDateTime := ISO8601ToDate(JSONobj.s['createdAt']);
          AppData.tblmHeat.Post;
          end;
      end;

      aHeatID := AppData.tblmHeat.FieldByName('HeatID').AsInteger;

      if JSONObj.Contains('Lanes') then
      begin
        lanesObj := JSONObj.A['Lanes']; // Get the array
        if Assigned(lanesObj) then // Check if it's actually an array
        begin
          // Assuming ApplyMaster sets the HeatID filter/parameter correctly
          AppData.tblmLane.ApplyMaster;

          for laneValue in lanesObj do // Iterate through array elements
          begin
            if (laneValue.DataType = dtObject) then // Ensure the array element is an object
            begin
              laneObject := laneValue.AsObject; // Get the lane object

              // --- Extract data from laneObject ---
              laneNum := laneObject.I['lane']; // Assuming 'lane' field exists and is integer

              // --- Locate or Insert/Edit Lane Record ---
              // You need a function like LocateDTLaneNum(HeatID, LaneNum): Boolean;
              if AppData.LocateTLaneNum(laneNum) then // Or however you locate lanes
              begin
                AppData.tblmLane.Edit;
              end
              else
              begin
                AppData.tblmLane.Insert;
                // primary key
                AppData.tblmLane.fieldbyName('LaneID').AsInteger := AppData.MaxID_Lane + 1;
                // master.detail.
                AppData.tblmLane.FieldByName('HeatID').AsInteger := aHeatID;
                AppData.tblmLane.FieldByName('LaneNum').AsInteger := laneObject.I['lane'];
                AppData.tblmLane.fieldbyName('Caption').AsString := 'Lane: ' + IntToStr(laneNum);
                AppData.tblmLane.fieldbyName('LaneIsEmpty').AsBoolean := false;


                AppData.tblmLane.FieldByName('finalTime').AsDateTime := Convert100thSecondsToDateTime(laneObject.I['finalTime']);
                AppData.tblmLane.FieldByName('padTime').AsDateTime := Convert100thSecondsToDateTime(laneObject.I['padTime']);
                AppData.tblmLane.FieldByName('time1').AsDateTime := Convert100thSecondsToDateTime(laneObject.I['timer1']);
                AppData.tblmLane.FieldByName('time2').AsDateTime := Convert100thSecondsToDateTime(laneObject.I['timer2']);
                AppData.tblmLane.FieldByName('time3').AsDateTime := Convert100thSecondsToDateTime(laneObject.I['timer3']);
                AppData.tblmLane.fieldbyName('LaneIsEmpty').AsBoolean := laneObject.B['isEmpty'];
                AppData.tblmLane.fieldbyName('isDq').AsBoolean := laneObject.B['isDq'];


                // Swimmers calculated racetime for post.
                AppData.tblmLane.fieldbyName('RaceTime').Clear;
                // A user entered race-time.
                AppData.tblmLane.fieldbyName('RaceTimeUser').Clear;
                // The Automatic race-time. Calculated on load of DT file.
                AppData.tblmLane.fieldbyName('RaceTimeA').Clear;
                // dtActiveRT = (artAutomatic, artManual, artUser, artSplit, artNone);
                AppData.tblmLane.fieldbyName('ActiveRT').AsInteger := ORD(artAutoMatic);
                // graphic used in column[6] - GRID IMAGES AppData.vimglistDTCell .
                // image index 1 indicts - dtTimeKeeperMode = dtAutomatic.
                AppData.tblmLane.fieldbyName('imgActiveRT').AsInteger := -1;
                // graphic used in column[1] - for noodle drawing...
                AppData.tblmLane.fieldbyName('imgPatch').AsInteger := 0;

              end;
              AppData.tblmLane.Post; // Post the inserted or edited record.

              if LaneObject.Contains('Splits') then
              begin
                splitsObj := JSONObj.A['splits']; // Get the array
                if Assigned(splitsObj) then // Check if it's actually an array
                begin
                  iter := 1;
                  for splitValue in splitsObj do // Iterate through array elements
                  begin
                    if (splitValue.DataType = dtObject) then // Ensure the array element is an object
                    begin
                      splitObject := splitValue.AsObject; // Get the split-time object
                      fldname := 'split' + intToStr(iter); // generate the field name
                      AppData.tblmLane.FieldByName(fldName).AsDateTime := Convert100thSecondsToDateTime(splitObject.I['split']);
                      Inc(iter); // next field Name
                    end;
                  end;
                end;
              end;


            end;
          end;
        end;
      end;
    end;

  finally
    FileStream.Free;
  end;
end;



procedure ProcessDirectory(const ADirectory: string);
var
  LList: TStringDynArray;
  SessionIds: TIntegerDynArray;
  Fields: TArray<string>;
  LSearchOption: TSearchOption;
  I, SessionID: Integer;
  wildCard: string;

  function IsInList(const AList: TIntegerDynArray; const AValue: Integer): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    for J := 0 to Length(AList) - 1 do
    begin
      if AList[J] = AValue then
        Exit(True);
    end;
  end;

begin
  // Do not do recursive extract into subfolders
  LSearchOption := TSearchOption.soTopDirectoryOnly;

  // Clear all datasets of records
  AppData.tblmSession.EmptyDataSet;
  AppData.tblmEvent.EmptyDataSet;
  AppData.tblmHeat.EmptyDataSet;
  AppData.tblmLane.EmptyDataSet;
  AppData.tblmNoodle.EmptyDataSet;

  // De-attach from Master-Detail. Create flat files. Necessary to calculate table Primary keys.
  AppData.DisableTDMasterDetail;

  try
    // For files use GetFiles method
    LList := TDirectory.GetFiles(ADirectory, 'Session*.JSON', LSearchOption);
  except
    // Catch the possible exceptions
    MessageBox(0, PChar('Incorrect path or search mask'),
      PChar('Extract Time Drops Result Files'), MB_ICONERROR or MB_OK);
    Exit;
  end;

  // Initialize SessionIds
  SetLength(SessionIds, 0);

  // Extract distinct session numbers
  for I := 0 to Length(LList) - 1 do
  begin
    // Filename syntax used by Time Drops: SessionSSSS_Event_EEEE_HeatHHHH_RaceRRRR_XXX.json
    Fields := SplitString(LList[I], '_');
    if Length(Fields) > 1 then
    begin
      // Strip non-numeric characters from Fields[1]
      Fields[1] := StripNonNumeric(Fields[1]);
      SessionID := StrToIntDef(Fields[1], 0);
      if (SessionID <> 0) and (not IsInList(SessionIds, SessionID)) then
      begin
        // Add SessionID to SessionIds array
        SetLength(SessionIds, Length(SessionIds) + 1);
        SessionIds[High(SessionIds)] := SessionID;
      end;
    end;
  end;

  // Process each distinct session
  for I := 0 to Length(SessionIds) - 1 do
  begin
    // Initialize SessionIds
    SetLength(LList, 0);
    try
      // filter specific session files.
      wildCard := 'Session' + IntToStr(SessionIds[I]) + '*.JSON';
      // For files use GetFiles method.
      LList := TDirectory.GetFiles(ADirectory, wildCard, LSearchOption);
    except
      // Catch the possible exceptions
      MessageBox(0, PChar('Incorrect path or search mask'),
        PChar('Extract Time Drops Result Files'), MB_ICONERROR or MB_OK);
      Exit;
    end;
    if Length(LList) <> 0 then
      // Calls - ProcessEvent, ProcessHeat, ProcessEntrant
      ProcessSession(LList, SessionIds[I]);
  end;

  // Re-attach Master-Detail
  AppData.EnableTDMasterDetail;
end;

procedure ProcessFile(const AFileName: string);
var
  SessionID, SessionNum, EventNum, HeatNum, RaceNum: integer;
  Fields: TArray<string>;
begin
  if FileExists(AFileName) then
  begin
    // =====================================================
    // De-attach from Master-Detail. Create flat files.
    // Necessary to calculate table Primary keys.
    AppData.DisableTDMasterDetail;
    // =====================================================

    Fields := SplitString(AFileName, '_');
    if Length(Fields) > 1 then
    begin
      // Strip non-numeric characters from Fields[1]
      Fields[1] := StripNonNumeric(Fields[1]);
      SessionID := StrToIntDef(Fields[1], 0);
      if (SessionID <> 0) then
      begin
        // init
        SessionNum := 0;
        EventNum := 0;
        HeatNum := 0;
        RaceNum := 0;
        // Filename syntax used by Time Drops: SessionSSSS_Event_EEEE_HeatHHHH_RaceRRRR_XXX.json
        if Length(Fields) > 2 then
          EventNum := StrToIntDef(StripNonNumeric(Fields[1]), 0);
        if Length(Fields) > 3 then
          HeatNum := StrToIntDef(StripNonNumeric(Fields[2]), 0);
        if Length(Fields) > 4 then
          RaceNum := StrToIntDef(StripNonNumeric(Fields[3]), 0);
        ReadJsonFile(AFileName, SessionID, EventNum, HeatNum, RaceNum);
      end;
    end;

    // =====================================================
    // Re-attach Master-Detail.
    AppData.EnableTDMasterDetail;
    // =====================================================
  end;
end;

procedure ProcessSession(AList: TStringDynArray; ASessionID: integer);
var
  i, EventNum, HeatNum, RaceNum: integer;
//  s: string;
  Fields: TArray<string>;
begin
  // iterate over the filenames.
  for I := 0 to Length(AList) - 1 do
  begin
    // test filename matches sessionID
    Fields := SplitString(AList[I], '_');
    if Length(Fields) > 1 then
    begin
      if Fields[0].Contains(IntToStr(ASessionID)) then
      begin
        // init
        EventNum := 0;
        HeatNum := 0;
        RaceNum := 0;
        // Filename syntax used by Time Drops: SessionSSSS_Event_EEEE_HeatHHHH_RaceRRRR_XXX.json
        if Length(Fields) > 2 then
          EventNum := StrToIntDef(StripNonNumeric(Fields[1]), 0);
        if Length(Fields) > 3 then
          HeatNum := StrToIntDef(StripNonNumeric(Fields[2]), 0);
        if Length(Fields) > 4 then
          RaceNum := StrToIntDef(StripNonNumeric(Fields[3]), 0);
        ReadJsonFile(AList[I], ASessionID, EventNum, HeatNum, RaceNum);
      end;
    end;
  end;
end;


(*
// Outline to using Embarcadero's Delphi JSON tools
// Instead of the x-SuperObject opensource tool.
procedure ReadJsonFileDelphi(const FileName: string);
var
  JSONString: string;
  JSONValue: TJSONValue;
  JSONObj: TJSONObject;
//  JSONReader: TStringReader;
  JSONStream: TFileStream;
begin
  JSONStream := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(JSONString, JSONStream.Size);
    JSONStream.ReadBuffer(Pointer(JSONString)^, JSONStream.Size);

    JSONValue := TJSONObject.ParseJSONValue(JSONString);
    try
      if JSONValue is TJSONObject then
      begin
        JSONObj := JSONValue as TJSONObject;
        // Process the JSON object
        Writeln(JSONObj.ToString);
      end;
    finally
      JSONValue.Free;
    end;
  finally
    JSONStream.Free;
  end;
end;
*)

(*

  // Process lanes...
  for I := 1 to (fSList.Count - 2) do
  begin
    lane := sListBodyLane(I);
    id := id + 1;

    AppData.tblmLane.Append;

    // gather up the timekeepers 1-3 recorded race times for this lane.
    sListBodyTimeKeepers(I, fTimeKeepers);

    for k := 0 to 2 do
    begin
      if (fTimeKeepers[k] = 0) then
      begin
        // The user's manual watch-time is disabled.
        s := Format('T%dM', [k + 1]);
        AppData.tblmLane.fieldbyName(s).AsBoolean := false;
        // Initialize - The Automatic watch-time is invalid.
        s := Format('T%dA', [k + 1]);
        AppData.tblmLane.fieldbyName(s).AsBoolean := false;
        AppData.tblmLane.fieldbyName(s).Clear;
      end
      else
      begin
        // The user's manual watch-time is enabled.
        s := Format('T%dM', [k + 1]);
        AppData.tblmLane.fieldbyName(s).AsBoolean := true;
        // Initialize - The Automatic watch-time is valid.
        // (vertified later in procedure)
        s := Format('T%dA', [k + 1]);
        AppData.tblmLane.fieldbyName(s).AsBoolean := true;
        // Place watch-time in manual time field.
        s := Format('Time%d', [k + 1]);
        AppData.tblmLane.fieldbyName(s).AsDateTime := TimeOf(fTimeKeepers[k]);
      end;
    end;

    // D e v i a t i o n  --- initialization
    // The watch-times, min-mid and mid-max, are within accepted deviation.
    // (verified later in procedure)
    AppData.tblmLane.fieldbyName('TDev1').AsBoolean := true;
    AppData.tblmLane.fieldbyName('TDev2').AsBoolean := true;

    // gather up the timekeepers 1-3 recorded race times for this lane.
    sListBodySplits(I, fSplits);
    for j := low(fSplits)  to High(fSplits) do
    begin
      if (fSplits[j] > 0) then
      begin
        s := 'Split' + IntTostr((j+1));
        AppData.tblmLane.FieldByName(s).AsDateTime := TDateTime(fSplits[j]);
      end;
    end;
    AppData.tblmLane.Post;

    // Main form assigns value. ASSERT - avoid division by zero.
    if fAcceptedDeviation = 0 then
      fAcceptedDeviation := 0.3; // Dolphin Timing's default.

    // Cacluate RaceTimeA for the ActiveRT. (artAutomatic)
    // AND verify deviaiton AND assert fields [T1A, T2A, T3A]
    AppData.CalcRaceTimeA(AppData.tblmLane, fAcceptedDeviation, fCalcMode);

    // FINALLY place values into manual and automatic watch time fields.
    AppData.tblmLane.Edit;
    AppData.tblmLane.fieldbyName('RaceTime').AsVariant :=
      AppData.tblmLane.fieldbyName('RaceTimeA').AsVariant;
    AppData.tblmLane.post;

  end;
  AppData.tblmLane.EnableControls;

*)


end.
