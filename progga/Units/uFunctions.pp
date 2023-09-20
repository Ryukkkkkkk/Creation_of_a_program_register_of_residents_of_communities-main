unit uFunctions;

{$mode objfpc}{$H+}

interface

Function ConvertToPassword(AValue : String) : String;
Function ConvertFromPassword(AValue : String) : String;

Function GetShortName(AValue : String) : String;

Function ParseFileName(AFileName : String; AReplace : Boolean = False) : String;
Function ParseMobile(APhone : String; AMobileOnly : Boolean = True) : String;

Function VarToInt(AValue : Variant; ADefaultValue : Integer = 0) : Integer;
Function BoolToInt(AValue : Boolean) : Byte;
Function IntToBool(AValue : Byte; AInverse : Boolean = False) : Boolean;

Function EmptyStr(AValue : String; AUseTrim : Boolean = True) : Boolean;
Function FullStr (AValue : String; AUseTrim : Boolean = True) : Boolean;

implementation

uses
  Classes, SysUtils, strutils, variants, LazUTF8;

const
  ENCODEKEY : String = 'йцукенгшщзхїqwertyuiopфівапролджєasdfghjklячсмитьбюzxcvbnm1234567890-=!@#$%^&*()_+,.<>/?';

Function ConvertToPassword(AValue : String) : String;
begin
  Result := XorEncode(ENCODEKEY, AValue);
end;

Function ConvertFromPassword(AValue : String) : String;
begin
  Result := XorDecode(ENCODEKEY, AValue);
end;

Function GetShortName(AValue : String) : String;
var
  tS, First_Name, Middle_Name, Last_Name : String;
begin
  if UTF8Pos(' ', AValue) > 0 then
  begin
    Last_Name := UTF8Copy(AValue, 1, UTF8Pos(' ', AValue) - 1);

    UTF8Delete(AValue, 1, UTF8Pos(' ', AValue));

    if UTF8Pos(' ', AValue) > 0 then
    begin
      First_Name := UTF8Copy(AValue, 1, UTF8Pos(' ', AValue) - 1);

      UTF8Delete(AValue, 1, UTF8Pos(' ', AValue));

      if FullStr(AValue) then
      begin
        Middle_Name := UTF8Trim(AValue);
			End;
  	End;

    if FullStr(First_Name)  then tS :=            UTF8Copy(First_Name,  1, 1) + '.';
    if FullStr(Middle_Name) then tS := tS + ' ' + UTF8Copy(Middle_Name, 1, 1) + '.';

    Result := Last_Name + ' ' + tS;
	End
	else
  begin
    Result := AValue;
	End;
End;

Function ParseFileName(AFileName : String; AReplace : Boolean = False) : String;
const
  ErrorSymbols: set of Char = ['"', '*', ':', '?', '/', '\', '|', '<', '>'];
var
  i : Word;
begin
  Result := '';

  if UTF8Length(AFileName) = 0 then Exit;

  i := 1;

  while i <= UTF8Length(AFileName) do
  begin
    AFileName := UTF8StringReplace(AFileName, '"', '''''', [rfReplaceAll]);

    if AFileName[i] in ErrorSymbols then
    begin
      if AReplace then
      begin
        AFileName[i] := '_';
      end
      else
      begin
        UTF8Delete(AFileName, i, 1);

        Dec(i);
      end;
    end;

    Inc(i);
  end;

  Result := AFileName;
end;

Function ParseMobile(APhone : String; AMobileOnly : Boolean = True) : String;
var
  Phone, Domain, Number : String;
  i : Word;
begin
  Result := '';

  APhone := UTF8Trim(APhone);

  if APhone <> '' then
  begin
    Phone := APhone;

    // Залишаємо лише цифри
    for i := UTF8Length(Phone) downto 1 do
    begin
      if not (Phone[i] in ['0' .. '9']) then UTF8Delete(Phone, i, 1);
    end;

    // Видаляємо міжнародний код, якщо є
    if (UTF8Length(Phone) > 0) and (Phone[1] = '3') then UTF8Delete(Phone, 1, 1);
    if (UTF8Length(Phone) > 0) and (Phone[1] = '8') then UTF8Delete(Phone, 1, 1);
    if (UTF8Length(Phone) > 0) and (Phone[1] = '0') then UTF8Delete(Phone, 1, 1);

    if (UTF8Length(Phone) < 9) or (UTF8Length(Phone) > 12) then
    begin
      Result := '';

      Exit;
    end;

    Domain := UTF8Copy(Phone, UTF8Length(Phone) - 9 + 1, 2); // Код оператора
    Number := UTF8Copy(Phone, UTF8Length(Phone) - 7 + 1, 7); // Номер телефону
    Phone  := '+38(0' + Domain + ')' + Number;

    if AMobileOnly then
    begin
      if not ((Domain = '50') or (Domain = '63') or (Domain = '66') or
              (Domain = '67') or (Domain = '68') or (Domain = '73') or
              (Domain = '91') or (Domain = '92') or (Domain = '93') or
              (Domain = '94') or (Domain = '95') or (Domain = '96') or
              (Domain = '97') or (Domain = '98') or (Domain = '99'))
      then
      begin
        Result := '';

        Exit;
      end;
    end;

    Result := Phone;
  end;
end;

Function VarToInt(AValue : Variant; ADefaultValue : Integer = 0) : Integer;
begin
  Result := ADefaultValue;

  if VarIsNull(AValue) then
  begin
    Result := 0;
  end
  else
  begin
    if VarIsOrdinal(AValue) then Result := StrToInt(VarToStr(AValue));
  end;
end;

Function BoolToInt(AValue : Boolean) : Byte;
begin
  if AValue
  then Result := 1
  else Result := 0;
end;

Function IntToBool(AValue : Byte; AInverse : Boolean = False) : Boolean;
begin
  if AInverse
  then if AValue = 0 then Result := True else Result := False
  else if AValue > 0 then Result := True else Result := False;
end;

Function EmptyStr(AValue : String; AUseTrim : Boolean = True) : Boolean;
begin
  if AUseTrim
  then Result := (UTF8Length(UTF8Trim(AValue)) = 0)
  else Result := (UTF8Length(         AValue ) = 0);
end;

Function FullStr(AValue : String; AUseTrim : Boolean = True) : Boolean;
begin
  Result := not EmptyStr(AValue, AUseTrim);
end;

end.

