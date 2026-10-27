unit UnitEmpreitadas.Model;

interface

uses
  UnitPortalORM.Model;

type

  [TNomeTabela('EMPREITADAS', 'EMP_CODIGO')]
  TEmpreitadas = class(TTabela)
  private
    FCodigo: integer;
    FObs: string;
    FNfs: string;
    FOrd: integer;
    FLocal_execucao_servicos: string;
    FFat: integer;
    FCodFor: integer;
    FValor: Currency;
    FFun: integer;
    { private declarations }
  public
    { public declarations }
    [TCampo('EMP_CODIGO', 'INTEGER NOT NULL PRIMARY KEY')]
    property Codigo: integer read FCodigo write FCodigo;
    [TCampo('EMP_ORD', 'INTEGER')]
    property Ord: integer read FOrd write FOrd;
    [TCampo('EMP_FOR', 'INTEGER')]
    property CodFor: integer read FCodFor write FCodFor;
    [TCampo('EMP_FAT', 'INTEGER')]
    property Fat: integer read FFat write FFat;
    [TCampo('EMP_OBS', 'VARCHAR(500)')]
    property Obs: string read FObs write FObs;
    [TCampo('EMP_LOCAL_EXECUCAO_SERVICOS', 'VARCHAR(500)')]
    property Local_execucao_servicos: string read FLocal_execucao_servicos write FLocal_execucao_servicos;
    [TCampo('EMP_NFS', 'VARCHAR(15)')]
    property Nfs: string read FNfs write FNfs;
    [TCampo('EMP_VALOR', 'NUMERIC(12,4)')]
    property Valor: Currency read FValor write FValor;
    [TCampo('EMP_FUN', 'INTEGER')]
    property Fun: integer read FFun write FFun;    
  end;

implementation

end.
