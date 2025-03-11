unit dlgSessionPicker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, dmAppData,
  Vcl.DBCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Param;

type
  TSessionPicker = class(TForm)
    pnlHeader: TPanel;
    pnlFooter: TPanel;
    pnlBody: TPanel;
    dbtxtClubName: TDBText;
    dbtxtNickName: TDBText;
    dbgridSession: TDBGrid;
    btnOk: TButton;
    btnCancel: TButton;
    btnSelectClub: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dbgridSessionDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    fSessionID: integer;
  public
    property rtnSessionID: integer read FSessionID write FSessionID;
  end;

var
  SessionPicker: TSessionPicker;

implementation

{$R *.dfm}

procedure TSessionPicker.btnCancelClick(Sender: TObject);
begin
  fSessionID := 0;
  ModalResult :=  mrCancel;
end;

procedure TSessionPicker.btnOkClick(Sender: TObject);
begin
  fSessionID := dbgridSession.DataSource.DataSet.FieldByName('SessionID').AsInteger;
  ModalResult :=  mrOk;
end;

procedure TSessionPicker.FormCreate(Sender: TObject);
begin
  fSessionID := 0;
  AppData.qrySessionList.Close;
  AppData.qrySessionList.ParamByName('SWIMCLUBID').AsInteger :=
    AppData.qrySwimClub.FieldByName('SwimClubID').AsInteger;
  AppData.qrySessionList.Prepare;
  AppData.qrySessionList.Open;
  if not AppData.qrySessionList.Active then
  begin
    raise Exception.Create('Session List failed to load.');
  end;

end;

procedure TSessionPicker.dbgridSessionDblClick(Sender: TObject);
begin
  fSessionID := dbgridSession.DataSource.DataSet.FieldByName('SessionID').AsInteger;
  ModalResult :=  mrOk;
end;

procedure TSessionPicker.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if (key = VK_ESCAPE) then
  begin
    fSessionID := 0;
    ModalResult :=  mrCancel;
  end;
end;

procedure TSessionPicker.FormShow(Sender: TObject);
var
  SearchOptions: TLocateOptions;
  success: boolean;
begin
  if fSessionID <> 0 then
  begin
    SearchOptions := [];
    if AppData.qrySessionList.Active and not AppData.qrySessionList.IsEmpty then
    begin
        success := AppData.qrySessionList.Locate('SessionID', fSessionID, SearchOptions);
        if not success then
        begin
          AppData.qrySessionList.First;
        end;
    end;
  end;
end;

end.
