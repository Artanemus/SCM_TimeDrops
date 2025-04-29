unit tdResults;

interface

uses XSuperJSON, XSuperObject, dmTDS, System.Types, System.StrUtils,
  uAppUtils, SCMDefines;

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
            TDS.tblmLane.Edit;
            fldname := 'split' + intToStr(indxLane); // generate the field name
            TDS.tblmLane.FieldByName(fldName).AsDateTime := ConvertCentiSecondsToDateTime(splitObject.I['split']);
            fldname := 'splitDist' + intToStr(indxLane); // generate the field name
            TDS.tblmLane.FieldByName(fldName).AsInteger := splitObject.I['distance'];
            TDS.tblmLane.Post;
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
  found: boolean;
begin
  lanesObj := JSONObj.A['Lanes']; // Get the array
  if Assigned(lanesObj) then // Check if it's actually an array
  begin
    // SYNC ... TDS.tblmLane.Refresh;
    PK_LaneID := 0;
    for laneValue in lanesObj do // Iterate through array elements
    begin
      if (laneValue.DataType = dtObject) then // Ensure the array element is an object
      begin
        laneObject := laneValue.AsObject; // Get the lane object

        TDS.tblmLane.ApplyMaster; // Redundant?
        // Find lane number within heat.
        found := TDS.LocateTLaneNum(PK_HeatID, laneObject.I['lane']);
        try
          begin
            if found then
            begin
              PK_LaneID := TDS.tblmLane.FieldByName('LaneID').AsInteger;
              TDS.tblmLane.Edit
            end
            else
            begin
              // Calculate a new unique primary key.
              PK_LaneID := TDS.MaxID_Lane + 1;
              TDS.tblmLane.Insert;
              TDS.tblmLane.fieldbyName('LaneID').AsInteger := PK_LaneID;
              TDS.tblmLane.FieldByName('HeatID').AsInteger := PK_HeatID; // master.detail.
              TDS.tblmLane.FieldByName('LaneNum').AsInteger := laneObject.I['lane'];
            end;

            TDS.tblmLane.fieldbyName('Caption').AsString := 'Lane: ' + IntToStr(laneObject.I['lane']);

            // ASSERT the state of all JSON 'times'.
            if laneObject.Contains('finalTime') then
              begin
                if (laneObject.Null['finalTime'] in [jUnAssigned, jNull]) then
                  TDS.tblmLane.FieldByName('finalTime').Clear
                else
                  TDS.tblmLane.FieldByName('finalTime').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['finalTime']);
              end
            else  TDS.tblmLane.FieldByName('finalTime').Clear;

            if laneObject.Contains('padTime') then
              begin
                if (laneObject.Null['padTime'] in [jUnAssigned, jNull]) then
                  TDS.tblmLane.FieldByName('padTime').Clear
                else
                  TDS.tblmLane.FieldByName('padTime').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['padTime']);
              end
            else  TDS.tblmLane.FieldByName('padTime').Clear;

            if laneObject.Contains('timer1') then
              begin
                if (laneObject.Null['timer1'] in [jUnAssigned, jNull]) then
                  TDS.tblmLane.FieldByName('time1').Clear
                else
                  TDS.tblmLane.FieldByName('time1').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['timer1']);
              end
            else  TDS.tblmLane.FieldByName('time1').Clear;

            if laneObject.Contains('timer2') then
              begin
                if (laneObject.Null['timer2'] in [jUnAssigned, jNull]) then
                  TDS.tblmLane.FieldByName('time2').Clear
                else
                  TDS.tblmLane.FieldByName('time2').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['timer2']);
              end
            else  TDS.tblmLane.FieldByName('time2').Clear;

            if laneObject.Contains('timer3') then
              begin
                if (laneObject.Null['timer3'] in [jUnAssigned, jNull]) then
                  TDS.tblmLane.FieldByName('time3').Clear
                else
                  TDS.tblmLane.FieldByName('time3').AsDateTime := ConvertCentiSecondsToDateTime(laneObject.I['timer3']);
              end
            else  TDS.tblmLane.FieldByName('time3').Clear;

            TDS.tblmLane.fieldbyName('LaneIsEmpty').AsBoolean := laneObject.B['isEmpty'];
            TDS.tblmLane.fieldbyName('isDq').AsBoolean := laneObject.B['isDq'];

            // Swimmers calculated racetime for post.
            TDS.tblmLane.fieldbyName('RaceTime').Clear;
            // A user entered race-time.
            TDS.tblmLane.fieldbyName('RaceTimeUser').Clear;
            // The Automatic race-time. Calculated on load of DT file.
            TDS.tblmLane.fieldbyName('RaceTimeA').Clear;
            // dtActiveRT = (artAutomatic, artManual, artUser, artSplit, artNone);
            TDS.tblmLane.fieldbyName('ActiveRT').AsInteger := ORD(artAutoMatic);
            // graphic used in column[6] - GRID IMAGES TDS.vimglistDTCell .
            // image index 1 indicts - dtTimeKeeperMode = dtAutomatic.
            TDS.tblmLane.fieldbyName('imgActiveRT').AsInteger := -1;
            // graphic used in column[1] - for noodle drawing...
            TDS.tblmLane.fieldbyName('imgPatch').AsInteger := 0;

            // Init misc fields
            TDS.tblmLane.fieldbyName('TDev1').AsBoolean := true;
            TDS.tblmLane.fieldbyName('TDev2').AsBoolean := true;
            TDS.tblmLane.fieldbyName('T1M').AsBoolean := true;
            TDS.tblmLane.fieldbyName('T2M').AsBoolean := true;
            TDS.tblmLane.fieldbyName('T3M').AsBoolean := true;
            TDS.tblmLane.fieldbyName('T1A').AsBoolean := true;
            TDS.tblmLane.fieldbyName('T2A').AsBoolean := true;
            TDS.tblmLane.fieldbyName('T3A').AsBoolean := true;

            TDS.tblmLane.Post; // Post the inserted or edited record.
          end;

        except on E: Exception do
          begin
            TDS.tblmLane.Cancel;
            found := false;
          end;
        end;

        if found and (PK_LaneID > 0) then
          ReadJsonSplits(laneObject, PK_LaneID);

      end;
    end;
  end;
