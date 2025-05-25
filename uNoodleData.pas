unit uNoodleData;
interface
uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uNoodleLink, dmTDS, dmSCM;
type
    TNoodleData = class
    private
    FSynced: Boolean;

    public
    constructor Create;
    destructor Destroy; override;
    
    // Methods to manage noodles
    procedure AddNoodle(ANoodleLink: TNoodleLink);
    procedure DeleteNoodle(ANoodleLink: TNoodleLink);
    procedure UpdateNoodle(ANoodleLink: TNoodleLink);

    property Synced: Boolean read FSynced write FSynced;

end;

implementation

procedure TNoodleData.AddNoodle(ANoodleLink: TNoodleLink);
var
    ANoodleID: Integer;
begin
  // Code to handle the creation of a new noodle link
  // This could involve adding it to a list or database
  ANoodleID := TDS.MaxID_Noodle;

  FSynced := False; // Mark as unsynced
  TDS.tblmNoodle.Insert;
  TDS.tblmNoodle.FieldByName('NoodleID').AsInteger := ANoodleID;
  TDS.tblmNoodle.FieldByName('HeatID').AsInteger := TDS.tblmHeat.FieldByName('HeatID').AsInteger;
  TDS.tblmNoodle.FieldByName('LaneID').AsInteger := TDS.tblmLane.FieldByName('LaneID').AsInteger;

end;
procedure TNoodleData.DeleteNoodle(ANoodleLink: TNoodleLink);
begin
  // Code to handle the deletion of a noodle link
  // This could involve removing it from a list or database
  FSynced := False; // Mark as unsynced
end;
procedure TNoodleData.UpdateNoodle(ANoodleLink: TNoodleLink);
begin
  // Code to handle the update of a noodle link
  // This could involve updating its properties in a list or database
  FSynced := False; // Mark as unsynced
end;
constructor TNoodleData.Create;
begin
  FSynced := True; // Initially, no noodles are present, so we consider it synced
end;
destructor TNoodleData.Destroy;
begin
  // Cleanup code if necessary
  inherited Destroy;
end;

end.


