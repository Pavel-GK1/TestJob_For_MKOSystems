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

    // �������, ������������ �� ����������
    ExecuteCommand: TExecuteCommand;
    // ���� ����� ���������� �����
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

// ��������� ��������� ��������� ���������� ����������� ��������
procedure TFmRunShellCommand.FProcessCompletion(ExitCode: Dword);
var
  LogStr: string;
begin
  Log.AddMes('��������� ���������� ������ "' + Itm.caption + '"');

  Application.ProcessMessages;

  // ��������� ������ �����������

  case ExitCode of
    0 : // �������
      begin
        LogStr := '������� : ' + EdCommandLine.text + ' ��������� �������.';
        LbResults.Items.Add(LogStr);
        Log.AddMes(LogStr);

        // ������� ������ ���������� �� ������� �����
        if Assigned(Itm) then
        begin
          Itm.SubItems[0] := '��������� (' +
                             IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' ���)';
          Itm.SubItems[1] := DateTimeTostr(Now);
        end;
      end;
    65535:
      begin
        LogStr := '������� : ' + EdCommandLine.text + ' ��������� � �������.';
        LbResults.Items.Add(LogStr);
        Log.AddMes(LogStr);

        LogStr := '������ �������� �������� : ' + IntToStr(ExitCode);
        LbResults.Items.Add(LogStr);
        Log.AddMes(LogStr);

        // ������� ������ ���������� �� ������� �����
        if Assigned(Itm) then
        begin
          Itm.SubItems[0] := '������! (' +
                             IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' ���)';
          Itm.SubItems[1] := DateTimeTostr(Now);
        end;

      end;
    else
    begin
      LogStr := '������� : ' + EdCommandLine.text + ' ��������� � �������.';
      LbResults.Items.Add(LogStr);
      Log.AddMes(LogStr);

      LogStr := '��� ������ : ' + IntToStr(ExitCode);
      LbResults.Items.Add(LogStr);
      Log.AddMes(LogStr);


      // ������� ������ ���������� �� ������� �����
      if Assigned(Itm) then
      begin
        Itm.SubItems[0] := '������! (' +
                           IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' ���)';
        Itm.SubItems[1] := DateTimeTostr(Now);
      end;
    end;
  end;

  Log.AddMes('');

  Application.ProcessMessages;

   // ��������� ����� �������� ���������� ������
  ProgressForm.close;
  FreeAndNil(ProgressForm);

  // ���������� ���������
  PC_ShellCommand.TabIndex := 1;
  Show;
end;






procedure TFmRunShellCommand.FormCreate(Sender: TObject);
begin
  OnProcessCompletion := FProcessCompletion;

  // ������ ����
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

// ����� ������� ����������
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

  // ���������� ������������ ���� ������ ��������
  SelectDirectory.DirectoryListBox.Directory := dir;
  res := SelectDirectory.ShowModal;

  // ���������� ������� (����� ��� �� �������� ������)
  if (res = MrOk) then
    EdDirPath.text := IncludeTrailingPathDelimiter(SelectDirectory.DirectoryListBox.Directory);
end;

// ��������� ��������� ������ �� ������ � ���� ����� �������
procedure TFmRunShellCommand.LB_EnteredCommandsClick(Sender: TObject);
begin
  if LB_EnteredCommands.ItemIndex >= 0 then
    EdCommandLine.text := LB_EnteredCommands.items[LB_EnteredCommands.ItemIndex];
end;


// ���������� CLI - �������
procedure TFmRunShellCommand.BtnRunCommandClick(Sender: TObject);
var
  I: Integer;
  dir: string;
  ExitCode: Dword;
begin
  // ������ �����
  close;

  // ��������� ������� ����������
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

  // ��������� ������� � ������ �������� ������
  LB_EnteredCommands.items.add(EdCommandLine.Text);

  // ��� �����������, ���������, �� ������� ���� ���
  // ��������� ������ ����������
  // ����� ������ � ������ ����� �������� ���� ���������
  Itm := nil;
  for I := 0 to FmMain.LvTasksList.GetCount - 1 do
  if TaskRecord.TaskFunctionDescription = FmMain.LvTasksList.items[i].caption then
  begin
    Itm := FmMain.LvTasksList.items[i];
    Itm.SubItems[0] := '�����������';
    Itm.SubItems[1] := DateTimeToStr(Now);
  end;

  Log.AddMes('������ ���������� ������ "' + Itm.caption + '"');
  Log.AddMes('������� ����� "' + EdDirPath.Text + '"');
  Log.AddMes('������� ��� ���������� "' + EdCommandLine.Text + '"');

  // ���������� ���� �������� ����������
  ProgressForm := TfmTaskProgress.Create(self);
  ProgressForm.LblTaskDescription.Caption := TaskRecord.TaskFunctionDescription;
  ProgressForm.OnTaskAbort := nil;
  ProgressForm.BtnAbortTask.enabled := false;

  ProgressForm.show;

  // ������ ������� ��������� � ������
  // ���� ����� ����������� � ���� ���������, �� ��� ������ �� DLL ��������� ���������� ERROR
  // �������� ��� ������� � ������������� ������������ ������������
  // ������������� ������� ����������� ���������� - �� ��������
  Thread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        LibHandle := LoadLibrary('TestJobDLL2.dll');

        if LibHandle <> 0 then
        begin
          ExecuteCommand := GetProcAddress(LibHandle, PwideChar(TaskRecord.TaskFunctionName));

          // ��� ������ �� DLL � callback �������� ���� �������� ������ (5 - �������� � �������)
          // � �������� ���� �� ����������
          // if Assigned(AsyncExecuteCommandCB) then
             // ���������� ������� � ������� � ���� ���������
          //   AsyncExecuteCommandCB(EdCommandLine.Text, OnProcessCompletion);

          // ����� �������� � ������� ������������ ����������
          if Assigned(ExecuteCommand) then
            ExecuteCommand(EdCommandLine.Text, ExitCode);

          // �������������� � VCL ����� ����������
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


// ����� ���������� � Callback ������������ �������� - ����������� �������
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

      // �������� callback � �������� ������
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
