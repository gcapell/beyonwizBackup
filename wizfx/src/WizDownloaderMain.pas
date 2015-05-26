{*********************************************************************************}
{                                                                                 }
{ WizFX WizPnP Download Manager                                                   }
{                                                                                 }
{                                                                                 }
{                                                                                 }
{ This program is freeware, thus any adaptation and/or re-distribution is         }
{ allowed. Redeveloped source codes based on this program are at the              }
{ redeveloper's judgment as to whether the source code remains open or not.       }
{                                                                                 }
{ This program is distributed for useful purposes, but it doesn't guarantee       }
{ any implied warranty of suitability of which it may be used for certain         }
{ special purpose or for sale.                                                    }
{ Any illegal act and/or damage to 3rd party through the open source of this      }
{ program is entirely prohibited and Beyonwiz accepts no responsibility for it.   }
{ Any act damaging Beyonwiz through the open source of this program may hold      }
{ you liable for the damage.                                                      }
{                                                                                 }
{                                                                                 }
{ The Soft Gems' Virtual Tree View component package which used in this program   }
{ conforms to MPL1.1 or LGPL.                                                     }
{ http://www.soft-gems.net/index.php?option=com_content&task=view&id=12&Itemid=33 }
{ JVCL component package which used in this program conforms to MPL1.1.           }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                         }
{*********************************************************************************}

unit WizDownloaderMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient, IdAntiFreezeBase,
  IdAntiFreeze, ImgList, VirtualTrees, ExtCtrls, Menus,
  XmlDoc, SyncObjs, IdTCPConnection, IdTCPClient, IdHTTP, ActiveX, XMLIntf,
  Buttons, jpeg, ComCtrls,
  ToolWin, XPMan, JvExControls,
  JvComponent, JvButton, JvTransparentButton, ActnMan, ActnColorMaps,
  uStructures, IniFiles, ShellCtrls;

type
  TfrmDownloader = class(TForm)
    IdUDPClient1: TIdUDPClient;
    ImageList1: TImageList;
    tmSearch: TTimer;
    PopupMenu1: TPopupMenu;
    Open1: TMenuItem;
    ViewInfomation1: TMenuItem;
    IdHTTP1: TIdHTTP;
    pnButtons: TPanel;
    imgToolbar: TImage;
    tbtnRefresh: TJvTransparentButton;
    XPManifest1: TXPManifest;
    imgFile: TImageList;
    pmFileList: TPopupMenu;
    DownloadTSFile1: TMenuItem;
    DownloadWizFile1: TMenuItem;
    tbtnAddDevice: TJvTransparentButton;
    tbtnPreference: TJvTransparentButton;
    tmLoadList: TTimer;
    tbtnChangeTS: TJvTransparentButton;
    tbtnDownload: TJvTransparentButton;
    IdAntiFreeze1: TIdAntiFreeze;
    StatusBar1: TStatusBar;
    pnClient: TPanel;
    pnDown: TPanel;
    Splitter3: TSplitter;
    pnLocalFolder: TPanel;
    pnLocalFolderTitle: TPanel;
    ShellTree: TShellTreeView;
    ShellList: TShellListView;
    Splitter2: TSplitter;
    pnUp: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    DeviceList: TVirtualStringTree;
    FileList: TVirtualStringTree;
    tbtnAbout: TJvTransparentButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tmSearchTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DeviceListGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure DeviceListGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure DeviceListGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure DeviceListChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure btnOpenClick(Sender: TObject);
    procedure FileListCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure FileListGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure FileListGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure FileListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure FileListHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShellListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ShellTreeDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ShellListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure tbtnRefreshClick(Sender: TObject);
    procedure ShellTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DownloadTSFile1Click(Sender: TObject);
    procedure tbtnPreferenceClick(Sender: TObject);
    procedure tmLoadListTimer(Sender: TObject);
    procedure DeviceListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FileListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ShellListChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ShellTreeChange(Sender: TObject; Node: TTreeNode);
    procedure FileListChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnDownloadClick(Sender: TObject);
    procedure tbtnChangeTSClick(Sender: TObject);
    procedure tbtnAddDeviceClick(Sender: TObject);
    procedure FileListPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure DeviceListClick(Sender: TObject);
    procedure FileListClick(Sender: TObject);
    procedure ShellTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure tbtnAboutClick(Sender: TObject);
  private
    FDefaultDownloadType: TDownloadType;
    FDefaultDestPath: String;
    FSaveDestPath: Boolean;
    procedure SetDefaultDownloadType(const Value: TDownloadType);
    procedure SetDefaultDestPath(const Value: String);
    procedure SetSaveDestPath(const Value: Boolean);

  private
    ActivateComponent : TObject;
    procedure LoadFileList;
    procedure ProcessFileItem(Sender: TObject);

    { Private declarations }
  public
    SLFileList : TStringList;
    property DefaultDownloadType : TDownloadType read FDefaultDownloadType write SetDefaultDownloadType;
    property DefaultDestPath: String read FDefaultDestPath write SetDefaultDestPath;
    property SaveDestPath: Boolean read FSaveDestPath write SetSaveDestPath;
    procedure AddDevice(Sender: TObject);
    procedure EditDevice(IP: String; Device: PDeviceInfo);
    procedure DeleteDevice(IP: String);
  end;



var
  frmDownloader: TfrmDownloader;
  bCloseQuery : Boolean;
  ServerURL : String;
  RequestClose, ConfirmClose: Boolean;

implementation

uses StrUtils, FielList, Functions, Download, AddDevice,
  DateUtils, Math, ShlObj, Preference, Favorites, Process, About;


{$R *.dfm}

{ TfrmDownloader }

procedure TfrmDownloader.FormCreate(Sender: TObject);
var
  IniFile : TIniFile;
  l, t, w, h : Integer;
  ws : TWindowState;
begin
  bCloseQuery  := False;
  CS := TCriticalSection.Create;
  SLFileList := TStringList.Create;
  IniFile := TIniFile.Create(ConcatPath(ExtractFilePath(ParamStr(0)),'Pref.ini'));
  try
    DefaultDownloadType := TDownloadType(IniFile.ReadInteger('Preference', 'DefaultDownloadType', Ord(dtTSFile)));
    DefaultDestPath := IniFile.ReadString('Preference', 'DefaultDestPath', '');
    SaveDestPath := IniFile.ReadBool('Preference', 'SaveDestPath', False);

    l := IniFile.ReadInteger('FormState', 'Left', Left);
    t := IniFile.ReadInteger('FormState', 'Top', Top);
    w := IniFile.ReadInteger('FormState', 'Width', Width);
    h := IniFile.ReadInteger('FormState', 'Height', Height);
    ws := TWindowState(Inifile.ReadInteger('FormState', 'WindowState', Ord(wsNormal)));

    if ws = wsMaximized then
      WindowState := ws
    else if ws = wsNormal then
    begin
      frmDownloader.SetBounds(l, t, w, h);
    end;

  finally
    IniFile.Free;
  end;
end;

procedure TfrmDownloader.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  bCloseQuery := True;
  CanClose := True;

  CanClose := False;
  if (not RequestClose) or (not ConfirmClose) then
  begin
    RequestClose := True;
    tmLoadList.Enabled := True;
    Exit;
  end;
  CanClose := True;
end;

procedure TfrmDownloader.tmSearchTimer(Sender: TObject);
var
  MSG : String;
  i : Integer;
  IniFile : TIniFile;
  SLSections : TStringList;

    function ProcessResult(var rtnMessage: String):Boolean;
    var
      iPosStart, iPosEnd : Integer;
      sURL : String;
      URLObject : PURLObject;
    begin
      iPosStart := PosEx('LOCATION:', rtnMessage);
      if iPosStart > 1 then
      begin
        //Memo1.Lines.Add(rtnMessage);
        iPosEnd := PosEx(#13#10, rtnMessage, iPosStart);
        sURL := Copy(rtnMessage, iPosStart + 10, iPosEnd - (iPosStart + 10));
        New(URLObject);
        URLObject.DeviceType := deUPnP;
        URLObject.URL := sURL;
        URLObject.Cnt := 0;
        //TRunThread.Create(AddDevice, TObject(URLObject));
        try
          AddDevice( TObject(URLObject) );
        except

        end;  
      end;
      Result := True;
    end;

var
  URLObject : PURLObject;
  SLTmp : TStringList;
  //Node : PVirtualNode;
begin
  DeviceList.Clear;

  IniFile := TIniFile.Create(ConcatPath(ExtractFilePath(ParamStr(0)), 'Pref.ini'));
  try
    SLSections := TStringList.Create;
    try
      IniFile.ReadSection('Favorites', SLSections);
      for i := 0 to SLSections.Count -1 do
      begin
        New(URLObject);
        URLObject.DeviceType := deHTTP;
        if IniFile.ReadString('Favorites', SLSections.Strings[i], '') = '' then Continue;
        SLTmp := TStringList.Create;
        try
          SLTmp.Text := StringReplace(IniFile.ReadString('Favorites', SLSections.Strings[i], ''), ';', #13, []);
          if SLTmp.Count <> 2 then Continue;
          URLObject.Name := SLTmp.Strings[1];
          URLObject.URL := format('http://%s/%s', [SLTmp.Strings[0], 'tvdevicedesc.xml']);
          URLObject.Cnt := 0;
          try
            AddDevice( TObject(URLObject) );
          except
            //
          end;  
        finally
          SLTmp.Free;
        end;


      end;
    finally
      SLSections.Free;
    end;
    
  finally
    IniFile.Free;
  end;
  
  Screen.Cursor := crHourGlass;
  try
    tmSearch.Enabled := False;
    MSG := 'M-SEARCH * HTTP/1.1' + #13+ #10
         + 'MX: 3' + #13+ #10
         + 'ST: urn:wizpnp-upnp-org:device:pvrtvdevice:1' + #13+ #10
         + 'HOST: 239.255.255.250:1900' + #13+ #10
         + 'MAN: "ssdp:discover"' + #13+ #10 + #13+ #10;

    IdUDPClient1.Send('239.255.255.250', 1900, MSG);
    for i:= 0 to 15 do
    begin
      MSG := '';
      MSG := IdUDPClient1.ReceiveString(100);
      if MSG <> '' then
      begin
        ProcessResult(MSG);

      end;
      if bCloseQuery then break;
    end;
  finally
    Screen.Cursor := crDefault;
    tbtnRefresh.Enabled := True;
  end;
  
  if DeviceList.GetFirst <> nil then
  begin
    DeviceList.Selected[DeviceList.GetFirst] := True;
  end;  
end;

procedure TfrmDownloader.FormShow(Sender: TObject);
begin
  pnDown.Height := (pnClient.Height * 45) div 100;
  tmSearch.Enabled := True;
  RequestClose := True;
  ConfirmClose := True;
  if SaveDestPath and (FDefaultDestPath <> '') and (DirectoryExists(FDefaultDestPath)) then ShellTree.Path := FDefaultDestPath;
  if DefaultDownloadType = dtTSFile then DownloadTSFile1.Default := True else DownloadWizFile1.Default := True;
  //if FDefaultDestPath <> '' then ShellTree.SelectByPath(FDefaultDestPath);
end;

procedure TfrmDownloader.AddDevice(Sender: TObject);
var
  URL : String;
  Node : PVirtualNode;
  Data : PDeviceInfo;
  HTTP : TIdHTTP;
  xmlStr : String;
  tmpURL : String;
  tmpPort : Integer;
  tmpSL : TStringList;
begin
  URL := PURLObject(Sender).URL;
  try
    if  PURLObject(Sender).DeviceType = deUPnP then
    begin
      HTTP := TIdHTTP.Create(Self);
      try
        //Memo1.Lines.Add(URL);
        try
          xmlStr := HTTP.Get(EncodeURL(URL));
        except
          PURLObject(Sender).Cnt := PURLObject(Sender).Cnt + 1;
          if PURLObject(Sender).Cnt > 3 then Exit;
          tmpSL := TStringList.Create;
          try
            tmpURL := StringReplace(PURLObject(Sender).URL, 'http://', '', [rfIgnoreCase]);
            tmpSL.Text := StringReplace(StringReplace(tmpURL, ':', #13, []), '/', #13, []);
            if tmpSL.Count <> 3 then Exit;
            tmpURL := tmpSL.Strings[0];
            tmpPort := StrToIntDef(tmpSL.Strings[1], -1);
            if tmpPort < 0 then Exit;
            tmpPort := tmpPort + 1;
            tmpURL := Format('http://%s:%d/%s', [tmpURL, tmpPort, tmpSL.Strings[2]]);
            PURLObject(Sender).URL := tmpURL;
          finally
            tmpSL.Free;
          end;
          AddDevice(Sender);
          Exit;
        end;
      
        CS.Enter; 
        try
          Node := DeviceList.AddChild(nil);
          DeviceList.MultiLine[Node] := True;
          Data := DeviceList.GetNodeData(Node);
          Data.DescURL :=  PURLObject(Sender).URL;
          try
            if not GetDeviceDescription(Data, PURLObject(Sender)) then
            begin
              DeviceList.DeleteNode(Node);
              Exit;
            end;
          except
            DeviceList.DeleteNode(Node);
            Exit;
          end;
            
          if PURLObject(Sender).DeviceType = deUPnP then Data.ImageIndex := 0 else Data.ImageIndex := 1;
          DeviceList.RepaintNode(Node);
        finally
         CS.Leave;
        end;
      finally
        HTTP.Free;
      end;
    end  
    else
    begin
      CS.Enter;
      try
        Node := DeviceList.AddChild(nil);
        DeviceList.MultiLine[Node] := True;
        Data := DeviceList.GetNodeData(Node);
        Data.Name := PURLObject(Sender).Name;
        Data.DescURL := URL;
        if PURLObject(Sender).DeviceType =deUPnP then Data.ImageIndex := 0 else Data.ImageIndex := 1;
        DeviceList.RepaintNode(Node);
      finally
        CS.Leave;
      end;  
    end;
  finally
    Dispose(PURLObject(Sender));
  end;    
end;

procedure TfrmDownloader.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  Inifile : TIniFile;  
begin
  CS.Free;
  DefaultDestPath := ShellTree.Path; 
  IniFile := TIniFile.Create(ConcatPath(ExtractFilePath(ParamStr(0)),'Pref.ini'));
  try
    if SaveDestPath then
    IniFile.WriteString('Preference', 'DefaultDestPath', DefaultDestPath);

    if WindowState = wsNormal then
    begin
      Inifile.WriteInteger('FormState', 'Left', Left);
      Inifile.WriteInteger('FormState', 'Top', Top);
      Inifile.WriteInteger('FormState', 'Width', Width);
      Inifile.WriteInteger('FormState', 'Height', Height);
    end;
    Inifile.WriteInteger('FormState', 'WindowState', Ord(WindowState));


  finally
    IniFile.Free;
  end;
end;

procedure TfrmDownloader.DeviceListGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PDeviceInfo;  
begin
  if Column = 0 then
  begin
    Data  := Sender.GetNodeData(Node);
    ImageIndex := Data.ImageIndex;
  end;
end;


procedure TfrmDownloader.DeviceListGetNodeDataSize(
  Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TDeviceInfo);
end;

procedure TfrmDownloader.DeviceListGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
var
  Data : PDeviceInfo;
begin
  Data := Sender.GetNodeData(Node);

  case Column of
    0 : CellText := IfThen(Data.Name <> '', Data.Name, 'Unknown')
        + #13 + Copy(Data.DescURL, 0, PosEx('/', Data.DescURL,8));
//        + #13 + IfThen(Data.ImageIndex = 0, 'WizPnP Device', 'HTTP Device');
  end;
end;

procedure TfrmDownloader.DeviceListChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);

var
  Data : PDeviceInfo;
(*
  frm : TfrmFileList;
  idx : Integer;
*)
begin
  Data := DeviceList.GetNodeData(DeviceList.GetNextSelected(nil));
  if Data <> nil then
    if Data.presentationURL = '' then GetDeviceDescription(Data, nil);
  (*
  if SLFileList.Find(Data.DescURL, idx) then
  begin
    frm := TfrmFileList(SLFileList.Objects[idx]);
    frm.BringToFront;
    Exit;
  end;
  frm := TfrmFileList.Create(Self);
  SLFileList.AddObject(Data.DescURL, TObject(frm));
  Screen.Cursor := crHourGlass;
  try
    frm.ShowEx(Data);
  finally
    Screen.Cursor := crDefault;
  end;
  *)
  Repaint;
  RequestClose := False;
  ConfirmClose := False;
  try

    DeviceList.Enabled := False;
    tbtnRefresh.Enabled := False;
    try
      LoadFileList;
    finally
      DeviceList.Enabled := True;
      tbtnRefresh.Enabled := True;
    end;  
  finally
    RequestClose := True;
    ConfirmClose := True;
    Screen.Cursor := crDefault;
  END;    
end;

procedure TfrmDownloader.LoadFileList;
var
  HTTP : TIdHTTP;
  ext : String;
  i : Integer;
  SL : TStringList;
  Data : PDeviceInfo;

    function ExtractFileInfo(Item: String): Boolean;
    var
      SL : TStringList;
      Node : PVirtualNode;
      Data : PWizFileInfo;
    begin
      Result := False;
      SL := TStringList.Create;
      try

        SL.Text := StringReplace(Item, '|', #13, []);

        if SL.Count <> 2 then Exit;
        Node := FileList.AddChild(nil);
        Data := FileList.GetNodeData(Node);
        Data.FileName := SL.Strings[0];
        Data.FullName := SL.Strings[1];

        //TRunThread.Create(ProcessFileItem, TObject(Node));

        Screen.Cursor := crHourGlass;
        try
          CS.Enter;
          try
            ProcessFileItem(TObject(Node));
          finally
            CS.Leave;
          end;
        finally
          Screen.Cursor := crDefault;
        end;
      finally
        SL.Free;
      end;
    end;
begin
  FileList.Clear;
  Data := DeviceList.GetNodeData(DeviceList.GetNextSelected(nil));
  if Data = nil then Exit;

  if Data.presentationURL = '' then
  begin
    Exit;
  end;

  ext := ExtractFileExt(Data.presentationURL);
  if ext <> '' then
    ServerURL := StringReplace(Data.presentationURL, ext, '.txt', [rfReplaceAll, rfIgnoreCase])
  else
    ServerURL := ConcatURL(Data.presentationURL, 'index.txt');

  HTTP := TIdHTTP.Create(Self);
  try
    SL := TStringList.Create;
    try
      Screen.Cursor := crHourGlass;
      try
        try
          SL.Text := HTTP.Get(EncodeURL(ServerURL));
        except
          on E: Exception do
          begin
            Assert(False, format('%s - %s', [E.Message, ServerURL]));
            Application.MessageBox(PChar('Failed to Load File List.'), PChar('Error'), MB_ICONERROR or MB_OK);
            Exit;
          end;  
        end;  
      finally
        Screen.Cursor := crDefault;
      end;

      for i := 0 to SL.Count -1 do
      begin
        if RequestClose then
        begin
          ConfirmClose := True;
          Break;
        end;
        Application.ProcessMessages;
        ExtractFileInfo(SL.Strings[i]);
      end;
    finally
      SL.Free;
    end;
      
  finally
    HTTP.Free;
  end;
end;

procedure TfrmDownloader.ProcessFileItem(Sender: TObject);
var
  Data : PWizFileInfo;
  HTTP : TIdHTTP;
  Stream : TMemoryStream;
  HeaderPath : String;
  WizFileHeader : TWizFileHeader;
  WizTSPoint : TWizTSPoint;
  Node : PVirtualNode;
  //header.tvwiz
begin

  Node := PVirtualNode(Sender);
  if Node = nil then Exit;
  Data := FileList.GetNodeData(Node);
  if Data = nil then Exit;

  HeaderPath := StringReplace(ServerURL, 'index.txt', '', [])
    + StringReplace(ExtractFilePath(StringReplace(Data.FullName, '/', '\', [rfReplaceAll])), '\', '/', [rfReplaceAll]);

  HTTP := TIdHTTP.Create(Self);
  Stream := TMemoryStream.Create;
  try
    try
      HTTP.Get(EncodeURL(HeaderPath + 'header.tvwiz'), Stream);
      Data.MediaType := mtVideo;
    except
      on E: Exception do
      begin
        Assert(False, format('%s - %s', [E.Message, EncodeURL(HeaderPath + 'header.tvwiz')]));

        try
          HTTP.Get(EncodeURL(HeaderPath + 'header.radwiz'), Stream);
          Data.MediaType := mtAudio;
        except
          if Node <> nil then FileList.DeleteNode(Node);
          //Node.States := [vsDisabled];
          Exit;
        end;
      end;
    end;
    Stream.Position := 0;
    Stream.Read(WizFileHeader, SizeOf(TWizFileHeader));
    Stream.Seek(1024, soFromBeginning);

    Stream.Read(WizTSPoint, SizeOf(TWizTSPoint));

    Data.FileName := IfThen(Trim(WizTSPoint.evtName) <> '', WizTSPoint.evtName, WizTSPoint.svcName);
    Data.PlayTime := WizTSPoint.last * 10 +  WizTSPoint.sec;
    Data.FileSize := WizTSPoint.Offset.lastOff - (WizTSPoint.Offset.fileOff[0] - 262144); //262144 = 256 * 1024
    Data.LastModifiedDate := IncSecond(ModifiedJulianDateToDateTime(WizTSPoint.mjd), WizTSPoint.start);
    Data.FullName := HeaderPath;
    Data.IsRec := WizFileHeader.inRec;
    //ShowMessage(IntToStr(WizFileHeader.header) + ':' + IntToStr(WizFileHeader.ver));
    {
    Stream.Clear;
    HTTP.Get(HeaderPath + 'trunc', Stream);
    Data.FileSize := (Stream.Size div SizeOf(TwizOffsetFileSection)) * 32 * 1024 * 1024;
    }
    FileList.RepaintNode(Node);
  finally
    HTTP.Free;
    Stream.Free;
  end;
  
end;



procedure TfrmDownloader.btnOpenClick(Sender: TObject);
var
  Data : PDeviceInfo;
  frm : TfrmFileList;
  idx : Integer;
begin
  Data := DeviceList.GetNodeData(DeviceList.GetNextSelected(nil));

  if SLFileList.Find(Data.DescURL, idx) then
  begin
    frm := TfrmFileList(SLFileList.Objects[idx]);
    frm.BringToFront;
    Exit;
  end;
  frm := TfrmFileList.Create(Self);
  SLFileList.AddObject(Data.DescURL, TObject(frm));
  Screen.Cursor := crHourGlass;
  try
    frm.ShowEx(Data);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmDownloader.FileListCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  Data1, Data2: PWizFileInfo;
begin
  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);
  case Column of
    0 : Result := CompareText(Data1.FileName, Data2.FileName);
    1 : Result := Data1.PlayTime - Data2.PlayTime;
    2 : Result := Ceil((Data1.LastModifiedDate - Data2.LastModifiedDate) * 3600 * 24);
    3 : Result := (Data1.FileSize shr 8) - (Data2.FileSize shr 8);
  end;  
end;

procedure TfrmDownloader.FileListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data : PWizFileInfo;
begin
  if Column = 0 then
  begin
    Data  := Sender.GetNodeData(Node);
    ImageIndex := Ord(Data.MediaType) + IfThen(Data.IsRec, 2, 0);
  end;
end;

procedure TfrmDownloader.FileListGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TWizFileInfo);
end;

procedure TfrmDownloader.FileListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  Data : PWizFileInfo;
begin
  Data := Sender.GetNodeData(Node);
  case Column of
    0 : CellText := Data.FileName;
    1 : if (Data.PlayTime <> 0) then CellText := SecToPlayTimeStr(Data.PlayTime) else CellText := '';
    2 : if (Data.LastModifiedDate <> 0) then CellText := DateTimeToStr(Data.LastModifiedDate) else CellText := '';
    3 : if (Data.FileSize > 0) then CellText := GetFileSizeStr(Data.FileSize) else CellText :=  '0 B';
  end;
  Screen.Cursor := crDefault;
end;

procedure TfrmDownloader.FileListHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (FileList.Header.SortColumn <> Column) then
    FileList.Header.SortColumn := Column
  else if (FileList.Header.SortDirection = VirtualTrees.sdAscending) then
    FileList.Header.SortDirection := VirtualTrees.sdDescending
  else
    FileList.Header.SortDirection := VirtualTrees.sdAscending;

  FileList.SortTree( Column, FileList.Header.SortDirection );
end;

procedure TfrmDownloader.ShellListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  Item: TListItem;
  TreeNode : TShellFolder;
begin
  Accept := False;
  if not tbtnDownload.Enabled then Exit;
  if Source is TVirtualStringTree then
  begin
    if (Source as TVirtualStringTree).Name <> 'FileList' then Exit;
    Item := ShellList.GetItemAt(X, Y);
    if Item = nil then
    begin

      TreeNode := ShellTree.SelectedFolder;
      if TreeNode.PathName = '' then Exit;
      if GetDriveType(PChar(TreeNode.PathName)) = DRIVE_CDROM then Exit;
      Accept := True;
      Exit;
    end;
    TreeNode := ShellList.Folders[Item.Index];
    if TreeNode = nil then Exit;
    if not TreeNode.IsFolder then Exit;
    if AnsiCompareText( ExtractFileExt( TreeNode.PathName ), '.lnk' ) = 0 then Exit;
    if TreeNode.PathName = '' then Exit;
    if GetDriveType(PChar(TreeNode.PathName)) = DRIVE_CDROM then Exit;
    if ((GetFileAttributes(PChar(TreeNode.PathName)) and FILE_ATTRIBUTE_READONLY) = FILE_ATTRIBUTE_READONLY) then
    begin
      if (Pos(GetMyDocumentPath, TreeNode.PathName) = 1) then Accept := True;
      Exit;
    end;
    if (GetFileAttributes(PChar(TreeNode.PathName)) and FILE_ATTRIBUTE_DIRECTORY) <> FILE_ATTRIBUTE_DIRECTORY then Exit;
    Accept := True;
  end;
end;

procedure TfrmDownloader.ShellTreeDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  Node: TTreeNode;
  TreeNode : TShellFolder;
begin
  Accept := False;
  if not tbtnDownload.Enabled then Exit;
  if Source is TVirtualStringTree then
  begin
    if (Source as TVirtualStringTree).Name <> 'FileList' then Exit;
    Node := ShellTree.GetNodeAt(X, Y);
    if Node = nil then Exit;

    TreeNode := TShellFolder(Node.Data);
    if TreeNode = nil then Exit;
    if not TreeNode.IsFolder then Exit;
    if AnsiCompareText( ExtractFileExt( TreeNode.PathName ), '.lnk' ) = 0 then Exit;
    if TreeNode.PathName = '' then Exit;

    //if not (TreeNode.Properties = (TreeNode.Properties * [fpIsLink])) then Exit;
    if GetDriveType(PChar(TreeNode.PathName)) = DRIVE_CDROM then Exit;
    if ((GetFileAttributes(PChar(TreeNode.PathName)) and FILE_ATTRIBUTE_READONLY) = FILE_ATTRIBUTE_READONLY) then
    begin
      if (Pos(GetMyDocumentPath, TreeNode.PathName) = 1) then Accept := True;
      Exit;
    end;
    Accept := True;
  end;
end;

procedure TfrmDownloader.ShellListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  Item: TListItem;
  TreeNode : TShellFolder;
  DestPath : String;

  frm : TfrmDownload;
  VirtualNode : PVirtualNode;
  PWizData : PWizFileInfo;
    
begin
  if Source is TVirtualStringTree then
  begin
    if (Source as TVirtualStringTree).Name <> 'FileList' then Exit;
    Item := ShellList.GetItemAt(X, Y);
    if Item = nil then
    begin
      TreeNode := ShellTree.SelectedFolder;
      DestPath := TreeNode.PathName;
    end
    else
    begin
      TreeNode := ShellList.Folders[Item.Index];
      if TreeNode = nil then Exit;
      if not TreeNode.IsFolder then Exit;
      DestPath := TreeNode.PathName;
    end;

    VirtualNode := nil;
    frm := TfrmDownload.Create(Self);
    frm.DownloadPath := DestPath;
    while true do
    begin
      VirtualNode := FileList.GetNextSelected(VirtualNode);
      if VirtualNode = nil then Break;
      if PWizFileInfo(FileList.GetNodeData(VirtualNode)).IsRec then Continue;
      New(PWizData);
      PWizData.FileName := PWizFileInfo(FileList.GetNodeData(VirtualNode)).FileName;
      PWizData.FullName := PWizFileInfo(FileList.GetNodeData(VirtualNode)).FullName;
      PWizData.PlayTime := PWizFileInfo(FileList.GetNodeData(VirtualNode)).PlayTime;
      PWizData.FileSize := PWizFileInfo(FileList.GetNodeData(VirtualNode)).FileSize;
      PWizData.Locked := PWizFileInfo(FileList.GetNodeData(VirtualNode)).Locked;
      PWizData.MediaType := PWizFileInfo(FileList.GetNodeData(VirtualNode)).MediaType;
      PWizData.LastModifiedDate := PWizFileInfo(FileList.GetNodeData(VirtualNode)).LastModifiedDate;

      frm.DownLoadType := DefaultDownloadType;
      frm.AddFileQue(PWizData);
    end;
    frm.Show;
    if SaveDestPath then DefaultDestPath := DestPath;
  end;

end;

procedure TfrmDownloader.tbtnRefreshClick(Sender: TObject);
begin
  if ActiveControl = FileList then
  begin
    DeviceListChange(DeviceList, nil);
  end
  else if ActiveControl = ShellList then
  begin
    ShellList.Refresh;
  end
  else if ActiveControl = ShellTree then
  begin
    ShellTree.Refresh(ShellTree.Selected);
  end
  else
  begin
    tbtnRefresh.Enabled := False;
    tmSearch.Enabled := True;
  end
  //SendMessage(Self.Handle, WM_KEYDOWN, VK_F5, 0);
  //DeviceList.SetFocus;
end;

procedure TfrmDownloader.SetDefaultDownloadType(
  const Value: TDownloadType);
begin
  FDefaultDownloadType := Value;
end;

procedure TfrmDownloader.ShellTreeDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  Node: TTreeNode;
  TreeNode : TShellFolder;
  DestPath : String;
  
  frm : TfrmDownload;
  VirtualNode : PVirtualNode;
  PWizData : PWizFileInfo;
    
begin
  if Source is TVirtualStringTree then
  begin
    if (Source as TVirtualStringTree).Name <> 'FileList' then Exit;
    Node := ShellTree.GetNodeAt(X, Y);
    if Node = nil then Exit;

    TreeNode := TShellFolder(Node.Data);
    if TreeNode = nil then Exit;

    if TreeNode.PathName = '' then Exit;
    if GetDriveType(PChar(TreeNode.PathName)) = DRIVE_CDROM then Exit;
    //if (TreeNode.Attributes and SFGAO_READONLY) <> 0 then Exit;
    DestPath := TreeNode.PathName;


    VirtualNode := nil;
    frm := TfrmDownload.Create(Self);
    frm.DownloadPath := DestPath;
    while true do
    begin
      VirtualNode := FileList.GetNextSelected(VirtualNode);
      if VirtualNode = nil then Break;
      if PWizFileInfo(FileList.GetNodeData(VirtualNode)).IsRec then Continue;
      New(PWizData);
      PWizData.FileName := PWizFileInfo(FileList.GetNodeData(VirtualNode)).FileName;
      PWizData.FullName := PWizFileInfo(FileList.GetNodeData(VirtualNode)).FullName;
      PWizData.PlayTime := PWizFileInfo(FileList.GetNodeData(VirtualNode)).PlayTime;
      PWizData.FileSize := PWizFileInfo(FileList.GetNodeData(VirtualNode)).FileSize;
      PWizData.Locked := PWizFileInfo(FileList.GetNodeData(VirtualNode)).Locked;
      PWizData.MediaType := PWizFileInfo(FileList.GetNodeData(VirtualNode)).MediaType;
      PWizData.LastModifiedDate := PWizFileInfo(FileList.GetNodeData(VirtualNode)).LastModifiedDate;
      frm.AddFileQue(PWizData);
    end;
    frm.DownLoadType := DefaultDownloadType;
    frm.Show;
    if SaveDestPath then DefaultDestPath := DestPath;
  end;
end;

procedure TfrmDownloader.DownloadTSFile1Click(Sender: TObject);
var
  frm : TfrmDownload;
  Node : PVirtualNode;
  Data : PWizFileInfo;
begin
  Node := nil;
  frm := TfrmDownload.Create(Self);
  if SelectDir('Select Download Path', DownLoadPath) then
  begin
    frm.DownloadPath := DownLoadPath;
    while true do
    begin
      Node := FileList.GetNextSelected(Node);
      if Node = nil then Break;
      New(Data);
      CopyMemory(Data, FileList.GetNodeData(Node), sizeof(TWizFileInfo));
      if TMenuItem(Sender).Tag = 0 then frm.DownLoadType := dtTSFile else frm.DownLoadType := dtWizFile;
      frm.AddFileQue(Data);
    end;
    frm.Show;
  end;  
end;

procedure TfrmDownloader.SetDefaultDestPath(const Value: String);
begin
  FDefaultDestPath := Value;
end;

procedure TfrmDownloader.SetSaveDestPath(const Value: Boolean);
begin
  FSaveDestPath := Value;
end;

procedure TfrmDownloader.tbtnPreferenceClick(Sender: TObject);
var
  IniFile : TIniFile;
begin
  frmPreference.rgDownloadType.ItemIndex := ord(DefaultDownloadType);
  frmPreference.cbLastDownloadpath.Checked := SaveDestPath;

  if frmPreference.ShowModal = mrOk then
  begin
    DefaultDownloadType := TdownloadType(frmPreference.rgDownloadType.ItemIndex);
    SaveDestPath := frmPreference.cbLastDownloadpath.Checked;
    IniFile := TIniFile.Create(ConcatPath(ExtractFilePath(ParamStr(0)),'Pref.ini'));
    if DefaultDownloadType = dtTSFile then DownloadTSFile1.Default := True else DownloadWizFile1.Default := True;
    try
      IniFile.WriteInteger('Preference', 'DefaultDownloadType', Ord(DefaultDownloadType));
      IniFile.WriteBool('Preference', 'SaveDestPath', SaveDestPath);
    finally
      IniFile.Free;
    end;  
  end;
end;

procedure TfrmDownloader.tmLoadListTimer(Sender: TObject);
begin
  tmLoadList.Enabled := False;
  if RequestClose then
  begin
    ConfirmClose := True;
    Close;
  end;
  RequestClose := True;
  ConfirmClose := True;
end;

procedure TfrmDownloader.DeviceListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    if tbtnRefresh.Enabled then tbtnRefreshClick(Self);
    Key := 0;
  end;
end;

procedure TfrmDownloader.FileListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    DeviceListChange(DeviceList, nil);
    Key := 0;
  end;
end;

procedure TfrmDownloader.ShellListChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  i : Integer;  
begin
  tbtnChangeTS.Enabled := False;
  if ShellList.SelectedFolder = nil then
  begin
    if ShellTree.SelectedFolder <> nil then
    begin
      if ShellTree.SelectedFolder.IsFolder then
         if (AnsiCompareText(ExtractFileExt(ShellTree.SelectedFolder.PathName), '.tvwiz') = 0)
           or (AnsiCompareText(ExtractFileExt(ShellTree.SelectedFolder.PathName), '.radwiz') = 0) then
             tbtnChangeTS.Enabled := True;
    end;
  end
  else
  begin

      for i := 0 to ShellList.Items.Count -1 do
      begin
        if ShellList.Items[i].Selected then
        begin
          if ShellList.Folders[i].IsFolder then
             if (AnsiCompareText(ExtractFileExt(ShellList.Folders[i].PathName), '.tvwiz') = 0)
               or (AnsiCompareText(ExtractFileExt(ShellList.Folders[i].PathName), '.radwiz') = 0) then
               begin
                 tbtnChangeTS.Enabled := True;
                 Exit;
               end;  
        end;  
      end;


  end;
end;

procedure TfrmDownloader.ShellTreeChange(Sender: TObject; Node: TTreeNode);
begin
  tbtnChangeTS.Enabled := False;
  if ShellTree.SelectedFolder <> nil then
  begin
    if ShellTree.SelectedFolder.IsFolder then
       if (AnsiCompareText(ExtractFileExt(ShellTree.SelectedFolder.PathName), '.tvwiz') = 0)
         or (AnsiCompareText(ExtractFileExt(ShellTree.SelectedFolder.PathName), '.radwiz') = 0) then
           tbtnChangeTS.Enabled := True;
  end;
end;

procedure TfrmDownloader.FileListChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  VirtualNode : PVirtualNode;  
begin
  tbtnDownload.Enabled := FileList.SelectedCount <> 0;
  DownloadTSFile1.Enabled := tbtnDownload.Enabled;
  DownloadWizFile1.Enabled := tbtnDownload.Enabled;
  VirtualNode := nil;
  while true do
  begin
    VirtualNode := FileList.GetNextSelected(VirtualNode);
    if VirtualNode = nil then Break;
    if not PWizFileInfo(FileList.GetNodeData(VirtualNode)).IsRec then Exit;;
  end;
  tbtnDownload.Enabled := False;
  DownloadTSFile1.Enabled := tbtnDownload.Enabled;
  DownloadWizFile1.Enabled := tbtnDownload.Enabled;  
end;

procedure TfrmDownloader.tbtnDownloadClick(Sender: TObject);
var
  TreeNode : TShellFolder;
  DestPath : String;

  frm : TfrmDownload;
  VirtualNode : PVirtualNode;
  PWizData : PWizFileInfo;

begin
  TreeNode := ShellTree.SelectedFolder;
  DestPath := TreeNode.PathName;

  VirtualNode := nil;
  frm := TfrmDownload.Create(Self);
  frm.DownloadPath := DestPath;
  while true do
  begin
    VirtualNode := FileList.GetNextSelected(VirtualNode);
    if VirtualNode = nil then Break;
    if PWizFileInfo(FileList.GetNodeData(VirtualNode)).IsRec then Continue;
    New(PWizData);
    PWizData.FileName := PWizFileInfo(FileList.GetNodeData(VirtualNode)).FileName;
    PWizData.FullName := PWizFileInfo(FileList.GetNodeData(VirtualNode)).FullName;
    PWizData.PlayTime := PWizFileInfo(FileList.GetNodeData(VirtualNode)).PlayTime;
    PWizData.FileSize := PWizFileInfo(FileList.GetNodeData(VirtualNode)).FileSize;
    PWizData.Locked := PWizFileInfo(FileList.GetNodeData(VirtualNode)).Locked;
    PWizData.MediaType := PWizFileInfo(FileList.GetNodeData(VirtualNode)).MediaType;
    PWizData.LastModifiedDate := PWizFileInfo(FileList.GetNodeData(VirtualNode)).LastModifiedDate;
    frm.AddFileQue(PWizData);
  end;
  frm.DownLoadType := DefaultDownloadType;
  frm.Show;
  if SaveDestPath then DefaultDestPath := DestPath;
end;

procedure TfrmDownloader.tbtnChangeTSClick(Sender: TObject);
var
  Item: TListItem;
  TreeNode : TShellFolder;

  frm : TfrmProcess;
  LocalFileInfo : PLocalFileInfo;
  i : Integer;
begin
    Item := ShellList.Selected;
    if Item = nil then
    begin
      TreeNode := ShellTree.SelectedFolder;
      frm := TfrmProcess.Create(Self);
      New(LocalFileInfo);
      LocalFileInfo.FullName := TreeNode.PathName;
      frm.AddFileQue(LocalFileInfo);
      frm.DownLoadType := dtTSFile;
      frm.Show;
    end
    else
    begin
      frm := TfrmProcess.Create(Self);
      for i := 0 to ShellList.Items.Count -1 do
      begin
        if ShellList.Items[i].Selected then
        begin
          TreeNode := ShellList.Folders[i];
          if not TreeNode.IsFolder then Continue;
          if AnsiCompareText(ExtractFileExt(ShellList.SelectedFolder.PathName), '.tvwiz') <> 0 then Continue;
          New(LocalFileInfo);
          LocalFileInfo.FullName := TreeNode.PathName;
          frm.AddFileQue(LocalFileInfo);
        end;  
      end;
      frm.DownLoadType := dtTSFile;
      frm.Show;
    end;
end;


procedure TfrmDownloader.tbtnAddDeviceClick(Sender: TObject);
begin
  frmFavorites.ShowModal;
end;

procedure TfrmDownloader.EditDevice(IP: String; Device: PDeviceInfo);
var
  Node : PVirtualNode;
  Data : PDeviceInfo;
  IpAddr : String;
  SLTmp: TStringList;

begin
  Node := DeviceList.GetFirst;
  while True do
  begin
    Data := DeviceList.GetNodeData(Node);
    if Data = nil then
    begin
      Node := DeviceList.GetNext(Node);
      Continue;
    end;
    if Data.ImageIndex = Ord(deUPnP) then
    begin
      Node := DeviceList.GetNext(Node);
      Continue;
    end;

    SLTmp := TStringList.Create;
    try
      SLTmp.Text := StringReplace(StringReplace(Data.DescURL, 'http://', '', [rfIgnoreCase]), ':', #13, []);
      IpAddr := SLTmp.Strings[0];

      if IpAddr = IP then
      begin
        Data.Name := Device.Name;
        Data.DescURL := Device.DescURL;
        Data.presentationURL := Device.presentationURL;
        Data.ImageIndex := Device.ImageIndex;
        DeviceList.RepaintNode(Node);
        Break;
      end;
    finally
      SLTmp.Free;
    end;
    Node := DeviceList.GetNext(Node);
    if Node = nil then Break;
  end;

end;

procedure TfrmDownloader.DeleteDevice(IP: String);
var
  Node : PVirtualNode;
  Data : PDeviceInfo;
  IpAddr : String;
  SLTmp: TStringList;

begin
  Node := DeviceList.GetFirst;
  while True do
  begin
    Data := DeviceList.GetNodeData(Node);
    if Data = nil then
    begin
      Node := DeviceList.GetNext(Node);
      Continue;
    end;
    if Data.ImageIndex = Ord(deUPnP) then
    begin
      Node := DeviceList.GetNext(Node);
      Continue;
    end;

    SLTmp := TStringList.Create;
    try
      SLTmp.Text := StringReplace(StringReplace(Data.DescURL, 'http://', '', [rfIgnoreCase]), ':', #13, []);
      IpAddr := SLTmp.Strings[0];

      if IpAddr = IP then
      begin
        DeviceList.DeleteNode(Node);
        Break;
      end;
    finally
      SLTmp.Free;
    end;
    Node := DeviceList.GetNext(Node);
    if Node = nil then Break;
  end;

end;

procedure TfrmDownloader.FileListPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  Data : PWizFileInfo;
begin
  Data := Sender.GetNodeData(Node);                                                                
  if Data.IsRec then TargetCanvas.Font.Color := clGrayText else TargetCanvas.Font.Color := clWindowText;
end;

procedure TfrmDownloader.DeviceListClick(Sender: TObject);
begin
  ActivateComponent := Sender;
end;

procedure TfrmDownloader.FileListClick(Sender: TObject);
begin
  ActivateComponent := Sender;
end;

procedure TfrmDownloader.ShellTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    ShellTree.Refresh(ShellTree.Selected);
    Key := 0;
  end;
end;

procedure TfrmDownloader.FormResize(Sender: TObject);
begin
  tbtnAbout.Left := Width - tbtnAbout.Width - 15;
end;

procedure TfrmDownloader.tbtnAboutClick(Sender: TObject);
begin
  frmAbout.show;
end;

initialization

  //ForceDirectories( ConcatPath(ExtractFilePath(ParamStr(0)), 'Log') );
  //LogFileName := ConcatPath(ExtractFilePath(ParamStr(0)), 'Log\Debug_' + FormatDateTime('yyyymmdd', now) + '.log');
  AssertErrorProc := AssertHack;

end.
