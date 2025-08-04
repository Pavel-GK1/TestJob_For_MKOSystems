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


type
  TProcessCompletionCallback = procedure(ExitCode: DWORD) of object;


Function GetTasksListInLibrary: TStringDynArray; stdcall;
var
  TasksList: TStringDynArray;
begin
  setLength(TasksList,1);

  TasksList[0] := allTasksDescription[3].TaskFunctionDescription;

  result := TasksList;
end;


// метод через CreateProcess
function ExecuteCommand_And_Wait(const CommandLine: string; out ExitCode: DWORD): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE; // или SW_SHOW дл€ видимого окна

  Result := CreateProcess(nil, PChar(CommandLine), nil, nil, False,
    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);

  if Result then
  begin
    try
      // ∆дем завершени€ процесса
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      // ѕолучаем код возврата
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
    finally
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;
  end;
end;


// метод асинхронного выполнени€ с Callback уведомлением
procedure ExecuteCommand_Async(const CommandLine: string; Callback: TProcessCompletionCallback);
var
  Thread: TThread;
begin
  Thread := TThread.CreateAnonymousThread(
    procedure
    var
      StartupInfo: TStartupInfo;
      ProcessInfo: TProcessInformation;
      ExitCode: DWORD;
    begin
      FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
      StartupInfo.cb := SizeOf(TStartupInfo);
      StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
      StartupInfo.wShowWindow := SW_HIDE;

      if CreateProcess(nil, PChar(CommandLine), nil, nil, False,
        CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then
      begin
        try
          WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

          // ¬ызываем callback в основном потоке
          TThread.Synchronize(nil,
            procedure
            begin
              if Assigned(Callback) then
                Callback(ExitCode);
            end);
        finally
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
        end;
      end;
    end);

  Thread.FreeOnTerminate := True;

  Thread.Start;
end;


// метод с использованием ShellExecuteEx с уведомлением
function Execute_And_Wait(const CommandLine: string; out ExitCode: DWORD): Boolean;
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
//  ExecuteCommand_And_Wait,
  ExecuteCommand_Async
//,  Execute_And_Wait
  ;

begin
end.

