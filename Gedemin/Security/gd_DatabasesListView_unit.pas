unit gd_DatabasesListView_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ComCtrls, TB2Dock, TB2Toolbar, ExtCtrls, TB2Item,
  TB2ExtItems, gd_DatabasesList_unit;

type
  Tgd_DatabasesListView = class(TForm)
    al: TActionList;
    actOk: TAction;
    pnlBottom: TPanel;
    pnlWorkArea: TPanel;
    lv: TListView;
    pnlButtons: TPanel;
    btnOk: TButton;
    actCreate: TAction;
    actEdit: TAction;
    actDelete: TAction;
    TBDock: TTBDock;
    tb: TTBToolbar;
    tbiCreate: TTBItem;
    tbiEdit: TTBItem;
    tbiDelete: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBControlItem1: TTBControlItem;
    Label1: TLabel;
    actImport: TAction;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem1: TTBItem;
    Button1: TButton;
    actCancel: TAction;
    edFilter: TEdit;
    TBControlItem2: TTBControlItem;
    actBackup: TAction;
    actRestore: TAction;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    actCopy: TAction;
    TBItem4: TTBItem;
    procedure actOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCreateExecute(Sender: TObject);
    procedure actImportUpdate(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure lvDblClick(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actBackupExecute(Sender: TObject);
    procedure actRestoreExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);

  private
    FChosen: Tgd_DatabaseItem;

    function AddListItem(DI: Tgd_DatabaseItem): TListItem;

  public
    procedure SyncControls;

    property Chosen: Tgd_DatabaseItem read FChosen;
  end;

var
  gd_DatabasesListView: Tgd_DatabasesListView;

implementation

{$R *.DFM}

uses
  jclStrings, gd_frmBackup_unit, gd_frmRestore_unit;

procedure Tgd_DatabasesListView.actOkExecute(Sender: TObject);
begin
  if lv.Selected <> nil then
    FChosen := gd_DatabasesList.FindByName(lv.Selected.Caption)
  else
    FChosen := nil;  
  ModalResult := mrOk;
end;

procedure Tgd_DatabasesListView.SyncControls;
var
  I: Integer;
  DI: Tgd_DatabaseItem;
  LI: TListItem;
  PrevSelected: String;
begin
  lv.Items.BeginUpdate;
  try
    if lv.Selected <> nil then
      PrevSelected := lv.Selected.Caption
    else
      PrevSelected := '';

    lv.Items.Clear;

    for I := 0 to gd_DatabasesList.Count - 1 do
    begin
      DI := gd_DatabasesList.Items[I] as Tgd_DatabaseItem;

      if (edFilter.Text = '') or (StrIPos(edFilter.Text,
        DI.Name + DI.Server + DI.FileName) > 0) then
      begin
        LI := AddListItem(DI);
        LI.Selected := ((PrevSelected > '') and (LI.Caption = PrevSelected)) or
          ((PrevSelected = '') and DI.Selected);
      end;
    end;

    if edFilter.Text = '' then
    begin
      lv.Color := clWindow;
      edFilter.Color := clWindow;
    end else
    begin
      lv.Color := clInfoBK;
      edFilter.Color := clInfoBk;
    end;

    if lv.Selected <> nil then
      lv.Selected.MakeVisible(False);
  finally
    lv.Items.EndUpdate;
  end;
end;

procedure Tgd_DatabasesListView.FormCreate(Sender: TObject);
begin
  SyncControls;
end;

procedure Tgd_DatabasesListView.actCreateExecute(Sender: TObject);
var
  DI: Tgd_DatabaseItem;
begin
  DI := gd_DatabasesList.Add as Tgd_DatabaseItem;
  try
    if DI.EditInDialog then
      AddListItem(DI).Selected := True
    else
      DI.Free;
  except
    DI.Free;
    raise;
  end;
end;

procedure Tgd_DatabasesListView.actImportUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := gd_DatabasesList <> nil;
end;

procedure Tgd_DatabasesListView.actImportExecute(Sender: TObject);
begin
  gd_DatabasesList.ReadFromRegistry;
  SyncControls;
end;

procedure Tgd_DatabasesListView.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgd_DatabasesListView.edFilterChange(Sender: TObject);
begin
  SyncControls;
end;

procedure Tgd_DatabasesListView.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (lv.Items.Count = 0) or (lv.Selected <> nil);
end;

procedure Tgd_DatabasesListView.lvDblClick(Sender: TObject);
begin
  actEdit.Execute;
end;

procedure Tgd_DatabasesListView.actEditUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gd_DatabasesList <> nil)
    and (lv.Selected <> nil);
