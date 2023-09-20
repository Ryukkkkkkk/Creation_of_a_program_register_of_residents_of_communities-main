{ Назва:       Num2Text
  Залежності:  SysUtils
  Автор:       reonid, reonid@yahoo.com
  Copyright:   Елисеев Леонид
  Дата:        15 июля 2002 г.
  Адаптація:   ZuluSpirit

  Набір функцій, що перетворюють цілі й дійсні числа в їх словесні аналоги
  (з одиницями вимірювання і без):
    - function FloatToText(R: Double; Precision: Integer): string;
        Перетворює дійсне число в текстове представлення з точністю
        до Precision <= 4 знаків після коми.

    - function AmountOfUnits(AUnit: TRusWord; R: Double; Precision: Integer;
                             Options: TNumberToTextOptions): string;
        Аналогічно FloatToText, з врахуванням одиниць вимірювання і з опціями:
         - ntoExplicitZero: "нуль цілих"
         - ntoMinus, ntoPlus: "мінус", "плюс".
         - ntoNotReduceFrac: "п'ятдесят сотих" замість "п'яти десятих".

    - function CountOfUnits(AUnit: TRusWord; N: Int64;
                            Options: TNumberToTextOptions): string;
        Те саме для цілих чисел.
        Всі функції модуля реалізовані через неї.

    - function CurrencyToText(ASum: Currency): string;
        ще одна реалізація суми прописом.

  Приклади використання:
    - str := FloatToText(3.14, 2); // три цілих чотирнадцать coтих

    - const
        WD_METRE: TUkrWord = (
          Gender: genMasculine;
          Base: 'метр';
          End1: '';
          End2: 'и';
          End5: 'ів';
        );

      str := AmountOfUnits(WD_METRE, 3.1, 2, [ntoExplicitZero, ntoMinus]);
      // Результат: три цілих одна десята метра
}

unit Num2Text;

{$mode objfpc}{$H+}

interface

type
  TNumberToTextOptions = set of (ntoExplicitZero,
                                 ntoMinus,
                                 ntoPlus,
                                 ntoDigits,
                                 ntoNotReduceFrac);
  // Рід
  TGender = (genNeuter,     // нейтральный
             genMasculine,  // чоловічий
             genFeminine);  // жіночий

  TUkrWord = record
    Gender: TGender;
    Base: String;
    End1: String;
    End2: String;
    End5: String;
  end;

const
  // Точність до десятитисячних
  MaxPrecision = 4;

  WD_EMPTY: TUkrWord = (
    Gender: genMasculine;
    Base: '';
    End1: '';
    End2: '';
    End5: '';
  );

  { Розряди }

  WD_THOUSEND: TUkrWord = (
    Gender: genFeminine;
    Base: 'тисяч';
    End1: 'а';
    End2: 'і';
    End5: '';
  );

  WD_MILLION: TUkrWord = (
    Gender: genMasculine;
    Base: 'мільйон';
    End1: '';
    End2: 'и';
    End5: 'ів';
  );

  WD_MILLIARD: TUkrWord = (
    Gender: genMasculine;
    Base: 'мільярд';
    End1: '';
    End2: 'и';
    End5: 'ів';
  );

  { Дробна частина }

  WD_INT: TUkrWord = (
    Gender: genFeminine;
    Base: 'ціл';
    End1: 'а';
    End2: 'і';
    End5: 'их';
  );

  WD_FRAC: array[1..4] of TUkrWord = (
    (Gender: genFeminine;
     Base: 'десят';
     End1: 'а';
     End2: 'і';
     End5: 'их'; ),

    (Gender: genFeminine;
     Base: 'coт';
     End1: 'а';
     End2: 'і';
     End5: 'их'; ),

    (Gender: genFeminine;
     Base: 'тисячн';
     End1: 'а';
     End2: 'і';
     End5: 'их'; ),

    (Gender: genFeminine;
     Base: 'десятитисячн';
     End1: 'а';
     End2: 'і';
     End5: 'их'; )
  );

  { Гривні, копійки }

  WD_GRYVNYA: TUkrWord = (
    Gender: genMasculine;
    Base: 'грив';
    End1: 'ня';
    End2: 'ні';
    End5: 'ень';
  );

  WD_KOPIYOK: TUkrWord = (
    Gender: genFeminine;
    Base: 'копі';
    End1: 'йка';
    End2: 'йки';
    End5: 'йок';
  );

  WD_GRYVNYA_SHORT: TUkrWord = (
    Gender: genMasculine;
    Base: 'грн';
    End1: '';
    End2: '';
    End5: '';
  );

  WD_KOPIYOK_SHORT: TUkrWord = (
    Gender: genFeminine;
    Base: 'коп.';
    End1: '';
    End2: '';
    End5: '';
  );

  { Тони, кілограми }

  WD_TON: TUkrWord = (
    Gender: genFeminine;
    Base: 'тон';
    End1: 'а';
    End2: 'и';
    End5: '';
  );

  WD_KG: TUkrWord = (
    Gender: genMasculine;
    Base: 'кілограм';
    End1: '';
    End2: 'и';
    End5: '';
  );

