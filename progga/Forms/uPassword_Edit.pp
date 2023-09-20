Unit uPassword_Edit;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, LazUTF8, LCLType, uFunctions;

Type
  { TfrmPassword_Edit }
  TfrmPassword_Edit = Class(TForm)
    btnClose : TBitBtn;
    btnSave : TBitBtn;
    edtPassword : TEdit;
    edtNewPassword_1 : TEdit;
    edtNewPassword_2 : TEdit;
    grpPassword : TGroupBox;
    grpNewPassword_1 : TGroupBox;
    grpNewPassword_2 : TGroupBox;
    pnlButtons : TPanel;
    qGetData : TSQLQuery;
    sqlPassword : TSQLQuery;
    Procedure FormCreate(Sender : TObject);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure btnCloseClick(Sender : TObject);
    Procedure btnSaveClick(Sender : TObject);
    Procedure OnChangeData(Sender : TObject);
    Procedure edtPasswordUTF8KeyPress(Sender : TObject;  var UTF8Key : TUTF8Char);
  Private
    { private declarations }
    is_Start : Boolean;
    Old_Password : String;
  Public
    { public declarations }
  End;

Var
  frmPassword_Edit : TfrmPassword_Edit;

Implementation

uses
  udm;

{$R *.lfm}

{ TfrmPassword_Edit }

Procedure TfrmPassword_Edit.FormCreate(Sender : TObject);
Begin
  is_Start := False;

  qGetData.ParamByName('prm_User').Value := dm.UserCode;
  qGetData.Open;

  Old_Password := ConvertFromPassword(qGetData.FieldByName('PAROL').AsString);

  qGetData.Close;

  is_Start := True;

  OnChangeData(nil);
End;

Procedure TfrmPassword_Edit.FormClose(Sender : TObject;  Var CloseAction : TCloseAction);
Begin
  is_Start := False;

  CloseAction := caFree;
End;

Procedure TfrmPassword_Edit.btnCloseClick(Sender : TObject);
Begin
  Close;
End;

Procedure TfrmPassword_Edit.btnSaveClick(Sender : TObject);
Begin
  if (not btnSave.Visible) or
     (not btnSave.Enabled)
  then Exit;

  try
    if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

    sqlPassword.ParamByName('PAROL').AsString := ConvertToPassword(edtNewPassword_1.Text);
    sqlPassword.ParamByName('ID').AsInteger   := dm.UserCode;
    sqlPassword.ExecSQL;

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

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
End;

Procedure TfrmPassword_Edit.OnChangeData(Sender : TObject);
Begin
  if not is_Start then Exit;

  btnSave.Visible :=     (edtPassword.Text      = Old_Password)
                     and (edtNewPassword_1.Text = edtNewPassword_2.Text);

  if edtPassword.Text <> Old_Password
  then edtPassword.Color := COLOR_ERROR_FIELD
  else edtPassword.Color := clDefault;

  if UTF8Length(edtNewPassword_1.Text) = 0
  then edtNewPassword_1.Color := COLOR_ERROR_FIELD
  else edtNewPassword_1.Color := clDefault;

  if UTF8Length(edtNewPassword_2.Text) = 0
  then edtNewPassword_2.Color := COLOR_ERROR_FIELD
  else edtNewPassword_2.Color := clDefault;

  if edtNewPassword_1.Text <> edtNewPassword_2.Text then
  begin
    edtNewPassword_1.Color := COLOR_ERROR_FIELD;
    edtNewPassword_2.Color := COLOR_ERROR_FIELD;
  end
  else
  begin
    edtNewPassword_1.Color := clDefault;
    edtNewPassword_2.Color := clDefault;
  end;
End;

Procedure TfrmPassword_Edit.edtPasswordUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
Begin
  case UTF8Key of
    #8: ; // BackSpace
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = edtNewPassword_2
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    'A'..'Z', 'a'..'z': ;
    'А'..'Я', 'а'..'я': ;
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

