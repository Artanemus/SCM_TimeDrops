unit tdResults;

interface

uses XSuperJSON, XSuperObject, dmAppData;

implementation
uses
  SysUtils, Classes, System.JSON;

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


procedure ReadJsonFile(const FileName: string);
var
  JSONObj, laneObject: ISuperObject;
  lanesObj: ISuperArray;
  finalTimeValue: ISuperExpression;
  FileStream: TFileStream;
  aIterator: TSuperEnumerator<IJSONAncestor>;
  laneValue: ICast;
  aSessionID, aEventID, aEventNum, aHeatID, aHeatNum, laneNum: integer;
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
        aSessionID := JSONobj.I['sessionId'];
        if (aSessionID <> 0) then
          if not AppData.LocateDTSessionID(aSessionID) then
          begin
            AppData.tblmSession.Insert;
            AppData.tblmSession.FieldByName('sessionId').AsInteger := aSessionId;
            AppData.tblmSession.Post;
          end;
      end;

      AppData.tblmEvent.ApplyMaster;
      if JSONObj.Contains('eventNumber') then
      begin
        aEventNum := JSONobj.I['eventNumber'];
        if (aEventNum <> 0) then
        begin
          if not AppData.LocateDTEventNum(aSessionID, aEventNum, dtPrecFileName) then
          begin
            AppData.tblmEvent.Insert;
            AppData.tblmEvent.FieldByName('EventNum').AsInteger := aEventNum;
            AppData.tblmEvent.Post;
          end;
        end;
        {TODO -oBSA -cGeneral : Locate EventId}
        aEventID := AppData.tblmEvent.FieldByName('EventID').AsInteger;
      end;

      AppData.tblmHeat.ApplyMaster;
      if JSONObj.Contains('heatNumber') then
      begin
        aHeatNum := JSONobj.I['heatNumber'];
        if (aHeatNum <> 0) then
        begin
          if not AppData.LocateDTHeatNum(aEventID, aHeatNum, dtPrecFileName) then
          begin
            AppData.tblmHeat.Insert;
            AppData.tblmHeat.FieldByName('HeatNum').AsInteger := aEventNum;
            AppData.tblmHeat.Post;
          end;
        end;
        {TODO -oBSA -cGeneral : Locate EventId}
        aHeatID := AppData.tblmHeat.FieldByName('HeatID').AsInteger;
      end;

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
              if AppData.LocateDTLaneNum(laneNum) then // Or however you locate lanes
              begin
                AppData.tblmLane.Edit;
              end
              else
              begin
                AppData.tblmLane.Insert;
                AppData.tblmLane.FieldByName('HeatID').AsInteger := aHeatID;
                AppData.tblmLane.FieldByName('LaneNum').AsInteger := laneNum;
              end;

              // --- Update fields (handle nulls!) ---
              finalTimeValue := laneObject['finalTime']; // ISuperExpression...

              if Assigned(finalTimeValue) and (finalTimeValue.DataType <> dtNull) then
              begin
                {TODO -oBSA -cGeneral : convert 10th of seconds to datetime...}
                // TTime t := finalTimeValue.AsInteger * 10 ...
//                AppData.tblmLane.FieldByName('finalTime').AsInteger := finalTimeValue.AsInteger;
              end
              else
                AppData.tblmLane.FieldByName('finalTime').Clear;

              // Add similar checks and assignments for padTime, timer1, isEmpty, isDq, etc.
              // if they exist in your JSON and database table.

              // ... other fields ...

              AppData.tblmLane.Post; // Post the inserted or edited record
            end;
          end;
        end;
      end;


    end;



  finally
    FileStream.Free;
  end;
end;

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

end.
