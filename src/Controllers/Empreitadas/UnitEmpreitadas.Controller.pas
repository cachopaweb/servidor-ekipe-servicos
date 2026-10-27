unit UnitEmpreitadas.Controller;

interface

uses
	Horse,
	Classes,
	SysUtils,
	System.Json,
  UnitFunctions,
	UnitConnection.Model.Interfaces, FireDAC.Comp.Client;

type
	TControllerEmpreitadas = class
		class procedure Router;
		class procedure PostFaturamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
	end;

implementation

{ TControllerEmpreitadas }

uses
	UnitInsereTabela.Model, 
  UnitDatabase, 
 	UnitTabela.Helper.Json,
  UnitEmpreitadas.Model,
  UnitPedFat.Model,
  UnitPF_Parcela.Model, UnitFaturamento2.Model, UnitPagamentos.Model;

class procedure TControllerEmpreitadas.PostFaturamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Cod_Fat: Integer;
  InsereRecCusto: iInsereTabela;
  Empreitada: TEmpreitadas;
  InserePedFat: iInsereTabela;
  jsonObj: TJSONObject;
  PedFat: TPedFat;
  PFParcela: TPF_Parcela;
  Faturamento2: TFaturamento2;
  aJsonPFParcela: TJSONArray;
  i: Integer;
  Parcela: Integer;
  Cod_Pag: Integer;
  Cod_Mov: Integer;
  InsereMov: TModelInsereTabela;
  CaiValorDinheiro: Currency;
  CaiCodigo: Integer;
  InsereCai: TModelInsereTabela;
  InserePag: TModelInsereTabela;
  InserePagPgm: TModelInsereTabela;
  Query: iQuery;
  DescricaoTipoPgm: string;
