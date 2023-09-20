Unit uPopulation;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, sqldb, db, FileUtil, RTTIGrids, Forms, Controls,
	Graphics, Dialogs, StdCtrls, ExtCtrls, EditBtn, DbCtrls, DBGrids, Buttons,
	Menus, ActnList, LCLType, LazUTF8, LR_Class, uSelect, uFunctions;

Type
  { TfrmPopulation }
  TfrmPopulation = Class(TForm)
		actAdd : TAction;
    actDel : TAction;
		actSelect : TAction;
		actUpd : TAction;
		ActionList : TActionList;
		BevelBottomLine : TBevel;
		btnAdd : TBitBtn;
		btnSelect : TBitBtn;
		btnUpd : TBitBtn;
		btnClose : TBitBtn;
    chkAlive: TCheckBox;
    chkFemale: TCheckBox;
    chkHomeless: TCheckBox;
    chkLifeless: TCheckBox;
    chkMale: TCheckBox;
    chkUnderaged: TCheckBox;
		dbgPopulation : TDBGrid;
		dsPopulation : TDataSource;
		dsLocation : TDataSource;
		edtAddress : TDBEdit;
		edtPhone : TDBEdit;
		edtYeDDR : TDBEdit;
		edtNotes : TDBEdit;
		edtPassportWhen : TDBEdit;
		edtIPN : TDBEdit;
		edtPassport : TDBEdit;
		edtPassportFrom : TDBEdit;
		edtSearch : TEditButton;
		grpInfo : TGroupBox;
		grpSearch : TGroupBox;
		grpLocation : TGroupBox;
		lblAddress : TLabel;
		lblPassportWhen : TLabel;
		lblPhone : TLabel;
		lblIPN : TLabel;
		lblNotes : TLabel;
		lblPassport : TLabel;
		lblPassportFrom : TLabel;
		lblYeDDR : TLabel;
		lcbLocation : TDBLookupComboBox;
    pmSelect : TMenuItem;
    pmLine_2 : TMenuItem;
    pmLine_1 : TMenuItem;
		pmDel : TMenuItem;
		pmAdd : TMenuItem;
		pmUpd : TMenuItem;
		pnlButtons : TPanel;
		pnlFilters : TPanel;
		pUpmPopulation : TPopupMenu;
		qGetHouseInfo : TSQLQuery;
    sqlPopulation : TSQLQuery;
		tmrSearch : TTimer;
    qLocation : TSQLQuery;
    qPopulation : TSQLQuery;
    Procedure FormCreate(Sender : TObject);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure btnCloseClick(Sender : TObject);
    Procedure edtSearchButtonClick(Sender : TObject);
    Procedure OnFilterChange(Sender : TObject);
    Procedure OnFilterDropDown(Sender : TObject);
    Procedure OnFilterCloseUp(Sender : TObject);
    Procedure OnFilterUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
		Procedure dbgPopulationKeyDown(Sender : TObject; Var Key : Word; Shift : TShiftState);
    Procedure dbgPopulationUTF8KeyPress(Sender : TObject;	Var UTF8Key : TUTF8Char);
    Procedure dbgPopulationDblClick(Sender : TObject);
    Procedure tmrSearchTimer(Sender : TObject);
		Procedure actAddUpdExecute(Sender : TObject);
    Procedure actDelExecute(Sender : TObject);
    Procedure actSelectExecute(Sender : TObject);
  Private
    { private declarations }
    MenuHandle : HMENU;
    PChanged : PBoolean;
    House : Integer;
    is_Start, is_Change, is_Select : Boolean;
  Public
    { public declarations }
    Select : TSelect;
    constructor SelectPerson(Sender : TComponent; iHouse : Integer; var bChanged : Boolean);
  End;

var
  frmPopulation : TfrmPopulation;

Implementation

uses
  udm, uMain, uPopulation_Edit;

{$R *.lfm}

{ TfrmPopulation }

constructor TfrmPopulation.SelectPerson(Sender : TComponent; iHouse : Integer; var bChanged : Boolean);
begin
  inherited Create(Sender);

  PChanged  := @bChanged;
  PChanged^ :=  False;

  House := iHouse;

  actSelect.Visible := True;
End;

