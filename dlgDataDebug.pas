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
    tabsheetEntrant: TTabSheet;
    tabsheetNoodle: TTabSheet;
    dbgridSession: TDBGrid;
    dbgridEvent: TDBGrid;
    dbgridHeat: TDBGrid;
    dbgridEntrant: TDBGrid;
    dbgridNoodle: TDBGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataDebug: TDataDebug;

implementation

{$R *.dfm}

end.
