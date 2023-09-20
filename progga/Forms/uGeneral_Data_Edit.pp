unit uGeneral_Data_Edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs, db,
  ExtCtrls, Buttons, StdCtrls, LazUTF8, LCLType, uFunctions;

type
  { TfrmGeneral_Data_Edit }
  TfrmGeneral_Data_Edit = class(TForm)
    btnClose : TBitBtn;
    btnSave : TBitBtn;
    edtValue : TEdit;
    edtID : TEdit;
    edtName : TEdit;
    edtDescription : TEdit;
    grpValue : TGroupBox;
    grpID : TGroupBox;
    grpName : TGroupBox;
    grpDescription : TGroupBox;
    pnlAccessAndCode : TPanel;
    pnlButtons : TPanel;
    qGetData : TSQLQuery;
    rgAccess : TRadioGroup;
    sqlGeneral_Data : TSQLQuery;
    procedure FormCreate(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure FormCloseQuery(Sender : TObject; var CanClose : boolean);
    procedure btnCloseClick(Sender : TObject);
    procedure btnSaveClick(Sender : TObject);
    procedure OnFieldChange(Sender: TObject);
    procedure OnFieldUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
  private
    PPrimary : PInteger;
    PChanged : PBoolean;
    ID : Integer;
    is_Start,
    Saved_Name, Saved_Value, Saved_Description,
    Saved_Show : Variant;
    procedure GetSavedValue();
    procedure SetSavedValue();
    procedure SetWindowSize();
    procedure SetTextFieldsLimits();
  public
    constructor CreateInt(Sender: TComponent; var AID : Integer; var AChanged : Boolean);
  end;

var
  frmGeneral_Data_Edit : TfrmGeneral_Data_Edit;

implementation

uses
  udm;

{$R *.lfm}

{ TfrmGeneral_Data_Edit }

procedure TfrmGeneral_Data_Edit.GetSavedValue();
begin
  qGetData.Close;
  qGetData.ParamByName('prm_ID').Value := ID;
  qGetData.Open;

  edtID.Text          := qGetData.FieldByName('ID').AsString;
  edtName.Text        := qGetData.FieldByName('NAZVA').AsString;
  edtValue.Text       := qGetData.FieldByName('ZNACHENNIA').AsString;
  edtDescription.Text := qGetData.FieldByName('OPYS').AsString;
  rgAccess.ItemIndex  := qGetData.FieldByName('DOSTUP').AsInteger;

  qGetData.Close;
end;

procedure TfrmGeneral_Data_Edit.SetTextFieldsLimits();
begin
  dm.StartSetColumnsLimit('zahalni_dani');

  edtName.MaxLength          := dm.GetColumnsLimit('nazva');
  edtValue.MaxLength         := dm.GetColumnsLimit('znachennia');
  edtDescription.MaxLength   := dm.GetColumnsLimit('opys');

  dm.FinishSetColumnsLimit();
end;

procedure TfrmGeneral_Data_Edit.SetSavedValue();
begin
  Saved_Name        := edtName.Text;
  Saved_Value       := edtValue.Text;
  Saved_Description := edtDescription.Text;
  Saved_Show        := rgAccess.ItemIndex;
end;

procedure TfrmGeneral_Data_Edit.SetWindowSize();
begin
  ClientHeight := grpName.Height +
                  grpValue.Height +
                  grpDescription.Height +
                  pnlAccessAndCode.Height +
                  pnlButtons.Height +
                  2 * BorderWidth;
end;

constructor TfrmGeneral_Data_Edit.CreateInt(Sender: TComponent;
  var AID : Integer;
  var AChanged : Boolean);
begin
  inherited Create(Sender);

  PPrimary := @AID;
  PChanged := @AChanged;

  PChanged^ := False;

  ID := AID;
end;

procedure TfrmGeneral_Data_Edit.FormCreate(Sender : TObject);
begin
  is_Start := False;

  if ID < 0 then
  begin
    Caption := '[Загалльні дані] Новий запис';
  end
  else
  begin
    Caption := '[Загалльні дані] Корекція';

    GetSavedValue();
  end;

  SetSavedValue();
  SetWindowSize();

  is_Start := True;

  OnFieldChange(Sender);
  SetTextFieldsLimits();
end;

procedure TfrmGeneral_Data_Edit.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  is_Start := False;

  CloseAction := caFree;
end;

procedure TfrmGeneral_Data_Edit.FormCloseQuery(Sender : TObject; var CanClose : boolean);
begin
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

procedure TfrmGeneral_Data_Edit.btnCloseClick(Sender : TObject);
begin
  Close;
end;

procedure TfrmGeneral_Data_Edit.btnSaveClick(Sender : TObject);
begin
  if (not btnSave.Visible) or
     (not btnSave.Enabled)
  then
  begin
    SelectNext(ActiveControl, True, True);

    Exit;
	End;

  if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

  if ID < 0 then
  begin
    sqlGeneral_Data.SQL := sqlGeneral_Data.InsertSQL;
  end
  else
  begin
    sqlGeneral_Data.SQL := sqlGeneral_Data.UpdateSQL;

    sqlGeneral_Data.ParamByName('ID').Value := ID;
  end;

  sqlGeneral_Data.ParamByName('Nazva').AsString      := edtName.Text;
  sqlGeneral_Data.ParamByName('Znachennia').AsString := edtValue.Text;
  sqlGeneral_Data.ParamByName('Opys').AsString       := edtDescription.Text;
  sqlGeneral_Data.ParamByName('Dostup').AsInteger    := rgAccess.ItemIndex;

  try
    sqlGeneral_Data.ExecSQL;

    if ID < 0 then ID := dm.GetLastInsertID();

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    PChanged^ := True;
    PPrimary^ := ID;

    btnSave.Visible := False;
    btnSave.Enabled := False;
  except
    on E: EDatabaseError do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Оновлення довідника скасовано!' + LineEnding +
                                                                      LineEnding +
                                   'Виникла наступна помилка:'      + LineEnding +
                                                                      LineEnding +
                                    E.Message                       + LineEnding +
                                                                      LineEnding +
                                   'Модуль: ' + E.ClassName),
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
      Exit;
    end;
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
      Exit;
    end;
  end;

  Close;
end;

procedure TfrmGeneral_Data_Edit.OnFieldChange(Sender: TObject);
begin
  if not is_Start then Exit;

  btnSave.Enabled := (Trim(edtName.Text)        <> Saved_Name)        or
                     (Trim(edtValue.Text)       <> Saved_Value)       or
                     (Trim(edtDescription.Text) <> Saved_Description) or
                     (rgAccess.ItemIndex        <> Saved_Show);

  btnSave.Visible := FullStr(edtName.Text);

  if FullStr(edtName.Text)
  then edtName.Color := clDefault
  else edtName.Color := COLOR_ERROR_FIELD;
end;

procedure TfrmGeneral_Data_Edit.OnFieldUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
begin
  Case UTF8Key of
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = rgAccess
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
  else
          Exit;
  end;
end;

end.