begin
	Cod_Fat         := IncrementaGenerator('GEN_FAT2');
  jsonObj := Req.Body<TJSONObject>;
  Empreitada := TEmpreitadas.Create(TDatabase.Connection).fromJson<TEmpreitadas>(jsonObj.GetValue<TJSONObject>('empreitadas').ToJSON);
	Empreitada.Fat := Cod_Fat;
  Empreitada.SalvaNoBanco();
	// Insere na tabela LANCAMENTO_REC_CUS para aparecer nos relatórios do Financeiro
	InsereRecCusto  := TModelInsereTabela.New(TFDQuery(TDatabase.Query.Component));
  InsereRecCusto.SetNomeTabela('LANCAMENTO_REC_CUS');
  InsereRecCusto.SetCampoCodigo('LRC_CODIGO');
  InsereRecCusto.AddCamposEValores('LRC_CODIGO', IncrementaGenerator('GEN_LRC'));
	InsereRecCusto.AddCamposEValores('LRC_DATA', Date);
	InsereRecCusto.AddCamposEValores('LRC_VALOR', Empreitada.Valor);
	InsereRecCusto.AddCamposEValores('LRC_HISTORICO', 'Empreitada da OS ' + Empreitada.Ord.ToString);
	InsereRecCusto.AddCamposEValores('LRC_OBS', 'OS ' + Empreitada.Ord.ToString + ' / NF ' + Empreitada.Nfs);
	InsereRecCusto.AddCamposEValores('LRC_DATAC', '01/01/1900');
	InsereRecCusto.AddCamposEValores('LRC_FAT2', Cod_Fat);
	InsereRecCusto.AddCamposEValores('LRC_FAT', 0);
	InsereRecCusto.AddCamposEValores('LRC_TIPO', 'C');
	InsereRecCusto.AddCamposEValores('LRC_CLI_FOR', Empreitada.CodFor);
	InsereRecCusto.AddCamposEValores('LRC_FUN', Empreitada.Fun);
  InsereRecCusto.Command.Execute;
	//
  PedFat := TPedFat.Create(TDatabase.Connection).fromJson<TPedFat>(jsonObj.GetValue<TJSONObject>('ped_fat'));
  PedFat.SalvaNoBanco();
	//
  aJsonPFParcela := jsonObj.GetValue<TJSONArray>('pf_parcela');
  for i := 0 to Pred(aJsonPFParcela.Count) do
  begin
  	PFParcela := TPF_Parcela.Create(TDatabase.Connection).fromJson<TPF_Parcela>(aJsonPFParcela.Items[i].ToJSON);
  	PFParcela.SalvaNoBanco();
  end;
	// FATURAMENTO DE PEDIDO A PRAZO
  Faturamento2 := TFaturamento2.Create(TDatabase.Connection).fromJson<TFaturamento2>(jsonObj.GetValue<TPF_Parcela>('faturamento2'));
  Faturamento2.SalvaNoBanco();	
  /// /  
  ///  
  Query := TDatabase.Query;
  Query.Add('SELECT CAI_CODIGO, CAI_VALORD FROM CAIXA WHERE CAI_CODIGO = (SELECT MAX(CAI_CODIGO) FROM CAIXA WHERE CAI_PDV = :PDV)');
  Query.AddParam('PDV', 1);
  Query.Open;
  if not Query.DataSet.IsEmpty then
  begin
  	CaiCodigo := Query.DataSet.FieldByName('CAI_CODIGO').AsInteger;
  	CaiValorDinheiro := Query.DataSet.FieldByName('CAI_VALORD').AsCurrency;
  end;  
  Parcela := 1;
  for i := 0 to Pred(aJsonPFParcela.Count) do
  begin
    PFParcela := TPF_Parcela.Create(TDatabase.Connection).fromJson<TPF_Parcela>(aJsonPFParcela.Items[i].ToJSON);
    ////
    Cod_Pag := IncrementaGenerator('GEN_PAG');
		Query := TDatabase.Query;
    Query.Add('SELECT TP_DESCRICAO FROM TIPO_PGM WHERE TP_CODIGO = :CODIGO');
    Query.AddParam('CODIGO', PFParcela.Tp);
    Query.Open;
    if not Query.DataSet.IsEmpty then
    begin
      DescricaoTipoPgm := Query.DataSet.FieldByName('TP_DESCRICAO').AsString;
    end;
    //
    InserePag := TModelInsereTabela.Create(TFDQuery(TDatabase.Query.Component));
    InserePag.SetNomeTabela('PAGAMENTOS'); 
    InserePag.SetCampoCodigo('PAG_CODIGO');
    InserePag.AddCamposEValores('PAG_CODIGO', Cod_Pag);
    InserePag.AddCamposEValores('PAG_VALOR', PFParcela.Valor);
    InserePag.AddCamposEValores('PAG_VENCIMENTO', PFParcela.Vencimento);
    InserePag.AddCamposEValores('PAG_JUROS', PFParcela.Juros);
    if PFParcela.Tp = -1 then
      InserePag.AddCamposEValores('PAG_ESTADO', 3)
    else
      InserePag.AddCamposEValores('PAG_ESTADO', 1);
    InserePag.AddCamposEValores('PAG_DUPLICATA', PFParcela.Duplicata);
    InserePag.AddCamposEValores('PAG_FPG', 1);
    InserePag.AddCamposEValores('PAG_FAT2', Cod_Fat);
    InserePag.AddCamposEValores('PAG_DESCONTOS', PFParcela.Descontos);
    InserePag.AddCamposEValores('PAG_CAI', CaiCodigo);
    InserePag.AddCamposEValores('PAG_TIPO', DescricaoTipoPgm);
    InserePag.AddCamposEValores('PAG_SITUACAO', 0);
    InserePag.AddCamposEValores('PAG_CON', PFParcela.Tp);
    InserePag.AddCamposEValores('PAG_DATAC', '01/01/1900');
    InserePag.Command.Execute;
  	//
    if PFParcela.Tp = -1 then
    begin
      Cod_Mov := IncrementaGenerator('GEN_MOV');
      InsereMov := TModelInsereTabela.Create(TFDQuery(TDatabase.Query.Component));
      InsereMov.SetNomeTabela('MOVIMENTACOES');
      InsereMov.SetCampoCodigo('MOV_CODIGO');
      InsereMov.AddCamposEValores('MOV_CODIGO', Cod_Mov);
      InsereMov.AddCamposEValores('MOV_CREDITO', 0);
      InsereMov.AddCamposEValores('MOV_DEBITO', PFParcela.Valorpg);
      InsereMov.AddCamposEValores('MOV_DESCRICAO', 'OS - ' + PedFat.Cliente);
      InsereMov.AddCamposEValores('MOV_TIPO', 2);
      InsereMov.AddCamposEValores('MOV_DATA', PedFat.Data);
      InsereMov.AddCamposEValores('MOV_SALDOANT', CaiValorDinheiro);
      InsereMov.AddCamposEValores('MOV_CON', 0);
      InsereMov.AddCamposEValores('MOV_DATAHORA', Now);
      InsereMov.AddCamposEValores('MOV_ORDENA', IncrementaGenerator('GEN_MOV2'));
      InsereMov.AddCamposEValores('MOV_PLANO', '2.2');
      InsereMov.AddCamposEValores('MOV_NOME', 'SERVIÇOS');
      InsereMov.AddCamposEValores('MOV_CAI', CaiCodigo);
      InsereMov.AddCamposEValores('MOV_ESTADO', 'A');
      InsereMov.AddCamposEValores('MOV_TROCO', 0);
      InsereMov.Command.Execute;
      //
      InsereCai := TModelInsereTabela.Create(TFDQuery(TDatabase.Query.Component));
      InsereCai.SetNomeTabela('CAIXA');
      InsereCai.SetCampoCodigo('CAI_CODIGO');
      InsereCai.AddCamposEValores('CAI_CODIGO', CaiCodigo);
      InsereCai.AddCamposEValores('CAI_VALORD', CaiValorDinheiro + PFParcela.Valorpg);
      InsereCai.Command.Execute;
      //
      InserePagPgm := TModelInsereTabela.Create(TFDQuery(TDatabase.Query.Component));
      InserePagPgm.SetNomeTabela('PAG_PGM');
      InserePagPgm.SetCampoCodigo('PP_CODIGO');      
      InserePagPgm.AddCamposEValores('PP_CODIGO', IncrementaGenerator('GEN_PP'));
      InserePagPgm.AddCamposEValores('PP_DATAPGM', PFParcela.Vencimento);
      InserePagPgm.AddCamposEValores('PP_DINHEIRO', PFParcela.Valorpg);
      InserePagPgm.AddCamposEValores('PP_CHEQUE', 0);
      InserePagPgm.AddCamposEValores('PP_MOV', Cod_Mov);
      InserePagPgm.AddCamposEValores('PP_PAG', Cod_Pag);
      InserePagPgm.AddCamposEValores('PP_HORA', Now);
      InserePagPgm.AddCamposEValores('PP_FUN', PedFat.Fun);
      InserePagPgm.AddCamposEValores('PP_CAI', CaiCodigo);
      InserePagPgm.AddCamposEValores('PP_JUROS', 0);
      InserePagPgm.AddCamposEValores('PP_DESCONTOS', 0);
      InserePagPgm.Command.Execute;
    end
    else
    begin
      InserePagPgm := TModelInsereTabela.Create(TFDQuery(TDatabase.Query.Component));
      InserePagPgm.SetNomeTabela('PAG_PGM');
      InserePagPgm.SetCampoCodigo('PP_CODIGO');      
      InserePagPgm.AddCamposEValores('PP_CODIGO', IncrementaGenerator('GEN_PP'));
      InserePagPgm.AddCamposEValores('PP_DINHEIRO', 0);
      InserePagPgm.AddCamposEValores('PP_CHEQUE', 0);
      InserePagPgm.AddCamposEValores('PP_PAG', Cod_Pag);
      InserePagPgm.Command.Execute;
    end;
    Parcela := Parcela + 1;
  end;
	Res.Send<TJSONObject>(TJSONObject.Create.AddPair('msg', 'Empreitada faturada com sucesso'));
end;

class procedure TControllerEmpreitadas.Router;
begin
	THorse
  	.Group
    	.Prefix('/v1')
      	.Route('/empreitadas/faturamento')
        	.Post(PostFaturamento)
        .&End;
end;

end.
