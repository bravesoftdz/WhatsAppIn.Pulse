unit uInterfacesConversa;

interface

uses
  FireDAC.Comp.Client;

type
  iConversa = interface
    ['{A0A73C2F-586F-4F90-A8D9-A9EC9F08EC7D}']

  function GravarMensagem(AContato,
                          ATelefone,
                          AMensagem,
                          AIdConversa,
                          ATipoMensagem: string;
                          ADataEnvioRecebido: TDateTime): iConversa;
  function VerificarMensagemEnviada: iConversa;
  function GravarDataEnvio(ACodigoMensagem: integer): iConversa;


  function Mensagem: string; overload;
  function Mensagem(AMensagem: string): iConversa; overload;
  function IdContato: string; overload;
  function IdContato(AIdContato: string): iConversa; overload;
  function CodigoMensagem: integer; overload;
  function CodigoMensagem(ACodigoMensagem: integer): iConversa; overload;
  end;

implementation

end.
