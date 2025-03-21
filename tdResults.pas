unit tdResults;

interface

uses XSuperJSON, XSuperObject, dmAppData;

implementation
uses
  SysUtils, Classes, System.JSON;

procedure ReadJsonFile(const FileName: string);
var
  JSONObj, lanesObj: ISuperObject;
  FileStream: TFileStream;
  Iterator1, Iterator2: TSuperEnumerator<IJSONPair>;
  cast1, cast2: ICast;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    JSONObj := TSuperObject.ParseStream(FileStream, True);
    if Assigned(JSONObj) and (JSONObj.DataType = dtObject) then
    begin
      // Process the JSON object
      Writeln(JSONObj.AsJSon);

      // Iterate over the JSON object using enumerator
      JSONObj.First;
      Iterator1 := JSONObj.GetEnumerator;
      while Iterator1.MoveNext do
      begin
        cast1 := Iterator1.GetCurrent;
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
        if cast1.Name = 'eventNumber' then
        begin
          AppData.tblmEvent.Insert;
          AppData.tblmEvent.FieldByName('EventNum').AsInteger := cast1.AsInteger;
          AppData.tblmEvent.Post;
        end;
        if cast1.Name = 'heatNumber' then
        begin
          AppData.tblmHeat.Insert;
          AppData.tblmHeat.FieldByName('HeatNum').AsInteger := cast1.AsInteger;
              AppData.tblmHeat.FieldByName('EventID').AsInteger :=
                AppData.tblmEvent.FieldByName('EventID').AsInteger;
          AppData.tblmHeat.Post;
        end;

        if cast1.Name = 'lanes' then
        begin
          lanesObj := TSuperObject.CreateCasted(JSONObj as IJSONAncestor);
          lanesObj.First;
          Iterator2 := lanesObj.GetEnumerator;
          while Iterator2.MoveNext do
          begin
            Cast2 := Iterator2.GetCurrent;
            if Cast2.Name = 'lane' then
            begin
              AppData.tblmLane.Insert;
              AppData.tblmLane.FieldByName('HeatID').AsInteger :=
                AppData.tblmHeat.FieldByName('HeatID').AsInteger;
              AppData.tblmLane.FieldByName('LaneNum').AsInteger := Cast2.AsInteger;
              AppData.tblmLane.Post;
            end;
            if Cast2.Name = 'finalTime' then
            begin
              AppData.tblmLane.Edit;
              AppData.tblmLane.FieldByName('finalTime').AsInteger := Cast2.AsInteger;
              AppData.tblmLane.Post;
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
