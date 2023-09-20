Unit uInhabitant_Edit;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, sqldb, db, FileUtil, DateTimePicker, Forms, Controls,
	Graphics, Dialogs, ExtCtrls, Buttons, StdCtrls, DbCtrls, ActnList, LCLType,
  uSelect, uFunctions;

Type
  { TfrmInhabitant_Edit }
  TRelationship = record
    ID    : Integer;
    House : Integer;
    Kind  : Integer;
    Who   : Integer;
    Whom  : Integer;
  end;

  TfrmInhabitant_Edit = Class(TForm)
    ActionList : TActionList;
    actReference : TAction;
    btnClose : TBitBtn;
    btnRelationship : TBitBtn;
    btnSave : TBitBtn;
    chgEviction : TCheckGroup;
    dsRelationship : TDataSource;
    edtAddress : TEdit;
    edtRegistration : TDateTimePicker;
    edtEviction : TDateTimePicker;
    edtPerson : TEdit;
    edtVillage : TEdit;
    edtDeclarant : TEdit;
    grpRegistration : TGroupBox;
    grpEviction : TGroupBox;
    grpHouse : TGroupBox;
    grpLocality : TGroupBox;
    grpPerson : TGroupBox;
    grpRelationship : TGroupBox;
    grpDeclarant : TGroupBox;
    lblPerson_Name : TLabel;
    lcbRelationship : TDBLookupComboBox;
    pnlMeshkantsi : TPanel;
    pnlDeclarant : TPanel;
    qGetData : TSQLQuery;
    qGetPerson : TSQLQuery;
    qGetHouse : TSQLQuery;
    pnlButtons : TPanel;
    qGetRelationship : TSQLQuery;
    qRelationship : TSQLQuery;
    rgRegistration_Status : TRadioGroup;
    sqlInhabitant : TSQLQuery;
    sqlRelationship : TSQLQuery;
    procedure edtRegistrationCheckBoxChange(Sender: TObject);
    Procedure FormCreate(Sender : TObject);
    Procedure FormCloseQuery(Sender : TObject; Var CanClose : Boolean);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure btnCloseClick(Sender : TObject);
    Procedure btnSaveClick(Sender : TObject);
    Procedure btnRelationshipClick(Sender : TObject);
    procedure chgEvictionItemClick(Sender : TObject; Index : Integer);
    Procedure OnFieldChange(Sender : TObject);
    Procedure OnFieldUTF8KeyPress(Sender : TObject;	Var UTF8Key : TUTF8Char);
  Private
    { private declarations }
    PPrimary : PInteger;
    PChanged : PBoolean;
    Inhabitant_ID, Relationship_ID,
    House_ID, Person_ID, Declarant_ID: Integer;
    is_Start, is_House, is_Family,
    is_New_Inhabitant, is_New_Relationship,
    is_Upd_Inhabitant, is_Upd_Relationship : Boolean;
    Saved_Registration_Date, Saved_Eviction_Date,
    Saved_Relationship, Saved_Eviction, Saved_Eviction_Temp,
    Saved_Registration_Status : Variant;
    procedure GetSavedValue();
    procedure SetSavedValue();
    procedure SetWindowSize();
    Function  GetPersonName(AID : Integer) : String;
    Function RelationshipDefault() : TRelationship;
    Function RelationshipExist(AHouse, AWho, AWhom : Integer) : TRelationship;
    Function RelationshipChange(AOperation : Byte;
                                ARelationship : TRelationship) : Integer;
  Public
    { public declarations }
    constructor CreateFromHouseTab     (Sender : TComponent; AHouse, APerson,             ARelationship : Integer; var APK : Integer; var AChanged : Boolean);
    constructor CreateFromPopulationTab(Sender : TComponent; AHouse, APerson, ADeclarant, ARelationship : Integer; var APK : Integer; var AChanged : Boolean);
  End;

Var
  frmInhabitant_Edit : TfrmInhabitant_Edit;

Implementation

uses
  udm, uReference;

const
  ADD_OPERATION       =  1;
  UPD_OPERATION       =  2;
  DEL_OPERATION       =  3;
  EVICTION_STATUS_TMP =  0;
  EVICTION_STATUS_OUT =  1;

