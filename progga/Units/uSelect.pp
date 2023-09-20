unit uSelect;

{$mode objfpc}{$H+}

interface

type
  TSelect = class(TObject)
  private
    FCode : Integer;
    FName : String;
    FParam : Variant;
    FSeparator : String;
    FCodeNeedSpace : Boolean;
    FNameNeedSpace : Boolean;
    FSelectedCode : String;
    FSelectedName : String;
    FSuccess : Boolean;
    procedure SetCode(ACode : Integer);
    Function  GetSelectedCode() : String;
    procedure SetSelectedCode(ASelectedCode : String);
    Function  GetSelectedName() : String;
    procedure SetSelectedName(ASelectedName : String);
    procedure SetSeparator(ASeparator : String);
  public
    constructor Create();
    constructor Init(ACode : Integer; AName : String);
    constructor Init(ACode : Integer; AName : String; AParam : Variant);
    constructor Select(ASelectedCode, ASelectedName : String);
    destructor Destroy(); override;
    property Code          : Integer read FCode           write SetCode;
    property Name          : String  read FName           write FName;
    property Param         : Variant read FParam          write FParam;
    property SelectedCode  : String  read GetSelectedCode write FSelectedCode;
    property SelectedName  : String  read GetSelectedName write FSelectedCode;
    property Separator     : String  read FSeparator      write SetSeparator;
    property CodeNeedSpace : Boolean read FCodeNeedSpace  write FCodeNeedSpace;
    property NameNeedSpace : Boolean read FNameNeedSpace  write FNameNeedSpace;
    property Success       : Boolean read FSuccess;
  end;

implementation

uses
  Classes, SysUtils, LazUTF8;

procedure TSelect.SetCode(ACode : Integer);
begin
  FCode    := ACode;
  FSuccess := True;
end;

Function TSelect.GetSelectedCode() : String;
begin
  if FCodeNeedSpace
  then Result := UTF8StringReplace(FSelectedCode, Separator, Separator + ' ', [rfReplaceAll])
  else Result := FSelectedCode;
end;

procedure TSelect.SetSelectedCode(ASelectedCode : String);
begin
  ASelectedCode := UTF8Trim(ASelectedCode);

  if (ASelectedCode = Separator) or
     (UTF8Length(ASelectedCode) = 0)
  then
  begin
    FSelectedCode := '';
  end
  else
  begin
    if ASelectedCode[UTF8Length(ASelectedCode)] = Separator then
    begin
      UTF8Delete(ASelectedCode, UTF8Length(ASelectedCode), 1);
    end;

    FSelectedCode := ASelectedCode;
  end;
end;

Function TSelect.GetSelectedName() : String;
begin
  if FNameNeedSpace
  then Result := UTF8StringReplace(FSelectedName, Separator, Separator + ' ', [rfReplaceAll])
  else Result := FSelectedName;
end;

procedure TSelect.SetSelectedName(ASelectedName : String);
begin
  ASelectedName := UTF8Trim(ASelectedName);

  if (ASelectedName = Separator) or
     (UTF8Length(ASelectedName) = 0)
  then
  begin
    FSelectedName := '';
  end
  else
  begin
    if ASelectedName[UTF8Length(ASelectedName)] = Separator then
    begin
      UTF8Delete(ASelectedName, UTF8Length(ASelectedName), 1);
    end;

    FSelectedName := ASelectedName;
  end;
end;

procedure TSelect.SetSeparator(ASeparator : String);
begin
  if UTF8Length(ASeparator) > 0 then FSeparator := ASeparator;
end;

constructor TSelect.Create();
begin
  inherited Create();

  FCode  := -1;
  FName  := '';
  FParam := Null;

  FSeparator := ',';

  FCodeNeedSpace := False;
  FNameNeedSpace := True;

  SetSelectedCode('');
  SetSelectedName('');

  FSuccess := False;
end;

constructor TSelect.Init(ACode : Integer; AName : String);
begin
  inherited Create();

  FCode  := ACode;
  FName  := AName;
  FParam := Null;

  FSeparator := ',';

  FCodeNeedSpace := False;
  FNameNeedSpace := True;

  SetSelectedCode(IntToStr(ACode));
  SetSelectedName(AName);

  FSuccess := False;
end;

constructor TSelect.Init(ACode : Integer; AName : String; AParam : Variant);
begin
  inherited Create();

  FCode  := ACode;
  FName  := AName;
  FParam := AParam;

  FSeparator := ',';

  FCodeNeedSpace := False;
  FNameNeedSpace := True;

  SetSelectedCode(IntToStr(ACode));
  SetSelectedName(AName);

  FSuccess := False;
end;

constructor TSelect.Select(ASelectedCode, ASelectedName : String);
begin
  inherited Create();

  FSeparator := ',';

  FCodeNeedSpace := False;
  FNameNeedSpace := True;

  SetSelectedCode(ASelectedCode);
  SetSelectedName(ASelectedName);

  if UTF8Length(UTF8Trim(FSelectedCode)) = 0 then
  begin
    FCode  := -1;
    FName  := '';
    FParam := Null;
  end
  else
  begin
    if UTF8Pos(FSeparator, FSelectedCode) > 0 then
    begin
      FCode := StrToInt(UTF8Copy(FSelectedCode, 1, UTF8Pos(FSeparator, FSelectedCode) - 1));
      FName :=          UTF8Copy(FSelectedName, 1, UTF8Pos(FSeparator, FSelectedName) - 1);
    end
    else
    begin
      FCode := StrToInt(FSelectedCode);
      FName :=          FSelectedName;
    end;
  end;

  FSuccess := False;
end;

destructor TSelect.Destroy();
begin
  inherited;
end;

end.

