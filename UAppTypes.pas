unit UAppTypes;


interface

uses System.Types;

Const
  PossibleTaskCount = 4;
  TaskIsUndefined   = 0;
  TaskInProgress    = 1;
  TaskIsDone        = 2;

type
  TInt64Array = array of int64;

  TSearchFilesFunc = Function(StartDir : string; Mask: TStringDynArray): TStringDynArray stdcall;
//  SearchFilesFunc = function(Mask, StartDir : string): string; stdcall;

  TSearchEntriesFunc = Function(const FileName: string;
                                const SearchArray: array of Byte): TInt64Array stdcall;

  TGetJobsListInLibrary = Function: TStringDynArray; stdcall;



  // ВОЗМОЖНЫЕ ТИПЫ ЗАДАЧ
  TtaskTypes = (task_SearchFiles, task_FindStringInFile, task_FindByteArrayInFile,
                task_ExecuteCommand_Async);

  // СПИСОК ЗАДАЧ ДЛЯ ВОЗМОЖНОГО ОТОБРАЖЕНИЯ ГДЕ-ЛИБО
  TtaskList = set of TtaskTypes;

  // СТРУКТУРА ЭЛЕМЕНТА СПИСКА ЗАДАЧ
  TtaskDescription = record
    NumTask: Integer; // номер запускаемой задачи
    Task: TtaskTypes; // тип запускаемой задачи
    TaskStatus: byte; // задача завершена
    TaskFunctionName, // название функции для выпонения
    TaskFunctionDescription: string; // описание задачи для списков отображения
  end;

var
  allTasksDescription: array [0..PossibleTaskCount-1] of TTaskDescription =
    (
      ( NumTask: 0; Task: task_SearchFiles; TaskStatus: TaskIsUndefined;
        TaskFunctionName: 'SearchFiles';
        TaskFunctionDescription: 'Задача поиска списка файлов по маске в папках'),

      ( NumTask: 1; Task: task_FindStringInFile; TaskStatus: TaskIsUndefined;
        TaskFunctionName: 'FindStringInFile';
        TaskFunctionDescription: 'Задача поиска вхождений строки в текстовом файле'),

      ( NumTask: 2; Task: task_FindByteArrayInFile; TaskStatus: TaskIsUndefined;
        TaskFunctionName: 'FindByteArrayInFile';
        TaskFunctionDescription: 'Задача поиска вхождений последовательности символов(строки) в файле'),

      ( NumTask: 3; Task: task_ExecuteCommand_Async; TaskStatus: TaskIsUndefined;
        TaskFunctionName: 'ExecuteCommand_Async';
        TaskFunctionDescription: 'Задача выполнения Shell-команды' )
    );



implementation

end.
