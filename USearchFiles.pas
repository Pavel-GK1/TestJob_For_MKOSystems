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
  UTaskProgress,
  Ulog
  ;

type
  TFmSearchFiles = class(TForm)
    BtnClose: TButton;
    PCSearchFiles: TPageControl;
    TS1_ParamsTask: TTabSheet;
    EdDirPath: TEdit;
    edFileMask: TEdit;
    Label3: TLabel;
    cbDoRecursive: TCheckBox;
    sbGetDirPath: TSpeedButton;
    Label2: TLabel;
    TS2_ResultTask: TTabSheet;
    LblFilesCount: TLabel;
    Label1: TLabel;
    BtnSearchFiles: TButton;
    TS3_Logs: TTabSheet;
    MemoLog: TMemo;
    MemoResults: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);

    procedure sbGetDirPathClick(Sender: TObject);
    procedure BtnSearchFilesClick(Sender: TObject);
    procedure FOnTaskDone;
    procedure FOnTaskAbort;
  private
    { Private declarations }
    LibHandle: THandle;
    Thread: TThread;
    MasksList: TStringDynArray;
    Itm: TlistItem;

    FilesList: TStringDynArray;
    FFileslist: TstringList;

    // функция подгружаемая из библиотеки
    SearchFilesFunc: TSearchFilesFunc;

    // сюда будем складывать кости
    Log: Tlog;

  public
    { Public declarations }
    TaskRecord: TTaskRecord;
    ProgressForm: TfmTaskProgress;
  end;

var
  FmSearchFiles: TFmSearchFiles;

implementation

{$R *.dfm}

Uses
  Umain, USelectDirectory;


procedure TFmSearchFiles.FormCreate(Sender: TObject);
begin
  // создаём логи
  Log := TLog.Create(GetlogFileName('SearchFiles'), MemoLog);

  FFileslist := TstringList.Create;
end;

procedure TFmSearchFiles.FormDestroy(Sender: TObject);
begin
  SetLength(FilesList,0);
  FFileslist.Free;

  Log.free;
end;

procedure TFmSearchFiles.BtnCloseClick(Sender: TObject);
begin
  close;
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

// запуск поиска
procedure TFmSearchFiles.BtnSearchFilesClick(Sender: TObject);
var
  I: Integer;

begin
  // очищаем результат
  MemoResults.Clear;
  LblFilesCount.Caption := '';

  // установим статус выполнения
  // найдём задачу в списке задач главного окна программы
  Itm := nil;
  for I := 0 to FmMain.LvTasksList.GetCount - 1 do
  if TaskRecord.TaskFunctionDescription = FmMain.LvTasksList.items[i].caption then
  begin
    Itm := FmMain.LvTasksList.items[i];
    Itm.SubItems[0] := 'выполняется';
    Itm.SubItems[1] := DateTimeToStr(Now);
  end;

  Log.AddMes('Начато выполнение задачи "' + Itm.caption + '"');
  Log.AddMes('стартовая папка "' + EdDirPath.Text + '"');
  Log.AddMes('маска поиска "' + edFileMask.Text + '"');

  // показываем окно процесса выполнения
  ProgressForm := TfmTaskProgress.Create(self);
  ProgressForm.LblTaskDescription.Caption := TaskRecord.TaskFunctionDescription;
  // опишем что надо сделать при прерывании выполнения задачи
  ProgressForm.OnTaskAbort := FOnTaskAbort;
  ProgressForm.show;

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
            FFileslist.Clear;

            // получим список масок для поиска файлов, маски должны разделяться запятыми
            MasksList := GetStringsArrayFromString(edFileMask.text, ',');
            // список найденных файлов
            SearchFilesFunc(EdDirPath.Text, MasksList, FFileslist);

            // синхронизируем с VCL вывод результата
            TThread.Synchronize(nil,
              procedure
              begin
                FOnTaskDone;
              end);
          end;
        end;

      finally
        SearchFilesFunc := nil;
        FreeLibrary(LibHandle);
      end;
    end);

  Thread.FreeOnTerminate := True;
  Thread.Start;
end;

// опишем что надо сделать при прерывании выполнения задачи
procedure TFmSearchFiles.FOnTaskDone;
var
  i: integer;
begin
  // закрываем форму процесса выполнения задачи
  if Assigned(ProgressForm) then
  begin
    ProgressForm.close;
    FreeAndNil(ProgressForm);
  end;

  // количество найденных файлов
//  LblFilesCount.Caption := IntToStr(Length(FilesList));
  LblFilesCount.Caption := IntToStr(FFilesList.Count);

  Application.ProcessMessages;

  // изменим статус выполнения задачи
  if Assigned(Itm) then
  begin
    Itm.SubItems[0] := 'выполнено (' +
                       IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' сек)';
    Itm.SubItems[1] := DateTimeTostr(Now);
  end;

  Log.AddMes('Закончено выполнение задачи "' + Itm.caption + '"');
  Log.AddMes('Найдено файлов : ' + LblFilesCount.Caption);
  Log.AddMes('');

  Application.ProcessMessages;

  // показываем результат
  PCSearchFiles.TabIndex := 1;

  // включим таймер заполнения списка,
  // для больших списков используем Application.ProcessMessages, чтобы приложение не зависало
  // но что-то работает кривовато
//  TmrStartFillFilesList.Enabled := true;

  // для очень больших списков работает медленно при построчном заполнении
  // и возникают ошибки с использованием Application.ProcessMessages
  // заплняем мемо списком, программа зависает на несколько секунд для 60000 файлов
  MemoResults.Lines.Text := FFileslist.Text;
  Application.ProcessMessages;
end;

// опишем что надо сделать при прерывании выполнения задачи
procedure TFmSearchFiles.FOnTaskAbort;
begin
  // закрываем форму процесса выполнения
  if Assigned(ProgressForm) then
  begin
    ProgressForm.close;
    FreeAndNil(ProgressForm);
  end;

  // уничтожаем поток
  If assigned(Thread) then
  begin
    // метод не совсем корректный
    terminateThread(Thread.Handle, 0);
    Thread := nil;
  end;

  // так... на всякий случай
  Application.ProcessMessages;

  // меняем статус выпалнения задачи
  if assigned(Itm) then
  begin
    Itm.SubItems[0] := 'прервано';
    Itm.SubItems[1] := DateTimeToStr(Now);

    Log.AddMes('Выполнение задачи "' + Itm.caption + '" прервано');
  end;

  // очищаем разультат поиска
  MemoResults.Clear;
  LblFilesCount.Caption := '0';
end;


end.
