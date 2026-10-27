unit UnitCliente.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json;

type
  TClienteController = class
    class procedure Router;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TClienteController }

uses
  UnitConnection.Model.Interfaces,
  UnitDatabase,
  UnitFunctions,
  UnitCliente.Model,
  UnitTabela.Helper.Json;

class procedure TClienteController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Cliente: TCliente;
  id: Integer;
begin
  try
    id := Req.Params.Items['id'].ToInteger();
    Cliente := TCliente.Create(TDatabase.Connection);
    Cliente.Apagar(id);
    Res.Send('').Status(THTTPStatus.NoContent);
  finally
    Cliente.DisposeOf;
  end;
end;

class procedure TClienteController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Cliente: TCliente;
    aJson: TJSONArray;
    Query: iQuery;
begin
  aJson := TJSONArray.Create;
  Query := TDatabase.Query;
  try
    Cliente := TCliente.Create(TDatabase.Connection);
    try
      Cliente.BuscaDadosTabela(GeraCodigo('CLIENTES', 'CLI_CODIGO')-1);
    except
      Cliente.BuscaDadosTabela(1);
    end;
    Query.Open('SELECT CLI_CODIGO FROM CLIENTES ORDER BY CLI_CODIGO');
    Query.Dataset.First;
    while not Query.Dataset.Eof do
    begin
      Cliente.BuscaDadosTabela(Query.Dataset.FieldByName('CLI_CODIGO').AsInteger);
      aJson.Add(TJSONObject.ParseJSONValue(Cliente.ToJson) as TJSONObject);
      Query.Dataset.Next;
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    Cliente.DisposeOf;
  end;
end;

class procedure TClienteController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Cliente: TCliente;
    aJson: TJSONArray;
    id: Integer;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  try
    Cliente := TCliente.Create(TDatabase.Connection);
    Cliente.BuscaDadosTabela(id);
    Res.Send<TJSONObject>(TJSONObject.ParseJSONValue(Cliente.ToJson) as TJSONObject);
  finally
    Cliente.DisposeOf;
  end;
end;

class procedure TClienteController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Cliente: TCliente;
begin
  try
    Cliente := TCliente.Create(TDatabase.Connection).fromJson<TCliente>(Req.Body);
    Cliente.SalvaNoBanco(1);
    Res.Send<TJSONObject>(TJSONObject.ParseJSONValue(Cliente.ToJson) as TJSONObject);
  finally
    Cliente.DisposeOf;
  end;
end;

class procedure TClienteController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Cliente: TCliente;
begin
  try
    Cliente := TCliente.Create(TDatabase.Connection).fromJson<TCliente>(Req.Body);
    Cliente.SalvaNoBanco(1);
    Res.Send<TJSONObject>(TJSONObject.ParseJSONValue(Cliente.ToJson) as TJSONObject);
  finally
    Cliente.DisposeOf;
  end;
end;

class procedure TClienteController.Router;
begin
  THorse.Group
        .Prefix('/v1')
        .Route('/clientes')
          .Get(Get)
          .Post(Post)
          .Put(Put)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/clientes/:id')
          .Get(GetForID)
          .Delete(Delete)
        .&End
end;

end.