function CurrencyToText(ASum : Currency;
  NeedZero, GrnByWords, KopByWords, GrnShort, KopShort : Boolean) : String;

function WeightToText(ASum : Currency; RealForm, NeedZero,
  AllByWords : Boolean) : String;

function FloatToText(R : Double; Precision: Integer): String;

function CountOfUnits(AUnit : TUkrWord; N: Int64;
  Options: TNumberToTextOptions): String;

function AmountOfUnits(AUnit : TUkrWord; R: Double; Precision: Integer;
  Options: TNumberToTextOptions) : String;

implementation

uses
  SysUtils, LazUTF8;

const
  TenIn: array[1..4] of Integer = (10, 100, 1000, 10000);

type
  TNumberAnalyser = class
  private
    FUnitWord    : TUkrWord;
    FNumber      : Integer;
    FFirstLevel  : Integer;
    FSecondLevel : Integer;
    FThirdLevel  : Integer;
    procedure SetNumber(AValue : Integer);
    function GetLevels(I : Integer): Integer;
    function GetNumberInWord(N, Level : Integer) : String;
    function GetGender : TGender;
    function Convert : String;
  public
    property Levels[I : Integer] : Integer read GetLevels;
    property Gender : TGender              read GetGender;
    property Number : Integer              read FNumber   write SetNumber;
    property UnitWord : TUkrWord           read FUnitWord write FUnitWord;

    function UnitWordInRightForm : String;
    function ConvertToText(AUnit : TUkrWord; ANumber : Integer) : String;
  end;

var
  NumberAnalyser: TNumberAnalyser;

function CurrencyToText(ASum : Currency;
  NeedZero, GrnByWords, KopByWords, GrnShort, KopShort : Boolean) : String;
var
  GrnSum, KopSum : Int64;
  GrnName, KopName : TUkrWord;
  Grn, Kop : String;
begin
  GrnSum := Trunc(ASum);
  KopSum := Round(Frac(ASum) * 100);

  Grn := '';
  Kop := '';

  if GrnShort
  then GrnName := WD_GRYVNYA_SHORT
  else GrnName := WD_GRYVNYA;

  if KopShort
  then KopName := WD_KOPIYOK_SHORT
  else KopName := WD_KOPIYOK;

  if NeedZero then
  begin
    if GrnByWords
    then Grn := CountOfUnits(GrnName, GrnSum, [ntoExplicitZero])
    else Grn := CountOfUnits(GrnName, GrnSum, [ntoExplicitZero, ntoDigits]);

    if KopByWords
    then Kop := CountOfUnits(KopName, KopSum, [ntoExplicitZero])
    else Kop := CountOfUnits(KopName, KopSum, [ntoExplicitZero, ntoDigits]);
  end
  else
  begin
    if GrnByWords
    then Grn := CountOfUnits(GrnName, GrnSum, [])
    else Grn := CountOfUnits(GrnName, GrnSum, [ntoDigits]);

    if KopByWords
    then Kop := CountOfUnits(KopName, KopSum, [])
    else Kop := CountOfUnits(KopName, KopSum, [ntoDigits]);
  end;

  Result := UTF8Trim(Grn) + ' ' + UTF8Trim(Kop);

  if Result <> '' then Result[1] := UTF8UpperString(Result[1])[1];
end;

function WeightToText(ASum : Currency;
  RealForm, NeedZero, AllByWords : Boolean) : String;
var
  TonSum, KgSum : Int64;
