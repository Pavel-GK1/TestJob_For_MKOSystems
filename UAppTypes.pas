unit UAppTypes;


interface

uses System.Types, System.SysUtils, Generics.Collections;

Const
  PossibleTaskCount = 4;
  TaskIsUndefined   = 0;
  TaskInProgress    = 1;
  TaskIsDone        = 2;

type
  TInt64Array = array of int64;

  // рекорд для поиска вхождений строки в файле
  TEntriesRecort = record
    Searchstring: string;           // искомая строка
    SearchBytesArray: Tbytes;       // массив символов строки поиска в байтах
    ResultsArray: TInt64Array;      // массив позиций вхождений строки поиска
  end;

  // список результатов поиска вхождений для каждой введённой строки поиска
  TResultEntiesSearchList = Tlist<TEntriesRecort>;


  TSearchFilesFunc = Function(StartDir : string; Mask: TStringDynArray): TStringDynArray stdcall;
//  SearchFilesFunc = function(Mask, StartDir : string): string; stdcall;

  TSearchEntriesFunc = Function(const FileName: string; const SearchArray: TStringDynArray;
                                out EntriesList: TResultEntiesSearchList): Boolean; stdcall;
//  TSearchEntriesFunc = Function(const FileName: string;
//                                const SearchArray: array of Byte): TInt64Array stdcall;

  TGetJobsListInLibrary = Function: TStringDynArray; stdcall;



  // ВОЗМОЖНЫЕ ТИПЫ ЗАДАЧ
  TtaskTypes = (task_SearchFiles, task_FindStringInFile, task_FindByteArrayInFile,
                task_ExecuteCommand_Async);

  // СПИСОК ЗАДАЧ ДЛЯ ВОЗМОЖНОГО ОТОБРАЖЕНИЯ ГДЕ-ЛИБО
  TtaskList = set of TtaskTypes;

  // СТРУКТУРА ЭЛЕМЕНТА СПИСКА ЗАДАЧ
  TtaskRecord = record
    NumTask: Integer; // номер запускаемой задачи
    Task: TtaskTypes; // тип запускаемой задачи
    TaskStatus: byte; // задача завершена
    TaskFunctionName, // название функции для выпонения
    TaskFunctionDescription: string; // описание задачи для списков отображения
  end;

var
  allTasksDescription: array [0..PossibleTaskCount-1] of TTaskRecord =
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



function GetFilesMasks(FilesMasksString, Delimiter: String): TStringDynArray;



implementation


// формируем из строки список масок
function GetFilesMasks(FilesMasksString, Delimiter: String): TStringDynArray;
var
  DelimiterPos: Integer;
  ResultArray: TStringDynArray;
  TempFilesMasksString, TempMasksString: string;
begin
  SetLength(ResultArray, 0);
  TempFilesMasksString := FilesMasksString;

  if Length(TempFilesMasksString) > 0 then
    repeat
      DelimiterPos := Pos(Delimiter, TempFilesMasksString);

      If DelimiterPos > 0 then
      begin
        // выделяем в маску из строки масок подстроку до разделителя
        TempMasksString := TrimLeft(TrimRight(Copy(TempFilesMasksString, 0, DelimiterPos - 1)));

        // добавляем в массив если не пустая строка
        if Length(TempMasksString) > 0 then
        begin
          SetLength(ResultArray, Length(ResultArray) + 1);
          ResultArray[Length(ResultArray) - 1] := TempMasksString;
        end;

        // копируем в стоку всё что есть после разделителя
        TempFilesMasksString := Copy(TempFilesMasksString, DelimiterPos + 1,
                                     Length(TempFilesMasksString) - DelimiterPos);
      end else
      // нет разделителей или они кончились
      // добавляем в массив если не пустая строка
      if Length(TrimLeft(TrimRight(TempFilesMasksString))) > 0 then
      begin
        SetLength(ResultArray, Length(ResultArray) + 1);
        ResultArray[Length(ResultArray) - 1] := TrimLeft(TrimRight(TempFilesMasksString));
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
