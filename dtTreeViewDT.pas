unit dtTreeViewDT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.StorageBin, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  dtUtils, dmDTData, Datasnap.DBClient, Datasnap.Provider, dtuSetting;

type

  TTVDTData = class(TObject)
  private
    { IDENTIFIER :
      node level 0 : SessionID,
      node level 1 : EventID,
      node level 2 : HeatID.
    }
    FID: integer;
    { stores - EventNum or HeatNum }
    FValue: integer;

    // Is filename REQUIRED?
    // Only node level 2 stores a filename.
    FFileName: string;
  public
    constructor Create(AID: integer; AValue: integer);
    property ID: Integer read FID write FID;
    property FileName: string read FFileName write FFileName;
  end;

type
  TTreeViewDT = class(TForm)
    btnCancel: TButton;
    btnClose: TButton;
    pnlFooter: TPanel;
    TV: TTreeView;
    procedure btnCancelClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LoadFromSettings; // JSON Program Settings
    procedure LoadSettings; // JSON Program Settings
    procedure LocateTVSessionID(ASessionID: integer);
    procedure LocateTVEventID(AEventID: integer);
    procedure LocateTVHeatID(AHeatID: integer);
    procedure TVDblClick(Sender: TObject);


  private
    { Private declarations }
    FSelectedSessionID: integer;
    FSelectedEventID: integer;
    FSelectedHeatID: integer;
    FSelectedFileName: string;
    fPrecedence: dtPrecedence;

    // Snapshot of the current position in the DTData tables.
    // NOTE: lane is ignored.
    // Assignment occurs in Populate tree.
    storeSessID, storeEvID, storeHtID: integer;

    procedure FreeTreeViewData;
    procedure PopulateTree;
    function CueTVtoSessionID(ASessionID: integer): boolean;
    function CueTVtoEventID(AEventID: integer): boolean;
    function CueTVtoHeatID(AHeatID: integer): boolean;

  public
    procedure Prepare(ASessionID, AEventID, AHeatID: integer);
    property SelectedSessionID: integer read FSelectedSessionID;
    property SelectedEventID: integer read FSelectedEventID;
    property SelectedHeatID: integer read FSelectedHeatID;


  end;

var
  TreeViewDT: TTreeViewDT;

implementation

{$R *.dfm}


{ TTVDTData }

constructor TTVDTData.Create(AID: integer; AValue: integer);
begin
    FID := AID; // SessionID, EventID or HeatID.
    FValue := AValue; // zero, EventNum or HeatNum.
end;

{ TTreeViewDT }

procedure TTreeViewDT.btnCancelClick(Sender: TObject);
begin
    FSelectedSessionID := 0;
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    FSelectedFileName := '';
    ModalResult := mrCancel;
end;

procedure TTreeViewDT.btnCloseClick(Sender: TObject);
var
node, nodeSess, nodeEv: TTreeNode;
obj : TTVDTData;
begin
  FSelectedSessionID := 0;
  FSelectedEventID := 0;
  FSelectedHeatID := 0;

  node := TV.Selected;
  if (node = nil) then
  begin
    ModalResult := mrCancel;
    exit;
  end;

  case node.level of
  0: { ROOT NODE - LEVEL 0 - SESSION}
    begin
      obj := node.Data;
      if (obj <> nil) then
      begin
        // S e s s i o n  I D .
        // EventID=0 and HeatID=0.
        FSelectedSessionID := obj.FID;
      end;
    end;

  1: { LEVEL 1 NODE - EVENT}
     begin
      obj := node.Data;
      if (obj <> nil) then
      begin
        // E v e n t  I D .
        // HeatID=0.
        FSelectedEventID := obj.FID;
        if (node.Parent <> nil) then
        begin
          nodeSess := TTreeNode(node.Parent);
          obj := nodeSess.Data;
          if (obj <> nil) then
          begin
            // S e s s i o n  I D .
            FSelectedSessionID := obj.FID;
          end;
        end;
      end;
    end;

  2: { LEVEL 2 NODE - HEAT}
     begin
      obj := node.Data;
      if (obj <> nil) then
      begin
        // H e a t  I D .
        FSelectedHeatID := obj.FID;
        if (node.Parent <> nil) then
        begin
          nodeEv := TTreeNode(node.Parent);
          obj := nodeEv.Data;
          if (obj <> nil) then
          begin
            // E v e n t  I D .
            FSelectedEventID := obj.FID;
            if (nodeEv.Parent <> nil) then
            begin
              nodeSess := TTreeNode(nodeEv.Parent);
              obj := nodeSess.Data;
              if (obj <> nil) then
              begin
                // S e s s i o n  I D .
                FSelectedSessionID := obj.FID;
              end;
            end;
          end;
        end;
      end;
    end
  end;

  ModalResult := mrOk;
