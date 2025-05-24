unit uNoodleData;
interface
uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uNoodleLink, dmTDS, dmSCM;
type
    TNoodleData = class
    private
    FSynced: Boolean;
    procedure NewNoodle(ANoodleLink: TNoodleLink);
    procedure DeleteNoodle(ANoodleLink: TNoodleLink);
    procedure UpdateNoodle(ANoodleLink: TNoodleLink);

    public
    constructor Create;
    destructor Destroy; override;
    
    property Synced: Boolean read FSynced write FSynced;
    
    // Methods to manage noodles
    procedure AddNoodle(ANoodleLink: TNoodleLink);
    procedure RemoveNoodle(ANoodleLink: TNoodleLink);
    procedure ModifyNoodle(ANoodleLink: TNoodleLink);



end;

implementation

procedure TNoodleData.NewNoodle(ANoodleLink: TNoodleLink);
var
    ANoodleID: Integer;
begin
  // Code to handle the creation of a new noodle link
  // This could involve adding it to a list or database
  FSynced := False; // Mark as unsynced
  dm.tblmNoodle.Insert;
    dm.tblmNoodle.FieldByName('NoodleID').AsInteger := ANoodleID;
    dm.tblmNoodle.FieldByName('HeatID').AsInteger := dm.tblmHeat.FieldByNameID('HeatID').AsInteger;
    dm.tblmNoodle.FieldByName('LaneID').AsInteger := dm.tblmLane.FieldByNameID('LaneID').AsInteger;

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


