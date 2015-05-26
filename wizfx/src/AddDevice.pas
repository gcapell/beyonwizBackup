unit AddDevice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Mask,
  Buttons, Spin, uStructures, StrUtils;

type
  TfrmAddDevice = class(TForm)
    lvIPAddress: TLabel;
    lvPort: TLabel;
    lbDeviceName: TLabel;
    Bevel1: TBevel;
    edIPAddress: TEdit;
    sePort: TSpinEdit;
    btnCheck: TBitBtn;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    lbStatus: TLabel;
    procedure btnCheckClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edIPAddressChange(Sender: TObject);
  private
    FDevice: PDeviceInfo;
    tmpDevice: PDeviceInfo;
    FState: TDeviceState;
    procedure SetDevice(const Value: PDeviceInfo);
    procedure SetState(const Value: TDeviceState);
    { Private declarations }
  public
    property Device : PDeviceInfo read FDevice write SetDevice;
    property State: TDeviceState read FState write SetState;
  end;

var
  frmAddDevice: TfrmAddDevice;

implementation

uses Functions, Favorites;

{$R *.dfm}

procedure TfrmAddDevice.btnCheckClick(Sender: TObject);
var
  URLObject: PURLObject;
begin

    New(URLObject);
    URLObject.DeviceType := deUPnP; //Deive Name을 가져오기 위해 UPnP로 설정한다.
    URLObject.URL := format('http://%s:%d/%s',[frmAddDevice.edIPAddress.Text, frmAddDevice.sePort.Value, 'tvdevicedesc.xml']);
    URLObject.Cnt := 0;
    tmpDevice.DescURL := URLObject.URL;
    
    if GetDeviceDescription(tmpDevice, URLObject) then
    begin
      lbStatus.Font.Color := clBlue;
      lbStatus.Caption := 'Check Succeeded';
      lbDeviceName.Caption := 'Device Name: ' + tmpDevice.Name;
    end
    else
    begin
      lbStatus.Font.Color := clRed;
      lbStatus.Caption := 'Check Failed';
      lbDeviceName.Caption := 'Device Name: ';
    end;

    Dispose(URLObject);

end;

procedure TfrmAddDevice.SetDevice(const Value: PDeviceInfo);
var
  iPos : Integer;
  SL: TStringList;
  tmpStr : String;
begin
  FDevice := Value;
  tmpDevice.Name := FDevice.Name;
  tmpDevice.DescURL := FDevice.DescURL;
  tmpDevice.presentationURL := FDevice.presentationURL;
  tmpDevice.ImageIndex := FDevice.ImageIndex;

  lbDeviceName.Caption := 'Device Name: ' + tmpDevice.Name;

  lbStatus.Caption := '';
  if tmpDevice.DescURL <> '' then
  begin
    iPos := PosEx('/', tmpDevice.DescURL, 8);

    SL := TStringList.Create;
    try
      tmpStr := StringReplace(Copy(Device.DescURL, 1, iPos - 1), 'http://', '', []);
      SL.Text := StringReplace(tmpStr, ':', #13, [rfReplaceAll]);
      if SL.Count <> 2 then
      begin
        edIPAddress.Text := '';
        sePort.Value := 49152;
        Exit;
      end;
      edIPAddress.Text := SL.Strings[0];
      sePort.Value := StrToIntDef(SL.Strings[1], 0);
      
    finally
      SL.Free;
    end;
  end
  else
  begin
    edIPAddress.Text := '';
    sePort.Value := 49152;
  end;  

end;

procedure TfrmAddDevice.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i : Integer;
  DeviceInfo : PDeviceInfo;
  Info : String;
begin
  CanClose := False;
  if ModalResult = mrOk then
  begin
    for i := 0 to frmFavorites.lvFavorites.Items.Count -1 do
    begin
      DeviceInfo := PDeviceInfo(frmFavorites.lvFavorites.Items[i].Data);
      if DeviceInfo = nil then Continue;
      Info := Copy(DeviceInfo.DescURL, 0, PosEx(':', DeviceInfo.DescURL,8)-1);
      if (Info = 'http://' + edIPAddress.Text)
        and not ((frmFavorites.lvFavorites.Items[i].Selected) and (State = dsEdit))  then
      begin
        Application.MessageBox('Same IPAddress is exist. Please check this IPAddress.', 'Warning', MB_ICONWARNING or MB_OK);
        edIPAddress.SetFocus;
        Exit;
      end;
    end;
    if tmpDevice.Name <> '' then
      FDevice.Name := tmpDevice.Name
    else
      FDevice.Name := 'Unknown';
    edIPAddressChange(Self);

    FDevice.DescURL := tmpDevice.DescURL;
    FDevice.presentationURL := tmpDevice.presentationURL;
    FDevice.ImageIndex := tmpDevice.ImageIndex;
  end;
  CanClose := True;;
end;

procedure TfrmAddDevice.FormCreate(Sender: TObject);
begin
  New(tmpDevice);
end;

procedure TfrmAddDevice.FormDestroy(Sender: TObject);
begin
  if Assigned(tmpDevice) then Dispose(tmpDevice);
end;

procedure TfrmAddDevice.SetState(const Value: TDeviceState);
begin
  FState := Value;
end;

procedure TfrmAddDevice.edIPAddressChange(Sender: TObject);
begin
  tmpDevice.DescURL := format('http://%s:%d/%s',[frmAddDevice.edIPAddress.Text, frmAddDevice.sePort.Value, 'tvdevicedesc.xml']);
end;

end.
