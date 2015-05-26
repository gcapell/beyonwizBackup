object frmPreference: TfrmPreference
  Left = 613
  Top = 353
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Preference'
  ClientHeight = 164
  ClientWidth = 277
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object rgDownloadType: TRadioGroup
    Left = 16
    Top = 16
    Width = 249
    Height = 79
    Caption = ' Default Download Type '
    ItemIndex = 0
    Items.Strings = (
      'WizFile Format(*.tvwiz;*.radwiz)'
      'Transfer Stream(*.TS)')
    TabOrder = 0
  end
  object cbLastDownloadpath: TCheckBox
    Left = 24
    Top = 104
    Width = 221
    Height = 17
    Caption = 'Remember last download path.'
    TabOrder = 1
  end
  object gbSpliteOption: TGroupBox
    Left = 16
    Top = 171
    Width = 249
    Height = 82
    TabOrder = 3
    Visible = False
    object Label1: TLabel
      Left = 26
      Top = 58
      Width = 42
      Height = 13
      Caption = 'File Size:'
    end
    object lbByte: TLabel
      Left = 200
      Top = 58
      Width = 22
      Height = 13
      Caption = 'Byte'
    end
    object cbPropositionSize: TComboBox
      Left = 26
      Top = 23
      Width = 167
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'User Defined'
      Items.Strings = (
        'User Defined'
        'CD Size(650 MB)'
        'CD Size(700 MB)'
        'Explorer Supported(2 GB)'
        'FAT32 Supported(4GB)'
        'DVD Single Layer(4.7 GB)'
        'DVD Double Layer(8.5 GB)')
    end
    object seFileSize: TSpinEdit
      Left = 72
      Top = 53
      Width = 121
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 1000000000
    end
  end
  object btnOk: TBitBtn
    Left = 96
    Top = 130
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    NumGlyphs = 2
  end
  object btnCancel: TBitBtn
    Left = 176
    Top = 130
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
    NumGlyphs = 2
  end
  object cbAutoSplite: TCheckBox
    Left = 24
    Top = 168
    Width = 91
    Height = 17
    Caption = 'Do Auto Splite'
    TabOrder = 2
    Visible = False
    OnClick = cbAutoSpliteClick
  end
end
