unit dlgTreeViewData;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.StorageBin, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uAppUtils, dmAppData, Datasnap.DBClient, Datasnap.Provider, tdSetting;

type

  TTVData = class(TObject)
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
    property ID: integer read FID write FID;
    property FileName: string read FFileName write FFileName;
  end;

type
  TTreeViewData = class(TForm)
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
    fPrecedence: dmAppData.dtPrecedence;

    // Snapshot of the current position in the Application Data tables.
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
  TreeViewData: TTreeViewData;

implementation

{$R *.dfm}

{ TTVData }

constructor TTVData.Create(AID: integer; AValue: integer);
begin
  FID := AID; // SessionID, EventID or HeatID.
  FValue := AValue; // zero, EventNum or HeatNum.
end;

{ TTreeViewDT }

procedure TTreeViewData.btnCancelClick(Sender: TObject);
begin
  FSelectedSessionID := 0;
  FSelectedEventID := 0;
  FSelectedHeatID := 0;
  FSelectedFileName := '';
  ModalResult := mrCancel;
end;

procedure TTreeViewData.btnCloseClick(Sender: TObject);
var
  node, nodeSess, nodeEv: TTreeNode;
  obj: TTVData;
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
    0: { ROOT NODE - LEVEL 0 - SESSION }
      begin
        obj := node.Data;
        if (obj <> nil) then
        begin
          // S e s s i o n  I D .
          // EventID=0 and HeatID=0.
          FSelectedSessionID := obj.FID;
        end;
      end;

    1: { LEVEL 1 NODE - EVENT }
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

    2: { LEVEL 2 NODE - HEAT }
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

function TTreeViewData.CueTVtoEventID(AEventID: integer): boolean;
var
  nodeSess, nodeEv: TTreeNode;
  obj: TTVData;
begin
  Result := False; // Initialize the result as False
  nodeSess := TV.Items.GetFirstNode; // Start with the first level 0 node

  while (nodeSess <> nil) do
  begin
    nodeEv := nodeSess.GetFirstChild;
    // Get the first child of the current level 0 node
    while (nodeEv <> nil) do
    begin
      obj := TTVData(nodeEv.Data);
      if (obj <> nil) then
      begin
        if (obj.FID = AEventID) then
        begin
          // Expand the parent node if it's collapsed
          if not nodeSess.Expanded then
            nodeSess.Expanded := True;
          TV.Selected := nodeEv;
          nodeEv.Focused := True;
          Result := True; // Found the node with the matching event number
          exit; // Exit the function immediately since we've found the match
        end;
      end;
      nodeEv := nodeEv.GetNextSibling;
      // Move to the next sibling (level 1 node)
    end;
    nodeSess := nodeSess.GetNextSibling; // Move to the next level 0 node
  end;
end;

function TTreeViewData.CueTVtoHeatID(AHeatID: integer): boolean;
var
  nodeSess, nodeEv, NodeHt: TTreeNode;
  obj: TTVData;
begin
  Result := False; // Initialize the result as False
  nodeSess := TV.Items.GetFirstNode; // Start with the first level 0 node

  // Iterate over all level 0 nodes (sessions)
  while (nodeSess <> nil) do
  begin
    nodeEv := nodeSess.GetFirstChild;
    // Get the first child of the current level 0 node (events)

    // Iterate over all level 1 nodes (events) under the current level 0 node (session)
    while (nodeEv <> nil) do
    begin
      NodeHt := nodeEv.GetFirstChild;
      // Get the first child of the current level 1 node (heats)

      // Iterate over all level 2 nodes (heats) under the current level 1 node (event)
      while (NodeHt <> nil) do
      begin
        obj := TTVData(NodeHt.Data); // Cast the Data property to TTVData
        if (obj <> nil) then
        // Check if the node data matches the target heat number
        begin
          if (obj.FID = AHeatID) then
          begin
            // Expand root branch.
            if not nodeSess.Expanded then
              nodeSess.Expanded := True;
            // Expand the parent node if it's collapsed
            if not nodeEv.Expanded then
              nodeEv.Expanded := True;
            TV.Selected := NodeHt;
            NodeHt.Focused := True;
            Result := True;
            // Set the result to True if a matching node is found
            exit; // Exit the function immediately since we've found the match
          end;
        end;
        NodeHt := NodeHt.GetNextSibling;
        // Move to the next sibling (level 2 node)
      end;
      nodeEv := nodeEv.GetNextSibling;
      // Move to the next sibling (level 1 node)
    end;
    nodeSess := nodeSess.GetNextSibling;
    // Move to the next sibling (level 0 node)
  end;
end;

function TTreeViewData.CueTVtoSessionID(ASessionID: integer): boolean;
var
  nodeSess: TTreeNode;
  obj: TTVData;
