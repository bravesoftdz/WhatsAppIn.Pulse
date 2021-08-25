unit uLogger;

interface

type
  TLogger = class
  private
    FArquivoLog: TextFile;
    class var FInstancia: TLogger;
    constructor Create;
  public
    class function ObterInstancia: TLogger;
    class function NewInstance: TObject; override;
    procedure RegistrarLog(pMetodo, pTexto: string);
    destructor Destroy; override;
  end;

implementation

uses
  Forms, SysUtils;

{ TLogger }

constructor TLogger.Create;
var
  DiretorioAplicacao: string;
begin
  DiretorioAplicacao := ExtractFilePath(Application.ExeName);
  AssignFile(FArquivoLog, DiretorioAplicacao + '\Log\LogErro.txt');

  if not FileExists(DiretorioAplicacao + 'LogErro.txt') then
  begin
    Rewrite(FArquivoLog);
    CloseFile(FArquivoLog);
  end;
end;

destructor TLogger.Destroy;
begin
  FInstancia.Free;
  inherited;
end;

class function TLogger.NewInstance: TObject;
begin
  if not Assigned(FInstancia) then
    FInstancia := TLogger(inherited NewInstance);

  Result := FInstancia;
end;

class function TLogger.ObterInstancia: TLogger;
begin
  Result := TLogger.Create;
end;

procedure TLogger.RegistrarLog(pMetodo, pTexto: string);
var
  lDataHora: string;
begin
  Append(FArquivoLog);
  lDataHora := FormatDateTime('[dd/mm/yyyy hh:nn:ss] ', Now);
  WriteLn(FArquivoLog, 'Data/Hora.......: ' + lDataHora);
  WriteLn(FArquivoLog, 'Método..........: ' + pMetodo);
  WriteLn(FArquivoLog, 'Erro............: ' + pTexto);
  WriteLn(FArquivoLog, StringOfChar('-', 70));

  CloseFile(FArquivoLog);
end;

end.
