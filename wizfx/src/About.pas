unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Types, jpeg, StdCtrls;

type
  TfrmAbout = class(TForm)
    Image1: TImage;
    lbVersion: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses Functions;

{$R *.dfm}

function FormToAlpha(Form: TForm; BMP: TBitmap): Boolean;

    procedure AlphaValueToColor(Bitmap: TBitmap);
    type
      TRGBA = packed record
        b, g, r, a: Byte;
      end;
    type
      TRGBArr = array[Word]of TRGBA;
      PRGBArr = ^TRGBArr;
    var
      P: PRGBArr;
      iW, iH, iWMax, iHMax: Integer;
      TempAlpha: Single;
    begin
      iWMax:=Bitmap.Width;
      iHMax:=Bitmap.Height;

      for iH:=0 to iHMax-1 do
      begin
        P:=Bitmap.ScanLine[iH];
        for iW:=0 to iWMax-1 do with P[iW] do
        begin
          TempAlpha:=a/$FF;
          r:=Round(r*TempAlpha);
          g:=Round(g*TempAlpha);
          b:=Round(b*TempAlpha);
        end;
      end;
    end;

var
  SrcPos, DstPos, Size: TPoint;
  BlendFun: TBlendFunction;
  DC: HDC;
begin
 Result:=False;

 if not Assigned(Form) then Exit;
 if not Assigned(BMP) then Exit;

 with Form do
 begin
   SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED); 

   if BMP.PixelFormat=pf32bit then AlphaValueToColor(BMP);

   SrcPos:=Point(0, 0);
   DstPos:=BoundsRect.TopLeft;
   Size:=Point(BMP.Width, BMP.Height);

   DC:=GetDC(0);

   BlendFun.BlendOp    :=AC_SRC_OVER;
   BlendFun.BlendFlags :=0;
   BlendFun.SourceConstantAlpha:=$FF;
   BlendFun.AlphaFormat:=AC_SRC_ALPHA;

   UpdateLayeredWindow(Handle, DC, @DstPos, @Size, BMP.Canvas.Handle, @SrcPos, clBlack, @BlendFun, ULW_ALPHA);
   ReleaseDC(0, DC);
 end;
end;

procedure ReassinAlpha(Src, Dest: TBitmap);
  type
    TRGBA = packed record
      b, g, r, a: Byte;
    end;
  type
    TRGBArr = array[Word]of TRGBA;
    PRGBArr = ^TRGBArr;
  var
    P1, P2: PRGBArr;
    iW, iH, iWMax, iHMax: Integer;
begin
  iWMax:=Src.Width;
  iHMax:=Src.Height;

  for iH:=0 to iHMax-1 do
  begin
    P1 := Src.ScanLine[iH];
    P2 := Dest.ScanLine[iH];
    for iW:=0 to iWMax-1 do
    begin
      P2[iW].a :=P1[iW].a;
    end;
  end;
end;


procedure TfrmAbout.FormActivate(Sender: TObject);
var
  TmpBitmap : TBitmap;
  Major, Minor, Release, Build : Word;
begin
  if ReadVersionInfo(ParamStr(0), @Major, @Minor, @Release, @Build) then
    lbVersion.Caption := Format('Version : %d.%d.%d.%d', [Major, Minor, Release, Build]);



  TmpBitmap := TBitmap.Create;
  try
    TmpBitmap.Assign(Image1.Picture.Bitmap);

    Image1.Picture.Bitmap.Canvas.Brush.Style := bsClear;
    Image1.Picture.Bitmap.Canvas.Font.Assign(lbVersion.Font);
    Image1.Picture.Bitmap.Canvas.TextOut(lbVersion.Left, lbVersion.Top, lbVersion.Caption);
    Image1.Picture.Bitmap.Canvas.TextOut(Label1.Left, Label1.Top, Label1.Caption);
    Image1.Picture.Bitmap.Canvas.TextOut(Label2.Left, Label2.Top, Label2.Caption);

    ReassinAlpha(TmpBitmap, Image1.Picture.Bitmap);
  finally
    TmpBitmap.Free;
  end;
  FormToAlpha(Self, Image1.Picture.Bitmap);
end;

procedure TfrmAbout.Image1Click(Sender: TObject);
begin
  Close;
end;

end.