end;

function TTreeViewDT.CueTVtoEventID(AEventID: integer): boolean;
var
  NodeSess, NodeEv: TTreeNode;
  obj: TTVDTData;
begin
  Result := False; // Initialize the result as False
  NodeSess := TV.Items.GetFirstNode; // Start with the first level 0 node

  while (NodeSess <> nil) do
  begin
    NodeEv := NodeSess.GetFirstChild; // Get the first child of the current level 0 node
    while (NodeEv <> nil) do
    begin
      obj := TTVDTData(NodeEv.Data);
      if (obj <> nil) then
      begin
        if (obj.FID = AEventID) then
        begin
          // Expand the parent node if it's collapsed
          if not NodeSess.Expanded then
            NodeSess.Expanded := True;
          TV.Selected := NodeEv;
          NodeEv.Focused := true;
          Result := True; // Found the node with the matching event number
          Exit; // Exit the function immediately since we've found the match
        end;
      end;
      NodeEv := NodeEv.GetNextSibling; // Move to the next sibling (level 1 node)
    end;
    NodeSess := NodeSess.GetNextSibling; // Move to the next level 0 node
  end;
end;

function TTreeViewDT.CueTVtoHeatID(AHeatID: integer): boolean;
var
  NodeSess, NodeEv, NodeHt: TTreeNode;
  obj: TTVDTData;
begin
  Result := False; // Initialize the result as False
  NodeSess := TV.Items.GetFirstNode; // Start with the first level 0 node

  // Iterate over all level 0 nodes (sessions)
  while (NodeSess <> nil) do
  begin
    NodeEv := NodeSess.GetFirstChild; // Get the first child of the current level 0 node (events)

    // Iterate over all level 1 nodes (events) under the current level 0 node (session)
    while (NodeEv <> nil) do
    begin
      NodeHt := NodeEv.GetFirstChild; // Get the first child of the current level 1 node (heats)

      // Iterate over all level 2 nodes (heats) under the current level 1 node (event)
      while (NodeHt <> nil) do
      begin
        obj := TTVDTData(NodeHt.Data); // Cast the Data property to TTVDTData
        if (obj <> nil) then // Check if the node data matches the target heat number
        begin
          if (obj.FID = AHeatID) then
          begin
            // Expand root branch.
            if not NodeSess.Expanded then
              NodeSess.Expanded := True;
            // Expand the parent node if it's collapsed
            if not NodeEv.Expanded then
              NodeEv.Expanded := True;
            TV.Selected := NodeHt;
            NodeHt.Focused := true;
            Result := True; // Set the result to True if a matching node is found
            Exit; // Exit the function immediately since we've found the match
          end;
        end;
        NodeHt := NodeHt.GetNextSibling; // Move to the next sibling (level 2 node)
      end;
      NodeEv := NodeEv.GetNextSibling; // Move to the next sibling (level 1 node)
    end;
    NodeSess := NodeSess.GetNextSibling; // Move to the next sibling (level 0 node)
  end;
end;

function TTreeViewDT.CueTVtoSessionID(ASessionID: integer): boolean;
var
  NodeSess: TTreeNode;
  obj: TTVDTData;
begin
  Result := False; // Initialize the result as False
  NodeSess := TV.Items.GetFirstNode;
  while (NodeSess <> nil) do
  begin
    obj := TTVDTData(NodeSess.Data);
    if (obj <> nil) then
    begin
      if (obj.FID = ASessionID)  then
      begin
        Result := True; // Found the node with the matching session number
        Break;
      end;
    end;
    NodeSess := NodeSess.GetNextSibling; // Iterate only over level 0 nodes
  end;
end;

procedure TTreeViewDT.FormCreate(Sender: TObject);
begin
    FSelectedSessionID := 0;
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    FSelectedFileName := '';;
    // remove all design-time layout items.
    TV.Items.Clear;
    // get the dtPrecedence from the JSON settings file.
    LoadFromSettings;
end;

procedure TTreeViewDT.FormDestroy(Sender: TObject);
begin
  FreeTreeViewData;
  TV.Items.Clear;
end;

procedure TTreeViewDT.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    FSelectedSessionID := 0;
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    fSelectedFileName := '';
    ModalResult := mrCancel;
  end;
end;

procedure TTreeViewDT.FreeTreeViewData;
var
ident: TTVDTData;
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

procedure TTreeViewDT.LoadFromSettings;
begin
  if not FileExists(Settings.GetDefaultSettingsFilename()) then
  begin
    ForceDirectories(Settings.GetSettingsFolder());
    Settings.SaveToFile();
  end;
  Settings.LoadFromFile();
  LoadSettings();
