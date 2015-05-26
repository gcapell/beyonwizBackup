object frmDownload: TfrmDownload
  Left = 380
  Top = 399
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Downloading...'
  ClientHeight = 145
  ClientWidth = 499
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
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
  object lbTotal: TLabel
    Left = 23
    Top = 26
    Width = 458
    Height = 13
    AutoSize = False
    Caption = 'Total Progress'
  end
  object lbFileName: TLabel
    Left = 24
    Top = 66
    Width = 450
    Height = 13
    AutoSize = False
    Caption = 'File Name'
  end
  object pbTotal: TProgressBar
    Left = 17
    Top = 44
    Width = 465
    Height = 17
    Max = 1000
    TabOrder = 0
  end
  object pbFile: TProgressBar
    Left = 17
    Top = 83
    Width = 465
    Height = 17
    Max = 1000
    TabOrder = 1
  end
  object btnClose: TBitBtn
    Left = 197
    Top = 110
    Width = 105
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCloseClick
    NumGlyphs = 2
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 328
    Top = 8
  end
  object HTTP: TIdHTTP
    MaxLineAction = maException
    ReadTimeout = 10000
    OnWork = HTTPWork
    AllowCookies = True
    HandleRedirects = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 304
    Top = 40
  end
  object tmClose: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmCloseTimer
    Left = 368
    Top = 8
  end
end
