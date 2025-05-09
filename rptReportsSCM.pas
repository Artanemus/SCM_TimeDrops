unit rptReportsSCM;

interface

uses
  System.SysUtils, System.Classes, dmSCM, frxClass, frxDBSet;

type
  TReportsSCM = class(TDataModule)
    frxReportSCM: TfrxReport;
    frxDBSession: TfrxDBDataset;
    frxDBSwimClub: TfrxDBDataset;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReportsSCM: TReportsSCM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
