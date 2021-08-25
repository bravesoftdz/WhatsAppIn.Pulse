unit ufrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  REST.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Vcl.AppEvnts, Vcl.ExtCtrls, REST.Response.Adapter, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, Vcl.ComCtrls, Vcl.Buttons, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, uTInject.Classes, uTInject.JS, uTInject.ConfigCEF,
  uTInject.Constant, uTInject.Console, uTInject.Diversos, uTInject.AdjustNumber,
  uBotGestor, uBotConversa, uInterfacesConversa, System.TypInfo,
  System.Generics.Collections, uGeral, System.UITypes,
  System.StrUtils, uTInject, uConversa, System.NetEncoding,
  uInjectDecryptFile, uBase64;

type
  TfrmPrincipal = class(TForm)
    TInject: TInject;
    tmrClearMemoria: TTimer;
    triIcon: TTrayIcon;
    btStatus: TStatusBar;
    lblAvisos: TLabel;
    tmrVerificarMensagem: TTimer;
    pnlNumeroConectado: TPanel;
    lblNumeroConectado: TLabel;
    lblMeuNumero: TLabel;
    ApplicationEvents: TApplicationEvents;
    chkAutoResposta: TCheckBox;
    lblTempoInatividade: TLabel;
    edtMinuto: TEdit;
    lblMinutos: TLabel;
    pgPrincipal: TPageControl;
    tbsAutenticacao: TTabSheet;
    tbsLogs: TTabSheet;
    pnlContatos: TPanel;
    whatsOn: TImage;
    whatsOff: TImage;
    lblStatus: TLabel;
    lblInformacoes: TLabel;
    btnDesconectar: TSpeedButton;
    btnAutenticar: TSpeedButton;
    mnoLogs: TMemo;
    procedure btnAutenticarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TInjectGetMyNumber(Sender: TObject);
    procedure TInjectGetStatus(Sender: TObject);
    procedure TInjectGetUnReadMessages(const Chats: TChatList);
    procedure tmrVerificarMensagemTimer(Sender: TObject);
  private
    { Private declarations }
    Gestor: TBotManager;
    ConversaAtual: TBotConversa;
    FiConversa: iConversa;

    procedure Autenticar;
    procedure CarregarConfiguracaoAutencicao;
    procedure EnviarMensagem(pEtapa: Integer;
                             pTexto: string;
                             pAnexo: string = '';
                             pExtra: Boolean = false);
    function Base64FromBitmap(Bitmap: TBitmap): string;
    function BitmapFromBase64(const base64: string): TBitmap;
  public
    { Public declarations }
    procedure GestorInteracao(pConversa: TBotConversa);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}


procedure TfrmPrincipal.Autenticar;
begin
  if not TInject.Auth(false) then
  begin
    TInject.FormQrCodeType := Ft_http;
    TInject.FormQrCodeStart;
  end;

  if not TInject.FormQrCodeShowing then
    TInject.FormQrCodeShowing := True;

  CarregarConfiguracaoAutencicao;
end;

function TfrmPrincipal.Base64FromBitmap(Bitmap: TBitmap): string;
var
  Input: TBytesStream;
  Output: TStringStream;
  Encoding: TBase64Encoding;
begin
  Input := TBytesStream.Create;
  try
    Bitmap.SaveToStream(Input);
    Input.Position := 0;
    Output := TStringStream.Create('', TEncoding.ASCII);

    try
      Encoding := TBase64Encoding.Create(0);
      Encoding.Encode(Input, Output);
      Result := Output.DataString;
    finally
      Encoding.Free;
      Output.Free;
    end;
  finally
    Input.Free;
  end;
end;

function TfrmPrincipal.BitmapFromBase64(const base64: string): TBitmap;
var
  Input: TStringStream;
  Output: TBytesStream;
  Encoding: TBase64Encoding;
begin
  Input := TStringStream.Create(base64, TEncoding.ASCII);
  try
    Output := TBytesStream.Create;
    try
      Encoding := TBase64Encoding.Create(0);
      Encoding.Decode(Input, Output);

      Output.Position := 0;
      Result := TBitmap.Create;
      try
        Result.LoadFromStream(Output);
      except
        Result.Free;
        raise;
      end;
    finally
      Encoding.DisposeOf;
      Output.Free;
    end;
  finally
    Input.Free;
  end;
end;

procedure TfrmPrincipal.btnAutenticarClick(Sender: TObject);
begin
  Autenticar;
end;

procedure TfrmPrincipal.CarregarConfiguracaoAutencicao;
var
  lMinuto: Integer;
begin
  TInject.Config.AutoDelay := 1000;
  TInject.Config.ControlSendTimeSec := 1000;
  TInject.Config.SecondsMonitor := 2;
  TInject.InjectJS.AutoUpdateTimeOut := 4000;

  Gestor := TBotManager.Create(self);
  Gestor.Simultaneos := 100;
  lMinuto := StrToInt(edtMinuto.Text);
  lMinuto := lMinuto * 60000;
  Gestor.TempoInatividade := lMinuto; // (90 * 1000);

  Gestor.OnInteracao := GestorInteracao;
end;

procedure TfrmPrincipal.EnviarMensagem(pEtapa: Integer; pTexto, pAnexo: string;
  pExtra: Boolean);
