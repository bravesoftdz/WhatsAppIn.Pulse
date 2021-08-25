unit uGeral;

interface

uses
  Winapi.Windows, System.AnsiStrings, System.SysUtils, uLogger, IdHTTP;

type
  TMetodo = procedure of object;

function GetBuildInfo(AProg: string): string;
function MSecToTime(const AIntTime: Integer): string;
function PrimeiraLetraMaiuscula(ANome: string): string;
function PrimeiroNome(ANome: String): String;
function EncurtaURL(AURL: string): string;
function SomenteNumero(ATexto: String): Boolean;

implementation

function SomenteNumero(ATexto: String): Boolean;
var
  lI: Integer;
begin
  Result := False;

  for lI := 1 to length(ATexto) do
  begin
    if CharInSet(ATexto[lI], ['0' .. '9']) then
      Result := True;
  end;
end;

function EncurtaURL(AURL: string): string;
var
  lHTTPMontaUrl: TIdHTTP;
  lAuxUrl: string;
begin
  lHTTPMontaUrl := TIdHTTP.Create(NIL);
  try
    try
      lAuxUrl := 'http://tinyurl.com/api-create.php?url=' + AURL;
      Result := lHTTPMontaUrl.Get(lAuxUrl);
    except
      on E: Exception do
      begin
        TLogger.ObterInstancia.RegistrarLog('EncurtaURL', E.Message);
        Exit;
      end;
    end;
  finally
    lHTTPMontaUrl.Free;
  end;
end;

function GetBuildInfo(AProg: string): string;
var
  lVerInfoSize: DWORD;
  lVerInfo: Pointer;
  lVerValueSize: DWORD;
  lVerValue: PVSFixedFileInfo;
  lDummy: DWORD;
  lV1, lV2, lV3, lV4: Word;
begin
  try
    lVerInfoSize := GetFileVersionInfoSize(PChar(AProg), lDummy);
    GetMem(lVerInfo, lVerInfoSize);
    GetFileVersionInfo(PChar(AProg), 0, lVerInfoSize, lVerInfo);
    VerQueryValue(lVerInfo, '', Pointer(lVerValue), lVerValueSize);

    with (lVerValue^) do
    begin
      lV1 := dwFileVersionMS shr 16;
      lV2 := dwFileVersionMS and $FFFF;
      lV3 := dwFileVersionLS shr 16;
      lV4 := dwFileVersionLS and $FFFF;
    end;

    FreeMem(lVerInfo, lVerInfoSize);
    Result := Format('%d.%d.%d.%d', [lV1, lV2, lV3, lV4]);
  except
    Result := '1.0.0';
  end;
end;

function MSecToTime(const AIntTime: Integer): string;
const
  lIntMSec = 1 / 24 / 60 / 60 / 1000; // o equivalente a 1 milisegundo
begin
  // define o retorno com o formato Time
  Result := TimeToStr(AIntTime * lIntMSec);
end;

function PrimeiraLetraMaiuscula(ANome: string): string;
begin
  if ANome <> '' then
  begin
    Result := UpperCase(Copy(ANome, 1, 1)) +
            LowerCase(Copy(ANome, 2, length(ANome)));
  end;
end;

function PrimeiroNome(ANome: String): String;
var
  lNome: String;
begin
  lNome := '';

  if pos(' ', ANome) <> 0 then
    lNome := Copy(ANome, 1, pos(' ', ANome) - 1);

  Result := lNome;
end;

end.
