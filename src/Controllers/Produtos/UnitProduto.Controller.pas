unit UnitProduto.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json;

type
  TProdutosController = class
    class procedure Router;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TProdutosController }

uses
  UnitConnection.Model.Interfaces,
  UnitDatabase,
  UnitFunctions,
  UnitProduto.Model,
  UnitTabela.Helper.Json;

class procedure TProdutosController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProduto;
  id: Integer;
begin
  try
    id := Req.Params.Items['id'].ToInteger();
    Produtos := TProduto.Create(TDatabase.Connection);
    Produtos.Apagar(id);
    Res.Send('').Status(THTTPStatus.NoContent);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProduto;
    aJson: TJSONArray;
    Query: iQuery;
begin
  aJson := TJSONArray.Create;
  Query := TDatabase.Query;
  try
    Produtos := TProduto.Create(TDatabase.Connection);
    try
      Produtos.BuscaDadosTabela(GeraCodigo('PRODUTOS', 'PRO_CODIGO')-1);
    except
      Produtos.BuscaDadosTabela(1);
    end;
    Query.Open('SELECT PRO_CODIGO FROM PRODUTOS ORDER BY PRO_CODIGO');
    Query.Dataset.First;
    while not Query.Dataset.Eof do
    begin
      Produtos.BuscaDadosTabela(Query.Dataset.FieldByName('PRO_CODIGO').AsInteger);
      aJson.Add(TJSONObject.ParseJSONValue(Produtos.ToJson) as TJSONObject);
      Query.Dataset.Next;
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProduto;
    aJson: TJSONArray;
    id: Integer;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  try
    Produtos := TProduto.Create(TDatabase.Connection);
    Produtos.BuscaDadosTabela(id);
    Res.Send<TJSONObject>(TJSONObject.ParseJSONValue(Produtos.ToJson) as TJSONObject);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProduto;
begin
  try
    Produtos := TProduto.Create(TDatabase.Connection).fromJson<TProduto>(Req.Body);
    Produtos.SalvaNoBanco(1);
    Res.Send<TJSONObject>(TJSONObject.ParseJSONValue(Produtos.ToJson) as TJSONObject);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProduto;
begin
  try
    Produtos := TProduto.Create(TDatabase.Connection).fromJson<TProduto>(Req.Body);
    Produtos.SalvaNoBanco(1);
    Res.Send<TJSONObject>(TJSONObject.ParseJSONValue(Produtos.ToJson) as TJSONObject);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.Router;
begin
  THorse.Group
        .Prefix('/v1')
        .Route('/produtos')
          .Get(Get)
          .Post(Post)
          .Put(Put)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/produtos/:id')
          .Get(GetForID)
          .Delete(Delete)
        .&End
end;

end.
