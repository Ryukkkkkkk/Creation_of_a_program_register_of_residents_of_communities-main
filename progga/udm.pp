Unit udm;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, mysql56conn, sqldb, sqldblib, db, FileUtil, Dialogs,
  DBGrids, Controls, variants, IniPropStorage, LazUTF8, Winsock,
  LR_Class, LR_Desgn, LR_ChBox, LR_E_TXT, LR_E_HTM, LR_E_CSV, LR_PGrid,
  Num2Text, uFunctions, uSpecialFolder;

Type
  TAddress = record
    Region_Type   : Integer;
    Region_Name   : String;
    Area_Type     : Integer;
    Area_Name     : String;
    Locality_Type : Integer;
    Locality_Name : String;
    Street_Type   : Integer;
    Street_Name   : String;
    House         : String;
    Apartment     : String;
	End;

	{ Tdm }
  Tdm = Class(TDataModule)
		frCheckBoxObject : TfrCheckBoxObject;
		frCSVExport : TfrCSVExport;
		frDesigner : TfrDesigner;
		frHTMExport : TfrHTMExport;
		FrPrintGrid : TFrPrintGrid;
		frReport : TfrReport;
		frTextExport : TfrTextExport;
    ilButtons : TImageList;
		IniPropStorage : TIniPropStorage;
    MySQLDB56 : TMySQL56Connection;
		MainTransaction : TSQLTransaction;
		OpenDialogPrint : TOpenDialog;
    ImageListSortGrid : TImageList;
		qArea : TSQLQuery;
    qGetColumnsLimit : TSQLQuery;
    qGetID : TSQLQuery;
		qRegion : TSQLQuery;
		qStreet_Type : TSQLQuery;
    qGeneral_Data : TSQLQuery;
    SaveTransaction : TSQLTransaction;
    SQLDBLibraryLoader : TSQLDBLibraryLoader;
		Procedure DataModuleCreate(Sender : TObject);
    Procedure frReportUserFunction(const AName : String; p1, p2, p3 : Variant; var Val : Variant);
  Private
    { private declarations }
    Function ClearAddress(AAddress, AChar : String) : String;
  Public
    { public declarations }
    UserCode : Integer;
    UserName,
    ShortUserName : String;
    Procedure LoadGlobal_Data();
    Procedure SetIniPropStorageValue(ASection, AKey : String; AValue : Integer); virtual;
    Procedure SetIniPropStorageValue(ASection, AKey : String; AValue : Boolean); virtual;
    Procedure SetIniPropStorageValue(ASection, AKey : String; AValue : String);  virtual;
    Function GetIniPropStorageValue(ASection, AKey : String; AShowMessage : Boolean; var AValue : Integer; ADefault : Integer = 0    ) : Boolean; virtual;
    Function GetIniPropStorageValue(ASection, AKey : String; AShowMessage : Boolean; var AValue : Boolean; ADefault : Boolean = False) : Boolean; virtual;
    Function GetIniPropStorageValue(ASection, AKey : String; AShowMessage : Boolean; var AValue : String;  ADefault : String  = ''   ) : Boolean; virtual;
    Procedure GridSort(AGrid : TDBGrid; AKeyFields, ASortField : String);
    Function  GridColumnByName(AGrid : TDBGrid; AName : String) : TColumn;
    Procedure SetGridColumnVisible(AGrid : TDBGrid; AName : String; AValue : Boolean);
    Procedure StartSetColumnsLimit(ATableName : String);
    Procedure FinishSetColumnsLimit();
    Function  GetColumnsLimit(AFieldName : String) : Word;
    Function GetAddress(AAddress : TAddress; ALocalityNeed : Boolean = True) : String;
    Function SetAddress(AAddress : String) : TAddress;
    Function GetLastInsertID() : Integer;
  End;

const
  COLOR_ERROR_FIELD = $00C8C8FF;
  COLUMN_SORT_DOWN  =  0;
  COLUMN_SORT_UP    =  1;
  USER_CODE_NONE    =  0;
  USER_CODE_ADMIN   =  1;
  REFERENCE_ALL     = -1;
  REFERENCE_NONE    =  0;
  CITIZENSHIP_UKR   =  1;

Var
  dm : Tdm;
  ApplicationPath,
  ProgramFilesX64Path,
  ProgramFilesX86Path,
  TempPath,
  SFReportPath,
  SFTempPath,
  LocalIPAddress : String;

Implementation

{$R *.lfm}

Function GetIPAddress() : String;
const
  WSVer = $101;
