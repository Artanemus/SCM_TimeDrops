unit dlgSwimClubPicker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.DBCtrls, dmSCM, AdvUtil, Vcl.Grids, AdvObj, BaseGrid,
  AdvGrid, DBAdvGrid;

type
  TSwimClubPicker = class(TForm)
    pnlFooter: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlHeader: TPanel;
    dbtxtClubName: TDBText;
    dbtxtNickName: TDBText;
    qrySwimClubList: TFDQuery;
    dsSwimClubList: TDataSource;
    qrySwimClubListSwimClubID: TFDAutoIncField;
    qrySwimClubListNickName: TWideStringField;
    qrySwimClubListCaption: TWideStringField;
    qrySwimClubListNumOfLanes: TIntegerField;
    qrySwimClubListLenOfPool: TIntegerField;
    qrySwimClubListLogoImg: TBlobField;
    qrySwimClubListPoolTypeID: TIntegerField;
    SwimClubGrid: TDBAdvGrid;
    pnlBody: TPanel;
    qrySwimClubListStartOfSwimSeason: TSQLTimeStampField;
    qrySwimClubListPoolTypeCaption: TWideStringField;
		procedure btnCancelClick(Sender: TObject);
		procedure btnOkClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
		{ Private declarations }
		FSwimClubID: integer;
	public
		{ Public declarations }
		property SwimClubID: integer read FSwimClubID write FSwimClubID;

	end;

var
  SwimClubPicker: TSwimClubPicker;

implementation

{$R *.dfm}

procedure TSwimClubPicker.btnCancelClick(Sender: TObject);
begin
	fSwimClubID := 0;
	ModalResult :=  mrCancel;
end;

procedure TSwimClubPicker.btnOkClick(Sender: TObject);
begin
	fSwimClubID := SwimClubGrid.DataSource.DataSet.FieldByName('SwimClubID').AsInteger;
	ModalResult :=  mrOk;
end;

procedure TSwimClubPicker.FormCreate(Sender: TObject);
begin
	FSwimClubID := 0;

	if Assigned(SCM) and Assigned(SCM.scmConnection)
			and SCM.scmConnection.Connected then
	begin
		qrySwimClubList.Connection := SCM.scmConnection;
//		if qrySwimClubList.Active then
//			qrySwimClubList.Close;
//		qrySwimClubList.ParamByName('SWIMCLUBID').AsInteger :=
//			SCM.qrySwimClub.FieldByName('SWIMCLUBID').AsInteger;
		qrySwimClubList.Prepare;
		qrySwimClubList.Open;
	end;

	if not qrySwimClubList.Active then
	begin
		raise Exception.Create('SwimClub List failed to load.');
	end;
end;

procedure TSwimClubPicker.FormKeyDown(Sender: TObject; var Key: Word; Shift:
		TShiftState);
begin
	if Key = VK_ESCAPE then
	begin
		fSwimClubID := 0;
		ModalResult :=  mrCancel;
	end;
end;

end.
