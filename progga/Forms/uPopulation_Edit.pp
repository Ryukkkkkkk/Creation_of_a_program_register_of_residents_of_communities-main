Unit uPopulation_Edit;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, sqldb, db, FileUtil, RTTICtrls, DateTimePicker, Forms,
	Controls, Graphics, Dialogs, ExtCtrls, Buttons, LCLType, StdCtrls, DbCtrls,
	ActnList, ComCtrls, MaskEdit, LazUTF8, uFunctions;

Type
  { TfrmPopulation_Edit }
  TfrmPopulation_Edit = Class(TForm)
    btnAddress : TBitBtn;
    btnClose : TBitBtn;
    btnSave : TBitBtn;
		dsCitizenship : TDataSource;
    edtAddress : TEdit;
    edtBirthDay : TDateTimePicker;
    edtBirthPlace : TEdit;
    edtDeathDay : TDateTimePicker;
    edtFirstName : TEdit;
    edtIPN : TEdit;
    edtLastName : TEdit;
    edtNotes : TMemo;
    edtPassportAgency : TEdit;
    edtPassportDate : TDateTimePicker;
    edtPassportNumber : TEdit;
    edtPassportSeries : TEdit;
    edtPhone : TEdit;
    edtMiddleName : TEdit;
    edtPIB_Davalnyi : TEdit;
    edtPIB_Rodovyi : TEdit;
    grpAddress : TGroupBox;
    grpBirthDay : TGroupBox;
    grpBirthPlace : TGroupBox;
    grpCitizenship : TGroupBox;
    grpDeathDay : TGroupBox;
    grpFirstName : TGroupBox;
    grpIPN : TGroupBox;
    grpLastName : TGroupBox;
    grpMiddleName : TGroupBox;
    grpNotes : TGroupBox;
    grpPassportAgency : TGroupBox;
    grpPassportDate : TGroupBox;
    grpPassportSeriesAndNumber : TGroupBox;
    grpPhone : TGroupBox;
    grpPIB_Davalnyi : TGroupBox;
    grpPIB_Rodovyi : TGroupBox;
    grpYeDDR : TGroupBox;
    lcbCitizenship : TDBLookupComboBox;
    medtYeDDR: TMaskEdit;
    pcInfo : TPageControl;
    pnlBorder : TPanel;
    pnlButtons : TPanel;
    pnlDates : TPanel;
    pnlDatesAndSex : TPanel;
    pnlInfo : TPanel;
    pnlInfo_Left : TPanel;
    pnlPassport : TPanel;
    pnlIPNAndYeDDR : TPanel;
		qCitizenship : TSQLQuery;
		qGetHouse : TSQLQuery;
    rgSex : TRadioGroup;
    sqlPerson : TSQLQuery;
    qGetData : TSQLQuery;
    tsMain_Data : TTabSheet;
    tsOther_Data : TTabSheet;
    procedure btnAddressClick(Sender : TObject);
    procedure edtDeathDayCheckBoxChange(Sender: TObject);
    Procedure FormCreate(Sender : TObject);
    Procedure FormCloseQuery(Sender : TObject; Var CanClose : boolean);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure btnCloseClick(Sender : TObject);
    Procedure btnSaveClick(Sender : TObject);
    Procedure OnPIBEnter(Sender : TObject);
    Procedure OnFieldChange(Sender : TObject);
    Procedure OnFieldUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
    Procedure OnNumbersUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
    Procedure OnLettersUTF8KeyPress(Sender : TObject;	Var UTF8Key : TUTF8Char);
    Procedure OnNumbersAndLettersUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
    Procedure OnPhoneUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
  Private
    { private declarations }
    PPrimary : PInteger;
    PChanged : PBoolean;
    ID, House : Integer;
    is_Start : Boolean;
    Saved_FirstName, Saved_MiddleName, Saved_LastName,
    Saved_BirthPlace, Saved_BirthDay, Saved_DeathDay,
    Saved_PassportSeries, Saved_PassportNumber,
    Saved_PassportDate, Saved_PassportAgency,
    Saved_Address, Saved_Phone, Saved_IPN,
    Saved_PIB_Davalnyi, Saved_PIB_Rodovyi,
    Saved_Notes, Saved_Yeddr,
    Saved_Citizenship : Variant;
    Saved_Sex : Byte;
    procedure GetSavedValue();
    procedure SetSavedValue();
    procedure SetTextFieldsLimits();
  Public
    { public declarations }
    constructor CreatePerson(Sender : TComponent; AHouse : Integer;
      var AID : Integer; var AChanged : Boolean);
  End;

