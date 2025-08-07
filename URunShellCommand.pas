unit URunShellCommand;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.DateUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Buttons,

  UAppTypes, UTaskProgress, Ulog
  ;

type
  TFmRunShellCommand = class(TForm)
    BtnRunCommand: TButton;
    EdCommandLine: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    LB_EnteredCommands: TListBox;
    BtnClose: TButton;
    Label3: TLabel;
    BtnClearCommandsList: TButton;
    PC_ShellCommand: TPageControl;
    TS1_RunCommandLine: TTabSheet;
    TS2_RunCommandsResults: TTabSheet;
    LBResults: TListBox;
    BtnClearResulrsList: TButton;
    EdDirPath: TEdit;
    sbGetDirPath: TSpeedButton;
    Label4: TLabel;
    TS3_Logs: TTabSheet;
    MemoLog: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnClearCommandsListClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnClearResulrsListClick(Sender: TObject);
    procedure sbGetDirPathClick(Sender: TObject);
    procedure LB_EnteredCommandsClick(Sender: TObject);

    procedure BtnRunCommandClick(Sender: TObject);
    procedure Async_ExecuteCommand(const CommandLine: string; OnProcessCompletion: TOnProcessCompletion);

  private
    { Private declarations }
    Itm: TlistItem;
    LibHandle: Thandle;
    Thread: TThread;

    // функция, подгружаемая из библиотеки
    ExecuteCommand: TExecuteCommand;
    // сюда будем складывать кости
    Log: Tlog;

    procedure FProcessCompletion(ExitCode: Dword);

  public
    { Public declarations }
    TaskRecord: TTaskRecord;
    ProgressForm: TfmTaskProgress;

    OnProcessCompletion: TOnProcessCompletion;

  end;

var
  FmRunShellCommand: TFmRunShellCommand;


implementation

{$R *.dfm}

Uses
  UMain, USelectDirectory;

// процедура обработки окончания выполнения запущенного процесса
procedure TFmRunShellCommand.FProcessCompletion(ExitCode: Dword);
var
  LogStr: string;
begin
  Log.AddMes('Закончено выполнение задачи "' + Itm.caption + '"');

  Application.ProcessMessages;

  // заполняем список результатов

  case ExitCode of
    0 : // успешно
      begin
        LogStr := 'Команда : ' + EdCommandLine.text + ' выполнена успешно.';
        LbResults.Items.Add(LogStr);
        Log.AddMes(LogStr);

        // изменим статус выполнения на главной форме
        if Assigned(Itm) then
        begin
          Itm.SubItems[0] := 'выполнено (' +
                             IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' сек)';
          Itm.SubItems[1] := DateTimeTostr(Now);
        end;
      end;
    65535:
      begin
        LogStr := 'Команда : ' + EdCommandLine.text + ' выполнена с ошибкой.';
        LbResults.Items.Add(LogStr);
        Log.AddMes(LogStr);

        LogStr := 'ошибка создания процесса : ' + IntToStr(ExitCode);
        LbResults.Items.Add(LogStr);
        Log.AddMes(LogStr);

        // изменим статус выполнения на главной форме
        if Assigned(Itm) then
        begin
          Itm.SubItems[0] := 'ОШИБКА! (' +
                             IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' сек)';
          Itm.SubItems[1] := DateTimeTostr(Now);
        end;

      end;
    else
    begin
      LogStr := 'Команда : ' + EdCommandLine.text + ' выполнена с ошибкой.';
      LbResults.Items.Add(LogStr);
      Log.AddMes(LogStr);

      LogStr := 'код ошибки : ' + IntToStr(ExitCode);
      LbResults.Items.Add(LogStr);
      Log.AddMes(LogStr);


      // изменим статус выполнения на главной форме
      if Assigned(Itm) then
      begin
        Itm.SubItems[0] := 'ОШИБКА! (' +
                           IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' сек)';
        Itm.SubItems[1] := DateTimeTostr(Now);
      end;
    end;
  end;

  Log.AddMes('');

  Application.ProcessMessages;

   // закрываем форму процесса выполнения задачи
  ProgressForm.close;
  FreeAndNil(ProgressForm);

  // показываем результат
  PC_ShellCommand.TabIndex := 1;
  Show;
end;






procedure TFmRunShellCommand.FormCreate(Sender: TObject);
begin
  OnProcessCompletion := FProcessCompletion;

  // создаём логи
  Log := TLog.Create(GetlogFileName('RunShell'), MemoLog);
end;

procedure TFmRunShellCommand.FormDestroy(Sender: TObject);
begin
  Log.free;