begin
  TonSum := Trunc(ASum);
  KgSum  := Round(Frac(ASum) * 1000);

  if RealForm then
  begin
    if NeedZero
    then Result := AmountOfUnits(WD_TON, ASum, 2, [ntoExplicitZero])
    else Result := AmountOfUnits(WD_TON, ASum, 2, []);

    // AllByWords не використовується
  end
  else
  begin
    if NeedZero then
    begin
      // Нуль тон стільки-то кілограм
      Result := CountOfUnits(WD_TON, TonSum, [ntoExplicitZero{, ntoMinus}]);

      if TonSum = 0 then Result := Result + ' ';
    end
    else
    begin
      // Стільки-то кілограм
      Result := CountOfUnits(WD_TON, TonSum, [{ntoExplicitZero, ntoMinus}]);
    end;

    if AllByWords then
    begin
      // Кілограми словами
      if NeedZero // Нуль кілограм
      then Result := Result + CountOfUnits(WD_KG, KgSum, [ntoExplicitZero])
      else Result := Result + CountOfUnits(WD_KG, KgSum, []);
    end
    else
    begin
      // Кілограми цифрами
      if NeedZero // Нуль кілограм
      then Result := Result + CountOfUnits(WD_KG, KgSum, [ntoDigits, ntoExplicitZero])
      else Result := Result + CountOfUnits(WD_KG, KgSum, [ntoDigits]);
    end;
  end;

  // З великої літери
  if Result <> '' then Result[1] := UTF8UpperString(Result[1])[1];
end;

function FloatToText(R : Double; Precision : Integer) : String;
begin
  Result := AmountOfUnits(WD_EMPTY, R, Precision, [ntoExplicitZero, ntoMinus]);
end;

function AmountOfUnits(AUnit : TUkrWord; R : Double; Precision : Integer;
  Options : TNumberToTextOptions) : String;
var
  n_Int, n_Frac : Integer;
begin
  // Опція ntoDigits не викоритовуєть за відсутністю потреби

  // Кількість цифр після коми
  if Precision < 0 then Precision := 0;

  if Precision > MaxPrecision then Precision := MaxPrecision;

  if (R > 0) and (ntoPlus  in Options) then Result := 'плюс ';
  if (R < 0) and (ntoMinus in Options) then Result := 'мінус ';

  R := Abs(R);

  // Якщо Precision = 0, тобто без дробової частини,
  // заокруглюється в більшую сторону
  if Precision > 0
  then n_Int := Trunc(R)
  else n_Int := Round(R);

  // Дробова частина
  n_Frac := Round((R - n_Int) * TenIn[Precision]);

  // Відкиданян нулів у дробовій частині
  // Опція ntoNotReduceFrac не працює
  // при n_Frac = 0 (тобто не буде "нуль сотих")
  if not (ntoNotReduceFrac in Options) then
  begin
    while (n_Frac mod 10 = 0) and (Precision > 0) do
    begin
      n_Frac := n_Frac div 10;

      Dec(Precision);
    end;
  end;

  // Явний запис нуля
  if n_Int = 0 then
  begin
    if n_Frac = 0 then
    begin
      // За відсутності дробової частини "нуль" додається незалежно
      // від опції ntoExplicitZero
      Result := {Result +} 'нуль ' + AUnit.Base + AUnit.End5;

      // "Result +" відкинуто, щоб уникнути "мінус нуль"
      // при дуже маленькій дробовій частині (за обмеженням точності)

      Exit;
    end
    else
    if (ntoExplicitZero in Options) then
    begin
      Result := Result + 'нуль цілих ';
    end;
  end;

  if {(Precision = 0)} (n_Frac = 0)
  then Result := Result + CountOfUnits(AUnit, n_Int, [])   // N одиниць
  else Result := Result + CountOfUnits(WD_INT, n_Int, []); // стільки-то цілих

  if {(Precision = 0)} (n_Frac = 0) then Exit;

  Result := Result + CountOfUnits(WD_FRAC[Precision], n_Frac, []);

  // N десятих, сотих...
  Result := Result + AUnit.Base + AUnit.End2;
end;

function CountOfUnits(AUnit : TUkrWord; N : Int64;
  Options : TNumberToTextOptions) : String;
var
  Mrd, Mil, Th, Un : Integer;
begin
  Result := '';

  if (N = 0) and not (ntoExplicitZero in Options) then Exit;

  if not (ntoDigits in Options) then
  begin
    if (N < 0) and (ntoMinus in Options) then Result := 'мінус ' else
    if (N > 0) and (ntoPlus  in Options) then Result := 'плюс '  else
    if (N = 0) then
    begin
      Result := 'нуль ' + AUnit.Base + AUnit.End5;

      Exit;
    end;
  end
  else
  begin
    if (N < 0) and (ntoMinus in Options) then Result := '-' else
    if (N > 0) and (ntoPlus  in Options) then Result := '+';
  end;

  N := Abs(N);

  if ntoDigits in Options then
  begin
    NumberAnalyser.Number   := N;
    NumberAnalyser.UnitWord := AUnit;

    Result := Result + Format('%d %s', [N, NumberAnalyser.UnitWordInRightForm]);
  end
  else
  begin
    with NumberAnalyser do
    begin
      Mrd := (N div 1000000000) mod 1000;
      Mil := (N div    1000000) mod 1000;
      Th  := (N div       1000) mod 1000;
      Un  := (N)                mod 1000;

      Result := Result + ConvertToText(WD_MILLIARD, Mrd)
                       + ConvertToText(WD_MILLION,  Mil)
                       + ConvertToText(WD_THOUSEND, Th);

      if Un > 0
      then Result := Result + ConvertToText(AUnit, Un)
      else Result := Result + AUnit.Base + AUnit.End5 + ' ';
    end;
  end;