Var
  frmPopulation_Edit : TfrmPopulation_Edit;

Implementation

uses
  udm, uAddress_Edit;

{$R *.lfm}

{ TfrmPopulation_Edit }

procedure TfrmPopulation_Edit.GetSavedValue();
begin
  qGetData.Close;
  qGetData.ParamByName('ID').Value := ID;
  qGetData.Open;

  edtLastName.Text        := qGetData.FieldByName('PRIZVYSHCHE').AsString;
  edtFirstName.Text       := qGetData.FieldByName('IMIA').AsString;
  edtMiddleName.Text      := qGetData.FieldByName('PO_BATKOVI').AsString;
  rgSex.ItemIndex         := qGetData.FieldByName('STAT').AsInteger;
  edtBirthPlace.Text      := qGetData.FieldByName('MISTSE_NARODZHENNIA').AsString;
  edtPhone.Text           := qGetData.FieldByName('NOMER_TELEFONU').AsString;
  edtNotes.Text           := qGetData.FieldByName('PRYMITKY').AsString;
  edtPIB_Rodovyi.Text     := qGetData.FieldByName('PIB_RODOVYI').AsString;
  edtPIB_Davalnyi.Text    := qGetData.FieldByName('PIB_DAVALNYI').AsString;
  edtAddress.Text         := qGetData.FieldByName('ADRESA').AsString;
  edtPassportSeries.Text  := qGetData.FieldByName('SERIIA_PASPORTU').AsString;
  edtPassportNumber.Text  := qGetData.FieldByName('NOMER_PASPORTU').AsString;
  edtPassportAgency.Text  := qGetData.FieldByName('ORGAN_PASPORTU').AsString;
  edtIPN.Text             := qGetData.FieldByName('IPN').AsString;
  medtYeDDR.Text          := qGetData.FieldByName('YEDDR_NOMER').AsString;
  lcbCitizenship.KeyValue := qGetData.FieldByName('ID_HROMADIANSTVO').AsInteger;

  if qGetData.FieldByName('DATA_NARODZHENNIA').IsNull
  then edtBirthDay.Date  := NullDate
  else edtBirthDay.Date  := qGetData.FieldByName('DATA_NARODZHENNIA').AsDateTime;

  if qGetData.FieldByName('DATA_SMERTI').IsNull then
  begin
    edtDeathDay.Checked := False;
    edtDeathDay.Date    := NullDate;
  end
  else
  begin
    edtDeathDay.Checked := True;
    edtDeathDay.Date    := qGetData.FieldByName('DATA_SMERTI').AsDateTime;
  end;

  if qGetData.FieldByName('DATA_PASPORTU').IsNull
  then edtPassportDate.Date := NullDate
  else edtPassportDate.Date := qGetData.FieldByName('DATA_PASPORTU').AsDateTime;

  qGetData.Close;
end;

procedure TfrmPopulation_Edit.SetSavedValue();
begin
  Saved_LastName       := edtLastName.Text;
  Saved_FirstName      := edtFirstName.Text;
  Saved_MiddleName     := edtMiddleName.Text;
  Saved_Sex            := rgSex.ItemIndex;
  Saved_BirthDay       := edtBirthDay.Date;
  Saved_DeathDay       := edtDeathDay.Date;
  Saved_BirthPlace     := edtBirthPlace.Text;
  Saved_Phone          := edtPhone.Text;
  Saved_Notes          := edtNotes.Text;
  Saved_PIB_Rodovyi    := edtPIB_Rodovyi.Text;
  Saved_PIB_Davalnyi   := edtPIB_Davalnyi.Text;
  Saved_Address        := edtAddress.Text;
  Saved_PassportSeries := edtPassportSeries.Text;
  Saved_PassportNumber := edtPassportNumber.Text;
  Saved_PassportDate   := edtPassportDate.Date;
  Saved_PassportAgency := edtPassportAgency.Text;
  Saved_IPN            := edtIPN.Text;
  Saved_Yeddr          := medtYeDDR.Text;
  Saved_Citizenship    := lcbCitizenship.KeyValue;
End;

