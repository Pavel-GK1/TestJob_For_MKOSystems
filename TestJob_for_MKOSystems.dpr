program TestJob_for_MKOSystems;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FmMain},
  USelectDirectory in 'USelectDirectory.pas' {SelectDirectory},
  USearchFiles in 'USearchFiles.pas' {FmSearchFiles},
  UTaskProgress in 'UTaskProgress.pas' {fmTaskProgress},
  UAppTypes in 'UAppTypes.pas',
  USearchEntriesSubstrInFile in 'USearchEntriesSubstrInFile.pas' {FmSearchEntriesSubstrInFile};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFmMain, FmMain);
  Application.CreateForm(TSelectDirectory, SelectDirectory);
  Application.CreateForm(TFmSearchFiles, FmSearchFiles);
  Application.CreateForm(TFmSearchEntriesSubstrInFile, FmSearchEntriesSubstrInFile);
  Application.Run;
end.