end;

{ TNumberAnalyser }

function TNumberAnalyser.GetLevels(I : Integer) : Integer;
begin
  case I of
    1: Result := FFirstLevel;
    2: Result := FSecondLevel;
    3: Result := FThirdLevel;
  end;
end;

procedure TNumberAnalyser.SetNumber(AValue : Integer);
begin
  if FNumber <> AValue then
  begin
    FNumber      :=  AValue;
    FFirstLevel  :=  FNumber          mod 10;
    FSecondLevel := (FNumber div  10) mod 10;
    FThirdLevel  := (FNumber div 100) mod 10;

    if FSecondLevel = 1 then
    begin
      FFirstLevel  := FFirstLevel + 10;
      FSecondLevel := 0;
    end;
  end;
end;

function TNumberAnalyser.GetGender : TGender;
begin
  Result := FUnitWord.Gender;
end;

function TNumberAnalyser.GetNumberInWord(N, Level : Integer): String;
begin
  if Level = 1 then
  begin
    case N of
       0: Result := '';
       1: if Gender = genMasculine then Result := 'один' else
          if Gender = genFeminine  then Result := 'одна' else
          if Gender = genNeuter    then Result := 'одна';

       2: if Gender = genMasculine then Result := 'два' else
          if Gender = genFeminine  then Result := 'дві' else
          if Gender = genNeuter    then Result := 'дві';

       3: Result := 'три';
       4: Result := 'чотири';
       5: Result := 'п''ять';
       6: Result := 'шість';
       7: Result := 'сім';
       8: Result := 'вісім';
       9: Result := 'дев''ять';
      10: Result := 'десять';
      11: Result := 'одинадцять';
      12: Result := 'дванадцять';
      13: Result := 'тринадцять';
      14: Result := 'чотирнадцять';
      15: Result := 'п''ятнадцять';
      16: Result := 'шістнадцять';
      17: Result := 'сімнадцять';
      18: Result := 'вісімнадцять';
      19: Result := 'дев''ятнадцять';
    end;
  end
  else
  if Level = 2 then
  begin
    case N of
      0: Result := '';
      1: Result := 'десять';
      2: Result := 'двадцять';
      3: Result := 'тридцять';
      4: Result := 'сорок';
      5: Result := 'п''ятьдесят';
      6: Result := 'шістдесят';
      7: Result := 'сімдесят';
      8: Result := 'вісімдесят';
      9: Result := 'дев''яносто';
    end;
  end
  else
  if Level = 3 then
  begin
    case N of
      0: Result := '';
      1: Result := 'сто';
      2: Result := 'двісті';
      3: Result := 'триста';
      4: Result := 'чотириста';
      5: Result := 'п''ятсот';
      6: Result := 'шістсот';
      7: Result := 'сімсот';
      8: Result := 'вісімсот';
      9: Result := 'дев''ятсот';
    end;
  end;
end;

function TNumberAnalyser.UnitWordInRightForm: string;
begin
  Result := UnitWord.Base;

  case Levels[1] of
    0, 5..19: Result := Result + UnitWord.End5;
    1:        Result := Result + UnitWord.End1;
    2..4:     Result := Result + UnitWord.End2;
  end;
end;

function TNumberAnalyser.Convert: string;
var
  i : Integer;
  s : String;
begin
  if FNumber = 0 then
  begin
    Result := '';
  end
  else
  begin
    Result := '';

    for i := 3 downto 1 do
    begin
      s := GetNumberInWord(Levels[i], i);

      if s <> '' then Result := Result + s + ' ';
    end;

    Result := Result + UnitWordInRightForm + ' ';
  end;
end;

function TNumberAnalyser.ConvertToText(AUnit : TUkrWord;
  ANumber : Integer): String;
begin
  UnitWord := AUnit;
  Number   := ANumber;
  Result   := Convert;
end;

initialization
  NumberAnalyser := TNumberAnalyser.Create;

finalization
  NumberAnalyser.Free;

end.
