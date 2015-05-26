unit Favorites;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, Buttons, ExtCtrls, IniFiles, StrUtils, uStructures;

type
  TfrmFavorites = class(TForm)
    pnToolbar: TPanel;
    btnAdd: TSpeedButton;
    btnEdit: TSpeedButton;
    btnDelete: TSpeedButton;
    lvFavorites: TListView;
    ImageList1: TImageList;
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvFavoritesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvFavoritesDblClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
  private
    SLFavorites : TStringList;
    procedure HandleListItem(Item: TListItem; Device: PDeviceInfo);
    procedure HandleIniFile(Item: TListItem; State: TDeviceState);
  public
    { Public declarations }
  end;

var
  frmFavorites: TfrmFavorites;

implementation

uses AddDevice, Functions, WizDownloaderMain;

{$R *.dfm}

procedure TfrmFavorites.btnAddClick(Sender: TObject);
var
  Device : PDeviceInfo;
  Item : TListItem;
  URLObject: PURLObject;
begin
  frmAddDevice.Caption := 'Add New Favorite';
  New(Device);
  Device.ImageIndex := Ord(deHTTP);
  frmAddDevice.Device := Device;
  frmAddDevice.State := dsInsert;
  if frmAddDevice.ShowModal = mrOk then
  begin
    Item := lvFavorites.Items.Add;
    HandleListItem(Item, Device);
    HandleIniFile(Item, dsInsert);
    New(URLObject);
    URLObject.Name := Device.Name;
    URLObject.DeviceType := deHTTP;
    URLObject.URL := Device.DescURL;
    Item.Selected := True;

    frmDownloader.AddDevice(TObject(URLObject));
  end
  else
    Dispose(Device);
    
end;

procedure TfrmFavorites.btnEditClick(Sender: TObject);
var
  IP : String;
begin
  frmAddDevice.Device := PDeviceInfo(lvFavorites.Selected.Data);
  frmAddDevice.Caption := 'Edit Favorite';
  frmAddDevice.State := dsEdit;
  if frmAddDevice.ShowModal = mrOk then
  begin
    IP := lvFavorites.Selected.SubItems[0];
    IP := copy(IP, 1, PosEx(':', IP, 8)-1);
    IP := StringReplace(IP, 'http://', '', []);
    frmDownloader.EditDevice(IP, PDeviceInfo(lvFavorites.Selected.Data));
    HandleIniFile(lvFavorites.Selected, dsEdit);
    HandleListItem(lvFavorites.Selected, PDeviceInfo(lvFavorites.Selected.Data));
  end;
end;


procedure TfrmFavorites.btnDeleteClick(Sender: TObject);
var
  IP : String;
begin
  if Application.MessageBox('Are you sure?', 'Confirm', MB_YESNO) = mrYes then
  begin
    IP := lvFavorites.Selected.SubItems[0];
    IP := copy(IP, 1, PosEx(':', IP, 8)-1);
    IP := StringReplace(IP, 'http://', '', []);
    frmDownloader.DeleteDevice(IP);
    
    HandleIniFile(lvFavorites.Selected, dsDelete);
    Dispose(PDeviceInfo(lvFavorites.Selected.Data));
    lvFavorites.DeleteSelected;
  end;
  
end;

procedure TfrmFavorites.FormCreate(Sender: TObject);
var
  IniFile : TIniFile;
  i : Integer;
  Item : TListItem;
  Device : PDeviceInfo;

begin
  SLFavorites := TStringList.Create;

  IniFile := TIniFile.Create(ConcatPath(ExtractFilePath(ParamStr(0)), 'Pref.ini'));
  try

    IniFile.ReadSection('Favorites', SLFavorites);
    for i := 0 to SLFavorites.Count -1 do
    begin
      New(Device);
      if ExtractFavoriteInfo(IniFile.ReadString('Favorites', SLFavorites.Strings[i], ''), Device) then
      begin
        Item := lvFavorites.Items.Add;
        HandleListItem(Item, Device);
      end
      else
        Dispose(Device);
    end;
  finally
    if Assigned(IniFile) then IniFile.Free;
  end;
end;

procedure TfrmFavorites.HandleListItem(Item: TListItem;
  Device: PDeviceInfo);
var
  iPos : Integer;
begin
  Item.Data := Device;
  Item.Caption := Device.Name;
  iPos := PosEx('/', Device.DescURL, 8);
  if Item.SubItems.Count = 0 then
    Item.SubItems.Add(Copy(Device.DescURL, 1, iPos - 1))
  else
    Item.SubItems[0] := Copy(Device.DescURL, 1, iPos - 1);
end;

procedure TfrmFavorites.lvFavoritesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  btnEdit.Enabled := lvFavorites.Selected <> nil;
  btnDelete.Enabled := btnEdit.Enabled;
end;

procedure TfrmFavorites.lvFavoritesDblClick(Sender: TObject);
begin
  if lvFavorites.Selected <> nil then btnEditClick(Sender);
end;



procedure TfrmFavorites.HandleIniFile(Item: TListItem;
  State: TDeviceState);
var
  iPos : Integer;
  iniFile : TIniFile;
  Key, Value : String;
  Device : PDeviceInfo;
  KeyIndex : Integer;
begin

  iniFile := TIniFile.Create(ConcatPath(ExtractFilePath(ParamStr(0)),'Pref.ini'));
  try
    case State of
      dsInsert :
        begin
          Device := PDeviceInfo(Item.Data);
          KeyIndex := 0;
          if SLFavorites.count <> 0 then
          begin
            Key := StringReplace(SLFavorites.Strings[SLFavorites.count -1], 'Item', '', [rfIgnoreCase]);
            KeyIndex := StrToIntDef(Key, SLFavorites.count);
          end;


          while True do
          begin
            Key := 'Item' + IntToStr(KeyIndex);
            if SLFavorites.IndexOf(Key) < 0 then Break;
            Inc(KeyIndex);
          end; 

          iPos := PosEx('/', Device.DescURL, 8);
          Value := Copy(Device.DescURL, 1, iPos - 1);
          Value := StringReplace(Value, 'http://', '', [rfIgnoreCase]);
          Value := Value + ';' + Device.Name;

          iniFile.WriteString('Favorites', Key, Value);
          SLFavorites.Add(Key);
        end;
      dsEdit :
        begin
          Key := SLFavorites.Strings[Item.Index];
          
          Device := PDeviceInfo(Item.Data);
          iPos := PosEx('/', Device.DescURL, 8);
          Value := Copy(Device.DescURL, 1, iPos - 1);
          Value := StringReplace(Value, 'http://', '', [rfIgnoreCase]);
          Value := Value + ';' + Device.Name;
          iniFile.WriteString('Favorites', Key, Value);
          
        end;
      dsDelete :
        begin
          iniFile.DeleteKey('Favorites', SLFavorites.Strings[Item.Index]);
          SLFavorites.Delete(Item.Index);
        end;    
    end;
  finally
    iniFile.Free;
  end;
end;

end.
