unit dlgTreeViewSCM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, dmSCM, Vcl.StdCtrls,
  Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Generics.Collections;

type

  TIdentData = class(TObject)
  private
    FID: integer; // EventID or HeatID - rootNode or SubNode
    FValue: integer; // EventNum or HeatNum.
  public
    constructor Create(AID: integer; AValue: integer);
    property ID: Integer read FID write FID;
  end;


type
  TTreeViewSCM = class(TForm)
    btnCancel: TButton;
    btnClose: TButton;
    dsEvent: TDataSource;
    dsHeat: TDataSource;
    pnlFooter: TPanel;
    qryEvent: TFDQuery;
    qryHeat: TFDQuery;
    TV: TTreeView;
    procedure btnCancelClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TVDblClick(Sender: TObject);
  private
    { Private declarations }
    FConnection: TFDConnection;
    FSelectedEventID: integer;
    FSelectedHeatID: integer;
    FSessionID: integer;
    procedure FreeTreeViewData;
    procedure LocateEventID(AEventID: integer);
    procedure LocateHeatID(AHeatID: integer);
    { procedure LocateTreeItem(EventNum, HeatNum: integer); }
    procedure PopulateTree;
  public
    { Public declarations }
    procedure Prepare(AConnectionID: TFDConnection; ASessionID, AEventID, AHeatID: integer);
    property Connection: TFDConnection read FConnection write FConnection;
    property SelectedEventID: integer read FSelectedEventID write FSelectedEventID;
    property SelectedHeatID: integer read FSelectedHeatID write FSelectedHeatID;
    property SessionID: integer read FSessionID write FSessionID;
  end;

var
  TreeViewSCM: TTreeViewSCM;

implementation

{$R *.dfm}

{ TIdentData }
constructor TIdentData.Create(AID: integer; AValue: integer);
begin
  FID := AID; // Identifier ...  eg EventID, HEATID.
  FValue := AValue; // EventNum or HeatNum ...
end;

procedure TTreeViewSCM.btnCancelClick(Sender: TObject);
begin
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    ModalResult := mrCancel;
end;

procedure TTreeViewSCM.btnCloseClick(Sender: TObject);
var
node: TTreeNode;
obj : TIdentData;
begin
  FSelectedEventID := 0;
  FSelectedHeatID := 0;
  node := TV.Selected;
  if (node <> nil) then
  begin
    { ROOT NODE }
    if (node.Level = 0) then
    begin
      obj := node.Data;
      if (obj <> nil) then
      begin
        FSelectedEventID := obj.FID;  // EVENT ID.
        node := node.getFirstChild;
        if (node <> nil) then
        begin
          obj := node.Data;
          if (obj <> nil) then
          begin
            FSelectedHeatID := obj.FID; // HEAT ID.
          end;
        end;
      end;
    end
    { CHILD NODE }
    else
    begin
      obj := node.Data;
      if (obj <> nil) then
      begin
        FSelectedHeatID := obj.FID;  // HEAT ID.
        if (node.Parent <> nil) then
        begin
          node := TTreeNode(node.Parent);
          obj := node.Data;
          if (obj <> nil) then
          begin
            FSelectedEventID := obj.FID; // HEAT ID.
          end;
        end;
      end;
    end;
  end;
  ModalResult := mrOk;
end;

procedure TTreeViewSCM.FreeTreeViewData;
var
ident: TIdentData;
Node: TTreeNode;
begin
  for Node in TV.Items do
  begin
    ident := Node.Data;
    if Assigned(ident) then
    begin
      ident.Free;
      Node.Data := nil;
    end;
  end;
end;

{ TTreeViewSCM }
procedure TTreeViewSCM.FormCreate(Sender: TObject);
begin
  // Empty the TreeView.
  FConnection := nil;
  FSessionID := 0;
  TV.Items.Clear; // remove all design-time layout items.
end;

procedure TTreeViewSCM.FormDestroy(Sender: TObject);
begin
  FreeTreeViewData;
  TV.Items.Clear;
end;

procedure TTreeViewSCM.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TTreeViewSCM.LocateEventID(AEventID: integer);
var
  Node, ChildNode: TTreeNode;
  obj : TIdentData;
begin
  Node := TV.Items.GetFirstNode;
  while Node <> nil do
  begin
    obj := Node.Data;
    if (obj <> nil) and (obj.FID = AEventID) then
    begin
      ChildNode := Node.GetFirstChild;
      if (ChildNode <> nil) then
      begin
        // Expand the parent node if it's collapsed.
        if not ChildNode.Parent.Expanded then
          ChildNode.Parent.Expanded := True;
        // Focus on first heat in event.
        TV.Selected := ChildNode;
        ChildNode.Focused := true;
      end;
      break;
    end;
    Node := Node.GetNextSibling;
  end;
end;

procedure TTreeViewSCM.LocateHeatID(AHeatID: integer);
var
  Node, ChildNode: TTreeNode;
  obj : TIdentData;
begin
  Node := TV.Items.GetFirstNode;
  while Node <> nil do
  begin
    ChildNode := Node.GetFirstChild;
    while ChildNode <> nil do
    begin
      obj := ChildNode.Data;
      if (obj <> nil) and (obj.FID = AHeatID) then
      begin
        // Expand the parent node if it's collapsed
        if not Node.Expanded then
          Node.Expanded := True;
        TV.Selected := ChildNode;
        ChildNode.Focused := true;
        break;
      end;
      ChildNode := ChildNode.GetNextSibling;
    end;
    Node := Node.GetNextSibling;
  end;