end;

procedure Tgd_DatabasesListView.actEditExecute(Sender: TObject);
var
  DI: Tgd_DatabaseItem;
begin
  if lv.Selected <> nil then
  begin
    DI := gd_DatabasesList.FindByName(lv.Selected.Caption);
    if DI <> nil then
      if DI.EditInDialog then
        SyncControls;
  end;
end;

procedure Tgd_DatabasesListView.actDeleteUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gd_DatabasesList <> nil)
    and (lv.Selected <> nil);
end;

procedure Tgd_DatabasesListView.actDeleteExecute(Sender: TObject);
var
  DI: Tgd_DatabaseItem;
  LI: TListItem;
begin
  if lv.Selected <> nil then
  begin
    DI := gd_DatabasesList.FindByName(lv.Selected.Caption);
    if DI <> nil then
    begin
      DI.Free;
      LI := lv.GetNextItem(lv.Selected, sdBelow, [isNone]);
      if LI = nil then
        LI := lv.GetNextItem(lv.Selected, sdAbove, [isNone]);
      lv.Selected.Free;
      if LI <> nil then
        LI.Selected := True;
    end;
  end;
end;

procedure Tgd_DatabasesListView.actBackupExecute(Sender: TObject);
var
  DI: Tgd_DatabaseItem;
  BF: Tgd_frmBackup;
begin
  BF := Tgd_frmBackup.CreateAndAssign(Application) as Tgd_frmBackup;
  if lv.Selected <> nil then
  begin
    DI := gd_DatabasesList.FindByName(lv.Selected.Caption);
    if DI <> nil then
    begin
      BF.edServer.Text := DI.Server;
      BF.edDatabase.Text := DI.FileName;
    end;
  end;
  BF.Show;
end;

procedure Tgd_DatabasesListView.actRestoreExecute(Sender: TObject);
var
  DI: Tgd_DatabaseItem;
  RF: Tgd_frmRestore;
begin
  RF := Tgd_frmRestore.CreateAndAssign(Application) as Tgd_frmRestore;
  if lv.Selected <> nil then
  begin
    DI := gd_DatabasesList.FindByName(lv.Selected.Caption);
    if DI <> nil then
    begin
      RF.edServer.Text := DI.Server;
      RF.edDatabase.Text := DI.FileName;
    end;
  end;
  RF.Show;
end;

procedure Tgd_DatabasesListView.actCopyUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gd_DatabasesList <> nil)
    and (lv.Selected <> nil);
end;

procedure Tgd_DatabasesListView.actCopyExecute(Sender: TObject);
var
  DI, DICopy: Tgd_DatabaseItem;
begin
  if lv.Selected <> nil then
  begin
    DI := gd_DatabasesList.FindByName(lv.Selected.Caption);
    if DI <> nil then
    begin
      DICopy := gd_DatabasesList.Add as Tgd_DatabaseItem;
      DICopy.Assign(DI);
      if DICopy.EditInDialog then
        AddListItem(DICopy).Selected := True
      else
        DICopy.Free;
    end;
  end;
end;

function Tgd_DatabasesListView.AddListItem(
  DI: Tgd_DatabaseItem): TListItem;
begin
  Assert(DI <> nil);
  Result := lv.Items.Add;
  Result.Caption := DI.Name;
  Result.SubItems.Add(DI.Server);
  Result.SubItems.Add(DI.FileName);
end;

end.