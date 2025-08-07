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

  // ��� ��������� ����������� ������� ���������� ����� ��� �����
  TaskIsUndefined   = 0;
  TaskInProgress    = 1;
  TaskIsDone        = 2;

type
  // ������ ������� ��������� ��� ������ ������
  TInt64Array = array of int64;

  // ������ ��� ������ ��������� ������ � �����
  TEntriesRecort = record
    Searchstring: string;           // ������� ������
    SearchBytesArray: Tbytes;       // ������ �������� ������ ������ � ������
    ResultsArray: TInt64Array;      // ������ ������� ��������� ������ ������
  end;

  // ������ ����������� ������ ��������� ��� ������ �������� ������ ������
  TResultEntiesSearchList = Tlist<TEntriesRecort>;


  // ��� ������� ��������� ������ ��� ���������� ������� �������
  TOnProcessCompletion = procedure(ExitCode: DWORD) of object;

  // ���������� ������� �������� ����� ��� ��������� ����������� �����
  TOnTaskAbort = procedure of object;




  // ���� ��� �����, ������� ����� ���� ���������� �� ���������
  // -------------------------------------------------------
Type
  // ������ ������������� �� DLL �����
  TGetJobsListInLibrary = Function(DllName: string): TStringDynArray; stdcall;

  // ����� ������ � ���������� �� ���������� ������
  TSearchFilesFunc = Function(StartDir : string; Masks: TStringDynArray;
                     out OutFiles: TstringList): boolean; stdcall;

  // ����� ������ � ���������� � ����� ������
  TSearchFilesFuncSingleMask = function(StartDir : string; Mask: string): string; stdcall;

  // ����� ��������� ������ � �����
  TSearchStringsEntriesFunc = function(const FileName, SearchString: string): Boolean; stdcall;

  // ����� ��������� ���������� ����� � ����� �� ������� ���� ������
  TSearchEntriesFunc = Function(const FileName: string; const SearchArray: TStringDynArray;
                                out EntriesList: TResultEntiesSearchList): Boolean; stdcall;

  // ����� ��������� ������ � ����� �� ������� ���� ������
  TSearchByteArrayEntriesFunc = Function(const FileName: string;
                                const SearchArray: array of Byte): TInt64Array stdcall;

  // ���������� ������� �������
  TExecuteCommand = function(const CommandLine: string;
                             out ExitCode: DWORD): Boolean; stdcall;
  // ���������� ������� ������� � callback �������
  TAsyncExecuteCommandCB = Procedure(const CommandLine: string;
                                     OnProcessCompletion: TOnProcessCompletion) stdcall;

  TExecuteSE = function(const CommandLine: string;
                        out ExitCode: DWORD): Boolean; stdcall;
  // -------------------------------------------------------



  // ��������� ���� �����
  TtaskTypes = (task_SearchFiles, task_FindStringInFile, task_FindByteArrayInFile,
                task_ExecuteCommand, task_AsyncExecuteCommandCB, task_ExecuteSE);

  // ������ ����� ��� ���������� ����������� ���-����
  TtaskList = set of TtaskTypes;

  // ��������� �������� ������ �����
  TtaskRecord = record
    NumTask: Integer; // ����� ����������� ������
    Task: TtaskTypes; // ��� ����������� ������
    TaskStatus: byte; // ������ ���������
    TaskFunctionName, // �������� ������� ��� ���������
    TaskFunctionDescription: string; // �������� ������ ��� ������� �����������
    FromDll: string;
    IsAvailable : boolean;
  end;


var
  // �������� ���� �����
  allTasksDescription: array [0..PossibleTaskCount-1] of TTaskRecord =
    (
      ( NumTask: NumTaskSearchFiles; Task: task_SearchFiles;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'SearchFiles';
        TaskFunctionDescription: '������ ������ ������ ������ �� ����� � ������';
        FromDll: 'TestJobDLL1'; IsAvailable: true),

      ( NumTask: NumTaskFindStringInFile; Task: task_FindStringInFile;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'FindStringInFile';
        TaskFunctionDescription: '������ ������ ��������� ������ � ��������� �����';
        FromDll: 'TestJobDLL1'; IsAvailable: false),

      ( NumTask: NumTaskFindByteArrayInFile; Task: task_FindByteArrayInFile;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'FindByteArrayInFile';
        TaskFunctionDescription: '������ ������ ��������� ������������������ ��������(������) � �����';
        FromDll: 'TestJobDLL1'; IsAvailable: True),

      ( NumTask: NumTaskExecuteCommand; Task: task_ExecuteCommand;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'ExecuteCommand';
        TaskFunctionDescription: '������ ���������� CLI-�������';
        FromDll: 'TestJobDLL2'; IsAvailable: True),

      ( NumTask: NumTaskAsyncExecuteCommandCB; Task: task_AsyncExecuteCommandCB;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'AsyncExecuteCommandCB';
        TaskFunctionDescription: '������ ���������� CLI-������� � callback �������';
        FromDll: 'TestJobDLL2'; IsAvailable: False ),

      ( NumTask: NumTaskExecuteSE; Task: task_ExecuteSE;
        TaskStatus: TaskIsUndefined; TaskFunctionName: 'ExecuteSE';
        TaskFunctionDescription: '������ ���������� ������� ������� ShellExecuteEx';
        FromDll: 'TestJobDLL2'; IsAvailable: False )
    );


// ��������� �� ������ ������ ��������
function GetStringsArrayFromString(InputsString, Delimiter: String): TStringDynArray;
Function GetlogFileName(ForTask: string): string;



implementation


Function GetlogFileName(ForTask: string): string;
Var
  FlogFileName,
  tempFileName,
  FlogFileDir: string;
begin
  // ����� � ���� ��� �����
  // ��������� ��� ���������
  tempFileName := ExtractFileName( Application.ExeName );
  // ������� ����������
  setlength(tempFileName, length(tempFileName) - 4);
  // ��������� ����������
  FlogFileDir := ExtractFileDir(Application.ExeName);
  // �������� ������� ����������
  FlogFileDir := FlogFileDir + '\' + tempFileName +  'Log';
  // ������ ������� ����������
  if not DirectoryExists(FlogFileDir) then
    CreateDir(FlogFileDir);
  // �������� ������ ������� ��� �����
  FlogFileName := FlogFiledir + '\log' + ForTask + FormatDateTime('yyyymmdd', Now) + '.txt';

  result := FlogFileName;
end;


// ��������� �� ������ ������ ��������
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
        // �������� � ����� �� ������ ����� ��������� �� �����������
        TempSubString := TrimLeft(TrimRight(Copy(TempInputsString, 0, DelimiterPos - 1)));

        // ��������� � ������ ���� �� ������ ������
        if Length(TempSubString) > 0 then
        begin
          SetLength(ResultArray, Length(ResultArray) + 1);
          ResultArray[Length(ResultArray) - 1] := TempSubString;
        end;

        // �������� � ����� �� ��� ���� ����� �����������
        TempInputsString := Copy(TempInputsString, DelimiterPos + 1,
                                     Length(TempInputsString) - DelimiterPos);
      end else
      // ��� ������������ ��� ��� ���������
      // ��������� � ������ ���� �� ������ ������
      if Length(TrimLeft(TrimRight(TempInputsString))) > 0 then
      begin
        SetLength(ResultArray, Length(ResultArray) + 1);
        ResultArray[Length(ResultArray) - 1] := TrimLeft(TrimRight(TempInputsString));
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
