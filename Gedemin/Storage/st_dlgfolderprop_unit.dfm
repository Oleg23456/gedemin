object st_dlgfolderprop: Tst_dlgfolderprop
  Left = 419
  Top = 239
  BorderStyle = bsDialog
  Caption = '�����'
  ClientHeight = 188
  ClientWidth = 327
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel5: TBevel
    Left = 8
    Top = 14
    Width = 314
    Height = 9
    Shape = bsTopLine
  end
  object Label1: TLabel
    Left = 8
    Top = 20
    Width = 77
    Height = 13
    Caption = '������������:'
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 66
    Height = 13
    Caption = '����������:'
  end
  object Bevel2: TBevel
    Left = 8
    Top = 147
    Width = 314
    Height = 9
    Shape = bsTopLine
  end
  object Bevel3: TBevel
    Left = 8
    Top = 40
    Width = 314
    Height = 9
    Shape = bsTopLine
  end
  object Label6: TLabel
    Left = 8
    Top = 89
    Width = 67
    Height = 13
    Caption = '����������:'
  end
  object Label7: TLabel
    Left = 8
    Top = 110
    Width = 81
    Height = 13
    Caption = '������ ������:'
  end
  object Label8: TLabel
    Left = 8
    Top = 69
    Width = 35
    Height = 13
    Caption = '�����:'
  end
  object Bevel4: TBevel
    Left = 87
    Top = 15
    Width = 10
    Height = 132
    Shape = bsRightLine
  end
  object lName: TLabel
    Left = 104
    Top = 20
    Width = 77
    Height = 13
    Caption = '������������:'
  end
  object lFolders: TLabel
    Left = 104
    Top = 69
    Width = 35
    Height = 13
    Caption = '�����:'
  end
  object lValues: TLabel
    Left = 104
    Top = 89
    Width = 67
    Height = 13
    Caption = '����������:'
  end
  object lSize: TLabel
    Left = 104
    Top = 110
    Width = 39
    Height = 13
    Caption = '������:'
  end
  object Label3: TLabel
    Left = 8
    Top = 130
    Width = 52
    Height = 13
    Caption = '��������:'
  end
  object lModified: TLabel
    Left = 104
    Top = 130
    Width = 48
    Height = 13
    Caption = '��������'
  end
  object Button1: TButton
    Left = 247
    Top = 160
    Width = 75
    Height = 21
    Caption = '�������'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 159
    Top = 160
    Width = 75
    Height = 21
    Caption = '�������'
    TabOrder = 1
  end
  object eLocation: TEdit
    Left = 104
    Top = 48
    Width = 217
    Height = 19
    BorderStyle = bsNone
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 2
    Text = '����������'
  end
end
