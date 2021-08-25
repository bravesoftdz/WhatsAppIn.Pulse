program WhastAppIn.Pulse;

uses
  Vcl.Forms,
  uTInject.ConfigCEF,
  ufrmPrincipal in 'View\ufrmPrincipal.pas' {frmPrincipal},
  udtmConexao in 'Model\udtmConexao.pas' {DM: TDataModule},
  uLogger in 'Controller\uLogger.pas',
  uBotGestor in 'Controller\uBotGestor.pas',
  uConversa in 'Controller\uConversa.pas',
  uInterfacesConversa in 'View\uInterfacesConversa.pas',
  uGeral in 'Controller\uGeral.pas',
  uBotConversa in 'Controller\uBotConversa.pas',
  uInjectDecryptFile in 'C:\Componentes\Projeto-TInject\Source\Model\uInjectDecryptFile.pas',
  uBase64 in 'Controller\uBase64.pas';

{$R *.res}

begin
  If not GlobalCEFApp.StartMainProcess then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
