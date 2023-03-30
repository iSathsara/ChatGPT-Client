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
  PixelsPerInch = 96
  TextHeight = 15
  object Label1: TLabel
    Left = 56
    Top = 19
    Width = 54
    Height = 15
    Caption = 'Ask here...'
  end
  object lblStatus: TLabel
    Left = 272
    Top = 86
    Width = 113
    Height = 17
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
  object memResult: TMemo
    Left = 56
    Top = 136
    Width = 497
    Height = 233
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Cascadia Code Light'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object btnClear: TButton
    Left = 478
    Top = 385
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 3
    OnClick = btnClearClick
  end
  object btnCopyToClipbrd: TButton
    Left = 191
    Top = 385
    Width = 281
    Height = 25
    Caption = 'Copy to Clipboard'
    TabOrder = 4
    OnClick = btnCopyToClipbrdClick
  end
end
