unit UnitQROrdemServicoEkipeServicos;

interface

uses
  System.SysUtils, System.Variants, System.Classes, 
  UnitQRPadrao, QRPDFFilt, Vcl.ExtCtrls, QuickRpt, QRCtrls, Vcl.Imaging.pngimage, 
  Data.DB, IBX.IBCustomDataSet, IBX.IBQuery, UnitDMPrincipal,
  Vcl.StdCtrls, Vcl.Controls;

type
  TQROrdemServicoEkipeServicos = class(TQRPadrao)
    he: TQRBand;
    QRImage1: TQRImage;
    TitleBand1: TQRBand;
    QRLabel5: TQRLabel;
    QRGroup1: TQRGroup;
    QRDBText2: TQRDBText;
    QRDBText1: TQRDBText;
    QRLabel30: TQRLabel;
    QRLabel32: TQRLabel;
    QRLabel6: TQRLabel;
    QRDBText6: TQRDBText;
    QRLabel7: TQRLabel;
    QRDBText13: TQRDBText;
    ChildBand1: TQRChildBand;
    QRBand3: TQRBand;
    QRLabel14: TQRLabel;
    QRLabel17: TQRLabel;
    QRSubDetail1: TQRSubDetail;
    QRDBText10: TQRDBText;
    QRDBText11: TQRDBText;
    QRDBText12: TQRDBText;
    QRChildBand1: TQRChildBand;
    QRChildBand2: TQRChildBand;
    QRExpr3: TQRExpr;
    QRLabel15: TQRLabel;
    QRSubDetail2: TQRSubDetail;
    QRDBText4: TQRDBText;
    QRDBText7: TQRDBText;
    QRChildBand3: TQRChildBand;
    QRExpr1: TQRExpr;
    QRLabel16: TQRLabel;
    IBQROrdemServico: TIBQuery;
    IBQRProduto: TIBQuery;
    IBQRServico: TIBQuery;
    QRLabel9: TQRLabel;
    QRDBText8: TQRDBText;
    QRDBText14: TQRDBText;
    QRDBText15: TQRDBText;
    QRLabel21: TQRLabel;
    QRMemo1: TQRMemo;
    QRLbFuncionario: TQRLabel;
    QRLabel23: TQRLabel;
    QRLabel24: TQRLabel;
    IBQROrdemServicoORD_DATA: TDateField;
    IBQROrdemServicoCLI_NOME: TIBStringField;
    IBQROrdemServicoFUN_NOME: TIBStringField;
    IBQROrdemServicoORD_VALOR: TIBBCDField;
    IBQROrdemServicoORD_CODIGO: TIntegerField;
    IBQROrdemServicoORD_OBS: TIBStringField;
    IBQROrdemServicoORD_ESTADO: TIBStringField;
    IBQROrdemServicoORD_HORAENTREGA: TTimeField;
    IBQROrdemServicoCLI_CNPJ_CPF: TIBStringField;
    IBQROrdemServicoORD_SOLICITACAO: TIBStringField;
    IBQRProdutoORE_QUANTIDADE: TIBBCDField;
    IBQRProdutoORE_VALOR: TIBBCDField;
    IBQRProdutoORE_NOME: TIBStringField;
    IBQRProdutoORE_PRO: TIntegerField;
    IBQRProdutoPRO_DESCRICAO: TIBStringField;
    IBQRProdutoPRO_CODIGO: TIntegerField;
    IBQRProdutoORE_EMBALAGEM: TIBStringField;
    IBQRServicoOS_VALOR: TIBBCDField;
    IBQRServicoOS_NOME: TIBStringField;
    IBQRServicoOS_SER: TIntegerField;
    IBQRServicoOS_UNIDADE_MED: TIBStringField;
    QRLabel22: TQRLabel;
    QRMemoTipoPgm: TQRMemo;
    QRMemoVlrTipoPgm: TQRMemo;
    QRLabel25: TQRLabel;
    QRDBText16: TQRDBText;
    IBQROrdemServicoORD_FAT: TIntegerField;
    QRDBText3: TQRDBText;
    IBQRServicoOS_QUANTIDADE: TIBBCDField;
    QRDBText5: TQRDBText;
    IBQRProdutoVLR_UNIT: TIBBCDField;
    IBQRServicoVLR_UNIT: TIBBCDField;
    QRDBText9: TQRDBText;
    IBQROrdemServicoTELEFONES: TIBStringField;
    QRLabel8: TQRLabel;
    QRDBText18: TQRDBText;
    QRBand6: TQRBand;
    Rodape: TQRLabel;
    IBQROrdemServicoCLI_ENDERECO: TIBStringField;
    IBQROrdemServicoCLI_NUMERO: TIBStringField;
    IBQROrdemServicoCLI_BAIRRO: TIBStringField;
    IBQROrdemServicoCID_DESCRICAO: TIBStringField;
    QRLabel4: TQRLabel;
    QRDBText17: TQRDBText;
    QRLabel18: TQRLabel;
    QRDBText19: TQRDBText;
    QRLabel20: TQRLabel;
    QRDBText20: TQRDBText;
    QRDBText21: TQRDBText;
    QRLabel26: TQRLabel;
    ChildBand2: TQRChildBand;
    QRLabel11: TQRLabel;
    QRLabel12: TQRLabel;
    QRLabel13: TQRLabel;
    QRLabel10: TQRLabel;
    QRLabel2: TQRLabel;
    ChildBand3: TQRChildBand;
    QRLabel29: TQRLabel;
    QRLabel31: TQRLabel;
    QRLabel19: TQRLabel;
    QRLabel1: TQRLabel;
    QRLabel3: TQRLabel;
    QRLabel27: TQRLabel;
    QRLabel28: TQRLabel;
    IBQRResumo: TIBQuery;
    IBQRResumoREC_TIPO: TIBStringField;
    IBQRResumoVLR_TOTAL: TIBBCDField;
    procedure IBQROrdemServicoAfterScroll(DataSet: TDataSet);
    procedure QuickRep1BeforePrint(Sender: TCustomQuickRep; var PrintReport: Boolean);
    procedure QRBand3BeforePrint(Sender: TQRCustomBand; var PrintBand: Boolean);
    procedure QRBand6BeforePrint(Sender: TQRCustomBand; var PrintBand: Boolean);
  private
    { Private declarations }
    FCodFatura: integer;
    function SaveReport: string;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; Fatura: integer); overload;
    function GetReport: TMemoryStream;
    procedure Execute;
  end;

