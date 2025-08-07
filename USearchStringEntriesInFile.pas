// можно было сделать наследника от TFmsearchFile, но так тоже неплохо
unit USearchStringEntriesInFile;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  System.DateUtils, System.IOUtils, System.UITypes,
  Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls,

  UAppTypes,
  UTaskProgress,
  Ulog
  ;

type
  TFmSearchStringEntriesInFile = class(TForm)
    PC_SearchEntries: TPageControl;
    TS1_ParamsTask: TTabSheet;
    Label3: TLabel;
    sbGetFilePath: TSpeedButton;
    Label2: TLabel;
    EdFilePath: TEdit;
    edSubStrForSearch: TEdit;
    BtnSearchEntries: TButton;
    TS2_ResultTask: TTabSheet;
    LblEntriesCount: TLabel;
    Label1: TLabel;
    LbResults: TListBox;
    BtnClose: TButton;
    TmrStartFillEntriesList: TTimer;
    TS3_Logs: TTabSheet;
    MemoLog: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);

    procedure sbGetFilePathClick(Sender: TObject);
    procedure BtnSearchEntriesClick(Sender: TObject);

    // штатное завершение задачи
    procedure FOnTaskDone;
    // завершение задачи по прерыванию
    procedure FOnTaskAbort;

  private
    { Private declarations }
    LibHandle: THandle;
    Thread: TThread;
    EntriesList: TResultEntiesSearchList;
    SearchStringsList: TStringDynArray;
    Itm: TlistItem;

    // функция, подгружаемая из библиотеки
    SearchEntriesFunc: TSearchEntriesFunc;

    // сюда будем складывать кости
    Log: Tlog;
  public
    { Public declarations }

    TaskRecord: TTaskRecord;
    ProgressForm: TfmTaskProgress;
  end;

var
  FmSearchStringEntriesInFile: TFmSearchStringEntriesInFile;

implementation

{$R *.dfm}

uses
  UMain, USelectDirectory;


procedure TFmSearchStringEntriesInFile.FormCreate(Sender: TObject);
begin
  EntriesList := TList<TEntriesRecort>.create;

  // создаём логи
  Log := TLog.Create(GetlogFileName('SearchEntries'), MemoLog);
end;

procedure TFmSearchStringEntriesInFile.FormDestroy(Sender: TObject);
begin
  EntriesList.free;
  Log.Free;
end;

procedure TFmSearchStringEntriesInFile.BtnCloseClick(Sender: TObject);
begin
  close;
end;


// выбор файла для сканирования вхождений строк
procedure TFmSearchStringEntriesInFile.sbGetFilePathClick(Sender: TObject);
var
  dir: WideString;
  res : Integer;
begin
  if Length(EdFilePath.text) > 0 then
  begin
    dir := ExtractFilePath(EdFilePath.text);
    if not DirectoryExists(dir) then
      dir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  end
  else
    dir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

  ForceDirectories(dir);

  // показываем пользователю окно выбора каталога и файлов
  SelectDirectory.DirectoryListBox.Directory := dir;
  res := SelectDirectory.ShowModal;

  // файл выбран (выбор идёт по двойному щелчку или кнопкой ОК)
  if (res = MrOk) then
    EdFilePath.text := SelectDirectory.FileListBox.FileName;
end;


// старт поиска
procedure TFmSearchStringEntriesInFile.BtnSearchEntriesClick(Sender: TObject);
var
  i: integer;
