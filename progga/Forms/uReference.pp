unit uReference;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, DBGrids, StdCtrls, EditBtn, Menus, ActnList, LazUTF8,
  LCLType, Grids, DbCtrls, uSelect, uFunctions;

type
  { TfrmReference }
  TfrmReference = class(TForm)
    pmLine_3 : TMenuItem;
    pmIDColumn : TMenuItem;
    pnlFilters : TPanel;
    grpSearch : TGroupBox;
    edtSearch : TEditButton;
    cgAccess : TCheckGroup;
    pnlButtons : TPanel;
    btnAdd : TBitBtn;
    btnUpd : TBitBtn;
    btnClose : TBitBtn;
    qTyp_Zemli : TSQLQuery;
    qReference : TSQLQuery;
    dsReference : TDataSource;
    ActionList : TActionList;
    actAdd : TAction;
    actUpd : TAction;
    tmrSearch : TTimer;
    dbgReferenceerence : TDBGrid;
    dbgReference : TDBGrid;
    actShow : TAction;
    actHide : TAction;
    actSelect : TAction;
    btnSelect : TBitBtn;
    pUpmReference : TPopupMenu;
    pmAdd : TMenuItem;
    pmUpd : TMenuItem;
    pmLine_1 : TMenuItem;
    pmHide : TMenuItem;
    pmShow : TMenuItem;
    pmLine_2 : TMenuItem;
    pmSelect : TMenuItem;
    qOblast : TSQLQuery;
    qRaion : TSQLQuery;
    qSelo : TSQLQuery;
    qTyp_Vulytsi : TSQLQuery;
    qTyp_Sporidnenosti : TSQLQuery;
    qHromadianstvo : TSQLQuery;
    qVulytsia : TSQLQuery;
    sqlShow : TSQLQuery;
    grpRegion : TGroupBox;
    lcbRegion : TDBLookupComboBox;
    dsRegion : TDataSource;
    qRegion : TSQLQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure pmIDColumnClick(Sender : TObject);
    procedure pUpmReferencePopup(Sender: TObject);
    procedure edtSearchUTF8KeyPress(Sender: TObject;    Var UTF8Key : TUTF8Char);
    procedure dbgReferenceUTF8KeyPress(Sender: TObject; Var UTF8Key : TUTF8Char);
    Procedure dbgReferenceKeyDown(Sender : TObject;     Var Key : Word;	Shift : TShiftState);
    procedure dbgReferenceTitleClick(Column : TColumn);
    procedure dbgReferenceDblClick(Sender: TObject);
    procedure actAddUpdExecute(Sender: TObject);
    procedure actShowHideExecute(Sender: TObject);
    procedure actSelectExecute(Sender: TObject);
    procedure edtSearchButtonClick(Sender : TObject);
    procedure cgAccessItemClick(Sender : TObject; Index : Integer);
    procedure OnFilterChange(Sender: TObject);
    procedure tmrSearchTimer(Sender: TObject);
    procedure qReferenceAfterOpen(DataSet: TDataSet);
  private
    { private declarations }
    MenuHandle : HMenu;
    PChanged : PBoolean;
    is_Start, is_Select, is_SelectByName,
    is_OBLAST, is_RAION, is_SELO, is_VULYTSIA,
    is_TYP_VULYTSI, is_HROMADIANSTVO, is_TYP_SPORIDNENOSTI,
    is_TYP_ZEMLI : Boolean;
    TableName : String;
    FreeParam, Current_Value : Variant;
    procedure AddColumn(AFieldName, ACaption : String; AWidth, ASizePriority : Word);
    procedure InitTableAndQueries();
    procedure RefreshQuery(ALocate_ID : Integer);
  public
    { public declarations }
    Select : TSelect;
    constructor CreateInt         (Sender: TComponent; ACaption, ATableName : String; AFreeParam                 : Variant);
    constructor CreateSelect      (Sender: TComponent; ACaption, ATableName : String; AFreeParam, ACurrent_Value : Variant; var AChanged : Boolean);
    constructor CreateSelectByName(Sender: TComponent; ACaption, ATableName : String; AFreeParam, ACurrent_Value : Variant; var AChanged : Boolean);
  end;

