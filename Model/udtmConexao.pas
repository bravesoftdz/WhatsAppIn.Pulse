unit udtmConexao;

interface

uses
  System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, uLogger,
  FireDAC.Phys.IBBase, FireDAC.VCLUI.Error, FireDAC.Comp.UI, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef;

type
  TDBConfINI = class(TComponent)
	private
		fHostName: String;
		fDataBase: String;
		fPorta: String;
		fUserName: String;
	public
		constructor Create(AOwner: TComponent); override;
		procedure LeArquivo;
		property HostName: String read fHostName;
		property DataBase: String read fDataBase;
		property Porta: String read fPorta;
		property UserName: String read fUserName;
	end;

  TDM = class(TDataModule)
    fdConexao: TFDConnection;
    fdPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
    fdWaitCursor: TFDGUIxWaitCursor;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    fDBConfINI: TDBConfINI;
    procedure CriarConexao;
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

uses
  System.IniFiles, System.SysUtils, Vcl.Forms;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDM.CriarConexao;
begin
  try
    fDBConfINI.Free;
    fDBConfINI := TDBConfINI.Create(Self);
    if (Assigned(fDBConfINI)) then
    begin
      fdConexao.Connected := False;
      fdConexao.Params.Values['DriverID'] := 'MySQL';
      fdConexao.Params.Values['Server'] := fDBConfINI.fHostName;
      fdConexao.Params.Values['Port'] := fDBConfINI.fPorta;
      fdConexao.Params.Values['Database'] := fDBConfINI.fDataBase;
      fdConexao.Params.Values['User_name'] := fDBConfINI.fUserName;
      fdConexao.Params.Values['Password'] := 'fat0516fat';
      fdConexao.Connected := True;
    end;
  except
    on E: Exception do
     TLogger.ObterInstancia.RegistrarLog('DataModuleCreate', E.Message);
  end;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  CriarConexao;
end;

{ TDBConfINI }

constructor TDBConfINI.Create(AOwner: TComponent);
begin
  inherited;
	LeArquivo;
end;

procedure TDBConfINI.LeArquivo;
var
	lExiste: Boolean;
	lCaminhoIni: String;
	lIni: TInifile;
	S: String;
begin
	lCaminhoIni := ExtractFilePath(Application.ExeName) + 'ConfTInject.ini';
	lExiste := FileExists(lCaminhoIni);

	if not lExiste then
	begin
    raise Exception.Create('Não foi possível localizar o arquivo de ' +
                           'informações do banco de dados. ' +
                           'A aplicação será fechada.');
		Application.Terminate;
	end;

	lIni := TInifile.Create(lCaminhoIni);
	try
		S := lIni.ReadString('hostname', 'hostname', '');
		if (S <> '') then
			fHostName := S;
		S := lIni.ReadString('database', 'database', '');
		if (S <> '') then
			fDataBase := S;
		S := lIni.ReadString('porta', 'porta', '');
		if (S <> '') then
			fPorta := S;
		S := lIni.ReadString('USUARIO', 'username', '');
		if (S <> '') then
			fUserName := S;
	finally
		lIni.Free;
	end;
end;

end.
