object DMPrincipal: TDMPrincipal
  OldCreateOrder = False
  Height = 356
  Width = 605
  object IBTransPrincipal: TIBTransaction
    DefaultDatabase = IBDBPrincipal
    Params.Strings = (
      'read_committed'
      'rec_version'
      'wait')
    Left = 24
    Top = 80
  end
  object IBDBPrincipal: TIBDatabase
    DatabaseName = 'D:\PROJETOS\Ekipe Servicos\Dados\PRINCIPAL.FDB'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey')
    LoginPrompt = False
    ServerType = 'IBServer'
    AllowStreamedConnected = False
    Left = 24
    Top = 16
  end
  object IBQRPrincipal: TIBQuery
    Database = IBDBPrincipal
    Transaction = IBTransPrincipal
    ObjectView = True
    BufferChunks = 1000
    CachedUpdates = True
    ParamCheck = True
    Left = 112
    Top = 16
  end
end
