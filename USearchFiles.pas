unit USearchFiles;

interface

uses
  Sharemem,
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  System.DateUtils,
  Vcl.ComCtrls,

  UAppTypes,
  UTaskProgress,
  Ulog
  ;

type
  TFmSearchFiles = class(TForm)
    BtnClose: TButton;
    PCSearchFiles: TPageControl;
    TS1_ParamsTask: TTabSheet;
    EdDirPath: TEdit;
    edFileMask: TEdit;
    Label3: TLabel;
    cbDoRecursive: TCheckBox;
    sbGetDirPath: TSpeedButton;
    Label2: TLabel;
    TS2_ResultTask: TTabSheet;
    LblFilesCount: TLabel;
    Label1: TLabel;
    BtnSearchFiles: TButton;
    TS3_Logs: TTabSheet;
    MemoLog: TMemo;
    MemoResults: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);

    procedure sbGetDirPathClick(Sender: TObject);
    procedure BtnSearchFilesClick(Sender: TObject);
    procedure FOnTaskDone;
    procedure FOnTaskAbort;
  private
    { Private declarations }
    LibHandle: THandle;
    Thread: TThread;
    MasksList: TStringDynArray;
    Itm: TlistItem;

    FilesList: TStringDynArray;
    FFileslist: TstringList;

    // ������� ������������ �� ����������
    SearchFilesFunc: TSearchFilesFunc;

    // ���� ����� ���������� �����
    Log: Tlog;

  public
    { Public declarations }
    TaskRecord: TTaskRecord;
    ProgressForm: TfmTaskProgress;
  end;

var
  FmSearchFiles: TFmSearchFiles;

implementation

{$R *.dfm}

Uses
  Umain, USelectDirectory;


procedure TFmSearchFiles.FormCreate(Sender: TObject);
begin
  // ������ ����
  Log := TLog.Create(GetlogFileName('SearchFiles'), MemoLog);

  FFileslist := TstringList.Create;
end;

procedure TFmSearchFiles.FormDestroy(Sender: TObject);
begin
  SetLength(FilesList,0);
  FFileslist.Free;

  Log.free;
end;

procedure TFmSearchFiles.BtnCloseClick(Sender: TObject);
begin
  close;
end;


// ����� ����� ��� ������
procedure TFmSearchFiles.sbGetDirPathClick(Sender: TObject);
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

// ������ ������
procedure TFmSearchFiles.BtnSearchFilesClick(Sender: TObject);
var
  I: Integer;

begin
  // ������� ���������
  MemoResults.Clear;
  LblFilesCount.Caption := '';

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
  Log.AddMes('��������� ����� "' + EdDirPath.Text + '"');
  Log.AddMes('����� ������ "' + edFileMask.Text + '"');

  // ���������� ���� �������� ����������
  ProgressForm := TfmTaskProgress.Create(self);
  ProgressForm.LblTaskDescription.Caption := TaskRecord.TaskFunctionDescription;
  // ������ ��� ���� ������� ��� ���������� ���������� ������
  ProgressForm.OnTaskAbort := FOnTaskAbort;
  ProgressForm.show;

  // ����� ��������� � ������
  Thread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        LibHandle := LoadLibrary('TestJobDLL1.dll');

        if LibHandle <> 0 then
        begin
          SearchFilesFunc := GetProcAddress(LibHandle, PwideChar(TaskRecord.TaskFunctionName)); //'SearchFiles');

          if Assigned(SearchFilesFunc) then
          begin
            setlength(MasksList, 0);
            FFileslist.Clear;

            // ������� ������ ����� ��� ������ ������, ����� ������ ����������� ��������
            MasksList := GetStringsArrayFromString(edFileMask.text, ',');
            // ������ ��������� ������
            SearchFilesFunc(EdDirPath.Text, MasksList, FFileslist);

            // �������������� � VCL ����� ����������
            TThread.Synchronize(nil,
              procedure
              begin
                FOnTaskDone;
              end);
          end;
        end;

      finally
        SearchFilesFunc := nil;
        FreeLibrary(LibHandle);
      end;
    end);

  Thread.FreeOnTerminate := True;
  Thread.Start;
end;

// ������ ��� ���� ������� ��� ���������� ���������� ������
procedure TFmSearchFiles.FOnTaskDone;
var
  i: integer;
begin
  // ��������� ����� �������� ���������� ������
  if Assigned(ProgressForm) then
  begin
    ProgressForm.close;
    FreeAndNil(ProgressForm);
  end;

  // ���������� ��������� ������
//  LblFilesCount.Caption := IntToStr(Length(FilesList));
  LblFilesCount.Caption := IntToStr(FFilesList.Count);

  Application.ProcessMessages;

  // ������� ������ ���������� ������
  if Assigned(Itm) then
  begin
    Itm.SubItems[0] := '��������� (' +
                       IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' ���)';
    Itm.SubItems[1] := DateTimeTostr(Now);
  end;

  Log.AddMes('��������� ���������� ������ "' + Itm.caption + '"');
  Log.AddMes('������� ������ : ' + LblFilesCount.Caption);
  Log.AddMes('');

  Application.ProcessMessages;

  // ���������� ���������
  PCSearchFiles.TabIndex := 1;

  // ������� ������ ���������� ������,
  // ��� ������� ������� ���������� Application.ProcessMessages, ����� ���������� �� ��������
  // �� ���-�� �������� ���������
//  TmrStartFillFilesList.Enabled := true;

  // ��� ����� ������� ������� �������� �������� ��� ���������� ����������
  // � ��������� ������ � �������������� Application.ProcessMessages
  // �������� ���� �������, ��������� �������� �� ��������� ������ ��� 60000 ������
  MemoResults.Lines.Text := FFileslist.Text;
  Application.ProcessMessages;
end;

// ������ ��� ���� ������� ��� ���������� ���������� ������
procedure TFmSearchFiles.FOnTaskAbort;
begin
  // ��������� ����� �������� ����������
  if Assigned(ProgressForm) then
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

  // ���... �� ������ ������
  Application.ProcessMessages;

  // ������ ������ ���������� ������
  if assigned(Itm) then
  begin
    Itm.SubItems[0] := '��������';
    Itm.SubItems[1] := DateTimeToStr(Now);

    Log.AddMes('���������� ������ "' + Itm.caption + '" ��������');
  end;

  // ������� ��������� ������
  MemoResults.Clear;
  LblFilesCount.Caption := '0';
end;


end.