end;

procedure ReadJsonFile(const FileName: string; out aRaceNum: integer );
var
  JSONObj: ISuperObject;
  FileStream: TFileStream;
  PK_SessionID, PK_EventID, PK_HeatID, PK: integer;
  fs: TFormatSettings;
  str: string;
  fCreationDT: TDateTime;
  wt: TWatchTime;
  found: boolean;
begin
  PK_SessionID := 0;
  found := false;

  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    JSONObj := TSuperObject.ParseStream(FileStream, True);
    if Assigned(JSONObj) and (JSONObj.DataType = dtObject) then
    begin
      if JSONObj.Contains('sessionId') then
      begin
        // Primary Key - NOTE: matches to SCM SessionID.
        PK_SessionID := JSONobj.I['sessionId'];
        // ApplyMaster : in the case where master-detail has be nullified
        // calling here may be redundant. Or it may ensure all records are
        // held in memory?
        {TODO -oBSA -cGeneral : Trace Delphi DB ApplyMaster procedure.}
        TDS.tblmSession.ApplyMaster;
        // ignore if found...
        if not TDS.LocateTSessionID(PK_SessionID) then
        begin
          // add the newly discovered session
          TDS.tblmSession.Insert;
          // May help to track an approx session time.
          fCreationDT := Now;
          // wit: the start of recording of race data from TimeDrops.
          TDS.tblmSession.FieldByName('createdOn').AsDateTime := fCreationDT;
          // Primary Key.
          TDS.tblmSession.FieldByName('sessionId').AsInteger := PK_SessionID;
          // Session Number.
          TDS.tblmSession.FieldByName('sessionNum').AsInteger := JSONobj.I['sessionNumber'];
          // Create a basic session caption.
          fs := TFormatSettings.Create;
          fs.DateSeparator := '_';
          fs.ShortDateFormat := 'yyyy-mm-dd';
          str := 'Session: ' + IntToStr(PK_SessionID) + ' Date: ' + DatetoStr(fCreationDT, fs);
          TDS.tblmSession.fieldbyName('Caption').AsString := str;
          TDS.tblmSession.Post;
        end;
      end;
      // SYNC ? ... TDS.tblmEvent.Refresh;
      if JSONObj.Contains('eventNumber') then
      begin
        TDS.tblmEvent.ApplyMaster; // Redundant?
        // Calc a primary key.
        PK := TDS.MaxID_Event + 1;
        // ignore if found...
        if not TDS.LocateTEventNum(PK_SessionID, JSONobj.I['eventNumber']) then
        begin
          // create new event
          TDS.tblmEvent.Insert;
          TDS.tblmEvent.FieldByName('EventNum').AsInteger := JSONobj.I['eventNumber'];
          // Calculate the Primary Key : IDENTIFIER.
          // ID isn't AutoInc. the primary key is calculated manually.
          TDS.tblmEvent.fieldbyName('EventID').AsInteger := PK;
          // master - detail. Also Index Field.
          TDS.tblmEvent.fieldbyName('SessionID').AsInteger := PK_SessionID;
          // CAPTION for Event :
          str := 'Event: ' +  IntToStr(JSONobj.I['eventNumber']);
          TDS.tblmEvent.fieldbyName('Caption').AsString := str;
          TDS.tblmEvent.Post;
        end;
      end;

      PK_EventID := TDS.tblmEvent.FieldByName('EventID').AsInteger;
      // SYNC ? ... TDS.tblmHeat.Refresh;
      if JSONObj.Contains('heatNumber') then
      begin
        PK := TDS.MaxID_Heat() + 1;
        TDS.tblmHeat.ApplyMaster; // Redundant?
        found := TDS.LocateTHeatNum(PK_EventID, JSONobj.I['heatNumber']);
        // Create a new heat in TDS.tblmHeat.
        if not found then
        begin
          try
            begin
              TDS.tblmHeat.Insert;
              TDS.tblmHeat.FieldByName('HeatNum').AsInteger := JSONobj.I['heatNumber'];
              // calculate the IDENTIFIER.
              // ID isn't AutoInc - calc manually.
              TDS.tblmHeat.fieldbyName('HeatID').AsInteger := PK;
              // master - detail.
              TDS.tblmHeat.fieldbyName('EventID').AsInteger := PK_EventID;
              // TIME STAMP.
              TDS.tblmHeat.fieldbyName('startTime').AsDateTime := ISO8601ToDate(JSONobj.S['startTime']);
              TDS.tblmHeat.fieldbyName('Caption').AsString := 'Heat: ' + IntToStr(JSONobj.I['heatNumber']);

              // A unique sequential number for each heat.
              TDS.tblmHeat.fieldbyName('RaceNum').AsInteger:= JSONobj.I['raceNumber'];
              if JSONobj.Null['raceNumber'] in [jUnAssigned, jNull] then
                aRaceNum := 0 else aRaceNum := JSONobj.I['raceNumber'];

              // TimeStamp of TimeDrops Results file.
              TDS.tblmHeat.fieldbyName('CreatedOn').AsDateTime := ISO8601ToDate(JSONobj.s['createdAt']);
              TDS.tblmHeat.Post;
              found := true;
            end;
          except on E: Exception do
            begin
              TDS.tblmHeat.Cancel;
              found := false;
            end;
          end;
        end;
      end;
      if found then
      begin
        PK_HeatID := TDS.tblmHeat.FieldByName('HeatID').AsInteger;
        ReadJsonLanes(JSONObj, PK_HeatID);

        wt := TWatchTime.Create();
        wt.ProcessHeat(PK_HeatID);
        wt.Free;
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
  TDS.tblmSession.EmptyDataSet;
  TDS.tblmEvent.EmptyDataSet;
  TDS.tblmHeat.EmptyDataSet;
  TDS.tblmLane.EmptyDataSet;
  TDS.tblmNoodle.EmptyDataSet;

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
  SessionID, RaceNum: integer;
