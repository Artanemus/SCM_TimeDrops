unit dlgFDExplorerMsg;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, OKCANCL1;

type
  TFDExplorerMsg = class(TForm)
    HelpBtn: TButton;
    pnlFooter: TPanel;
    lblBodyMsg: TLabel;
    pnlBody: TPanel;
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FDExplorerMsg: TFDExplorerMsg;

implementation

{$R *.dfm}

procedure TFDExplorerMsg.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
 