var
  QROrdemServicoEkipeServicos: TQROrdemServicoEkipeServicos;

implementation

{$R *.dfm}

{ TOrcamentoEkipeServicos }

constructor TQROrdemServicoEkipeServicos.Create(AOwner: TComponent; Fatura: integer);
begin
  inherited Create(AOwner);
  FCodFatura := Fatura;
end;

procedure TQROrdemServicoEkipeServicos.Execute;
begin
	IBQROrdemServico.Close;
  IBQROrdemServico.Params[0].Value := FCodFatura;
  IBQROrdemServico.Open;
end;

function TQROrdemServicoEkipeServicos.GetReport: TMemoryStream;
var
  CaminhoArquivo: string;
begin
	CaminhoArquivo := SaveReport;
  Result.LoadFromFile(CaminhoArquivo);
end;

procedure TQROrdemServicoEkipeServicos.IBQROrdemServicoAfterScroll(DataSet: TDataSet);
var
  SOMAP, SOMAS: Currency;
begin
  IBQRProduto.Close;
  IBQRProduto.Params[0].Value := IBQROrdemServicoORD_CODIGO.Value;
  IBQRProduto.Open;
  IBQRProduto.First;
  SOMAP := 0;
  while not IBQRProduto.Eof do
  begin
    SOMAP := SOMAP + IBQRProdutoORE_VALOR.AsCurrency;
    IBQRProduto.Next;
  end;
  ChildBand1.Enabled   := not IBQRProduto.IsEmpty;
  QRSubDetail1.Enabled := ChildBand1.Enabled;
  QRChildBand2.Enabled := ChildBand1.Enabled;

  IBQRServico.Close;
  IBQRServico.Params[0].Value := IBQROrdemServicoORD_CODIGO.Value;
  IBQRServico.Open;
  IBQRServico.First;
  SOMAS := 0;
  while not IBQRServico.Eof do
  begin
    SOMAS := SOMAS + IBQRServicoOS_VALOR.AsCurrency;
    IBQRServico.Next;
  end;
  QRChildBand1.Enabled := not IBQRServico.IsEmpty;
  QRSubDetail2.Enabled := QRChildBand1.Enabled;
  QRChildBand3.Enabled := QRChildBand1.Enabled;
  QRLabel17.Caption    := FormatFloat('R$ 0.00', SOMAP + SOMAS);
  QRMemo1.Lines.Clear;
  QRMemo1.Lines.Text      := IBQROrdemServicoORD_OBS.AsString;
  QRLbFuncionario.Caption := IBQROrdemServicoFUN_NOME.AsString;
end;

procedure TQROrdemServicoEkipeServicos.QRBand3BeforePrint(Sender: TQRCustomBand; var PrintBand: Boolean);
begin
  QRMemoTipoPgm.Lines.Clear;
  QRMemoVlrTipoPgm.Lines.Clear;
  IBQRResumo.Close;
  IBQRResumo.ParamByName('FATURA').Value := FCodFatura;
  IBQRResumo.Open;
  IBQRResumo.First;
  while not IBQRResumo.Eof do
  begin
    QRMemoTipoPgm.Lines.Add(' ' + IBQRResumoREC_TIPO.AsString);
    QRMemoVlrTipoPgm.Lines.Add(FormatFloat('R$ ,0.00  ', IBQRResumoVLR_TOTAL.AsCurrency));
    IBQRResumo.Next;
  end;
end;

procedure TQROrdemServicoEkipeServicos.QRBand6BeforePrint(Sender: TQRCustomBand; var PrintBand: Boolean);
begin
  inherited;
//  Rodape.Caption := FrmPrincipal.Rodape;
end;

procedure TQROrdemServicoEkipeServicos.QuickRep1BeforePrint(Sender: TCustomQuickRep; var PrintReport: Boolean);
begin	
  try
    Execute;
  except

  end;
end;

function TQROrdemServicoEkipeServicos.SaveReport: string;
var
  Caminho: string;
  Pasta: string;
begin
	 Pasta := paramStr(0)+'/pdf';
   if not DirectoryExists(Pasta) then
     ForceDirectories(Pasta);
	 Caminho := Pasta + '/ORD '+IBQROrdemServicoORD_CODIGO.AsString + ' - '+ IBQROrdemServicoCLI_NOME.AsString + '.pdf';	
   Self.ExportToFilter(TQRPDFDocumentFilter.Create(Caminho));
   Result := Caminho
end;

end.