{$R *.lfm}

{ TfrmInhabitant_Edit }

procedure TfrmInhabitant_Edit.GetSavedValue();
var
  Relationship : TRelationship;
begin
  qGetData.Close;
  qGetData.ParamByName('ID').AsInteger := Inhabitant_ID;
  qGetData.Open;

  if qGetData.FieldByName('DATA_REIESTRATSII').IsNull
  then edtRegistration.Date := NullDate
  else edtRegistration.Date := qGetData.FieldByName('DATA_REIESTRATSII').AsDateTime;

  edtRegistration.Checked := not qGetData.FieldByName('DATA_REIESTRATSII').IsNull;

  if qGetData.FieldByName('DATA_VYBUTTIA').IsNull
  then edtEviction.Date := NullDate
  else edtEviction.Date := qGetData.FieldByName('DATA_VYBUTTIA').AsDateTime;

  chgEviction.Checked[EVICTION_STATUS_TMP] := (qGetData.FieldByName('TYMCHASOVO_VYBUV').AsInteger > 0);
  chgEviction.Checked[EVICTION_STATUS_OUT] := (qGetData.FieldByName('OSTATOCHNO_VYBUV').AsInteger > 0);

  rgRegistration_Status.ItemIndex := qGetData.FieldByName('STATUS_PROZHYVANNIA').AsInteger;

  qGetData.Close;

  Relationship := RelationshipExist(House_ID, Person_ID, Declarant_ID);

  lcbRelationship.KeyValue := Relationship.Kind;
end;

Procedure TfrmInhabitant_Edit.SetSavedValue();
Begin
  Saved_Registration_Date   := edtRegistration.Date;
  Saved_Eviction_Date       := edtEviction.Date;
  Saved_Eviction_Temp       := chgEviction.Checked[EVICTION_STATUS_TMP];
  Saved_Eviction            := chgEviction.Checked[EVICTION_STATUS_OUT];
  Saved_Registration_Status := rgRegistration_Status.ItemIndex;
  Saved_Relationship        := lcbRelationship.KeyValue;
End;

procedure TfrmInhabitant_Edit.SetWindowSize();
begin
  if is_House then
  begin
    pnlDeclarant.Visible := False;

    ClientHeight := pnlMeshkantsi.Height +
                    pnlButtons.Height +
                    2 * BorderWidth;
  end;
end;

Function TfrmInhabitant_Edit.GetPersonName(AID : Integer) : String;
begin
  qGetPerson.Close;
  qGetPerson.ParamByName('ID').Value := AID;
  qGetPerson.Open;

  Result := qGetPerson.FieldByName('PIB').AsString;

  qGetPerson.Close;
end;

Function TfrmInhabitant_Edit.RelationshipDefault() : TRelationship;
begin
  Result.ID    := -1;
  Result.House := -1;
  Result.Kind  := -1;
  Result.Who   := -1;
  Result.Whom  := -1;
end;

Function TfrmInhabitant_Edit.RelationshipExist(AHouse, AWho, AWhom : Integer) : TRelationship;
begin
  Result := RelationshipDefault();

  qGetRelationship.Close;
  qGetRelationship.ParamByName('ID_Hospodarstvo').Value    := AHouse;
  qGetRelationship.ParamByName('ID_Naselennia_Khto').Value := AWho;
  qGetRelationship.ParamByName('ID_Naselennia_Komu').Value := AWhom;
  qGetRelationship.Open;

  Result.ID    := VarToInt(qGetRelationship.FieldByName('ID').Value,                   -1);
  Result.House := VarToInt(qGetRelationship.FieldByName('ID_HOSPODARSTVO').Value,      -1);
  Result.Who   := VarToInt(qGetRelationship.FieldByName('ID_NASELENNIA_KHTO').Value,   -1);
  Result.Whom  := VarToInt(qGetRelationship.FieldByName('ID_NASELENNIA_KOMU').Value,   -1);
  Result.Kind  := VarToInt(qGetRelationship.FieldByName('ID_TYP_SPORIDNENOSTI').Value, -1);

  qGetRelationship.Close;