end;

procedure TTreeViewDT.LoadSettings;
begin
  fPrecedence := Settings.DolphinPrecedence;
end;

procedure TTreeViewDT.LocateTVEventID(AEventID: integer);
var
  NodeSess, NodeEv: TTreeNode;
  obj : TTVDTData;
  found : boolean;
begin
  found := false;
  NodeSess := TV.Items.GetFirstNode;
  while NodeSess <> nil do
  begin
    NodeEv := NodeSess.GetFirstChild;
    while NodeEv <> nil do
    begin
      obj := NodeEv.Data;
      if (obj <> nil) and (obj.FID = AEventID) then
      begin
        // Expand NodeSess if it's collapsed
        if not NodeSess.Expanded then
          NodeSess.Expanded := True;
        TV.Selected := NodeEv;
        NodeEv.Focused := true;
        break;
      end;
      NodeEv := NodeEv.GetNextSibling;
    end;
    if Found  then break;
    NodeSess := NodeSess.GetNextSibling;
  end;
end;

procedure TTreeViewDT.LocateTVHeatID(AHeatID: integer);
var
  NodeSess, NodeEv, NodeHt: TTreeNode;
  obj : TTVDTData;
  found : boolean;
begin
  found := false;
  NodeSess := TV.Items.GetFirstNode;
  while NodeSess <> nil do
  begin
    NodeEv := NodeSess.GetFirstChild;
    while NodeEv <> nil do
    begin
      NodeHt := NodeEv.GetFirstChild;
      while (NodeHt <> nil) do
      begin
        obj := NodeHt.Data;
        if (obj <> nil) and (obj.FID = AHeatID) then
        begin
          // Expand the sess node, if it's collapsed.
          if not NodeSess.Expanded then
            NodeSess.Expanded := True;
          // Expand the ev node, if it's collapsed.
          if not NodeEv.Expanded then
            NodeEv.Expanded := True;

          TV.Selected := NodeHt;
          NodeHt.Focused := true;
          found := true;
          break;
        end;
        NodeEv := NodeHt.GetNextSibling;
      end;
      if Found  then break;
      NodeEv := NodeEv.GetNextSibling;
    end;
    if Found  then break;
    NodeSess := NodeSess.GetNextSibling;
  end;
end;

procedure TTreeViewDT.LocateTVSessionID(ASessionID: integer);
var
  NodeSess, NodeEv: TTreeNode;
  obj : TTVDTData;
begin
  NodeSess := TV.Items.GetFirstNode;
  while NodeSess <> nil do
  begin
    obj := NodeSess.Data;
    if (obj <> nil) and (obj.FID = ASessionID) then
    begin
      NodeEv := NodeSess.GetFirstChild;
      if (NodeEv <> nil) then
      begin
        // Expand the parent NodeSess if it's collapsed.
        if not NodeEv.Parent.Expanded then
          NodeEv.Parent.Expanded := True;
        // Focus on first heat in event.
        TV.Selected := NodeEv;
        NodeEv.Focused := true;
        break;
      end;
    end;
    NodeSess := NodeSess.GetNextSibling;
  end;
end;

procedure TTreeViewDT.PopulateTree;
var
  nodeSess, nodeEv, nodeHt: TTreeNode;
  s, sev, sht: string;
  i, idsess, idev, idht: integer;
  ident: TTVDTData;
begin
  { p o p u l a t e   t h e   T r e e V i e w . . .
    TABLES HAVE MASTER-DETAIL RELATIONSHIPS ENABLED.
  }
  DTData.tblDTEntrant.DisableControls;
  DTData.tblDTHeat.DisableControls;
  DTData.tblDTEvent.DisableControls;
  DTData.tblDTSession.DisableControls;

  storeSessID := DTData.tblDTSession.FieldByName('SessionID').AsInteger;
  storeEvID := DTData.tblDTEvent.FieldByName('EventID').AsInteger;
  storeHtID := DTData.tblDTHeat.FieldByName('HeatID').AsInteger;

  // R O O T   N O D E    -   LEVEL 0 - S E S S I O N   . . .
  DTData.tblDTSession.First;
  while not DTData.tblDTSession.Eof do
  begin
    s := DTData.tblDTSession.FieldByName('Caption').AsString;
    if fPrecedence = dtPrecFileName then
      i := DTData.tblDTSession.FieldByName('fnSessionNum').AsInteger
    else
      i := DTData.tblDTSession.FieldByName('SessionNum').AsInteger;
    idsess := DTData.tblDTSession.FieldByName('SessionID').AsInteger;

    { CREATE NodeSess : EventID, EventNum.}
    ident := TTVDTData.Create(idsess, i);
      // object to hold event and even number.
    // Level 0 .
    NodeSess := TV.Items.AddObject(nil, s, ident); // assign data ptr.

    // ------------------------------------------------------------
    // Level 1  -   E V E N T S  ...  SESSION CHILD NODES.
    DTData.tblDTEvent.ApplyMaster;
