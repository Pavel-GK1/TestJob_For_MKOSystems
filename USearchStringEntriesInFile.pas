// ����� ���� ������� ���������� �� TFmsearchFile, �� ��� ���� �������
unit USearchStringEntriesInFile;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  System.DateUtils, System.IOUtils, System.UITypes,
  Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls,

  UAppTypes,
  UTaskProgress,
  Ulog
  ;

type
  TFmSearchStringEntriesInFile = class(TForm)
    PC_SearchEntries: TPageControl;
    TS1_ParamsTask: TTabSheet;
    Label3: TLabel;
    sbGetFilePath: TSpeedButton;
    Label2: TLabel;
    EdFilePath: TEdit;
    edSubStrForSearch: TEdit;
    BtnSearchEntries: TButton;
    TS2_ResultTask: TTabSheet;
    LblEntriesCount: TLabel;
    Label1: TLabel;
    LbResults: TListBox;
    BtnClose: TButton;
    TmrStartFillEntriesList: TTimer;
    TS3_Logs: TTabSheet;
    MemoLog: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);

    procedure sbGetFilePathClick(Sender: TObject);
    procedure BtnSearchEntriesClick(Sender: TObject);

    // ������� ���������� ������
    procedure FOnTaskDone;
    // ���������� ������ �� ����������
    procedure FOnTaskAbort;

  private
    { Private declarations }
    LibHandle: THandle;
    Thread: TThread;
    EntriesList: TResultEntiesSearchList;
    SearchStringsList: TStringDynArray;
    Itm: TlistItem;

    // �������, ������������ �� ����������
    SearchEntriesFunc: TSearchEntriesFunc;

    // ���� ����� ���������� �����
    Log: Tlog;
  public
    { Public declarations }

    TaskRecord: TTaskRecord;
    ProgressForm: TfmTaskProgress;
  end;

var
  FmSearchStringEntriesInFile: TFmSearchStringEntriesInFile;

implementation

{$R *.dfm}

uses
  UMain, USelectDirectory;


procedure TFmSearchStringEntriesInFile.FormCreate(Sender: TObject);
begin
  EntriesList := TList<TEntriesRecort>.create;

  // ������ ����
  Log := TLog.Create(GetlogFileName('SearchEntries'), MemoLog);
end;

procedure TFmSearchStringEntriesInFile.FormDestroy(Sender: TObject);
begin
  EntriesList.free;
  Log.Free;
end;

procedure TFmSearchStringEntriesInFile.BtnCloseClick(Sender: TObject);
begin
  close;
end;


// ����� ����� ��� ������������ ��������� �����
procedure TFmSearchStringEntriesInFile.sbGetFilePathClick(Sender: TObject);
var
  dir: WideString;
  res : Integer;
begin
  if Length(EdFilePath.text) > 0 then
  begin
    dir := ExtractFilePath(EdFilePath.text);
    if not DirectoryExists(dir) then
      dir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  end
  else
    dir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

  ForceDirectories(dir);

  // ���������� ������������ ���� ������ �������� � ������
  SelectDirectory.DirectoryListBox.Directory := dir;
  res := SelectDirectory.ShowModal;

  // ���� ������ (����� ��� �� �������� ������ ��� ������� ��)
  if (res = MrOk) then
    EdFilePath.text := SelectDirectory.FileListBox.FileName;
end;


// ����� ������
procedure TFmSearchStringEntriesInFile.BtnSearchEntriesClick(Sender: TObject);
var
  i: integer;
