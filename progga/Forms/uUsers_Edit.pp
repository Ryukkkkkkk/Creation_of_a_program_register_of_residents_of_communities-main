Unit uUsers_Edit;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, DbCtrls, LCLType, LazUTF8, uFunctions;

Type
  { TfrmUsers_Edit }
  TfrmUsers_Edit = Class(TForm)
    btnClose : TBitBtn;
    btnSave : TBitBtn;
    edtUserPassword : TEdit;
    edtUserName : TEdit;
    grpUserPassword : TGroupBox;
    grpUserName : TGroupBox;
    pnlButtons : TPanel;
    qGetData : TSQLQuery;
    rgAccess : TRadioGroup;
    sqlUser : TSQLQuery;
    Procedure FormCreate(Sender : TObject);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure btnCloseClick(Sender : TObject);
    Procedure btnSaveClick(Sender : TObject);
    Procedure OnChangeData(Sender : TObject);
    Procedure OnUTF8KeyPress(Sender : TObject;              var UTF8Key : TUTF8Char);
    Procedure edtUserPasswordUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
  Private
    { private declarations }
    //PPrimary,
    PChanged : PBoolean;
    ID : Integer;
    is_Start : Boolean;
    Saved_UserName, Saved_Password : String;
    Saved_Access : Integer;
    procedure GetSavedValue();
    procedure SetSavedValue();
    procedure SetTextFieldsLimits();
  Public
    { public declarations }
    constructor CreateUser(Sender : TComponent; AID : Integer; var AChanged : Boolean);
  End;

Var
  frmUsers_Edit : TfrmUsers_Edit;

Implementation

uses
  udm;

{$R *.lfm}

{ TfrmUsers_Edit }

procedure TfrmUsers_Edit.GetSavedValue();
begin
  qGetData.ParamByName('ID').AsInteger := ID;
  qGetData.Open;
  qGetData.ExecSQL;

  edtUserName.Text     := qGetData.FieldByName('PIB').AsString;
  edtUserPassword.Text := ConvertFromPassword(qGetData.FieldByName('PAROL').AsString);
  rgAccess.ItemIndex   := qGetData.FieldByName('DOSTUP').AsInteger;

  qGetData.Close;
end;

procedure TfrmUsers_Edit.SetSavedValue();
begin
  Saved_UserName := edtUserName.Text;
  Saved_Password := edtUserPassword.Text;
  Saved_Access   := rgAccess.ItemIndex;
End;

constructor TfrmUsers_Edit.CreateUser(Sender : TComponent; AID : Integer; var AChanged : Boolean);
begin
  Inherited Create(Sender);

  //PPrimary := @AID;
  PChanged := @AChanged;

  PChanged^ := False;

  ID := AID;

  is_Start := False;
End;

procedure TfrmUsers_Edit.SetTextFieldsLimits();
begin
  dm.StartSetColumnsLimit('korystuvachi');

  edtUserName.MaxLength     := dm.GetColumnsLimit('pib');
  edtUserPassword.MaxLength := dm.GetColumnsLimit('parol');

  dm.FinishSetColumnsLimit();
end;

Procedure TfrmUsers_Edit.FormCreate(Sender : TObject);
Begin
  if ID < 0 then
  begin
    Caption := 'Новий користувач';
  end
  else
  begin
    Caption := 'Корекція користувача';

    GetSavedValue();
  end;

  SetSavedValue();
  SetTextFieldsLimits();

  is_Start := True;

  OnChangeData(nil);
End;

Procedure TfrmUsers_Edit.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
Begin
  is_Start := False;

  CloseAction := caFree;
End;

Procedure TfrmUsers_Edit.btnCloseClick(Sender : TObject);
Begin
  Close;
End;

Procedure TfrmUsers_Edit.btnSaveClick(Sender : TObject);
Begin
  if (not btnSave.Visible) or
     (not btnSave.Enabled)
  then Exit;

  try
    if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

    sqlUser.SQL.Clear;

    if ID < 0 then
    begin
      sqlUser.SQL := sqlUser.InsertSQL;
    end
    else
    begin
      sqlUser.SQL := sqlUser.UpdateSQL;

      sqlUser.ParamByName('ID').AsInteger := ID;
    end;

    sqlUser.ParamByName('PIB').AsString     := edtUserName.Text;
    sqlUser.ParamByName('PAROL').AsString   := ConvertToPassword(edtUserPassword.Text);
    sqlUser.ParamByName('DOSTUP').AsInteger := rgAccess.ItemIndex;

    sqlUser.ExecSQL;

    if ID < 0 then ID := dm.GetLastInsertID();

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    PChanged^ := True;

    Close;
  except
    on E:Exception do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Модуль: ' + E.ClassName     + LineEnding +
                                                                  LineEnding +
                                   'Виникла наступна помилка:'  + LineEnding +
                                    E.Message                   + LineEnding +
                                                                  LineEnding +
                                   'Зміни не збережено '        + LineEnding +
                                   'Закрийте вікно і повторіть спробу.'),
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
   end;
  end;
end;

Procedure TfrmUsers_Edit.OnChangeData(Sender : TObject);
Begin
  if not is_Start then Exit;

  btnSave.Visible := FullStr(edtUserName.Text);

  btnSave.Enabled := (Saved_UserName <> edtUserName.Text)     or
                     (Saved_Password <> edtUserPassword.Text) or
                     (Saved_Access   <> rgAccess.ItemIndex);

  if EmptyStr(edtUserName.Text)
  then edtUserName.Color := COLOR_ERROR_FIELD
  else edtUserName.Color := clDefault;
end;

procedure TfrmUsers_Edit.OnUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
begin
  case UTF8Key of
    #8: ; // BackSpace
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = rgAccess
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    'А'..'Я', 'а'..'я', '''', '.', '-',
    'і', 'І', 'Ї', 'ї',
    'є', 'Є', 'ґ', 'Ґ', ' ': ;
    else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    end;
  end;
End;

procedure TfrmUsers_Edit.edtUserPasswordUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
begin
    case UTF8Key of
    #8: ; // BackSpace
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if btnSave.Visible and btnSave.Enabled
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    'A'..'Z', 'a'..'z': ;
    'А'..'Я', 'а'..'я': ;
    'і', 'І', 'Ї', 'ї',
    'є', 'Є', 'ґ', 'Ґ': ;
    '0'..'9': ;
    ',', '.', '-', '_', '+', '=', '/', '*', '!', '?', '<', '>', ' ' : ;
    else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                              PChar(Caption),
                              MB_OK + MB_ICONSTOP);
    end;
  end;
End;

End.