begin
  // очищаем результаты
  LbResults.Clear;
  LblEntriesCount.Caption := '0';

  // код дублируется, некрасиво, но оставим пока так
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

  Log.AddMes('Начато выполнение задачи "' + Itm.caption + '"');
  Log.AddMes('стартовая папка "' + EdFilePath.Text + '"');
  Log.AddMes('строка(строки) поиска "' + edSubStrForSearch.Text + '"');

  // показываем окно процесса выполнения
  ProgressForm := TfmTaskProgress.Create(self);
  ProgressForm.LblTaskDescription.Caption := TaskRecord.TaskFunctionDescription;
  ProgressForm.OnTaskAbort := FOnTaskAbort;
  ProgressForm.BtnAbortTask.enabled := false;
  ProgressForm.show;

  // поиск выполняем в потоке
  Thread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        LibHandle := LoadLibrary('TestJobDLL1.dll');

        if LibHandle <> 0 then
        begin
          SearchEntriesFunc := GetProcAddress(LibHandle, PwideChar(TaskRecord.TaskFunctionName)); //'FindByteArrayInFile'

          if Assigned(SearchEntriesFunc) then
          begin
            setlength(SearchStringsList, 0);
            // получим список строк для поиска вхождений этих строк в файле, строки должны разделяться запятыми
            SearchStringsList := GetStringsArrayFromString(edSubStrForSearch.text, ',');
            // поиск вхождений, список найденных вхождений по всем строкам поиска - EntriesList
            SearchEntriesFunc(EdFilePath.Text, SearchStringsList, EntriesList);

            // синхронизируем с VCL вывод результата
            TThread.Synchronize(nil,
              procedure
              begin
                FOnTaskDone;
              end);
          end;
        end;

      finally
        SearchEntriesFunc := nil;
        FreeLibrary(LibHandle);
      end;
    end);

  Thread.FreeOnTerminate := True;
  Thread.Start;
end;


// штатное завершение задачи
procedure TFmSearchStringEntriesInFile.FOnTaskDone;
var
  i, j: integer;
  LogStr: string;

begin
  // изменим статус выполнения
  if Assigned(Itm) then
  begin
    Itm.SubItems[0] := 'выполнено (' +
                       IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' сек)';
    Itm.SubItems[1] := DateTimeTostr(Now);

    Log.AddMes('Закончено выполнение задачи "' + Itm.caption + '"');

  end;
  Application.ProcessMessages;

  // заполняем список найденных файлов
  LbResults.Clear;
  for I := 0 to EntriesList.Count - 1 do
  begin
    // искомая строка
    LogStr := 'Строка поиска : ' + EntriesList.items[I].Searchstring +
              ', вхождений : ' +
              IntToStr(Length(EntriesList.items[I].ResultsArray));
    LbResults.Items.Add(LogStr);
    Log.AddMes(LogStr);

    // результаты вхождений для искомой строки
    for j := 0 to Length(EntriesList.items[I].ResultsArray) - 1 do
    begin
      LogStr := 'в позиции : ' + IntToStr(EntriesList.items[I].ResultsArray[j]);
      LbResults.Items.Add(LogStr);
      Log.AddMes(LogStr);
    end;

    Log.AddMes('');
  end;
  Application.ProcessMessages;

  // сколько строк введено для поиска
  LblEntriesCount.Caption := IntToStr(EntriesList.Count);

  // закрываем форму процесса выполнения задачи
  if assigned(ProgressForm) then
  begin
    ProgressForm.close;
    FreeAndNil(ProgressForm);
  end;

  // показываем результат
  PC_SearchEntries.TabIndex := 1;
end;

// завершение задачи по прерыванию
// метод уничтожения потока РАБОТАЕТ НЕКОРРЕКТНО,
// закрытие главной формы вызывает глобальный ERROR
procedure TFmSearchStringEntriesInFile.FOnTaskAbort;
begin
{  if assigned(ProgressForm) then
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

  // меняем статус выпалнения задачи
  if assigned(Itm) then
  begin
    Itm.SubItems[0] := 'прервано';
    Itm.SubItems[1] := DateTimeToStr(Now);

    Log.AddMes('Выполнение задачи "' + Itm.caption + '" прервано');
  end;

  // очищаем разультат поиска
  lbResults.Clear;
  LblEntriesCount.Caption := '0';}
end;

end.
