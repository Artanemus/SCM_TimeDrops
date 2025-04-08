unit tdResults;

interface

uses XSuperJSON, XSuperObject, dmAppData, System.Types, System.StrUtils,
  uAppUtils;

  // Main Process entry points

  procedure ProcessDirectory(const ADirectory: string);
  procedure ProcessFile(const AFileName: string);
  procedure ProcessSession(AList: TStringDynArray; ASessionID: integer);


implementation
uses
  SysUtils, Classes, System.JSON, System.IOUtils, Windows,
  Vcl.Dialogs, DateUtils, uWatchTime;

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


procedure ReadJsonSplits(laneObject: ISuperObject; PK_LaneID: integer);
var
  splitObject: ISuperObject;
  splitsObj: ISuperArray;
  splitValue: ICast;
  indxLane: integer;
  fldname: string;
begin
    if LaneObject.Contains('Splits') then
    begin
      splitsObj := LaneObject.A['splits']; // Get the array
      if Assigned(splitsObj) then
      begin
        indxLane := 1;
        {TODO -oBSA -cGeneral : Remove all split-times from tblmLane}
        for splitValue in splitsObj do // Iterate through array elements
        begin
          if (splitValue.DataType = dtObject) then // Ensure the array element is an object
          begin
            splitObject := splitValue.AsObject; // Get the split-time object
            AppData.tblmLane.Edit;
            fldname := 'split' + intToStr(indxLane); // generate the field name
            AppData.tblmLane.FieldByName(fldName).AsDateTime := ConvertCentiSecondsToDateTime(splitObject.I['split']);
            fldname := 'splitDist' + intToStr(indxLane); // generate the field name
            AppData.tblmLane.FieldByName(fldName).AsInteger := splitObject.I['distance'];
            AppData.tblmLane.Post;
            Inc(indxLane); // next field Name
            if (indxLane > 10) then break;
          end;
        end;
      end; // END SPLIT.
    end; // END SPLITS.
end;


procedure ReadJsonLanes(JSONObj: ISuperObject; PK_HeatID: integer);
var
  laneObject: ISuperObject;
  lanesObj: ISuperArray;
  laneValue: ICast;
  PK_LaneID: integer;
  aWatchTime: TWatchTime;
