unit uHouse_Edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, DbCtrls, LCLType, LResources, ActnList, LazUTF8,
  uFunctions;

type
  { TfrmHouse_Edit }
  TfrmHouse_Edit = class(TForm)
    actReference : TAction;
    ActionList : TActionList;
    btnAddress : TBitBtn;
    edtAddress : TEdit;
    edtNumber : TEdit;
    grpAddress : TGroupBox;
    sqlHouse : TSQLQuery;
    qGetData : TSQLQuery;
    pnlButtons : TPanel;
    btnSave : TBitBtn;
    btnClose : TBitBtn;
    pnlInfo : TPanel;
    grpNumber : TGroupBox;
    grpVillage : TGroupBox;
    lcbVillage : TDBLookupComboBox;
    qVillage : TSQLQuery;
    dsVillage : TDataSource;
    pnlInfo_Border : TPanel;
    Procedure FormCreate(Sender : TObject);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure FormCloseQuery(Sender : TObject; Var CanClose : boolean);
    Procedure btnCloseClick(Sender : TObject);
    Procedure btnSaveClick(Sender : TObject);
    procedure btnAddressClick(Sender : TObject);
    Procedure OnFieldChange(Sender : TObject);
    Procedure OnFieldUTF8KeyPress(Sender : TObject;  var UTF8Key : TUTF8Char);
    Procedure OnNumberUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
  private
    { private declarations }
    PPrimary : PInteger;
    PChanged : PBoolean;
    House_ID : Integer;
    is_Start, is_New, is_Upd : Boolean;
    Saved_Number, Saved_Address : String;
    Saved_Village : Integer;
    procedure GetSavedValue();
    procedure SetSavedValue();
    procedure SetWindowSize();
    procedure SetTextFieldsLimits();
  public
    { public declarations }
    constructor CreateInt(Sender : TComponent; var APK : Integer; var AChanged : Boolean);
  end;

var
  frmHouse_Edit : TfrmHouse_Edit;

implementation

uses
  udm, uAddress_Edit;

{$R *.lfm}

procedure TfrmHouse_Edit.GetSavedValue();
begin
  qGetData.ParamByName('ID').AsInteger := House_ID;
  qGetData.Open;

  edtNumber.Text      := qGetData.FieldByName('NOMER').AsString;
  edtAddress.Text     := qGetData.FieldByName('ADRESA').AsString;
  lcbVillage.KeyValue := qGetData.FieldByName('ID_SELO').AsInteger;

  qGetData.Close;
end;

Procedure TfrmHouse_Edit.SetSavedValue();
Begin
  Saved_Number  := edtNumber.Text;
  Saved_Address := edtAddress.Text;
  Saved_Village := lcbVillage.KeyValue;
End;

procedure TfrmHouse_Edit.SetWindowSize();
begin
  ClientHeight := pnlInfo.Height    +
                  grpAddress.Height +
                  pnlButtons.Height +
                  2 * BorderWidth;
end;

procedure TfrmHouse_Edit.SetTextFieldsLimits();
begin
  dm.StartSetColumnsLimit('hospodarstvo');

  edtAddress.MaxLength := dm.GetColumnsLimit('adresa');

  dm.FinishSetColumnsLimit();
end;

constructor TfrmHouse_Edit.CreateInt(Sender : TComponent; var APK : Integer; var AChanged : Boolean);
begin
  Inherited Create(Sender);

  PPrimary  := @APK;
  PChanged  := @AChanged;
  PChanged^ := False;

  House_ID := APK;
End;

Procedure TfrmHouse_Edit.FormCreate(Sender : TObject);
Begin
  is_Start := False;

  qVillage.Open;
  qVillage.Last;
  qVillage.First;

  is_New := (House_ID < 0);

  if is_New then
  begin
    Caption := '[Господарство] Новий запис';

    lcbVillage.KeyValue := REFERENCE_NONE;
   end
  else
  begin
    Caption := '[Господарство] Корекція';

    GetSavedValue();
  end;

  SetSavedValue();   
  SetWindowSize();
  SetTextFieldsLimits();

  is_Start := True;

  OnFieldChange(nil);
