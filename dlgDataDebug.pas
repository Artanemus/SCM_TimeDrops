unit dlgDataDebug;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dmAppData, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ComCtrls;

type
  TDataDebug = class(TForm)
    pgcntrlData: TPageControl;
    grid: TTabSheet;
    tabsheetEvent: TTabSheet;
    tabsheetHeat: TTabSheet;
    tabsheetLane: TTabSheet;
    tabsheetNoodle: TTabSheet;
    dbgridSession: TDBGrid;
    dbgridEvent: TDBGrid;
    dbgridHeat: TDBGrid;
    dbgridLane: TDBGrid;
    dbgridNoodle: TDBGrid;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataDebug: TDataDebug;

implementation

{$R *.dfm}

procedure TDataDebug.FormShow(Sender: TObject);
begin
  // ASSERT connection
  dbgridSession.DataSource := appData.dsmSession;
  dbgridEvent.DataSource := appData.dsmEvent;
  dbgridHeat.DataSource := appData.dsmHeat;
  dbgridLane.DataSource := appData.dsmLane;
  dbgridNoodle.DataSource := appData.dsmNoodle;

end;

end.