end;

Function TfrmInhabitant_Edit.RelationshipChange(AOperation : Byte;
                                                ARelationship : TRelationship) : Integer;
begin
  if AOperation = 0 then
  begin
    Result := -2;

    MessageDlg('Корекція відносин',
               'Модуль: Tdm.RelationshipChange' + #13#10 +
                                                  #13#10 +
               'Виникла наступна помилка:'      + #13#10 +
               ' > Некоректний тип операції!'   + #13#10 +
                                                  #13#10 +
               'Зміни не збережено!',
               mtError, [mbOK], '');
    Exit;
  end;

  case AOperation of
    ADD_OPERATION : sqlRelationship.SQL := sqlRelationship.InsertSQL;
    UPD_OPERATION : sqlRelationship.SQL := sqlRelationship.UpdateSQL;
    DEL_OPERATION : sqlRelationship.SQL := sqlRelationship.DeleteSQL;
  end;

  if (AOperation = ADD_OPERATION) or
     (AOperation = UPD_OPERATION)
  then
  begin
    sqlRelationship.ParamByName('ID_Hospodarstvo').Value          := ARelationship.House;
    sqlRelationship.ParamByName('ID_Typ_Sporidnenosti').AsInteger := ARelationship.Kind;
    sqlRelationship.ParamByName('ID_Naselennia_Khto').Value       := ARelationship.Who;
    sqlRelationship.ParamByName('ID_Naselennia_Komu').Value       := ARelationship.Whom;
  end;

  if AOperation = ADD_OPERATION
  then sqlRelationship.ParamByName('ID').Value := Null
  else sqlRelationship.ParamByName('ID').Value := ARelationship.ID;

  sqlRelationship.ExecSQL;

  Result := ARelationship.ID;

  if AOperation = ADD_OPERATION then
  begin
    dm.qGetID.Open;

    Result := dm.qGetID.FieldByName('ID').AsInteger;

    dm.qGetID.Close;
  end;
end;

constructor TfrmInhabitant_Edit.CreateFromHouseTab(Sender : TComponent; AHouse, APerson,             ARelationship : Integer; var APK : Integer; var AChanged : Boolean);
begin
  Inherited Create(Sender);

  PPrimary  := @APK;
  PChanged  := @AChanged;
  PChanged^ :=  False;

  House_ID        :=  AHouse;
  Person_ID       :=  APerson;
  Declarant_ID    := -1;
  Relationship_ID :=  ARelationship;
  Inhabitant_ID   :=  APK;

  is_House  := True;
  is_Family := False;
End;

constructor TfrmInhabitant_Edit.CreateFromPopulationTab(Sender : TComponent; AHouse, APerson, ADeclarant, ARelationship : Integer; var APK : Integer; var AChanged : Boolean);
begin
  Inherited Create(Sender);

  PPrimary  := @APK;
  PChanged  := @AChanged;
  PChanged^ :=  False;

  House_ID        := AHouse;
  Person_ID       := APerson;
  Declarant_ID    := ADeclarant;
  Relationship_ID := ARelationship;
  Inhabitant_ID   := APK;

  is_House  := False;
  is_Family := True;
End;

Procedure TfrmInhabitant_Edit.FormCreate(Sender : TObject);
Begin
  is_Start := False;

  qRelationship.Open;
  qRelationship.Last;
  qRelationship.First;

  RelationshipDefault();

  qGetHouse.Close;
  qGetHouse.ParamByName('ID').Value := House_ID;
  qGetHouse.Open;

  edtVillage.Text := qGetHouse.FieldByName('NAZVA').AsString;
  edtAddress.Text := qGetHouse.FieldByName('ADRESA').AsString;

  qGetHouse.Close;

  edtPerson.Text := GetPersonName(Person_ID);

  if is_Family then
  begin
    edtDeclarant.Text := GetPersonName(Declarant_ID);
  end;

  lblPerson_Name.Caption := ' > ' + edtPerson.Text;

  is_New_Inhabitant   := (Inhabitant_ID   < 0);
  is_New_Relationship := (Relationship_ID < 0);

  GetSavedValue();

  if is_New_Inhabitant then
  begin
    Caption := '[Мешканці господарства] Новий запис';

    edtRegistration.Date := Date;
    edtEviction.Date     := NullDate;

    rgRegistration_Status.ItemIndex := 0;

    chgEviction.Checked[EVICTION_STATUS_TMP] := False;
    chgEviction.Checked[EVICTION_STATUS_OUT] := False;
  end
  else
  begin
    Caption := '[Мешканці господарства] Корекція';
  end;

  SetSavedValue();
  SetWindowSize();

  is_Start := True;

  OnFieldChange(nil);
