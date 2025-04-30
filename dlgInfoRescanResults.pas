unit dlgInfoRescanResults;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TInfoReScanResults = class(TForm)
    pnlBody: TPanel;
    chkbDoShowAgain: TCheckBox;
    RichEditInfo: TRichEdit;
    pnlFooter: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    chkbHideInfoBox: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InfoReScanResults: TInfoReScanResults;

implementation

{$R *.dfm}

end.
