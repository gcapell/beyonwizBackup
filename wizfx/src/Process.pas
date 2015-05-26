unit Process;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls, uStructures, SyncObjs,
  Math, StrUtils;

type
  TfrmProcess = class(TForm)
    lbFileName: TLabel;
    pbTotal: TProgressBar;
    pbFile: TProgressBar;
    btnClose: TBitBtn;
    tmClose: TTimer;
    lbTotal: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmCloseTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
  private
    FCurrentStream: TStream;
    FCurrentFileSize: UInt64;
    FProgressCurrentFileSize: UInt64;
    FTotalFileSize: UInt64;
    FProgressTotalFileSize: UInt64;
    FDownLoadType: TDownloadType;
    procedure SetCurrentFileSize(const Value: UInt64);
    procedure SetCurrentStream(const Value: TStream);
    procedure SetProgressCurrentFileSize(const Value: UInt64);
    procedure SetProgressTotalFileSize(const Value: UInt64);
    procedure SetTotalFileSize(const Value: UInt64);
    procedure ProcessFileList(Sender: TObject);
    function ProcessChangeTSFile(Data: PLocalFileInfo): Boolean;
    procedure SetDownLoadType(const Value: TDownloadType);
    function AppendStream(Source, Dest: TStream; Size: UInt64): UInt64;
    { Private declarations }
  public
    property DownLoadType: TDownloadType read FDownLoadType write SetDownLoadType;  
    function AddFileQue(Data: PLocalFileInfo):Boolean;
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
    SplitSize : UInt64;
    PartialFileSize: UInt64;    
  end;

var
  frmProcess: TfrmProcess;

  
implementation

uses Functions, WarningFileSize;


{$R *.dfm}

{ TfrmProcess }



function TfrmProcess.AddFileQue(Data: PLocalFileInfo): Boolean;
begin
  FileList.AddObject(Data.FullName, TObject(Data));
  Result := True;
  Data.FileSize := GetWizFileSize(Data.FullName);
  TotalFileSize := TotalFileSize + Data.FileSize;
end;

procedure TfrmProcess.SetCurrentFileSize(const Value: UInt64);
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

procedure TfrmProcess.SetCurrentStream(const Value: TStream);
begin
  FCurrentStream := Value;
end;

procedure TfrmProcess.SetProgressCurrentFileSize(const Value: UInt64);
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

procedure TfrmProcess.SetProgressTotalFileSize(const Value: UInt64);
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

procedure TfrmProcess.SetTotalFileSize(const Value: UInt64);
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

procedure TfrmProcess.FormCreate(Sender: TObject);
begin
  FileList := TStringList.Create;
  dnCS := TCriticalSection.Create ;
  TotalFileSize := 0;
  ProgressTotalFileSize := 0;
  CurrentFileSize := 0;
  ProgressCurrentFileSize := 0;
end;

procedure TfrmProcess.FormShow(Sender: TObject);
var
  i : Integer;
  bWarningFileSize : Boolean;
  MaxFileSize: UInt64;
begin
  bCompletedJob := False;
  bRequestCancel := False;
  tmClose.Enabled := True;
  SplitSize := 0;

  if (not IsNTFS(Copy(PLocalFileInfo(FileList.Objects[0]).FullName,1,3))) then
  begin
    bWarningFileSize := False;
    MaxFileSize := 0;
    for i := 0 to FileList.Count -1 do
    begin
      if (PLocalFileInfo(FileList.Objects[i]).FileSize > MAX_INT32_SIZE) then
      begin
        if MaxFileSize < PLocalFileInfo(FileList.Objects[i]).FileSize then
          MaxFileSize := PLocalFileInfo(FileList.Objects[i]).FileSize;
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
                      [IfThen(IsNTFS(Copy(PLocalFileInfo(FileList.Objects[0]).FullName,1,3)), 'NTFS', 'FAT32'),
                       IfThen(DownLoadType = dtTSFile, 'TS File', 'WizFile or Splite TS') ]));  
  TRunThread.Create(ProcessFileList, Self);