end;

procedure TfrmInhabitant_Edit.edtRegistrationCheckBoxChange(Sender: TObject);
begin
  if edtRegistration.Checked
  then edtRegistration.Date := Date
  else edtRegistration.Date := NullDate;

  if edtEviction.Checked
  then edtEviction.Date := Date
  else edtEviction.Date := NullDate;

  OnFieldChange(edtRegistration);
end;

Procedure TfrmInhabitant_Edit.FormCloseQuery(Sender : TObject; Var CanClose : Boolean);
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

Procedure TfrmInhabitant_Edit.FormClose(Sender : TObject;	Var CloseAction : TCloseAction);
Begin
  is_Start := False;

  qRelationship.Close;

  CloseAction := caFree;
end;

Procedure TfrmInhabitant_Edit.btnCloseClick(Sender : TObject);
Begin
  Close;
end;

Procedure TfrmInhabitant_Edit.btnSaveClick(Sender : TObject);
var
  rOperation : Byte;
  Relationship : TRelationship;
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

    if is_New_Inhabitant or
       is_Upd_Inhabitant
    then
    begin
      if is_New_Inhabitant
      then sqlInhabitant.SQL := sqlInhabitant.InsertSQL
      else sqlInhabitant.SQL := sqlInhabitant.UpdateSQL;

      if is_New_Inhabitant
      then sqlInhabitant.ParamByName('ID').Value := Null
      else sqlInhabitant.ParamByName('ID').Value := Inhabitant_ID;

      sqlInhabitant.ParamByName('ID_Hospodarstvo').AsInteger := House_ID;
      sqlInhabitant.ParamByName('ID_Naselennia').AsInteger   := Person_ID;

      if edtRegistration.Date = NullDate
      then sqlInhabitant.ParamByName('Data_Reiestratsii').Value  := Null
      else sqlInhabitant.ParamByName('Data_Reiestratsii').AsDate := edtRegistration.Date;

      if edtEviction.Date = NullDate
      then sqlInhabitant.ParamByName('Data_Vybuttia').Value  := Null
      else sqlInhabitant.ParamByName('Data_Vybuttia').AsDate := edtEviction.Date;

      sqlInhabitant.ParamByName('Tymchasovo_Vybuv').AsInteger := BoolToInt(chgEviction.Checked[EVICTION_STATUS_TMP]);
      sqlInhabitant.ParamByName('Ostatochno_Vybuv').AsInteger := BoolToInt(chgEviction.Checked[EVICTION_STATUS_OUT]);

      sqlInhabitant.ParamByName('Status_Prozhyvannia').AsInteger := rgRegistration_Status.ItemIndex;

      sqlInhabitant.ExecSQL;

      if is_New_Inhabitant then Inhabitant_ID := dm.GetLastInsertID();
    end;

    if is_New_Relationship or
       is_Upd_Relationship
    then
    begin
      Relationship := RelationshipExist(House_ID, Person_ID, Declarant_ID);

      Relationship.House := House_ID;
      Relationship.Who   := Person_ID;
      Relationship.Whom  := Declarant_ID;
      Relationship.Kind  := lcbRelationship.KeyValue;

      rOperation := 0;

      if is_New_Relationship then
      begin
        if Relationship.ID > 0
        then rOperation := UPD_OPERATION
        else rOperation := ADD_OPERATION;
      end
      else
      if is_Upd_Relationship then
      begin
        rOperation := UPD_OPERATION;
      end;

      RelationshipChange(rOperation, Relationship);
    end;

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    PChanged^ := True;
    PPrimary^ := Inhabitant_ID;

    if is_New_Inhabitant then
    begin
      is_New_Inhabitant   := False;
      is_New_Relationship := False;
    end;

    SetSavedValue();
    OnFieldChange(nil);

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

