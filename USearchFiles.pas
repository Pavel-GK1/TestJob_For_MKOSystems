unit USearchFiles;

interface

uses
  Sharemem,
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.DateUtils,
  Vcl.ComCtrls,

  UAppTypes,
  UProgressOfJob
  ;

type
  TFmSearchFiles = class(TForm)
    BtnClose: TButton;
    TmrStartFillFilesList: TTimer;
    PCSearchFiles: TPageControl;
    TS1_ParamsTask: TTabSheet;
    EdDirPath: TEdit;
    edFileMask: TEdit;
    Label3: TLabel;
    cbDoRecursive: TCheckBox;
    sbGetDirPath: TSpeedButton;
    Label2: TLabel;
    TS2_ResultTask: TTabSheet;
    LbResults: TListBox;
    LblFilesCount: TLabel;
    Label1: TLabel;
    BtnSearchFiles: TButton;

    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSearchFilesClick(Sender: TObject);
    procedure sbGetDirPathClick(Sender: TObject);

    procedure TmrStartFillFilesListTimer(Sender: TObject);
  private
    { Private declarations }
    LibHandle: THandle;
    SearchFilesFunc: TSearchFilesFunc;
    Thread: TThread;
    FilesList, MasksList: TStringDynArray;
    Itm: TlistItem;

  public
    { Public declarations }
    TaskRecord: TTaskRecord;
    ProgressForm:TfmProgressOfJob;
  end;

var
  FmSearchFiles: TFmSearchFiles;

implementation

{$R *.dfm}

Uses
  Umain, USelectDirectory;

procedure TFmSearchFiles.BtnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TFmSearchFiles.BtnSearchFilesClick(Sender: TObject);
var
//  LSearchOption: TSearchOption;
  I: Integer;

begin
  // прячем форму
  close;

  // установим статус выполненя
  // найдём задачу в списке задач главного окна программы
  Itm := nil;
  for I := 0 to FmMain.LvTasksList.GetCount - 1 do
  if TaskRecord.TaskFunctionDescription = FmMain.LvTasksList.items[i].caption then
  begin
    Itm := FmMain.LvTasksList.items[i];
    Itm.SubItems[0] := 'выполняется';
    Itm.SubItems[1] := DateTimeToStr(Now);
  end;

  // показываем окно процесса выполнения
  ProgressForm := TfmProgressOfJob.Create(self);
  ProgressForm.LblTaskDescription.Caption := TaskRecord.TaskFunctionDescription;
  ProgressForm.show;

  // где будем искать - пока не используется
//  if cbDoRecursive.Checked then
//    LSearchOption := TSearchOption.soAllDirectories
//  else
//    LSearchOption := TSearchOption.soTopDirectoryOnly;

  // всякие разные опции
//    if cbIncludeDirectories.Checked and cbIncludeFiles.Checked then
//      FilesList := TDirectory.GetFileSystemEntries(editPath.Text, LSearchOption, nil);

//    if cbIncludeDirectories.Checked and not cbIncludeFiles.Checked then
//      LList := TDirectory.GetDirectories(editPath.Text, editFileMask.Text, LSearchOption);

//    if not cbIncludeDirectories.Checked and cbIncludeFiles.Checked then
//      FilesList := TDirectory.GetFiles(editPath.Text, editFileMask.Text, LSearchOption);

  // поиск выполняем в потоке
  Thread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        LibHandle := LoadLibrary('TestJobDLL1.dll');

        if LibHandle <> 0 then
        begin
          SearchFilesFunc := GetProcAddress(LibHandle, PwideChar(TaskRecord.TaskFunctionName)); //'SearchFiles');

          if Assigned(SearchFilesFunc) then
          begin
            setlength(MasksList, 0);
            // получим список масок для поиска файлов, маски должны разделяться запятыми
            MasksList := GetStringsArrayFromString(edFileMask.text, ',');
            // список найденных файлов
            Fileslist := SearchFilesFunc(EdDirPath.Text, MasksList);
          end;
        end;

      finally
        SearchFilesFunc := nil;
        FreeLibrary(LibHandle);

        // в потоке синхронизацию с VCL не будем использовать - включим таймер заполнения списка,
        // для больших списков используем Application.ProcessMessages, чтобы приложение не зависало
        // но что-то работает кривовато
        TmrStartFillFilesList.Enabled := true;
      end;
    end);

  Thread.FreeOnTerminate := True;
  Thread.Start;
end;


// выбор папки для поиска
procedure TFmSearchFiles.sbGetDirPathClick(Sender: TObject);
var
  dir: WideString;
  res : Integer;
begin
  if Length(EdDirPath.text) > 0 then
  begin
    dir := EdDirPath.text;
    if not DirectoryExists(dir) then
      dir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  end
  else
    dir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

  ForceDirectories(dir);

  // показываем пользователю окно выбора каталога
  SelectDirectory.DirectoryListBox.Directory := dir;
  res := SelectDirectory.ShowModal;

  // директория выбрана (выбор идёт по двойному щелчку)
  if (res = MrOk) then
    EdDirPath.text := IncludeTrailingPathDelimiter(SelectDirectory.DirectoryListBox.Directory);
end;

// ТАЙМЕР ЗАПОЛНЕНИЯ СПИСКА РЕЗУЛЬТАТОВ ПОИСКА
procedure TFmSearchFiles.TmrStartFillFilesListTimer(Sender: TObject);
var i: integer;
begin
  TmrStartFillFilesList.Enabled := false;

  // заполняем список найденных файлов
  LbResults.Clear;
  for I := 0 to Length(FilesList) - 1 do
  begin
    LbResults.Items.Add(FilesList[I]);

    Application.ProcessMessages;
  end;

  // количество найденных файлов
  LblFilesCount.Caption := IntToStr(Length(FilesList));

  // закрываем форму процесса выполнения задачи
  ProgressForm.close;
  FreeAndNil(ProgressForm);

  // изменим статус выполнения
  if Assigned(Itm) then
  begin
    Itm.SubItems[0] := 'выполнено (' +
                       IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' сек)';
    Itm.SubItems[1] := DateTimeTostr(Now);
  end;

  // показываем результат
  PCSearchFiles.TabIndex := 1;
  Show;
end;

end.