end;

{
procedure TTreeViewSCM.LocateTreeItem(EventNum, HeatNum: integer);
var
  Node: TTreeNode;
  Found: Boolean;
  obj : TIdentData;
begin
  Found := False;
  Node := TV.Items.GetFirstNode;
  while Node <> nil do
  begin
    obj := Node.Data;
    if (obj <> nil) and (obj.FID= EventNum) then
    begin
      Found := True;
      break;
    end;
    Node := Node.GetNextSibling;
  end;

  if Found then
  begin
    Node := Node.GetFirstChild;
    while Node <> nil do
    begin
      obj := Node.Data;
      if (obj <> nil) and (obj.FID = HeatNum) then
      begin
        // Expand the parent node if it's collapsed
        if not Node.Parent.Expanded then
          Node.Parent.Expanded := True;
        TV.Selected := Node;
        Node.Focused := true;
        break;
      end;
      Node := Node.GetNextSibling;
    end;
  end;
end;
}

procedure TTreeViewSCM.PopulateTree;
var
  node, subnode: TTreeNode;
  s: string;
  i, j, id: integer;
  ident: TIdentData;
begin
  { p o p u l a t e   t h e   T r e e V i e w . . .   }

  // R O O T   N O D E S    -   E V E N T S   . . .
  qryEvent.First;
  while not qryEvent.Eof do
  begin
    s := qryEvent.FieldByName('EventCaption').AsString;
    i := qryEvent.FieldByName('StrokeID').AsInteger;
    j := qryEvent.FieldByName('EventNum').AsInteger;
    id := qryEvent.FieldByName('EventID').AsInteger;
    { CREATE NODE : EventID, EventNum.}
    ident := TIdentData.Create(id, j); // object to hold event and even number.
    Node := TV.Items.AddObject(nil, s, ident); // assign data ptr.

    if (qryEvent.FieldByName('EventTypeID').AsInteger = 1) then
    begin
      case i of
        1: // Freestyle
          Node.ImageIndex := 1;
        2: // BreastStroke
          Node.ImageIndex := 3;
        3: // BackStroke
          Node.ImageIndex := 2;
        4: // Butterfly
          Node.ImageIndex := 4;
        5: // Medley
          Node.ImageIndex := 5;
      end;
    end;

    if (qryEvent.FieldByName('EventTypeID').AsInteger = 2) then
    begin
      case i of
        1: // Freestyle
          Node.ImageIndex := 6;
        2: // BreastStroke
          Node.ImageIndex := 8;
        3: // BackStroke
          Node.ImageIndex := 7;
        4: // Butterfly
          Node.ImageIndex := 9;
        5: // Medley
          Node.ImageIndex := 10;
      end;
    end;

    if (qryEvent.FieldByName('EventStatusID').AsInteger = 2) then
      Node.StateIndex := 5   // ticked box - all heats are closed
    else
      Node.StateIndex := 4;  // un-ticked box.

    Node.SelectedIndex := Node.ImageIndex;
    Node.ExpandedImageIndex := -1;

    // ------------------------------------------------------------
    // C H I L D   N O D E S   -   H E A T S  ...
    qryHeat.First;
    while not qryHeat.Eof do
    begin
      // Add child nodes
      s := qryHeat.FieldByName('HeatCaption').AsString;
      i := qryHeat.FieldByName('HeatNum').AsInteger;
      j := qryHeat.FieldByName('HeatStatusID').AsInteger;
      id := qryHeat.FieldByName('HeatID').AsInteger;

      { CREATE SUBNODE : HeatID, HeatNum.}
      ident := TIdentData.Create(id, i);
      subnode := TV.Items.AddChildObject(Node, s, ident);

      // ICON ORDERED heat numbers ...
      if (i > 9) then
        subnode.ImageIndex := 0
      else
        // heat number icons 1 thru 9..
        subnode.ImageIndex := i + 14;

      // ICON Heat status : Open, Raced, Closed.
      case j of
        1:
          subnode.StateIndex := 1;
        2:
          subnode.StateIndex := 2;
        3:
          subnode.StateIndex := 3;
      end;

      subNode.SelectedIndex := subnode.ImageIndex;

      qryHeat.Next;
    end;
    // ------------------------------------------------------------
    qryEvent.Next;
  end;

end;

procedure TTreeViewSCM.Prepare(AConnectionID: TFDConnection;
  ASessionID, AEventID, AHeatID: integer);
var
  node: TTreeNode;
begin
  if Assigned(AConnectionID) then
  begin
    FConnection := AConnectionID;
    qryEvent.Connection := FConnection;
    qryEvent.ParamByName('SESSIONID').AsInteger := ASessionID;
    qryEvent.Prepare;
    qryEvent.Open;
    if qryEvent.Active then
    begin
      qryHeat.Connection :=FConnection;
      qryHeat.Open; // Master : Detail relationship ...
    end;

    PopulateTree;

    if (AHeatID <> 0) then
      LocateHeatID(AHeatID)
    else if (AEventID <> 0) then
      LocateEventID(AEventID)
    else
    begin
      node := TV.Items.GetFirstNode;
      if (node <> nil) then
        TV.Select(Node);
    end;
  end;
end;

procedure TTreeViewSCM.TVDblClick(Sender: TObject);
begin
  btnClose.Click;
end;

end.
