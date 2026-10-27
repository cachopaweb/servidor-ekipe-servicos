unit UnitOrdens.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json,
  Dataset.Serialize;

type
  TOrdensController = class
  private
  	class function BuscaProdutosOrdem(CodOrdem: integer): TJSONArray;
    class function BuscaServicosOrdem(CodOrdem: integer): TJSONArray;
  public
    class procedure Router;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetServicos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TOrdensController }

uses
  UnitConnection.Model.Interfaces,
  UnitDatabase,
  UnitFunctions,
  UnitOrdens.Model,
  UnitTabela.Helper.Json;

class function TOrdensController.BuscaProdutosOrdem(CodOrdem: integer): TJSONArray;
var
  Query: iQuery;
begin
	Query := TDatabase.Query;
  Query.Add('SELECT ORE_CODIGO, ORE_ORD, ORE_PRO, ORE_QUANTIDADE, ORE_VALOR, ORE_LUCRO, ORE_VALORR, ORE_VALORL, ORE_VALORF, ORE_NOME, ORE_VALORC,');
  Query.Add('ORE_VALORCM, ORE_ALIQICMS, ORE_EMBALAGEM, PRO_DESCRICAO');
  Query.Add('FROM ORD_EST JOIN PRODUTOS ON ORE_PRO = PRO_CODIGO');
  Query.Add('WHERE ORE_ORD = :ORDEM');
  Query.Add('ORDER BY ORE_CODIGO');
  Query.AddParam('ORDEM', CodOrdem);
  Query.Open;  
  Result := Query.DataSet.ToJSONArray();
end;

class function TOrdensController.BuscaServicosOrdem(CodOrdem: integer): TJSONArray;
var
  Query: iQuery;
begin
	Query := TDatabase.Query;
  Query.Add('SELECT OS_CODIGO, OS_ORD, OS_SER, OS_VALOR, OS_NOME, OS_TIPO, OS_VALORR, OS_UNIDADE_MED, OS_QUANTIDADE');
  Query.Add('FROM ORD_SER');
  Query.Add('WHERE OS_ORD = :ORDEM');
  Query.Add('ORDER BY OS_CODIGO');  
  Query.AddParam('ORDEM', CodOrdem);
  Query.Open;  
  Result := Query.DataSet.ToJSONArray();
end;

class procedure TOrdensController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Ordens: TOrdens;
  id: Integer;
begin
  try
    id := Req.Params.Items['id'].ToInteger();
    Ordens := TOrdens.Create(TDatabase.Connection);
    Ordens.Apagar(id);
    Res.Send('').Status(THTTPStatus.NoContent);
  finally
    Ordens.DisposeOf;
  end;
end;

class procedure TOrdensController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var 
	Ordens: TOrdens;
  Query: iQuery;
  SQL: string;
  Periodo: string;
  NomeCliente: string;
  Solicitacao: string;
  Status: string;
  oJson: TJSONObject;
  CodOrdem: Integer;
  Data1: string;
  Data2: string;