Procedure TfrmPopulation.FormCreate(Sender : TObject);
Begin
  frmMain.AddItemToMainMenu(Self.Caption, MenuHandle, Self.Handle);

  is_Start  := False;
  is_Change := False;
  is_Select := actSelect.Visible;

  qLocation.Open;
  qLocation.Last;
  qLocation.First;

  if is_Select then
  begin
    qGetHouseInfo.Close;
    qGetHouseInfo.ParamByName('prm_ID').Value := House;
    qGetHouseInfo.Open;

    if qGetHouseInfo.RecordCount > 0 then
    begin
      //lcbLocation.KeyValue := qGetHouseInfo.FieldByName('ID_SELO').Value;
      lcbLocation.KeyValue := -1;
      edtSearch.Text       := qGetHouseInfo.FieldByName('ADRESA').AsString;
		End;

    qGetHouseInfo.Close;
	End
  else
  begin
	  lcbLocation.KeyValue := -1;
	End;

  is_Start := True;

  OnFilterChange(nil);
end;

Procedure TfrmPopulation.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
Begin
  is_Start := False;

  qLocation.Close;
  qPopulation.Close;

  frmMain.DeleteItemFromMainMenu(MenuHandle);

  CloseAction := caFree;
end;

Procedure TfrmPopulation.btnCloseClick(Sender : TObject);
Begin
  Close;
end;

Procedure TfrmPopulation.dbgPopulationKeyDown(Sender : TObject; Var Key : Word;	Shift : TShiftState);
Begin
  if qPopulation.RecordCount = 0 then Exit;

  if (Key = VK_RETURN) then
  begin
    Key := 0;

    if actSelect.Visible
    then btnSelect.Click
    else btnUpd.Click;
  end;
end;

Procedure TfrmPopulation.dbgPopulationUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
Begin
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

Procedure TfrmPopulation.dbgPopulationDblClick(Sender : TObject);
Begin
  if qPopulation.RecordCount = 0 then
  begin
    btnAdd.Click;

    Exit;
	End;

  if actSelect.Visible
  then btnSelect.Click
  else btnUpd.Click;
end;

Procedure TfrmPopulation.edtSearchButtonClick(Sender : TObject);
Begin
  edtSearch.Clear;
end;

Procedure TfrmPopulation.OnFilterChange(Sender : TObject);
Begin
  if not is_Start then Exit;

  is_Change := True;

  tmrSearch.Enabled := False;
  tmrSearch.Enabled := True;
end;

Procedure TfrmPopulation.OnFilterDropDown(Sender : TObject);
Begin
  if is_Change then tmrSearch.Enabled := False;
end;

Procedure TfrmPopulation.OnFilterCloseUp(Sender : TObject);
Begin
  if is_Change then tmrSearch.Enabled := True;
end;

Procedure TfrmPopulation.OnFilterUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
Begin
  case UTF8Key of
    #10 : begin
            UTF8Key := #0;

            tmrSearchTimer(nil);
		      end;
    #13 : begin
            UTF8Key := #0;

            SelectNext(ActiveControl, True, True);
		      End;
	End;
end;

Procedure TfrmPopulation.tmrSearchTimer(Sender : TObject);
var
  Locate_ID : Integer;
  tS, tA : String;
Begin
  tmrSearch.Enabled := False;

  if qPopulation.Active
  then Locate_ID := qPopulation.FieldByName('ID').AsInteger
  else Locate_ID := -1;

  qPopulation.Close;

  qPopulation.SQL[qPopulation.SQL.Count - 9] := ''; // Село
  qPopulation.SQL[qPopulation.SQL.Count - 8] := ''; // Стать
  qPopulation.SQL[qPopulation.SQL.Count - 7] := ''; // Живі або неживі
  qPopulation.SQL[qPopulation.SQL.Count - 6] := ''; // Неповнолітні
  qPopulation.SQL[qPopulation.SQL.Count - 5] := ''; // Без господарства
  qPopulation.SQL[qPopulation.SQL.Count - 4] := ''; //
  qPopulation.SQL[qPopulation.SQL.Count - 3] := ''; //
  qPopulation.SQL[qPopulation.SQL.Count - 2] := ''; // Пошук

  If lcbLocation.KeyValue >= 0 Then
  Begin
    qPopulation.SQL[qPopulation.SQL.Count - 9] := '  and (q.ID_SELO = :prm_Selo)';
    qPopulation.ParamByName('prm_Selo').AsString := lcbLocation.KeyValue;
  End;

  tS := '';
  tA := '';

  if chkMale.Checked     then tS := tS + ' or (q.STAT = 0)';
  if chkFemale.Checked   then tS := tS + ' or (q.STAT = 1)';
  if chkAlive.Checked    then tA := tA + ' or (q.DATA_SMERTI is     null)';
  if chkLifeless.Checked then tA := tA + ' or (q.DATA_SMERTI is not null)';

  qPopulation.SQL[qPopulation.SQL.Count - 8] := '  and ((1 = 0)' + tS + ')';
  qPopulation.SQL[qPopulation.SQL.Count - 7] := '  and ((1 = 0)' + tA + ')';

  if chkUnderaged.Checked then qPopulation.SQL[qPopulation.SQL.Count - 6] := '  and (q.AGE < 18)';
  if chkHomeless.Checked  then qPopulation.SQL[qPopulation.SQL.Count - 5] := '  and (q.ID_HOSPODARSTVO is null)';

  if FullStr(edtSearch.Text) then
  begin
    tS := '''%' + StringReplace(edtSearch.Text, '''', '''''', [rfReplaceAll]) + '%''';

    qPopulation.SQL[qPopulation.SQL.Count - 2] := '  and ((q.FULLNAME       like ' + tS + ') or ' +
                                                         '(q.VILLAGE        like ' + tS + ') or ' +
                                                         '(q.ADRESA         like ' + tS + ') or ' +
                                                         '(q.PASSPORT       like ' + tS + ') or ' +
                                                         '(q.IPN            like ' + tS + ') or ' +
                                                         '(q.YEDDR_NOMER    like ' + tS + ') or ' +
                                                         '(q.NOMER_TELEFONU like ' + tS + ') or ' +
                                                         '(q.PRYMITKY       like ' + tS + '))';
	End;

	qPopulation.Open;

  is_Change := False;

  qPopulation.Last;
  qPopulation.First;

  qPopulation.Locate('ID', Locate_ID, []);

  try
    dbgPopulation.SetFocus;
	Except
    //
	End;
