object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 357
  Width = 438
  object fdConexao: TFDConnection
    Params.Strings = (
      'Database=whatsappinpulse'
      'User_Name=root'
      'Password=fat0516fat'
      'Server=127.0.0.1'
      'DriverID=MySQL')
    LoginPrompt = False
    Left = 16
    Top = 16
  end
  object fdPhysMySQLDriverLink: TFDPhysMySQLDriverLink
    VendorLib = 'C:\Projetos\WhatsAppIn.Pulse\bin\libmysql.dll'
    Left = 112
    Top = 16
  end
  object fdWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 64
    Top = 16
  end
end
