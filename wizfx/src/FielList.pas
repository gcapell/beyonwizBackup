unit FielList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, VirtualTrees, ExtCtrls, 
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  StdCtrls, Menus, StrUtils, FileCtrl, uStructures;

type
  TfrmFileList = class(TForm)
    FileList: TVirtualStringTree;
    imgFile: TImageList;
    pmFileList: TPopupMenu;
    DownloadTSFile1: TMenuItem;
    DownloadWizFile1: TMenuItem;
    tmLoadList: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FileListGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure FileListGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure FileListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure FileListCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure FileListHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DownloadTSFile1Click(Sender: TObject);
    procedure tmLoadListTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FServerURL: String;
    DescURL: String;
    procedure SetServerURL(const Value: String);
    procedure ProcessFileItem(Sender: TObject);
  protected
    property ServerURL: String read FServerURL write SetServerURL;
  public
    procedure ShowEx(Data: PDeviceInfo);
    procedure LoadFileList;
  end;

var
  frmFileList: TfrmFileList;
  DownLoadPath : String;
  RequestClose, ConfirmClose: Boolean;


implementation

uses Functions, Math, ComObj, DateUtils, Download,
  WizDownloaderMain;

{$R *.dfm}

{ TfrmFileList }

procedure TfrmFileList.LoadFileList;
var
  HTTP : TIdHTTP;
  ext : String;
  i : Integer;
  SL : TStringList;

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
        ProcessFileItem(TObject(Node));
      finally
        SL.Free;
      end;
    end;

begin
  FileList.Clear;
  ext := ExtractFileExt(ServerURL);
  if ext <> '' then
    ServerURL := StringReplace(ServerURL, ext, '.txt', [rfReplaceAll, rfIgnoreCase])
  else
    ServerURL := ServerURL + 'index.txt';

  HTTP := TIdHTTP.Create(Self);
  try
    SL := TStringList.Create;
    try
      SL.Text := HTTP.Get(EncodeURL(ServerURL));
      //dbFileList.EnableOk := False;
      try
        for i := 0 to SL.Count -1 do
        begin
          if RequestClose then
          begin
            ConfirmClose := True;
            Break;
          end;  
          ExtractFileInfo(SL.Strings[i]);
        end;  
      finally
        //dbFileList.EnableOk := True;
      end;
    finally
      SL.Free;
    end;
      
  finally
    HTTP.Free;
  end;
end;

procedure TfrmFileList.SetServerURL(const Value: String);
begin
  FServerURL := Value;
end;

procedure TfrmFileList.ShowEx(Data: PDeviceInfo);
begin
  Caption := Data.Name;
  ServerURL := Data.presentationURL;
  DescURL := Data.DescURL;
  Show;
end;

procedure TfrmFileList.FormShow(Sender: TObject);
begin
  tmLoadList.Enabled := True;
  RequestClose := False;
end;

procedure TfrmFileList.FileListGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TWizFileInfo);
end;



procedure TfrmFileList.FileListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data : PWizFileInfo;
begin
  if Column = 0 then
  begin
    Data  := Sender.GetNodeData(Node);
    ImageIndex := Ord(Data.MediaType);
  end;
end;

procedure TfrmFileList.FileListGetText(Sender: TBaseVirtualTree;
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
    3 : if (Data.FileSize <> 0) then CellText := GetFileSizeStr(Data.FileSize) else CellText :=  '';
  end;
  Screen.Cursor := crDefault;
end;

procedure TfrmFileList.ProcessFileItem(Sender: TObject);
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
  CS.Enter;
  try
    Screen.Cursor := crHourGlass;
  finally
    CS.Leave;
  end;

  Node := PVirtualNode(Sender);
  Data := FileList.GetNodeData(Node);

  HeaderPath := StringReplace(FServerURL, 'index.txt', '', [])
    + StringReplace(ExtractFilePath(StringReplace(Data.FullName, '/', '\', [rfReplaceAll])), '\', '/', [rfReplaceAll]);

  HTTP := TIdHTTP.Create(Self);
  Stream := TMemoryStream.Create;
  try
    CS.Enter;
    try
      Screen.Cursor := crHourGlass;
    finally
      CS.Leave;
    end;

    try
      HTTP.Get(EncodeURL(HeaderPath + 'header.tvwiz'), Stream);
      Data.MediaType := mtVideo;
    except
      try
        HTTP.Get(EncodeURL(HeaderPath + 'header.radwiz'), Stream);
        Data.MediaType := mtAudio;
      except
        Node.States := [vsDisabled];
        Exit;
      end;
    end;

    Stream.Read(WizFileHeader, SizeOf(TWizFileHeader));
    Stream.Seek(1024, soFromBeginning);

    Stream.Read(WizTSPoint, SizeOf(TWizTSPoint));

    Data.FileName := IfThen(Trim(WizTSPoint.evtName) <> '', WizTSPoint.evtName, WizTSPoint.svcName);
    Data.PlayTime := WizTSPoint.last * 10 +  WizTSPoint.sec;
    Data.LastModifiedDate := IncSecond(ModifiedJulianDateToDateTime(WizTSPoint.mjd), WizTSPoint.start);
    Data.FullName := HeaderPath;

    CS.Enter;
    try
      Screen.Cursor := crHourGlass;
    finally
      CS.Leave;
    end;
    Stream.Clear;
    HTTP.Get(EncodeURL(HeaderPath + 'trunc'), Stream);
    Data.FileSize := (Stream.Size div SizeOf(TwizOffsetFileSection)) * 32 * 1024 * 1024;
    FileList.RepaintNode(Node);
  finally
    HTTP.Free;
    Stream.Free;
  end;
  
end;

procedure TfrmFileList.FileListCompareNodes(Sender: TBaseVirtualTree;
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

procedure TfrmFileList.FileListHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (FileList.Header.SortColumn <> Column) then
    FileList.Header.SortColumn := Column
  else if (FileList.Header.SortDirection = sdAscending) then
    FileList.Header.SortDirection := sdDescending
  else
    FileList.Header.SortDirection := sdAscending;

  FileList.SortTree( Column, FileList.Header.SortDirection );
end;

procedure TfrmFileList.DownloadTSFile1Click(Sender: TObject);
var
  frm : TfrmDownload;
  Node : PVirtualNode;
  Data : PWizFileInfo;
begin
  Node := nil;
  frm := TfrmDownload.Create(Self);
  if SelectDir('Select Download Path', DownLoadPath) then
  begin
    FileList.Enabled := False;
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

procedure TfrmFileList.tmLoadListTimer(Sender: TObject);
begin
  tmLoadList.Enabled := False;
  LoadFileList;
  if RequestClose then
  begin
    ConfirmClose := True;
    Close;
  end;
  RequestClose := True;
  ConfirmClose := True;
end;

procedure TfrmFileList.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmFileList.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  idx : Integer;  
begin
  CanClose := False;
  if (not RequestClose) or (not ConfirmClose) then
  begin
    RequestClose := True;
    Exit;
  end;  

  if frmDownloader.SLFileList.Find(DescURL, idx) then
    frmDownloader.SLFileList.Delete(idx);
  CanClose := True;
end;

end.