procedure TfrmPopulation_Edit.SetTextFieldsLimits();
begin
  dm.StartSetColumnsLimit('naselennia');

  edtLastName.MaxLength       := dm.GetColumnsLimit('prizvyshche');
  edtFirstName.MaxLength      := dm.GetColumnsLimit('imia');
  edtMiddleName.MaxLength     := dm.GetColumnsLimit('po_batkovi');
  edtBirthPlace.MaxLength     := dm.GetColumnsLimit('mistse_narodzhennia');
  edtPhone.MaxLength          := dm.GetColumnsLimit('nomer_telefonu');
  edtNotes.MaxLength          := dm.GetColumnsLimit('prymitky');
  edtPIB_Rodovyi.MaxLength    := dm.GetColumnsLimit('pib_rodovyi');
  edtPIB_Davalnyi.MaxLength   := dm.GetColumnsLimit('pib_davalnyi');
  edtAddress.MaxLength        := dm.GetColumnsLimit('adresa');
  edtPassportSeries.MaxLength := dm.GetColumnsLimit('seriia_pasportu');
  edtPassportNumber.MaxLength := dm.GetColumnsLimit('nomer_pasportu');
  edtPassportAgency.MaxLength := dm.GetColumnsLimit('organ_pasportu');
  edtIPN.MaxLength            := dm.GetColumnsLimit('ipn');
  medtYeDDR.MaxLength         := dm.GetColumnsLimit('yeddr_nomer');

  dm.FinishSetColumnsLimit();
end;

constructor TfrmPopulation_Edit.CreatePerson(Sender : TComponent; AHouse : Integer;
  var AID : Integer; var AChanged : Boolean);
begin
  Inherited Create(Sender);

  PPrimary := @AID;
  PChanged := @AChanged;

  PChanged^ := False;

  House := AHouse;
  ID    := AID;
End;

Procedure TfrmPopulation_Edit.FormCreate(Sender : TObject);
Begin
  is_Start := False;

  qCitizenship.Open;
  qCitizenship.Last;
  qCitizenship.First;

  if ID < 0 then
  begin
    Caption := '[Населення] Новий запис';

    lcbCitizenship.KeyValue := CITIZENSHIP_UKR;

    if House > 0 then
    begin
      qGetHouse.Close;
      qGetHouse.ParamByName('ID').AsInteger := House;
      qGetHouse.Open;

      edtAddress.Text := qGetHouse.FieldByName('ADRESA').AsString;

      qGetHouse.Close;
		End;
	End
  else
  begin
    Caption := '[Населення] Корекція';

    GetSavedValue();
  end;

  SetSavedValue();
  SetTextFieldsLimits();

  is_Start := True;

  OnFieldChange(nil);
end;

procedure TfrmPopulation_Edit.edtDeathDayCheckBoxChange(Sender: TObject);
begin
  if edtDeathDay.Checked then
  begin
    edtDeathDay.Date := Date;
  end
  else
  begin
    edtDeathDay.Date := NullDate;
  end;

  OnFieldChange(edtDeathDay);
end;

procedure TfrmPopulation_Edit.btnAddressClick(Sender : TObject);
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

Procedure TfrmPopulation_Edit.FormCloseQuery(Sender : TObject; Var CanClose : Boolean);
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

Procedure TfrmPopulation_Edit.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
Begin
  is_Start := False;

  qCitizenship.Close;

  CloseAction := caFree;
end;

Procedure TfrmPopulation_Edit.btnCloseClick(Sender : TObject);
Begin
  Close;
end;

