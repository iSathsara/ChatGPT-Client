object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'ChatGPT Client'
  ClientHeight = 418
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 56
    Top = 19
    Width = 54
    Height = 15
    Caption = 'Ask here...'
  end
  object edtAsk: TEdit
    Left = 56
    Top = 40
    Width = 497
    Height = 23
    TabOrder = 0
  end
  object btnSubmit: TButton
    Left = 56
    Top = 82
    Width = 185
    Height = 25
    Caption = 'Ask'
    TabOrder = 1
    OnClick = btnSubmitClick
  end
  object btnClear: TButton
    Left = 478
    Top = 385
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 2
    OnClick = btnClearClick
  end
  object btnCopyToClipbrd: TButton
    Left = 191
    Top = 385
    Width = 281
    Height = 25
    Caption = 'Copy to Clipboard'
    TabOrder = 3
    OnClick = btnCopyToClipbrdClick
  end
  object pnlResult: TPanel
    Left = 56
    Top = 136
    Width = 497
    Height = 233
    Caption = 'pnlResult'
    TabOrder = 4
    object imgResult: TImage
      Left = 288
      Top = 40
      Width = 169
      Height = 145
    end
    object memResult: TMemo
      Left = 29
      Top = 40
      Width = 212
      Height = 145
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Cascadia Code Light'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object btnImage: TButton
    Left = 247
    Top = 82
    Width = 185
    Height = 25
    Caption = 'Show Image'
    TabOrder = 5
    OnClick = btnImageClick
  end
  object IdHTTP: TIdHTTP
    IOHandler = IdSSLIOHandlerSocketOpenSSL
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 176
    Top = 144
  end
  object IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Method = sslvSSLv23
    SSLOptions.SSLVersions = [sslvSSLv2, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2]
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 296
    Top = 144
  end
end
