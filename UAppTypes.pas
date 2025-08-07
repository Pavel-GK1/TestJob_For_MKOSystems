unit UAppTypes;


interface

uses
  System.Types, System.SysUtils, System.Classes,
  Generics.Collections,
  VCL.Forms
;

Const
  PossibleTaskCount = 6;

  NumTaskSearchFiles = 0;
  NumTaskFindStringInFile = 1;
  NumTaskFindByteArrayInFile = 2;
  NumTaskExecuteCommand = 3;
  NumTaskAsyncExecuteCommandCB = 4;
  NumTaskExecuteSE = 5;

  // для возможной организации списков выполненых работ или логов
  TaskIsUndefined   = 0;
  TaskInProgress    = 1;
  TaskIsDone        = 2;

type
  // массив позиций вхождений для строки поиска
  TInt64Array = array of int64;

  // рекорд для поиска вхождений строки в файле
  TEntriesRecort = record
    Searchstring: string;           // искомая строка
    SearchBytesArray: Tbytes;       // массив символов строки поиска в байтах
    ResultsArray: TInt64Array;      // массив позиций вхождений строки поиска
  end;

  // список результатов поиска вхождений для каждой введённой строки поиска
  TResultEntiesSearchList = Tlist<TEntriesRecort>;


  // для функции обратного вызова при выполнении внешней крманды
  TOnProcessCompletion = procedure(ExitCode: DWORD) of object;

  // обработчик события закрытия формы для владельца закрываемой формы
  TOnTaskAbort = procedure of object;




  // типы для рутин, которые могут быть подгружены из библиотек
  // -------------------------------------------------------
Type
  // список импортируемых из DLL рутин
  TGetJobsListInLibrary = Function(DllName: string): TStringDynArray; stdcall;

  // поиск файлов в директории по нескольким маскам
  TSearchFilesFunc = Function(StartDir : string; Masks: TStringDynArray;
                     out OutFiles: TstringList): boolean; stdcall;

  // поиск файлов в директории с одной маской
  TSearchFilesFuncSingleMask = function(StartDir : string; Mask: string): string; stdcall;

  // поиск вхождений строки в файле
  TSearchStringsEntriesFunc = function(const FileName, SearchString: string): Boolean; stdcall;

  // поиск вхождений нескольких строк в файле по массиву байт строки
  TSearchEntriesFunc = Function(const FileName: string; const SearchArray: TStringDynArray;
                                out EntriesList: TResultEntiesSearchList): Boolean; stdcall;

  // поиск вхождений строки в файле по массиву байт строки
  TSearchByteArrayEntriesFunc = Function(const FileName: string;
                                const SearchArray: array of Byte): TInt64Array stdcall;

  // выполнение внешней команды
  TExecuteCommand = function(const CommandLine: string;
                             out ExitCode: DWORD): Boolean; stdcall;
  // выполнение внешней команды с callback вызовом
  TAsyncExecuteCommandCB = Procedure(const CommandLine: string;
                                     OnProcessCompletion: TOnProcessCompletion) stdcall;

  TExecuteSE = function(const CommandLine: string;
                        out ExitCode: DWORD): Boolean; stdcall;
  // -------------------------------------------------------



  // ВОЗМОЖНЫЕ ТИПЫ ЗАДАЧ
  TtaskTypes = (task_SearchFiles, task_FindStringInFile, task_FindByteArrayInFile,
                task_ExecuteCommand, task_AsyncExecuteCommandCB, task_ExecuteSE);

  // СПИСОК ЗАДАЧ ДЛЯ ВОЗМОЖНОГО ОТОБРАЖЕНИЯ ГДЕ-ЛИБО
  TtaskList = set of TtaskTypes;

  // СТРУКТУРА ЭЛЕМЕНТА СПИСКА ЗАДАЧ
  TtaskRecord = record
    NumTask: Integer; // номер запускаемой задачи
    Task: TtaskTypes; // тип запускаемой задачи
    TaskStatus: byte; // задача завершена
    TaskFunctionName, // название функции для выпонения
    TaskFunctionDescription: string; // описание задачи для списков отображения
    FromDll: string;
    IsAvailable : boolean;
  end;