Procedure TfrmPopulation_Edit.btnSaveClick(Sender : TObject);
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

    if ID < 0 then
    begin // Insert
      sqlPerson.SQL := sqlPerson.InsertSQL;
    end
    else
    begin // Update
      sqlPerson.SQL := sqlPerson.UpdateSQL;

      sqlPerson.ParamByName('ID').AsInteger := ID;
    end;

    sqlPerson.ParamByName('Prizvyshche').AsString         := edtLastName.Text;
    sqlPerson.ParamByName('Imia').AsString                := edtFirstName.Text;
    sqlPerson.ParamByName('Po_Batkovi').AsString          := edtMiddleName.Text;
    sqlPerson.ParamByName('PIB_Rodovyi').AsString         := edtPIB_Rodovyi.Text;
    sqlPerson.ParamByName('PIB_Davalnyi').AsString        := edtPIB_Davalnyi.Text;
    sqlPerson.ParamByName('Adresa').AsString              := edtAddress.Text;
    sqlPerson.ParamByName('Stat').AsInteger               := rgSex.ItemIndex;
    sqlPerson.ParamByName('Data_Narodzhennia').AsDate     := edtBirthDay.Date;
    sqlPerson.ParamByName('Mistse_Narodzhennia').AsString := edtBirthPlace.Text;
    sqlPerson.ParamByName('Seriia_Pasportu').AsString     := edtPassportSeries.Text;
    sqlPerson.ParamByName('Nomer_Pasportu').AsString      := edtPassportNumber.Text;
    sqlPerson.ParamByName('Organ_Pasportu').AsString      := edtPassportAgency.Text;
    sqlPerson.ParamByName('IPN').AsString                 := edtIPN.Text;
    sqlPerson.ParamByName('YeDDR_Nomer').AsString         := medtYeDDR.Text;
    sqlPerson.ParamByName('Nomer_Telefonu').AsString      := edtPhone.Text;
    sqlPerson.ParamByName('Prymitky').AsString            := edtNotes.Text;
    sqlPerson.ParamByName('ID_Hromadianstvo').Value       := lcbCitizenship.KeyValue;

    if edtDeathDay.DateIsNull
    then sqlPerson.ParamByName('Data_Smerti').Value  := Null
    else sqlPerson.ParamByName('Data_Smerti').AsDate := edtDeathDay.Date;

    if edtPassportDate.DateIsNull
    then sqlPerson.ParamByName('Data_Pasportu').Value  := Null
    else sqlPerson.ParamByName('Data_Pasportu').AsDate := edtPassportDate.Date;

    sqlPerson.ExecSQL;

    if ID < 0 then ID := dm.GetLastInsertID();

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    PChanged^ := True;
    PPrimary^ := ID;

    SetSavedValue();
    OnFieldChange(nil);
  Except
    on E:Exception do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Модуль: ' + E.ClassName    + LineEnding +
                                                                 LineEnding +
                                   'Виникла наступна помилка:' + LineEnding +
                                    E.Message                  + LineEnding +
                                                                 LineEnding +
                                   'Зміни не збережено '       + LineEnding +
                                   'Закрийте вікно і повторіть спробу.'),
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    End;
  End;

  Close;
end;

Procedure TfrmPopulation_Edit.OnPIBEnter(Sender : TObject);
Begin
  if EmptyStr((Sender as TEdit).Text) then
  begin
    (Sender as TEdit).Text := edtLastName.Text  + ' ' +
                              edtFirstName.Text + ' ' +
                              edtMiddleName.Text;
	End;
end;

Procedure TfrmPopulation_Edit.OnFieldChange(Sender : TObject);
Begin
  if not is_Start then Exit;

  btnSave.Visible :=     FullStr(edtLastName.Text)
                     and FullStr(edtFirstName.Text)
                     and FullStr(edtMiddleName.Text)
                     and        (edtBirthDay.Date <> Null);
                     //and FullStr(edtPIB_Rodovyi.Text)
                     //and FullStr(edtPIB_Davalnyi.Text)
                     //and FullStr(edtAddress.Text)
                     //and FullStr(edtPassportSeries.Text)
                     //and FullStr(edtPassportNumber.Text)
                     //and           (edtPassportDate.Text <> Null)
                     //and FullStr(edtPassportAgency.Text)
                     //and FullStr(edtIPN.Text)
                     //and FullStr(edtYeDDR.Text)
                     //and FullStr(edtBirthPlace.Text)
                     //and FullStr(edtPhone.Text)
                     //and FullStr(edtNotes.Text);

  btnSave.Enabled := (Saved_LastName       <> edtLastName.Text)       or
                     (Saved_FirstName      <> edtFirstName.Text)      or
                     (Saved_MiddleName     <> edtMiddleName.Text)     or
                     (Saved_Sex            <> rgSex.ItemIndex)        or
                     (Saved_BirthDay       <> edtBirthDay.Date)       or
                     (Saved_DeathDay       <> edtDeathDay.Date)       or
                     (Saved_BirthPlace     <> edtBirthPlace.Text)     or
                     (Saved_Phone          <> edtPhone.Text)          or
                     (Saved_Notes          <> edtNotes.Text)          or
                     (Saved_PIB_Rodovyi    <> edtPIB_Rodovyi.Text)    or
                     (Saved_PIB_Davalnyi   <> edtPIB_Davalnyi.Text)   or
                     (Saved_Address        <> edtAddress.Text)        or
                     (Saved_PassportSeries <> edtPassportSeries.Text) or
                     (Saved_PassportNumber <> edtPassportNumber.Text) or
                     (Saved_PassportDate   <> edtPassportDate.Date)   or
                     (Saved_PassportAgency <> edtPassportAgency.Text) or
                     (Saved_IPN            <> edtIPN.Text)            or
                     (Saved_Yeddr          <> medtYeDDR.Text)         or
                     (Saved_Citizenship    <> lcbCitizenship.KeyValue);

  if FullStr(edtLastName.Text)             then edtLastName.Color       := clDefault else edtLastName.Color       := COLOR_ERROR_FIELD;
  if FullStr(edtFirstName.Text)            then edtFirstName.Color      := clDefault else edtFirstName.Color      := COLOR_ERROR_FIELD;
  if FullStr(edtMiddleName.Text)           then edtMiddleName.Color     := clDefault else edtMiddleName.Color     := COLOR_ERROR_FIELD;
  if        (edtBirthDay.Date <> Null)     then edtBirthDay.Color       := clDefault else edtBirthDay.Color       := COLOR_ERROR_FIELD;