begin
  // ������� ����������
  LbResults.Clear;
  LblEntriesCount.Caption := '0';

  // ��� �����������, ���������, �� ������� ���� ���
  // ��������� ������ ���������
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
  Log.AddMes('��������� ����� "' + EdFilePath.Text + '"');
  Log.AddMes('������(������) ������ "' + edSubStrForSearch.Text + '"');

  // ���������� ���� �������� ����������
  ProgressForm := TfmTaskProgress.Create(self);
  ProgressForm.LblTaskDescription.Caption := TaskRecord.TaskFunctionDescription;
  ProgressForm.OnTaskAbort := FOnTaskAbort;
  ProgressForm.BtnAbortTask.enabled := false;
  ProgressForm.show;

  // ����� ��������� � ������
  Thread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        LibHandle := LoadLibrary('TestJobDLL1.dll');

        if LibHandle <> 0 then
        begin
          SearchEntriesFunc := GetProcAddress(LibHandle, PwideChar(TaskRecord.TaskFunctionName)); //'FindByteArrayInFile'

          if Assigned(SearchEntriesFunc) then
          begin
            setlength(SearchStringsList, 0);
            // ������� ������ ����� ��� ������ ��������� ���� ����� � �����, ������ ������ ����������� ��������
            SearchStringsList := GetStringsArrayFromString(edSubStrForSearch.text, ',');
            // ����� ���������, ������ ��������� ��������� �� ���� ������� ������ - EntriesList
            SearchEntriesFunc(EdFilePath.Text, SearchStringsList, EntriesList);

            // �������������� � VCL ����� ����������
            TThread.Synchronize(nil,
              procedure
              begin
                FOnTaskDone;
              end);
          end;
        end;

      finally
        SearchEntriesFunc := nil;
        FreeLibrary(LibHandle);
      end;
    end);

  Thread.FreeOnTerminate := True;
  Thread.Start;
end;


// ������� ���������� ������
procedure TFmSearchStringEntriesInFile.FOnTaskDone;
var
  i, j: integer;
  LogStr: string;

begin
  // ������� ������ ����������
  if Assigned(Itm) then
  begin
    Itm.SubItems[0] := '��������� (' +
                       IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' ���)';
    Itm.SubItems[1] := DateTimeTostr(Now);

    Log.AddMes('��������� ���������� ������ "' + Itm.caption + '"');

  end;
  Application.ProcessMessages;

  // ��������� ������ ��������� ������
  LbResults.Clear;
  for I := 0 to EntriesList.Count - 1 do
  begin
    // ������� ������
    LogStr := '������ ������ : ' + EntriesList.items[I].Searchstring +
              ', ��������� : ' +
              IntToStr(Length(EntriesList.items[I].ResultsArray));
    LbResults.Items.Add(LogStr);
    Log.AddMes(LogStr);

    // ���������� ��������� ��� ������� ������
    for j := 0 to Length(EntriesList.items[I].ResultsArray) - 1 do
    begin
      LogStr := '� ������� : ' + IntToStr(EntriesList.items[I].ResultsArray[j]);
      LbResults.Items.Add(LogStr);
      Log.AddMes(LogStr);
    end;

    Log.AddMes('');
  end;
  Application.ProcessMessages;

  // ������� ����� ������� ��� ������
  LblEntriesCount.Caption := IntToStr(EntriesList.Count);

  // ��������� ����� �������� ���������� ������
  if assigned(ProgressForm) then
  begin
    ProgressForm.close;
    FreeAndNil(ProgressForm);
  end;

  // ���������� ���������
  PC_SearchEntries.TabIndex := 1;
end;

// ���������� ������ �� ����������
// ����� ����������� ������ �������� �����������,
// �������� ������� ����� �������� ���������� ERROR
procedure TFmSearchStringEntriesInFile.FOnTaskAbort;
begin
{  if assigned(ProgressForm) then
  begin
    ProgressForm.close;
    FreeAndNil(ProgressForm);
  end;

  // ���������� �����
  If assigned(Thread) then
  begin
    // ����� �� ������ ����������
    terminateThread(Thread.Handle, 0);
    Thread := nil;
  end;

  // ������ ������ ���������� ������
  if assigned(Itm) then
  begin
    Itm.SubItems[0] := '��������';
    Itm.SubItems[1] := DateTimeToStr(Now);

    Log.AddMes('���������� ������ "' + Itm.caption + '" ��������');
  end;

  // ������� ��������� ������
  lbResults.Clear;
  LblEntriesCount.Caption := '0';}
end;

end.
