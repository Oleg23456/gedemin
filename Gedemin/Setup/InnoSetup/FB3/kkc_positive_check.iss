; External components: Windows Script Host, Windows Script Control

; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define public GedAppID "POSitiveCheck25"
#define public URL "http://kkc.by"
#define public DefDir "\KKC\POSitive Check"
#define public DefGroup "KKC"
#define public SupportPhone "+375-17-32-111-32"

#define public GedAppName "POSitive: Check"
#define public GedAppVerName "POSitive: Check"
#define public GedSafeAppName "POSitive Check"
#define public DBFileOnlyName "menufront"

#define public UpdateToken "POSITIVE_CHECK"
#define public Cash "True"

#include "CommonLocal.iss"

[Icons]
Name: "{group}\{#GedSafeAppName} �����-����"; Filename: "{app}\gedemin.exe"; Parameters: "/sn ""{app}\Database\{#DBFileOnlyName}.fdb"" /user Term /password 1"; WorkingDir: "{app}"
Name: "{commondesktop}\{#GedSafeAppName} �����-����"; Filename: "{app}\gedemin.exe"; Parameters: "/sn ""{app}\Database\{#DBFileOnlyName}.fdb"" /user Term /password 1"; WorkingDir: "{app}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#GedSafeAppName} �����-����"; Filename: "{app}\gedemin.exe"; Parameters: "/sn ""{app}\Database\{#DBFileOnlyName}.fdb"" /user Term /password 1"; WorkingDir: "{app}"; Tasks: quicklaunchicon
Name: "{group}\������������"; Filename: "http://gsbelarus.com/gs/content/downloads/doc/rest_front.pdf"; IconFileName: "{app}\gedemin.exe"