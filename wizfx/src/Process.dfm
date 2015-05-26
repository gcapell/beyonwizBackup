object frmProcess: TfrmProcess
  Left = 448
  Top = 388
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Changing File'
  ClientHeight = 136
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbFileName: TLabel
    Left = 24
    Top = 58
    Width = 450
    Height = 13
    AutoSize = False
    Caption = 'File Name'
  end
  object lbTotal: TLabel
    Left = 24
    Top = 19
    Width = 450
    Height = 13
    AutoSize = False
    Caption = 'Total Progress'
  end
  object pbTotal: TProgressBar
    Left = 17
    Top = 36
    Width = 465
    Height = 17
    Max = 1000
    TabOrder = 0
  end
  object pbFile: TProgressBar
    Left = 17
    Top = 75
    Width = 465
    Height = 17
    Max = 1000
    TabOrder = 1
  end
  object btnClose: TBitBtn
    Left = 197
    Top = 102
    Width = 105
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCloseClick
    NumGlyphs = 2
  end
  object tmClose: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmCloseTimer
    Left = 336
    Top = 32
  end
end
