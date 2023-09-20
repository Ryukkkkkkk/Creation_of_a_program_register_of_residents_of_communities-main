unit uHouse;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, DBGrids, StdCtrls, EditBtn, Menus, ActnList, DbCtrls,
  LCLType, LazUTF8, uSelect, uFunctions;

type
  { TfrmHouse }
  TfrmHouse = class(TForm)
    actDel: TAction;
    pmLine_1 : TMenuItem;
    pmDel : TMenuItem;
    pnlButtons : TPanel;
    btnAdd : TBitBtn;
    btnUpd : TBitBtn;
    btnClose : TBitBtn;
    dbgHouse : TDBGrid;
    pnlFilters : TPanel;
    grpSearch : TGroupBox;
    edtSearch : TEditButton;
    qHouse : TSQLQuery;
    dsHouse : TDataSource;
    sqlHouse: TSQLQuery;
    tmrSearch : TTimer;
    btnSelect : TBitBtn;
    ActionList : TActionList;
    actAdd : TAction;
    actUpd : TAction;
    actSelect : TAction;
    pUpmHouse : TPopupMenu;
    pmAdd : TMenuItem;
    pmUpd : TMenuItem;
    pmLine_2 : TMenuItem;
    pmSelect : TMenuItem;
    grpVillage : TGroupBox;
    lcbVillage : TDBLookupComboBox;
    qVillage : TSQLQuery;
    dsVillage : TDataSource;
    procedure actDelExecute(Sender: TObject);
    Procedure FormCreate(Sender : TObject);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure btnCloseClick(Sender : TObject);
    Procedure actAddUpdExecute(Sender : TObject);
    Procedure actSelectExecute(Sender: TObject);
    Procedure OnFilterChange(Sender : TObject);
    Procedure tmrSearchTimer(Sender : TObject);
    Procedure edtSearchButtonClick(Sender : TObject);
    Procedure edtSearchKeyPress(Sender : TObject; var Key : char);
    Procedure dbgHouseDblClick(Sender : TObject);
    Procedure dbgHouseTitleClick(Column : TColumn);
    Procedure dbgHouseUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
    Procedure qHouseAfterOpen(DataSet: TDataSet);
  private
    { private declarations }
    PChanged : PBoolean;
    is_Start : Boolean;
    Current_Value : Variant;
    procedure RefreshQuery(ALocate_ID : Integer);
  public
    { public declarations }
    tmpHouse : TSelect;
    constructor CreateSelect(Sender: TComponent; vCurrent_Value : Variant;
                             var bChanged : Boolean);
  end;

var
  frmHouse : TfrmHouse;

implementation

uses
  udm, uHouse_Edit;

{$R *.lfm}

procedure TfrmHouse.RefreshQuery(ALocate_ID : Integer);
begin
  qHouse.DisableControls;
  qHouse.Close;
  qHouse.Open;
  qHouse.Last;
  qHouse.First;
  qHouse.Locate('ID', ALocate_ID, []);
  qHouse.EnableControls;

  try
    if Showing then dbgHouse.SetFocus;
  except
    //
  end;
end;

constructor TfrmHouse.CreateSelect(Sender: TComponent; vCurrent_Value : Variant;
                                       var bChanged : Boolean);
begin
  inherited Create(Sender);

  PChanged  := @bChanged;
  PChanged^ := False;

  Current_Value := vCurrent_Value;
end;

procedure TfrmHouse.FormCreate(Sender: TObject);
begin
  is_Start := False;

  tmpHouse := nil;

  qVillage.Open;
  qVillage.Last;
  qVillage.First;

  lcbVillage.KeyValue := -1;

  is_Start := True;

  tmrSearchTimer(nil);

  if Current_Value <> Null then qHouse.Locate('ID', Current_Value, []);
end;

procedure TfrmHouse.actDelExecute(Sender: TObject);
var
  LHouse_ID : Integer;

  procedure ExecSQL(AText : String);
  begin
    sqlHouse.Clear;
    sqlHouse.SQL.Text := AText;
    sqlHouse.ParamByName('prm_House_ID').Value := LHouse_ID;
    sqlHouse.ExecSQL;
  end;
begin
  if Application.MessageBox(PChar('Увага!'                                           + LineEnding +
                                  'Видаленння господарства призведе до втрати всіх ' + LineEnding +
                                  'пов''язаних з ним даних: '                        + LineEnding +
                                  ' - мешканців; '                                   + LineEnding +
                                  ' - спорідненості ; '                              + LineEnding +
                                  ' - інші. '                                        + LineEnding +
                                                                                      LineEnding +
                                  'Продовжити?'),
                            PChar(Caption),
                            MB_YESNOCANCEL + MB_ICONQUESTION) = IDNO
  then Exit;

  LHouse_ID:= qHouse.FieldByName('ID').AsInteger;

  try
    if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

    ExecSQL('delete from SPORIDNENIST where ID_HOSPODARSTVO = :prm_House_ID');
    ExecSQL('delete from MESHKANTSI   where ID_HOSPODARSTVO = :prm_House_ID');
    ExecSQL('delete from HOSPODARSTVO where ID              = :prm_House_ID');

    qHouse.Close;
    qHouse.Open;

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;
  Except
    on E:Exception do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Господарство не видалене!' + LineEnding +
                                                                 LineEnding +
                                   'Модуль: ' + E.ClassName    + LineEnding +
                                                                 LineEnding +
                                   'Виникла наступна помилка:' + LineEnding +
                                    E.Message                  + LineEnding +
                                                                 LineEnding +
                                   'Закрийте вікно і повторіть спробу.'),
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    End;
  End;
