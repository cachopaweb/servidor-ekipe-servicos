unit UnitDMPrincipal;

interface

uses
  System.SysUtils, System.Classes, Data.DB, IBX.IBCustomDataSet, IBX.IBQuery,
  IBX.IBDatabase;

type
  TDMPrincipal = class(TDataModule)
    IBTransPrincipal: TIBTransaction;
    IBDBPrincipal: TIBDatabase;
    IBQRPrincipal: TIBQuery;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DMPrincipal: TDMPrincipal;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