//  , EventNum, HeatNum: integer;
  Fields: TArray<string>;
  fn: string;
begin
  // init
//  SessionID := 0;
//  EventNum := 0;
//  HeatNum := 0;
  RaceNum := 0;
  if FileExists(AFileName) then
  begin
    TDS.DisableAllTDControls;
    // =====================================================
    // De-attach from Master-Detail. Create flat files.
    // Necessary to calculate table Primary keys.
    TDS.DisableTDMasterDetail;
    // =====================================================
    try
      begin
        // remove path from filename
        fn := ExtractFileName(AFileName);
        Fields := SplitString(fn, '_');
        if Length(Fields) > 1 then
        begin
          // Strip non-numeric characters from Fields[1]
          Fields[0] := StripNonNumeric(Fields[0]);
          SessionID := StrToIntDef(Fields[0], 0);
          if (SessionID <> 0) then
          begin
            // Filename syntax used by Time Drops: SessionSSSS_Event_EEEE_HeatHHHH_RaceRRRR_XXX.json
//            if Length(Fields) > 2 then
//              EventNum := StrToIntDef(StripNonNumeric(Fields[1]), 0);
//            if Length(Fields) > 3 then
//              HeatNum := StrToIntDef(StripNonNumeric(Fields[2]), 0);
            if Length(Fields) > 4 then
              RaceNum := StrToIntDef(StripNonNumeric(Fields[3]), 0);
            ReadJsonFile(AFileName, RaceNum);
          end;
        end;      
      end;
    finally

    // =====================================================
    // Re-attach Master-Detail.
    TDS.EnableTDMasterDetail;
    TDS.EnableAllTDControls;
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



end.
