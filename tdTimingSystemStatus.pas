unit tdTimingSystemStatus;

interface
uses
  system.IOUtils,
  system.SysUtils, system.Types, system.UITypes, system.Classes,
  system.Variants, VCL.Controls, system.DateUtils,
  XSuperJSON, XSuperObject,
  FireDAC.Stan.Param, dmSCM, tdSetting;

function BuildAndSaveTimingSystemStatus(AFilePath: TFileName; ASessionID, currEvent, currHeat: integer): boolean;

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

function BuildAndSaveTimingSystemStatus(AFilePath: TFileName; ASessionID, currEvent, currHeat: integer): boolean;
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
  X.S['type'] := 'time_drops_timing_status';
  X.I['currentEvent'] := currEvent;
  X.I['currentHeat'] := currHeat;
  X.I['currentSessionNumber'] := 1; // only one session in meet program.
  X.I['currentSessionID'] := ASessionID;
  X.S['protocolVersion'] := '1.0.0';
  X.S['timingSystemType'] := 'Time-Drops';
  X.S['timingSystemVersion'] := '2023.04.787.debug"';
  // The datetime of the last meet program contructed and saved _
  // (by SCM_TimeDrops) to the Time-Drops Meet folder.
  if Assigned(settings) then
    X.S['lastMeetProgramDate'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Settings.lastMeetProgramDate, AFormatSettings)
  else
    {TODO -oBSA -cGeneral : Read the previous 'updatedAt' ?}
    X.S['lastMeetProgramDate'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Now, AFormatSettings);

  X.S['updatedAt'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Now, AFormatSettings);
  // includes backslash ...
  pathStr := ExtractFilePath(AFilePath);
  pathStr := pathStr + defName;
  X.SaveTo(pathStr);
  Result := True;
end;

end.
