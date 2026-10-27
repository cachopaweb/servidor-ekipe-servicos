program ServidorEkipe;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DataSet.Serialize,
  Horse,
  Horse.CORS,
  Horse.Jhonson,
  UnitProduto.Controller in 'src\Controllers\Produtos\UnitProduto.Controller.pas',
  UnitProduto.Model in '..\Codigo\Modulos\Produtos\UnitProduto.Model.pas',
  UnitTotalizador.Model in '..\..\FormsComuns\Classes\Totalizadores\UnitTotalizador.Model.pas',
  UnitUnidadeMedida.Model in '..\..\FormsComuns\Classes\Unidade Medida\UnitUnidadeMedida.Model.pas',
  UnitDatabase in 'src\Database\UnitDatabase.pas',
  UnitConstants in 'src\Utils\UnitConstants.pas',
  UnitFunctions in 'src\Utils\UnitFunctions.pas',
  UnitCliente.Model in '..\Codigo\Modulos\Clientes\UnitCliente.Model.pas',
  UnitCliente.Controller in 'src\Controllers\Clientes\UnitCliente.Controller.pas',
  UnitFuncionarios.Model in '..\Codigo\Modulos\Funcionarios\UnitFuncionarios.Model.pas',
  UnitFuncionarios.Controller in 'src\Controllers\Funcionarios\UnitFuncionarios.Controller.pas',
  UnitOrdens.Model in '..\Shared\Ordens\UnitOrdens.Model.pas',
  UnitOrdens.Controller in 'src\Controllers\Ordens\UnitOrdens.Controller.pas',
  UnitEstado.Model in '..\..\FormsComuns\Classes\Estado\UnitEstado.Model.pas',
  UnitLogin.Controller in 'src\Controllers\Login\Controller\UnitLogin.Controller.pas',
  UnitDataset.Controller in 'src\Controllers\Dataset\UnitDataset.Controller.pas',
  UnitCidade.Model in '..\..\formscomuns\classes\cidade\UnitCidade.Model.pas',
  UnitInsereTabela.Model in '..\..\FormsComuns\Classes\Insere Dados Tabela Firedac\UnitInsereTabela.Model.pas',
  UnitEmpreitadas.Model in 'src\Controllers\Empreitadas\Model\UnitEmpreitadas.Model.pas',
  UnitPedFat.Model in '..\..\FormsComuns\Classes\PedFat\UnitPedFat.Model.pas',
  UnitPF_Parcela.Model in '..\..\FormsComuns\Classes\PF_Parcela\UnitPF_Parcela.Model.pas',
  UnitFaturamento2.Model in '..\..\FormsComuns\Classes\Faturamento2\UnitFaturamento2.Model.pas',
  UnitPagamentos.Model in '..\..\FormsComuns\Classes\Pagamentos\UnitPagamentos.Model.pas';

var 
	Port: integer;
	Porta: string;
begin
  THorse
  	.Use(CORS)
    .Use(Jhonson);
  ////
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := TCaseNameDefinition.cndNone;
  
  TLoginController.Router; 
  TProdutosController.Router;	
  TClienteController.Router;
  TFuncionariosController.Router;
  TOrdensController.Router;
  TDatasetController.Router;
  Porta := GetEnvironmentVariable('PORT');
  if not Porta.IsEmpty then
  	Port := Porta.ToInteger	
  else
  	Port := 3333;
  THorse.Listen(Port, procedure 
  begin 
  	Writeln('Server is running on port '+THorse.Port.ToString);	
  end); 
end.
