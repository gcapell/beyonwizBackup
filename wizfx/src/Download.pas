unit Download;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls,
  ImgList, uStructures, IdBaseComponent, IdAntiFreezeBase, IdAntiFreeze,
  ExtCtrls, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, SyncObjs,
  Buttons, StrUtils, IdException;

type
  TfrmDownload = class(TForm)
    pbTotal: TProgressBar;
    pbFile: TProgressBar;
    lbTotal: TLabel;
    lbFileName: TLabel;
    IdAntiFreeze1: TIdAntiFreeze;
    HTTP: TIdHTTP;
    tmClose: TTimer;
    btnClose: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure tmCloseTimer(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure HTTPWork(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
  private
    FDownLoadType: TDownloadType;
    FDownloadPath: String;
    FCurrentFileSize: UInt64;
    FTotalFileSize: UInt64;
    FProgressTotalFileSize: UInt64;
    FProgressCurrentFileSize: UInt64;
    FCurrentStream: TStream;
    procedure SetDownLoadType(const Value: TDownloadType);
    procedure SetDownloadPath(const Value: String);
    function ProcessDownloadFile(Data: PWizFileInfo): Boolean;
    procedure RemoveTrashFile(Data: PWizFileInfo);
    procedure SetCurrentFileSize(const Value: UInt64);
    procedure SetTotalFileSize(const Value: UInt64);
    procedure ProcessFileList(Sender: TObject);
    procedure SetProgressTotalFileSize(const Value: UInt64);
    procedure SetProgressCurrentFileSize(const Value: UInt64);
    procedure SetCurrentStream(const Value: TStream);
  public
    property DownLoadType: TDownloadType read FDownLoadType write SetDownLoadType;
    property DownloadPath: String read FDownloadPath write SetDownloadPath;
    function AddFileQue(Data: PWizFileInfo):Boolean;
    property TotalFileSize: UInt64 read FTotalFileSize write SetTotalFileSize;
    property ProgressTotalFileSize: UInt64 read FProgressTotalFileSize write SetProgressTotalFileSize;
    property CurrentFileSize: UInt64 read FCurrentFileSize write SetCurrentFileSize;
    property ProgressCurrentFileSize: UInt64 read FProgressCurrentFileSize write SetProgressCurrentFileSize;
    property CurrentStream: TStream read FCurrentStream write SetCurrentStream;
  protected
    FileList : TStringList;
    dnCS : TCriticalSection;
    bCompletedJob : Boolean;
    bRequestCancel : Boolean;
    DefaultBlockSize : UInt64;
    SplitSize : UInt64;
    PartialFileSize: UInt64;
  end;

var
  frmDownload: TfrmDownload;



implementation

uses Functions, FielList, WizDownloaderMain, WarningFileSize, Math;



{$R *.dfm}

procedure TfrmDownload.FormCreate(Sender: TObject);
begin
  FileList := TStringList.Create;
  dnCS := TCriticalSection.Create;
  FTotalFileSize := 0;
  FProgressTotalFileSize := 0;  
end;

procedure TfrmDownload.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
//  dnCS.Free;
//  FileList.Free;
  if (Owner as TForm).Name = 'frmFileList' then
    TfrmFileList(Owner).FileList.Enabled := True;

  if frmDownloader.SaveDestPath then frmDownloader.DefaultDestPath := DownloadPath;
  FreeAndNil(Self);
end;

function TfrmDownload.AddFileQue(Data: PWizFileInfo): Boolean;
begin
  TotalFileSize := TotalFileSize + Data.FileSize;
  FileList.AddObject(Data.FileName, TObject(Data));
  Result := True;
end;

procedure TfrmDownload.SetDownLoadType(const Value: TDownloadType);
begin
  FDownLoadType := Value;
end;

procedure TfrmDownload.SetDownloadPath(const Value: String);
begin
  FDownloadPath := Value;
end;

procedure TfrmDownload.ProcessFileList(Sender: TObject);
var
  i : Integer;
  Data: PWizFileInfo;
begin
  try
    for i := 0 to FileList.Count -1 do
    begin
      Data := PWizFileInfo(FileList.Objects[i]);

      if (DownLoadType = dtSplitTS) or (DownLoadType = dtTSFile) then
      begin
        if (IsNTFS(Copy(DownloadPath,1,3))) then
          DownLoadType := dtTSFile
        else
        begin
          DownLoadType := dtTSFile;
          if Data.FileSize > MAX_UINT32_SIZE then DownLoadType := dtSplitTS;

          if (Data.FileSize > MAX_INT32_SIZE) and (Data.FileSize < MAX_UINT32_SIZE)
              and frmWarningFileSize.rb2GB.Checked then
            DownLoadType := dtSplitTS;
        end;
      end;

      if not ProcessDownloadFile(Data) then
      begin
        RemoveTrashFile(Data);
      end;
    end;
  finally
    bRequestCancel := True;
    bCompletedJob := True;
  end;  
end;




function TfrmDownload.ProcessDownloadFile(Data: PWizFileInfo): Boolean;
var
  i : Integer;
  TmpPath : String;
  Stream : TMemoryStream;
  SaveFile, FStream : TFileStream;
  WizTrunc: TwizOffsetFileSection;
  Ext : String;
  //PrevFileNum : Integer;
  //PrevFileSize : UInt64;

  
    function DownloadFile(Url, DestPath, FileName: String):Boolean;
    var
      tmlFileStream : TFileStream;
    begin
      Result := False;
      if bRequestCancel then Exit;
      CS.Enter;
      try
        Caption := 'Downloading...';
      finally
        CS.Leave;
      end; 

      if not FileExists(ConcatPath(DestPath, FileName)) then
        tmlFileStream := TFileStream.Create(ConcatPath(DestPath, FileName), fmCreate)
      else
      begin
        tmlFileStream := TFileStream.Create(ConcatPath(DestPath, FileName), fmOpenReadWrite);
        tmlFileStream.Size := 0;
      end;
      try
        CurrentStream := tmlFileStream;
        try
          HTTP.Get(EncodeURL(ConcatURL(Url, FileName)), tmlFileStream);
        except
          on E: Exception do
          begin
            Assert(False, format('(%s Error No.: %d)DownloadFile %s - %s', [E.ClassName, E.HelpContext, E.Message, EncodeURL(ConcatURL(Url, FileName))]));

            if (E.ClassName = 'EIdReadTimeout') or (E.ClassName = 'EIdSocketError') then
            begin
              case Application.MessageBox(PChar('Connetion Refused. Retry?'), PChar('Read timed out'),
                MB_ICONERROR or MB_ABORTRETRYIGNORE) of
                mrRetry :
                  begin
                    tmlFileStream.Free;
                    tmlFileStream := nil;
                    if not DownloadFile(Url, DestPath, FileName) then Result := False else Result := True;
                  end;  
                mrAbort :
                  begin
                    bRequestCancel := True;
                    Result := False;
                  end;
                mrIgnore : Result := False;

              end;
              Exit;
            end
            else if E.ClassName = 'EOSError' then
            begin
              Application.MessageBox(PChar(EOSError(E).Message), PChar('OS Error Message'), MB_ICONERROR or MB_OK);
              bRequestCancel := True;
              Result := False;
            end;
          end;  
        end;
        CurrentStream := nil;
        //Stream.SaveToFile(ConcatPath(DestPath, FileName));

        ProgressTotalFileSize := ProgressTotalFileSize + tmlFileStream.Size;
        ProgressCurrentFileSize := ProgressCurrentFileSize + tmlFileStream.Size;
      finally
        if Assigned(tmlFileStream) then tmlFileStream.Free;
      end;
      
      Result := True;
    end;

    function Caclulate(Url: String; STRM: TStream; const Trunc: PwizOffsetFileSection = nil):Boolean;
    var
      tmpFileSize : UInt64;
    begin
      Result := False;
      if bRequestCancel then Exit;
      CS.Enter;
      try
        Caption := 'Downloading...';
      finally
        CS.Leave;
      end;  

      tmpFileSize := STRM.Size;
      CurrentStream := STRM;
      try
        if Trunc = nil then
        begin
          HTTP.Request.Clear;
          HTTP.Get(EncodeURL(Url), STRM)
        end
        else
        begin
          Assert(False, 'Stream Download');
          HTTP.Request.ContentRangeStart := Trunc.offset;
          Assert(False, 'ContentRangeStart = ' + IntToStr(Trunc.offset));
          HTTP.Request.ContentRangeEnd := Trunc.size + Trunc.offset -1;
          Assert(False, 'ContentRangeEnd = ' + IntToStr(Trunc.size + Trunc.offset -1));

          HTTP.Get(EncodeURL(Url), STRM);
        end;  
      except
        on E: Exception do
        begin
          Assert(False, Format('(%s Error No.: %d)%s - %s', [E.ClassName, E.HelpContext, E.Message, EncodeURL(Url)]));
          if (E.ClassName = 'EIdReadTimeout') or (E.ClassName = 'EIdSocketError') then
          begin
            case Application.MessageBox(PChar('Connetion Refused. Retry?'), PChar('Read timed out'),
              MB_ICONERROR or MB_ABORTRETRYIGNORE) of
              mrRetry :
                begin
                  STRM.Size := tmpFileSize;
                  if not Caclulate(Url, STRM, Trunc) then Result := False else Result := True;
                end;
              mrAbort :
                begin
                  bRequestCancel := True;
                  Result := False;
                end;
              mrIgnore : Result := False;
            end;
            Exit;
          end
          else if E.ClassName = 'EOSError' then
          begin
            Application.MessageBox(PChar(EOSError(E).Message), PChar('OS Error Message'), MB_ICONERROR or MB_OK);
            bRequestCancel := True;
            Result := False;
            Exit;
          end;
        end;  
      end;
                                                    
      CurrentStream := nil;
      Result := True;
    end;

begin
  Result := False;
  PartialFileSize := 0;

  if bRequestCancel then Exit;

  if DownLoadType = dtWizFile then
  begin
    if Data.MediaType = mtVideo then Ext := '.tvwiz' else Ext := '.radwiz';
    if not DirectoryExists(DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName) + Ext) then
    begin
      TmpPath := DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName) + Ext;
      dnCS.Enter;
      try
        lbFileName.Caption := ChangeUnsupportedFileName(Data.FileName) + Ext;
      finally
        dnCS.Leave;
      end;
      if not CreateDir(TmpPath) then
      begin
        Application.MessageBox('Failed Create File.', 'Failed', MB_OK);
        Exit;
      end;
    end
    else
    begin
      i := 0;
      while true do
      begin
        Inc(i);
        if not DirectoryExists(DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName) + '_' + IntToStr(i) + Ext) then
          Break;
      end;
      TmpPath := DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName) + '_' + IntToStr(i) + Ext;
      dnCS.Enter;
      try
        lbFileName.Caption := ChangeUnsupportedFileName(Data.FileName) + '_' + IntToStr(i) + Ext;
      finally
        dnCS.Leave;
      end;

      if not CreateDir(TmpPath) then
      begin
        Application.MessageBox('Failed Create File.', 'Failed', MB_OK);
        Exit;
      end;
    end;
    Assert(False, Format('Download WizFile: %s', [TmpPath]));
    if bRequestCancel then Exit;
    ProgressCurrentFileSize := 0;
    CurrentFileSize := Data.FileSize;

    if not DownloadFile(Data.FullName, TmpPath, 'header' + Ext) then Exit;
    if not DownloadFile(Data.FullName, TmpPath, 'stat') then Exit;
    if not DownloadFile(Data.FullName, TmpPath, 'trunc') then Exit;

    if bRequestCancel then Exit;
    FStream := TFileStream.Create(ConcatPath(TmpPath, 'trunc'), fmOpenRead);
    try
      while True do
      begin
        if bRequestCancel then Exit;
        if FStream.Read(WizTrunc, SizeOf(TwizOffsetFileSection)) = 0 then Break;
        if FileExists(ConcatPath(TmpPath, FormatFloat('0000', WizTrunc.fileNum))) then Continue;
        if bRequestCancel then Exit;
        if not DownloadFile(Data.FullName, TmpPath, FormatFloat('0000', WizTrunc.fileNum)) then
        begin
          TotalFileSize := TotalFileSize - Data.FileSize;
          ProgressTotalFileSize := ProgressTotalFileSize - ProgressCurrentFileSize;
          Exit;
        end;  
      end;
      ProgressTotalFileSize := ProgressTotalFileSize + (Data.FileSize - ProgressCurrentFileSize);
    finally
      FStream.Free;
    end;


  end
  else if DownLoadType = dtTSFile then
  begin
    if bRequestCancel then Exit;
    Ext := '.ts';
    if not FileExists(DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName) + Ext) then
    begin
      TmpPath := DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName) + Ext;
      dnCS.Enter;
      try
        lbFileName.Caption := ChangeUnsupportedFileName(Data.FileName) + Ext;
      finally
        dnCS.Leave;
      end;
    end
    else
    begin
      i := 0;
      while true do
      begin
        Inc(i);
        if not FileExists(DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName) + '_' + IntToStr(i) + Ext) then
          Break;
      end;
      TmpPath := DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName) + '_' + IntToStr(i) + Ext;
      dnCS.Enter;
      try
        lbFileName.Caption := ChangeUnsupportedFileName(Data.FileName) + '_' + IntToStr(i) + Ext;
      finally
        dnCS.Leave;
      end;
    end;
    Assert(False, Format('Download TS File: %s', [TmpPath]));
    
    if bRequestCancel then Exit;
    ProgressCurrentFileSize := 0;
    CurrentFileSize := Data.FileSize;

    Stream := TMemoryStream.Create;
    try
      if bRequestCancel then Exit;
      if not Caclulate(ConcatURL(Data.FullName, 'trunc'), Stream) then Exit;

      SaveFile := TFileStream.Create(TmpPath, fmCreate);
      try
        Stream.Position := 0;
        while True do
        begin
          if bRequestCancel then Exit;
          if Stream.Read(WizTrunc, SizeOf(TwizOffsetFileSection)) = 0 then Break;
          if not Caclulate(ConcatURL(Data.FullName, FormatFloat('0000', WizTrunc.fileNum)), SaveFile, @WizTrunc) then
          begin
            TotalFileSize := TotalFileSize - Data.FileSize;
            Exit;
          end;

          CS.Enter;
          try
            Caption := 'Analysing...';
          finally
            CS.Leave;
          end;  
          Assert(False, Format('WizTrunc.wizOffset = %d, WizTrunc.offset = %d, WizTrunc.size = %d', [WizTrunc.wizOffset, WizTrunc.offset, WizTrunc.size]));
        end;
        ProgressTotalFileSize := ProgressTotalFileSize + CurrentFileSize;
      finally
        SaveFile.Free;
      end;

    finally
      Stream.Free;
    end;
  end
  else if DownLoadType = dtSplitTS then
  begin
    if bRequestCancel then Exit;
    Ext := '.ts';
    
    if not DirectoryExists(DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName)) then
    begin
      TmpPath := ConcatPath(DownloadPath, ChangeUnsupportedFileName(Data.FileName));
      dnCS.Enter;
      try
        lbFileName.Caption := ChangeUnsupportedFileName(Data.FileName) + Ext;
      finally
        dnCS.Leave;
      end;
    end
    else
    begin
      i := 0;
      while true do
      begin
        Inc(i);
        if not DirectoryExists(DownloadPath + '\' + ChangeUnsupportedFileName(Data.FileName) + '_' + IntToStr(i)) then
          Break;
      end;
      TmpPath := ConcatPath(DownloadPath, ChangeUnsupportedFileName(Data.FileName) + '_' + IntToStr(i));
      dnCS.Enter;
      try
        lbFileName.Caption := ChangeUnsupportedFileName(Data.FileName) + '_' + IntToStr(i);
      finally
        dnCS.Leave;
      end;
    end;
    ForceDirectories(TmpPath);
    Assert(False, Format('Download Splite TS File: %s', [TmpPath]));
    if bRequestCancel then Exit;
    ProgressCurrentFileSize := 0;
    CurrentFileSize := Data.FileSize;

    Stream := TMemoryStream.Create;
    try
      if bRequestCancel then Exit;
      if not Caclulate(ConcatURL(Data.FullName, 'trunc'), Stream) then Exit;

      i := 0;
      SaveFile := TFileStream.Create(ConcatPath(TmpPath, 'Part' + FormatFloat('00', i) + Ext), fmCreate);
      try
        Stream.Position := 0;
        while True do
        begin
          if bRequestCancel then Exit;
          if Stream.Read(WizTrunc, SizeOf(TwizOffsetFileSection)) = 0 then Break;
          if SaveFile.Size + DEFAULT_DATAFILE_SIZE > SplitSize then
          begin
            FStream := TFileStream.Create(ConcatPath(TmpPath, 'Tmp'), fmCreate);
            try

              PartialFileSize := PartialFileSize + SaveFile.Size;
              if not Caclulate(ConcatURL(Data.FullName, FormatFloat('0000', WizTrunc.fileNum)), FStream, @WizTrunc) then
              begin
                TotalFileSize := TotalFileSize - Data.FileSize;
                Exit;
              end;
              FStream.Position := 0;
              PartialFileSize := PartialFileSize + FStream.Size;
              if SaveFile.Size + FStream.Size > SplitSize then
              begin
                CopyToStream(FStream, SaveFile, SplitSize - SaveFile.Size);
                SaveFile.Free;
                Inc(i);
                SaveFile := TFileStream.Create(ConcatPath(TmpPath, 'Part' + FormatFloat('00', i) + Ext), fmCreate);
                CopyToStream(FStream, SaveFile, FStream.Size - FStream.Position);
                PartialFileSize := PartialFileSize - SaveFile.Size;
              end
              else
              begin
                SaveFile.CopyFrom(FStream, FStream.Size);
                PartialFileSize := PartialFileSize - SaveFile.Size;
              end;

            finally
              FStream.Free;
              DeleteFile(ConcatPath(TmpPath, 'Tmp'));
            end;
          end
          else
          begin
            if not Caclulate(ConcatURL(Data.FullName, FormatFloat('0000', WizTrunc.fileNum)), SaveFile,  @WizTrunc) then
            begin
              TotalFileSize := TotalFileSize - Data.FileSize;
              Exit;
            end;  
          end;  
        end;
        ProgressTotalFileSize := ProgressTotalFileSize + CurrentFileSize;
      finally
        if Assigned(SaveFile) then SaveFile.Free;
      end;

    finally
      Stream.Free;
    end;

  end;
  Result := True;
end;

procedure TfrmDownload.RemoveTrashFile(Data: PWizFileInfo);
begin
  //TODO: Remove Trash File :)
end;

procedure TfrmDownload.FormShow(Sender: TObject);
var
  i : Integer;
  bWarningFileSize : Boolean;
  MaxFileSize : UInt64;
begin
  bCompletedJob := False;
  bRequestCancel := False;
  tmClose.Enabled := True;
  SplitSize := 0;

  if (not IsNTFS(Copy(DownloadPath,1,3))) and (DownLoadType = dtTSFile) then
  begin
    bWarningFileSize := False;
    MaxFileSize := 0;
    for i := 0 to FileList.Count -1 do
    begin
      if (PWizFileInfo(FileList.Objects[i]).FileSize > MAX_INT32_SIZE) then
      begin
        if MaxFileSize < PWizFileInfo(FileList.Objects[i]).FileSize then
          MaxFileSize := PWizFileInfo(FileList.Objects[i]).FileSize;
        bWarningFileSize := True;

      end;
    end;

    if bWarningFileSize then
    begin
      frmWarningFileSize.rb4GB.Caption := 'Do Not Split';
      if MaxFileSize > MAX_UINT32_SIZE then frmWarningFileSize.rb4GB.Caption := 'FAT32 Supported(4 GB)';

      if frmWarningFileSize.ShowModal = mrOk then
      begin
        SplitSize := IfThen(frmWarningFileSize.rb2GB.Checked, MAX_INT32_SIZE, MAX_UINT32_SIZE);
      end
      else
        bRequestCancel := True;
    end;    
  end;
  Assert(False, format('Start Download: %s File System, DownLoad Type is %s',
                      [IfThen(IsNTFS(Copy(DownloadPath,1,3)), 'NTFS', 'FAT32'),
                       IfThen(DownLoadType = dtTSFile, 'TS File', 'WizFile or Splite TS') ]));
  TRunThread.Create(ProcessFileList, Self);
end;

procedure TfrmDownload.SetTotalFileSize(const Value: UInt64);
begin
  FTotalFileSize := Value;
  dnCS.Enter;
  try
    if FTotalFileSize = 0 then Exit;
    pbTotal.Max := FTotalFileSize div (1024 * 1024);
    if FProgressTotalFileSize = 0 then Exit;
    pbTotal.Position := FProgressTotalFileSize div (1024 * 1024);
    lbTotal.Caption := Format('Total Progress(%s/%s)', [GetFileSizeStr(FProgressTotalFileSize), GetFileSizeStr(FTotalFileSize)]);
  finally
    dnCS.Leave;
  end;
end;


procedure TfrmDownload.SetProgressTotalFileSize(const Value: UInt64);
begin
  FProgressTotalFileSize := Value;
  if FProgressTotalFileSize = 0 then Exit;
  if FTotalFileSize = 0 then Exit;
  dnCS.Enter;
  try
    pbTotal.Position := FProgressTotalFileSize div (1024 * 1024);
    lbTotal.Caption := Format('Total Progress(%s/%s)', [GetFileSizeStr(FProgressTotalFileSize), GetFileSizeStr(FTotalFileSize)]);
  finally
    dnCS.Leave;
  end;
end;


procedure TfrmDownload.SetCurrentFileSize(const Value: UInt64);
begin
  FCurrentFileSize := Value;
  dnCS.Enter;
  try
    if FCurrentFileSize = 0 then Exit;
    pbFile.Max := FCurrentFileSize div (1024 * 1024);
    if FProgressCurrentFileSize = 0 then Exit;
    pbFile.Position := FProgressCurrentFileSize div (1024 * 1024);
  finally
    dnCS.Leave;
  end;
end;

procedure TfrmDownload.SetProgressCurrentFileSize(const Value: UInt64);
begin
  FProgressCurrentFileSize := Value;
  if FProgressCurrentFileSize = 0 then Exit;
  if FCurrentFileSize = 0 then Exit;
  dnCS.Enter;
  try
    pbFile.Position := FProgressCurrentFileSize div (1024 * 1024);
  finally
    dnCS.Leave;
  end;
end;


procedure TfrmDownload.tmCloseTimer(Sender: TObject);
begin
  if bCompletedJob then
  begin
    tmClose.Enabled := False;
    Close;
  end;  
end;

procedure TfrmDownload.btnCloseClick(Sender: TObject);
begin
  Close;
end;


procedure TfrmDownload.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i : Integer;
  Data: PWizFileInfo;
begin
  CanClose := False;
  if not bRequestCancel then
  begin
    btnClose.Enabled := False;
    bRequestCancel := True;
    Exit;
  end;

  if not bCompletedJob then Exit;

  dnCS.Enter;
  try
    for i := FileList.Count -1 downto 0 do
    begin
      Data := PWizFileInfo(FileList.Objects[i]);
      Dispose(Data);
      FileList.Delete(i);
    end;
  finally
    dnCS.Leave;
  end;
  
  CanClose := True;
end;





procedure TfrmDownload.HTTPWork(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
var
  tmpFileSize : UInt64;
begin
  dnCS.Enter;
  try
    if bRequestCancel then HTTP.Disconnect;
    if CurrentStream =  nil then Exit;
    lbTotal.Caption := Format('Total Progress(%s/%s)',
      [GetFileSizeStr(FProgressTotalFileSize + PartialFileSize + CurrentStream.Position),
       GetFileSizeStr(FTotalFileSize)]);
    tmpFileSize :=  (FProgressTotalFileSize + PartialFileSize + CurrentStream.Position) div (1024 * 1024);
    pbTotal.Position := tmpFileSize;
    tmpFileSize := (FProgressCurrentFileSize + PartialFileSize + CurrentStream.Position) div (1024 * 1024);
    pbFile.Position := tmpFileSize;
  finally
    dnCS.Leave;
  end;
end;

procedure TfrmDownload.SetCurrentStream(const Value: TStream);
begin
  FCurrentStream := Value;
end;

end.
