�
 TGDC_DLGACCTTRENTRY 0�  TPF0�Tgdc_dlgAcctTrEntrygdc_dlgAcctTrEntryLeft�Top�BorderWidthCaption������� ��������ClientHeight,ClientWidthePixelsPerInch`
TextHeight � TBevelBevel1Left TopWidtheHeightAlignalTopShape	bsTopLine  �TButton	btnAccessLeft TopTabOrder  �TButtonbtnNewLeftHTopTabOrder  �TButtonbtnHelpLeft� TopTabOrder  �TButtonbtnOKLeft� TopTabOrder  �TButton	btnCancelLeft!TopTabOrder  �TPanelPanel2Left Top WidtheHeightAlignalTop
BevelOuterbvNoneTabOrder  TLabelLabel1LeftTopWidth5HeightCaption	��������:  TLabelLabel2LeftTop4WidthKHeightCaption�� ���������:  TLabellblRecordFunctionLeftTop|Width0HeightCaption�������:  TLabelLabel3LeftTopdWidthCHeightCaption���� ������:  TLabellDocTypeLeftTopLWidthPHeightCaption��� ���������:  TLabelLabel4LeftTopWidthMHeightCaption������� ����.:  TLabelLabel5LeftTop� WidthCHeightCaption��������� �:  TLabelLabel6Left� Top� WidthHeightCaption��:  TDBEditdbedDescriptionLeftXTop WidthHeight	DataFieldDESCRIPTION
DataSource	dsgdcBaseTabOrder   TgsIBLookupComboBoxiblcDocumentTypeLeftXTop0WidthHeightHelpContextDatabasedmDatabase.ibdbGAdminTransaction
ibtrCommon
DataSource	dsgdcBase	DataFielddocumenttypekey	ListTableGD_DOCUMENTTYPE	ListFieldNAMEKeyFieldID	SortOrdersoAsc
ItemHeightTabOrder  TButtonBtnFuncWizardLeftTopwWidthRHeightAction	actWizardParentShowHintShowHint	TabOrder  TDBCheckBoxdbcbIsSaveNullEntryLeftXTop� Width� HeightCaption��������� ������� ��������	DataField
issavenull
DataSource	dsgdcBaseTabOrderValueChecked1ValueUnchecked0  TgsIBLookupComboBoxiblcAccountChartLeftXTop`WidthHeightHelpContextDatabasedmDatabase.ibdbGAdminTransaction
ibtrCommon
DataSource	dsgdcBase	DataField
accountkey	ListTable
ac_account	ListFieldaliasKeyFieldID	SortOrdersoAsc	Conditioncaccounttype = 'C' and EXISTS (SELECT * FROM ac_companyaccount c WHERE c.accountkey = ac_account.id)gdClassNameTgdcAcctChart
ItemHeightParentShowHintShowHint	TabOrder  TDBEditdbeFumctionNameLeftXTopxWidth� HeightColor	clBtnFace	DataFieldNAME
DataSource
dsFunctionReadOnly	TabOrder  TDBComboBoxcbDocumentPartLeftXTopHWidthHeight	DataFieldDOCUMENTPART
DataSource	dsgdcBase
ItemHeightItems.Strings������������ TabOrder  TgsIBLookupComboBoxiblcTransactionLeftXTopWidthHeightHelpContext
DataSource	dsgdcBase	DataFieldTRANSACTIONKEY	ListTableac_transaction	ListFieldnameKeyFieldID	ConditionN(ac_transaction.AUTOTRANSACTION IS NULL OR ac_transaction.AUTOTRANSACTION = 0)gdClassNameTgdcAcctTransaction
ItemHeightParentShowHintShowHint	TabOrder  TDBCheckBoxdbcbIsDiasabledLeftXTop� Width� HeightCaption������� �������� ���������	DataFieldDISABLED
DataSource	dsgdcBaseTabOrderValueChecked1ValueUnchecked0  TxDateDBEditxDTeddbeginLeftWTop� WidthAHeight	DataFielddbegin
DataSource	dsgdcBaseKindkDateEmptyAtStart	EditMask!99\.99\.9999;1;_	MaxLength
TabOrder	  TxDateDBEdit	xDTeddendLeft� Top� WidthAHeight	DataFielddend
DataSource	dsgdcBaseKindkDateEmptyAtStart	EditMask!99\.99\.9999;1;_	MaxLength
TabOrder
  TMemomPeriodHelpLeftWTop� WidthHeight<TabStopColorclInfoBkLines.Strings-�������� ����� ������������� ��� ����������, )�������� � ��������� �������� ���. ����� -���� ������: ������ ���� ������, ������ ���� $��������� ��� ��� ���� ������������. ReadOnly	TabOrder   �TActionListalBaseLeft� Topx TActionactDetailNewCategoryDetailCaption�����
ImageIndex   TActionactDetailEditCategoryDetailCaption�������������
ImageIndex  TActionactDetailDeleteCategoryDetailCaption�������
ImageIndex  TActionactDetailDuplicateCategoryDetailCaption��������
ImageIndex  TActionactDetailCutCategoryDetailCaption��������
ImageIndex  TActionactDetailCopyCategoryDetailCaption
����������
ImageIndex  TActionactDetailPasteCategoryDetailCaption��������
ImageIndex	  TActionactDetailMacroCategoryDetailCaption�������
ImageIndex  TAction	actWizardCaption�����������Hint����������� �������	OnExecuteactWizardExecuteOnUpdateactWizardUpdate   �TDataSource	dsgdcBaseLeft� Topx  �
TPopupMenupm_dlgGLeftTop�   �TIBTransaction
ibtrCommonLeft� TopP  TDataSource
dsFunctionDataSetgdcFunctionLeft� TopP  TgdcFunctiongdcFunctionMasterSource	dsgdcBaseMasterFieldFUNCTIONKEYDetailFieldIDSubSetByIDLeft� TopP   