end;

Procedure TfrmPopulation.actAddUpdExecute(Sender : TObject);
var
  ID : Integer;
  DataChanged : Boolean;
Begin
  DataChanged := False;

  if Sender = actAdd then ID := -1                                      else
  if Sender = actUpd then ID := qPopulation.FieldByName('ID').AsInteger else Exit;

  with TfrmPopulation_Edit.CreatePerson(Self, House, ID, DataChanged) do
  begin
    ShowModal;
    Free;
  end;

  if DataChanged then
  begin
    qPopulation.Open;
    qPopulation.Last;
    qPopulation.First;
    qPopulation.Locate('ID', ID, []);

    if is_Select then Boolean(PChanged^) := True;
  End;
end;

procedure TfrmPopulation.actDelExecute(Sender : TObject);
var
  LPerson_ID : Integer;

  procedure ExecSQL(AText : String);
  begin
    sqlPopulation.Clear;
    sqlPopulation.SQL.Text := AText;
    sqlPopulation.ParamByName('prm_Person_ID').Value := LPerson_ID;
    sqlPopulation.ExecSQL;
  end;
begin
  if Application.MessageBox(PChar('Увага!'                                    + LineEnding +
                                  'Видаленння особи призведе до втрати всіх ' + LineEnding +
                                  'пов''язаних з нею даних: '                 + LineEnding +
                                  ' - спорідненості; '                        + LineEnding +
                                  ' - дані про реєстрацію як мешканця ; '     + LineEnding +
                                  ' - дані про землю; '                       + LineEnding +
                                  ' - інші. '                                 + LineEnding +
                                                                                LineEnding +
                                  'Продовжити?'),
                            PChar(Caption),
                            MB_YESNOCANCEL + MB_ICONQUESTION) = IDNO
  then Exit;

  LPerson_ID:= qPopulation.FieldByName('ID').AsInteger;

  try
    if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

    { TODO : Видалити після видалення з БД поля ID_HOLOVA_HOSPODARSTVA }
    ExecSQL('update HOSPODARSTVO set ID_HOLOVA_HOSPODARSTVA = 0 where ID_HOLOVA_HOSPODARSTVA = :prm_Person_ID');

    ExecSQL('delete from SPORIDNENIST where ID_NASELENNIA_KHTO = :prm_Person_ID');
    ExecSQL('delete from SPORIDNENIST where ID_NASELENNIA_KOMU = :prm_Person_ID');
    ExecSQL('delete from ZEMLIA       where ID_NASELENNIA      = :prm_Person_ID');
    ExecSQL('delete from MESHKANTSI   where ID_NASELENNIA      = :prm_Person_ID');
    ExecSQL('delete from NASELENNIA   where ID                 = :prm_Person_ID');

    qPopulation.Close;
    qPopulation.Open;

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;
  Except
    on E:Exception do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Особу не видалено!'        + LineEnding +
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

Procedure TfrmPopulation.actSelectExecute(Sender : TObject);
Begin
  Select.Code := qPopulation.FieldByName('ID').AsInteger;
  Select.Name := qPopulation.FieldByName('FULLNAME').AsString;

  Close;
end;

End.
