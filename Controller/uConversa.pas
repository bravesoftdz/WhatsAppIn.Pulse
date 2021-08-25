unit uConversa;

interface

uses System.SysUtils, VCL.Graphics, FireDAC.Comp.Client, FireDAC.DApt,
     FireDAC.Stan.Param, udtmConexao, uInterfacesConversa;

type
  TConversa = class(TInterfacedObject, iConversa)
  private
    FConnection: TFDConnection;
    FQuery: TFDQuery;
    FMensagem: string;
    FContato: string;
    FCodigoMensagem: Integer;

  public

    constructor Create;
    destructor Destroy; override;

    class function New: iConversa;

    function GravarMensagem(AContato,
                            ATelefone,
                            AMensagem,
                            AIdConversa,
                            ATipoMensagem: string;
                            ADataEnvioRecebido: TDateTime): iConversa;
    function GravarDataEnvio(ACodigoMensagem: integer): iConversa;
    function VerificarMensagemEnviada: iConversa;

  function Mensagem: string; overload;
  function Mensagem(AMensagem: string): iConversa; overload;
  function IdContato: string; overload;
  function IdContato(AIdContato: string): iConversa; overload;
  function CodigoMensagem: integer; overload;
  function CodigoMensagem(ACodigoMensagem: integer): iConversa; overload;

  function AjustarNumTelefone(pNumTelefone, pNumTelefoneBot: string): string;
  end;

implementation

{ TConversa }

function TConversa.AjustarNumTelefone(pNumTelefone,
                                      pNumTelefoneBot: string): string;
var
  lNumTelefoneAux: String;
begin
  if Length(pNumTelefone) < 13 then
  begin
    pNumTelefone := Copy(pNumTelefone, 1, 4);
    lNumTelefoneAux := Copy(pNumTelefoneBot, 5, Length(pNumTelefoneBot));
    pNumTelefone := pNumTelefone + '9' + lNumTelefoneAux;
  end;

  Result := Copy(pNumTelefone, 3, Length(pNumTelefone));
end;

constructor TConversa.Create;
begin
  FConnection := dm.fdConexao;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection;
end;

destructor TConversa.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TConversa.VerificarMensagemEnviada: iConversa;
begin
  try
    FQuery.Active := False;

    FQuery.SQL.Clear;
    FQuery.SQL.Add('SELECT COD_MENSAGEM, IDCONVERSA, MENSAGEM ');
    FQuery.SQL.Add('FROM MENSAGEM ');
    FQuery.SQL.Add('WHERE DATA_ENVIO_RECEBIDO IS NULL AND ');
    FQuery.SQL.Add('TIPO_MENSAGEM = ''M'' ');
    FQuery.SQL.Add('LIMIT 1');
    FQuery.Active := true;

    FMensagem := FQuery.FieldByName('MENSAGEM').AsString;
    FContato := FQuery.FieldByName('IDCONVERSA').AsString;
    FCodigoMensagem := FQuery.FieldByName('COD_MENSAGEM').AsInteger;

    Result := Self;
  except
    on ex: exception do
      raise exception.Create('Erro ao consultar mensagem, não enviada: '
                             + ex.Message);
  end;

//  try
//    FQuery.Active := false;
//    FQuery.SQL.Clear;
////    FQuery.SQL.Add('INSERT INTO MENSAGEM(CONTATO,TELEFONE,MENSAGEM,');
////    FQuery.SQL.Add('IDCONVERSA,DATA_ENVIO_RECEBIDO, TIPO_MENSAGEM)');
////    FQuery.SQL.Add('VALUES (:CONTATO,:TELEFONE,:MENSAGEM,:IDCONVERSA,');
////    FQuery.SQL.Add(':DATA_ENVIO_RECEBIDO,:TIPO_MENSAGEM);');
//
//    FQuery.ParamByName('TIPO_MENSAGEM').AsString := ATipoMensagem;
//    FQuery.ParamByName('DATA_ENVIO_RECEBIDO').AsString :=
//      FormatDateTime('YYYY-MM-DD HH:MM:SS', ADataEnvioMensagem);
//
//    FQuery.ExecSQL;
//
//    Result := Self;
//  except
//    on ex: exception do
//      raise exception.Create('Erro ao gravar mensagem: ' + ex.Message);
//  end;
end;

function TConversa.GravarDataEnvio(ACodigoMensagem: integer): iConversa;
begin
  try
    FQuery.Active := False;
    FQuery.SQL.Clear;
    FQuery.SQL.Add('UPDATE MENSAGEM SET DATA_ENVIO_RECEBIDO = ');
    FQuery.SQL.Add(':DATA_ENVIO_RECEBIDO ');
    FQuery.SQL.Add(' WHERE COD_MENSAGEM = :COD_MENSAGEM');
    FQuery.ParamByName('DATA_ENVIO_RECEBIDO').AsString :=
      FormatDateTime('YYYY-MM-DD HH:MM:SS', Now());
    FQuery.ParamByName('COD_MENSAGEM').AsInteger := ACodigoMensagem;
    FQuery.ExecSQL;

    Result := Self;
  except
    on ex: exception do
      raise exception.Create('Erro ao gravar Data de Envio: ' + ex.Message);
  end;
end;

function TConversa.GravarMensagem(AContato,
                                  ATelefone,
                                  AMensagem,
                                  AIdConversa,
                                  ATipoMensagem: string;
                                  ADataEnvioRecebido: TDateTime): iConversa;
begin
  try
    FQuery.Active := False;
    FQuery.SQL.Clear;
    FQuery.SQL.Add('INSERT INTO MENSAGEM(CONTATO,TELEFONE,MENSAGEM,');
    FQuery.SQL.Add('IDCONVERSA,DATA_ENVIO_RECEBIDO, TIPO_MENSAGEM)');
    FQuery.SQL.Add('VALUES (:CONTATO,:TELEFONE,:MENSAGEM,:IDCONVERSA,');
    FQuery.SQL.Add(':DATA_ENVIO_RECEBIDO,:TIPO_MENSAGEM);');
    FQuery.ParamByName('CONTATO').AsString := AContato;
    FQuery.ParamByName('TELEFONE').AsString := ATelefone;
    FQuery.ParamByName('MENSAGEM').AsString := AMensagem;
    FQuery.ParamByName('IDCONVERSA').AsString := AIdConversa;
    FQuery.ParamByName('DATA_ENVIO_RECEBIDO').AsString :=
      FormatDateTime('YYYY-MM-DD HH:MM:SS', ADataEnvioRecebido);
    FQuery.ParamByName('TIPO_MENSAGEM').AsString := ATipoMensagem;
    FQuery.ExecSQL;

    Result := Self;
  except
    on ex: exception do
      raise exception.Create('Erro ao gravar mensagem: ' + ex.Message);
  end;
end;

function TConversa.IdContato: string;
begin
  Result := FContato;
end;

function TConversa.IdContato(AIdContato: string): iConversa;
begin
  Result := Self;
  FContato := AIdContato;
end;

function TConversa.Mensagem: string;
begin
  Result := FMensagem;
end;

function TConversa.Mensagem(AMensagem: string): iConversa;
begin
  Result := Self;
  FMensagem := AMensagem;
end;

function TConversa.CodigoMensagem(ACodigoMensagem: integer): iConversa;
begin
  Result := Self;
  FCodigoMensagem := ACodigoMensagem;
end;

function TConversa.CodigoMensagem: integer;
begin
  Result := FCodigoMensagem;
end;

class function TConversa.New: iConversa;
begin
  Result := Self.Create;
end;

end.
