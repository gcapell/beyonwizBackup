program WizFX;

uses
  Forms,
  WizDownloaderMain in 'WizDownloaderMain.pas' {frmDownloader},
  uStructures in 'uStructures.pas',
  Functions in 'Functions.pas',
  Download in 'Download.pas' {frmDownload},
  AddDevice in 'AddDevice.pas' {frmAddDevice},
  Preference in 'Preference.pas' {frmPreference},
  Process in 'Process.pas' {frmProcess},
  Favorites in 'Favorites.pas' {frmFavorites},
  WarningFileSize in 'WarningFileSize.pas' {frmWarningFileSize},
  About in 'About.pas' {frmAbout};

{$R *.res}


begin
  Application.Initialize;
  Application.Title := 'WizFX';
  Application.CreateForm(TfrmDownloader, frmDownloader);
  Application.CreateForm(TfrmAddDevice, frmAddDevice);
  Application.CreateForm(TfrmPreference, frmPreference);
  Application.CreateForm(TfrmFavorites, frmFavorites);
  Application.CreateForm(TfrmWarningFileSize, frmWarningFileSize);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.
