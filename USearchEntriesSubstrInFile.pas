// ����� ���� ������� ���������� �� TFmsearchFile, �� ��� ���� �������
unit USearchEntriesSubstrInFile;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  System.DateUtils, System.IOUtils, System.UITypes,
  Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ComCtrls,

  UAppTypes,
  UProgressOfJob, Vcl.ExtCtrls
  ;

type
  TFmSearchEntriesSubstrInFile = class(TForm)
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
    procedure sbGetFilePathClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSearchEntriesClick(Sender: TObject);
    procedure TmrStartFillEntriesListTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    LibHandle: THandle;
    SearchEntriesFunc: TSearchEntriesFunc;
    Thread: TThread;
    EntriesList: TResultEntiesSearchList;
    SearchSubstringsList: TStringDynArray;
    Itm: TlistItem;

  public
    { Public declarations }

    TaskRecord: TTaskRecord;
    ProgressForm:TfmProgressOfJob;
  end;

var
  FmSearchEntriesSubstrInFile: TFmSearchEntriesSubstrInFile;

implementation

{$R *.dfm}

uses
  UMain, USelectDirectory;

procedure TFmSearchEntriesSubstrInFile.BtnCloseClick(Sender: TObject);
begin
  close;
end;


procedure TFmSearchEntriesSubstrInFile.sbGetFilePathClick(Sender: TObject);
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



procedure TFmSearchEntriesSubstrInFile.BtnSearchEntriesClick(Sender: TObject);
var
  i: integer;
begin
  // ������ �����
  close;

  // ��������� ������ ���������
  // ����� ������ � ������ �����
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
            setlength(SearchSubstringsList, 0);
            // ������� ������ ����� ��� ������ ������, ����� ������ ����������� ��������
            SearchSubstringsList := GetFilesMasks(edSubStrForSearch.text, ',');
            // ������ ��������� ������
            SearchEntriesFunc(EdFilePath.Text, SearchSubstringsList, EntriesList);
          end;
        end;

      finally
        SearchEntriesFunc := nil;
        FreeLibrary(LibHandle);

        // � ������ ������������� � VCL �� ����� ������������ - ������� ������ ���������� ������,
        // ��� ������� ������� ���������� Application.ProcessMessages, ����� ���������� �� ��������
        // �� ���-�� �������� ���������
        TmrStartFillEntriesList.Enabled := true;
      end;
    end);

  Thread.FreeOnTerminate := True;
  Thread.Start;
end;


// ������ ���������� ������ ����������� ������
procedure TFmSearchEntriesSubstrInFile.TmrStartFillEntriesListTimer(
  Sender: TObject);
var i, j: integer;
begin
  TmrStartFillEntriesList.Enabled := false;

  // ��������� ������ ��������� ������
  LbResults.Clear;
  for I := 0 to EntriesList.Count - 1 do
  begin
    // ������� ������
    LbResults.Items.Add('������ ������ : ' + EntriesList.items[I].Searchstring +
                        ', ��������� : ' +
                        IntToStr(Length(EntriesList.items[I].ResultsArray)));

    // ���������� ��������� ��� ������� ������
    for j := 0 to Length(EntriesList.items[I].ResultsArray) - 1 do
      LbResults.Items.Add('� ������� : ' + IntToStr(EntriesList.items[I].ResultsArray[j]));

    Application.ProcessMessages;
  end;

  // ������� ����� ������� ��� ������
  LblEntriesCount.Caption := IntToStr(EntriesList.Count);

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
  PC_SearchEntries.TabIndex := 1;
  Show;
end;


procedure TFmSearchEntriesSubstrInFile.FormCreate(Sender: TObject);
begin
  EntriesList := TList<TEntriesRecort>.create;
end;

procedure TFmSearchEntriesSubstrInFile.FormDestroy(Sender: TObject);
begin
  EntriesList.free;
end;



end.
