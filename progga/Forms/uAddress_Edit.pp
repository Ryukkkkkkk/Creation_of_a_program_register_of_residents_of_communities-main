unit uAddress_Edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DbCtrls, Buttons, ExtCtrls, LazUTF8, LCLType, ActnList, udm, uSelect;

type
  { TfrmAddress_Edit }
  TfrmAddress_Edit = class(TForm)
    ActionList : TActionList;
    actReference : TAction;
    btnClose : TBitBtn;
    btnSave : TBitBtn;
    btnStreet : TBitBtn;
    cbLocality_Type : TComboBox;
    dsArea : TDataSource;
    dsRegion : TDataSource;
    dsStreet_Type : TDataSource;
    edtAddress : TEdit;
    edtApartment : TEdit;
    edtHouse : TEdit;
    edtLocality : TEdit;
    edtStreet : TEdit;
    grpAddress : TGroupBox;
    grpApartment : TGroupBox;
    grpArea : TGroupBox;
    grpHouse : TGroupBox;
    grpLocality : TGroupBox;
    grpRegion : TGroupBox;
    grpStreet : TGroupBox;
    lcbArea : TDBLookupComboBox;
    lcbRegion : TDBLookupComboBox;
    lcbStreet_Type : TDBLookupComboBox;
    pnlButtons : TPanel;
    qArea : TSQLQuery;
    qRegion : TSQLQuery;
    qStreet_Type : TSQLQuery;
    procedure OnAddressChange(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure FormCloseQuery(Sender : TObject; var CanClose : Boolean);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure btnCloseClick(Sender : TObject);
    procedure btnSaveClick(Sender : TObject);
    Procedure btnStreetClick(Sender : TObject);
    Procedure actReferenceExecute(Sender : TObject);
    Procedure OnFieldChange(Sender : TObject);
    Procedure OnFieldUTF8KeyPress(Sender : TObject; var UTF8Key : TUTF8Char);
  private
    PAddress : PString;
    PChanged : PBoolean;
    is_Start, is_Population, is_House : Boolean;
    Saved_Address : Variant;
    procedure SetTextFieldsLimits();
  public
    Constructor CreateFromPopulation(Sender : TComponent; var AAddress : String; var AChanged : Boolean);
    Constructor CreateFromHouse(Sender : TComponent; var AAddress : String; var AChanged : Boolean);
  end;

var
  frmAddress_Edit : TfrmAddress_Edit;

implementation

uses
  uReference;

{$R *.lfm}

{ TfrmAddress_Edit }

procedure TfrmAddress_Edit.SetTextFieldsLimits();
begin
  if is_Population then
  begin
    dm.StartSetColumnsLimit('naselennia');

    edtAddress.MaxLength := dm.GetColumnsLimit('adresa');

    dm.FinishSetColumnsLimit();
  end
  else
  if is_House then
  begin
    dm.StartSetColumnsLimit('hospodarstvo');

    edtAddress.MaxLength := dm.GetColumnsLimit('adresa');

    dm.FinishSetColumnsLimit();
  end;
end;

Constructor TfrmAddress_Edit.CreateFromPopulation(Sender : TComponent;
  var AAddress : String; var AChanged : Boolean);
begin
  Inherited Create(Sender);

  PAddress := @AAddress;
  PChanged := @AChanged;

  PChanged^ := False;

  is_Population := True;
  is_House      := False;

  Saved_Address := AAddress;
end;

Constructor TfrmAddress_Edit.CreateFromHouse(Sender : TComponent;
  var AAddress : String; var AChanged : Boolean);
begin
  Inherited Create(Sender);

  PAddress := @AAddress;
  PChanged := @AChanged;

  PChanged^ := False;

  is_Population := False;
  is_House      := True;

  Saved_Address := AAddress;
end;

procedure TfrmAddress_Edit.FormCreate(Sender : TObject);
var
  Address : TAddress;
begin
  is_Start := False;

  qRegion.Open;
  qRegion.Last;
  qRegion.First;

  qArea.Open;
  qArea.Last;
  qArea.First;

  qStreet_Type.Open;
  qStreet_Type.Last;
  qStreet_Type.First;

  Address := dm.SetAddress(Saved_Address);

  with Address Do
  begin
    lcbRegion.KeyValue        := Region_Type;
    lcbArea.KeyValue          := Area_Type;
    cbLocality_Type.ItemIndex := Locality_Type;
    edtLocality.Text          := Locality_Name;
    lcbStreet_Type.KeyValue   := Street_Type;
    edtStreet.Text            := Street_Name;
    edtHouse.Text             := House;
    edtApartment.Text         := Apartment;
  End;

  lcbStreet_Type.ItemIndex := 2;

  edtAddress.Text := dm.GetAddress(Address, False);

  SetTextFieldsLimits();

  is_Start := True;

  OnAddressChange(nil);

  //грубе обмеження полів
  edtLocality.MaxLength  := 50;
  edtStreet.MaxLength    := 100;
  edtHouse.MaxLength     := 7;
  edtApartment.MaxLength := 7;
end;

procedure TfrmAddress_Edit.FormCloseQuery(Sender : TObject; var CanClose : boolean);
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
                  PAddress^ := Saved_Address;
                end;
    end;
  end;
end;

procedure TfrmAddress_Edit.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  is_Start := False;

  qRegion.Close;
  qArea.Close;
  qStreet_Type.Close;

  CloseAction := caFree;
end;

procedure TfrmAddress_Edit.btnCloseClick(Sender : TObject);
begin
  Close;
end;

procedure TfrmAddress_Edit.btnSaveClick(Sender : TObject);
begin
  Saved_Address := edtAddress.Text;

  PAddress^ := Saved_Address;
  PChanged^ := True;

  Close;
end;

Procedure TfrmAddress_Edit.btnStreetClick(Sender : TObject);
var
  Street : String;
  DataChanged : Boolean;
Begin
  Street := edtStreet.Text;

  DataChanged := False;

  with TfrmReference.CreateSelectByName(Self, 'Довідник вулиць',
                                              'VULYTSIA',
                                              Null,
                                              Street,
                                              DataChanged)
  Do
  begin
    Select := TSelect.Create();

    ShowModal;

    if Select.Success then
    begin
      lcbStreet_Type.KeyValue := Select.Param;
      edtStreet.Text          := Select.Name;

      Self.SelectNext(Self.ActiveControl, True, True);
		End;

    Free;
  End;
end;

Procedure TfrmAddress_Edit.actReferenceExecute(Sender : TObject);
var
  Locality : String;
  DataChanged : Boolean;
Begin
  if ActiveControl = edtStreet   then btnStreet.Click else
  if ActiveControl = edtLocality then
  begin
    Locality := edtLocality.Text;

    DataChanged := False;

    with TfrmReference.CreateSelectByName(Self, 'Довідник сіл',
                                                'SELO',
                                                 Null,
                                                 Locality,
                                                 DataChanged)
    Do
    begin
      Select := TSelect.Create();

      ShowModal;

      if Select.Success then
      begin
        cbLocality_Type.ItemIndex := 0;
        edtLocality.Text          := Select.Name;
  		End;

      Free;
    End;
  End
  else Exit;

  SelectNext(ActiveControl, True, True);
end;

Procedure TfrmAddress_Edit.OnFieldChange(Sender : TObject);
var
  Address : TAddress;
Begin
  if not is_Start then Exit;

  if (Sender = edtLocality) or
     (Sender = edtStreet)
  then
  begin
    if UTF8Length((Sender as TEdit).Text) = 1 then
    begin
      (Sender as TEdit).Text := UTF8UpperCase((Sender as TEdit).Text);

      (Sender as TEdit).SelStart := 1;
    End;
  End;

  if Sender = lcbRegion then
  begin
    qArea.Close;

    qArea.SQL[qArea.SQL.Count - 2]:= '  and ((ID_OBLAST = :ID_Oblast) or (ID = 0))';

    qArea.ParamByName('ID_Oblast').AsInteger := lcbRegion.KeyValue;

    qArea.Open;
    qArea.Last;

    if not qArea.Locate('ID', lcbArea.KeyValue, []) then lcbArea.KeyValue := 0;
  end;

  with Address Do
  begin
    Region_Type   := lcbRegion.KeyValue;
    Region_Name   := Trim(lcbRegion.Text);
    Area_Type     := lcbArea.KeyValue;
    Area_Name     := Trim(lcbArea.Text);
    Locality_Type := cbLocality_Type.ItemIndex;
    Locality_Name := Trim(edtLocality.Text);
    Street_Type   := lcbStreet_Type.KeyValue;
    Street_Name   := Trim(edtStreet.Text);
    House         := Trim(edtHouse.Text);
    Apartment     := Trim(edtApartment.Text);
  End;

  edtAddress.Text := dm.GetAddress(Address, False);
end;

procedure TfrmAddress_Edit.OnAddressChange(Sender : TObject);
begin
  if not is_Start then Exit;

  btnSave.Enabled := edtAddress.Text <> Saved_Address;
end;

Procedure TfrmAddress_Edit.OnFieldUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
Begin
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
    '0'..'9' : ;
    'А'..'Я', 'І', 'Ї', 'Є', 'Ґ' : ;
    'а'..'я', 'і', 'ї', 'є', 'ґ' : ;
    '-', '.', '"', '''', ' ', '/': ;
    else
    begin
      UTF8Key := #0;

      Application.MessageBox('Недопустимий символ!',
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
    end;
  end;
end;

end.

