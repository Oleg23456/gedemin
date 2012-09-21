
unit gd_dlgAbout_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IBDatabaseInfo, ComCtrls, Mask, DBCtrls, Registry, WinSock,
  SynEdit, SynEditHighlighter, SynHighlighterIni, gdc_createable_form;

type
  TgdSysInfo = class(TObject)
  private
    FLines: TStrings;
    FTitle: String;
    FCopyright: String;

    procedure FillTempFiles;
    procedure AddSection(const S: String);
    procedure AddSpaces(const Name, Value: String);
    procedure AddLibrary(h: HMODULE; const AName: String);
    procedure AddEnv(const AName: String);
    procedure AddBoolean(const AName: String; const AValue: Boolean);
    procedure AddComLibrary(const AClsID: String; const AName: String);

  public
    constructor Create;
    destructor Destroy; override;

    procedure FillSysData;
    procedure CopyToClipboard;

    property Title: String read FTitle;
    property Copyright: String read FCopyright;
    property Lines: TStrings read FLines;
  end;

  Tgd_dlgAbout = class(TgdcCreateableForm)
    pc: TPageControl;
    TabSheet1: TTabSheet;
    btnOk: TButton;
    mCredits: TMemo;
    btnHelp: TButton;
    lblTitle: TLabel;
    TabSheet4: TTabSheet;
    btnCopy: TButton;
    SynIniSyn: TSynIniSyn;
    mSysData: TSynEdit;
    btnMSInfo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnMSInfoClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);

  private
    FSysInfo: TgdSysInfo;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  gd_dlgAbout: Tgd_dlgAbout;

implementation

{$R *.DFM}

uses
  IB, IBIntf, jclFileUtils, gd_security, ShellAPI, TypInfo,
  IBSQLMonitor_Gedemin, Clipbrd, MidConst, gdcBaseInterface,
  gd_directories_const, IBSQL, IBDatabase, gd_ClassList,
  {$IFDEF FR4}frxClass,{$ENDIF} FR_Class, ZLIB, jclBase,
  {$IFDEF EXCMAGIC_GEDEMIN}ExcMagic,{$ENDIF} TB2Version{$IFDEF GEDEMIN}, FastMM4{$ENDIF}
  {$IFDEF WITH_INDY}, IdGlobal, gd_WebClientControl_unit, gd_WebServerControl_unit{$ENDIF};

type
  TMemoryStatusEx = record
    dwLength: DWORD;
    dwMemoryLoad: DWORD;
    ullTotalPhys: Int64;
    ullAvailPhys: Int64;
    ullTotalPageFile: Int64;
    ullAvailPageFile: Int64;
    ullTotalVirtual: Int64;
    ullAvailVirtual: Int64;
    ullAvailExtendedVirtual: Int64;
  end;

function GetDiskSizeAvail(TheDrive: PChar; var Total: Integer; var Free: Integer): Boolean;
var
  lpSectorsPerCluster, lpBytesPerSector, lpNumberOfFreeClusters, lpTotalNumberOfClusters: DWORD;
begin
  Result := GetDiskFreeSpace(TheDrive, lpSectorsPerCluster, lpBytesPerSector,
    lpNumberOfFreeClusters, lpTotalNumberOfClusters);

  if Result then
  begin
    Total := MulDiv(lpTotalNumberOfClusters, lpSectorsPerCluster * lpBytesPerSector, 1024 * 1024);
    Free := MulDiv(lpNumberOfFreeClusters, lpSectorsPerCluster * lpBytesPerSector, 1024 * 1024);
  end;
end;

function HostToIP(sHost: String): String;
var
  pcAddr: PChar;
  HostEnt: PHostEnt;
  wsData: TWSAData;
  P: Integer;
