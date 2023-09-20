unit uGeneral_Data;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, EditBtn, DbCtrls, DBGrids, ActnList, Menus,
  LazUTF8, LCLType, uFunctions;

type
  { TfrmGeneral_Data }
  TfrmGeneral_Data = class(TForm)
    actAdd : TAction;
    actHide : TAction;
    ActionList : TActionList;
    actShow : TAction;
    actUpd : TAction;
    btnAdd : TBitBtn;
    btnClose : TBitBtn;
    btnUpd : TBitBtn;
    cgAccess : TCheckGroup;
    dbgGeneral_Data : TDBGrid;
    dsGeneral_Data : TDataSource;
    edtSearch : TEditButton;
    grpSearch : TGroupBox;
    pmAdd : TMenuItem;
    pmHide : TMenuItem;
    pmIDColumn : TMenuItem;
    pmShow : TMenuItem;
    pmLine_1 : TMenuItem;
    pmLine_2 : TMenuItem;
    pmUpd : TMenuItem;
    pnlButtons : TPanel;
    pnlFilters : TPanel;
    pUpmGeneral_Data : TPopupMenu;
    qGeneral_Data : TSQLQuery;
    sqlShow : TSQLQuery;
    tmrSearch : TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure pmIDColumnClick(Sender : TObject);
    procedure pUpmGeneral_DataPopup(Sender: TObject);
    procedure edtSearchUTF8KeyPress(Sender: TObject;       Var UTF8Key : TUTF8Char);
    procedure dbgGeneral_DataUTF8KeyPress(Sender: TObject; Var UTF8Key : TUTF8Char);
    Procedure dbgGeneral_DataKeyDown(Sender : TObject;     Var Key : Word;	Shift : TShiftState);
    procedure dbgGeneral_DataTitleClick(Column : TColumn);
    procedure dbgGeneral_DataDblClick(Sender: TObject);
    procedure actAddUpdExecute(Sender: TObject);
    procedure actShowHideExecute(Sender: TObject);
    procedure edtSearchButtonClick(Sender : TObject);
    procedure cgAccessItemClick(Sender : TObject; Index : Integer);
    procedure OnFilterChange(Sender: TObject);
    procedure tmrSearchTimer(Sender: TObject);
    procedure qGeneral_DataAfterOpen(DataSet: TDataSet);
  private
    { private declarations }
    MenuHandle : HMenu;
    PChanged : PBoolean;
    is_Start : Boolean;
    procedure RefreshQuery(ALocate_ID : Integer);
  public
    { public declarations }
    constructor CreateInt(Sender: TComponent; var AChanged : Boolean);
  end;

var
  frmGeneral_Data : TfrmGeneral_Data;

implementation

uses
  udm, uMain, uGeneral_Data_Edit;

{$R *.lfm}

procedure TfrmGeneral_Data.RefreshQuery(ALocate_ID : Integer);
begin
  qGeneral_Data.DisableControls;
  qGeneral_Data.Close;
  qGeneral_Data.Open;
  qGeneral_Data.Last;
  qGeneral_Data.First;
  qGeneral_Data.Locate('ID', ALocate_ID, []);
  qGeneral_Data.EnableControls;

  try
    if Showing then dbgGeneral_Data.SetFocus;
  except
    //
  end;
end;

constructor TfrmGeneral_Data.CreateInt(Sender: TComponent;  var AChanged : Boolean);
begin
  inherited Create(Sender);

  PChanged  := @AChanged;
  PChanged^ := False;
end;

procedure TfrmGeneral_Data.FormCreate(Sender: TObject);
begin
  frmMain.AddItemToMainMenu(Caption, MenuHandle, Handle);

  is_Start := False;

  cgAccess.Checked[0] := False;
  cgAccess.Checked[1] := True;

  is_Start := True;

  tmrSearchTimer(nil);
end;

procedure TfrmGeneral_Data.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
begin
  is_Start := False;

  qGeneral_Data.Close;

  frmMain.DeleteItemFromMainMenu(MenuHandle);

  CloseAction := caFree;
end;

procedure TfrmGeneral_Data.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGeneral_Data.pmIDColumnClick(Sender : TObject);
begin
  dm.SetGridColumnVisible(dbgGeneral_Data, 'ID', pmIDColumn.Checked);
end;

procedure TfrmGeneral_Data.pUpmGeneral_DataPopup(Sender: TObject);
var
  is_Show : Boolean;
begin
  actShow.Visible := False;
  actHide.Visible := False;

  if qGeneral_Data.RecordCount = 0 then Exit;

  is_Show := IntToBool(qGeneral_Data.FieldByName('DOSTUP').AsInteger);

  actShow.Visible := not is_Show;
  actHide.Visible :=     is_Show;
end;

procedure TfrmGeneral_Data.edtSearchUTF8KeyPress(Sender: TObject; Var UTF8Key : TUTF8Char);
begin
  If UTF8Key = #13 Then
  begin
    UTF8Key := #0;

    tmrSearchTimer(nil);
  end;
