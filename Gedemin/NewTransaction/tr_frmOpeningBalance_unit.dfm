inherited tr_frmOpeningBalance: Ttr_frmOpeningBalance
  Left = 212
  Top = 105
  Caption = '������� �� ������������� ������'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    object Splitter1: TSplitter [0]
      Left = 201
      Top = 27
      Width = 6
      Height = 264
      Cursor = crHSplit
    end
    inherited cbMain: TControlBar
      Height = 26
      BevelEdges = []
      inherited tbMain: TToolBar
        AutoSize = False
        inherited tbtFilter: TToolButton
          DropdownMenu = pFilter
        end
      end
      object ToolBar1: TToolBar
        Left = 374
        Top = 2
        Width = 25
        Height = 22
        Caption = 'ToolBar1'
        EdgeBorders = []
        Flat = True
        Images = ilRemains
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        object ToolButton1: TToolButton
          Left = 0
          Top = 0
          Action = actComputeAll
        end
      end
    end
    object pnlTree: TPanel
      Left = 1
      Top = 27
      Width = 200
      Height = 264
      Align = alLeft
      BevelOuter = bvNone
      BorderWidth = 2
      TabOrder = 1
      object pnlTotal: TPanel
        Left = 2
        Top = 225
        Width = 196
        Height = 37
        Align = alBottom
        BevelInner = bvLowered
        TabOrder = 0
        object Label1: TLabel
          Left = 11
          Top = 2
          Width = 36
          Height = 13
          Caption = '�����:'
          Transparent = True
        end
        object Label2: TLabel
          Left = 23
          Top = 20
          Width = 42
          Height = 13
          Caption = '������:'
          Transparent = True
        end
        object Bevel1: TBevel
          Left = 10
          Top = 19
          Width = 175
          Height = 2
          Anchors = [akLeft, akTop, akRight]
        end
        object lblDebet: TLabel
          Left = 96
          Top = 2
          Width = 77
          Height = 13
          Cursor = crHandPoint
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          AutoSize = False
          Caption = 'lblDebet'
          Transparent = True
          OnClick = lblDebetClick
        end
        object lblCredit: TLabel
          Left = 108
          Top = 21
          Width = 77
          Height = 13
          Cursor = crHandPoint
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          AutoSize = False
          Caption = 'lblCredit'
          Transparent = True
          OnClick = lblDebetClick
        end
      end
      object tvAccounts: TgsIBLargeTreeView
        Left = 2
        Top = 2
        Width = 196
        Height = 223
        IDField = 'ID'
        ParentField = 'PARENT'
        LBField = 'LB'
        RBField = 'RB'
        LBRBMode = True
        ListField = 'NAME'
        OrderByField = 'ALIAS'
        RelationName = 'GD_CARDACCOUNT'
        TopBranchID = 'NULL'
        Database = dmDatabase.ibdbGAdmin
        AutoLoad = False
        StopOnCount = 150
        ShowTopBranch = False
        TopBranchText = '���'
        CheckBoxes = False
        Align = alClient
        BorderStyle = bsNone
        HideSelection = False
        Indent = 19
        TabOrder = 1
        OnChange = tvAccountsChange
      end
    end
    object pnlEntries: TPanel
      Left = 207
      Top = 27
      Width = 337
      Height = 264
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 2
      TabOrder = 2
      object Splitter2: TSplitter
        Left = 2
        Top = 196
        Width = 333
        Height = 6
        Cursor = crVSplit
        Align = alBottom
      end
      object ibgrdEntries: TgsIBGrid
        Left = 2
        Top = 2
        Width = 333
        Height = 194
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsRemains
        Options = [dgTitles, dgColumnResize, dgColLines, dgCancelOnExit]
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
      end
      object lvAnalytics: TListView
        Left = 2
        Top = 202
        Width = 333
        Height = 60
        Align = alBottom
        BorderStyle = bsNone
        Columns = <
          item
            AutoSize = True
            Caption = '���������:'
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
      end
    end
  end
  inherited alMain: TActionList
    Left = 160
    Top = 40
    inherited actNew: TAction
      OnExecute = actNewExecute
    end
    inherited actEdit: TAction
      OnExecute = actEditExecute
    end
    inherited actDelete: TAction
      OnExecute = actDeleteExecute
    end
    object actComputeAll: TAction
      Caption = '���������� ��� �����'
      Hint = '���������� ��� �����'
      ImageIndex = 0
      OnExecute = actComputeAllExecute
    end
    object actComputeCurrent: TAction
      Caption = '���������� ������� ����'
      Hint = '���������� ������� ����'
      ImageIndex = 1
    end
  end
  inherited pmMainReport: TPopupMenu
    Top = 104
  end
  object ibtrOpeningBalance: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 240
    Top = 100
  end
  object ibdsAccounts: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrOpeningBalance
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT '
      '  *'
      ''
      'FROM'
      '  GD_CARDACCOUNT CA'
      ''
      'ORDER BY'
      '  CA.ALIAS'
      '  ')
    Left = 300
    Top = 100
  end
  object dsAccounts: TDataSource
    DataSet = ibdsAccounts
    Left = 300
    Top = 130
  end
  object ibsqlEntryAnalitics: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '  SUM(DEBITSUMNCU), SUM(CREDITSUMNCU)'
      ''
      'FROM'
      '  GD_ENTRYS E'
      ''
      'WHERE'
      '  E.ACCOUNTKEY = :ACCOUNTKEY '
      '    AND'
      '  E.ENTRYKEY = :ENTRYKEY')
    Transaction = ibtrOpeningBalance
    Left = 270
    Top = 100
  end
  object ibdsRemains: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrOpeningBalance
    AfterScroll = ibdsRemainsAfterScroll
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_ENTRYS'
      'where'
      '  ID = :OLD_ID')
    RefreshSQL.Strings = (
      'SELECT'
      '  E.ID,'
      '  E.ACCOUNTTYPE,'
      '  E.DOCUMENTKEY,'
      '  E.ENTRYDATE,'
      ''
      '  E.DEBITSUMNCU,'
      '  E.CREDITSUMNCU,'
      ''
      '  E.DEBITSUMEQ,'
      '  E.CREDITSUMEQ,'
      ''
      '  E.CREDITSUMCURR,'
      '  E.DEBITSUMCURR,'
      ''
      '  CR.NAME AS CURRNAME'
      ''
      'FROM'
      '  GD_ENTRYS E    '
      '    LEFT JOIN'
      '      GD_CURR CR'
      '    ON'
      '      CR.ID = E.CURRKEY'
      'WHERE'
      '  E.ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  E.ID,'
      '  E.ACCOUNTTYPE,'
      '  E.DOCUMENTKEY,'
      '  E.ENTRYDATE,'
      ''
      '  E.DEBITSUMNCU,'
      '  E.CREDITSUMNCU,'
      ''
      '  E.DEBITSUMEQ,'
      '  E.CREDITSUMEQ,'
      ''
      '  E.CREDITSUMCURR,'
      '  E.DEBITSUMCURR,'
      ''
      '  CR.NAME AS CURRNAME'
      ''
      'FROM'
      '  GD_ENTRYS E    '
      '    LEFT JOIN'
      '      GD_CURR CR'
      '    ON'
      '      CR.ID = E.CURRKEY'
      ''
      'WHERE'
      '  E.ACCOUNTKEY = :ACCOUNTKEY '
      '    AND'
      '  E.ENTRYKEY = :ENTRYKEY')
    Left = 330
    Top = 100
  end
  object dsRemains: TDataSource
    DataSet = ibdsRemains
    Left = 330
    Top = 130
  end
  object atSQLSetup1: TatSQLSetup
    Ignores = <
      item
        Link = ibdsAccounts
        RelationName = 'GD_CARDACCOUNT'
        IgnoryType = itFull
      end>
    Left = 330
    Top = 70
  end
  object ilRemains: TImageList
    Left = 160
    Top = 70
    Bitmap = {
      494C010101000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00C6C6C60000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF0000FFFF00C6C6C60000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF00C6C6C60000FFFF0000000000C6C6C60000FFFF0000FFFF00C6C6
      C60000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000FFFF00C6C6C6000000000000000000C6C6C60000FF
      FF0000FFFF00C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00C6C6C60000FFFF000000000000FFFF0000FFFF00C6C6C60000000000C6C6
      C60000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF000000000000FFFF00C6C6C600000000000000000000FFFF0000FFFF00C6C6
      C60000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF00C6C6
      C60000FFFF000000000000FFFF0000FFFF00C6C6C6000000000000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF00C6C6C600000000000000000000FFFF0000FFFF00C6C6C60000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00C6C6C6000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF00C6C6C60000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFF000000000000F9FF000000000000
      F87F000000000000F01F000000000000F007000000000000E001000000000000
      E001000000000000C003000000000000C0030000000000008007000000000000
      8007000000000000E00F000000000000F80F000000000000FE1F000000000000
      FF9F000000000000FFFF00000000000000000000000000000000000000000000
      000000000000}
  end
  object ibsqlAccounts: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT '
      '  *'
      ''
      'FROM'
      '  GD_CARDACCOUNT CC'
      ''
      'WHERE'
      '  CC.LB >= :LB'
      '    AND'
      '  CC.RB <= :RB')
    Transaction = ibtrOpeningBalance
    Left = 270
    Top = 70
  end
  object ibsqlCurrentCard: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT '
      '  CARDAC.ID, '
      '  CARDAC.LB,'
      '  CARDAC.RB'
      ''
      'FROM'
      '  GD_CARDCOMPANY CARDCOMP'
      '    JOIN'
      '      GD_CARDACCOUNT CARDAC'
      '    ON'
      '      CARDAC.ID = CARDCOMP.CARDACCOUNTKEY '
      ''
      'WHERE'
      '  CARDCOMP.OURCOMPANYKEY = :COMPANYKEY'
      '    AND'
      '  CARDCOMP.ACTIVECARD = 1')
    Transaction = ibtrOpeningBalance
    Left = 270
    Top = 130
  end
  object gsqfOpenBalance: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsRemains
    Left = 375
    Top = 75
  end
  object pFilter: TPopupMenu
    Left = 215
    Top = 155
  end
  object gsReportManager1: TgsReportManager
    DataBase = dmDatabase.ibdbGAdmin
    Transaction = ibtrOpeningBalance
    PopupMenu = pmMainReport
    MenuType = mtSeparator
    Caption = '������ �������'
    GroupID = 2000602
    Left = 375
    Top = 115
  end
end
