program TestJob_for_MKOSystems;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FmMain},
  USelectDirectory in 'USelectDirectory.pas' {SelectDirectory},
  USearchFiles in 'USearchFiles.pas' {FmSearchFiles},
  UTaskProgress in 'UTaskProgress.pas' {fmTaskProgress},
  UAppTypes in 'UAppTypes.pas',
  USearchStringEntriesInFile in 'USearchStringEntriesInFile.pas' {FmSearchStringEntriesInFile},
  URunShellCommand in 'URunShellCommand.pas' {FmRunShellCommand},
  ULog in 'ULog.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFmMain, FmMain);
  Application.CreateForm(TSelectDirectory, SelectDirectory);
  Application.CreateForm(TFmSearchFiles, FmSearchFiles);
  Application.CreateForm(TFmSearchStringEntriesInFile, FmSearchStringEntriesInFile);
  Application.CreateForm(TFmRunShellCommand, FmRunShellCommand);
  Application.Run;
end.
