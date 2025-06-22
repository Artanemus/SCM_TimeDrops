unit uNoodleInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, dmSCM,
  dmTDS, uNoodle, Vcl.WinXCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;
type
  TNoodleInfo = class(TForm)
    pnlFooter: TPanel;
    btnOk: TButton;
    rpnlDetail: TRelativePanel;
    pnlSCM: TPanel;
    lblSCMSess: TLabel;
    lblSCMEv: TLabel;
    lblSCMHt: TLabel;
    lblSCML: TLabel;
    pnlTDS: TPanel;
    lblTDSSess: TLabel;
    lblTDSEv: TLabel;
    lblTDSHt: TLabel;
    lblTDSL: TLabel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    pnlHeader: TPanel;
    lblH1: TLabel;
    lblH2: TLabel;
		qryNDetail: TFDQuery;
		procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure FormShow(Sender: TObject);
  private
		FConnection: TFDConnection;
		fNoodle: TNoodle;

		FSCM_SessID: integer;
		FSCM_EvNum, FSCM_HtNum, FSCM_LNum: integer;
		FSCM_HeatID: Integer;
		FTDS_SessNum, FTDS_EvNum, FTDS_HtNum, FTDS_LNum: integer;

		procedure SetConnection(const Value: TFDConnection);
		procedure SetNoodle(const Value: TNoodle);

	public
		myNoodle: TNoodle;

		property Connection: TFDConnection read FConnection write SetConnection;
		property Noodle: Tnoodle read FNoodle write SetNoodle;

	end;

var
  NoodleInfo: TNoodleInfo;

implementation

{$R *.dfm}

procedure TNoodleInfo.FormCreate(Sender: TObject);
begin
	FNoodle := nil;
	FConnection := nil;
	qryNDetail.Connection := nil;
end;

procedure TNoodleInfo.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TNoodleInfo.FormKeyDown(Sender: TObject; var Key: Word; Shift:
  TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
		ModalResult := mrOk;
    Key := 0;
	end;
end;

procedure TNoodleInfo.FormShow(Sender: TObject);
var
  id: integer;
  nh: TNoodlehandle;
found: boolean;
begin
  lbl1.Caption := '';
  lbl2.Caption := '';
  lbl3.Caption := '';
  lbl4.Caption := '';
  lbl5.Caption := '';
  lbl6.Caption := '';
  lbl7.Caption := '';
  lbl8.Caption := '';

  if not assigned(FNoodle) or not assigned(FConnection) then exit;

	id := FNoodle.NDataID;
	found := true;
  if TDS.tblmNoodle.FieldByName('NoodleID').AsInteger <> id then
    found := TDS.Locate_NoodleID(id);
  if found then
  begin
    FTDS_LNum := 0;
    FTDS_HtNum := 0;
    FTDS_EvNum := 0;
    FTDS_SessNum := 0;

    FSCM_LNum := 0;
    FSCM_HtNum := 0;
    FSCM_EvNum := 0;
    FSCM_SessID := 0;

    nh := FNoodle.Gethandle(0);
    FSCM_LNum := nh.Lane;
    FSCM_HeatID := nh.HeatID;

    qryNDetail.Connection := FConnection;
    qryNDetail.Close;
    FSCM_HeatID := nh.HeatID;
    qryNDetail.ParamByName('HEATID').AsInteger := FSCM_HeatID;
    qryNDetail.Prepare;
    qryNDetail.Open;
    if qryNDetail.Active then
    begin
      if not qryNDetail.IsEmpty then
      begin
        FSCM_SessID := qryNDetail.FieldByName('SessionID').AsInteger;
        FSCM_EvNum := qryNDetail.FieldByName('EventNum').AsInteger;
        FSCM_HtNum := qryNDetail.FieldByName('HeatNum').AsInteger;
      end;
    end;

    nh := FNoodle.Gethandle(1);
    FTDS_LNum := nh.Lane;
    FTDS_HtNum := TDS.tblmHeat.FieldByName('HeatNum').AsInteger;
    FTDS_EvNum := TDS.tblmEvent.FieldByName('EventNum').AsInteger;
    FTDS_SessNum := TDS.tblmSession.FieldByName('SessionNum').AsInteger;

  end;

  lbl1.Caption := IntToStr(FTDS_SessNum);
  lbl2.Caption := IntToStr(FSCM_EvNum);
  lbl3.Caption := IntToStr(FSCM_HtNum);
  lbl4.Caption := IntToStr(FSCM_LNum);
  lbl5.Caption := IntToStr(FTDS_SessNum);
  lbl6.Caption := IntToStr(FTDS_EvNum);
  lbl7.Caption := IntToStr(FTDS_HtNum);
  lbl8.Caption := IntToStr(FTDS_LNum);

end;

procedure TNoodleInfo.SetConnection(const Value: TFDConnection);
begin
	if Value <> nil then
		FConnection := Value;
end;

procedure TNoodleInfo.SetNoodle(const Value: TNoodle);
begin
	FNoodle := Value;
end;

end.

