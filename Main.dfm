object frmForm: TfrmForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'iCode Send Socket Module'
  ClientHeight = 515
  ClientWidth = 469
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LabelToken: TLabel
    Left = 19
    Top = 37
    Width = 33
    Height = 13
    Caption = #53664#53360#53412
  end
  object LabelIP: TLabel
    Left = 20
    Top = 10
    Width = 32
    Height = 13
    Caption = #49436#48260'IP'
  end
  object LabelPort: TLabel
    Left = 249
    Top = 10
    Width = 44
    Height = 13
    Caption = #54252#53944#48264#54840
  end
  object LabelTitle: TLabel
    Left = 30
    Top = 92
    Width = 22
    Height = 13
    Caption = #51228#47785
  end
  object LabelCallback: TLabel
    Left = 8
    Top = 64
    Width = 44
    Height = 13
    Caption = #48156#49888#48264#54840
  end
  object LabelTel: TLabel
    Left = 249
    Top = 64
    Width = 44
    Height = 13
    Caption = #49688#49888#48264#54840
  end
  object LabelMessage: TLabel
    Left = 8
    Top = 116
    Width = 44
    Height = 13
    Caption = #48156#49569#45236#50857
  end
  object LabelTime: TLabel
    Left = 8
    Top = 214
    Width = 44
    Height = 13
    Caption = #50696#50557#49884#44036
  end
  object LabelTimeInfo: TLabel
    Left = 225
    Top = 214
    Width = 227
    Height = 13
    Caption = #50630#51004#47732' '#51593#49884#48156#49569' / yyyymmddhhnn '#54805#53468#47196' '#51077#47141
  end
  object LabelSendType: TLabel
    Left = 32
    Top = 173
    Width = 20
    Height = 13
    Alignment = taRightJustify
    Caption = 'SMS'
  end
  object LabelMessageLength: TLabel
    Left = 40
    Top = 192
    Width = 12
    Height = 13
    Alignment = taRightJustify
    Caption = '0b'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object ButtonSend: TButton
    Left = 8
    Top = 238
    Width = 452
    Height = 41
    Caption = #47928#51088#51204#49569
    TabOrder = 8
    OnClick = ButtonSendClick
  end
  object MemoResult: TMemo
    Left = 8
    Top = 285
    Width = 452
    Height = 223
    Lines.Strings = (
      '## '#48156#49569' '#45236#50669#51060' '#51060#44275#50640' '#48372#50668#51665#45768#45796'. ##')
    ScrollBars = ssBoth
    TabOrder = 9
  end
  object EditToken: TEdit
    Left = 58
    Top = 34
    Width = 402
    Height = 21
    TabOrder = 2
  end
  object MemoMessage: TMemo
    Left = 58
    Top = 116
    Width = 402
    Height = 89
    ScrollBars = ssVertical
    TabOrder = 6
    OnChange = MemoMessageChange
  end
  object EditIP: TEdit
    Left = 58
    Top = 7
    Width = 161
    Height = 21
    TabOrder = 0
    Text = '211.172.232.124'
  end
  object EditPort: TEdit
    Left = 300
    Top = 7
    Width = 161
    Height = 21
    TabOrder = 1
    Text = '9201'
  end
  object EditTitle: TEdit
    Left = 58
    Top = 89
    Width = 402
    Height = 21
    TabOrder = 5
  end
  object EditCallback: TEdit
    Left = 58
    Top = 61
    Width = 161
    Height = 21
    TabOrder = 3
  end
  object EditTel: TEdit
    Left = 299
    Top = 61
    Width = 161
    Height = 21
    TabOrder = 4
  end
  object EditTime: TEdit
    Left = 58
    Top = 211
    Width = 161
    Height = 21
    TabOrder = 7
  end
end