End;

Procedure TfrmHouse_Edit.FormCloseQuery(Sender : TObject; Var CanClose : boolean);
Begin
  if btnSave.Enabled and btnSave.Visible then
  begin
    case Application.MessageBox('Увага!'                              + LineEnding +
                                'Всі незбережені дані буде втрачено!' + LineEnding +
                                                                        LineEnding +
                                'Зберегти?',
                                 PChar(Caption),
                                 MB_YESNOCANCEL + MB_ICONQUESTION)
    of
      IDCANCEL: begin
                  CanClose := False;
                end;
      IDYES:    begin
                  btnSave.Click;
                end;
      IDNO:     begin
                  if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;
                end;
    end;
  end;
end;

Procedure TfrmHouse_Edit.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
Begin
  is_Start := False;

  qVillage.Close;

  CloseAction := caFree;
End;

Procedure TfrmHouse_Edit.btnCloseClick(Sender : TObject);
Begin
  Close;
End;

Procedure TfrmHouse_Edit.btnSaveClick(Sender : TObject);
Begin
  if (not btnSave.Visible) or
     (not btnSave.Enabled)
  then
  begin
    SelectNext(ActiveControl, True, True);

    Exit;
  End;

  try
    if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

    if is_New then
    begin // Insert
      sqlHouse.SQL := sqlHouse.InsertSQL;
    end
    else
    if is_Upd then
    begin // Update
      sqlHouse.SQL := sqlHouse.UpdateSQL;

      sqlHouse.ParamByName('ID').AsInteger := House_ID;
    end;

    if is_New or
       is_Upd
    then
    begin
      sqlHouse.ParamByName('Nomer').AsString    := edtNumber.Text;
      sqlHouse.ParamByName('Adresa').AsString   := edtAddress.Text;
      sqlHouse.ParamByName('ID_Selo').AsInteger := lcbVillage.KeyValue;

      sqlHouse.ExecSQL;

      if is_New then House_ID := dm.GetLastInsertID();
    end;

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    PChanged^ := True;
    PPrimary^ := House_ID;

    if is_New then
    begin
      is_New := False;

      GetSavedValue();
      SetWindowSize();
    end;

    SetSavedValue();
    OnFieldChange(nil);
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

  Close;
end;

procedure TfrmHouse_Edit.btnAddressClick(Sender : TObject);
var
  Address : String;
  Data_Changed : Boolean;
begin
  Address      := edtAddress.Text;
  Data_Changed := False;

  with TfrmAddress_Edit.CreateFromPopulation(Self, Address, Data_Changed) do
  begin
    ShowModal;
    Free;
  end;

  if Data_Changed then edtAddress.Text := Address;
end;

Procedure TfrmHouse_Edit.OnFieldChange(Sender : TObject);
Begin
  if not is_Start then Exit;

  btnSave.Visible := FullStr(edtAddress.Text);

  is_Upd := (Saved_Number  <> edtNumber.Text)  or
            (Saved_Address <> edtAddress.Text) or
            (Saved_Village <> lcbVillage.KeyValue);

  btnSave.Enabled := is_Upd;

  if FullStr(edtAddress.Text) then edtAddress.Color := clDefault else edtAddress.Color := COLOR_ERROR_FIELD;
end;

procedure TfrmHouse_Edit.OnFieldUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
begin
  case UTF8Key of
     #8 : ; // BackSpace
    #27 : ;
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = edtAddress
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    'А'..'Я', 'І', 'Ї', 'Є', 'Ґ' : ;
    'а'..'я', 'і', 'ї', 'є', 'ґ' : ;
    '''', ',', '-', ' ': ;
    '0'..'9': ;
    else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    end;
  end;
End;

procedure TfrmHouse_Edit.OnNumberUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
begin
  case UTF8Key of
     #8 : ; // BackSpace
    #27 : ; // Esc
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            SelectNext(ActiveControl, True, True);
          end;
    '0'..'9': ;
  else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                              PChar(Caption),
                              MB_OK + MB_ICONSTOP);
    end;
  end;
End;

end.