var
  WSAData : TWSAData;
  HostEnt : PHostEnt;
  Buffer : Array[0..255] of Char;
begin
  Result := '';

  If WSAStartup(WSVer, WSAData) = 0 Then
  Begin
    if GetHostName(Buffer, SizeOf(Buffer)) = 0 then
    begin
      HostEnt := GetHostByName(Buffer);

      if HostEnt <> nil then
      begin
        Result := iNet_ntoa(PInAddr(HostEnt^.h_addr_list^)^);
      end;
    end;

    WSACleanup;
  End;
end;

{ Tdm }

Procedure Tdm.DataModuleCreate(Sender : TObject);
var
  HostName, DataBase : String;
  HostPort : Integer;
begin
  ApplicationPath     := ExtractFilePath(ParamStr(0));
  ProgramFilesX64Path := GetSpecialFolderLocation(CSIDL_PROGRAM_FILES, FOLDERID_ProgramFilesX64);
  ProgramFilesX86Path := GetSpecialFolderLocation(CSIDL_PROGRAM_FILES, FOLDERID_ProgramFilesX86);
  TempPath            := GetTempDir();
  SFReportPath        := TempPath + 'SF-Report' + PathDelim;
  SFTempPath          := TempPath + 'SF-Temp'   + PathDelim;
  LocalIPAddress      := GetIPAddress();

  ForceDirectories(SFReportPath);
  ForceDirectories(SFTempPath);

  {$IfDef WIN32_MODE}
  SQLDBLibraryLoader.ConnectionType := 'MySQL 5.6';
  SQLDBLibraryLoader.LibraryName    := ApplicationPath + 'x32\libmysql.dll';
  SQLDBLibraryLoader.Enabled        := True;

  SQLDBLibraryLoader.LoadLibrary;
  {$Else}
  SQLDBLibraryLoader.ConnectionType := 'MySQL 5.6';
  SQLDBLibraryLoader.LibraryName    := ApplicationPath + 'x64\libmysql.dll';
  SQLDBLibraryLoader.Enabled        := True;

  SQLDBLibraryLoader.LoadLibrary;
  {$EndIf}

  DataBase := 'SocFix';
  HostName := '127.0.0.1';
  HostPort :=  3306;

  if not (    GetIniPropStorageValue('Server', 'DataBase', False, DataBase)
          and GetIniPropStorageValue('Server', 'HostName', False, HostName)
          and GetIniPropStorageValue('Server', 'HostPort', False, HostPort))
  then
  begin
    MessageDlg(ApplicationName,
              'Не вдалося прочитати з файлу конфігурації' + LineEnding +
              'параметри підключення до бази даних!',
               mtError, [mbOK], '');

    Exit;
  end;

  if EmptyStr(DataBase) then
  begin
    MessageDlg(ApplicationName,
              'У файлі конфігурації не вказано' + LineEnding +
              'назва бази даних!',
               mtError, [mbOK], '');
    Exit;
  end;

  if EmptyStr(HostName) then
  begin
    MessageDlg(ApplicationName,
              'У файлі конфігурації не вказано' + LineEnding +
              'адресу підключення до сервера!',
               mtError, [mbOK], '');
    Exit;
  end;

  if HostPort = 0 then
  begin
    MessageDlg(ApplicationName,
              'У файлі конфігурації не вказано' + LineEnding +
              'порт підключення до сервера!',
               mtError, [mbOK], '');
    Exit;
  end;

  try
    MySQLDB56.DatabaseName := DataBase;
    MySQLDB56.HostName     := HostName;
    MySQLDB56.Port         := HostPort;
    MySQLDB56.Connected    := True;
  except
    on E : Exception do
    begin
      MessageDlg(ApplicationName,
                'Помилка підключення до бази даних!' + LineEnding +
                                                       LineEnding +
                'Модуль: ' + E.ClassName             + LineEnding +
                                                       LineEnding +
                'Виникла наступна помилка:'          + LineEnding +
                 E.Message,
                 mtError, [mbOK], '');
    end;
  end;

  frVariables['LineEnding'] := LineEnding;
end;

procedure Tdm.frReportUserFunction(const AName : String; p1, p2, p3 : Variant; var Val : Variant);
var
  wd_Person: TUkrWord;
begin
  If UTF8UpperCase(AName) = 'BY_WORDS' Then
  begin
    with wd_Person do
    begin
      Gender := genNeuter;
      Base   := '';
      End1   := '';
      End2   := '';
      End5   := '';
    end;

    Val := Num2Text.CountOfUnits(wd_Person, frVariables[p1], [ntoExplicitZero]);
  end;