begin
  ConversaAtual.Etapa := pEtapa;
  ConversaAtual.Pergunta := pTexto;
  ConversaAtual.Resposta := '';

//  if ConversaAtual.ID <> '' then
//  begin
//    if pAnexo <> '' then
//      TInject.SendFile(ConversaAtual.ID,
//                       pAnexo,
//                       ConversaAtual.Pergunta)
//    else
//      TInject.send(ConversaAtual.ID,
//                   ConversaAtual.Pergunta);
//  end;
end;

procedure TfrmPrincipal.GestorInteracao(pConversa: TBotConversa);
var
  lNumTelefone: String;
  injectDecrypt: TInjectDecryptFile;
  AChat: TChatClass;
  AMessage: TMessagesClass;
begin
  ConversaAtual := pConversa;
  lNumTelefone := ConversaAtual.Telefone;

//  lNumTelefone :=
//    FiConversa.AjustarNumTelefone(lNumTelefone, ConversaAtual.Telefone);

  mnoLogs.Lines.Add(PChar( 'Contato: ' + Trim(pConversa.Nome)));
  mnoLogs.Lines.Add(PChar( 'Telefone: ' + pConversa.Telefone));
  mnoLogs.Lines.Add('Mensagem: ' +
                    StringReplace(pConversa.Resposta,
                                  #$A,
                                  #13#10,
                                  [rfReplaceAll,
                                  rfIgnoreCase]));

  FiConversa.GravarMensagem(pConversa.Nome,
                              pConversa.Telefone,
                              pConversa.Resposta,
                              pConversa.ID,
                              'C',
                              pConversa.DataEnvioRecebido)
end;

procedure TfrmPrincipal.TInjectGetMyNumber(Sender: TObject);
begin
  lblNumeroConectado.Caption := TInject.MyNumber;
end;

procedure TfrmPrincipal.TInjectGetStatus(Sender: TObject);
begin
  if not Assigned(Sender) Then
    Exit;

  if (TInject.Status = Inject_Initialized) then
  begin
    whatsOn.Visible := True;
    whatsOff.Visible := false;
    lblStatus.Caption := 'Online';
    lblStatus.Font.Color := $0000AE11;
    lblNumeroConectado.Visible := whatsOn.Visible;
    tmrVerificarMensagem.Enabled := True;
    TInject.GetBatteryStatus;
  end
  else
  begin
    whatsOn.Visible := false;
    whatsOff.Visible := True;
    lblStatus.Caption := 'Offline';
    lblStatus.Font.Color := $002894FF;
    tmrVerificarMensagem.Enabled := False;
  end;

  lblInformacoes.Visible := false;
  case TInject.Status of
    Server_ConnectedDown:
      lblInformacoes.Caption := TInject.StatusToStr;
    Server_Disconnected:
      lblInformacoes.Caption := TInject.StatusToStr;
    Server_Disconnecting:
      lblInformacoes.Caption := TInject.StatusToStr;
    Server_Connected:
      lblInformacoes.Caption := '';
    Server_Connecting:
      lblInformacoes.Caption := TInject.StatusToStr;
    Inject_Initializing:
      lblInformacoes.Caption := TInject.StatusToStr;
    Inject_Initialized:
      lblInformacoes.Caption := TInject.StatusToStr;
    Server_ConnectingNoPhone:
      lblInformacoes.Caption := TInject.StatusToStr;
    Server_ConnectingReaderCode:
      lblInformacoes.Caption := TInject.StatusToStr;
    Server_TimeOut:
      lblInformacoes.Caption := TInject.StatusToStr;
    Inject_Destroying:
      lblInformacoes.Caption := TInject.StatusToStr;
    Inject_Destroy:
      lblInformacoes.Caption := TInject.StatusToStr;
  end;

  if lblInformacoes.Caption <> '' Then
    lblInformacoes.Visible := True;
end;

procedure TfrmPrincipal.TInjectGetUnReadMessages(const Chats: TChatList);
var
  lChatClass: TChatClass;
  lMessagesClass: TMessagesClass;
  injectDecrypt: TInjectDecryptFile;
  lteste: string;
begin
  for lChatClass in Chats.Result do
  begin
    for lMessagesClass in lChatClass.Messages do
    begin
      if not lChatClass.isGroup then
      begin
        if not lMessagesClass.sender.isMe then
          Gestor.AdministrarChatList(TInject, Chats);
      end;
    end;
  end;
end;

procedure TfrmPrincipal.tmrVerificarMensagemTimer(Sender: TObject);
  procedure prTesteEnvio;
  begin
    TInject.SendFile('554884549164@c.us',
                     'C:\Projetos\WhatsAppIn.Pulse\BIN\teste daniel.pdf',
                     'teste pdf');
  end;

begin
  try
//    prTesteEnvio;
    tmrVerificarMensagem.Enabled := False;

    FiConversa.VerificarMensagemEnviada;

    if not (FiConversa.Mensagem = EmptyStr) then
    begin
      TInject.Send(FiConversa.IdContato,
                   FiConversa.Mensagem);

      FiConversa.GravarDataEnvio(FiConversa.CodigoMensagem);
    end;
  finally
    tmrVerificarMensagem.Interval := 50000 * (Random(3) + 1);
    tmrVerificarMensagem.Enabled := true;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  GlobalCEFApp.EnableMediaStream := True;
  FiConversa := TConversa.New;
end;

end.
