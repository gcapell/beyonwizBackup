unit Functions;

interface

uses DateUtils, Classes, Windows, ShlObj, ActiveX, Forms, uStructures,
  XmlDoc, IdHTTP, XMLIntf, StrUtils, SysUtils;


type
  //---------------------------------------------------------------------------
  { TRunThread }

	TRunThread = class(TThread)
	private
		OnEvent: TNotifyEvent;
		Sender: TObject;
	public
		constructor Create(event: TNotifyEvent; _sender: TObject);
		procedure Execute(); override;
	end;
  //---------------------------------------------------------------------------


{ System }
function GetMyDocumentPath: String;
function GetSpecialPath(nFolder: Integer): String;
function IsNTFS(Path : String) : Boolean;
function IsFAT32(Path : String) : Boolean;

function SecToPlayTimeStr(Sec: Word): String;
function GetFileSizeStr(FileSize: Int64): String;
function ChangeUnsupportedFileName(FileName: String): String;

function SelectDir(const Caption: string; var InitDir: string): boolean;

function ConcatPath(const p1, p2: string): string; overload;
function ConcatPath(const p1, p2, p3: string): string; overload;

function ConcatURL(const p1, p2: string): string;

function GetWizFileSize(Path: String): UInt64;
function CopyToStream(Source, Dest: TStream; Size: UInt64): UInt64;

function ExtractFavoriteInfo(RawInfo: String; var Data: PDeviceInfo): Boolean;

function GetDeviceDescription(var DeviceInfo: PDeviceInfo; URLObject: PURLObject): Boolean;

function EncodeURL(Source: String): String;

function ReadVersionInfo(sProgram: string; Major, Minor,
  Release, Build : pWord) :Boolean; 

procedure WriteLog(MSG: String);
procedure AssertHack(const Message, Filename: string; LineNumber: Integer; ErrorAddr: Pointer);



var
  LogFileName: TFileName;
  
implementation


{ TRunThread }

constructor TRunThread.Create(event: TNotifyEvent; _sender: TObject);
begin
  inherited Create(false);
	FreeOnTerminate := true;
  OnEvent := event;
  Sender := _sender;
end;

procedure TRunThread.Execute;
begin
	OnEvent(Sender);
end;

function GetMyDocumentPath: String;
begin
  Result := GetSpecialPath(CSIDL_PERSONAL);
end;

function GetSpecialPath(nFolder: Integer): String;
var
  pidl: PItemIDList;
  hRes: HRESULT;
  Success: bool;
  RealPath: Array[0..MAX_PATH] of Char;
begin
  hRes:=SHGetSpecialFolderLocation(Application.Handle, nFolder, pidl);

  if hRes = NO_ERROR then
  begin
    Success := SHGetPathFromIDList( pidl, RealPath );
    if Success then
    begin
      Result := String( RealPath );
    end;
  end;
end;

function IsNTFS(Path : String) : Boolean;
var
  FName : Array[0..255] of Char;
  ComponentLength,
  SystemFlag : Cardinal;
begin
   GetVolumeInformation(PChar(Path),nil,0,nil,ComponentLength,SystemFlag,FName,SizeOf(FName));
   if FName ='NTFS' then
     Result := True
     else Result := False;
end;

function IsFAT32(Path : String) : Boolean;
var
  FName : Array[0..255] of Char;
  ComponentLength,
  SystemFlag : Cardinal;
begin
   GetVolumeInformation(PChar(Path),nil,0,nil,ComponentLength,SystemFlag,FName,SizeOf(FName));
   if FName ='FAT32' then
     Result := True
     else Result := False;
end;


function SecToPlayTimeStr(Sec: Word): String;
var
  mm, ss : Word;
begin
  mm := Sec div 60;
  ss := Sec mod 60;
  if mm > 0 then
    Result := Format('%s min %s sec', [FormatFloat('00', mm), FormatFloat('00',ss)])
  else
    Result := Format('%s sec', [FormatFloat('00',ss)]);
end;

function GetFileSizeStr(FileSize: Int64): String;
begin
  case (FileSize div 1024) of
    0 :
        Result := IntToStr(FileSize) + ' B';
    1 .. 1023 :
        Result := FormatFloat('#,###.00',Round((FileSize / 1024) * 100)/100) + ' KB';
    1024 .. 1048576 -1 :
        Result := FormatFloat('#,###.00',Round((FileSize / (1024 * 1024)) * 100)/100) + ' MB';
    else
        Result := FormatFloat('#,###.00',Round((FileSize / (1024 * 1024 * 1024)) * 100)/100) + ' GB';
  end;

end;

function ChangeUnsupportedFileName(FileName: String): String;

    function ExchangeChar(MSG: String; Before, After: Char): String;
    begin
      Result := StringReplace(MSG, Before, After, [rfReplaceAll]);
    end;