begin
  Result := '127.0.0.1';

  P := Pos('/', sHost);
  if P > 0 then
    SetLength(sHost, P - 1);

  if sHost = '' then
    exit;

  WSAStartup($0101, wsData);
  try
    HostEnt := GetHostByName(PChar(sHost));
    if Assigned(HostEnt) and Assigned(HostEnt^.H_Addr_List)
      and Assigned(HostEnt^.H_Addr_List^) then
    begin
      pcAddr := HostEnt^.H_Addr_List^;
      Result := Format('%d.%d.%d.%d', [Byte(pcAddr[0]), Byte(pcAddr[1]),
        Byte(pcAddr[2]), Byte(pcAddr[3])]);
    end;
  finally
    WSACleanup;
  end;
end;

function GetGlobalMemoryRecord: TMemoryStatusEx;
type
  TGlobalMemoryStatusEx = procedure(var lpBuffer: TMemoryStatusEx); stdcall;
var
  h : THandle;
  gms : TGlobalMemoryStatusEx;
begin
  FillChar(Result, SizeOf(Result), 0);
  h := LoadLibrary(kernel32);
  try
    if h <> 0 then
    begin
      @gms := GetProcAddress(h, 'GlobalMemoryStatusEx');
      if @gms <> nil then
      begin
        Result.dwLength := SizeOf(Result);
        gms(Result);
      end;
    end;
  finally
    FreeLibrary(h);
  end;
end;

function GetOS: String;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', False)
      and Reg.ValueExists('ProductName') then
    begin
      Result := Reg.ReadString('ProductName');
      if Reg.ValueExists('CSDVersion') then
        Result := Result + ', ' + Reg.ReadString('CSDVersion');
    end else
      Result := '����������';
  finally
    Reg.Free;
  end;
end;

procedure Tgd_dlgAbout.FormCreate(Sender: TObject);
begin
  with FSysInfo do
  begin
    lblTitle.Caption := Title;

    mCredits.Lines.Insert(0, '');
    mCredits.Lines.Insert(0, Copyright);

    mSysData.Lines.Assign(Lines);
    mSysData.SelStart := 0;
  end;
end;

procedure Tgd_dlgAbout.btnHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure Tgd_dlgAbout.btnMSInfoClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'msinfo32.exe', nil, nil, SW_SHOW);
end;

procedure TgdSysInfo.FillTempFiles;
var
  TempPath: array[0..1023] of Char;

  procedure AddFile(const AFileName: String);
  var
    FullName, S: String;
    F: THandle;
    Sz: DWORD;
  begin
    FullName := String(TempPath) + '\' + AFileName;
    if FileExists(FullName) then
    begin
      S := '���� ������������';
      F := FileOpen(FullName, fmOpenRead);
      if F <> INVALID_HANDLE_VALUE then
      try
        Sz := GetFileSize(F, nil);
        if Sz <> INVALID_FILE_SIZE then
          S := FormatFloat('#,##0', Sz) + ' ����';
      finally
        FileClose(F);
      end;

      AddSpaces(AFileName, S);
    end;
  end;

begin
  if Assigned(IBLogin) and (IBLogin.DBID > -1) and (IBLogin.UserKey > -1)
    and (GetTempPath(SizeOf(TempPath), TempPath) > 0) then
  begin
    AddSection('��������� �����');
    AddSpaces('������������', TempPath);

    AddFile('g' + IntToStr(IBLogin.DBID) + '.atr');
    AddFile('g' + IntToStr(IBLogin.DBID) + '.sfh');
    AddFile('g' + IntToStr(IBLogin.DBID) + '.sfd');
    AddFile('g' + IntToStr(IBLogin.DBID) + '.gsc');
    AddFile('g' + IntToStr(IBLogin.DBID) + '_' + IntToStr(IBLogin.UserKey) + '.usc');

    FLines.Add('');
    FLines.Add('; ��������� ����� ������������ ��� ����������� ����������');
    FLines.Add('; �� ���� ������ � ��������� ������� ���������.');
    FLines.Add('; ��� �������� ��������� ������ �������: �������� �������,');
    FLines.Add('; ��������� � ��������� �����, ������� ����� �� ������.');
    FLines.Add('; ��������� �������� ��������� ������ ����� � �������');
    FLines.Add('; ��������� ��������� ������ /nc.');
  end;