end;

Function Tdm.ClearAddress(AAddress, AChar : String) : String;
begin
  UTF8Delete(AAddress, 1, UTF8Pos(AChar, AAddress) + UTF8Length(AChar) - 1);

  Result := UTF8Trim(AAddress);
End;

Procedure Tdm.LoadGlobal_Data();
var
  Variable_Name : String;
  Variable_Value : Variant;
begin
  qGeneral_Data.Close;
  qGeneral_Data.Open;
  qGeneral_Data.First;

  while not qGeneral_Data.EOF do
  begin
    Variable_Name  := qGeneral_Data.FieldByName('NAZVA').AsString;
    Variable_Value := qGeneral_Data.FieldByName('ZNACHENNIA').Value;

    frVariables[Variable_Name] := Variable_Value;

    qGeneral_Data.Next;
  end;

  qGeneral_Data.Close;
end;

Procedure Tdm.SetIniPropStorageValue(ASection, AKey : String; AValue : Integer);
begin
  IniPropStorage.IniSection := ASection;

  IniPropStorage.WriteInteger(AKey, AValue);
End;

Procedure Tdm.SetIniPropStorageValue(ASection, AKey : String; AValue : Boolean);
begin
  IniPropStorage.IniSection := ASection;

  IniPropStorage.WriteBoolean(AKey, AValue);
End;

Procedure Tdm.SetIniPropStorageValue(ASection, AKey : String; AValue : String);
begin
  IniPropStorage.IniSection := ASection;

  IniPropStorage.WriteString(AKey, AValue);
End;

Function Tdm.GetIniPropStorageValue(ASection, AKey : String; AShowMessage : Boolean; var AValue : Integer; ADefault : Integer = 0) : Boolean;
begin
  try
    IniPropStorage.IniSection := ASection;

    AValue := IniPropStorage.ReadInteger(AKey, ADefault);

    Result := True;
	Except
    on E : Exception do
    begin
      Result := False;

      if not AShowMessage then Exit;

      MessageDlg(ApplicationName,
                'Не вдалося прочитати файл конфігурації!' + LineEnding +
                                                            LineEnding +
                'Модуль: ' + E.ClassName                  + LineEnding +
                                                            LineEnding +
                'Виникла наступна помилка:'               + LineEnding +
                 E.Message,
                 mtError, [mbOK], '');
    end;
  End;
End;

Function Tdm.GetIniPropStorageValue(ASection, AKey : String; AShowMessage : Boolean; var AValue : Boolean; ADefault : Boolean = False) : Boolean;
begin
  try
    IniPropStorage.IniSection := ASection;

    AValue := IniPropStorage.ReadBoolean(AKey, ADefault);

    Result := True;
	Except
    on E : Exception do
    begin
      Result := False;

      if not AShowMessage then Exit;

      MessageDlg(ApplicationName,
                'Не вдалося прочитати файл конфігурації!' + LineEnding +
                                                            LineEnding +
                'Модуль: ' + E.ClassName                  + LineEnding +
                                                            LineEnding +
                'Виникла наступна помилка:'               + LineEnding +
                 E.Message,
                 mtError, [mbOK], '');
    end;
	End;
End;

Function Tdm.GetIniPropStorageValue(ASection, AKey : String; AShowMessage : Boolean; var AValue : String; ADefault : String = '') : Boolean;
begin
  try
    IniPropStorage.IniSection := ASection;

    AValue := IniPropStorage.ReadString(AKey, ADefault);

    Result := True;
	Except
    on E : Exception do
    begin
      Result := False;

      if not AShowMessage then Exit;

      MessageDlg(ApplicationName,
                'Не вдалося прочитати файл конфігурації!' + LineEnding +
                                                            LineEnding +
                'Модуль: ' + E.ClassName                  + LineEnding +
                                                            LineEnding +
                'Виникла наступна помилка:'               + LineEnding +
                 E.Message,
                 mtError, [mbOK], '');
    end;
	End;
End;

Procedure Tdm.GridSort(AGrid: TDBGrid; AKeyFields, ASortField : String);
var
  i : Integer;
  tS : String;
  KeyMemo : TStringList;
  KeyArray : Variant;
