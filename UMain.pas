unit UMain;

interface

uses
  Sharemem,
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  WinApi.ImageHlp, Vcl.Buttons,

  UAppTypes, Vcl.ComCtrls
  ;


type
  TFmMain = class(TForm)
    Label1: TLabel;
    BtnRunTask: TButton;
    LvTasksList: TListView;
    BtnClose: TButton;

    procedure FormShow(Sender: TObject);
    procedure LvTasksListDblClick(Sender: TObject);
    procedure ShowTaskForm(Task: TtaskDescription);
    procedure BtnRunTaskClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
  private
    { Private declarations }
    GetTasksListInLibrary : TGetJobsListInLibrary;

    procedure GetTasksListFromDLL;

  public
    { Public declarations }
  end;

var
  FmMain: TFmMain;


implementation

{$R *.dfm}

Uses
  USearchFiles, USearchEntriesSubstrInFile;


// Не будем мудрствоовать, возьмём списки экспортируемых из DLL функций
// из специально подготовленных рутин в библиотеках
procedure TFmMain.FormShow(Sender: TObject);
begin
  GetTasksListFromDLL;
end;

procedure TFmMain.GetTasksListFromDLL;
var
  LibHandle: Thandle;
  Taskslist: TStringDynArray;
  I : Integer;
  itm: TListItem;
begin
  try
    LibHandle := LoadLibrary('TestJobDLL1.dll');

    if LibHandle <> 0 then
    begin
      GetTasksListInLibrary := GetProcAddress(LibHandle, 'GetTasksListInLibrary');

      if Assigned(GetTasksListInLibrary) then
      begin
        // список найденных функций
        Taskslist := GetTasksListInLibrary;
      end;
    end;

  finally
    GetTasksListInLibrary := nil;
    FreeLibrary(LibHandle);
  end;

  For i:= 0 to Length(Taskslist) - 1 do
  begin
    itm := LvTasksList.Items.Add();
    itm.Caption := Taskslist[i];
    itm.SubItems.Add('-');
    itm.SubItems.Add('-');
  end;

  try
    LibHandle := LoadLibrary('TestJobDLL2.dll');

    if LibHandle <> 0 then
    begin
      GetTasksListInLibrary := GetProcAddress(LibHandle, 'GetTasksListInLibrary');

      if Assigned(GetTasksListInLibrary) then
      begin
        // список найденных функций
        Taskslist := GetTasksListInLibrary;
      end;
    end;

  finally
    GetTasksListInLibrary := nil;
    FreeLibrary(LibHandle);
  end;

  itm := LvTasksList.Items.Add();
  itm.Caption := Taskslist[0];
  itm.SubItems.Add('-');
  itm.SubItems.Add('-');

  itm := LvTasksList.Items[0];

  itm.Selected := True;
end;


// запуск форм для задач
procedure TFmMain.LvTasksListDblClick(Sender: TObject);
var
  Itm: TListItem;
  I: Integer;
begin
  Itm := LvTasksList.Selected;

  // если позиция в списке выбрана
  if Assigned(itm) then
  for I := Low(allTasksDescription) to High(allTasksDescription) do
  if Itm.Caption = allTasksDescription[i].TaskFunctionDescription then
  begin
    ShowTaskForm(allTasksDescription[i]);

    break
  end;
end;

procedure TFmMain.ShowTaskForm(Task: TtaskDescription);
begin
  case Task.NumTask of
    // ограничим запуск однотипных задач на выполнение одним экземпляром
    // не будем запускать форму, если идёт процесс выполнения
    0: if not Assigned(FmSearchFiles.ProgressForm) then
       // процесс выполнения не запущен - запускаем задачу
       begin
         FmSearchFiles.TaskDescription := Task.TaskFunctionDescription;
         FmSearchFiles.PCSearchFiles.TabIndex :=0;
         FmSearchFiles.Show;
       end else
         ShowMessage('Задача "' + Task.TaskFunctionDescription + '" уже запущена!' +
                      'Процесс выполнения ещё не завершился.' );
    2: if not Assigned(FmSearchEntriesSubstrInFile.ProgressForm) then
       // процесс выполнения не запущен - запускаем задачу
       begin
         FmSearchEntriesSubstrInFile.TaskDescription := Task.TaskFunctionDescription;
         FmSearchEntriesSubstrInFile.PC_SearchEntries.TabIndex :=0;
         FmSearchEntriesSubstrInFile.Show;
       end else
         ShowMessage('Задача "' + Task.TaskFunctionDescription + '" уже запущена!' +
                      'Процесс выполнения ещё не завершился.' );

  end;
end;

procedure TFmMain.BtnRunTaskClick(Sender: TObject);
begin
  LvTasksListDblClick(Sender);
end;

procedure TFmMain.BtnCloseClick(Sender: TObject);
begin
  close;
end;

end.
