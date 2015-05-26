unit WarningFileSize;

interface
{$ASSERTIONS ON}
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfrmWarningFileSize = class(TForm)
    gbSelectFileSize: TGroupBox;
    rb2GB: TRadioButton;
    rb4GB: TRadioButton;
    lbMessage: TLabel;
    btnOk: TBitBtn;
    imgWarning: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmWarningFileSize: TfrmWarningFileSize;

implementation

{$R *.dfm}

end.