//    DTData.tblDTEvent.Refresh;
    DTData.tblDTEvent.First;
    while not DTData.tblDTEvent.Eof do
    begin
      sev := DTData.tblDTEvent.FieldByName('Caption').AsString;
      if fPrecedence = dtPrecFileName then
        i := DTData.tblDTEvent.FieldByName('fnEventNum').AsInteger
      else
        i := DTData.tblDTEvent.FieldByName('EventNum').AsInteger;
      idEv := DTData.tblDTEvent.FieldByName('EventID').AsInteger;

      { CREATE nodeEv : EventID, EventNum.}
      ident := TTVDTData.Create(idEv, i);
      nodeEv := TV.Items.AddChildObject(NodeSess, sev, ident);

      // ICON ORDERED heat numbers ..
      if (i > 9) then
        nodeEv.ImageIndex := 28
      else
        // heat number icons 1 thru 9.
        nodeEv.ImageIndex := i + 28;
      nodeEv.SelectedIndex := nodeEv.ImageIndex;

      // ------------------------------------------------------------
      // Level 2  -   H E A T S  ..   EVENT CHILD NODES.
      {
      MANATORY HERE - ELSE IT DOESN'T WORK!
      Use the ApplyMaster method to synchronize this detail dataset with the
      current master record.  This method is useful, when DisableControls was
      called for the master dataset or when scrolling is disabled by
      MasterLink.DisableScroll.
      }
      DTData.tblDTHeat.ApplyMaster;
//      DTData.tblDTHeat.Refresh;
      DTData.tblDTHeat.First;
      while not DTData.tblDTHeat.Eof do
      begin
        sht := DTData.tblDTHeat.FieldByName('Caption').AsString;
        if fPrecedence = dtPrecFileName then
          i := DTData.tblDTHeat.FieldByName('fnHeatNum').AsInteger
        else
          i := DTData.tblDTHeat.FieldByName('HeatNum').AsInteger;
        idHt := DTData.tblDTHeat.FieldByName('HeatID').AsInteger;

        { CREATE nodeHt : HeatID, HeatNum.}
        ident := TTVDTData.Create(idht, i);
        nodeHt := TV.Items.AddChildObject(NodeEv, sht, ident);

        // ICON ORDERED heat numbers ..
        if (i > 9) then
          nodeHt.ImageIndex := 0
        else
          // heat number icons 1 thru 9.
          nodeHt.ImageIndex := i + 14;
        nodeHt.SelectedIndex := nodeHt.ImageIndex;
        DTData.tblDTHeat.Next;
      end;
      DTData.tblDTEvent.Next;
    end;
    // ------------------------------------------------------------
    DTData.tblDTSession.Next;
  end;

  // Master-Detail enabled - order is important ...
  // Restore Record positions for DT tables.
  if DTData.LocateDTSessionID(storeSessID) then
  begin
    DTData.tblDTEvent.ApplyMaster;
    if DTData.LocateDTEventID(storeEvID) then
    begin
      DTData.tblDTHeat.ApplyMaster;
      DTData.LocateDTHeatID(storeHtID);
    end;
  end;

  DTData.tblDTSession.EnableControls;
  DTData.tblDTEvent.EnableControls;
  DTData.tblDTHeat.EnableControls;
  DTData.tblDTEntrant.EnableControls;

end;

procedure TTreeViewDT.Prepare(ASessionID, AEventID, AHeatID: integer);
var
  node: TTreeNode;
  SearchOptions: TLocateOptions;
begin
  if not Assigned(DTData) then exit;
  if not DTData.SCMDataIsActive then exit;
  SearchOptions := [];
  // File the tree view with nodes deom the Dolphin Timing data tables.
  PopulateTree;
  // Attempt to cue-to-node
  if AHeatID > 0 then
    CueTVtoHeatID(AHeatID)
  else if AEventID > 0 then
    CueTVtoEventID(AEventID)
  else if ASessionID > 0 then
    CueTVtoSessionID(ASessionID)
  else
  begin
    node := TV.Items.GetFirstNode;
    if (node <> nil) then
      TV.Select(Node);
  end;
end;

procedure TTreeViewDT.TVDblClick(Sender: TObject);
begin
  btnClose.Click;
end;

end.
