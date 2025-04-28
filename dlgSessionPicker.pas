unit dlgSessionPicker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.DBCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Param, dmSCM,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

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
    qrySessionList: TFDQuery;
    qrySessionListSessionID: TFDAutoIncField;
    qrySessionListCaption: TWideStringField;
    qrySessionListSessionStart: TSQLTimeStampField;
    qrySessionListClosedDT: TSQLTimeStampField;
    qrySessionListSwimClubID: TIntegerField;
    qrySessionListSessionStatusID: TIntegerField;
    dsSessionList: TDataSource;
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

  if Assigned(SCM) and Assigned(SCM.scmConnection)
      and SCM.scmConnection.Connected then
  begin
    qrySessionList.Connection := SCM.scmConnection;
    if qrySessionList.Active then
      qrySessionList.Close;
    qrySessionList.ParamByName('SWIMCLUBID').AsInteger :=
      SCM.qrySwimClub.FieldByName('SwimClubID').AsInteger;
    qrySessionList.Prepare;
    qrySessionList.Open;
  end;

  if not qrySessionList.Active then
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
    if qrySessionList.Active and not qrySessionList.IsEmpty then
    begin
        success := qrySessionList.Locate('SessionID', fSessionID, SearchOptions);
        if not success then
        begin
          qrySessionList.First;
        end;
    end;
  end;
end;

end.
