unit uStructures;

interface

uses SyncObjs;


const
  MAX_TS_POINT = 8640;
  DEFAULT_DATAFILE_SIZE = 33554432;

  MAX_INT32_SIZE = 2147483647;
  MAX_UINT32_SIZE = 4294967295;

type
  TMediaType = (mtVideo, mtAudio, mtPhoto);
  TDeviceType = (deUPnP, deHTTP);
  TDownloadType = (dtWizFile, dtTSFile, dtSplitTS);
  TDeviceState = (dsInsert, dsEdit, dsDelete); 

  TDeviceInfo = record
    Name: String;
    DescURL: String;
    presentationURL: String;
    ImageIndex: Integer;
  end;
  PDeviceInfo = ^TDeviceInfo;

  TURLObject = record
    DeviceType: TDeviceType;
    Name : String;
    Cnt : Integer;
    URL: String;
  end;
  PURLObject = ^TURLObject;

  TLocalFileInfo = record
    FullName : String;
    FileSize : UInt64; 
  end;
  PLocalFileInfo = ^TLocalFileInfo;
  
  TWizFileInfo = record
     FileName : String;
     FullName : String;
     PlayTime : Integer;
     FileSize : UInt64;
     Locked : Boolean;
     MediaType : TMediaType;
     LastModifiedDate: TDateTime;
     IsRec: Boolean;
  end;
  PWizFileInfo = ^TWizFileInfo;

  TWizFileHeader = packed record
    header: Word;
    ver: Word;

    vidPid: Word;
    audPid: Word;
    pcrPid: Word;
    pmtPid: Word;

    lock: ByteBool;
    full: ByteBool;
	  inRec: ByteBool;
	  xxx: ByteBool; // 16
  end;
  PWizFileHeader = ^TWizFileHeader;

  TOffSet = packed record
    lastOff: UInt64;
    fileOff: array [0 .. 8639] of UInt64;
  end;
  
  TWizTSPoint = record
    svcName: array [0 .. 255] of Char;
    evtName: array [0 .. 255] of Char;

    mjd  : Word;
    start: LongWord;
    last : Word;
    sec  : Word;   //last * 10 + sec = playtime
    Offset : TOffSet;
  end;

  TwizOffsetFileSection = packed record
    wizOffset : UInt64;
    fileNum: Word;
    flags: Smallint;
    offset: UInt64;
    size: LongWord;
  end;
  PwizOffsetFileSection = ^TwizOffsetFileSection;

const
  WIZFS_FLAG_DUP_FILENUM	= $C3;

var
  CS : TCriticalSection;

implementation

end.