begin
  Result := False; // Initialize the result as False
  nodeSess := TV.Items.GetFirstNode;
  while (nodeSess <> nil) do
  begin
    obj := TTVData(nodeSess.Data);
    if (obj <> nil) then
    begin
      if (obj.FID = ASessionID) then
      begin
        Result := True; // Found the node with the matching session number
        Break;
      end;
    end;
    nodeSess := nodeSess.GetNextSibling; // Iterate only over level 0 nodes
  end;
end;

procedure TTreeViewData.FormCreate(Sender: TObject);
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

procedure TTreeViewData.FormDestroy(Sender: TObject);
begin
  FreeTreeViewData;
  TV.Items.Clear;
end;

procedure TTreeViewData.FormKeyDown(Sender: TObject; var Key: Word; Shift:
  TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    FSelectedSessionID := 0;
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    FSelectedFileName := '';
    ModalResult := mrCancel;
  end;
end;

procedure TTreeViewData.FreeTreeViewData;
var
  ident: TTVData;
  node: TTreeNode;
begin
  for node in TV.Items do
  begin
    ident := node.Data;
    if Assigned(ident) then
    begin
      ident.Free;
      node.Data := nil;
    end;
  end;
end;

procedure TTreeViewData.LoadFromSettings;
begin
  if not FileExists(Settings.GetDefaultSettingsFilename()) then
  begin
    ForceDirectories(Settings.GetSettingsFolder());
    Settings.SaveToFile();
  end;
  Settings.LoadFromFile();
  LoadSettings();
end;

procedure TTreeViewData.LoadSettings;
begin
  fPrecedence := Settings.Precedence;
end;

procedure TTreeViewData.LocateTVEventID(AEventID: integer);
var
  nodeSess, nodeEv: TTreeNode;
  obj: TTVData;
  found: boolean;
begin
  found := False;
  nodeSess := TV.Items.GetFirstNode;
  while nodeSess <> nil do
  begin
    nodeEv := nodeSess.GetFirstChild;
    while nodeEv <> nil do
    begin
      obj := nodeEv.Data;
      if (obj <> nil) and (obj.FID = AEventID) then
      begin
        // Expand NodeSess if it's collapsed
        if not nodeSess.Expanded then
          nodeSess.Expanded := True;
        TV.Selected := nodeEv;
        nodeEv.Focused := True;
        Break;
      end;
      nodeEv := nodeEv.GetNextSibling;
    end;
    if found then
      Break;
    nodeSess := nodeSess.GetNextSibling;
  end;
end;

procedure TTreeViewData.LocateTVHeatID(AHeatID: integer);
var
  nodeSess, nodeEv, NodeHt: TTreeNode;
  obj: TTVData;
  found: boolean;
begin
  found := False;
  nodeSess := TV.Items.GetFirstNode;
  while nodeSess <> nil do
  begin
    nodeEv := nodeSess.GetFirstChild;
    while nodeEv <> nil do
    begin
      NodeHt := nodeEv.GetFirstChild;
      while (NodeHt <> nil) do
      begin
        obj := NodeHt.Data;
        if (obj <> nil) and (obj.FID = AHeatID) then
        begin
          // Expand the sess node, if it's collapsed.
          if not nodeSess.Expanded then
            nodeSess.Expanded := True;
          // Expand the ev node, if it's collapsed.
          if not nodeEv.Expanded then
            nodeEv.Expanded := True;

          TV.Selected := NodeHt;
          NodeHt.Focused := True;
          found := True;
          Break;
        end;
        nodeEv := NodeHt.GetNextSibling;
      end;
      if found then
        Break;
      nodeEv := nodeEv.GetNextSibling;
    end;
    if found then
      Break;
    nodeSess := nodeSess.GetNextSibling;
  end;
end;

procedure TTreeViewData.LocateTVSessionID(ASessionID: integer);
var
  nodeSess, nodeEv: TTreeNode;
  obj: TTVData;
begin
  nodeSess := TV.Items.GetFirstNode;
  while nodeSess <> nil do
  begin
    obj := nodeSess.Data;
    if (obj <> nil) and (obj.FID = ASessionID) then
    begin
      nodeEv := nodeSess.GetFirstChild;
      if (nodeEv <> nil) then
      begin
        // Expand the parent NodeSess if it's collapsed.
        if not nodeEv.Parent.Expanded then
          nodeEv.Parent.Expanded := True;
        // Focus on first heat in event.
        TV.Selected := nodeEv;
        nodeEv.Focused := True;
        Break;
      end;
    end;
    nodeSess := nodeSess.GetNextSibling;
  end;
end;

procedure TTreeViewData.PopulateTree;
var
  nodeSess, nodeEv, NodeHt: TTreeNode;
  s, sev, sht: string;
  i, idsess, idev, idht: integer;
  ident: TTVData;
begin
  { p o p u l a t e   t h e   T r e e V i e w . . .
    TABLES HAVE MASTER-DETAIL RELATIONSHIPS ENABLED.
  }
  AppData.tblmLane.DisableControls;
  AppData.tblmHeat.DisableControls;
  AppData.tblmEvent.DisableControls;
  AppData.tblmSession.DisableControls;

  storeSessID := AppData.tblmSession.FieldByName('SessionID').AsInteger;
  storeEvID := AppData.tblmEvent.FieldByName('EventID').AsInteger;
  storeHtID := AppData.tblmHeat.FieldByName('HeatID').AsInteger;

  // R O O T   N O D E    -   LEVEL 0 - S E S S I O N   . . .
  AppData.tblmSession.First;
  while not AppData.tblmSession.Eof do
  begin
    s := AppData.tblmSession.FieldByName('Caption').AsString;
    if fPrecedence = dtPrecFileName then
      i := AppData.tblmSession.FieldByName('fnSessionNum').AsInteger
    else
      i := AppData.tblmSession.FieldByName('SessionNum').AsInteger;
    idsess := AppData.tblmSession.FieldByName('SessionID').AsInteger;

    { CREATE NodeSess : EventID, EventNum. }
    ident := TTVData.Create(idsess, i);
    // object to hold event and even number.
    // Level 0 .
    nodeSess := TV.Items.AddObject(nil, s, ident); // assign data ptr.

    // ------------------------------------------------------------
    // Level 1  -   E V E N T S  ...  SESSION CHILD NODES.
    AppData.tblmEvent.ApplyMaster;
    // AppData.tblmEvent.Refresh;
    AppData.tblmEvent.First;
    while not AppData.tblmEvent.Eof do
    begin
      sev := AppData.tblmEvent.FieldByName('Caption').AsString;
      if fPrecedence = dtPrecFileName then
        i := AppData.tblmEvent.FieldByName('fnEventNum').AsInteger
      else
        i := AppData.tblmEvent.FieldByName('EventNum').AsInteger;
      idev := AppData.tblmEvent.FieldByName('EventID').AsInteger;

      { CREATE nodeEv : EventID, EventNum. }
      ident := TTVData.Create(idev, i);
      nodeEv := TV.Items.AddChildObject(nodeSess, sev, ident);

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
      AppData.tblmHeat.ApplyMaster;
      // AppData.tblmHeat.Refresh;
      AppData.tblmHeat.First;
      while not AppData.tblmHeat.Eof do
      begin
        sht := AppData.tblmHeat.FieldByName('Caption').AsString;
        if fPrecedence = dtPrecFileName then
          i := AppData.tblmHeat.FieldByName('fnHeatNum').AsInteger
        else
          i := AppData.tblmHeat.FieldByName('HeatNum').AsInteger;
        idht := AppData.tblmHeat.FieldByName('HeatID').AsInteger;

        { CREATE nodeHt : HeatID, HeatNum. }
        ident := TTVData.Create(idht, i);
        NodeHt := TV.Items.AddChildObject(nodeEv, sht, ident);

        // ICON ORDERED heat numbers ..
        if (i > 9) then
          NodeHt.ImageIndex := 0
        else
          // heat number icons 1 thru 9.
          NodeHt.ImageIndex := i + 14;
        NodeHt.SelectedIndex := NodeHt.ImageIndex;
        AppData.tblmHeat.Next;
      end;
      AppData.tblmEvent.Next;
    end;
    // ------------------------------------------------------------
    AppData.tblmSession.Next;
  end;

  // Master-Detail enabled - order is important ...
  // Restore Record positions for DT tables.
  if AppData.LocateDTSessionID(storeSessID) then
  begin
    AppData.tblmEvent.ApplyMaster;
    if AppData.LocateDTEventID(storeEvID) then
    begin
      AppData.tblmHeat.ApplyMaster;
      AppData.LocateDTHeatID(storeHtID);
    end;
  end;

  AppData.tblmSession.EnableControls;
  AppData.tblmEvent.EnableControls;
  AppData.tblmHeat.EnableControls;
  AppData.tblmLane.EnableControls;

end;

procedure TTreeViewData.Prepare(ASessionID, AEventID, AHeatID: integer);
var
  node: TTreeNode;
  SearchOptions: TLocateOptions;
begin
  if not Assigned(AppData) then
    exit;
  if not AppData.SCMDataIsActive then
    exit;
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
      TV.Select(node);
  end;
end;

procedure TTreeViewData.TVDblClick(Sender: TObject);
begin
  btnClose.Click;
end;

end.
