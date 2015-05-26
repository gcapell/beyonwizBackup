unit Preference;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Spin;

type
  TfrmPreference = class(TForm)
    rgDownloadType: TRadioGroup;
    cbLastDownloadpath: TCheckBox;
    cbAutoSplite: TCheckBox;
    gbSpliteOption: TGroupBox;
    Label1: TLabel;
    lbByte: TLabel;
    cbPropositionSize: TComboBox;
    seFileSize: TSpinEdit;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    procedure cbAutoSpliteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPreference: TfrmPreference;

implementation

{$R *.dfm}

procedure TfrmPreference.cbAutoSpliteClick(Sender: TObject);
begin
  gbSpliteOption.Enabled := not cbAutoSplite.Checked;
end;

end.