var
  // описания всех задач
  allTasksDescription: array [0..PossibleTaskCount-1] of TTaskRecord =
    (
      ( NumTask: NumTaskSearchFiles; Task: task_SearchFiles;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'SearchFiles';
        TaskFunctionDescription: 'Задача поиска списка файлов по маске в папках';
        FromDll: 'TestJobDLL1'; IsAvailable: true),

      ( NumTask: NumTaskFindStringInFile; Task: task_FindStringInFile;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'FindStringInFile';
        TaskFunctionDescription: 'Задача поиска вхождений строки в текстовом файле';
        FromDll: 'TestJobDLL1'; IsAvailable: false),

      ( NumTask: NumTaskFindByteArrayInFile; Task: task_FindByteArrayInFile;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'FindByteArrayInFile';
        TaskFunctionDescription: 'Задача поиска вхождений последовательности символов(строки) в файле';
        FromDll: 'TestJobDLL1'; IsAvailable: True),

      ( NumTask: NumTaskExecuteCommand; Task: task_ExecuteCommand;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'ExecuteCommand';
        TaskFunctionDescription: 'Задача выполнения CLI-команды';
        FromDll: 'TestJobDLL2'; IsAvailable: True),

      ( NumTask: NumTaskAsyncExecuteCommandCB; Task: task_AsyncExecuteCommandCB;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'AsyncExecuteCommandCB';
        TaskFunctionDescription: 'Задача выполнения CLI-команды с callback вызовом';
        FromDll: 'TestJobDLL2'; IsAvailable: False ),

      ( NumTask: NumTaskExecuteSE; Task: task_ExecuteSE;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'ExecuteSE';
        TaskFunctionDescription: 'Задача выполнения команды методом ShellExecuteEx';
        FromDll: 'TestJobDLL2'; IsAvailable: False )
    );


// формируем из строки список подстрок
function GetStringsArrayFromString(InputsString, Delimiter: String): TStringDynArray;
Function GetlogFileName(ForTask: string): string;



implementation


Function GetlogFileName(ForTask: string): string;
Var
  FlogFileName,
  tempFileName,
  FlogFileDir: string;
begin
  // ПАПКА И ФАЙЛ ДЛЯ ЛОГОВ
  // извлекаем имя экзешника
  tempFileName := ExtractFileName( Application.ExeName );
  // убираем расширение
  setlength(tempFileName, length(tempFileName) - 4);
  // извлекаем директорию
  FlogFileDir := ExtractFileDir(Application.ExeName);
  // получаем целевую директорию
  FlogFileDir := FlogFileDir + '\' + tempFileName +  'Log';
  // создаём целевую директорию
  if not DirectoryExists(FlogFileDir) then
    CreateDir(FlogFileDir);
  // получаем полное целевое имя файла
  FlogFileName := FlogFiledir + '\log' + ForTask + FormatDateTime('yyyymmdd', Now) + '.txt';

  result := FlogFileName;
end;


// формируем из строки список подстрок
function GetStringsArrayFromString(InputsString, Delimiter: String): TStringDynArray;
var
  DelimiterPos: Integer;
  ResultArray: TStringDynArray;
  TempInputsString, TempSubString: string;
begin
  SetLength(ResultArray, 0);
  TempInputsString := InputsString;

  if Length(TempInputsString) > 0 then
    repeat
      DelimiterPos := Pos(Delimiter, TempInputsString);

      If DelimiterPos > 0 then
      begin
        // выделяем в маску из строки масок подстроку до разделителя
        TempSubString := TrimLeft(TrimRight(Copy(TempInputsString, 0, DelimiterPos - 1)));

        // добавляем в массив если не пустая строка
        if Length(TempSubString) > 0 then
        begin
          SetLength(ResultArray, Length(ResultArray) + 1);
          ResultArray[Length(ResultArray) - 1] := TempSubString;
        end;

        // копируем в стоку всё что есть после разделителя
        TempInputsString := Copy(TempInputsString, DelimiterPos + 1,
                                     Length(TempInputsString) - DelimiterPos);
      end else
      // нет разделителей или они кончились
      // добавляем в массив если не пустая строка
      if Length(TrimLeft(TrimRight(TempInputsString))) > 0 then
      begin
        SetLength(ResultArray, Length(ResultArray) + 1);
        ResultArray[Length(ResultArray) - 1] := TrimLeft(TrimRight(TempInputsString));
      end;
    until DelimiterPos = 0
  else
    begin // маска на все файлы, если строка масок введена пустой
      SetLength(ResultArray, 1);
      ResultArray[0] := '*.*';
    end;

  Result := ResultArray;
end;

end.
