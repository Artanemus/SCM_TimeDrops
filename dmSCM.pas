unit dmSCM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.Client, Data.DB,
  FireDAC.Comp.DataSet;

type
  TSCM = class(TDataModule)
    scmConnection: TFDConnection;
    tblSwimClub: TFDTable;
    dsSwimClub: TDataSource;
    qrySCMSystem: TFDQuery;
  private
    { Private declarations }
    fDBModel, fDBVersion, fDBMajor, fDBMinor: integer;
    FIsActive: boolean;
  public
    { Public declarations }
    property IsActive: boolean read FIsActive write FIsActive;
    procedure ActivateTable();
    procedure DeActivateTable();
    function  GetDBVerInfo(): string;
  end;

var
  SCM: TSCM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TSCM }

procedure TSCM.ActivateTable;
begin
  // activate the SCM system table .
  tblSwimClub.Open;
  if tblSwimClub.Active then
    FIsActive := true;
end;

procedure TSCM.DeActivateTable;
begin
  // close all ....
  tblSwimClub.Close;
  FIsActive := false;
end;

function TSCM.GetDBVerInfo: string;
begin
  result := '';
  if scmConnection.Connected then
  begin
    with qrySCMSystem do
    begin
      Connection := scmConnection;
      Open;
      if Active then
      begin
        fDBModel := FieldByName('SCMSystemID').AsInteger;
        fDBVersion := FieldByName('DBVersion').AsInteger;
        fDBMajor := FieldByName('Major').AsInteger;
        fDBMinor := FieldByName('Minor').AsInteger;
        result := IntToStr(fDBModel) + '.' + IntToStr(fDBVersion) + '.' +
          IntToStr(fDBMajor) + '.' + IntToStr(fDBMinor);
      end;
      Close;
    end;
  end;
end;

end.
