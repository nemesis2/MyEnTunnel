{ Compiler switches:
  D- : Debug info off
  L- : Local vars off
  O+ : Optimization on
  Q- : Range checking off
  R- : I/O checking off
  Y- : Local debugging off
  S- : Stack overflow check off
  H+ : Long strings on }

{$D-,L-,O+,Q-,R-,Y-,S-,H+}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, INIFiles, ComCtrls, ShellAPI, IdBaseComponent,
  IdContext, IdComponent, IdTCPConnection, IdTCPClient, IdCustomTCPServer,
  IdTCPServer, IdSync, System.UITypes, System.DateUtils, System.IOUtils,

  System.Win.Registry, // for the registry read access
  VCL.themes, VCL.Buttons; // Used for access to TStyleManager

type

  TForm1 = class(TForm)

    N1: TMenuItem;
    Exit1: TMenuItem;
    Show1: TMenuItem;
    About1: TMenuItem;
    Connect1: TMenuItem;

    Image1: TImage;
    Image2: TImage;

    PopupMenu1: TPopupMenu;
    PageControl1: TPageControl;

    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    StatusMemo: TMemo;
    ServerLabel: TLabel;
    ServerLabel2: TLabel;
    UsernameLabel: TLabel;
    PassLabel: TLabel;
    PortLabel: TLabel;

    SSHPort: TEdit;
    DecPass: TEdit;
    Username: TEdit;
    SocksPort: TEdit;
    SSHServer: TEdit;
    BeVerbose: TCheckBox;
    UseKeyfile: TCheckBox;
    EnableSocks: TCheckBox;
    RetryForever: TCheckBox;
    UseCompression: TCheckBox;
    ConnectOnStartup: TCheckBox;
    ReconnectOnFailure: TCheckBox;
    ConnectionFilter: TCheckBox;
    RetryDelay: TEdit;
    RetryLabel: TLabel;
    Notifications: TCheckBox;
    Profiles1: TMenuItem;
    NewProfile1: TMenuItem;
    N2: TMenuItem;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    licmemo: TMemo;
    readmemo: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Image3: TImage;
    Label6: TLabel;
    TrayIcon1: TTrayIcon;
    Panel1: TPanel;
    Connect: TButton;
    Hide: TButton;
    SaveHide: TButton;
    Cancel: TButton;
    Panel2: TPanel;
    LocalTunnels: TMemo;
    LocalLabel: TLabel;
    Panel3: TPanel;
    RemoteTunnels: TMemo;
    RemoteLabel: TLabel;
    TunnelLabel: TPanel;
    ExeArgs: TLabel;
    ComboBox1: TComboBox;
    plinkargs: TEdit;
    Language1: TLabel;
    EnableEchoPing: TCheckBox;
    ConfirmClose: TCheckBox;
    PingPortLabel: TLabel;
    PingPort: TEdit;
    PingTimer: TTimer;
    EnableLoopPing: TCheckBox;
    IdTCPServer1: TIdTCPServer;
    Label7: TLabel;
    heme1: TMenuItem;
    Auto1: TMenuItem;
    Dark1: TMenuItem;
    Light1: TMenuItem;
    SpeedButton1: TSpeedButton;
    Label8: TLabel;

    procedure ReadINI;
    procedure SaveINI;
    procedure SaveLang;
    procedure ReadLang;
    procedure DoConnect;
    procedure DoDisconnect;
    procedure ProcessStandardIO;
    procedure UpdateProfiles;
    procedure SwitchProfile(s: string);
    procedure Exit1Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure HideClick(Sender: TObject);
    procedure WriteStandardIO(s: string);
    procedure FormCreate(Sender: TObject);
    procedure EnableSocksClick(Sender: TObject);
    procedure ReconnectOnFailureClick(Sender: TObject);
    procedure ConnectClick(Sender: TObject);
    procedure SaveHideClick(Sender: TObject);
    procedure UseKeyfileClick(Sender: TObject);
    procedure NumbersOnly(Sender: TObject; var Key: Char);
    procedure BeVerboseClick(Sender: TObject);
    procedure WebClick(Sender: TObject);
    procedure Underline(Sender: TObject);
    procedure CheckRange(Sender: TObject);
    procedure SSHPortEnter(Sender: TObject);
    procedure RetryDelayEnter(Sender: TObject);
    procedure SocksPortEnter(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure LocalTunnelsChange(Sender: TObject);
    procedure RemoteTunnelsChange(Sender: TObject);
    procedure ProfilePopupHandler(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure NewProfile1Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Label5MouseEnter(Sender: TObject);
    procedure Label5MouseLeave(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure TabSheet3Resize(Sender: TObject);
    procedure ComboBox1DropDown(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox1CloseUp(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure PingThreadTerminate(Sender: TObject);
    procedure StopPingTimer;
    procedure PingTimerTimer(Sender: TObject);
    procedure PlinkThreadTerminate(Sender: TObject);
    procedure RightClickMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure EnableLoopPingClick(Sender: TObject);
    procedure EnableEchoPingClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure PageControl1Resize(Sender: TObject);
    procedure Auto1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);

  private
    { Private declarations }
    procedure WMPowerBroadcast(var Msg: TMessage); message WM_POWERBROADCAST;
    procedure WMEndSession(var Msg: TWMEndSession); message WM_ENDSESSION;
  public
    { Public declarations }
  end;

  TPingThread = class(TThread)
  private
    PInterval: Integer;
    PPort: Integer;
  protected
    procedure Execute; override;
    property Interval: Integer write PInterval;
    property Port: Integer write PPort;
  end;

  TPlinkThread = class(TThread)
  private
  protected
    procedure Execute; override;
  end;

  TMyNotify = class(TThread)
  private
    FStr: String;
  protected
    procedure Execute; override;
  public
    constructor Create(const AStr: string);
    class procedure UpdateForm(const Str: string);
  end;

const
  PlinkOutputPrefix = 'plink.exe: ';
  Conn = 'Connection'; { INI section name used for all settings }
  GitHubURL = 'https://github.com/nemesis2/MyEnTunnel';
  AppVersion = 'MyEnTunnel r3.6.2';
  PuTTYLink = 'https://putty.software/';
  ClickHere = 'Click here to visit';
  DarkModeThemeName = 'Carbon';
  LightModeThemeName = 'Windows';

var
  Form1: TForm1;
  Done: boolean;
  UseBlankPhrase: boolean;
  ShowOnDoubleClick: boolean;
  Shutdown: boolean;
  ExitClick: boolean = FALSE;
  GotPing: boolean = FALSE;
  AwaitingLoginResponse: boolean = FALSE;
  LostPings: Integer = 0;
  PingSequenceNumber: longint;
  PingTimerInterval: Integer;
  PingTCPPort: Integer;
  EchoPort: String = '7';
  SystemTheme: Integer = 0;

  AppIni: TIniFile;
  APPPath: string;
  password: string;
  StoreKey: string;
  FormCaption: string;
  TrayHintString: string;

  CustomPlinkExe: string;
  KeyFilePath: string;
  DefaultValue: string;
  LogFilePath: string;
  LogFileHandle: THandle = INVALID_HANDLE_VALUE;
  Profile: string;
  language: string;
  Retries: Integer;
  BackScrollLines: Integer;
  ReadPipe, WritePipe: THandle;
  ReadPipe2, WritePipe2: THandle;
  ProcessInfo: TProcessInformation;
  PlinkProcessValid: boolean = FALSE;
  Prompt: TLabel;

  ProfileSubItemCount: Integer = 0;
  ProfileSubItems: array of TMenuItem;
  LangStrings: array [0 .. 61] of WideString;
  LanguageFileNames: array [0 .. 10] of string;
  LanguageSavedText: string;

  PingThread: TPingThread;
  PlinkThread: TPlinkThread;

implementation

{$R *.DFM}
{ ── Theme ──────────────────────────────────────────────────────────────── }

function DarkModeIsEnabled: boolean;
{$IFDEF MSWINDOWS}
const
  TheKey = 'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\';
  TheValue = 'AppsUseLightTheme';
var
  Reg: TRegistry;
{$ENDIF}
begin
  Result := FALSE; // There is no dark side - the Jedi are victorious!
{$IFNDEF MSWINDOWS}
{$MESSAGE WARN '"DarkModeIsEnabled" will only work on MS Windows targets'}
{$ELSE}
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.KeyExists(TheKey)
    then
      if Reg.OpenKey(TheKey, FALSE)
      then
        try
          if Reg.ValueExists(TheValue)
          then
            Result := Reg.ReadInteger(TheValue) = 0;
        finally
          Reg.CloseKey;
        end;
  finally
    Reg.Free;
  end;
{$ENDIF}
end;

procedure SetSpecificThemeMode(const AsDarkMode: boolean;
  const DarkModeThemeName, LightModeThemeName: string);
var
  ChosenTheme: string;
  link_color: TColor;
begin
  if AsDarkMode
  then
  begin
    ChosenTheme := DarkModeThemeName;
    link_color := $00BBBB00;
  end
  else
  begin
    ChosenTheme := LightModeThemeName;
    link_color := clBlue;
  end;
  TStyleManager.TrySetStyle(ChosenTheme, FALSE);
  Form1.Label4.Font.Color := link_color;
  Form1.Label5.Font.Color := link_color;
end;

procedure SetAppropriateThemeMode(const DarkModeThemeName, LightModeThemeName: string);
begin
  SetSpecificThemeMode(DarkModeIsEnabled, DarkModeThemeName, LightModeThemeName);
end;

procedure SetTheme(c: Integer);
begin
  Form1.Auto1.Checked := FALSE;
  Form1.Dark1.Checked := FALSE;
  Form1.Light1.Checked := FALSE;
  SystemTheme := c;
  case c of
    0:
      begin
        SetSpecificThemeMode(DarkModeIsEnabled, DarkModeThemeName, LightModeThemeName);
        Form1.Auto1.Checked := TRUE;
      end;
    1:
      begin
        SetSpecificThemeMode(TRUE, DarkModeThemeName, LightModeThemeName);
        Form1.Dark1.Checked := TRUE;
      end;
    2:
      begin
        SetSpecificThemeMode(FALSE, DarkModeThemeName, LightModeThemeName);
        Form1.Light1.Checked := TRUE;
      end;
  end;
end;

procedure TForm1.Auto1Click(Sender: TObject);
begin
  SetTheme((Sender as TMenuItem).Tag);
  SaveINI;
end;

procedure SettingsTabsEnabled(b: boolean);
var
  i: Integer;
  Child: TControl;
begin
  with Form1 do
  begin
    if (LocalLabel.Enabled = FALSE) and (not b)
    then
      Exit;
    for i := 0 to TabSheet2.ControlCount - 1 do
    begin
      Child := TabSheet2.Controls[i];
      if ((Child.Name = 'EnableLoopPing') or (Child.Name = 'EnableEchoPing'))
      then
      begin
        if (b)
        then
        begin
          if Child.Tag = 1
          then
            Child.Enabled := TRUE;
        end
        else
        begin
          if Child.Enabled
          then
            Child.Tag := 1
          else
            Child.Tag := 0;
          Child.Enabled := FALSE;
        end;
      end
      else
        Child.Enabled := b;

    end;
    LocalLabel.Enabled := b;
    RemoteLabel.Enabled := b;
    LocalTunnels.Enabled := b;
    RemoteTunnels.Enabled := b;
  end;
end;

procedure TForm1.WMEndSession(var Msg: TWMEndSession);
begin
  if Msg.EndSession = TRUE
  then
  begin
    ExitClick := TRUE;
    Shutdown := TRUE;
    { Terminate plink so it does not become an orphan process after the
      Windows session ends without a normal application close sequence. }
    DoDisconnect;
  end;
  inherited;
end;

function XorCipher(s: string): string;
var
  i: Integer;
  Decoded: string;
begin
  SetLength(Decoded, Length(s));
  for i := 1 to Length(s) do
    Decoded[i] := Chr(ord(s[i]) xor i);
  Result := Decoded;
end;

{ ── Logging ─────────────────────────────────────────────────────────────── }

procedure WriteLogFile(s: string);
var
  Buf: ansistring;
  Written: DWord;
begin
  if LogFilePath = ''
  then
    Exit;
  if LogFileHandle = INVALID_HANDLE_VALUE
  then
  begin
    LogFileHandle := CreateFile(PWideChar(LogFilePath), GENERIC_WRITE, FILE_SHARE_READ,
      nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if LogFileHandle = INVALID_HANDLE_VALUE
    then
      Exit;
    SetFilePointer(LogFileHandle, 0, nil, FILE_END);
  end;
  Buf := ansistring(s + #13#10);
  WriteFile(LogFileHandle, PAnsiChar(Buf)^, Length(Buf), Written, nil);
end;

procedure LogIt(s: string);
var
  LogEntry: string;
begin
  LogEntry := '[' + FormatDateTime('hh:mm:ss mm/dd', Now) + '] ' + s;
  Form1.StatusMemo.Lines.BeginUpdate;
  try
    while Form1.StatusMemo.Lines.Count > BackScrollLines do
      Form1.StatusMemo.Lines.Delete(0); { trim oldest entry, not newest }
    Form1.StatusMemo.Lines.Add(LogEntry);
  finally
    Form1.StatusMemo.Lines.EndUpdate;
  end;
  SendMessage(Form1.StatusMemo.Handle, WM_VSCROLL, SB_BOTTOM, 0);
  if LogFilePath <> ''
  then
    WriteLogFile(LogEntry);
end;

procedure TForm1.WriteStandardIO(s: string);
var
  Buf: ansistring;
  BytesWritten: DWord;
begin
  Buf := ansistring(s + #13#10);
  WriteFile(WritePipe2, PAnsiChar(Buf)^, Length(Buf), BytesWritten, nil);
end;

procedure Error(s: string);
begin
  if Form1.Notifications.Checked
  then
    Exit;
  if Win32MajorVersion > 4
  then
  begin
    Form1.TrayIcon1.BalloonTitle := 'MyEnTunnel - ' + LangStrings[0];
    Form1.TrayIcon1.BalloonHint := s;
    Form1.TrayIcon1.ShowBalloonHint;
  end
  else
    MessageDlg('MyEnTunnel - ' + s, mterror, [mbOK], 0);
end;

procedure PreLog(s: string);
const
  CapturingHostKeyText: boolean = FALSE;
var
  i: Integer;
  UpperLine: string;
begin
  if s = PlinkOutputPrefix
  then
    Exit;

  i := Pos(APPPath, s);
  while i > 0 do
  begin
    Delete(s, i, Length(APPPath));
    i := Pos(APPPath, s);
  end;

  if Form1.ConnectionFilter.Checked
  then
    if ((Pos('Opening forwarded connection to', s) > 0) or
      (Pos('Opening connection to', s) > 0) or (Pos('Forwarded port closed', s) > 0) or
      (Pos('Received remote port', s) > 0) or (Pos('Forwarded port opened successfully',
      s) > 0) or (Pos('Attempting to forward remote port to', s) > 0))
    then
      Exit;

  LogIt(s);
  if ((Pos('refused', s) > 0) and (Pos('Forwarded connection refused', s) = 0))
  then
  begin
    Error(s);
    Form1.Connect.Caption := LangStrings[41];
    Form1.Connect1.Caption := Form1.Connect.Caption;
    Form1.StopPingTimer;
    if PlinkProcessValid
    then
      TerminateProcess(ProcessInfo.hProcess, 255);
    PlinkProcessValid := FALSE;
  end
  else if Pos('Too many authentication failures for remote', s) > 0
  then
    Form1.DoDisconnect
  else if Pos('FATAL ERROR', s) > 0
  then
    Error(s)
  else
  begin
    UpperLine := UpperCase(s);
    if ((Pos('Passphrase for key', s) > 0) or (Pos('PASSWORD:', UpperLine) > 0) or
      ((Pos('PASSWORD FOR ', UpperLine) > 0) and (Pos('@', s) > 0) and (Pos(':', s) > 0)))
    then
    begin
      if Form1.UseKeyfile.Checked
      then
        LogIt(LangStrings[1])
      else
        LogIt(LangStrings[2]);
      AwaitingLoginResponse := TRUE;
      Form1.WriteStandardIO(password);
    end
    else if ((Pos('The server''s host key is not cached in the registry.', s) > 0) or
      (Pos('WARNING - POTENTIAL SECURITY BREACH', s) > 0))
    then
    begin
      CapturingHostKeyText := TRUE;
      StoreKey := s + ' ';
    end
    else if CapturingHostKeyText
    then
    begin
      if ((Pos('Store key in cache?', s) = 0) and (Pos('Update cached key?', s) = 0))
      then
        StoreKey := StoreKey + s + ' '
      else
      begin
        CapturingHostKeyText := FALSE;
        i := Pos(PlinkOutputPrefix, StoreKey);
        while i > 0 do
        begin
          Delete(StoreKey, i, Length(PlinkOutputPrefix));
          i := Pos(PlinkOutputPrefix, StoreKey);
        end;
        i := Pos('Return', StoreKey);
        while i > 0 do
        begin
          Insert('"Cancel"', StoreKey, i);
          Delete(StoreKey, i + 8, 6);
          i := Pos('Return', StoreKey);
        end;
        i := Pos('"y"', StoreKey);
        if i > 0
        then
        begin
          Insert('"Yes"', StoreKey, i);
          Delete(StoreKey, i + 6, 3);
        end;
        i := Pos('"n"', StoreKey);
        if i > 0
        then
        begin
          Insert('"No"', StoreKey, i);
          Delete(StoreKey, i + 6, 3);
        end;
        case MessageDlg(StoreKey, mtCustom, [mbYes, mbNo, mbCancel], 0) of
          mrYes:
            begin
              Form1.WriteStandardIO('Y');
              LogIt(LangStrings[3]);
            end;
          mrNo:
            begin
              Form1.WriteStandardIO('N');
              LogIt(LangStrings[4]);
            end;
          MrCancel:
            begin
              Form1.ConnectClick(nil);
              LogIt(LangStrings[5]);
            end;
        end;
      end;
    end;
  end;
end;

{ ── Password obfuscation ─────────────────────────────────────────────────
  Passwords are stored XOR-obfuscated in the INI file.  This prevents
  casual plaintext exposure but is NOT cryptographically secure. }

function MyDec(s: string; salt: Integer): string;
var
  i, len: Integer;
  Chars, XoredChars: string;
  SeedValue: longword;
begin
  if s = ''
  then
  begin
    Result := #10;
    Exit;
  end;
  if s = #10
  then
  begin
    Result := #10#13#10#13#10#13;
    Exit;
  end;
  len := Length(s) div 3;
  SetLength(Chars, len);
  try
    for i := 0 to len - 1 do
      Chars[i + 1] := Chr(StrToInt(Copy(s, i * 3 + 1, 3)));
    SeedValue := len + salt;
    if SeedValue > 2147483647
    then
      SeedValue := 2147483647;
    RANDSEED := SeedValue;
    SetLength(XoredChars, len);
    for i := 1 to len do
      XoredChars[i] := Chr(ord(Chars[i]) xor (RANDOM(254) + 1));
    XoredChars := XorCipher(XoredChars);
    SetLength(Chars, Length(XoredChars));
    for i := 1 to Length(XoredChars) do
      Chars[i] := XoredChars[Length(XoredChars) - i + 1];
  except
    on E: Exception do
      LogIt('Decryption error: ' + E.Message);
  end;
  Result := Chars;
end;

procedure TrayHint(s: string);
begin
  if Profile <> ''
  then
    s := '(' + Copy(Profile, 1, Length(Profile) - 1) + ') ' + s;
  Form1.TrayIcon1.Hint := s;
  TrayHintString := s;
end;

function IsInt(AString: string; var AInteger: Integer): boolean;
var
  Code: Integer;
begin
  Val(AString, AInteger, Code);
  Result := (Code = 0);
end;

type
  TCaptionHelper = class(TControl);

procedure ChangeLanguage(s, t: WideString);
var
  UIO: TComponent;
begin
  UIO := Form1.FindComponent(s);
  if UIO = nil
  then
    UIO := Form1.PopupMenu1.FindComponent(s);
  if UIO <> nil
  then
    if UIO is TControl
    then
      TCaptionHelper(UIO).Caption := t
    else if UIO is TMenuItem
    then
      TMenuItem(UIO).Caption := t;
end;

procedure DoLanguage(n: string);
var
  LangFile: file of widechar;
  CurrentLine, StringValue, StringKey: WideString;
  Ch: widechar;
  EqualsPos: Integer;
  AtEOF: boolean;
  fn: string;

begin
  fn := n;
  if Pos('.lng', fn) = 0
  then
    fn := fn + '.lng';

  if not FileExists(APPPath + fn)
  then
    Exit;

  assignfile(LangFile, APPPath + fn);
  reset(LangFile);
  try
    LockWindowUpdate(Form1.Handle);
    try
      language := fn;
      AtEOF := FALSE;

      Form1.StatusMemo.Lines.Add('Loading Language:');

      repeat
        CurrentLine := '';
        if not EOF(LangFile)
        then
          read(LangFile, Ch);
        repeat
          read(LangFile, Ch);
          if Ch <> #13
          then
            if Ch <> '|'
            then
              CurrentLine := CurrentLine + Ch
            else
              CurrentLine := CurrentLine + #13#10;
        until (Ch = #13) and (not EOF(LangFile));
        if Copy(CurrentLine, 1, 10) = 'Language: '
        then
        begin
          Form1.StatusMemo.Lines.Add(CurrentLine);
          CurrentLine := Copy(CurrentLine, 11, Length(CurrentLine) - 10);
          Form1.ComboBox1.Items.Add(CurrentLine);
          Form1.ComboBox1.ItemIndex := 0;
        end
        else if Copy(CurrentLine, 1, 8) = 'Author: '
        then
          Form1.StatusMemo.Lines.Add(CurrentLine)
        else if CurrentLine <> 'EOF'
        then
        begin
          EqualsPos := Pos('=', CurrentLine);
          if EqualsPos > 0
          then
          begin
            StringKey := Copy(CurrentLine, 1, EqualsPos - 1);
            Delete(CurrentLine, 1, EqualsPos);
            StringValue := CurrentLine;
            if IsInt(StringKey, EqualsPos)
            then
              LangStrings[EqualsPos] := StringValue
            else
              ChangeLanguage(StringKey, StringValue);
          end;
        end
        else
          AtEOF := TRUE;
      until EOF(LangFile) or AtEOF;
    finally
      LockWindowUpdate(0);
    end;
  finally
    closefile(LangFile);
  end;
  Form1.TabSheet6.Caption := LangStrings[36];
  if Form1.UseKeyfile.Checked
  then
    Form1.PassLabel.Caption := LangStrings[43] + ':'
  else
    Form1.PassLabel.Caption := LangStrings[44] + ':';

  Form1.Label2.Caption := LangStrings[57];
  Form1.Label4.Caption := LangStrings[58] + ' (' + PuTTYLink + ')';
  Form1.Label5.Caption := LangStrings[59] + ' (' + GitHubURL + ')';
end;

{ ── Configuration persistence ───────────────────────────────────────────── }

procedure TForm1.ReadINI;
var
  Salt1: Integer;
  Salt2: Integer;
  EncodedPassword: string;
begin
  AppIni := nil;
  try
    AppIni := TIniFile.Create(APPPath + Profile + 'myentunnel.ini');
    if AppIni = nil
    then
      Exit;
    SystemTheme := AppIni.ReadInteger(Conn, 'ThemeMode', 0);
    SetTheme(SystemTheme);
    SSHServer.Text := AppIni.ReadString(Conn, 'Host', '');
    SSHPort.Text := AppIni.ReadString(Conn, 'Port', '22');
    Username.Text := AppIni.ReadString(Conn, 'Username', '');
    RetryDelay.Text := AppIni.ReadString(Conn, 'RetryDelay', '10');
    ConnectOnStartup.Checked := AppIni.ReadBool(Conn, 'AutoStart', FALSE);
    RetryForever.Checked := AppIni.ReadBool(Conn, 'RetryForever', FALSE);
    ReconnectOnFailure.Checked := AppIni.ReadBool(Conn, 'Reconnect', FALSE);
    ReconnectOnFailureClick(nil);

    BeVerbose.Checked := AppIni.ReadBool(Conn, 'Verbose', FALSE);
    BeVerboseClick(nil);

    UseCompression.Checked := AppIni.ReadBool(Conn, 'Compression', FALSE);
    EnableSocks.Checked := AppIni.ReadBool(Conn, 'UseSOCKS', FALSE);
    EnableSocksClick(nil);

    UseKeyfile.Checked := AppIni.ReadBool(Conn, 'UseKeyfile', FALSE);
    UseKeyfileClick(nil);

    ConnectionFilter.Checked := AppIni.ReadBool(Conn, 'ConnectionFilter', FALSE);

    EnableEchoPing.Checked := AppIni.ReadBool(Conn, 'EnableEchoPing', TRUE);
    EnableLoopPing.Checked := AppIni.ReadBool(Conn, 'EnableLoopPing', TRUE);

    ConfirmClose.Checked := AppIni.ReadBool(Conn, 'ConfirmClose', TRUE);

    UseBlankPhrase := AppIni.ReadBool(Conn, 'UseBlankPhrase', FALSE);

    Notifications.Checked := AppIni.ReadBool(Conn, 'DisableNotifications', FALSE);

    ShowOnDoubleClick := AppIni.ReadBool(Conn, 'ShowOnDoubleClick', TRUE);

    SocksPort.Text := AppIni.ReadString(Conn, 'SOCKSPort', '7070');
    PingPort.Text := AppIni.ReadString(Conn, 'PINGPort', '64000');

    CustomPlinkExe := AppIni.ReadString(Conn, 'Executable', '');
    plinkargs.Text := AppIni.ReadString(Conn, 'ExecArguments', '-N -ssh -2');

    KeyFilePath := AppIni.ReadString(Conn, 'FullPathKeyfile', '');

    LogFilePath := AppIni.ReadString(Conn, 'FullPathLogfile', '');

    Salt1 := AppIni.ReadInteger(Conn, 'PasswordSalt1', 1);
    Salt2 := AppIni.ReadInteger(Conn, 'PasswordSalt2', 1);

    BackScrollLines := AppIni.ReadInteger(Conn, 'BackScrollLines', 200);

    EchoPort := AppIni.ReadString(Conn, 'EchoPort', '7');
    PingTimerInterval := AppIni.ReadInteger(Conn, 'PingInterval', 10000);

    try
      EncodedPassword := AppIni.ReadString(Conn, 'Password', '');
      if EncodedPassword <> ''
      then
        DecPass.Text := MyDec(MyDec(EncodedPassword, Salt2), Salt1);
    except
      on E: Exception do
        LogIt('Error reading password: ' + E.Message);
    end;
  finally
    FreeAndNil(AppIni);
  end;

  SSHServer.Hint := LangStrings[49];
  DecPass.Hint := LangStrings[50];

  RetryDelay.Hint := LangStrings[52];
  UseKeyfile.Hint := LangStrings[53];
  BeVerbose.Hint := LangStrings[54];
  ConnectionFilter.Hint := LangStrings[55];

  try
    LocalTunnels.Lines.LoadFromFile(APPPath + Profile + 'localports.txt');
  except
    on E: Exception do
      LogIt('Error loading local ports: ' + E.Message);
  end;

  try
    RemoteTunnels.Lines.LoadFromFile(APPPath + Profile + 'remoteports.txt');
  except
    on E: Exception do
      LogIt('Error loading remote ports: ' + E.Message);
  end;
end;

procedure TForm1.ReadLang;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(APPPath + 'myentunnel_lng.ini');
  try
    language := Ini.ReadString('Language', 'Language', '');
  finally
    Ini.Free;
  end;
  if language <> ''
  then
    DoLanguage(language);
end;

{ Interruptible sleep honoring Done/Shutdown flags so reconnect delays
  can be cancelled immediately.  Uses GetTickCount64 to avoid the ~49.7-day
  wrap-around that GetTickCount() would produce for long-running sessions. }
procedure MySleep(SleepTime: DWord);
var
  StartValue: UInt64;
begin
  StartValue := GetTickCount64;
  while ((GetTickCount64 - StartValue) <= SleepTime) and (not Done) and (not Shutdown) do
  begin
    Application.ProcessMessages;
    Sleep(100);
  end;
end;

function Enc(s: string; salt: Integer): string;
var
  i, OutPos: Integer;
  Chars, XoredChars: string;
  SeedValue: longword;
begin
  SetLength(Chars, Length(s));
  for i := 1 to Length(s) do
    Chars[i] := s[Length(s) - i + 1];
  Chars := XorCipher(Chars);
  SeedValue := Length(s) + salt;
  if SeedValue > 2147483647
  then
    SeedValue := 2147483647;
  RANDSEED := SeedValue;
  SetLength(XoredChars, Length(Chars));
  for i := 1 to Length(Chars) do
    XoredChars[i] := Chr(ord(Chars[i]) xor (RANDOM(254) + 1));
  SetLength(Chars, Length(XoredChars) * 3);
  OutPos := 0;
  for i := 1 to Length(XoredChars) do
  begin
    OutPos := OutPos + 1;
    Chars[OutPos] := Format('%3.3d', [ord(XoredChars[i])])[1];
    Chars[OutPos + 1] := Format('%3.3d', [ord(XoredChars[i])])[2];
    Chars[OutPos + 2] := Format('%3.3d', [ord(XoredChars[i])])[3];
    inc(OutPos, 2);
  end;
  Result := Chars;
end;

procedure TForm1.SaveLang;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(APPPath + 'myentunnel_lng.ini');
  try
    Ini.WriteString('Language', 'Language', language);
  finally
    Ini.Free;
  end;
end;

procedure TForm1.SaveINI;
var
  Salt1: Integer;
  Salt2: Integer;
begin
  try
    AppIni := TIniFile.Create(APPPath + Profile + 'myentunnel.ini');
  except
    AppIni := nil;
  end;
  if AppIni = nil
  then
    Exit;

  Salt1 := RANDOM(2147482747);

  AppIni.WriteString(Conn, 'Host', SSHServer.Text);
  AppIni.WriteString(Conn, 'Port', SSHPort.Text);
  AppIni.WriteString(Conn, 'Username', Username.Text);
  AppIni.WriteString(Conn, 'SOCKSPort', SocksPort.Text);
  AppIni.WriteString(Conn, 'PINGPort', PingPort.Text);

  AppIni.WriteInteger(Conn, 'PasswordSalt1', Salt1);
  AppIni.WriteString(Conn, 'RetryDelay', RetryDelay.Text);
  AppIni.WriteString(Conn, 'ExecArguments', plinkargs.Text);

  AppIni.WriteBool(Conn, 'AutoStart', ConnectOnStartup.Checked);
  AppIni.WriteBool(Conn, 'Reconnect', ReconnectOnFailure.Checked);
  AppIni.WriteBool(Conn, 'Verbose', BeVerbose.Checked);
  AppIni.WriteBool(Conn, 'RetryForever', RetryForever.Checked);

  AppIni.WriteBool(Conn, 'Compression', UseCompression.Checked);
  AppIni.WriteBool(Conn, 'UseSOCKS', EnableSocks.Checked);
  AppIni.WriteBool(Conn, 'UseKeyfile', UseKeyfile.Checked);
  AppIni.WriteBool(Conn, 'ConnectionFilter', ConnectionFilter.Checked);
  AppIni.WriteBool(Conn, 'DisableNotifications', Notifications.Checked);

  AppIni.WriteBool(Conn, 'EnableEchoPing', EnableEchoPing.Checked);
  AppIni.WriteBool(Conn, 'EnableLoopPing', EnableLoopPing.Checked);
  AppIni.WriteBool(Conn, 'ConfirmClose', ConfirmClose.Checked);

  if DecPass.Text <> ''
  then
    UseBlankPhrase := FALSE;
  AppIni.WriteBool(Conn, 'UseBlankPhrase', UseBlankPhrase);

  Salt2 := RANDOM(2147482747);

  try
    LocalTunnels.Lines.SaveToFile(APPPath + Profile + 'localports.txt');
  except
    on E: Exception do
      LogIt('Error saving local ports: ' + E.Message);
  end;

  AppIni.WriteInteger(Conn, 'ThemeMode', SystemTheme);
  AppIni.WriteInteger(Conn, 'PasswordSalt2', Salt2);
  AppIni.WriteString(Conn, 'Password', Enc(Enc(DecPass.Text, Salt1), Salt2));

  try
    RemoteTunnels.Lines.SaveToFile(APPPath + Profile + 'remoteports.txt');
  except
    on E: Exception do
      LogIt('Error saving remote ports: ' + E.Message);
  end;

  FreeAndNil(AppIni);

end;

procedure TForm1.ProcessStandardIO;
const
  ReadBuffer = 4096;
var
  RawOutput: ansistring;
  OutputText: string;
  Buffer: PAnsiChar;
  BytesRead: DWord;
  CrPos: Integer;
begin
  RawOutput := '';
  Buffer := AllocMem(ReadBuffer + 1);
  try
    repeat
      ReadFile(ReadPipe, Buffer[0], ReadBuffer, BytesRead, nil);
      Buffer[BytesRead] := #0;
      RawOutput := RawOutput + Buffer;
    until (BytesRead < ReadBuffer);
    OutputText := string(RawOutput);
    while TRUE do
    begin
      CrPos := Pos(#13, OutputText);
      if CrPos = 0
      then
        Break;
      PreLog(string(PlinkOutputPrefix + Copy(OutputText, 1, CrPos - 1)));
      Delete(OutputText, 1, CrPos + 1);
    end;
    if OutputText <> ''
    then
      PreLog(string(PlinkOutputPrefix + OutputText));
  finally
    FreeMem(Buffer);
  end;
end;

function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  i: Integer;
  Buffer: array [0 .. 51] of Char;
begin
  for i := 0 to 25 do
    Buffer[i] := Chr(i + ord('A'));
  for i := 0 to 25 do
    Buffer[i + 26] := Chr(i + ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

function DoQuery(pwchar: string; const ACaption, APrompt: string;
  var Value: string): boolean;
var
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
  SMsgDlgOK, SMsgDlgCancel: string;

begin
  SMsgDlgOK := LangStrings[6];
  SMsgDlgCancel := LangStrings[7];
  Result := FALSE;
  Form := TForm.Create(Application);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(190, DialogUnits.X, 4);
      ClientHeight := MulDiv(53, DialogUnits.Y, 8);
      Position := poScreenCenter;
      Prompt := TLabel.Create(Form);
      with Prompt do
      begin
        Parent := Form;
        AutoSize := TRUE;
        Left := MulDiv(13, DialogUnits.X, 4);
        Top := MulDiv(5, DialogUnits.Y, 8);
        Caption := APrompt;
      end;
      Edit := TEdit.Create(Form);
      with Edit do
      begin
        Parent := Form;
        Left := Prompt.Left;
        Top := MulDiv(15, DialogUnits.Y, 8);
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength := 255;
        Text := Value;
        if pwchar <> ''
        then
          PassWordChar := pwchar[1];
        SelectAll;
      end;
      ButtonTop := MulDiv(31, DialogUnits.Y, 8);
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := SMsgDlgOK;
        ModalResult := mrOk;
        Default := TRUE;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
      end;
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := SMsgDlgCancel;
        ModalResult := MrCancel;
        Cancel := TRUE;
        SetBounds(MulDiv(102, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
      end;
      if ShowModal = mrOk
      then
      begin
        Value := Edit.Text;
        Result := TRUE;
      end;
    finally
      Form.Free;
    end;
end;

{ ── SSH process thread ──────────────────────────────────────────────────────
  TPlinkThread launches plink.exe as a child process and runs the full
  connect → monitor → reconnect loop until Done is TRUE.
  The global pipe handles (ReadPipe/WritePipe/ReadPipe2/WritePipe2) are
  shared with the main thread's WriteStandardIO/ProcessStandardIO.
  All VCL access inside Execute must go through Synchronize(). }

procedure TPlinkThread.Execute;
var
  ExitCode: DWord;
  StableAfterLoops, StabilityCounter: Integer;
  BytesWaiting: DWord;
  CommandLine, s, t: string;
  StartInfo: TStartupInfo;
  Security: TSecurityAttributes;

begin
  with Form1 do
  begin

    TThread.Synchronize(Self,
      procedure
      var
        i: Integer;
      begin

        SettingsTabsEnabled(FALSE);
        StatusMemo.Clear;
        password := DecPass.Text;
        TrayIcon1.Icon := Image2.Picture.Icon;

        if DecPass.Text = ''
        then
          if UseKeyfile.Checked
          then
          begin
            if (not UseBlankPhrase)
            then
            begin
              DoQuery('*', 'MyEnTunnel - ' + LangStrings[8],
                LangStrings[9] + Username.Text + '@' + SSHServer.Text, password);
              if password = ''
              then
                if MessageDlg(LangStrings[10], mtconfirmation, [mbYes, mbNo], 0) = mrYes
                then
                  UseBlankPhrase := TRUE
                else
                begin
                  DoDisconnect;
                  Exit;
                end;
            end;
          end
          else
          begin
            DoQuery('*', 'MyEnTunnel - ' + LangStrings[11],
              LangStrings[12] + Username.Text + '@' + SSHServer.Text, password);
            if password = ''
            then
              Exit;
          end;

        SaveINI;
        Done := FALSE;

        s := 'plink.exe';
        if CustomPlinkExe <> ''
        then
        begin
          s := CustomPlinkExe;
          if BeVerbose.Checked
          then
            LogIt(LangStrings[13] + ': ' + CustomPlinkExe);
          CommandLine := s + ' ' + SSHServer.Text;
        end
        else
          CommandLine := APPPath + s + ' ' + SSHServer.Text;

        s := '';
        if plinkargs.Text <> ''
        then
          s := plinkargs.Text;

        CommandLine := CommandLine + ' ' + s + ' -P ' + SSHPort.Text + ' -l "' +
          Username.Text + '" ';

        if UseCompression.Checked
        then
          CommandLine := CommandLine + '-C ';

        if EnableSocks.Checked
        then
          CommandLine := CommandLine + '-D ' + SocksPort.Text + ' ';

        if UseKeyfile.Checked
        then
        begin
          s := APPPath + Profile + 'keyfile.ppk';
          if KeyFilePath <> ''
          then
          begin
            s := KeyFilePath;
            if BeVerbose.Checked
            then
              LogIt(LangStrings[15] + ': ' + KeyFilePath);
          end;
          CommandLine := CommandLine + '-i "' + s + '" ';
        end;

        if LocalTunnels.Lines.Count > 0
        then
          for i := 0 to LocalTunnels.Lines.Count - 1 do
            if ((LocalTunnels.Lines[i] <> '') and (LocalTunnels.Lines[i][1] <> '#'))
            then
              CommandLine := CommandLine + '-L ' + trim(LocalTunnels.Lines[i]) + ' ';

        if EnableEchoPing.Checked
        then
          CommandLine := CommandLine + '-L ' + '127.0.0.1:' + PingPort.Text +
            ':127.0.0.1:' + EchoPort + ' ';

        if EnableLoopPing.Checked
        then
          CommandLine := CommandLine + '-L ' + '127.0.0.1:' + PingPort.Text +
            ':127.0.0.1:' + PingPort.Text + ' ';

        if RemoteTunnels.Lines.Count > 0
        then
          for i := 0 to RemoteTunnels.Lines.Count - 1 do
            if ((RemoteTunnels.Lines[i] <> '') and (RemoteTunnels.Lines[i][1] <> '#'))
            then
              CommandLine := CommandLine + '-R ' + trim(RemoteTunnels.Lines[i]) + ' ';

        if EnableLoopPing.Checked
        then
          CommandLine := CommandLine + '-R ' + '127.0.0.1:' + PingPort.Text +
            ':127.0.0.1:' + IntToStr(StrToInt(PingPort.Text) + 1) + ' ';

        PingTCPPort := StrToInt(PingPort.Text);

        if BeVerbose.Checked
        then
          CommandLine := CommandLine + '-v';

        s := CommandLine;
        while Pos(APPPath, s) > 0 do
          Delete(s, Pos(APPPath, s), Length(APPPath));
        LogIt(LangStrings[16] + ': ' + s);

        if UseBlankPhrase
        then
          LogIt(LangStrings[17]);

        Retries := 0;

      end);

    repeat

      TThread.Synchronize(Self,
        procedure
        begin
          Connect.Caption := LangStrings[18];
          Connect1.Caption := Connect.Caption;
          TrayHint(LangStrings[20] + ' ' + Username.Text + '@' + SSHServer.Text);
        end);

      with Security do
      begin
        nlength := SizeOf(TSecurityAttributes);
        binherithandle := TRUE;
        lpsecuritydescriptor := nil;
      end;

      { Use local handle vars so only successfully-opened handles are closed
        at the end of this iteration, avoiding double-close of stale globals. }
      var
      LReadPipe := INVALID_HANDLE_VALUE;
      var
      LWritePipe := INVALID_HANDLE_VALUE;
      var
      LReadPipe2 := INVALID_HANDLE_VALUE;
      var
      LWritePipe2 := INVALID_HANDLE_VALUE;

      if CreatePipe(LReadPipe2, LWritePipe2, @Security, 0)
      then
      begin
        ReadPipe2 := LReadPipe2;
        WritePipe2 := LWritePipe2;
      end;

      if (LReadPipe2 <> INVALID_HANDLE_VALUE) and CreatePipe(LReadPipe, LWritePipe,
        @Security, 0)
      then
      begin
        ReadPipe := LReadPipe;
        WritePipe := LWritePipe;
      end;

      if LReadPipe <> INVALID_HANDLE_VALUE
      then
      begin

        FillChar(StartInfo, SizeOf(StartInfo), #0);
        StartInfo.cb := SizeOf(StartInfo);

        StartInfo.hStdInput := ReadPipe2;
        StartInfo.hStdOutput := WritePipe;
        StartInfo.hStdError := WritePipe;

        StartInfo.wShowWindow := SW_HIDE;
        StartInfo.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;

        FillChar(ProcessInfo, SizeOf(ProcessInfo), #0);

        StabilityCounter := 0;
        StableAfterLoops := 10;
        LostPings := 0;
        PingSequenceNumber := 0;

        if CreateProcess(nil, PChar(CommandLine), @Security, @Security, TRUE,
          NORMAL_PRIORITY_CLASS, nil, nil, StartInfo, ProcessInfo)
        then
        begin
          PlinkProcessValid := TRUE;

          while WaitForSingleObject(ProcessInfo.hProcess, 250) = WAIT_TIMEOUT do
          begin

            PeekNamedPipe(ReadPipe, nil, 0, nil, @BytesWaiting, nil);

            if BytesWaiting > 0
            then
              TThread.Synchronize(Self,
                procedure
                begin
                  AwaitingLoginResponse := FALSE;
                  ProcessStandardIO;
                end);

            if StabilityCounter < StableAfterLoops
            then
            begin
              inc(StabilityCounter);
              if AwaitingLoginResponse
              then
                StabilityCounter := 0;
              if StabilityCounter >= StableAfterLoops
              then
                TThread.Synchronize(Self,
                  procedure
                  begin
                    TrayHint(LangStrings[21] + ' ' + Username.Text + '@' +
                      SSHServer.Text);
                    TrayIcon1.Icon := Image3.Picture.Icon;
                    LogIt(LangStrings[22]);

                    if EnableLoopPing.Checked
                    then
                    begin
                      if IdTCPServer1.Active
                      then
                        IdTCPServer1.Active := FALSE;
                      IdTCPServer1.Bindings.Items[0].Port := StrToInt(PingPort.Text) + 1;
                      IdTCPServer1.Active := TRUE;
                    end;

                    if (EnableEchoPing.Checked) or (EnableLoopPing.Checked)
                    then
                    begin
                      PingTimerTimer(nil);
                      PingTimer.Enabled := TRUE;
                    end;
                  end);
            end;
          end;

        end
        else
        begin
          TThread.Synchronize(Self,
            procedure
            begin
              Done := TRUE;
              Application.BringToFront;
              PreLog(LangStrings[23]);
            end);
        end;

        if not Done
        then
        begin
          repeat
            PeekNamedPipe(ReadPipe, nil, 0, nil, @BytesWaiting, nil);
            if BytesWaiting > 0
            then
              TThread.Synchronize(Self,
                procedure
                begin
                  ProcessStandardIO;
                end);
          until BytesWaiting = 0;

          TThread.Synchronize(Self,
            procedure
            begin
              LogIt(LangStrings[24]);
            end);

          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

          if ExitCode <> 0
          then
            TThread.Synchronize(Self,
              procedure
              begin
                if ReconnectOnFailure.Checked
                then
                begin
                  if RetryForever.Checked
                  then
                    Retries := 0;

                  if Retries > 5
                  then
                    Done := TRUE;

                  if (Retries <= 5) and (not Done)
                  then
                  begin
                    inc(Retries);
                    TrayIcon1.Icon := Image2.Picture.Icon;

                    t := LangStrings[25] + ' ' + RetryDelay.Text + ' ' + LangStrings[26];
                    if (not Done) and (not RetryForever.Checked)
                    then
                      t := t + ', ' + LangStrings[27] + ': ' + IntToStr(Retries) + ' ' +
                        LangStrings[28] + ' 6';
                    TrayHint(t);
                    LogIt(t);

                    try
                      MySleep(1000 * StrToInt(RetryDelay.Text));
                    except
                    end;
                  end;
                end
                else
                begin
                  Done := TRUE;
                  PreLog(LangStrings[29]);
                end;
              end)
          else
            Done := TRUE;
        end;

        { Only close process handles when the process was actually launched. }
        if PlinkProcessValid or (ProcessInfo.hProcess <> 0)
        then
        begin
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
        end;
        if LWritePipe <> INVALID_HANDLE_VALUE
        then
          CloseHandle(LWritePipe);
        if LReadPipe <> INVALID_HANDLE_VALUE
        then
          CloseHandle(LReadPipe);
        if LWritePipe2 <> INVALID_HANDLE_VALUE
        then
          CloseHandle(LWritePipe2);
        if LReadPipe2 <> INVALID_HANDLE_VALUE
        then
          CloseHandle(LReadPipe2);

      end; { if LReadPipe <> INVALID_HANDLE_VALUE }

      Form1.Caption := FormCaption;

    until Done;

    TThread.Synchronize(Self,
      procedure
      begin
        StopPingTimer;

        SettingsTabsEnabled(TRUE);

        Connect.Caption := LangStrings[32];
        Connect1.Caption := Connect.Caption;
        Form1.Caption := FormCaption;

        TrayIcon1.Icon := Image1.Picture.Icon;
        TrayHint(LangStrings[30]);

        LogIt(LangStrings[31]);
      end);

  end;

end;

procedure TForm1.CancelClick(Sender: TObject);
begin
  Show1.Caption := LangStrings[33];
  Form1.Visible := FALSE;
  ReadINI;
end;

procedure TForm1.HideClick(Sender: TObject);
begin
  Form1.Show1Click(nil);
end;

constructor TMyNotify.Create(const AStr: string);
begin
  FStr := AStr;
  inherited Create(TRUE);
  FreeOnTerminate := TRUE;
  Start;
end;

procedure TMyNotify.Execute;
begin
  { All VCL property writes must occur on the main thread. }
  TThread.Synchronize(Self,
    procedure
    begin
      GotPing := TRUE;
      Form1.TrayIcon1.Icon := Form1.Image3.Picture.Icon;
      Form1.TrayIcon1.Hint := TrayHintString + FStr;
      Form1.Caption := FormCaption + FStr;
    end);
end;

class procedure TMyNotify.UpdateForm(const Str: string);
begin
  Create(Str);
end;

procedure ParsePing(s: string);
var
  SentTickCount, CurrentTickCount: Cardinal;
  Seq: string;
  SepPos: Integer;
begin
  s := trim(s);
  if Copy(s, 1, 4) = 'PING'
  then
  begin
    Delete(s, 1, 4);
    SepPos := Pos('|', s);
    if SepPos = 0
    then
      Exit;
    Seq := Copy(s, 1, SepPos - 1);
    Delete(s, 1, SepPos);
    SentTickCount := StrToIntDef(s, 0);
    if SentTickCount = 0
    then
      Exit;
    CurrentTickCount := GetTickCount;
    LostPings := 0;
    if CurrentTickCount > SentTickCount
    then
      s := IntToStr(CurrentTickCount - SentTickCount)
    else
      s := '?';
    TMyNotify.UpdateForm(' [ping: ' + Seq + ' rtt: ' + s + 'ms]');
  end;
end;

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
var
  s: string;
begin
  s := AContext.Connection.IOHandler.InputBufferAsString();
  if s <> ''
  then
    ParsePing(s);
  AContext.Connection.IOHandler.InputBuffer.Clear;
end;

procedure FormCheck;
begin
  if Form1.Visible
  then
    Form1.Show1.Caption := LangStrings[34]
  else
    Form1.Show1.Caption := LangStrings[33];
end;

procedure TForm1.Show1Click(Sender: TObject);
begin
  Form1.Visible := not Form1.Visible;
  FormCheck;
end;

procedure TForm1.WebClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PWideChar(GitHubURL), '', '', 0);
end;

procedure TForm1.Underline(Sender: TObject);
begin
  with Sender as TLabel do
    Font.Style := Font.Style + [fsunderline];
  if Assigned(Prompt)
  then
    Prompt.Caption := LangStrings[35];
end;

procedure TForm1.About1Click(Sender: TObject);
begin
  Form1.Show;
  PageControl1.ActivePageIndex := 5;
end;

procedure TForm1.SwitchProfile(s: string);
var
  WaitCount: Integer;
begin
  LogIt(LangStrings[37] + ': ' + s);

  if Connect.Caption = LangStrings[18]
  then
    DoDisconnect;

  if s <> 'default'
  then
  begin
    Profile := s;
    Form1.Caption := 'MyEnTunnel - ' + LangStrings[38] + ': ' + Profile;
    Profile := Profile + '-';
  end
  else
  begin
    Profile := '';
    Form1.Caption := 'MyEnTunnel';
  end;

  FormCaption := Form1.Caption;

  LocalTunnels.Lines.Clear;
  RemoteTunnels.Lines.Clear;

  ReadINI;

  LocalLabel.Caption := LangStrings[39] + ': ' + IntToStr(LocalTunnels.Lines.Count);
  RemoteLabel.Caption := LangStrings[40] + ': ' + IntToStr(RemoteTunnels.Lines.Count);

  if SSHServer.Text = ''
  then
  begin
    Form1.Visible := TRUE;
    FormCheck;
    PageControl1.ActivePageIndex := 1;

    if language = ''
    then
    begin
      ComboBox1.SetFocus;
      SendMessage(ComboBox1.Handle, CB_SHOWDROPDOWN, Integer(TRUE), 0);
    end
    else
      SSHServer.SetFocus;
  end
  else if ConnectOnStartup.Checked
  then
  begin
    WaitCount := 0;
    while Assigned(PlinkThread) and (WaitCount < 20) do
    begin
      Sleep(100);
      Application.ProcessMessages;
      inc(WaitCount);
    end;
    DoConnect;
  end;
end;

procedure TForm1.TabSheet3Resize(Sender: TObject);
begin
  Panel2.Width := (TabSheet3.Width - 4) div 2;
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  if ShowOnDoubleClick
  then
    Form1.Visible := not Form1.Visible;
  if Form1.Visible
  then
    Application.BringToFront;
end;

procedure TForm1.PingTimerTimer(Sender: TObject);
begin
  PingTimer.Enabled := FALSE;
  if (not Assigned(PingThread))
  then
  begin
    PingThread := TPingThread.Create(TRUE);
    PingThread.FreeOnTerminate := TRUE;
    PingThread.OnTerminate := PingThreadTerminate;
    PingThread.Interval := PingTimerInterval;
    PingThread.Port := PingTCPPort;
    PingThread.Start;
  end;
end;

procedure TForm1.ProfilePopupHandler(Sender: TObject);
var
  s: string;
begin
  TrayIcon1.Icon := Image1.Picture.Icon;
  UseBlankPhrase := FALSE;
  s := lowercase((Sender as TMenuItem).Caption);
  while Pos('&', s) > 0 do
    Delete(s, Pos('&', s), 1);
  SwitchProfile(s);
end;

function GetLinkerTimestamp: TDateTime;
begin
  Result := PImageNtHeaders(HInstance + Cardinal(PImageDosHeader(HInstance)^._lfanew))
    ^.FileHeader.TimeDateStamp / SecsPerDay + UnixDateDelta;
end;

function ConvertToLocalTime(UTC: TDateTime): TDateTime;
begin
  Result := TTimeZone.Local.ToLocalTime(UTC);
end;

{ ── Form lifecycle ──────────────────────────────────────────────────────── }

procedure TForm1.FormCreate(Sender: TObject);
begin
  try
    FreeLibrary(GetModuleHandle('OleAut32'));
  except
  end;
  Label6.Caption := 'Built on ' + FormatDateTime('dddd, mmmm d, yyyy "at" hh:mm AM/PM',
    ConvertToLocalTime(GetLinkerTimestamp)) + ' with Delphi 12.3 Athens';
  APPPath := ExtractFilePath(Application.ExeName);
  Label7.Caption := APPPath;
  TrayIcon1.Icon := Image1.Picture.Icon;
  TrayIcon1.Visible := TRUE;
  UseBlankPhrase := FALSE;
  Shutdown := FALSE;
  LogFilePath := '';
  Randomize;
{$IFDEF WIN64}
  Label3.Caption := AppVersion + ' (64-bit build)';
{$ELSE}
  Label3.Caption := AppVersion + ' (32-bit build)';
{$ENDIF}
  LangStrings[0] := 'Error';
  LangStrings[1] := 'Sending passphrase';
  LangStrings[2] := 'Sending password';
  LangStrings[3] := 'Yes, store key in registry';
  LangStrings[4] := 'Accept key but do not store key in registry';
  LangStrings[5] := 'User canceled connection';
  LangStrings[6] := 'OK';
  LangStrings[7] := 'Cancel';
  LangStrings[8] := 'Passphrase Needed';
  LangStrings[9] := 'Enter passphrase for ';
  LangStrings[10] := 'Allow Blank Passphrase?';
  LangStrings[11] := 'Password Needed';
  LangStrings[12] := 'Enter password for ';
  LangStrings[13] := 'Using executable';
  { LangStrings[14] reserved (unused) }
  LangStrings[15] := 'Using keyfile';
  LangStrings[16] := 'Launching';
  LangStrings[17] := 'Using blank pass phrase';
  LangStrings[18] := 'Disco&nnect';
  { LangStrings[19] reserved (unused) }
  LangStrings[20] := 'Connecting to';
  LangStrings[21] := 'Connected to';
  LangStrings[22] := 'Connection is stable';
  LangStrings[23] := 'FATAL ERROR: Error launching executable';
  LangStrings[24] := 'Disconnected';
  LangStrings[25] := 'Reconnecting in';
  LangStrings[26] := 'second(s)';
  LangStrings[27] := 'attempt';
  LangStrings[28] := 'of';
  LangStrings[29] := 'FATAL ERROR: SSH connection was terminated unexpectedly';
  LangStrings[30] := 'Disconnected';
  LangStrings[31] := 'Done';
  LangStrings[32] := 'Co&nnect';
  LangStrings[33] := 'Show';
  LangStrings[34] := 'Hide';
  LangStrings[35] := 'Click to visit Authors Website';
  LangStrings[36] := 'About MyEnTunnel';
  LangStrings[37] := 'Switched to profile';
  LangStrings[38] := 'Profile';
  LangStrings[39] := 'Local';
  LangStrings[40] := 'Remote';
  LangStrings[41] := 'Connect';
  LangStrings[42] := 'Manually terminated';
  LangStrings[43] := 'Passphrase';
  LangStrings[44] := 'Password';
  LangStrings[45] := 'Value can not be blank and must be between 1 and ';
  LangStrings[46] := 'Resetting to default of ';
  LangStrings[47] := 'Create Profile';
  LangStrings[48] := 'Name for Profile';
  LangStrings[49] := 'Hostname, IP Address or Saved Putty Session Name';
  LangStrings[50] := 'Max length 100 characters';
  LangStrings[51] :=
    'Slow Poll Rate to once a second (Note: makes application GUI less responsive!)';
  LangStrings[52] := 'In Seconds';
  LangStrings[53] := 'File must be named keyfile.ppk';
  LangStrings[54] := 'Show all plink.exe messages';
  LangStrings[55] := 'Strip Port Connection Messages from Status Window';
  LangStrings[56] := 'Close MyEnTunnel?';

  LangStrings[61] := 'Missed too many pings, restarting';

  Label4.Hint := ClickHere;
  Label5.Hint := ClickHere;
  SpeedButton1.Hint := 'Explore';

  ReadLang;

  Profile := '';
  if paramcount = 1
  then
  begin
    Profile := lowercase(paramstr(1));
    Form1.Caption := 'MyEnTunnel - ' + LangStrings[38] + ': ' + Profile;
    Profile := Profile + '-';
  end;

  FormCaption := Form1.Caption;

  ReadINI;

  licmemo.Lines.LoadFromFile(APPPath + 'license.txt');

  UpdateProfiles;

  if SSHServer.Text = ''
  then
  begin
    Show1Click(nil);
    PageControl1.ActivePageIndex := 1;
    if language = ''
    then
      SendMessage(ComboBox1.Handle, CB_SHOWDROPDOWN, Integer(TRUE), 0)
    else
      SSHServer.SetFocus;
  end;

end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  ProcessExitCode: DWord;

begin
  if not ExitClick
  then
  begin
    Shutdown := FALSE;
    CanClose := FALSE;
    Visible := FALSE;
  end
  else
  begin

    if ConfirmClose.Checked
    then
    begin
      if not Shutdown
      then
        CanClose := MessageDlg(LangStrings[56], mtconfirmation, [mbYes, mbNo], 0) = mrYes
      else
        CanClose := TRUE;
      ExitClick := CanClose;
    end
    else
      CanClose := TRUE;

    Shutdown := CanClose;
    if CanClose
    then
    begin

      StopPingTimer;

      Shutdown := TRUE;
      Done := TRUE;
      if LogFileHandle <> INVALID_HANDLE_VALUE
      then
      begin
        CloseHandle(LogFileHandle);
        LogFileHandle := INVALID_HANDLE_VALUE;
      end;
      if PlinkProcessValid
      then
      begin
        GetExitCodeProcess(ProcessInfo.hProcess, ProcessExitCode);
        if ProcessExitCode = STILL_ACTIVE
        then
          DoDisconnect;
      end;

      if Assigned(PlinkThread)
      then
      begin
        PlinkThread.Terminate;
        { Wait for PlinkThreadTerminate (fires on main thread via OnTerminate)
          to nil PlinkThread.  PlinkThread has FreeOnTerminate=TRUE so WaitFor
          would be unsafe — watch the nil instead.  Cap at 5 seconds. }
        var
        Deadline := GetTickCount64 + 5000;
        while Assigned(PlinkThread) and (GetTickCount64 < Deadline) do
        begin
          Sleep(50);
          Application.ProcessMessages;
        end;
      end;

    end;
  end;
end;

procedure TForm1.EnableEchoPingClick(Sender: TObject);
begin
  EnableLoopPing.Enabled := not EnableEchoPing.Checked;
  if EnableEchoPing.Checked
  then
    EnableLoopPing.Checked := FALSE;
  PingPortLabel.Enabled := EnableEchoPing.Checked OR EnableLoopPing.Checked;
  PingPort.Enabled := PingPortLabel.Enabled;
end;

procedure TForm1.EnableLoopPingClick(Sender: TObject);
begin
  EnableEchoPing.Enabled := not EnableLoopPing.Checked;
  if EnableLoopPing.Checked
  then
    EnableEchoPing.Checked := FALSE;
  PingPortLabel.Enabled := EnableEchoPing.Checked OR EnableLoopPing.Checked;
  PingPort.Enabled := PingPortLabel.Enabled;
end;

procedure TForm1.EnableSocksClick(Sender: TObject);
begin
  SocksPort.Enabled := EnableSocks.Checked;
  PortLabel.Enabled := EnableSocks.Checked;
end;

procedure TForm1.ReconnectOnFailureClick(Sender: TObject);
begin
  RetryForever.Enabled := ReconnectOnFailure.Checked;
end;

procedure TForm1.DoDisconnect;
begin
  StopPingTimer;
  Connect.Caption := LangStrings[41];
  Connect1.Caption := Connect.Caption;
  Retries := 100;
  LogIt(LangStrings[42]);
  Done := TRUE;
  if PlinkProcessValid
  then
    TerminateProcess(ProcessInfo.hProcess, 0);
  PlinkProcessValid := FALSE;
  Form1.Caption := FormCaption;
end;

procedure PopulateLanguageDropdown(fn: string);
var
  LangFile: file of widechar;
  CurrentLine: WideString;
  Ch: widechar;
  AtEOF: boolean;

begin
  assignfile(LangFile, APPPath + fn);
  reset(LangFile);
  try
    AtEOF := FALSE;
    repeat
      CurrentLine := '';
      if not EOF(LangFile)
      then
        read(LangFile, Ch);
      repeat
        read(LangFile, Ch);
        if Ch <> #13
        then
          if Ch <> '|'
          then
            CurrentLine := CurrentLine + Ch
          else
            CurrentLine := CurrentLine + #13#10;
      until (Ch = #13) and (not EOF(LangFile));
      if Copy(CurrentLine, 1, 10) = 'Language: '
      then
      begin
        CurrentLine := Copy(CurrentLine, 11, Length(CurrentLine) - 10);
        Form1.ComboBox1.Items.Add(CurrentLine);
        AtEOF := TRUE;
      end;
    until EOF(LangFile) or AtEOF;
  finally
    closefile(LangFile);
  end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  SavedIndex: Integer;
begin
  if (language <> LanguageFileNames[ComboBox1.ItemIndex])
  then
  begin
    SavedIndex := ComboBox1.ItemIndex;
    DoLanguage(LanguageFileNames[ComboBox1.ItemIndex]);
    ComboBox1.ItemIndex := 0;
    ComboBox1.ItemIndex := SavedIndex;
  end;
  SaveLang;
  if Not Done
  then
    Connect.Caption := LangStrings[18];
end;

procedure TForm1.ComboBox1CloseUp(Sender: TObject);
begin
  if ComboBox1.Text = ''
  then
  begin
    Form1.ComboBox1.Clear;
    Form1.ComboBox1.Items.Add(LanguageSavedText);
    Form1.ComboBox1.ItemIndex := 0;
  end;
end;

procedure TForm1.ComboBox1DropDown(Sender: TObject);
var
  i: Integer;
  searchResult: TSearchRec;
begin
  LanguageSavedText := ComboBox1.Text;
  ComboBox1.Clear;
  FillChar(LanguageFileNames, SizeOf(LanguageFileNames), 0);
  i := 0;
  if FindFirst(APPPath + '*.lng', faAnyFile, searchResult) = 0
  then
  begin
    repeat
      LanguageFileNames[i] := searchResult.Name;
      PopulateLanguageDropdown(searchResult.Name);
      inc(i);
    until ((FindNext(searchResult) <> 0) or (i > 10));
    FindClose(searchResult);
  end;
end;

procedure TForm1.DoConnect;
begin
  if (not Assigned(PlinkThread))
  then
  begin
    PlinkThread := TPlinkThread.Create(TRUE);
    PlinkThread.FreeOnTerminate := TRUE;
    PlinkThread.OnTerminate := PlinkThreadTerminate;
    PlinkThread.Start;
  end;
end;

procedure TForm1.ConnectClick(Sender: TObject);
begin
  if Connect.Caption = LangStrings[18]
  then
    DoDisconnect
  else
    DoConnect;
end;

procedure TForm1.RightClickMouseUp(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Integer);
var
  Pt: TPoint;
begin
  if Button = mbRight
  then
  begin
    UpdateProfiles;
    GetCursorPos(Pt);
    PopupMenu1.Popup(Pt.X, Pt.Y);
  end;
end;

procedure TForm1.SaveHideClick(Sender: TObject);
begin
  SaveINI;
end;

procedure TForm1.UseKeyfileClick(Sender: TObject);
begin
  if UseKeyfile.Checked
  then
    PassLabel.Caption := LangStrings[43] + ':'
  else
    PassLabel.Caption := LangStrings[44] + ':'
end;

procedure TForm1.NumbersOnly(Sender: TObject; var Key: Char);
begin
  if (not CharInSet(Key, ['0' .. '9', #8]))
  then
    Key := #0;
end;

procedure TForm1.BeVerboseClick(Sender: TObject);
begin
  ConnectionFilter.Enabled := BeVerbose.Checked;
end;

procedure TForm1.CheckRange(Sender: TObject);
var
  ParsedValue: Integer;
begin
  ParsedValue := -1;
  try
    ParsedValue := StrToInt((Sender as TEdit).Text);
  except
  end;
  if ((ParsedValue > 0) and (ParsedValue < (Sender as TEdit).Tag))
  then
    Exit;
  MessageDlg(LangStrings[45] + ' ' + IntToStr((Sender as TEdit).Tag) + #13#10 +
    LangStrings[46] + ' ' + DefaultValue, mterror, [mbOK], 0);
  (Sender as TEdit).Text := DefaultValue;
  (Sender as TEdit).SetFocus;
end;

procedure TForm1.SSHPortEnter(Sender: TObject);
begin
  DefaultValue := '22';
end;

procedure TForm1.RetryDelayEnter(Sender: TObject);
begin
  DefaultValue := '10';
end;

procedure TForm1.SocksPortEnter(Sender: TObject);
begin
  DefaultValue := '7070';
end;

procedure TForm1.FormHide(Sender: TObject);
begin
  FormCheck;
end;

procedure TForm1.LocalTunnelsChange(Sender: TObject);
begin
  LocalLabel.Caption := LangStrings[39] + ': ' + IntToStr(LocalTunnels.Lines.Count);
end;

procedure TForm1.RemoteTunnelsChange(Sender: TObject);
begin
  RemoteLabel.Caption := LangStrings[40] + ': ' + IntToStr(RemoteTunnels.Lines.Count);
end;

procedure TForm1.UpdateProfiles;
var
  ExistingItem: TComponent;
  Idx: Integer;
  sr: TSearchRec;
  ProfileName: string;
  ProfileList: TStringList;

begin
  Idx := ProfileSubItemCount;

  while Idx >= 0 do
  begin
    ExistingItem := FindComponent('TI_' + IntToStr(Idx));
    if Assigned(ExistingItem)
    then
      ExistingItem.Free;
    Dec(Idx);
  end;

  ProfileList := TStringList.Create;
  try
    if FindFirst(APPPath + '*.ini', faAnyFile, sr) = 0
    then
      try
        repeat
          if sr.Name <> 'myentunnel_lng.ini'
          then
            ProfileList.Add(lowercase(sr.Name));
        until FindNext(sr) <> 0;
      finally
        FindClose(sr);
      end;

    ProfileList.Sort;

    SetLength(ProfileSubItems, ProfileList.Count);
    for Idx := 0 to ProfileList.Count - 1 do
    begin
      ProfileName := Copy(ProfileList[Idx], 1, Length(ProfileList[Idx]) - 15);
      if ProfileName = ''
      then
        ProfileName := 'default';

      ProfileSubItems[Idx] := TMenuItem.Create(Self);
      ProfileSubItems[Idx].Caption := ProfileName;
      ProfileSubItems[Idx].OnClick := ProfilePopupHandler;
      ProfileSubItems[Idx].Name := 'TI_' + IntToStr(Idx);
      PopupMenu1.Items[2].Add(ProfileSubItems[Idx]);
    end;
  finally
    ProfileList.Free;
  end;
  ProfileSubItemCount := High(ProfileSubItems);
end;

procedure TForm1.PopupMenu1Popup(Sender: TObject);
begin
  UpdateProfiles;
end;

procedure TForm1.NewProfile1Click(Sender: TObject);
var
  s: string;
begin
  DoQuery('', 'MyEnTunnel - ' + LangStrings[47], LangStrings[48], s);
  s := lowercase(s);
  if ((s <> '') and (s <> 'default'))
  then
    SwitchProfile(s);
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  ExitClick := TRUE;
  Close;
  if LogFileHandle <> INVALID_HANDLE_VALUE
  then
  begin
    CloseHandle(LogFileHandle);
    LogFileHandle := INVALID_HANDLE_VALUE;
  end;
end;

{ Handles Windows power-management events: disconnect before sleep,
  reconnect after wake.  Uses legacy APM constants which remain supported
  on all Windows versions for compatibility with older hardware. }
procedure TForm1.WMPowerBroadcast(var Msg: TMessage);
begin
  if (Msg.WPARAM = PBT_APMQUERYSUSPEND) or (Msg.WPARAM = PBT_APMQUERYSTANDBY)
  then
  begin
    // allow standby/hibernation
    LogIt('Entering hibernate/standby');
    DoDisconnect;
    Msg.Result := 0;
  end
  else if (Msg.WPARAM = PBT_APMRESUMECRITICAL) or (Msg.WPARAM = PBT_APMRESUMESUSPEND) or
    (Msg.WPARAM = PBT_APMRESUMESTANDBY)
  then
  begin
    // windows returns from standby or hibernation
    LogIt('Returned from hibernate/standby ');
    if Form1.ConnectOnStartup.Checked
    then
      DoConnect;
  end;
end;

procedure RunDosInMemo(DosApp: string);
const
  READ_BUFFER_SIZE = 2400;
var
  Security: TSecurityAttributes;
  readableEndOfPipe, writeableEndOfPipe: THandle;
  Start: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: PAnsiChar;
  BytesRead: DWord;
  AppRunning: DWord;
  Buf: TStringList;
begin
  Security.nlength := SizeOf(TSecurityAttributes);
  Security.binherithandle := TRUE;
  Security.lpsecuritydescriptor := nil;
  Buf := TStringList.Create;
  try
    if CreatePipe( { var } readableEndOfPipe, { var } writeableEndOfPipe, @Security, 0)
    then
    begin
      Buffer := AllocMem(READ_BUFFER_SIZE + 1);
      FillChar(Start, SizeOf(Start), #0);
      Start.cb := SizeOf(Start);
      Start.dwFlags := Start.dwFlags or STARTF_USESTDHANDLES;
      Start.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
      Start.hStdOutput := writeableEndOfPipe;
      Start.hStdError := writeableEndOfPipe;
      Start.dwFlags := Start.dwFlags + STARTF_USESHOWWINDOW;
      Start.wShowWindow := SW_HIDE;

      ProcessInfo := Default (TProcessInformation);
      UniqueString( { var } DosApp);

      if CreateProcess(nil, PChar(DosApp), nil, nil, TRUE, NORMAL_PRIORITY_CLASS, nil,
        nil, Start,
      { var } ProcessInfo)
      then
      begin
        repeat
          AppRunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
          Application.ProcessMessages;
        until (AppRunning <> WAIT_TIMEOUT);

        repeat
          BytesRead := 0;
          ReadFile(readableEndOfPipe, Buffer[0], READ_BUFFER_SIZE,
          { var } BytesRead, nil);
          Buffer[BytesRead] := #0;
          OemToAnsi(Buffer, Buffer);
          Buf.Add(string(Buffer));
        until (BytesRead < READ_BUFFER_SIZE);

        Form1.Label8.Caption := Buf.Text;

      end
      else
        Form1.Label8.Caption := 'Unknown error or missing plink.exe';

      FreeMem(Buffer);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(readableEndOfPipe);
      CloseHandle(writeableEndOfPipe);

    end;
  finally
    Buf.Free;
  end;
end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePageIndex = 1
  then
    TabSheet2.Repaint
  else if PageControl1.ActivePageIndex = 4
  then
  begin
    try
      readmemo.Lines.LoadFromFile(APPPath + 'readme.txt')
    except
      readmemo.Clear;
      readmemo.Lines.Add('Unable to load readme.txt');
    end;
  end
  else if PageControl1.ActivePageIndex = 5
  then
  begin
    RunDosInMemo(APPPath + 'plink.exe -V');
  end
  else
    readmemo.Clear;
end;

procedure TForm1.PageControl1Resize(Sender: TObject);
begin
  SendMessage(Form1.StatusMemo.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TForm1.Label5MouseEnter(Sender: TObject);
begin
  (Sender as TLabel).Font.Style := (Sender as TLabel).Font.Style + [fsunderline];
end;

procedure TForm1.Label5MouseLeave(Sender: TObject);
begin
  (Sender as TLabel).Font.Style := (Sender as TLabel).Font.Style - [fsunderline];
end;

procedure OpenWebLink(s: string);
begin
  ShellExecute(Application.Handle, 'open', PWideChar(s), '', '', 0);
end;

procedure TForm1.Label4Click(Sender: TObject);
begin
  OpenWebLink(PuTTYLink);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', 'explorer.exe', PWideChar('"' + APPPath + '"'),
    nil, SW_NORMAL);
end;

procedure TForm1.Label5Click(Sender: TObject);
begin
  OpenWebLink(GitHubURL);
end;

{ ── Connection health / ping thread ─────────────────────────────────────────
  TPingThread sends one probe per timer tick via a loopback TCP connection
  through the tunnel.  It signals success through TMyNotify (which uses
  Synchronize to update the tray icon on the main thread).
  PingThreadTerminate counts consecutive missed pings and kills the plink
  process after 3 misses, triggering a reconnect. }

procedure TPingThread.Execute;
var
  Client: TIdTCPClient;
  PollCount, MaxPollCount: Integer;
  PingResponse: string;
  IsLoopPing: boolean;
begin
  IsLoopPing := Form1.EnableLoopPing.Checked;
  try
    Client := TIdTCPClient.Create(nil);
    try
      Client.Host := '127.0.0.1';
      Client.Port := PPort;
      Client.UseNagle := FALSE;
      Client.Connect;
      GotPing := FALSE;
      inc(PingSequenceNumber);
      if PingSequenceNumber > 2147483646
      then
        PingSequenceNumber := 1;
      PingResponse := '';
      PollCount := 0;
      MaxPollCount := (PingTimerInterval - 1) div 10;
      Client.Socket.Writeln('PING' + IntToStr(PingSequenceNumber) + '|' +
        IntToStr(GetTickCount));
      if not IsLoopPing
      then
        while (Client.Connected) and (PollCount < MaxPollCount) and (PingResponse = '')
          and (not Shutdown) do
        begin
          if not Client.IOHandler.InputBufferIsEmpty
          then
            PingResponse := Client.Socket.ReadLn;
          Sleep(50);
          inc(PollCount);
          Client.IOHandler.CheckForDisconnect;
        end
      else
        repeat
          Sleep(50);
          inc(PollCount);
          Client.IOHandler.CheckForDisconnect;
        until (not Client.Connected) or GotPing or (PollCount > MaxPollCount) or Shutdown;
      if (not IsLoopPing) and (PingResponse <> '')
      then
        ParsePing(PingResponse);
      Client.Disconnect;
    finally
      Client.Free;
    end;
  except
    on E: Exception do
    begin
      { LogIt touches VCL — marshal to the main thread. }
      TThread.Synchronize(Self,
        procedure
        begin
          LogIt('Ping thread error: ' + E.Message);
        end);
    end;
  end;
end;

procedure TForm1.PingThreadTerminate(Sender: TObject);
begin
  PingThread := nil;
  if not GotPing
  then
  begin
    inc(LostPings);
    LogIt('Ping timeout.  Counter: ' + IntToStr(LostPings));
    Form1.Caption := FormCaption + ' (lost: ' + IntToStr(LostPings) + ')';
    if LostPings > 2
    then
    begin
      LogIt(LangStrings[61]);
      if PlinkProcessValid
      then
        TerminateProcess(ProcessInfo.hProcess, 255);
      PlinkProcessValid := FALSE;
      Connect.Caption := LangStrings[41];
      Connect1.Caption := Connect.Caption;
    end;
  end
  else
    LostPings := 0;
  PingTimer.Enabled := TRUE;
end;

procedure TForm1.PlinkThreadTerminate(Sender: TObject);
begin
  PlinkThread := nil;
end;

procedure TForm1.StopPingTimer;
begin
  PingTimer.Enabled := FALSE;
  if Assigned(PingThread)
  then
  begin
    PingThread.Terminate;
    { PingThread has FreeOnTerminate=TRUE so WaitFor is unsafe.
      Watch for PingThreadTerminate to nil the pointer instead (2-sec cap). }
    var
    Deadline := GetTickCount64 + 2000;
    while Assigned(PingThread) and (GetTickCount64 < Deadline) do
      Sleep(50);
  end;
  IdTCPServer1.Active := FALSE;
end;

end.
