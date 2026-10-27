unit UnitDataset.Controller;

interface
uses
	System.SysUtils,
  System.Json,
	Horse,
  Dataset.Serialize,
  UnitConnection.Model.Interfaces;

type
	TDatasetController = class
  	class procedure Router;
    class procedure Post(Req: THorseRequest; Res: THorseResponse);
  end;

implementation

{ TControllerDataset }

uses UnitDatabase;

class procedure TDatasetController.Post(Req: THorseRequest;
  Res: THorseResponse);
var
  JsonSQL: TJSONObject;
  SQL: string;
  Query: iQuery;
  aJson: TJSONArray;
  oJson: TJSONObject;
begin
	JsonSQL := Req.Body<TJSONObject>;
  SQL := JsonSQL.GetValue<string>('sql');
  Query := TDatabase.Query;
  Query.Add(SQL);
  if not SQL.ToUpper.contains('SELECT') then
  begin
	  Query.ExecSQL;
    Res.Send('{}');
  end else
  begin  	
  	Query.Open();
    if Query.DataSet.RecordCount > 1 then
    begin
    	if Query.DataSet.FieldCount = 1 then
      begin
      	//tratamento para quando tem somente um campo no dataset
      	aJson := TJSONArray.Create;
      	Query.DataSet.First;
        while not Query.DataSet.Eof do
        begin
        	oJson := Query.DataSet.ToJSONObject();
          aJson.AddElement(oJson);
          Query.DataSet.Next;
        end;
        Res.Send<TJSONArray>(aJson);
      end else
    		Res.Send<TJSONArray>(Query.DataSet.ToJSONArray())
    end
    else
    	Res.Send<TJSONObject>(Query.DataSet.ToJSONObject())    
  end;
end;

class procedure TDatasetController.Router;
begin
 	THorse.Group
  	.Prefix('v1')
    	.Route('dataset')
        .Post(Post)
      .&End;
end;

end.
