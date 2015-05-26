object frmAddDevice: TfrmAddDevice
  Left = 496
  Top = 419
  ActiveControl = edIPAddress
  BorderStyle = bsDialog
  Caption = 'Add Device'
  ClientHeight = 155
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lvIPAddress: TLabel
    Left = 24
    Top = 16
    Width = 52
    Height = 13
    Caption = 'IP Address'
  end
  object lvPort: TLabel
    Left = 56
    Top = 43
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object lbDeviceName: TLabel
    Left = 22
    Top = 96
    Width = 66
    Height = 13
    Caption = 'Device Name:'
  end
  object Bevel1: TBevel
    Left = 16
    Top = 69
    Width = 264
    Height = 2
  end
  object lbStatus: TLabel
    Left = 15
    Top = 80
    Width = 264
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'Check Failed'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edIPAddress: TEdit
    Left = 88
    Top = 12
    Width = 121
    Height = 21
    ImeName = 'Microsoft IME 2003'
    TabOrder = 0
    OnChange = edIPAddressChange
  end
  object sePort: TSpinEdit
    Left = 88
    Top = 38
    Width = 85
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
    OnChange = edIPAddressChange
  end
  object btnCheck: TBitBtn
    Left = 212
    Top = 11
    Width = 67
    Height = 46
    Caption = 'Check'
    TabOrder = 2
    OnClick = btnCheckClick
    Glyph.Data = {
      02020000424D0202000000000000020100002800000010000000100000000100
      08000000000000010000120B0000120B0000330000003300000000000000FFFF
      FF00FF00FF0000970000008E0000008800000085000000820000006900000066
      0000016A010002830200026A0200036B030005880600046C040006920700079C
      0700087E08000C6C0C00159C16001871180024772400307D30003C823C004888
      48000E820F001090120018A81A001586160023A525002AB32C00218C240031AF
      34003BBF3F003AB23E004DCB520058CF5E005ED664001EAA26001B83220054C8
      5D003ABE47003DC54A0045C5530051CC5E0046AF520046B454006BE1820072E5
      8900FFFFFF000202020202020202020202020202020202020202021709150202
      0202020202020202020213070305080202020202020202020213060303030408
      0202020202020202130603030303030408020202020202020E1111110B271111
      100A02020202151B1C1C1C1213282A1C1C140C020202092B1F1F1A160219282C
      1F1F1E0D0202132E291D1602020219282D2222210F0202150918020202020219
      2830242423130202020202020202020219283126250902020202020202020202
      0219282F20170202020202020202020202020219020202020202020202020202
      0202020202020202020202020202020202020202020202020202020202020202
      020202020202}
  end
  object btnOk: TBitBtn
    Left = 128
    Top = 123
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    NumGlyphs = 2
  end
  object btnCancel: TBitBtn
    Left = 207
    Top = 123
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    NumGlyphs = 2
  end
end
