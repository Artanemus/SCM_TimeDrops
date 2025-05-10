unit rptReportsSCM;

interface

uses
  System.SysUtils, System.Classes, dmSCM, frxClass, frxDBSet, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, VCL.Forms;

type
  TReportsSCM = class(TDataModule)
    frxReportSCM: TfrxReport;
    frxDBSession: TfrxDBDataset;
    frxDBSwimClub: TfrxDBDataset;
    frxDBEvent: TfrxDBDataset;
    frxDBDistance: TfrxDBDataset;
    frxDBStroke: TfrxDBDataset;
    qryEventType: TFDQuery;
    frxDBEventType: TfrxDBDataset;
    qryEventStatus: TFDQuery;
    frxDBEventStatus: TfrxDBDataset;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure RptExecute();
  end;

var
  ReportsSCM: TReportsSCM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TReportsSCM.DataModuleCreate(Sender: TObject);
var
msg: string;
begin
  if Assigned(SCM) and SCM.DataIsActive then
  begin
    qryEventType.Connection := SCM.scmConnection;
    qryEventType.Open;
    qryEventStatus.Connection := SCM.scmConnection;
    qryEventStatus.Open;
  end
  else
  Begin
    msg := 'Failed to connect with SCM datamodule.';
    raise Exception.Create(msg);
  End;
end;

procedure TReportsSCM.RptExecute;
begin
  frxReportSCM.ShowReport();
end;

end.