begin
  AGrid.TitleImageList := ImageListSortGrid;

  with (AGrid.DataSource.DataSet as TSQLQuery) do
  begin
    If FullStr(AKeyFields) Then
    begin
      If Active Then
      begin
        KeyMemo := TStringList.Create;

        try
          KeyMemo.CommaText := UTF8StringReplace(AKeyFields, ';', ',', [rfReplaceAll]);

          KeyArray := VarArrayCreate([0, KeyMemo.Count - 1], varVariant);

          For i := 0 to KeyMemo.Count - 1 do
          begin
            KeyArray[i] := FieldByName(KeyMemo.Strings[i]).Value;
          end;
        finally
          KeyMemo.Free;
        end;
      end;
    end;

    tS := '';

    For i := 0 to AGrid.Columns.Count - 1 do
    begin
      if UTF8UpperCase(ASortField) = UTF8UpperCase(AGrid.Columns[i].FieldName) then
      begin
        if AGrid.Columns[i].Tag < 0
        then AGrid.Columns[i].Tag := 1
        else AGrid.Columns[i].Tag := 1 - AGrid.Columns[i].Tag;

        if AGrid.Columns[i].Tag = 0
        then tS := 'ORDER BY ' + ASortField + ' DESC'
        else tS := 'ORDER BY ' + ASortField;
      end
      else
      begin
        AGrid.Columns[i].Tag := -1;
      end;

      AGrid.Columns[i].Title.ImageIndex := AGrid.Columns[i].Tag;
    end;

    DisableControls;
    Close;

    if FullStr(tS) then SQL[SQL.Count - 1] := tS;

    Open;

    If FullStr(AKeyFields) Then
    begin
      try
        Locate(AKeyFields, KeyArray, []);
      except
        //
      end;
    end;

    EnableControls;
  end;
end;

Function Tdm.GridColumnByName(AGrid : TDBGrid; AName : String) : TColumn;
var
  i : Integer;
begin
  Result := Nil;

  for i := 0 to AGrid.Columns.Count - 1 do
  begin
    if (CompareText(AGrid.Columns[i].FieldName, AName) = 0) then
    begin
      Result := AGrid.Columns[i];

      Exit;
    end;
  end;
end;

procedure Tdm.SetGridColumnVisible(AGrid : TDBGrid; AName : String; AValue : Boolean);
var
  LColumn : TColumn;
begin
  LColumn := dm.GridColumnByName(AGrid, AName);

  if LColumn <> nil then
  begin
    LColumn.Visible := AValue;
  end;
end;

Procedure Tdm.StartSetColumnsLimit(ATableName : String);
begin
  qGetColumnsLimit.Close;
  qGetColumnsLimit.ParamByName('prm_DB_Name').AsString    := MySQLDB56.DatabaseName;
  qGetColumnsLimit.ParamByName('prm_Table_Name').AsString := ATableName;
  qGetColumnsLimit.Open;
end;

Procedure Tdm.FinishSetColumnsLimit();
begin
  qGetColumnsLimit.Close;
end;

Function Tdm.GetColumnsLimit(AFieldName : String) : Word;
begin
  Result := 0;

  if qGetColumnsLimit.Locate('COLUMN_NAME', AFieldName, []) then
  begin
    Result := qGetColumnsLimit.FieldByName('COLUMN_LIMIT').AsInteger;
  end;
end;

Function Tdm.GetAddress(AAddress : TAddress; ALocalityNeed : Boolean = True) : String;
var
  tS : String;
begin
  Result := '';

  with AAddress Do
  begin
    if Region_Type > 0 then
    begin
      Result := Result + Region_Name + ' обл., ';

      if Area_Type > 0 then Result := Result + Area_Name + ' р-н, ';
		End;

    if FullStr(Locality_Name) then
    begin
      case Locality_Type of
        0: Result := Result + 'с. '  + Locality_Name + ', ';
        1: Result := Result + 'м '   + Locality_Name + ', ';
        2: Result := Result + 'смт ' + Locality_Name + ', ';
			End;
		End;

    qStreet_Type.Open;

    if qStreet_Type.Locate('ID', Street_Type, [])
    then tS := qStreet_Type.FieldByName('SKOROCHENA_NAZVA').AsString
    else tS := '';

    qStreet_Type.Close;

    Result := Result +  tS + ' ' + Street_Name + ', буд. ' + House;

    if FullStr(Apartment) then Result := Result + ', кв. ' + Apartment;

    if (EmptyStr(Street_Name))  or
       (EmptyStr(House))
    then Result := '';

    if ALocalityNeed then
    begin
      if     EmptyStr(Locality_Name)
         and FullStr(Region_Name)
      then Result := '';
    end;
	End;
end;

Function Tdm.SetAddress(AAddress : String) : TAddress;
var
  tS : String;