end;

procedure TfrmProcess.ProcessFileList(Sender: TObject);
var
  i : Integer;
  Data: PLocalFileInfo;
begin
  try
    for i := 0 to FileList.Count -1 do
    begin
      Data := PLocalFileInfo(FileList.Objects[i]);
      if (IsNTFS(Copy(Data.FullName,1,3))) then
        DownLoadType := dtTSFile
      else
      begin
        if (Data.FileSize > MAX_INT32_SIZE) and (Data.FileSize < MAX_UINT32_SIZE)
            and  frmWarningFileSize.rb2GB.Checked then
          DownLoadType := dtSplitTS
        else if Data.FileSize > MAX_UINT32_SIZE then
          DownLoadType := dtSplitTS
        else
          DownLoadType := dtTSFile;
      end;

      if not ProcessChangeTSFile(Data) then
      begin
        //RemoveTrashFile(Data);
        Break;
      end;
    end;
  finally
    bRequestCancel := True;
    bCompletedJob := True;
  end;  
end;

function TfrmProcess.AppendStream(Source, Dest: TStream; Size: UInt64): UInt64;
const
  MaxBufSize = $F000;
var
  BufSize, N: Integer;
  Buffer: PChar;
  tmpSize : UInt64;
begin
  Result := 0;
  if Size > MaxBufSize then BufSize := MaxBufSize else BufSize := Size;
  GetMem(Buffer, BufSize);
  try
    tmpSize := Size;
    while tmpSize <> 0 do
    begin
      try
        if tmpSize > BufSize then N := BufSize else N := tmpSize;
        Source.ReadBuffer(Buffer^, N);
        Dest.WriteBuffer(Buffer^, N);
        Dec(tmpSize, N);
        ProgressTotalFileSize := ProgressTotalFileSize + N;
        ProgressCurrentFileSize := ProgressCurrentFileSize + N;
        Result := Result + N;
      except
        on E: Exception do
        begin
          Assert(False, Format('%s', [E.Message]));
          Assert(False, Format('Size = %d, N = %d', [tmpSize, N]));
          if E.ClassName = 'EOSError' then
          begin
            Application.MessageBox(PChar(EOSError(E).Message), PChar('OS Error Message'), MB_ICONERROR or MB_OK);
            bRequestCancel := True;
          end;
          Break;
        end;   
      end;        
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
end;


function TfrmProcess.ProcessChangeTSFile(Data: PLocalFileInfo): Boolean;
var
  TruncFileStream, TSFileStream, tmpFileStream: TFileStream;
  WizOffsetFile : TwizOffsetFileSection;
  TSFileName, tmpFileName : String;
  ReadSize : UInt64;
  i : Integer;
