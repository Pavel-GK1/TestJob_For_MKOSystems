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

  // ������ ��� ������ ��������� ������ � �����
  TEntriesRecort = record
    Searchstring: string;           // ������� ������
    SearchBytesArray: Tbytes;       // ������ �������� ������ ������ � ������
    ResultsArray: TInt64Array;      // ������ ������� ��������� ������ ������
  end;

  // ������ ����������� ������ ��������� ��� ������ �������� ������ ������
  TResultEntiesSearchList = Tlist<TEntriesRecort>;


  TSearchFilesFunc = Function(StartDir : string; Mask: TStringDynArray): TStringDynArray stdcall;
//  SearchFilesFunc = function(Mask, StartDir : string): string; stdcall;

  TSearchEntriesFunc = Function(const FileName: string; const SearchArray: TStringDynArray;
                                out EntriesList: TResultEntiesSearchList): Boolean; stdcall;
//  TSearchEntriesFunc = Function(const FileName: string;
//                                const SearchArray: array of Byte): TInt64Array stdcall;

  TGetJobsListInLibrary = Function: TStringDynArray; stdcall;



  // ��������� ���� �����
  TtaskTypes = (task_SearchFiles, task_FindStringInFile, task_FindByteArrayInFile,
                task_ExecuteCommand_Async);

  // ������ ����� ��� ���������� ����������� ���-����
  TtaskList = set of TtaskTypes;

  // ��������� �������� ������ �����
  TtaskRecord = record
    NumTask: Integer; // ����� ����������� ������
    Task: TtaskTypes; // ��� ����������� ������
    TaskStatus: byte; // ������ ���������
    TaskFunctionName, // �������� ������� ��� ���������
    TaskFunctionDescription: string; // �������� ������ ��� ������� �����������
  end;

var
  allTasksDescription: array [0..PossibleTaskCount-1] of TTaskRecord =
    (
      ( NumTask: 0; Task: task_SearchFiles; TaskStatus: TaskIsUndefined;
        TaskFunctionName: 'SearchFiles';
        TaskFunctionDescription: '������ ������ ������ ������ �� ����� � ������'),

      ( NumTask: 1; Task: task_FindStringInFile; TaskStatus: TaskIsUndefined;
        TaskFunctionName: 'FindStringInFile';
        TaskFunctionDescription: '������ ������ ��������� ������ � ��������� �����'),

      ( NumTask: 2; Task: task_FindByteArrayInFile; TaskStatus: TaskIsUndefined;
        TaskFunctionName: 'FindByteArrayInFile';
        TaskFunctionDescription: '������ ������ ��������� ������������������ ��������(������) � �����'),

      ( NumTask: 3; Task: task_ExecuteCommand_Async; TaskStatus: TaskIsUndefined;
        TaskFunctionName: 'ExecuteCommand_Async';
        TaskFunctionDescription: '������ ���������� Shell-�������' )
    );



function GetFilesMasks(FilesMasksString, Delimiter: String): TStringDynArray;



implementation


// ��������� �� ������ ������ �����
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
        // �������� � ����� �� ������ ����� ��������� �� �����������
        TempMasksString := TrimLeft(TrimRight(Copy(TempFilesMasksString, 0, DelimiterPos - 1)));

        // ��������� � ������ ���� �� ������ ������
        if Length(TempMasksString) > 0 then
        begin
          SetLength(ResultArray, Length(ResultArray) + 1);
          ResultArray[Length(ResultArray) - 1] := TempMasksString;
        end;

        // �������� � ����� �� ��� ���� ����� �����������
        TempFilesMasksString := Copy(TempFilesMasksString, DelimiterPos + 1,
                                     Length(TempFilesMasksString) - DelimiterPos);
      end else
      // ��� ������������ ��� ��� ���������
      // ��������� � ������ ���� �� ������ ������
      if Length(TrimLeft(TrimRight(TempFilesMasksString))) > 0 then
      begin
        SetLength(ResultArray, Length(ResultArray) + 1);
        ResultArray[Length(ResultArray) - 1] := TrimLeft(TrimRight(TempFilesMasksString));
      end;
    until DelimiterPos = 0
  else
    begin // ����� �� ��� �����, ���� ������ ����� ������� ������
      SetLength(ResultArray, 1);
      ResultArray[0] := '*.*';
    end;

  Result := ResultArray;
end;

end.