var
  frmReference : TfrmReference;

implementation

uses
  udm, uMain, uReference_Edit;

{$R *.lfm}

{ TfrmReference }

procedure TfrmReference.AddColumn(AFieldName, ACaption : String; AWidth, ASizePriority : Word);
var
  Column : TColumn;
begin
  Column := dbgReference.Columns.Add;

  Column.FieldName       := AFieldName;
  Column.Title.Alignment := taCenter;
  Column.Title.Caption   := ACaption;
  Column.Width           := AWidth;
  Column.SizePriority    := ASizePriority;
end;

procedure TfrmReference.InitTableAndQueries();
var
  Column : TColumn;
begin
  grpRegion.Visible := False;

  is_OBLAST            := False;
  is_RAION             := False;
  is_SELO              := False;
  is_VULYTSIA          := False;
  is_TYP_VULYTSI       := False;
  is_HROMADIANSTVO     := False;
  is_TYP_SPORIDNENOSTI := False;
  is_TYP_ZEMLI         := False;

  if TableName = UTF8Trim(UTF8UpperString('OBLAST'))            then is_OBLAST            := True else
  if TableName = UTF8Trim(UTF8UpperString('RAION'))             then is_RAION             := True else
  if TableName = UTF8Trim(UTF8UpperString('SELO'))              then is_SELO              := True else
  if TableName = UTF8Trim(UTF8UpperString('TYP_VULYTSI'))       then is_TYP_VULYTSI       := True else
  if TableName = UTF8Trim(UTF8UpperString('VULYTSIA'))          then is_VULYTSIA          := True else
  if TableName = UTF8Trim(UTF8UpperString('TYP_SPORIDNENOSTI')) then is_TYP_SPORIDNENOSTI := True else
  if TableName = UTF8Trim(UTF8UpperString('HROMADIANSTVO'))     then is_HROMADIANSTVO     := True else
  if TableName = UTF8Trim(UTF8UpperString('TYP_ZEMLI'))         then is_TYP_ZEMLI         := True else Close;

  qReference.SQL.Clear;

  if is_OBLAST            then qReference.SQL := qOblast.SQL            else
  if is_RAION             then qReference.SQL := qRaion.SQL             else
  if is_SELO              then qReference.SQL := qSelo.SQL              else
  if is_TYP_VULYTSI       then qReference.SQL := qTyp_Vulytsi.SQL       else
  if is_VULYTSIA          then qReference.SQL := qVulytsia .SQL         else
  if is_TYP_SPORIDNENOSTI then qReference.SQL := qTyp_Sporidnenosti.SQL else
  if is_HROMADIANSTVO     then qReference.SQL := qHromadianstvo.SQL     else
  if is_TYP_ZEMLI         then qReference.SQL := qTyp_Zemli.SQL         else Close;

  if is_RAION or
     is_SELO
  then
  begin
    grpRegion.Visible := True;

    qRegion.Open;
    qRegion.Last;
    qRegion.First;

    if (FreeParam  = Null) or
       (FreeParam <= REFERENCE_NONE)
    then lcbRegion.KeyValue := REFERENCE_ALL
    else lcbRegion.KeyValue := FreeParam;
  end;

  if is_RAION then
  begin
    AddColumn('NAZVA_OBLASTI', 'Область', 100, 1);
  end
  else
  if is_SELO  then
  begin
    AddColumn('NAZVA_OBLASTI', 'Область', 100, 1);
    AddColumn('NAZVA_RAIONU',  'Район',   100, 1);
  end
  else
  if is_TYP_VULYTSI then
  begin
    AddColumn('SKOROCHENA_NAZVA', 'Скорочення', 50, 0);
  end
  else
  if is_VULYTSIA then
  begin
    AddColumn('SKOROCHENA_NAZVA', 'Тип', 50, 0);

    Column := dm.GridColumnByName(dbgReference, 'NAZVA');

    if Column <> nil then
    begin
      Column.Index := 1;
    end;
  end;

  Column := nil;

  if is_OBLAST or
     is_RAION
  then Column := dm.GridColumnByName(dbgReference, 'ID')
  else Column := dm.GridColumnByName(dbgReference, 'NAZVA');

  if Column <> nil then
  begin
    Column.Tag              := COLUMN_SORT_UP;
    Column.Title.ImageIndex := COLUMN_SORT_UP;
  end;
