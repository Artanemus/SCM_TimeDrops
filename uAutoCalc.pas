unit uAutoCalc;

interface

uses dmAppData, vcl.ComCtrls, Math, System.Types, System.IOUtils,
  Windows, System.Classes,System.StrUtils, SysUtils ;
type

TAutoCalc = class(TObject)
  private

  protected

  public
    constructor Create; override;
    destructor Destroy; override;

  published

  end;

implementation

{ TAutoCalc }

constructor TAutoCalc.Create;
begin
  inherited;

end;

destructor TAutoCalc.Destroy;
begin

  inherited;
end;

end.
