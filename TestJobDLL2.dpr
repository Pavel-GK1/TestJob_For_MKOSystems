library TestJobDLL2;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.

  Important note about VCL usage: when this DLL will be implicitly
  loaded and this DLL uses TWicImage / TImageCollection created in
  any unit initialization section, then Vcl.WicImageInit must be
  included into your library's USES clause. }

uses
  ShareMem,
  System.SysUtils,
  System.Classes,
  System.Types,
  Windows,ShellAPI,
  UappTypes;

{$R *.res}


// Не будем мудрствовать, возьмём списки экспортируемых из DLL функций
// из специально подготовленных рутин в библиотеках
// код дублируется, некрасиво, но пока оставим так
Function GetTasksListInLibrary(DllName: string): TStringDynArray; stdcall;
var
  TasksList: TStringDynArray;
  i: Integer;
begin
  setLength(TasksList, 0);

  For i:= 0 to PossibleTaskCount- 1 do
  With allTasksDescription[i] do
  if FromDll = DllName then
  if IsAvailable then
  begin
    setLength(TasksList, Length(TasksList) + 1);
    TasksList[Length(TasksList) - 1] := allTasksDescription[i].TaskFunctionDescription;
  end;

  result := TasksList;
end;


// метод выполнения через CreateProcess
// с возаратом кода завершения
function ExecuteCommand(const CommandLine: string; out ExitCode: DWORD): Boolean; stdcall;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOW; // или SW_SHOW для видимого окна

  ExitCode := 65535;

  Result := CreateProcess(nil, PwideChar(CommandLine), nil, nil, False,
                          CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil,
                          StartupInfo, ProcessInfo);
  if Result then
  begin
    try
      // Ждем завершения процесса
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      // Получаем код возврата
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

    finally
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;
  end;
end;


// метод асинхронного выполнения через CreateProcess
// в потоке с Callback уведомлением - как оказалось вызывает ошибку
procedure AsyncExecuteCommandCB(const CommandLine: string;
                                OnProcessCompletion: TOnProcessCompletion); stdcall;
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
      StartupInfo.wShowWindow := SW_SHOW;

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

    end
    );

  Thread.FreeOnTerminate := True;
  Thread.Start;
end;


// метод с использованием ShellExecuteEx с возвратом кода завершения
function ExecuteSE(const CommandLine: string; out ExitCode: DWORD): Boolean; stdcall;
var
  SEInfo: TShellExecuteInfo;
begin
  FillChar(SEInfo, SizeOf(SEInfo), 0);

  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  SEInfo.Wnd := 0;
  SEInfo.lpVerb := 'open';
  SEInfo.lpFile := PChar(CommandLine);
  SEInfo.lpParameters := nil;
  SEInfo.nShow := SW_SHOWNORMAL;

  Result := ShellExecuteEx(@SEInfo);
  if Result then
  begin
    try
      WaitForSingleObject(SEInfo.hProcess, INFINITE);
      GetExitCodeProcess(SEInfo.hProcess, ExitCode);
      // ExitCode содержит код возврата
    finally
      CloseHandle(SEInfo.hProcess);
    end;
  end;
end;




exports
  GetTasksListInLibrary,
  ExecuteCommand,
  AsyncExecuteCommandCB,
  ExecuteSE
  ;

begin
end.