begin
  Result := ExchangeChar(FileName, '\', '_');
  Result := ExchangeChar(Result, '/', '_');
  Result := ExchangeChar(Result, ':', '_');
  Result := ExchangeChar(Result, '*', '_');
  Result := ExchangeChar(Result, '?', '_');
  Result := ExchangeChar(Result, '"', '_');
  Result := ExchangeChar(Result, '<', '_');
  Result := ExchangeChar(Result, '>', '_');
  Result := ExchangeChar(Result, '|', '_');
end;

function BrowseCallbackProc(hwnd: HWND; uMsg: UINT; lParam, lpData: LPARAM):
  Integer; stdcall;
var
  Path: array[0..MAX_PATH] of Char;
begin
  case uMsg of
    BFFM_INITIALIZED:
      begin
        SendMessage(hwnd, BFFM_SETSELECTION, 1, lpData);
        SendMessage(hwnd, BFFM_SETSTATUSTEXT, 0, lpData);
      end;
    BFFM_SELCHANGED:
      begin
        if SHGetPathFromIDList(Pointer(lParam), Path) then
          SendMessage(hwnd, BFFM_SETSTATUSTEXT, 0, Integer(@Path));
      end;
  end;
  Result := 0;
end;

function SelectDir(const Caption: string; var InitDir: string): boolean;
var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
begin
  Result := False;
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then
  begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    try
      with BrowseInfo do
      begin
        hwndOwner := Application.Handle;
        pidlRoot := nil;
        pszDisplayName := Buffer;
        lpszTitle := PChar(Caption);
        ulFlags := BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT;
        lParam := Integer(PChar(InitDir));
        lpfn := @BrowseCallbackProc;
      end;
      WindowList := DisableTaskWindows(0);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        EnableTaskWindows(WindowList);
      end;

      if ItemIDList <> nil then
      begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        InitDir := Buffer;
        Result := True;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;

function ConcatPath(const p1, p2: string): string; overload;
begin
  if p1 = '' then
    Result := p2
  else
    if p1[length(p1)] = '\' then
      Result := p1 + p2
    else
      Result := p1 + '\' + p2;
end;

function ConcatPath(const p1, p2, p3: string): string; overload;
begin
  Result := ConcatPath(ConcatPath(p1, p2), p3);
end;


function ConcatURL(const p1, p2: string): string;
begin
  if p1 = '' then
    Result := p2
  else
    if p1[length(p1)] = '/' then
      Result := p1 + p2
    else
      Result := p1 + '/' + p2;
end;

function GetWizFileSize(Path: String): UInt64;
var
  FileStream : TFileStream;
  WizTSPoint : TWizTSPoint;
begin
  Result := 0;
  if FileExists(ConcatPath(Path, 'header.tvwiz')) then
    FileStream := TFileStream.Create(ConcatPath(Path, 'header.tvwiz'), fmOpenRead)
  else if FileExists(ConcatPath(Path, 'header.radwiz')) then
    FileStream := TFileStream.Create(ConcatPath(Path, 'header.radwiz'), fmOpenRead)
  else
    Exit;
      
  try
    FileStream.Seek(1024, soFromBeginning);
    FileStream.Read(WizTSPoint, SizeOf(TWizTSPoint));
    Result := WizTSPoint.Offset.lastOff - (WizTSPoint.Offset.fileOff[0] - 262144); //262144 = 256 * 1024
  finally
    FileStream.Free;
  end;
end;


function CopyToStream(Source, Dest: TStream; Size: UInt64): UInt64;
var
  BufSize: Integer;
  Buffer: PChar;
begin
  BufSize := Size;

  if Source.Size - Source.Position < BufSize then BufSize := Source.Size - Source.Position;

  GetMem(Buffer, BufSize);
  try
    try
      Source.ReadBuffer(Buffer^, BufSize);
      Dest.WriteBuffer(Buffer^, BufSize);
    except
      on E: Exception do
        Assert(False, Format('%s', [E.Message])); 
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
  Result := BufSize;
end;


function ExtractFavoriteInfo(RawInfo: String; var Data: PDeviceInfo): Boolean;
var
  SL : TStringList;
begin
  SL := TStringList.Create;
  try
    Result := False;
    SL.Text := StringReplace(RawInfo, ';' , #13, []);
    if SL.Count = 1 then
      Data.Name := 'Unknown'
    else if SL.Count = 2 then
    begin
      Data.Name := SL.Strings[1];
    end
    else
      Exit;
    SL.Text := StringReplace(SL.Strings[0], ':', #13, []);
    if SL.Count <> 2 then Exit;
    Data.DescURL := format('http://%s:%d/%s', [SL.Strings[0], StrToIntDef(SL.Strings[1], 0), 'tvdevicedesc.xml']);
    Data.ImageIndex := Ord(deHTTP);
    Result := True;
  finally
    SL.Free;
  end;
end;


function GetDeviceDescription(var DeviceInfo: PDeviceInfo; URLObject: PURLObject): Boolean;
var
  xmlDoc : TXMLDocument;
  Http: TIdHTTP;
  URL, xmlStr, tmpURL : String;
  i, iPos : Integer;
  tmpSL : TStringList;
  tmpPort : Integer;
  xmlNode : IXMLNode;
begin
  Result := False;
  URL := DeviceInfo.DescURL;

  if URL = '' then Exit;
  HTTP := TIdHTTP.Create(nil);
  try
    for i := 0 to 2 do
    begin
      try
        xmlStr := HTTP.Get(EncodeURL(URL));
        Break;
      except
        on E: Exception do
        begin
          Assert(False, Format('%s - %s', [E.Message, EncodeURL(URL)]));
          tmpSL := TStringList.Create;
          try
            tmpURL := StringReplace(URL, 'http://', '', [rfIgnoreCase]);
            tmpSL.Text := StringReplace(StringReplace(tmpURL, ':', #13, []), '/', #13, []);
            if tmpSL.Count <> 3 then Exit;
            tmpURL := tmpSL.Strings[0];
            tmpPort := StrToIntDef(tmpSL.Strings[1], -1);
            if tmpPort < 0 then Exit;
            tmpPort := tmpPort + 1;
            tmpURL := Format('http://%s:%d/%s', [tmpURL, tmpPort, tmpSL.Strings[2]]);
            URL := tmpURL;
          finally
            tmpSL.Free;
          end;
        end;

      end;
    end;

    xmlDoc := TXMLDocument.Create(Application);
    try
      CoInitialize(nil);
      xmlDoc.Active := True;
      xmlDoc.XML.Text := HTTP.Get(EncodeURL(URL));
      xmlDoc.Active := True;
      xmlNode := xmlDoc.Node.ChildNodes.Nodes['root'].ChildNodes.Nodes['device'];


      if (Pos('http://', URL) > 0) then
        iPos := PosEx('/', URL, 8)
      else
        iPos := PosEx('/', URL);
      DeviceInfo.presentationURL := Copy(URL, 1, iPos - 1) + xmlNode.ChildNodes.Nodes['presentationURL'].NodeValue;

      if URLObject = nil then Exit;
      if URLObject.DeviceType = deUPnP then
      begin
        DeviceInfo.Name := xmlNode.ChildNodes.Nodes['friendlyName'].NodeValue;
        DeviceInfo.DescURL := URL;
      end;

    finally
      xmlDoc.Free;
    end;
  finally
    HTTP.Free;
  end;
  Result := True;
end;

function EncodeURL(Source: String): String;
const
  UnsafeChars = ['*', '#', '%', '<', '>', '+', ' '];  {do not localize}
var
  i: Integer;
begin
  Result := '';    {Do not Localize}
  for i := 1 to Length(Source) do begin
    if (Source[i] in UnsafeChars) or (Source[i] >= #$80) or (Source[i] < #32) then begin
      Result := Result + '%' + IntToHex(Ord(Source[i]), 2);  {do not localize}
    end else begin
      Result := Result + Source[i];
    end;
  end;
end;

procedure WriteLog(MSG: String);
var
  F : TextFile;
begin
  if Trim(LogFileName) = '' then Exit;
  if not DirectoryExists(ExtractFileDir(LogFileName)) then
    ForceDirectories(ExtractFileDir(LogFileName));

  AssignFile(F, LogFileName);
  if not FileExists(LogFileName) then Rewrite(F);
  Append(F);
  Writeln(F,  format('[%s] %s', [TimeToStr(Now), MSG]));
  CloseFile(F);
end;

function ReadVersionInfo(sProgram: string; Major, Minor,
  Release, Build : pWord) :Boolean;
var
  Info: PVSFixedFileInfo;
  InfoSize: Cardinal;
  nHwnd: DWORD;
  BufferSize: DWORD;
  Buffer: Pointer;
begin
  BufferSize := GetFileVersionInfoSize(pchar(sProgram),nHWnd);
  Result := True;
  if BufferSize <> 0 then
  begin
    GetMem( Buffer, BufferSize);
    try
      if GetFileVersionInfo(PChar(sProgram),nHWnd,BufferSize,Buffer) then
      begin
        if VerQueryValue(Buffer, '', Pointer(Info), InfoSize) then
        begin
          if Assigned(Major) then
            Major^ := HiWord(Info^.dwFileVersionMS);

          if Assigned(Minor) then
            Minor^ := LoWord(Info^.dwFileVersionMS);

          if Assigned(Release) then
            Release^ := HiWord(Info^.dwFileVersionLS);

          if Assigned(Build) then
            Build^ := LoWord(Info^.dwFileVersionLS);

        end else
        begin
          Result := False;
        end;
      end else
      begin
        Result := False;
      end;
    finally
      FreeMem(Buffer, BufferSize);
    end;
  end else 
  begin
    Result := False; 
  end;
end;


procedure AssertHack(const Message, Filename: string; LineNumber: Integer; ErrorAddr: Pointer);
begin
  //WriteLog(Format('%s (%s, line %d)', [Message, ExtractFileName(Filename), LineNumber]));
end;

end.
