Unit uUsers;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, DBGrids, StdCtrls, EditBtn, DbCtrls, Menus, ActnList,
  LCLType, LazUTF8, uFunctions;

Type
  { TfrmUsers }
  TfrmUsers = Class(TForm)
	  actAdd : TAction;
	  ActionList : TActionList;
	  actUpd : TAction;
	  btnAdd : TBitBtn;
	  btnUpd : TBitBtn;
	  btnClose : TBitBtn;
	  dbgUsers : TDBGrid;
	  dsUsers : TDataSource;
	  edtSearch : TEditButton;
	  grpSearch : TGroupBox;
	  pmAdd : TMenuItem;
	  pmUpd : TMenuItem;
	  pnlButtons : TPanel;
	  pnlFilters : TPanel;
	  pUpmUsers : TPopupMenu;
	  qUsers : TSQLQuery;
	  tmrSearch : TTimer;
    cgAccess : TCheckGroup;
		Procedure FormCreate(Sender : TObject);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure btnCloseClick(Sender : TObject);
    Procedure actAddUpdExecute(Sender : TObject);
		Procedure dbgUsersDblClick(Sender : TObject);
    Procedure dbgUsersUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
    Procedure edtSearchButtonClick(Sender : TObject);
    Procedure edtSearchKeyPress(Sender : TObject; var Key : char);
    Procedure cgAccessItemClick(Sender : TObject; Index : integer);
    Procedure OnFilterChange(Sender : TObject);
		Procedure tmrSearchTimer(Sender : TObject);
  Private
    { private declarations }
    is_Start : Boolean;
  Public
    { public declarations }
  End;

Var
  frmUsers : TfrmUsers;

Implementation

uses
  udm, uUsers_Edit;

{$R *.lfm}

{ TfrmUsers }

Procedure TfrmUsers.FormCreate(Sender : TObject);
var
  i : Byte;
Begin
  is_Start := False;

  for i := 0 to cgAccess.Items.Count - 1 do
  begin
    cgAccess.Checked[i] := True;
  end;

  is_Start := True;

  OnFilterChange(nil)
end;

Procedure TfrmUsers.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
Begin
  is_Start :=  False;

  CloseAction := caFree;
end;

Procedure TfrmUsers.btnCloseClick(Sender : TObject);
Begin
  Close;
end;

Procedure TfrmUsers.actAddUpdExecute(Sender : TObject);
var
  ID : Integer;
  DataChanged : Boolean;
Begin
  DataChanged := False;

  if Sender = actAdd then ID := -1                                 else
  if Sender = actUpd then ID := qUsers.FieldByName('ID').AsInteger else Exit;

  with TfrmUsers_Edit.CreateUser(Self, ID, DataChanged) Do
  begin
    ShowModal;
    Free;
	End;

  if DataChanged then
  begin
    qUsers.Open;
	  qUsers.Last;
	  qUsers.First;
	  qUsers.Locate('ID', ID, []);
	End;
End;

Procedure TfrmUsers.dbgUsersDblClick(Sender : TObject);
Begin
  if qUsers.RecordCount = 0
  then btnAdd.Click
  else btnUpd.Click;
End;

Procedure TfrmUsers.dbgUsersUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
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

  if qUsers.RecordCount = 0 then Exit;

  if (UTF8Key = #13) then
  begin
    btnUpd.Click;
  end;
End;

Procedure TfrmUsers.edtSearchButtonClick(Sender : TObject);
Begin
  edtSearch.Clear;
End;

Procedure TfrmUsers.edtSearchKeyPress(Sender : TObject; var Key : char);
Begin
  if Key = #13 then
  begin
    Key := #0;

    tmrSearchTimer(Sender);
  end;
end;

procedure TfrmUsers.cgAccessItemClick(Sender : TObject; Index : integer);
begin
  OnFilterChange(Sender);
end;

Procedure TfrmUsers.OnFilterChange(Sender : TObject);
Begin
  if not is_Start then Exit;;

  tmrSearch.Enabled := False;
  tmrSearch.Enabled := True;
End;

Procedure TfrmUsers.tmrSearchTimer(Sender : TObject);
var
  Locate_ID : Integer;
  tS : String;
Begin
  tmrSearch.Enabled := False;

  if qUsers.RecordCount > 0
  then Locate_ID := qUsers.FieldByName('ID').AsInteger
  else Locate_ID := 0;

  qUsers.Close;

  qUsers.SQL[qUsers.SQL.Count - 3] := '';
  qUsers.SQL[qUsers.SQL.Count - 2] := '';

  tS := '';

  if cgAccess.Checked[0] then tS := tS + ' or (DOSTUP = 0)';
  if cgAccess.Checked[1] then tS := tS + ' or (DOSTUP = 1)';

  qUsers.SQL[qUsers.SQL.Count - 3] := '  and ((1 = 0)' + tS + ')';

  if FullStr(edtSearch.Text) then
  begin
    tS := StringReplace(edtSearch.Text, '''', '''''', [rfReplaceAll]);

    qUsers.SQL[qUsers.SQL.Count - 2] := '  and (PIB like ''%' + tS + '%'')';
	End;

  qUsers.Open;
  qUsers.Last;
  qUsers.First;
  qUsers.Locate('ID', Locate_ID, []);

  try
    dbgUsers.SetFocus;
  except
    //
  end;
End;

End.

