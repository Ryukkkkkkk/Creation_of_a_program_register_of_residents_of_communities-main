Unit uPassword;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, sqldb, db, Forms, Controls, Graphics, Dialogs, LCLType,
  StdCtrls, DbCtrls, ExtCtrls, Buttons, LR_Class, LazUTF8, uFunctions,DateUtils;

Type
  { TfrmPassword }
  TfrmPassword = Class(TForm)
    btnOk : TBitBtn;
    btnClose : TBitBtn;
    dsUsers : TDataSource;
    edtPassword : TEdit;
    grpUsers : TGroupBox;
    grpPassword : TGroupBox;
    lcbUsers : TDBLookupComboBox;
    pnlButtons : TPanel;
    qUsers : TSQLQuery;
    Procedure FormCreate(Sender : TObject);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure btnCloseClick(Sender : TObject);
    Procedure btnOkClick(Sender : TObject);
    Procedure lcbUsersChange(Sender : TObject);
    Procedure OnFieldKeyPress(Sender : TObject; Var Key : char);
  Private
    { private declarations }
    GError_Count : Byte;
  Public
    { public declarations }
    class function Execute : Boolean;
  End;

Var
  frmPassword : TfrmPassword;

Implementation

uses
  udm;

{$R *.lfm}

class function TfrmPassword.Execute : Boolean;
begin
  with TfrmPassword.Create(nil) do
  begin
    try
      Result := (ShowModal = mrOk);
    finally
      Free;
    end;
  end;
end;

{ TfrmPassword }

Procedure TfrmPassword.FormCreate(Sender : TObject);
var
  LLastUser : Integer;
Begin
  GError_Count := 0;

  qUsers.Open;
  qUsers.Last;
  qUsers.First;

  LLastUser := 0;

  if dm.GetIniPropStorageValue(Self.Name, 'LastUser', False, LLastUser, USER_CODE_ADMIN) then
  begin
    lcbUsers.KeyValue := LLastUser;

    qUsers.Locate('USER_ID', lcbUsers.KeyValue, []);
  end;
end;

Procedure TfrmPassword.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
Begin
  qUsers.Close;

  if (ModalResult <> mrOK) then
  begin
    dm.MySQLDB56.Connected := False;
  end;

  CloseAction := caFree;
end;

Procedure TfrmPassword.btnCloseClick(Sender : TObject);
Begin
  ModalResult := mrAbort;

  Close;
end;

Procedure TfrmPassword.btnOkClick(Sender : TObject);
var
  LPassword : String;
  LIs_Success_Login : Boolean;
Begin
  LIs_Success_Login := False;

  LPassword := ConvertFromPassword(qUsers.FieldByName('USER_PASSWORD').AsString);

  If (edtPassword.Text = LPassword) Then
  Begin
    LIs_Success_Login := True;

    dm.UserCode      := qUsers.FieldByName('USER_ID').AsInteger;
    dm.UserName      := qUsers.FieldByName('USER_NAME').AsString;
    dm.ShortUserName := GetShortName(dm.UserName);

    dm.SetIniPropStorageValue(Self.Name, 'LastUser', dm.UserCode);

    frVariables['User_Name']       := dm.UserName;
    frVariables['User_Name_Short'] := dm.ShortUserName;

    qUsers.Close;
  End
  Else
  Begin
    Application.MessageBox('Доступ заборонено!' + LineEnding +
                           '> Невірний пароль',
                           'Помилка авторизації', MB_OK + MB_ICONERROR);

    GError_Count := GError_Count + 1;

    edtPassword.Text := '';

    edtPassword.SetFocus;

    If GError_Count < 3 Then Exit;
  End;

  if LIs_Success_Login
  then ModalResult := mrOK
  else ModalResult := mrAbort;
end;

Procedure TfrmPassword.lcbUsersChange(Sender : TObject);
Begin
  btnOk.Enabled := (UTF8Length(lcbUsers.Text) > 0);
end;

Procedure TfrmPassword.OnFieldKeyPress(Sender : TObject; Var Key : char);
Begin
  case Key of
    #10 : begin
            if UTF8Length(edtPassword.Text) > 0 then btnOk.Click;
          end;
    #13 : begin
            if Sender = edtPassword
            then btnOk.Click
            else SelectNext(ActiveControl, True, True);
          end;
   end;
end;

End.