begin
  lanesObj := JSONObj.A['Lanes']; // Get the array
  if Assigned(lanesObj) then // Check if it's actually an array
  begin
    // SYNC ... AppData.tblmLane.Refresh;
    for laneValue in lanesObj do // Iterate through array elements
    begin
      if (laneValue.DataType = dtObject) then // Ensure the array element is an object
      begin
        laneObject := laneValue.AsObject; // Get the lane object
        // Find lane number within heat.
        if AppData.LocateTLaneNum(PK_HeatID, laneObject.I['lane']) then
        begin
          PK_LaneID := AppData.tblmLane.FieldByName('LaneID').AsInteger;
          AppData.tblmLane.Edit
        end
        else
        begin
          // Calculate a new unique primary key.
          PK_LaneID := AppData.MaxID_Lane + 1;
          AppData.tblmLane.Insert;
          AppData.tblmLane.fieldbyName('LaneID').AsInteger := PK_LaneID;
          AppData.tblmLane.FieldByName('HeatID').AsInteger := PK_HeatID; // master.detail.
          AppData.tblmLane.FieldByName('LaneNum').AsInteger := laneObject.I['lane'];
        end;

        AppData.tblmLane.fieldbyName('Caption').AsString := 'Lane: ' + IntToStr(laneObject.I['lane']);

        // ASSERT the state of all JSON 'times'.
        if laneObject.Contains('finalTime') then
          begin
            if (laneObject.Null['finalTime'] in [jUnAssigned, jNull]) then
              AppData.tblmLane.FieldByName('finalTime').Clear
            else
              AppData.tblmLane.FieldByName('finalTime').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['finalTime']);
          end
        else  AppData.tblmLane.FieldByName('finalTime').Clear;

        if laneObject.Contains('padTime') then
          begin
            if (laneObject.Null['padTime'] in [jUnAssigned, jNull]) then
              AppData.tblmLane.FieldByName('padTime').Clear
            else
              AppData.tblmLane.FieldByName('padTime').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['padTime']);
          end
        else  AppData.tblmLane.FieldByName('padTime').Clear;

        if laneObject.Contains('timer1') then
          begin
            if (laneObject.Null['timer1'] in [jUnAssigned, jNull]) then
              AppData.tblmLane.FieldByName('time1').Clear
            else
              AppData.tblmLane.FieldByName('time1').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['timer1']);
          end
        else  AppData.tblmLane.FieldByName('time1').Clear;

        if laneObject.Contains('timer2') then
          begin
            if (laneObject.Null['timer2'] in [jUnAssigned, jNull]) then
              AppData.tblmLane.FieldByName('time2').Clear
            else
              AppData.tblmLane.FieldByName('time2').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['timer2']);
          end
        else  AppData.tblmLane.FieldByName('time2').Clear;

        if laneObject.Contains('timer3') then
          begin
            if (laneObject.Null['timer3'] in [jUnAssigned, jNull]) then
              AppData.tblmLane.FieldByName('time3').Clear
            else
              AppData.tblmLane.FieldByName('time3').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['timer3']);
          end
        else  AppData.tblmLane.FieldByName('time3').Clear;

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

        // Init misc fields
        AppData.tblmLane.fieldbyName('TDev1').AsBoolean := true;
        AppData.tblmLane.fieldbyName('TDev2').AsBoolean := true;

        AppData.tblmLane.Post; // Post the inserted or edited record.

        ReadJsonSplits(laneObject, PK_LaneID);

        // Calculate the Auto-RaceTime for the lane.....
        aWatchTime := TWatchTime.Create(AppData.tblmLane.fieldbyName('Time1').AsVariant,
          AppData.tblmLane.fieldbyName('Time2').AsVariant,
          AppData.tblmLane.fieldbyName('Time3').AsVariant);
        aWatchTime.ExecCalcRaceTime;
        aWatchTime.SyncData(AppData.tblmLane);
        aWatchTime.free;

      end;
    end;
  end;
end;

procedure ReadJsonFile(const FileName: string; SessionID, EventNum, HeatNum, RaceNum: integer);
var
  JSONObj: ISuperObject;
  FileStream: TFileStream;
  PK_SessionID, PK_EventID, PK_HeatID, PK: integer;
  fs: TFormatSettings;
  str: string;
  fCreationDT: TDateTime;