end;

procedure TFmRunShellCommand.BtnClearCommandsListClick(Sender: TObject);
begin
  LB_EnteredCommands.clear;
end;

procedure TFmRunShellCommand.BtnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TFmRunShellCommand.BtnClearResulrsListClick(Sender: TObject);
begin
  LBResults.Clear;
end;

// выбор рабочей директории
procedure TFmRunShellCommand.sbGetDirPathClick(Sender: TObject);
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

// установим выбранную строку из списка в поле ввода команды
procedure TFmRunShellCommand.LB_EnteredCommandsClick(Sender: TObject);
begin
  if LB_EnteredCommands.ItemIndex >= 0 then
    EdCommandLine.text := LB_EnteredCommands.items[LB_EnteredCommands.ItemIndex];
end;


// выполнение CLI - команды
procedure TFmRunShellCommand.BtnRunCommandClick(Sender: TObject);
var
  I: Integer;
  dir: string;
  ExitCode: Dword;
begin
  // прячем форму
  close;

  // установим рабочую директорию
  if Length(EdDirPath.text) > 0 then
  begin
    dir := EdDirPath.text;
    if not DirectoryExists(dir) then
      dir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  end
  else
    dir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  setcurrentdir(dir);
  EdDirPath.text := dir;

  // добавляем команду в список введённых команд
  LB_EnteredCommands.items.add(EdCommandLine.Text);

  // код дублируется, некрасиво, но оставим пока так
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
  Log.AddMes('рабочая папка "' + EdDirPath.Text + '"');
  Log.AddMes('команда для выполнения "' + EdCommandLine.Text + '"');

  // показываем окно процесса выполнения
  ProgressForm := TfmTaskProgress.Create(self);
  ProgressForm.LblTaskDescription.Caption := TaskRecord.TaskFunctionDescription;
  ProgressForm.OnTaskAbort := nil;
  ProgressForm.BtnAbortTask.enabled := false;

  ProgressForm.show;

  // запуск команды выполняем в потоке
  // если поток реализовать в теле процедуры, то при вызове из DLL возникает глобальный ERROR
  // возможно это связано с реализованной конструкцией освобождения
  // динамического ресурса загруженной библиотеки - не проверял
  Thread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        LibHandle := LoadLibrary('TestJobDLL2.dll');

        if LibHandle <> 0 then
        begin
          ExecuteCommand := GetProcAddress(LibHandle, PwideChar(TaskRecord.TaskFunctionName));

          // при вызове из DLL с callback функцией тоже вызывает ошибку (5 - отказано в доступе)
          // в причинах пока не разобрался
          // if Assigned(AsyncExecuteCommandCB) then
             // выполнение команды с потоком в теле процедуры
          //   AsyncExecuteCommandCB(EdCommandLine.Text, OnProcessCompletion);

          // будем вызывать с простым передаваемым параметром
          if Assigned(ExecuteCommand) then
            ExecuteCommand(EdCommandLine.Text, ExitCode);

          // синхронизируем с VCL вывод результата
          TThread.Synchronize(nil,
            procedure
            begin
              FProcessCompletion(ExitCode);
            end);
        end;

      finally
        ExecuteCommand := nil;
        FreeLibrary(LibHandle);
      end;
    end);

  Thread.FreeOnTerminate := True;
  Thread.Start;
end;


// метод выполнения с Callback уведомлением локально - контрольная закупка
procedure TFmRunShellCommand.Async_ExecuteCommand(const CommandLine: string;
                                                  OnProcessCompletion: TOnProcessCompletion);
var
  Thread: TThread;
begin
  Thread := TThread.CreateAnonymousThread(
    procedure
    var
      StartupInfo: TStartupInfo;
      ProcessInfo: TProcessInformation;
      ExitCode: DWORD;
      Result: boolean;

    begin
      FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
      StartupInfo.cb := SizeOf(TStartupInfo);
      StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
      StartupInfo.wShowWindow := SW_HIDE;

      ExitCode := 65535;

      result := CreateProcess(nil, PChar(string(CommandLine)), nil, nil, False,
                CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil,
                StartupInfo, ProcessInfo);

      if result then
      begin
        try
          WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

        finally
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
        end;
      end;

      // Вызываем callback в основном потоке
      TThread.Synchronize(nil,
        procedure
        begin
          if Assigned(OnProcessCompletion) then
            OnProcessCompletion(ExitCode);
        end);

    end);

  Thread.FreeOnTerminate := True;
  Thread.Start;
end;

end.