begin
  with Result Do
  begin
    Region_Type   := 0;
    Region_Name   := '';
    Area_Type     := 0;
    Area_Name     := '';
    Locality_Type := 0;
    Locality_Name := '';
    Street_Type   := 0;
    Street_Name   := '';
    House         := '';
    Apartment     := '';
  End;

  if EmptyStr(AAddress) then Exit;

  // Визначаємо область
  if UTF8Pos(' обл.,', AAddress) > 0 then
  begin
    tS := UTF8Trim(UTF8Copy(AAddress, 1, UTF8Pos(' обл.,', AAddress)));

    qRegion.Open;

    if qRegion.Locate('NAZVA', tS, [])
    then Result.Region_Type := qRegion.FieldByName('ID').AsInteger
    else Result.Region_Type := 0;

    qRegion.Close;

    Result.Region_Name := tS;

    AAddress := ClearAddress(AAddress, ' обл.,');

    // Визначаємо район
    if UTF8Pos(' р-н,', AAddress) > 0 then
    begin
      tS := UTF8Trim(UTF8Copy(AAddress, 1, UTF8Pos(' р-н,', AAddress)));

      qArea.Open;

      if qArea.Locate('NAZVA', tS, [])
      then Result.Area_Type := qArea.FieldByName('ID').AsInteger
      else Result.Area_Type := 0;

      qArea.Close;

      Result.Area_Name := tS;

      AAddress := ClearAddress(AAddress, ' р-н,');
	  End
    else
    begin
      Result.Area_Type := 0;
      Result.Area_Name := '';
		End;
	End
  else
  begin
    Result.Region_Type := 0;
    Result.Region_Name := '';
	End;

  // Визначаємо населений пункт
	if (UTF8Pos('с.',  AAddress) = 1) or
     (UTF8Pos('м.',  AAddress) = 1) or
     (UTF8Pos('смт', AAddress) = 1)
  then
	begin
    if (UTF8Pos('с.',  AAddress) = 1) then Result.Locality_Type := 0;
    if (UTF8Pos('м.',  AAddress) = 1) then Result.Locality_Type := 1;
    if (UTF8Pos('смт', AAddress) = 1) then Result.Locality_Type := 2;

    AAddress := ClearAddress(AAddress, ' ');

    // Визначаємо назву вулиці
    if UTF8Pos(',', AAddress) = 0 then Exit;

    Result.Locality_Name := UTF8Trim(UTF8Copy(AAddress, 1, UTF8Pos(',', AAddress) - 1));

    AAddress := ClearAddress(AAddress, ',');
	End
	else
	begin
	  Result.Area_Type := 0;
	  Result.Area_Name := '';
	End;

  // Визначаємо тип вулиці
  if UTF8Pos('.', AAddress) = 0 then Exit;

  tS := UTF8Trim(UTF8Copy(AAddress, 1, UTF8Pos('.', AAddress)));

  qStreet_Type.Open;

  if qStreet_Type.Locate('SKOROCHENA_NAZVA', tS, [])
  then Result.Street_Type := qStreet_Type.FieldByName('ID').AsInteger
  else Result.Street_Type := 0;

  qStreet_Type.Close;

  AAddress := ClearAddress(AAddress, '.');

  // Визначаємо назву вулиці
  if UTF8Pos(',', AAddress) = 0 then Exit;

  Result.Street_Name := UTF8Trim(UTF8Copy(AAddress, 1, UTF8Pos(',', AAddress) - 1));

  AAddress := ClearAddress(AAddress, ',');

  // Визначаємо номер будинку
  if UTF8Pos('буд.', AAddress) = 0 then Exit;

  AAddress := ClearAddress(AAddress, '.');

  if UTF8Pos(',', AAddress) > 0
  then Result.House := UTF8Trim(UTF8Copy(AAddress, 1, UTF8Pos(',', AAddress) - 1))
  else Result.House := UTF8Trim(UTF8Copy(AAddress, 1, UTF8Length(tS)));

  AAddress := ClearAddress(AAddress, ',');

  // Визначаємо номер квартири
  if UTF8Pos('кв.', AAddress) = 0 then Exit;

  AAddress := ClearAddress(AAddress, '.');

  Result.Apartment := UTF8Trim(UTF8Copy(AAddress, 1, UTF8Length(AAddress)));
End;

Function Tdm.GetLastInsertID() : Integer;
begin
  qGetID.Open;

  Result := qGetID.FieldByName('ID').AsInteger;

  qGetID.Close;
end;

End.