begin
	//filtros
	if Req.Query.ContainsKey('periodo') then
  	Periodo := Req.Query.Items['periodo'];
  if Req.Query.ContainsKey('cliente') then
  	NomeCliente := Req.Query.Items['cliente'];
  if Req.Query.ContainsKey('solicitacao') then
  	Solicitacao := Req.Query.Items['solicitacao'];
  if Req.Query.ContainsKey('status') then
  	Status := Req.Query.Items['status'];
  ////
  Query := TDatabase.Query;
  try
    SQL := 'SELECT ORD_CODIGO, ORD_DATA, ORD_VALOR, ORD_FUN, ORD_CLI, CLI_NOME, ORD_OBS, ORD_ESTADO, ' +
    'ORD_DESCONTO_P, ORD_DESCONTO_S, ORD_FAT, ORD_DEVOLUCAO_P, ORD_SOLICITACAO, ORD_OBS_ADM, ORD_NFS ' + 'FROM ORDENS JOIN CLIENTES ON ORD_CLI = CLI_CODIGO ' + 'WHERE 1=1[PERIODO][STATUS][BUSCA] ' +
    'ORDER BY [ORDEM]';
    if (not NomeCliente.IsEmpty) or (not Solicitacao.IsEmpty)then
    begin
      if not NomeCliente.IsEmpty then
      begin
        SQL := StringReplace(SQL, '[BUSCA]', ' AND CLI_NOME LIKE ''%' + NomeCliente + '%''', []);
        SQL := StringReplace(SQL, '[ORDEM]', 'CLI_NOME, ORD_CODIGO DESC', []);
      end;
      if not Solicitacao.IsEmpty then
      begin
        SQL := StringReplace(SQL, '[BUSCA]', ' AND ORD_SOLICITACAO LIKE ''%' + Solicitacao + '%''', []);
        SQL := StringReplace(SQL, '[ORDEM]', 'ORD_SOLICITACAO, ORD_CODIGO DESC', []);
      end;
    end else
      SQL := StringReplace(SQL, '[BUSCA]', '', []);
    if not Periodo.IsEmpty then
    begin
      SQL := StringReplace(SQL, '[PERIODO]', ' AND ORD_DATA BETWEEN :DATA1 AND :DATA2', []); 
      Data1 := Periodo.Replace('''', '').Substring(0, 10);
      Data2 := Periodo.Replace('''', '').Substring(13, 10);
      Query.AddParam('DATA1', StrToDate(Data1));
      Query.AddParam('DATA2', StrToDate(Data2));    
    end
    else
      SQL := StringReplace(SQL, '[PERIODO]', '', []);
    if not Status.IsEmpty then
      SQL := StringReplace(SQL, '[STATUS]', ' AND ORD_ESTADO = ''' + Status + '''', [])
    else
      SQL := StringReplace(SQL, '[STATUS]', '', []);
    // Para o caso da string não ter sido substituída ainda
    SQL := StringReplace(SQL, '[ORDEM]', 'ORD_DATA DESC, ORD_CODIGO DESC', []);
    Query.Add(SQL);
    Query.Open;
    Res.Send<TJSONArray>(Query.DataSet.ToJSONArray());
  finally
    Ordens.DisposeOf;
  end;
end;

class procedure TOrdensController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Ordens: TOrdens;
    aJson: TJSONArray;
    id: Integer;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  try
    Ordens := TOrdens.Create(TDatabase.Connection);
    Ordens.BuscaDadosTabela(id);
    Res.Send<TJSONObject>(TJSONObject.ParseJSONValue(Ordens.ToJson) as TJSONObject);
  finally
    Ordens.DisposeOf;
  end;
end;

class procedure TOrdensController.GetProdutos(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  CodOrdem: Integer;
  aJson: TJSONArray;
begin
	CodOrdem := Req.Params.Items['id'].ToInteger;
	aJson := BuscaProdutosOrdem(CodOrdem);
  Res.Send<TJSONArray>(aJson);
end;

class procedure TOrdensController.GetServicos(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  CodOrdem: Integer;
  aJson: TJSONArray;
begin
	CodOrdem := Req.Params.Items['id'].ToInteger;
	aJson := BuscaServicosOrdem(CodOrdem);
  Res.Send<TJSONArray>(aJson);

end;

class procedure TOrdensController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Ordens: TOrdens;
begin
  try
    Ordens := TOrdens.Create(TDatabase.Connection).fromJson<TOrdens>(Req.Body);
    Ordens.SalvaNoBanco(1);
    Res.Send<TJSONObject>(TJSONObject.ParseJSONValue(Ordens.ToJson) as TJSONObject);
  finally
    Ordens.DisposeOf;
  end;
end;

class procedure TOrdensController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Ordens: TOrdens;
begin
  try
    Ordens := TOrdens.Create(TDatabase.Connection).fromJson<TOrdens>(Req.Body);
    Ordens.SalvaNoBanco(1);
    Res.Send<TJSONObject>(TJSONObject.ParseJSONValue(Ordens.ToJson) as TJSONObject);
  finally
    Ordens.DisposeOf;
  end;
end;

class procedure TOrdensController.Router;
begin
  THorse.Group
        .Prefix('/v1')
        .Route('/ordens')
          .Get(Get)
          .Post(Post)
          .Put(Put)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/ordens/:id')
          .Get(GetForID)
          .Delete(Delete)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/ordens/produtos/:id')
          .Get(GetProdutos)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/ordens/servicos/:id')
          .Get(GetServicos)
        .&End
end;

end.