end;

procedure TfrmHouse.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
begin
  is_Start := False;

  qVillage.Close;
  qHouse.Close;

  CloseAction := caFree;
end;

procedure TfrmHouse.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmHouse.actAddUpdExecute(Sender: TObject);
var
  DataChanged : Boolean;
  PK : Integer;
begin
  DataChanged := False;

  if Sender = actAdd then PK := -1                                 else
  if Sender = actUpd then PK := qHouse.FieldByName('ID').AsInteger else Exit;

  with TfrmHouse_Edit.CreateInt(Self, PK, DataChanged) do
  begin
    if Sender = actAdd then Caption := Self.Caption + ': Новий запис' else
    if Sender = actUpd then Caption := Self.Caption + ': Корекція';

    tmpHouse := TSelect.Create();

    ShowModal;
    Free;
  end;

  if DataChanged then
  begin
    PChanged^ := True;

    RefreshQuery(PK);
  end;
end;

procedure TfrmHouse.actSelectExecute(Sender: TObject);
var
  i : Integer;
begin
  If tmpHouse <> nil Then
  begin
    tmpHouse.Code := qHouse.FieldByName('ID').AsInteger;
    tmpHouse.Name := qHouse.FieldByName('NAZVA').AsString;

    if (dgMultiSelect in dbgHouse.Options) then
    begin
      For i := 0 to dbgHouse.SelectedRows.Count - 1 do
      begin
        dbgHouse.DataSource.DataSet.GotoBookmark(Pointer(dbgHouse.SelectedRows.Items[i]));

        tmpHouse.SelectedCode := tmpHouse.SelectedCode + qHouse.FieldByName('ID').AsString    + ',';
        tmpHouse.SelectedName := tmpHouse.SelectedName + qHouse.FieldByName('NAZVA').AsString + ',';
      end;
    end;
  end;

  Close;
end;

procedure TfrmHouse.OnFilterChange(Sender: TObject);
begin
  if not is_Start then Exit;

  tmrSearch.Enabled := False;
  tmrSearch.Enabled := True;
end;

procedure TfrmHouse.tmrSearchTimer(Sender: TObject);
var
  Locate_ID : Integer;
  ConditionText : String;
begin
  tmrSearch.Enabled := False;

  if qHouse.RecordCount > 0
  then Locate_ID := qHouse.FieldByName('ID').AsInteger
  else Locate_ID := 0;

  qHouse.Close;

  qHouse.SQL[qHouse.SQL.Count - 3] := ''; // Село
  qHouse.SQL[qHouse.SQL.Count - 2] := ''; // Пошук

  if lcbVillage.KeyValue >= 0 then
  begin
    qHouse.SQL[qHouse.SQL.Count - 3] := '  and (ID_SELO = :prm_Selo)';

    qHouse.ParamByName('prm_Selo').Value := lcbVillage.KeyValue;
  end;

  if FullStr(edtSearch.Text) then
  begin
    ConditionText := '''%' + UTF8StringReplace(edtSearch.Text, '''', '''''', [rfReplaceAll]) + '%''';

    qHouse.SQL[qHouse.SQL.Count - 2] := '  and ((NAZVA  like ' + ConditionText + ') or ' +
                                               '(ADRESA like ' + ConditionText + '))';
  end;

  RefreshQuery(Locate_ID);
end;

procedure TfrmHouse.edtSearchButtonClick(Sender : TObject);
begin
  edtSearch.Clear;
end;

procedure TfrmHouse.edtSearchKeyPress(Sender: TObject; Var Key : Char);
begin
  If Key = #13 Then
  begin
    Key := #0;

    tmrSearchTimer(nil);
  end;
end;

procedure TfrmHouse.dbgHouseUTF8KeyPress(Sender: TObject; Var UTF8Key : TUTF8Char);
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

  if qHouse.RecordCount = 0 then Exit;

  if (UTF8Key = #13) then
  begin
    UTF8Key := #0;

    if btnSelect.Visible
    then btnSelect.Click
    else btnUpd.Click;
  end;
end;

procedure TfrmHouse.dbgHouseDblClick(Sender: TObject);
begin
  if qHouse.RecordCount = 0 then
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

procedure TfrmHouse.dbgHouseTitleClick(Column : TColumn);
begin
  if Column = nil
  then dm.GridSort(dbgHouse, 'ID', 'ID')
  else dm.GridSort(dbgHouse, 'ID', Column.FieldName);
end;

procedure TfrmHouse.qHouseAfterOpen(DataSet: TDataSet);
var
  is_Record : Boolean;
begin
  is_Record := (DataSet.RecordCount > 0);

  actUpd.Enabled    := is_Record;
  actSelect.Enabled := is_Record;
end;

end.

