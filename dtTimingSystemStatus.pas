unit dtTimingSystemStatus;

interface
uses
  system.IOUtils,
  system.SysUtils, system.Types, system.UITypes, system.Classes,
  system.Variants, VCL.Controls, system.DateUtils,
  XSuperJSON, XSuperObject, dmAppData,
  FireDAC.Stan.Param, dmSCM, tdSetting;

function BuildAndSaveTimingSystemStatus(AFilePath: TFileName; ASessionID: integer; dt: TDateTime): boolean;

implementation

(*

"currentEvent": "1",
"currentHeat": 1,
"currentSessionNumber": 123,
"currentSessionId": "67251",
"protocolVersion": "1.0.0",
"timingSystemType": "Time-Drops",
"timingSystemVersion": "2023.04.787.debug",
"lastMeetProgramDate": "2023-07-29T16:33:41.922",
"updatedAt": "2023-07-31T17:32:31.725-07:00"

*)

function BuildAndSaveTimingSystemStatus(AFilePath: TFileName; ASessionID: integer; dt: TDateTime): boolean;
var
  X: ISuperObject;
  AFormatSettings: TFormatSettings;
  defName, pathStr: string;
begin
  AFormatSettings := TFormatSettings.Create;
  AFormatSettings.DateSeparator := '-';
  AFormatSettings.TimeSeparator := ':';
  AFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  AFormatSettings.LongTimeFormat := 'hh:nn:ss';

  defName := 'time_drops_status.json';

  // Create the main SuperObject
  X := SO();
  X.S['type'] := 'time_drops_status';
  X.I['currentEvent'] := 1;
  X.I['currentHeat'] := 1;
  X.I['currentSessionNumber'] := 1; // only one session in meet program.
  X.I['currentSessionID'] := ASessionID;
  X.S['protocolVersion'] := '1.0.0';
  X.S['timingSystemType'] := 'Time-Drops';
  X.S['timingSystemVersion'] := '2023.04.787.debug"';
  // meet program datetime eg. TSuperObject  .S['meetProgramDateTime']
  X.S['lastMeetProgramDate'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', dt, AFormatSettings);
  X.S['updatedAt'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Now, AFormatSettings);
  // includes backslash ...
  pathStr := ExtractFilePath(AFilePath);
  pathStr := pathStr + defName;
  X.SaveTo(pathStr);
  Result := True;
end;

end.