begin
  PK_SessionID := 0;
  
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    JSONObj := TSuperObject.ParseStream(FileStream, True);
    if Assigned(JSONObj) and (JSONObj.DataType = dtObject) then
    begin
      if JSONObj.Contains('sessionId') then
      begin
        // Primary Key - NOTE: matches to SCM SessionID.
        PK_SessionID := JSONobj.I['sessionId'];
        // ignore if found...
        if not AppData.LocateTSessionID(PK_SessionID) then
        begin
          // add the newly discovered session
          AppData.tblmSession.Insert;
          // May help to track an approx session time.
          fCreationDT := Now;
          // wit: the start of recording of race data from TimeDrops.
          AppData.tblmSession.FieldByName('createdOn').AsDateTime := fCreationDT;
          // Primary Key.
          AppData.tblmSession.FieldByName('sessionId').AsInteger := PK_SessionID;
          // Session Number.
          AppData.tblmSession.FieldByName('sessionNum').AsInteger := JSONobj.I['sessionNumber'];
          // Create a basic session caption.
          fs := TFormatSettings.Create;
          fs.DateSeparator := '_';
          fs.ShortDateFormat := 'yyyy-mm-dd';
          str := 'Session: ' + IntToStr(PK_SessionID) + ' Date: ' + DatetoStr(fCreationDT, fs);
          AppData.tblmSession.fieldbyName('Caption').AsString := str;
          AppData.tblmSession.Post;
        end;
      end;
      // SYNC ? ... AppData.tblmEvent.Refresh;
      if JSONObj.Contains('eventNumber') then
      begin
        // Calc a primary key.
        PK := AppData.MaxID_Event + 1;
        // ignore if found...
        if not AppData.LocateTEventNum(PK_SessionID, JSONobj.I['eventNumber']) then
        begin
          // create new event
          AppData.tblmEvent.Insert;
          AppData.tblmEvent.FieldByName('EventNum').AsInteger := JSONobj.I['eventNumber'];
          // Calculate the Primary Key : IDENTIFIER.
          // ID isn't AutoInc. the primary key is calculated manually.
          AppData.tblmEvent.fieldbyName('EventID').AsInteger := PK;
          // master - detail. Also Index Field.
          AppData.tblmEvent.fieldbyName('SessionID').AsInteger := PK_SessionID;
          // CAPTION for Event :
          str := 'Event: ' +  IntToStr(JSONobj.I['eventNumber']);
          AppData.tblmEvent.fieldbyName('Caption').AsString := str;
          AppData.tblmEvent.Post;
        end;
      end;

      PK_EventID := AppData.tblmEvent.FieldByName('EventID').AsInteger;
      // SYNC ? ... AppData.tblmHeat.Refresh;
      if JSONObj.Contains('heatNumber') then
      begin
        PK := AppData.MaxID_Heat() + 1;
        // ignore if found...
        if not AppData.LocateTHeatNum(PK_EventID, JSONobj.I['heatNumber']) then
        begin
          AppData.tblmHeat.Insert;
          AppData.tblmHeat.FieldByName('HeatNum').AsInteger := JSONobj.I['heatNumber'];
          // calculate the IDENTIFIER.
          // ID isn't AutoInc - calc manually.
          AppData.tblmHeat.fieldbyName('HeatID').AsInteger := PK;
          // master - detail.
          AppData.tblmHeat.fieldbyName('EventID').AsInteger := PK_EventID;
          // TIME STAMP.
          AppData.tblmHeat.fieldbyName('startTime').AsDateTime := ISO8601ToDate(JSONobj.S['startTime']);
          AppData.tblmHeat.fieldbyName('Caption').AsString := 'Heat: ' + IntToStr(JSONobj.I['heatNumber']);
          // A unique sequential number for each heat.
          AppData.tblmHeat.fieldbyName('RaceNum').AsInteger:= JSONobj.I['raceNumber'];;
          // TimeStamp of TimeDrops Results file.
          AppData.tblmHeat.fieldbyName('CreatedOn').AsDateTime := ISO8601ToDate(JSONobj.s['createdAt']);
          AppData.tblmHeat.Post;
          end;
      end;
      PK_HeatID := AppData.tblmHeat.FieldByName('HeatID').AsInteger;
      ReadJsonLanes(JSONObj, PK_HeatID);
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

end;

procedure ProcessFile(const AFileName: string);
var
  SessionID, EventNum, HeatNum, RaceNum: integer;
  Fields: TArray<string>;
begin
  if FileExists(AFileName) then
  begin
    // =====================================================
    // De-attach from Master-Detail. Create flat files.
    // Necessary to calculate table Primary keys.
    AppData.DisableTDMasterDetail;
    // =====================================================
    try
      begin
        Fields := SplitString(AFileName, '_');
        if Length(Fields) > 1 then
        begin
          // Strip non-numeric characters from Fields[1]
          Fields[1] := StripNonNumeric(Fields[1]);
          SessionID := StrToIntDef(Fields[1], 0);
          if (SessionID <> 0) then
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
            ReadJsonFile(AFileName, SessionID, EventNum, HeatNum, RaceNum);
          end;
        end;      
      end;
    finally
    
      // =====================================================
      // Re-attach Master-Detail.
      AppData.EnableTDMasterDetail;
      // =====================================================
    end;
  end;
end;

procedure ProcessSession(AList: TStringDynArray; ASessionID: integer);
var
  Fields: TArray<string>;
  I: integer;
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
        ProcessFile(AList[I]);
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