begin
  Result := False;
  if bRequestCancel then Exit;
  tmpFileName := ExtractFileName(Data.FullName);
  TSFileName := ConcatPath(ExtractFilePath(Data.FullName),
    Copy(tmpFileName, 1, Length(tmpFileName) - Length(ExtractFileExt(tmpFileName))));
  if DownLoadType = dtTSFile then
  begin
    if FileExists(TSFileName+ '.ts') then
    begin
      i := 0;
      while True do
      begin
        if not FileExists(TSFileName + '_' + IntToStr(i) + '.ts') then Break;
        Inc(i);
      end;
      TSFileName := TSFileName + '_' + IntToStr(i);
    end;
    TSFileName := TSFileName + '.ts';
    lbFileName.Caption := ExtractFileName(TSFileName);
    if bRequestCancel then Exit;
    Assert(False, Format('Process TS File: %s', [TSFileName]));
    
    CurrentFileSize := Data.FileSize;
    ProgressCurrentFileSize := 0;
    TruncFileStream := TFileStream.Create(ConcatPath(Data.FullName, 'trunc'), fmOpenRead);
    TSFileStream := TFileStream.Create(TSFileName, fmCreate);
    try
      while true do
      begin
        if bRequestCancel then Exit;
        if TruncFileStream.Read(WizOffsetFile, SizeOf(TwizOffsetFileSection)) = 0 then Break;
        if FileExists(ConcatPath(Data.FullName, FormatFloat('0000', WizOffsetFile.fileNum))) then
        begin
          tmpFileStream := TFileStream.Create(ConcatPath(Data.FullName, FormatFloat('0000', WizOffsetFile.fileNum)), fmOpenRead);
          try
            tmpFileStream.Position := WizOffsetFile.offset;
            if bRequestCancel then Exit;
            AppendStream(tmpFileStream, TSFileStream, WizOffsetFile.size);
          finally
            tmpFileStream.Free;
          end;  
        end;  
      end;  
    finally
      if Assigned(TruncFileStream) then TruncFileStream.Free;
      if Assigned(TSFileStream) then TSFileStream.Free;
    end;
  end
  else
  begin
    if DirectoryExists(TSFileName) then
    begin
      i := 0;
      while True do
      begin
        if not DirectoryExists(TSFileName + '_' + IntToStr(i)) then Break;
        Inc(i);
      end;
      TSFileName := TSFileName + '_' + IntToStr(i);
    end;
    if bRequestCancel then Exit;
    Assert(False, Format('Process Splite TS File: %s', [TSFileName]));
  
    CurrentFileSize := Data.FileSize;
    ProgressCurrentFileSize := 0;
    TruncFileStream := TFileStream.Create(ConcatPath(Data.FullName, 'trunc'), fmOpenRead);
    ForceDirectories(TSFileName);
    lbFileName.Caption := ExtractFileName(TSFileName);
    i := 0;
    TSFileStream := TFileStream.Create(ConcatPath(TSFileName, 'Part' + FormatFloat('00', i) + '.ts'), fmCreate);
    try
      while true do
      begin
        if bRequestCancel then Exit;
        if TruncFileStream.Read(WizOffsetFile, SizeOf(TwizOffsetFileSection)) = 0 then Break;

        if FileExists(ConcatPath(Data.FullName, FormatFloat('0000', WizOffsetFile.fileNum))) then
        begin
          tmpFileStream := TFileStream.Create(ConcatPath(Data.FullName, FormatFloat('0000', WizOffsetFile.fileNum)), fmOpenRead);
          try
            tmpFileStream.Position := 0;
            if TSFileStream.Size + WizOffsetFile.size >= SplitSize then
            begin
              ReadSize := AppendStream(tmpFileStream, TSFileStream, SplitSize - TSFileStream.Size);

              TSFileStream.Free;
              Inc(i);
              TSFileStream := TFileStream.Create(ConcatPath(TSFileName, 'Part' + FormatFloat('00', i) + '.ts'), fmCreate);

              AppendStream(tmpFileStream, TSFileStream, WizOffsetFile.size - ReadSize);
            end
            else
            begin
              AppendStream(tmpFileStream, TSFileStream, WizOffsetFile.size);
            end;
          finally
            tmpFileStream.Free;
          end;  
        end;  
      end;  
    finally
      if Assigned(TruncFileStream) then TruncFileStream.Free;
      if Assigned(TSFileStream) then TSFileStream.Free;
    end;
  end;  
  Result := True;
end;

procedure TfrmProcess.tmCloseTimer(Sender: TObject);
begin
  if bCompletedJob then
  begin
    tmClose.Enabled := False;
    Close;
  end;  
end;

procedure TfrmProcess.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i : Integer;
  Data: PLocalFileInfo;  
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
      Data := PLocalFileInfo(FileList.Objects[i]);
      Dispose(Data);
      FileList.Delete(i);
    end;
  finally
    dnCS.Leave;
  end;
  
  CanClose := True;
end;

procedure TfrmProcess.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(Self);
end;

procedure TfrmProcess.SetDownLoadType(const Value: TDownloadType);
begin
  FDownLoadType := Value;
end;

procedure TfrmProcess.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
