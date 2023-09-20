unit uReference_Edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, DbCtrls, LazUTF8, LCLType, uSelect, uFunctions;

type
  { TfrmReference_Edit }
  TfrmReference_Edit = class(TForm)
    edtID : TEdit;
    grpID : TGroupBox;
    pnlAccessAndCode : TPanel;
    pnlButtons : TPanel;
    btnSave : TBitBtn;
    btnClose : TBitBtn;
    grpName : TGroupBox;
    edtName : TEdit;
    qGetData : TSQLQuery;
    qTyp_Zemli : TSQLQuery;
    rgAccess : TRadioGroup;
    sqlReference : TSQLQuery;
    grpGenitiveName : TGroupBox;
    edtGenitiveName : TEdit;
    grpRegion : TGroupBox;
    lcbRegion : TDBLookupComboBox;
    qRegion : TSQLQuery;
    dsRegion : TDataSource;
    grpArea : TGroupBox;
    lcbArea : TDBLookupComboBox;
    qArea : TSQLQuery;
    dsArea : TDataSource;
    btnArea : TBitBtn;
    btnRegion : TBitBtn;
    grpShortName : TGroupBox;
    edtShortName : TEdit;
    grpStreetType : TGroupBox;
    lcbStreetType : TDBLookupComboBox;
    btnStreetType : TBitBtn;
    qStreetType : TSQLQuery;
    dsStreetType : TDataSource;
    qHromadianstvo : TSQLQuery;
    qOblast : TSQLQuery;
    qRaion : TSQLQuery;
    qSelo : TSQLQuery;
    qSporidnenist : TSQLQuery;
    qTyp_Vulytsi : TSQLQuery;
    qVulytsia : TSQLQuery;
    qGetID : TSQLQuery;
    procedure FormCreate(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure FormCloseQuery(Sender : TObject; var CanClose : boolean);
    procedure btnCloseClick(Sender : TObject);
    procedure btnSaveClick(Sender : TObject);
    procedure OnFieldChange(Sender: TObject);
    procedure OnFieldEnter(Sender: TObject);
    procedure OnFieldUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure OnReferenceButtonClick(Sender : TObject);
  private
    { private declarations }
    PPrimary : PInteger;
    PChanged : PBoolean;
    TableName : String;
    FreeParam : Variant;
    ID : Integer;
    is_Start,
    is_OBLAST, is_RAION, is_SELO, is_VULYTSIA,
    is_TYP_VULYTSI, is_HROMADIANSTVO, is_TYP_SPORIDNENOSTI,
    is_TYP_ZEMLI : Boolean;
    Saved_Name, Saved_GenitiveName,
    Saved_Show, Saved_Region, Saved_Area,
    Saved_ShortName, Saved_StreetType : Variant;
    procedure InitTableAndQueries();
    procedure GetAddUpdQuery();
    procedure GetSavedValue();
    procedure SetSavedValue();
    procedure SetWindowSize();
  public
    { public declarations }
    constructor CreateInt(Sender: TComponent; ATableName : String; AFreeParam : Variant;
                          var AID : Integer; var AChanged : Boolean);
  end;

var
  frmReference_Edit : TfrmReference_Edit;

implementation

uses
  udm, uReference;

{$R *.lfm}

{ TfrmReference_Edit }

procedure TfrmReference_Edit.InitTableAndQueries();
begin
  grpRegion.Visible := False;

  is_OBLAST            := False;
  is_RAION             := False;
  is_SELO              := False;
  is_VULYTSIA          := False;
  is_TYP_VULYTSI       := False;
  is_HROMADIANSTVO     := False;
  is_TYP_SPORIDNENOSTI := False;
  is_TYP_ZEMLI         := False;

  if TableName = UTF8Trim(UTF8UpperString('OBLAST'))            then is_OBLAST            := True else
  if TableName = UTF8Trim(UTF8UpperString('RAION'))             then is_RAION             := True else
  if TableName = UTF8Trim(UTF8UpperString('SELO'))              then is_SELO              := True else
  if TableName = UTF8Trim(UTF8UpperString('TYP_VULYTSI'))       then is_TYP_VULYTSI       := True else
  if TableName = UTF8Trim(UTF8UpperString('VULYTSIA'))          then is_VULYTSIA          := True else
  if TableName = UTF8Trim(UTF8UpperString('TYP_SPORIDNENOSTI')) then is_TYP_SPORIDNENOSTI := True else
  if TableName = UTF8Trim(UTF8UpperString('HROMADIANSTVO'))     then is_HROMADIANSTVO     := True else
  if TableName = UTF8Trim(UTF8UpperString('TYP_ZEMLI'))         then is_TYP_ZEMLI         := True else Close;

  if is_HROMADIANSTVO then
  begin
    //
  end
  else
  if is_OBLAST then
  begin
    //
  end
  else
  if is_RAION then
  begin
    qRegion.Open;
    qRegion.Last;
    qRegion.First;
  end
  else
  if is_SELO then
  begin
    qRegion.Open;
    qRegion.Last;
    qRegion.First;

    qArea.Open;
    qArea.Last;
    qArea.First;
  end
  else
  if is_TYP_SPORIDNENOSTI then
  begin
    //
  end
  else
  if is_TYP_VULYTSI then
  begin
    //
  end
  else
  if is_VULYTSIA then
  begin
    qStreetType.Open;
    qStreetType.Last;
    qStreetType.First;
  end
  else
  if is_TYP_ZEMLI then
  begin
    //
  end;
end;

procedure TfrmReference_Edit.GetAddUpdQuery();
begin
  sqlReference.InsertSQL.Text :=
    'insert into ' + TableName  + #13 +
    '( NAZVA,  DOSTUP) values ' + #13 +
    '(:Nazva, :Dostup)        ';

  sqlReference.UpdateSQL.Text :=
    'update ' + TableName + #13 +
    'set                ' + #13 +
    '  NAZVA  = :Nazva, ' + #13 +
    '  DOSTUP = :Dostup ' + #13 +
    'where              ' + #13 +
    '  ID = :ID         ';

  if is_HROMADIANSTVO then
  begin
    //
  end
  else
  if is_OBLAST then
  begin
    sqlReference.InsertSQL := qOblast.InsertSQL;
    sqlReference.UpdateSQL := qOblast.UpdateSQL;
  end
  else
  if is_RAION then
  begin
    sqlReference.InsertSQL := qRaion.InsertSQL;
    sqlReference.UpdateSQL := qRaion.UpdateSQL;
  end
  else
  if is_SELO then
  begin
    sqlReference.InsertSQL := qSelo.InsertSQL;
    sqlReference.UpdateSQL := qSelo.UpdateSQL;
  end
  else
  if is_TYP_SPORIDNENOSTI then
  begin
    //
  end
  else
  if is_TYP_VULYTSI then
  begin
    sqlReference.InsertSQL := qTyp_Vulytsi.InsertSQL;
    sqlReference.UpdateSQL := qTyp_Vulytsi.UpdateSQL;
  end
  else
  if is_VULYTSIA then
  begin
    sqlReference.InsertSQL := qVulytsia.InsertSQL;
    sqlReference.UpdateSQL := qVulytsia.UpdateSQL;
  end
  else
  if is_TYP_ZEMLI then
  begin
    sqlReference.InsertSQL := qTyp_Zemli.InsertSQL;
    sqlReference.UpdateSQL := qTyp_Zemli.UpdateSQL;
  end;
end;

procedure TfrmReference_Edit.GetSavedValue();
begin
  qGetData.Close;
  qGetData.SQL.Text :=
  'select                  ' + #13 +
  '    *                   ' + #13 +
  'from ' + TableName        + #13 +
  'where                   ' + #13 +
  '    ID = :prm_ID';

  qGetData.ParamByName('prm_ID').Value := ID;
  qGetData.Open;

  edtID.Text         := qGetData.FieldByName('ID').AsString;
  edtName.Text       := qGetData.FieldByName('NAZVA').AsString;
  rgAccess.ItemIndex := qGetData.FieldByName('DOSTUP').AsInteger;

  if is_HROMADIANSTVO then
  begin
    //
  end
  else
  if is_OBLAST then
  begin
    edtGenitiveName.Text := qGetData.FieldByName('NAZVA_RODOVYI').AsString;
  end
  else
  if is_RAION then
  begin
    lcbRegion.KeyValue   := qGetData.FieldByName('ID_OBLAST').AsInteger;
    edtGenitiveName.Text := qGetData.FieldByName('NAZVA_RODOVYI').AsString;
  end
  else
  if is_SELO then
  begin
    lcbRegion.KeyValue := qGetData.FieldByName('ID_OBLAST').AsInteger;
    lcbArea.KeyValue   := qGetData.FieldByName('ID_RAION').AsInteger;
  end
  else
  if is_TYP_SPORIDNENOSTI then
  begin
    //
  end
  else
  if is_TYP_VULYTSI then
  begin
    edtShortName.Text := qGetData.FieldByName('SKOROCHENA_NAZVA').AsString;
  end
  else
  if is_VULYTSIA then
  begin
    lcbStreetType.KeyValue := qGetData.FieldByName('ID_TYP_VULYTSI').AsInteger;
  end
  else
  if is_TYP_ZEMLI then
  begin
    //
  end;

  qGetData.Close;
end;

procedure TfrmReference_Edit.SetSavedValue();
begin
  Saved_Name := edtName.Text;
  Saved_Show := rgAccess.ItemIndex;

  if is_HROMADIANSTVO then
  begin
    //
  end
  else
  if is_OBLAST then
  begin
    Saved_GenitiveName := edtGenitiveName.Text;
  end
  else
  if is_RAION then
  begin
    Saved_Region       := lcbRegion.KeyValue;
    Saved_GenitiveName := edtGenitiveName.Text;
  end
  else
  if is_SELO then
  begin
    Saved_Region := lcbRegion.KeyValue;
    Saved_Area   := lcbArea.KeyValue;
  end
  else
  if is_TYP_SPORIDNENOSTI then
  begin
    //
  end
  else
  if is_TYP_VULYTSI then
  begin
    Saved_ShortName := edtShortName.Text;
  end
  else
  if is_VULYTSIA then
  begin
    Saved_StreetType := lcbStreetType.KeyValue;
  end
  else
  if is_TYP_ZEMLI then
  begin
    //
  end;
end;

procedure TfrmReference_Edit.SetWindowSize();
begin
  grpGenitiveName.Visible := False;
  grpRegion.Visible       := False;
  grpArea.Visible         := False;
  grpShortName.Visible    := False;
  grpStreetType.Visible   := False;

  ClientHeight := grpName.Height +
                  pnlAccessAndCode.Height +
                  pnlButtons.Height +
                  2 * BorderWidth;

  if is_HROMADIANSTVO then
  begin
    //
  end
  else
  if is_OBLAST then
  begin
    grpGenitiveName.Visible := True;

    ClientHeight := ClientHeight + grpGenitiveName.Height;
  end
  else
  if is_RAION then
  begin
    grpGenitiveName.Visible := True;
    grpRegion.Visible       := True;

    ClientHeight := ClientHeight + grpGenitiveName.Height + grpRegion.Height;
  end
  else
  if is_SELO then
  begin
    grpRegion.Visible := True;
    grpArea.Visible   := True;

    ClientHeight := ClientHeight + grpRegion.Height + grpArea.Height;
  end
  else
  if is_TYP_SPORIDNENOSTI then
  begin
    //
  end
  else
  if is_TYP_VULYTSI then
  begin
    grpShortName.Visible := True;

    ClientHeight := ClientHeight + grpShortName.Height;
  end
  else
  if is_VULYTSIA then
  begin
    grpStreetType.Visible := True;

    ClientHeight := ClientHeight + grpStreetType.Height;
  end
  else
  if is_TYP_ZEMLI then
  begin
    //
  end;
end;

constructor TfrmReference_Edit.CreateInt(Sender: TComponent; ATableName : String; AFreeParam : Variant;
                                         var AID : Integer; var AChanged : Boolean);
begin
  inherited Create(Sender);

  PPrimary := @AID;
  PChanged := @AChanged;

  PChanged^ := False;

  TableName := UTF8UpperCase(ATableName);
  FreeParam := AFreeParam;
  ID        := AID;
end;

procedure TfrmReference_Edit.FormCreate(Sender : TObject);
begin
  is_Start := False;

  InitTableAndQueries();
  GetAddUpdQuery();

  if ID < 0 then
  begin
    if qRegion.Active     then lcbRegion.KeyValue     := REFERENCE_NONE;
    if qArea.Active       then lcbArea.KeyValue       := REFERENCE_NONE;
    if qStreetType.Active then lcbStreetType.KeyValue := REFERENCE_NONE;
  end
  else
  begin
    GetSavedValue();
  end;

  SetSavedValue();
  SetWindowSize();

  is_Start := True;

  OnFieldChange(Sender);
end;

procedure TfrmReference_Edit.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  is_Start := False;

  if qRegion.Active     then qRegion.Close;
  if qArea.Active       then qArea.Close;
  if qStreetType.Active then qStreetType.Close;

  CloseAction := caFree;
end;

procedure TfrmReference_Edit.FormCloseQuery(Sender : TObject; var CanClose : boolean);
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

procedure TfrmReference_Edit.btnCloseClick(Sender : TObject);
begin
  Close;
end;

procedure TfrmReference_Edit.btnSaveClick(Sender : TObject);
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
    sqlReference.SQL := sqlReference.InsertSQL;
  end
  else
  begin
    sqlReference.SQL := sqlReference.UpdateSQL;

    sqlReference.ParamByName('ID').Value := ID;
  end;

  sqlReference.ParamByName('Nazva').AsString   := edtName.Text;
  sqlReference.ParamByName('Dostup').AsInteger := rgAccess.ItemIndex;

  if is_HROMADIANSTVO then
  begin
    //
  end
  else
  if is_OBLAST then
  begin
    sqlReference.ParamByName('Nazva_Rodovyi').AsString := edtGenitiveName.Text;
  end
  else
  if is_RAION then
  begin
    sqlReference.ParamByName('Nazva_Rodovyi').AsString := edtGenitiveName.Text;
    sqlReference.ParamByName('ID_Oblast').AsInteger    := lcbRegion.KeyValue;
  end
  else
  if is_SELO then
  begin
    sqlReference.ParamByName('ID_Oblast').AsInteger := lcbRegion.KeyValue;
    sqlReference.ParamByName('ID_Raion').AsInteger  := lcbArea.KeyValue;
  end
  else
  if is_TYP_SPORIDNENOSTI then
  begin
    //
  end
  else
  if is_TYP_VULYTSI then
  begin
    sqlReference.ParamByName('Skorochena_Nazva').AsString := edtShortName.Text;
  end
  else
  if is_VULYTSIA then
  begin
    sqlReference.ParamByName('ID_Typ_Vulytsi').AsInteger := lcbStreetType.KeyValue;
  end
  else
  if is_TYP_ZEMLI then
  begin
    //
  end;

  try
    sqlReference.ExecSQL;

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

procedure TfrmReference_Edit.OnFieldChange(Sender: TObject);
begin
  if not is_Start then Exit;

  if Sender = lcbRegion then
  begin
    qArea.Close;

    qArea.SQL[qArea.SQL.Count - 2]:= '  and ((ID_OBLAST = :ID_Oblast) or (ID = 0))';

    qArea.ParamByName('ID_Oblast').AsInteger := lcbRegion.KeyValue;

    qArea.Open;
    qArea.Last;

    if not qArea.Locate('ID', lcbArea.KeyValue, []) then lcbArea.KeyValue := 0;
  end;

  btnSave.Enabled := (Trim(edtName.Text) <> Saved_Name) or
                     (rgAccess.ItemIndex <> Saved_Show);

  btnSave.Visible := FullStr(edtName.Text);

  if FullStr(edtName.Text)
  then edtName.Color := clDefault
  else edtName.Color := COLOR_ERROR_FIELD;

  if is_HROMADIANSTVO then
  begin
    //
  end
  else
  if is_OBLAST then
  begin
    if Sender = lcbRegion then qRegion.Locate('ID', lcbRegion.KeyValue, []) else
    if Sender = lcbArea   then qArea.Locate(  'ID', lcbArea.KeyValue,   []);

    btnSave.Enabled := (Trim(edtName.Text)         <> Saved_Name)         or
                       (Trim(edtGenitiveName.Text) <> Saved_GenitiveName) or
                       (rgAccess.ItemIndex         <> Saved_Show);

    btnSave.Visible :=     FullStr(edtName.Text)
                       and FullStr(edtGenitiveName.Text);

    if FullStr(edtName.Text)         then edtName.Color         := clDefault else edtName.Color         := COLOR_ERROR_FIELD;
    if FullStr(edtGenitiveName.Text) then edtGenitiveName.Color := clDefault else edtGenitiveName.Color := COLOR_ERROR_FIELD;
  end
  else
  if is_RAION then
  begin
    btnSave.Enabled := (Trim(edtName.Text)         <> Saved_Name)         or
                       (Trim(edtGenitiveName.Text) <> Saved_GenitiveName) or
                       (lcbRegion.KeyValue         <> Saved_Region)       or
                       (rgAccess.ItemIndex         <> Saved_Show);

    btnSave.Visible :=      FullStr(edtName.Text)
                       and  FullStr(edtGenitiveName.Text)
                       and (lcbRegion.KeyValue > 0);

    if FullStr(edtName.Text)         then edtName.Color         := clDefault else edtName.Color         := COLOR_ERROR_FIELD;
    if FullStr(edtGenitiveName.Text) then edtGenitiveName.Color := clDefault else edtGenitiveName.Color := COLOR_ERROR_FIELD;
    if lcbRegion.KeyValue > 0        then grpRegion.Color       := clDefault else grpRegion.Color       := COLOR_ERROR_FIELD;
  end
  else
  if is_SELO then
  begin
    btnSave.Enabled := (Trim(edtName.Text) <> Saved_Name)   or
                       (lcbRegion.KeyValue <> Saved_Region) or
                       (lcbArea.KeyValue   <> Saved_Area)   or
                       (rgAccess.ItemIndex <> Saved_Show);

    btnSave.Visible :=      FullStr(edtName.Text)
                       and (lcbRegion.KeyValue > 0)
                       and (lcbArea.KeyValue   > 0);

    if FullStr(edtName.Text)  then edtName.Color   := clDefault else edtName.Color   := COLOR_ERROR_FIELD;
    if lcbRegion.KeyValue > 0 then grpRegion.Color := clDefault else grpRegion.Color := COLOR_ERROR_FIELD;
    if lcbArea.KeyValue   > 0 then grpArea.Color   := clDefault else grpArea.Color   := COLOR_ERROR_FIELD;
  end
  else
  if is_TYP_SPORIDNENOSTI then
  begin
    //
  end
  else
  if is_TYP_VULYTSI then
  begin
    btnSave.Enabled := (Trim(edtName.Text)      <> Saved_Name)      or
                       (Trim(edtShortName.Text) <> Saved_ShortName) or
                       (rgAccess.ItemIndex      <> Saved_Show);

    btnSave.Visible :=      FullStr(edtName.Text)
                       and  FullStr(edtShortName.Text);

    if FullStr(edtName.Text)      then edtName.Color      := clDefault else edtName.Color      := COLOR_ERROR_FIELD;
    if FullStr(edtShortName.Text) then edtShortName.Color := clDefault else edtShortName.Color := COLOR_ERROR_FIELD;
  end
  else
  if is_VULYTSIA then
  begin
    btnSave.Enabled := (Trim(edtName.Text)     <> Saved_Name)       or
                       (lcbStreetType.KeyValue <> Saved_StreetType) or
                       (rgAccess.ItemIndex     <> Saved_Show);

    btnSave.Visible :=      FullStr(edtName.Text)
                       and (lcbStreetType.KeyValue > 0);

    if FullStr(edtName.Text)      then edtName.Color       := clDefault else edtName.Color       := COLOR_ERROR_FIELD;
    if lcbStreetType.KeyValue > 0 then grpStreetType.Color := clDefault else grpStreetType.Color := COLOR_ERROR_FIELD;
  end
  else
  if is_TYP_ZEMLI then
  begin
    //
  end;
end;

procedure TfrmReference_Edit.OnFieldEnter(Sender: TObject);
begin
  if Sender = edtGenitiveName then
  begin
    if EmptyStr(edtGenitiveName.Text) then edtGenitiveName.Text := edtName.Text;
  end
  else
  if Sender = edtShortName then
  begin
    if EmptyStr(edtShortName.Text) then edtShortName.Text := UTF8Copy(edtName.Text, 1, 3) + '.';
  end;
end;

procedure TfrmReference_Edit.OnFieldUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
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

procedure TfrmReference_Edit.OnReferenceButtonClick(Sender : TObject);
var
  DataCaption, DataTable : String;
  DataParam : Variant;
  DataID : Integer;
  DataChanged : Boolean;
begin
  DataChanged := False;

  if Sender = btnRegion     then
  begin
    DataCaption := 'Виберіть область';
    DataTable   :=  UTF8Trim(UTF8UpperString('OBLAST'));
    DataParam   :=  FreeParam;
    DataID      :=  lcbRegion.KeyValue;
  end
  else
  if Sender = btnArea       then
  begin
    DataCaption := 'Виберіть район';
    DataTable   :=  UTF8Trim(UTF8UpperString('RAION'));
    DataParam   :=  lcbRegion.KeyValue;
    DataID      :=  lcbArea.KeyValue;
  end
  else
  if Sender = btnStreetType then
  begin
    DataCaption := 'Виберіть тип вулиці';
    DataTable   :=  UTF8Trim(UTF8UpperString('TYP_VULYTSI'));
    DataParam   :=  FreeParam;
    DataID      :=  lcbStreetType.KeyValue;
  end
  else Exit;

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
    if Sender = btnRegion     then
    begin
      qRegion.Close;
      qRegion.Open;
      qRegion.Last;
      qRegion.Locate('ID', DataID, []);
    end
    else
    if Sender = btnArea       then
    begin
      qArea.Close;
      qArea.Open;
      qArea.Last;
      qArea.Locate('ID', DataID, []);
    end
    else
    if Sender = btnStreetType then
    begin
      qStreetType.Close;
      qStreetType.Open;
      qStreetType.Last;
      qStreetType.Locate('ID', DataID, []);
    end;
  end;

  if DataID > 0 then
  begin
    if Sender = btnRegion     then
    begin
      lcbRegion.KeyValue := DataID;

      OnFieldChange(lcbRegion);
    end
    else
    if Sender = btnArea       then
    begin
      if DataID > 0 then lcbArea.KeyValue := DataID;

      OnFieldChange(lcbArea);
    end
    else
    if Sender = btnStreetType then
    begin
      if DataID > 0 then lcbStreetType.KeyValue := DataID;

      OnFieldChange(lcbStreetType);
    end;
  end;
end;

end.

