unit uLands_Edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, DbCtrls, Buttons, LazUTF8, LCLType, ActnList, Spin,
  MaskEdit, uSelect;

type
  { TfrmLands_Edit }
  TfrmLands_Edit = class(TForm)
    btnPurpose : TBitBtn;
    dsPurpose : TDataSource;
    edtNotes : TEdit;
    edtContract : TEdit;
    fseArea : TFloatSpinEdit;
    grpArea : TGroupBox;
    grpNotes : TGroupBox;
    grpCadastral : TGroupBox;
    grpContract : TGroupBox;
    grpPurpose : TGroupBox;
    lcbPurpose : TDBLookupComboBox;
    medtCadastral : TMaskEdit;
    pnlAreaAndNumber : TPanel;
    pnlButtons : TPanel;
    btnClose : TBitBtn;
    qPurpose : TSQLQuery;
    sqlLands : TSQLQuery;
    qGetData : TSQLQuery;
    btnSave : TBitBtn;
    procedure btnPurposeClick(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure FormCloseQuery(Sender : TObject; var CanClose : boolean);
    procedure btnCloseClick(Sender : TObject);
    procedure btnSaveClick(Sender : TObject);
    Procedure OnFieldChange(Sender : TObject);
    procedure OnFieldUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
  private
    { private declarations }
    PPrimary : PInteger;
    PChanged : PBoolean;
    ID, ID_Person : Integer;
    Saved_Area, Saved_Purpose,
    Saved_Cadastral, Saved_Notes, Saved_Contract : Variant;
    is_Start : Boolean;
    procedure GetSavedValue();
    procedure SetSavedValue();
    procedure SetTextFieldsLimits();
  public
    { public declarations }
    constructor CreateLands(Sender : TComponent; iID_Person : Integer; var iPK : Integer; var bChanged : Boolean);
  end;

var
  frmLands_Edit : TfrmLands_Edit;

implementation

uses
  udm, uReference;

{$R *.lfm}

{ TfrmLands_Edit }

procedure TfrmLands_Edit.GetSavedValue();
begin
  qGetData.Close;
  qGetData.ParamByName('prm_ID').Value := ID;
  qGetData.Open;

  lcbPurpose.KeyValue := qGetData.FieldByName('ID_TYP_ZEMLI').Value;
  fseArea.Value       := qGetData.FieldByName('PLOSHCHA').AsFloat;
  medtCadastral.Text  := qGetData.FieldByName('KADASTROVYI_NOMER').AsString;
  edtNotes.Text       := qGetData.FieldByName('PRYMITKA').AsString;
  edtContract.Text    := qGetData.FieldByName('DOGOVIR').AsString;

  qGetData.Close;
end;

Procedure TfrmLands_Edit.SetSavedValue;
Begin
  Saved_Purpose   := lcbPurpose.KeyValue;
  Saved_Area      := fseArea.Value;
  Saved_Cadastral := medtCadastral.Text;
  Saved_Notes     := edtNotes.Text;
  Saved_Contract  := edtContract.Text;
End;

constructor Tfrmlands_Edit.CreateLands(Sender : TComponent; iID_Person : Integer; var iPK : Integer; var bChanged : Boolean);
begin
  Inherited Create(Sender);

  PPrimary := @iPK;
  PChanged := @bChanged;

  PChanged^ := False;

  ID        := iPK;
  ID_Person := iID_Person;
End;

procedure Tfrmlands_Edit.SetTextFieldsLimits();
begin
  dm.StartSetColumnsLimit('zemlia');

  medtCadastral.MaxLength := dm.GetColumnsLimit('kadastrovyi_nomer');
  edtNotes.MaxLength      := dm.GetColumnsLimit('prymitka');

  dm.FinishSetColumnsLimit();
end;

procedure TfrmLands_Edit.FormCreate(Sender : TObject);
begin
  is_Start := False;

  qPurpose.Open;
  qPurpose.Last;
  qPurpose.First;

  if ID < 0 then
  begin
    Caption := '[Земля] Новий запис';

    lcbPurpose.KeyValue := REFERENCE_NONE;
  end
  else
  begin
    Caption := '[Земля] Корекція';

    GetSavedValue();
  end;

  SetSavedValue();

  is_Start := True;

  OnFieldChange(Sender);
  SetTextFieldsLimits();
end;

procedure TfrmLands_Edit.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  is_Start := False;

  qPurpose.Close;

  CloseAction := caFree;
end;

procedure TfrmLands_Edit.FormCloseQuery(Sender : TObject; var CanClose : boolean);
begin
  if btnSave.Enabled and btnSave.Visible then
  begin
    case Application.MessageBox(PChar('Увага!'                              + LineEnding +
                                      'Всі незбережені дані буде втрачено!' + LineEnding +
                                                                              LineEnding +
                                      'Зберегти?'),
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

procedure TfrmLands_Edit.btnCloseClick(Sender : TObject);
begin
  Close;
end;

procedure TfrmLands_Edit.btnSaveClick(Sender : TObject);
begin
  if (not btnSave.Visible) or
     (not btnSave.Enabled)
  then Exit;

  if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

  if ID < 0 then
  begin // Insert
    sqlLands.SQL := sqlLands.InsertSQL;

    sqlLands.ParamByName('ID_Naselennia').AsInteger := ID_Person;
  end
  else
  begin // Update
    sqlLands.SQL := sqlLands.UpdateSQL;

    sqlLands.ParamByName('ID').AsInteger := ID;
  end;

  try
    sqlLands.ParamByName('ID_Typ_Zemli').AsInteger     := lcbPurpose.KeyValue;
    sqlLands.ParamByName('Ploshcha').AsFloat     		   := fseArea.Value;
    sqlLands.ParamByName('Kadastrovyi_Nomer').AsString := medtCadastral.Text;
    sqlLands.ParamByName('Prymitka').AsString		       := edtNotes.Text;
    sqlLands.ParamByName('Dogovir').AsString		       := edtContract.Text;

    sqlLands.ExecSQL;

    if ID < 0 then ID := dm.GetLastInsertID();

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    PChanged^ := True;
    PPrimary^ := ID;

    btnSave.Visible := False;
    btnSave.Enabled := False;
  Except
    on E:Exception do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Зміни не збережено!'       + LineEnding +
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

  Close;
end;

procedure TfrmLands_Edit.btnPurposeClick(Sender : TObject);
var
  DataCaption, DataTable : String;
  DataParam : Variant;
  DataID : Integer;
  DataChanged : Boolean;
begin
  DataChanged := False;

  DataCaption := 'Виберіть призначення земельної ділянки';
  DataTable   :=  UTF8Trim(UTF8UpperString('TYP_ZEMLI'));
  DataParam   :=  Null;
  DataID      :=  lcbPurpose.KeyValue;

  with TfrmReference.CreateSelect(Self, DataCaption,
                                        DataTable,
                                        DataParam,
                                        DataID,
                                        DataChanged)
  do
  begin
    Select := TSelect.Create();

    ShowModal;

    if Select.Success
    then DataID := Select.Code
    else DataID := -1;

    Free;
  end;

  if DataChanged then
  begin
    qPurpose.Close;
    qPurpose.Open;
    qPurpose.Last;
    qPurpose.Locate('ID', DataID, []);
  end;

  if DataID > 0 then
  begin
    lcbPurpose.KeyValue := DataID;

    OnFieldChange(lcbPurpose);
  end;
end;

Procedure TfrmLands_Edit.OnFieldChange(Sender : TObject);
Begin
  if not is_Start then Exit;

  btnSave.Enabled := (lcbPurpose.KeyValue <> Saved_Purpose)   or
                     (fseArea.Value       <> Saved_Area)      or
                     (medtCadastral.Text  <> Saved_Cadastral) or
                     (edtNotes.Text       <> Saved_Notes)     or
                     (edtContract.Text    <> Saved_Contract);

  btnSave.Visible := (lcbPurpose.KeyValue > 0)
                 and (fseArea.Value       > 0);

  if lcbPurpose.KeyValue > 0 then lcbPurpose.Color := clDefault else lcbPurpose.Color := COLOR_ERROR_FIELD;
  if fseArea.Value       > 0 then fseArea.Color    := clDefault else fseArea.Color    := COLOR_ERROR_FIELD;
end;

procedure TfrmLands_Edit.OnFieldUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
begin
  Case UTF8Key of
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = edtNotes
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
	else
          Exit;
  end;
end;

end.