end;

procedure TfrmReference.RefreshQuery(ALocate_ID : Integer);
begin
  qReference.DisableControls;
  qReference.Close;
  qReference.Open;
  qReference.Last;
  qReference.First;
  qReference.Locate('ID', ALocate_ID, []);
  qReference.EnableControls;

  try
    if Showing then dbgReference.SetFocus;
  except
    //
  end;
end;

constructor TfrmReference.CreateInt(Sender: TComponent; ACaption, ATableName : String; AFreeParam : Variant);
begin
  inherited Create(Sender);

  Caption       := ACaption;
  TableName     := UTF8Trim(UTF8UpperString(ATableName));
  FreeParam     := AFreeParam;
  Current_Value := Null;

  is_Select       := False;
  is_SelectByName := False;
end;

constructor TfrmReference.CreateSelect(Sender: TComponent; ACaption, ATableName : String; AFreeParam, ACurrent_Value : Variant;
                                       var AChanged : boolean);
begin
  inherited Create(Sender);

  PChanged  := @AChanged;
  PChanged^ := False;

  Caption       := ACaption;
  TableName     := UTF8Trim(UTF8UpperString(ATableName));
  FreeParam     := AFreeParam;
  Current_Value := ACurrent_Value;

  is_Select       := True;
  is_SelectByName := False;
end;

constructor TfrmReference.CreateSelectByName(Sender: TComponent; ACaption, ATableName : String; AFreeParam, ACurrent_Value : Variant;
                                             var AChanged : boolean);
begin
  inherited Create(Sender);

  PChanged  := @AChanged;
  PChanged^ := False;

  Caption       := ACaption;
  TableName     := UTF8Trim(UTF8UpperString(ATableName));
  FreeParam     := AFreeParam;
  Current_Value := ACurrent_Value;

  is_Select       := True;
  is_SelectByName := True;
end;

procedure TfrmReference.FormCreate(Sender: TObject);
begin
  frmMain.AddItemToMainMenu(Caption, MenuHandle, Handle);

  is_Start := False;

  Select := nil;

  InitTableAndQueries();

  actSelect.Visible := is_Select;
  pmLine_1.Visible  := is_Select;

  cgAccess.Checked[0] := not is_Select;
  cgAccess.Checked[1] := True;

  // Формуємо запит на зміну видимості записів
  sqlShow.SQL.Clear;
  sqlShow.SQL.Add('update ' + TableName     );
  sqlShow.SQL.Add('set                     ');
  sqlShow.SQL.Add('    DOSTUP = :prm_Dostup');
  sqlShow.SQL.Add('where                   ');
  sqlShow.SQL.Add('    ID     = :prm_ID    ');

  is_Start := True;

  tmrSearchTimer(nil);

  if Current_Value <> Null then
  begin
    if is_SelectByName
    then qReference.Locate('NAZVA', Current_Value, [])
    else qReference.Locate('ID',    Current_Value, []);
	 End;
end;

procedure TfrmReference.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
begin
  is_Start := False;

  if is_RAION or
     is_SELO
  then qRegion.Close;

  qReference.Close;

  frmMain.DeleteItemFromMainMenu(MenuHandle);

  CloseAction := caFree;
end;

procedure TfrmReference.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmReference.pmIDColumnClick(Sender : TObject);
  function ColumnByName(AGrid : TDBGrid; const AName : String) : TColumn;
  var
    i : Integer;
  begin
    Result := Nil;

    for i := 0 to AGrid.Columns.Count - 1 do
    begin
      if     (AGrid.Columns[i].Field <> Nil)
         and (CompareText(AGrid.Columns[i].FieldName, AName) = 0)
      then
      begin
        Result := AGrid.Columns[i];

        Exit;
      end;
    end;
  end;
begin
  ColumnByName(dbgReference, 'ID').Visible := pmIDColumn.Checked;
end;