end;

procedure TfrmGeneral_Data.dbgGeneral_DataUTF8KeyPress(Sender: TObject; Var UTF8Key : TUTF8Char);
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

Procedure TfrmGeneral_Data.dbgGeneral_DataKeyDown(Sender : TObject; Var Key : Word;	Shift : TShiftState);
Begin
  if qGeneral_Data.RecordCount = 0 then Exit;

  if (Key = VK_RETURN) then
  begin
    Key := 0;

    dbgGeneral_DataDblClick(Sender);
  end;
end;

procedure TfrmGeneral_Data.dbgGeneral_DataTitleClick(Column : TColumn);
begin
  if Column = nil
  then dm.GridSort(dbgGeneral_Data, 'ID', 'ID')
  else dm.GridSort(dbgGeneral_Data, 'ID', Column.FieldName);
end;

procedure TfrmGeneral_Data.dbgGeneral_DataDblClick(Sender: TObject);
begin
  if qGeneral_Data.RecordCount = 0
  then btnAdd.Click
  else btnUpd.Click;
end;

procedure TfrmGeneral_Data.actAddUpdExecute(Sender: TObject);
var
  DataChanged : Boolean;
  PK : Integer;
begin
  DataChanged := False;

  if Sender = actAdd then PK := -1                                        else
  if Sender = actUpd then PK := qGeneral_Data.FieldByName('ID').AsInteger else Exit;

  with TfrmGeneral_Data_Edit.CreateInt(Self, PK, DataChanged) do
  begin
    ShowModal;
    Free;
  end;

  if DataChanged then
  begin
    if PChanged <> nil then PChanged^ := True;

    RefreshQuery(PK);
  end;
end;

procedure TfrmGeneral_Data.actShowHideExecute(Sender: TObject);
var
  Locate_ID : Integer;
begin
  Locate_ID := dbgGeneral_Data.DataSource.DataSet.FieldByName('ID').AsInteger;

  if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

  sqlShow.ParamByName('prm_Dostup').Value := 1 - dbgGeneral_Data.DataSource.DataSet.FieldByName('DOSTUP').AsInteger;
  sqlShow.ParamByName('prm_ID').Value     :=     dbgGeneral_Data.DataSource.DataSet.FieldByName('ID').AsInteger;

  if (not cgAccess.Checked[0]) or
     (not cgAccess.Checked[1])
  then
  begin
    qGeneral_Data.DisableControls;

    qGeneral_Data.Next;

    if qGeneral_Data.EOF then qGeneral_Data.Prior;

    Locate_ID := dbgGeneral_Data.DataSource.DataSet.FieldByName('ID').AsInteger;

    qGeneral_Data.EnableControls;
  end;

  try
    sqlShow.ExecSQL;

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    if PChanged <> nil then PChanged^ := True;

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

procedure TfrmGeneral_Data.edtSearchButtonClick(Sender : TObject);
begin
  edtSearch.Clear;
end;

procedure TfrmGeneral_Data.cgAccessItemClick(Sender : TObject; Index : Integer);
begin
  OnFilterChange(Sender);
end;

procedure TfrmGeneral_Data.OnFilterChange(Sender: TObject);
begin
  if not is_Start then Exit;

  tmrSearch.Enabled := False;
  tmrSearch.Enabled := True;
end;

procedure TfrmGeneral_Data.tmrSearchTimer(Sender: TObject);
var
  Locate_ID : Integer;
  ConditionText, tS : String;
begin
  tmrSearch.Enabled := False;

  if qGeneral_Data.RecordCount > 0
  then Locate_ID := qGeneral_Data.FieldByName('ID').AsInteger
  else Locate_ID := 0;

  qGeneral_Data.Close;

  qGeneral_Data.SQL[qGeneral_Data.SQL.Count - 3] := ''; // Видимысть
  qGeneral_Data.SQL[qGeneral_Data.SQL.Count - 2] := ''; // Пошук

  tS := '';

  if cgAccess.Checked[0] then tS := tS + ' or (d.DOSTUP = 0)';
  if cgAccess.Checked[1] then tS := tS + ' or (d.DOSTUP = 1)';

  qGeneral_Data.SQL[qGeneral_Data.SQL.Count - 3] := '  and ((1 = 0)' + tS + ')';

  if FullStr(edtSearch.Text) then
  begin
    ConditionText := '''%' + UTF8StringReplace(edtSearch.Text, '''', '''''', [rfReplaceAll]) + '%''';

    qGeneral_Data.SQL[qGeneral_Data.SQL.Count - 2] := '  and (d.ZNACHENNIA like ' + ConditionText + ')';
  end;

  RefreshQuery(Locate_ID);
end;

procedure TfrmGeneral_Data.qGeneral_DataAfterOpen(DataSet: TDataSet);
var
  is_Record : Boolean;
begin
  is_Record := (DataSet.RecordCount > 0);

  actUpd.Enabled  := is_Record;
  actHide.Visible := is_Record;
  actShow.Visible := is_Record;
end;

end.