Procedure TfrmInhabitant_Edit.btnRelationshipClick(Sender : TObject);
var
  ID : Integer;
  DataChanged : Boolean;
  Temp_lcbRelationship : TDBLookupComboBox;
  Temp_qRelationship : TSQLQuery;
Begin
  if Sender = btnRelationship then
  begin
    Temp_lcbRelationship := lcbRelationship;
    Temp_qRelationship   := qRelationship;
  end
  else Exit;

  ID := Temp_lcbRelationship.KeyValue;

  DataChanged := False;

  with TfrmReference.CreateSelect(Self, 'Довідник зв''язків',
                                        'TYP_SPORIDNENOSTI',
                                         Null,
                                         ID,
                                         DataChanged)
  Do
  begin
    Select := TSelect.Create();

    ShowModal;

    if Select.Success then ID := Select.Code;

    Free;
  End;

  If ID = Temp_lcbRelationship.KeyValue then Exit;

  if DataChanged then
  begin
    Temp_qRelationship.Close;
    Temp_qRelationship.Open;
    Temp_qRelationship.Last;
	End;

	Temp_lcbRelationship.KeyValue := ID;

  OnFieldChange(nil);

  SelectNext(ActiveControl, True, True);
end;

procedure TfrmInhabitant_Edit.chgEvictionItemClick(Sender : TObject; Index : integer);
begin
  OnFieldChange(Sender);
end;

Procedure TfrmInhabitant_Edit.OnFieldChange(Sender : TObject);
Begin
  if not is_Start then Exit;

  if Sender = edtEviction then
  begin
    if edtEviction.DateIsNull then
    begin
      chgEviction.Checked[EVICTION_STATUS_TMP] := False;
      chgEviction.Checked[EVICTION_STATUS_OUT] := False;
    end;
	End
  else
  if Sender = chgEviction then
  begin
    if (chgEviction.Checked[EVICTION_STATUS_TMP]) or
       (chgEviction.Checked[EVICTION_STATUS_OUT])
    then edtEviction.Date := Date
    else edtEviction.Date := NullDate;
	End;

  //btnSave.Visible :=     (edtRegistration.Date   <> NullDate)
  //                  and ((edtEviction.Date       <> NullDate) or
  //                       (rgRetirement.ItemIndex  = 0));

  is_Upd_Inhabitant := (Saved_Registration_Date   <> edtRegistration.Date)                     or
                       (Saved_Eviction_Date       <> edtEviction.Date)                         or
                       (Saved_Eviction            <> chgEviction.Checked[EVICTION_STATUS_OUT]) or
                       (Saved_Eviction_Temp       <> chgEviction.Checked[EVICTION_STATUS_TMP]) or
                       (Saved_Registration_Status <> rgRegistration_Status.ItemIndex);

  is_Upd_Relationship := (Saved_Relationship <> lcbRelationship.KeyValue);

  btnSave.Enabled := is_New_Inhabitant or
                     is_Upd_Inhabitant or
                     is_Upd_Relationship;

//  if  (edtRegistration.Date <> NullDate) then edtRegistration.Color := clDefault else edtRegistration.Color := clErrorField;
//  if ((edtEviction.Date     <> NullDate) or
//      (rgRetirement.ItemIndex      = 0)) then edtEviction.Color   := clDefault else edtEviction.Color   := clErrorField;
end;

Procedure TfrmInhabitant_Edit.OnFieldUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
Begin
  case UTF8Key of
     #8 : ; // BackSpace
    #27 : ;
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = lcbRelationship
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    '0'..'9' : ;
    'А'..'Я', 'І', 'Ї', 'Є', 'Ґ' : ;
    'а'..'я', 'і', 'ї', 'є', 'ґ' : ;
    else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                              PChar(Caption),
                              MB_OK + MB_ICONSTOP);
    end;
  end;
end;

End.

