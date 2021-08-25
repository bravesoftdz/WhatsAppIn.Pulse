unit uBotGestor;

interface

uses
  System.StrUtils, System.SysUtils, System.Classes, Vcl.ExtCtrls,
  System.Generics.Collections, uTInject, uTInject.Classes, uBotConversa;

type
  TBotManager = class(TComponent)
  private
    FSenhaADM: String;
    FSimultaneos: Integer;
    FTempoInatividade: Integer;
    FConversas: TObjectList<TBotConversa>;

    FOnInteracao: TNotifyConversa;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AdministrarChatList(AInject: TInject; AChats: TChatList);
    procedure ProcessarResposta(AMessagem: TMessagesClass);

    function BuscarConversa(AID: String): TBotConversa;
    function NovaConversa(AMessage: TMessagesClass): TBotConversa;
    function BuscarConversaEmEspera: TBotConversa;
    function AtenderProximoEmEspera: TBotConversa;

    property SenhaADM: String read FSenhaADM write FSenhaADM;
    property Simultaneos: Integer read FSimultaneos write FSimultaneos default 1;
    property Conversas: TObjectList<TBotConversa> read FConversas;
    property TempoInatividade: Integer read FTempoInatividade write FTempoInatividade;

    // Procedures notificadoras
    procedure ProcessarInteracao(Conversa: TBotConversa);
    procedure ConversaSituacaoAlterada(Conversa: TBotConversa);

    // Notify
    property OnInteracao: TNotifyConversa read FOnInteracao write FOnInteracao;
  end;

implementation

{ TBotManager }

constructor TBotManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FConversas := TObjectList<TBotConversa>.Create;
//  FiConversa := TConversa.New;
end;

destructor TBotManager.Destroy;
begin
  FreeAndNil(FConversas);
  inherited Destroy;
end;

procedure TBotManager.AdministrarChatList(AInject: TInject; AChats: TChatList);
var
  AChat: TChatClass;
  AMessage: TMessagesClass;
begin
  for AChat in AChats.result do
  begin
    if not AChat.isGroup then
    begin
      AInject.ReadMessages(AChat.id);
      AMessage := AChat.messages[Low(AChat.messages)];

      if not AMessage.sender.isMe then
        ProcessarResposta(AMessage);
    end;
  end;
end;

procedure TBotManager.ProcessarResposta(AMessagem: TMessagesClass);
var
  AConversa: TBotConversa;
begin
  AConversa := BuscarConversa(AMessagem.sender.id);

  if not Assigned(AConversa) then
    AConversa := NovaConversa(AMessagem);

  // Tratando a situacao em que vem a mesma mensagem.
  if AConversa.IDMensagem <> AMessagem.t then
  begin
    AConversa.IDMensagem := AMessagem.t;
    AConversa.Resposta := AMessagem.body;
    AConversa.&type := AMessagem.&type;
    AConversa.DataEnvioRecebido := Now;
    // Houve interacao, reinicia o timer de inatividade da conversa;
    AConversa.ReiniciarTimer;

    // Tratando a situacao em que vem a localizacao.
    if (AMessagem.lat <> 0) and (AMessagem.lng <> 0) then
    begin
      AConversa.lat := AMessagem.lat;
      AConversa.lng := AMessagem.lng;
    end;

    // Notifica mensagem recebida
    ProcessarInteracao(AConversa);
  end;
end;

function TBotManager.BuscarConversa(AID: String): TBotConversa;
var
  AConversa: TBotConversa;
begin
  result := nil;
  for AConversa in FConversas do
  begin
    if AConversa.id = AID then
    begin
      result := AConversa;
      Break;
    end;
  end;
end;

function TBotManager.NovaConversa(AMessage: TMessagesClass): TBotConversa;
var
  ADisponivel: Boolean;
begin
  ADisponivel := (Conversas.Count < Simultaneos);

  result := TBotConversa.Create(Self);
  with result do
  begin
    TempoInatividade := Self.TempoInatividade;
    id := AMessage.sender.id;
    Telefone := Copy(AMessage.sender.id, 1, Pos('@', AMessage.sender.id) - 1);

    // Capturar nome publico, ou formatado (numero/nome).
    Nome := IfThen(AMessage.sender.PushName <> EmptyStr,
                   AMessage.sender.PushName,
                   AMessage.sender.FormattedName);

    // Eventos para controle externos
    OnSituacaoAlterada := ConversaSituacaoAlterada;
    OnRespostaRecebida := ProcessarInteracao;
  end;
  FConversas.Add(result);
end;

function TBotManager.BuscarConversaEmEspera: TBotConversa;
var
  AConversa: TBotConversa;
begin
  result := nil;
  for AConversa in FConversas do
  begin
//    if AConversa.Situacao = saEmEspera then
//    begin
//      result := AConversa;
//      Break;
//    end;
  end;
end;

function TBotManager.AtenderProximoEmEspera: TBotConversa;
begin
  result := BuscarConversaEmEspera;

  if Assigned(result) then
  begin
//    result.Situacao := saNova;
    result.ReiniciarTimer;

    ProcessarInteracao(result);
  end;
end;

procedure TBotManager.ProcessarInteracao(Conversa: TBotConversa);
begin
  if Assigned(OnInteracao) then
    OnInteracao(Conversa);
end;

procedure TBotManager.ConversaSituacaoAlterada(Conversa: TBotConversa);
begin
  // Se ficou inativo
//  if Conversa.Situacao in [saInativa, saFinalizada] then
//  begin
//    // Encaminha
//    OnInteracao(Conversa);
//
//    // Destroy
//    Conversas.Remove(Conversa);
//
//    // Atende proximo da fila
//    AtenderProximoEmEspera;
//  end;
end;

end.