procedure TfrmReference.pUpmReferencePopup(Sender: TObject);
var
  is_Show : Boolean;
begin
  actShow.Visible := False;
  actHide.Visible := False;

  if qReference.RecordCount = 0 then Exit;

  is_Show := IntToBool(qReference.FieldByName('DOSTUP').AsInteger);

  actShow.Visible := not is_Show;
  actHide.Visible :=     is_Show;
end;

procedure TfrmReference.edtSearchUTF8KeyPress(Sender: TObject; Var UTF8Key : TUTF8Char);
begin
  If UTF8Key = #13 Then
  begin
    UTF8Key := #0;

    tmrSearchTimer(nil);
  end;
end;

procedure TfrmReference.dbgReferenceUTF8KeyPress(Sender: TObject; Var UTF8Key : TUTF8Char);
begin
  If not ((UTF8Key > ' ') or
          (UTF8Key =  #8) or
          (UTF8Key = #13) or
          (UTF8Key = #22) or
          (UTF8Key = #46)) Then Exit;

  If (UTF8Key > ' ') or (UTF8Key = #8) Then
  begin
    if UTF8Key = #8
    then edtSearch.Text := UTF8Copy(edtSearch.Text, 1, UTF8Length(edtSearch.Text) - 1)
    else edtSearch.Text := edtSearch.Text + UTF8Key;

    edtSearch.SetFocus;
    edtSearch.SelStart := UTF8Length(edtSearch.Text);
  end;
end;

Procedure TfrmReference.dbgReferenceKeyDown(Sender : TObject; Var Key : Word;	Shift : TShiftState);
Begin
  if qReference.RecordCount = 0 then Exit;

  if (Key = VK_RETURN) then
  begin
    Key := 0;

    dbgReferenceDblClick(Sender);
  end;
end;

procedure TfrmReference.dbgReferenceTitleClick(Column : TColumn);
begin
  if Column = nil
  then dm.GridSort(dbgReference, 'ID', 'ID')
  else dm.GridSort(dbgReference, 'ID', Column.FieldName);
end;

procedure TfrmReference.dbgReferenceDblClick(Sender: TObject);
begin
  if qReference.RecordCount = 0 then
  begin
    btnAdd.Click;
  end
  else
  begin
    if btnSelect.Visible
    then btnSelect.Click
    else btnUpd.Click;
  end;
end;

procedure TfrmReference.actAddUpdExecute(Sender: TObject);
var
  DataChanged : Boolean;
  PK : Integer;
begin
  DataChanged := False;

  if Sender = actAdd then PK := -1                                     else
  if Sender = actUpd then PK := qReference.FieldByName('ID').AsInteger else Exit;

  if Sender = actUpd then
  begin
    if not (PK > 0) then
    begin
      Application.MessageBox('Службовий запис!' + LineEnding +
                             'Корекція заборонена!',
                              PChar(Caption),
                              MB_OK + MB_ICONWARNING);

      Exit;
    end;
  end;

  with TfrmReference_Edit.CreateInt(Self, TableName, FreeParam, PK, DataChanged) do
  begin
    if Sender = actAdd then Caption := Self.Caption + ': Новий запис' else
    if Sender = actUpd then Caption := Self.Caption + ': Корекція';

    ShowModal;
    Free;
  end;

  if DataChanged then
  begin
    if is_Select then PChanged^ := True;

    RefreshQuery(PK);
  end;
end;

procedure TfrmReference.actShowHideExecute(Sender: TObject);
var
  Locate_ID : Integer;
begin
  Locate_ID := dbgReference.DataSource.DataSet.FieldByName('ID').AsInteger;

  if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

  sqlShow.ParamByName('prm_Dostup').Value := 1 - dbgReference.DataSource.DataSet.FieldByName('DOSTUP').AsInteger;
  sqlShow.ParamByName('prm_ID').Value     :=     dbgReference.DataSource.DataSet.FieldByName('ID').AsInteger;

  if (not cgAccess.Checked[0]) or
     (not cgAccess.Checked[1])
  then
  begin
    qReference.DisableControls;

    qReference.Next;

    if qReference.EOF then qReference.Prior;

    Locate_ID := dbgReference.DataSource.DataSet.FieldByName('ID').AsInteger;

    qReference.EnableControls;
  end;

  try
    sqlShow.ExecSQL;

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    if is_Select then PChanged^ := True;

    RefreshQuery(Locate_ID);
  except
    on E : Exception do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Модуль: ' + E.ClassName    + LineEnding +
                                                                 LineEnding +
                                   'Виникла наступна помилка:' + LineEnding +
                                    E.Message                  + LineEnding +
                                                                 LineEnding +
                                   'Зміни не збережено! '      + LineEnding +
                                   'Закрийте вікно і повторіть спробу.'),
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    end;
  end;
end;

procedure TfrmReference.actSelectExecute(Sender: TObject);
var
  i : Integer;
begin
  If Select <> nil Then
  begin
    Select.Code := qReference.FieldByName('ID').AsInteger;
    Select.Name := qReference.FieldByName('NAZVA').AsString;

    if is_VULYTSIA then
    begin
      Select.Param := qReference.FieldByName('ID_TYP_VULYTSI').AsInteger;
		End;

    if (dgMultiSelect in dbgReference.Options) then
    begin
      For i := 0 to dbgReference.SelectedRows.Count - 1 do
      begin
        dbgReference.DataSource.DataSet.GotoBookmark(Pointer(dbgReference.SelectedRows.Items[i]));

        Select.SelectedCode := Select.SelectedCode + qReference.FieldByName('ID').AsString    + ',';
        Select.SelectedName := Select.SelectedName + qReference.FieldByName('NAZVA').AsString + ',';
      end;
    end;
  end;

  Close;
end;

procedure TfrmReference.edtSearchButtonClick(Sender : TObject);
begin
  edtSearch.Clear;
end;

procedure TfrmReference.cgAccessItemClick(Sender : TObject; Index : Integer);
begin
  OnFilterChange(Sender);
end;

procedure TfrmReference.OnFilterChange(Sender: TObject);
begin
  if not is_Start then Exit;

  tmrSearch.Enabled := False;
  tmrSearch.Enabled := True;
end;

procedure TfrmReference.tmrSearchTimer(Sender: TObject);
var
  Locate_ID : Integer;
  ConditionText, tS : String;
begin
  tmrSearch.Enabled := False;

  if qReference.RecordCount > 0
  then Locate_ID := qReference.FieldByName('ID').AsInteger
  else Locate_ID := 0;

  qReference.Close;

  qReference.SQL[qReference.SQL.Count - 5] := ''; // Видимысть
  qReference.SQL[qReference.SQL.Count - 4] := ''; // Область
  qReference.SQL[qReference.SQL.Count - 3] := ''; // Не використовується
  qReference.SQL[qReference.SQL.Count - 2] := ''; // Пошук

  tS := '';

  if cgAccess.Checked[0] then tS := tS + ' or (DOSTUP = 0)';
  if cgAccess.Checked[1] then tS := tS + ' or (DOSTUP = 1)';

  qReference.SQL[qReference.SQL.Count - 5] := '  and ((1 = 0)' + tS + ')';

  if is_RAION or
     is_SELO
  then
  begin
    if lcbRegion.KeyValue >= 0 then
    begin
      qReference.SQL[qReference.SQL.Count - 4] := '  and (ID_OBLAST = :prm_Oblast)';

      qReference.ParamByName('prm_Oblast').Value := lcbRegion.KeyValue;
    end;
  end;

  if FullStr(edtSearch.Text) then
  begin
    ConditionText := '''%' + UTF8StringReplace(edtSearch.Text, '''', '''''', [rfReplaceAll]) + '%''';

    qReference.SQL[qReference.SQL.Count - 2] := '  and (NAZVA like ' + ConditionText + ')';
  end;

  RefreshQuery(Locate_ID);
end;

procedure TfrmReference.qReferenceAfterOpen(DataSet: TDataSet);
var
  is_Record : Boolean;
begin
  is_Record := (DataSet.RecordCount > 0);

  actUpd.Enabled    := is_Record;
  actSelect.Enabled := is_Record;

  actHide.Visible := is_Record;
  actShow.Visible := is_Record;
end;

end.

