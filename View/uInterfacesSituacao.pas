unit uInterfacesSituacao;

interface

type
  iSituacao = interface
    ['{38B39351-A579-4E95-B07F-021D1B59AD22}']
    function PegarSituacao(pCPF: String): iSituacao;
    function GetTextoSituacao: string;
    property TextoSituacao: string read GetTextoSituacao;
  end;

implementation

end.