//  if FullStr(edtPIB_Rodovyi.Text)          then edtPIB_Rodovyi.Color    := clDefault else edtPIB_Rodovyi.Color    := COLOR_ERROR_FIELD;
//  if FullStr(edtPIB_Davalnyi.Text)         then edtPIB_Davalnyi.Color   := clDefault else edtPIB_Davalnyi.Color   := COLOR_ERROR_FIELD;
//  if FullStr(edtAddress.Text)              then edtAddress.Color        := clDefault else edtAddress.Color        := COLOR_ERROR_FIELD;
//  if FullStr(edtPassportSeries.Text)       then edtPassportSeries.Color := clDefault else edtPassportSeries.Color := COLOR_ERROR_FIELD;
//  if FullStr(edtPassportNumber.Text)       then edtPassportNumber.Color := clDefault else edtPassportNumber.Color := COLOR_ERROR_FIELD;
//  if        (edtPassportDate.Text <> Null) then edtPassportDate.Color   := clDefault else edtPassportDate.Color   := COLOR_ERROR_FIELD;
//  if FullStr(edtPassportAgency.Text)       then edtPassportAgency.Color := clDefault else edtPassportAgency.Color := COLOR_ERROR_FIELD;
//  if FullStr(edtIPN.Text)                  then edtIPN.Color            := clDefault else edtIPN.Color            := COLOR_ERROR_FIELD;
//  if FullStr(edtYeDDR.Text)                then edtYeDDR.Color          := clDefault else edtYeDDR.Color          := COLOR_ERROR_FIELD;
//  if FullStr(edtBirthPlace.Text)           then edtBirthPlace.Color     := clDefault else edtBirthPlace.Color     := COLOR_ERROR_FIELD;
//  if FullStr(edtPhone.Text)                then edtPhone.Color          := clDefault else edtPhone.Color          := COLOR_ERROR_FIELD;
//  if FullStr(edtNotes.Text);               then edtNotes.Color          := clDefault else edtNotes.Color          := COLOR_ERROR_FIELD;
end;

Procedure TfrmPopulation_Edit.OnFieldUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
Begin
  case UTF8Key of
     #8 : ; // BackSpace
    #27 : ;
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = medtYeDDR
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    '0'..'9' : ;
    'А'..'Я', 'І', 'Ї', 'Є', 'Ґ' : ;
    'а'..'я', 'і', 'ї', 'є', 'ґ' : ;
    '-', '.',',','’', '"', '''', ' ': ;
    else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    end;
  end;
end;

Procedure TfrmPopulation_Edit.OnNumbersUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
Begin
  case UTF8Key of
     #8 : ; // BackSpace
    #27 : ; // Esc
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = medtYeDDR
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    '0'..'9' : ;
  else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    end;
  end;
end;

Procedure TfrmPopulation_Edit.OnLettersUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
Begin
  case UTF8Key of
     #8 : ; // BackSpace
    #27 : ; // Esc
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = medtYeDDR
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    'А'..'Я', 'І', 'Ї', 'Є', 'Ґ' : ;
    'а'..'я', 'і', 'ї', 'є', 'ґ' : ;
    '-', ' ', '''' : ;
  else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    end;
  end;
end;

Procedure TfrmPopulation_Edit.OnNumbersAndLettersUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
Begin
  case UTF8Key of
     #8 : ; // BackSpace
    #27 : ; // Esc
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = medtYeDDR
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    '0'..'9' : ;
    'А'..'Я', 'І', 'Ї', 'Є', 'Ґ' : ;
    'а'..'я', 'і', 'ї', 'є', 'ґ' : ;
    '-', '/', ' ' : ;
  else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    end;
  end;
end;

Procedure TfrmPopulation_Edit.OnPhoneUTF8KeyPress(Sender : TObject;  Var UTF8Key : TUTF8Char);
Begin
  case UTF8Key of
     #8 : ; // BackSpace
    #27 : ; // Esc
    #10 : begin
            btnSave.Click;
          end;
    #13 : begin
            if Sender = medtYeDDR
            then btnSave.Click
            else SelectNext(ActiveControl, True, True);
          end;
    '0'..'9' : ;
    '(', ')' : ;
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

