object frAnalytics: TfrAnalytics
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object Panel: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    BevelOuter = bvLowered
    FullRepaint = False
    TabOrder = 0
    object sbAnalytics: TScrollBox
      Left = 1
      Top = 1
      Width = 318
      Height = 238
      VertScrollBar.Increment = 16
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 0
      OnMouseWheel = sbAnalyticsMouseWheel
    end
  end
end
