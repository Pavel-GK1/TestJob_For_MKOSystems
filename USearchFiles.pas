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
  UProgressOfJob
  ;

type
  TFmSearchFiles = class(TForm)
    BtnClose: TButton;
    TmrStartFillFilesList: TTimer;
    PCSearchFiles: TPageControl;
    TS1_ParamsTask: TTabSheet;
    EdDirPath: TEdit;
    edFileMask: TEdit;
    Label3: TLabel;
    cbDoRecursive: TCheckBox;
    sbGetDirPath: TSpeedButton;
    Label2: TLabel;
    TS2_ResultTask: TTabSheet;
    LbResults: TListBox;
    LblFilesCount: TLabel;
    Label1: TLabel;
    BtnSearchFiles: TButton;

    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSearchFilesClick(Sender: TObject);
    procedure sbGetDirPathClick(Sender: TObject);

    procedure TmrStartFillFilesListTimer(Sender: TObject);
  private
    { Private declarations }
    LibHandle: THandle;
    SearchFilesFunc: TSearchFilesFunc;
    Thread: TThread;
    FilesList, MasksList: TStringDynArray;
    Itm: TlistItem;

  public
    { Public declarations }
    TaskRecord: TTaskRecord;
    ProgressForm:TfmProgressOfJob;
  end;

var
  FmSearchFiles: TFmSearchFiles;

implementation

{$R *.dfm}

Uses
  Umain, USelectDirectory;

procedure TFmSearchFiles.BtnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TFmSearchFiles.BtnSearchFilesClick(Sender: TObject);
var
//  LSearchOption: TSearchOption;
  I: Integer;

begin
  // ������ �����
  close;

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

  // ���������� ���� �������� ����������
  ProgressForm := TfmProgressOfJob.Create(self);
  ProgressForm.LblTaskDescription.Caption := TaskRecord.TaskFunctionDescription;
  ProgressForm.show;

  // ��� ����� ������ - ���� �� ������������
//  if cbDoRecursive.Checked then
//    LSearchOption := TSearchOption.soAllDirectories
//  else
//    LSearchOption := TSearchOption.soTopDirectoryOnly;

  // ������ ������ �����
//    if cbIncludeDirectories.Checked and cbIncludeFiles.Checked then
//      FilesList := TDirectory.GetFileSystemEntries(editPath.Text, LSearchOption, nil);

//    if cbIncludeDirectories.Checked and not cbIncludeFiles.Checked then
//      LList := TDirectory.GetDirectories(editPath.Text, editFileMask.Text, LSearchOption);

//    if not cbIncludeDirectories.Checked and cbIncludeFiles.Checked then
//      FilesList := TDirectory.GetFiles(editPath.Text, editFileMask.Text, LSearchOption);

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
            // ������� ������ ����� ��� ������ ������, ����� ������ ����������� ��������
            MasksList := GetStringsArrayFromString(edFileMask.text, ',');
            // ������ ��������� ������
            Fileslist := SearchFilesFunc(EdDirPath.Text, MasksList);
          end;
        end;

      finally
        SearchFilesFunc := nil;
        FreeLibrary(LibHandle);

        // � ������ ������������� � VCL �� ����� ������������ - ������� ������ ���������� ������,
        // ��� ������� ������� ���������� Application.ProcessMessages, ����� ���������� �� ��������
        // �� ���-�� �������� ���������
        TmrStartFillFilesList.Enabled := true;
      end;
    end);

  Thread.FreeOnTerminate := True;
  Thread.Start;
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

// ������ ���������� ������ ����������� ������
procedure TFmSearchFiles.TmrStartFillFilesListTimer(Sender: TObject);
var i: integer;
begin
  TmrStartFillFilesList.Enabled := false;

  // ��������� ������ ��������� ������
  LbResults.Clear;
  for I := 0 to Length(FilesList) - 1 do
  begin
    LbResults.Items.Add(FilesList[I]);

    Application.ProcessMessages;
  end;

  // ���������� ��������� ������
  LblFilesCount.Caption := IntToStr(Length(FilesList));

  // ��������� ����� �������� ���������� ������
  ProgressForm.close;
  FreeAndNil(ProgressForm);

  // ������� ������ ����������
  if Assigned(Itm) then
  begin
    Itm.SubItems[0] := '��������� (' +
                       IntToStr(SecondsBetween(Now, StrToDateTime(Itm.SubItems[1]))) + ' ���)';
    Itm.SubItems[1] := DateTimeTostr(Now);
  end;

  // ���������� ���������
  PCSearchFiles.TabIndex := 1;
  Show;
end;

end.