end;

procedure Tgd_dlgAbout.btnCopyClick(Sender: TObject);
begin
  FSysInfo.CopyToClipboard;
end;

procedure TgdSysInfo.FillSysData;
var
  T: TTraceFlag;
  S: String;
  I, TotalB, TotalF: Integer;
  WSAData: TWSAData;
  CompName: array[0..$FF] of Char;
  DriveLetter: Char;
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  FLines.Clear;
  FTitle := '';
  FCopyright := '';

  if Assigned(IBLogin) and IBLogin.LoggedIn then
  begin
    with TIBDatabaseInfo.Create(nil) do
    try
      Database := IBLogin.Database;

      AddSection('C����� ���� ������');
      AddSpaces('������ �������',  Version);
      if IBLogin.ServerName > '' then
      begin
        AddSpaces('��� ����������/����',  IBLogin.ServerName);
        AddSpaces('IP �������',  HostToIP(IBLogin.ServerName));
      end;
      //AddBoolean('���������� ������',  IBLogin.ServerName = '');
      AddSpaces('��� ����� ��',  DBFileName);
      AddSpaces('ODS ������',  IntToStr(ODSMajorVersion) + '.' + IntToStr(ODSMinorVersion));
      AddSpaces('������ ��������',  IntToStr(PageSize));
      AddBoolean('�������������� ���.', Boolean(ForcedWrites));
      AddSpaces('������ ������', IntToStr(NumBuffers));
      AddSpaces('������������ ������', FormatFloat('#,##0', CurrentMemory div 1024) + ' ��');
    finally
      Free;
    end;
  end;

  WSAStartup($0101, WSAData);
  try
    GetHostName(CompName, SizeOf(CompName));
  finally
    WSACleanup;
  end;

  AddSection('���������');
  AddSpaces('�������� ���������', CompName);
  AddSpaces('IP �����', HostToIP(CompName));
  AddSpaces('��� �����', FormatFloat('#,##0', GetGlobalMemoryRecord.ullTotalPhys div 1024 div 1024) + ' ��');
  AddSpaces('��� ��������', FormatFloat('#,##0', GetGlobalMemoryRecord.ullAvailPhys div 1024 div 1024) + ' ��');
  AddSpaces('������ ��', GetOS);
  AddSpaces('���� � �����', FormatDateTime('dd.mm.yyyy hh:nn:ss', Now));

  AddSection('�������');
  AddSpaces('��� �����', ExtractFileName(Application.EXEName));
  AddSpaces('������������', ExtractFilePath(Application.EXEName));
  AddSpaces('���� �����', FormatDateTime('dd.mm.yyyy', FileDateToDateTime(FileAge(Application.EXEName))));
  if VersionResourceAvailable(Application.EXEName) then
    with TjclFileVersionInfo.Create(Application.EXEName) do
    try
      FTitle := '��������� �������, v. ' + ProductVersion;
      FCopyright := LegalCopyright;

      AddSpaces('������ �����', BinFileVersion);
      AddSpaces('��������', FileDescription);
    finally
      Free;
    end;

  S := '';
  for I := 1 to ParamCount do
    if Pos(' ', ParamStr(I)) = 0 then
      S := S + ParamStr(I) + ' '
    else
      S := S + '"' + ParamStr(I) + '"' + ' ';
  AddSpaces('��������� ������', S);

  S := '';
  {$IFDEF EXCMAGIC_GEDEMIN}S := S + 'EXCMAGIC_GEDEMIN, ';{$ENDIF}
  {$IFDEF DUNIT_TEST}S := S + 'DUNIT_TEST, ';{$ENDIF}
  {$IFDEF GEDEMIN_LOCK}S := S + 'GEDEMIN_LOCK, ';{$ENDIF}
  {$IFDEF SPLASH}S := S + 'SPLASH, ';{$ENDIF}
  {$IFDEF CATTLE}S := S + 'CATTLE, ';{$ENDIF}
  {$IFDEF SYNEDIT}S := S + 'SYNEDIT, ';{$ENDIF}
  {$IFDEF DEBUG}S := S + 'DEBUG, ';{$ENDIF}
  {$IFDEF FR4}S := S + 'FR4, ';{$ENDIF}
  {$IFDEF IBSQLCACHE}S := S + 'IBSQLCACHE, ';{$ENDIF}
  {$IFDEF TEECHARTPRO}S := S + 'TEECHARTPRO, ';{$ENDIF}
  {$IFDEF QEXPORT}S := S + 'QEXPORT, ';{$ENDIF}
  {$IFDEF CATTLE}S := S + 'CATTLE, ';{$ENDIF}
  {$IFDEF MESSAGE}S := S + 'MESSAGE, ';{$ENDIF}
  {$IFDEF CURRSELLCONTRACT}S := S + 'CURRSELLCONTRACT, ';{$ENDIF}
  {$IFDEF REALIZATION}S := S + 'REALIZATION, ';{$ENDIF}
  {$IFDEF PROTECT}S := S + 'PROTECT, ';{$ENDIF}
  {$IFDEF GEDEMIN}S := S + 'GEDEMIN, ';{$ENDIF}
  {$IFDEF LOADMODULE}S := S + 'LOADMODULE, ';{$ENDIF}
  {$IFDEF MODEM}S := S + 'MODEM, ';{$ENDIF}
  {$IFDEF GED_LOC_RUS}S := S + 'GED_LOC_RUS, ';{$ENDIF}
  {$IFDEF LOCALIZATION}S := S + 'LOCALIZATION, ';{$ENDIF}
  {$IFDEF QBUILDER}S := S + 'QBUILDER, ';{$ENDIF}
  {$IFDEF WITH_INDY}S := S + 'WITH_INDY, ';{$ENDIF}
  if S > '' then
  begin
    SetLength(S, Length(S) - 2);
    AddSpaces('������� ����������', S);
  end;

  {$IFDEF WITH_INDY}
  AddSection('WebServer');
  AddBoolean('�������', gdWebServerControl.Active);
  AddSpaces('Bindings', gdWebServerControl.GetBindings);
  AddSpaces('WebServer', gdWebClientThread.gdWebServerURL);
  AddSpaces('ServerResponse', gdWebClientThread.ServerResponse);
  {$ENDIF}

  AddSection('������ ���������');
  AddSpaces('Fast Report 2', Copy(IntToStr(frCurrentVersion), 1, 1) + '.' +
    Copy(IntToStr(frCurrentVersion), 2, 255));
  {$IFDEF FR4}AddSpaces('Fast Report 4', FR_VERSION);{$ENDIF}
  AddSpaces('ZLib', ZLIB_VERSION);
  AddSpaces('JCL', IntToStr(JclVersionMajor) + '.' + IntToStr(JclVersionMinor));
  AddSpaces('Toolbar 2000', Toolbar2000Version);
  {$IFDEF GEDEMIN}AddSpaces('FastMM', FastMMVersion);{$ENDIF}
  {$IFDEF EXCMAGIC_GEDEMIN}AddSpaces('Exceptional Magic', ExceptionHook.Version);{$ENDIF}
  {$IFDEF WITH_INDY}AddSpaces(gsIdProductName, gsIdVersion);{$ENDIF}

  AddLibrary(GetIBLibraryHandle, 'fbclient.dll');
  AddComLibrary(MIDAS_GUID1, 'MIDAS.DLL');
  AddComLibrary(GSDBQUERY_GUID, 'GSDBQUERY.DLL');

  AddSection('������������ ���������');
  AddSpaces('CurrencyString', CurrencyString);
  AddSpaces('ThousandSeparator', '"' + ThousandSeparator + '"');
  AddSpaces('DecimalSeparator', DecimalSeparator);
  AddSpaces('CurrencyDecimals', IntToStr(CurrencyDecimals));
  AddSpaces('DateSeparator', DateSeparator);
  AddSpaces('ShortDateFormat', ShortDateFormat);
  AddSpaces('LongDateFormat', LongDateFormat);
  AddSpaces('TimeSeparator', TimeSeparator);
  AddSpaces('TimeAMString', TimeAMString);
  AddSpaces('TimePMString', TimePMString);
  AddSpaces('ShortTimeFormat', ShortTimeFormat);
  AddSpaces('LongTimeFormat', LongTimeFormat);
  AddSpaces('TwoDigitYearCenturyWindow', IntToStr(TwoDigitYearCenturyWindow));

  AddSection('������� �����');
  for DriveLetter := 'C' to 'Z' do
  begin
    if (GetDriveType(PChar(DriveLetter + ':\')) = DRIVE_FIXED) and
      GetDiskSizeAvail(PChar(DriveLetter + ':\'), TotalB, TotalF) then
        AddSpaces(DriveLetter + ':',
          FormatFloat('#,##0', TotalB) + ' ��, ��������: ' + FormatFloat('#,##0', TotalF) + ' ��');
  end;

  AddSection('���������� �����');
  AddEnv('ISC_USER');
  AddEnv('ISC_PASSWORD');
  AddEnv('ISC_PATH');
  AddEnv('TEMP');
  AddEnv('TMP');
  AddEnv('PATH');

  if Assigned(IBLogin) and IBLogin.LoggedIn then
  with IBLogin do
  begin
    AddSection('���� ������');
    AddSpaces('������ ����� ��', DBVersion);
    AddSpaces('�� ����� ��', IntToStr(DBID));
    AddSpaces('���� ������ ��', FormatDateTime('dd.mm.yyyy', DBReleaseDate));
    AddSpaces('�����������', DBVersionComment);

    AddSpaces('�� �����������', IntToStr(CompanyKey));
    AddSpaces('�����������', CompanyName);
    AddSpaces('�������', HoldingList);
    AddSpaces('������� ��', IntToStr(gdcBaseManager.GetNextID));

    AddSection('��������� �����������');
    for I := 0 to Database.Params.Count - 1 do
    begin
      if I = Database.Params.IndexOfName('USER_NAME') then
        continue;
      if I = Database.Params.IndexOfName('PASSWORD') then
        continue;
      AddSpaces(Database.Params.Names[I], Database.Params.Values[Database.Params.Names[I]]);
    end;

    AddSection('������������');
    AddSpaces('������� ������', UserName);
    AddSpaces('�������', ContactName);
    AddSpaces('������������ ��', IBName);
    AddSpaces('�� ������� ������', IntToStr(UserKey));
    AddSpaces('�� ��������', IntToStr(ContactKey));
    AddSpaces('������',  IntToStr(SessionKey));
    AddSpaces('���� � ����� �����.',  DateTimeToStr(StartTime));

    AddSection('��������� �����������');
    S := '';
    for T := tfQPrepare to tfMisc do
    begin
      if T in Database.TraceFlags then
        S := S + GetEnumName(TypeInfo(TTraceFlag), Integer(T)) + ', ';
    end;
    if S > '' then
      SetLength(S, Length(S) - 2);
    AddSpaces('����������� � ��', S);

    S := '';
    for T := tfQPrepare to tfMisc do
    begin
      if T in MonitorHook.TraceFlags then
        S := S + GetEnumName(TypeInfo(TTraceFlag), Integer(T)) + ', ';
    end;
    if S > '' then
      SetLength(S, Length(S) - 2);
    AddSpaces('SQL �������', S);
  end;

  FillTempFiles;

  if Assigned(IBLogin) and IBLogin.LoggedIn and Assigned(gdcBaseManager) then
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;
      q.Transaction := Tr;

      q.SQL.Text :=
        'SELECT CURRENT_CONNECTION as conn, CURRENT_ROLE as role, CURRENT_USER as usr, ' +
        'CURRENT_DATE as dt, CURRENT_TIME as tm  FROM rdb$database';
      q.ExecQuery;
      AddSection('����������� ����������');
      AddSpaces('CURRENT_CONNECTION',  q.FieldByName('conn').AsString);
      AddSpaces('CURRENT_ROLE',  q.FieldByName('role').AsString);
      AddSpaces('CURRENT_USER',  q.FieldByName('usr').AsString);
      AddSpaces('CURRENT_DATE',  q.FieldByName('dt').AsString);
      AddSpaces('CURRENT_TIME',  q.FieldByName('tm').AsString);

      q.Close;
      q.SQL.Text :=
        'SELECT mon$variable_name, mon$variable_value ' +
        'FROM mon$context_variables WHERE mon$transaction_id IS NULL';
      q.ExecQuery;
      while not q.EOF do
      begin
        AddSpaces(q.Fields[0].AsString,  q.Fields[1].AsString);
        q.Next;
      end;

      q.Close;
      q.SQL.Text := 'SELECT * FROM mon$database';
      q.ExecQuery;
      if not q.EOF then
      begin
        AddSection('MON$DATABASE');
        for I := 0 to q.Current.Count - 1 do
          AddSpaces(q.Current[I].Name,  q.Current[I].AsString);
      end;

      q.Close;
      q.SQL.Text :=
        'SELECT u.name as username, a.*, ROUND(mu.mon$memory_used / 1024 / 1024 + 0.5) || '' Mb'' AS mon$memory_usage ' +
        'FROM mon$attachments a JOIN gd_user u ON u.ibname = a.mon$user ' +
        '  JOIN mon$memory_usage mu ON mu.mon$stat_id = a.mon$stat_id ' +
        'WHERE mon$attachment_id = CURRENT_CONNECTION';
      q.ExecQuery;
      if not q.EOF then
      begin
        AddSection('������� ����������� �� MON$ATTACHMENTS');
        for I := 0 to q.Current.Count - 1 do
          AddSpaces(q.Current[I].Name,  q.Current[I].AsString);
      end;

      if IBLogin.IsIBUserAdmin then
      begin
        q.Close;
        q.SQL.Text :=
          'SELECT u.name as username, a.*, ROUND(mu.mon$memory_used / 1024 / 1024 + 0.5) || '' Mb'' AS mon$memory_usage ' +
          'FROM mon$attachments a JOIN gd_user u ON u.ibname = a.mon$user ' +
          '  JOIN mon$memory_usage mu ON mu.mon$stat_id = a.mon$stat_id ' +
          'WHERE mon$attachment_id <> CURRENT_CONNECTION';
        q.ExecQuery;
        while not q.EOF do
        begin
          AddSection(q.FieldByName('username').AsTrimString);
          for I := 0 to q.Current.Count - 1 do
            AddSpaces(q.Current[I].Name,  q.Current[I].AsString);
          q.Next;
        end;
      end;  
    finally
      q.Free;
      Tr.Free;
    end;
  end;
end;

procedure TgdSysInfo.AddSection(const S: String);
begin
  if FLines.Count > 0 then
    FLines.Add('');
  FLines.Add('[' + S + ']');
end;

procedure TgdSysInfo.AddSpaces(const Name, Value: String);
begin
  FLines.Add(Name + StringOfChar(' ', 20 - Length(Name)) + ' = ' + Value);
end;

procedure TgdSysInfo.AddLibrary(h: HMODULE; const AName: String);
var
  HasLoaded: Boolean;
  Ch: array[0..2048] of Char;
begin
  if h = 0 then
  begin
    h := SafeLoadLibrary(AName);
    HasLoaded := True;
  end else
    HasLoaded := False;

  if h > HINSTANCE_ERROR then
    try
      GetModuleFileName(h, Ch, SizeOf(Ch));

      AddSection('���������� ' + ExtractFileName(Ch));
      AddSpaces('��� �����', Ch);
      AddSpaces('���� �����', FormatDateTime('dd.mm.yyyy', FileDateToDateTime(FileAge(Ch))));

      if VersionResourceAvailable(Ch) then
        with TjclFileVersionInfo.Create(Ch) do
        try
          AddSpaces('������', BinFileVersion);
          AddSpaces('��������', FileDescription);
        finally
          Free;
        end;
    finally
      if HasLoaded then
        FreeLibrary(h);
    end
  else begin
    AddSection('���������� ' + AName);
    AddSpaces('��� �����', '<�� ���������>');
  end;
end;

procedure TgdSysInfo.AddEnv(const AName: String);
var
  Ch: array[0..2048] of Char;
begin
  if GetEnvironmentVariable(PChar(AName), Ch, SizeOf(Ch)) > 0 then
    AddSpaces(AName, Ch)
  else
    AddSpaces(AName, '<�� ����������>')
end;

procedure TgdSysInfo.AddBoolean(const AName: String;
  const AValue: Boolean);
begin
  if AValue then
    AddSpaces(AName, '��')
  else
    AddSpaces(AName, '���');
end;

procedure TgdSysInfo.AddComLibrary(const AClsID: String; const AName: String);
var
  Reg: TRegistry;
  FN: String;
  Flag: Boolean;
  FAge: Integer;
begin
  Flag := False;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;

    if Reg.OpenKeyReadOnly('CLSID\' + AClsID + '\InProcServer32')
      and (Reg.GetDataType('') = rdString) and (Reg.ReadString('') > '') then
    begin
      FN := Reg.ReadString('');

      AddSection('���������� ' + AName);
      if FileExists(FN) then
      begin
        AddSpaces('��� �����', FN);

        FAge := FileAge(FN);
        if FAge > -1 then
          AddSpaces('���� �����', FormatDateTime('dd.mm.yyyy', FileDateToDateTime(FAge)));

        if VersionResourceAvailable(FN) then
          with TjclFileVersionInfo.Create(FN) do
          try
            AddSpaces('������', BinFileVersion);
            AddSpaces('��������', FileDescription);
          finally
            Free;
          end;
      end else
        AddSpaces('���� �� ������', FN);

      Flag := True;
    end;
  finally
    Reg.Free;
  end;

  if not Flag then
    AddLibrary(0, AName);
end;

constructor TgdSysInfo.Create;
begin
  FLines := TStringList.Create;
  FillSysData;
end;

destructor TgdSysInfo.Destroy;
begin
  FLines.Free;
  inherited;
end;

constructor Tgd_dlgAbout.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FSysInfo := TgdSysInfo.Create;
end;

destructor Tgd_dlgAbout.Destroy;
begin
  FSysInfo.Free;
  inherited;
end;

procedure TgdSysInfo.CopyToClipboard;
var
  Ch: array[0..KL_NAMELENGTH] of Char;
  Kl: Integer;
  FNext: Boolean;
begin
  FNext := False;

  GetKeyboardLayoutName(Ch);
  KL := StrToInt('$' + StrPas(Ch));

  case (KL and $3ff) of
    LANG_BELARUSIAN, LANG_RUSSIAN: ;
  else
    ActivateKeyBoardLayout(HKL_NEXT, 0);

    GetKeyboardLayoutName(Ch);
    KL := StrToInt('$' + StrPas(Ch));

    case (KL and $3ff) of
      LANG_BELARUSIAN, LANG_RUSSIAN: FNext := True;
    else
      ActivateKeyBoardLayout(HKL_PREV, 0);
    end;
  end;

  Clipboard.AsText := FLines.Text;

  if FNext then
    ActivateKeyBoardLayout(HKL_PREV, 0);
end;

initialization
  RegisterFrmClass(Tgd_dlgAbout);

finalization
  UnRegisterFrmClass(Tgd_dlgAbout);
end.

