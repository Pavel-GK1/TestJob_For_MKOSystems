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



  // ��������� ���� �����
  TtaskTypes = (task_SearchFiles, task_FindStringInFile, task_FindByteArrayInFile,
                task_ExecuteCommand_Async);

  // ������ ����� ��� ���������� ����������� ���-����
  TtaskList = set of TtaskTypes;

  // ��������� �������� ������ �����
  TtaskDescription = record
    NumTask: Integer; // ����� ����������� ������
    Task: TtaskTypes; // ��� ����������� ������
    TaskStatus: byte; // ������ ���������
    TaskFunctionName, // �������� ������� ��� ���������
    TaskFunctionDescription: string; // �������� ������ ��� ������� �����������
  end;

var
  allTasksDescription: array [0..PossibleTaskCount-1] of TTaskDescription =
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



implementation

end.
