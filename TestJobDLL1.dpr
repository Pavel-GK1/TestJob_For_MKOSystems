library TestJobDLL1;

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
  System.IOUtils,
  System.Types,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.UITypes,
  VCL.Dialogs,
  UappTypes
;

{$R *.res}


Function GetTasksListInLibrary: TStringDynArray; stdcall;
var
  TasksList: TStringDynArray;
  i: Integer;
begin
  setLength(TasksList,3);

  For i:= 0 to 2 do
    TasksList[i] := allTasksDescription[i].TaskFunctionDescription;

  result := TasksList;
end;


function CompareLowerStr(const Left, Right: string): Integer;
begin
  Result := CompareStr(AnsiLowerCase(Left), AnsiLowerCase(Right));
end;


Function SearchFiles(StartDir : string; Mask: TStringDynArray ): TStringDynArray; stdcall;
var
  Files: TStringDynArray;
  I: Integer;
  LSearchOption: TSearchOption;

begin
  { Опция поиска - во всех директориях }
  LSearchOption := TSearchOption.soAllDirectories;

  try
    setLength(Files,0);

    for I := 0 to Length(Mask) -1 do
      files := files + TDirectory.GetFiles(StartDir, Mask[I], LSearchOption);

    // отсортируем список
    if Length(files) > 0 then
      TArray.Sort<String>(files, TComparer<String>.Construct(CompareLowerStr));

    Result := files;

  except
    on E:exception do
    begin
      MessageDlg('Некорректный путь или маска поиска - -' + E.Message, mtError, [mbOK], 0);
      Exit;
    end;
  end;
end;


// поиск вхождения строки в текстовом файле
// поиск до первого вхождения
function FindStringInFile(const FileName, SearchString: string): Boolean; stdcall;
var
  Stream: TFileStream;
  Buffer: string;
  ChunkSize, BytesRead: Integer;
begin
  Result := False;

  ChunkSize := 1024 * 1024; // порция в 1MB
  SetLength(Buffer, ChunkSize);

  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    repeat
      BytesRead := Stream.Read(Buffer[1], ChunkSize);

      if Pos(SearchString, Buffer) > 0 then
      begin
        Result := True;

        break
      end;
    until BytesRead < ChunkSize;

  finally
    Stream.Free;
  end;
end;

function FindByteArrayInFile(const FileName: string; const SearchArray: array of Byte): TInt64Array; stdcall;
var
  FS: TFileStream;
  Buffer: array of Byte;
  i, j, ReadBytes: Integer;
  Match: Boolean;
  BufSize: Integer;
  ResultArray: TInt64Array;
begin
  // пока ничего не найдено
  setlength(ResultArray,0);

  // читаем вот постольку, можно и больше
  BufSize := 65536;
  SetLength(Buffer, BufSize + Length(SearchArray) - 1);

  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    while FS.Position < FS.Size do
    begin
      ReadBytes := FS.Read(Buffer[0], BufSize);

      for i := 0 to ReadBytes - Length(SearchArray) do
      begin
        // начальное значение соответствия - типа есть вхождение
        Match := True;

        for j := 0 to High(SearchArray) do
        begin
          if Buffer[i + j] <> SearchArray[j] then
          begin
            // вхождения нет
            Match := False;
            Break;
          end;
        end;

        // цикл по искомой строке пробежали и match не изменился - найдено вхождение
        if Match then
        begin
          // заполняем массив позициями вхождений
          setLength(ResultArray, Length(ResultArray) + 1);
          ResultArray[Length(ResultArray) - 1] := FS.Position - ReadBytes + i;
        end;
      end;

      // Перемещаемся назад для перекрытия поиска
      if ReadBytes = BufSize then
        FS.Position := FS.Position - Length(SearchArray) + 1;
    end;

  finally
    FS.Free;
    Result := ResultArray;
  end;
end;


Exports
 GetTasksListInLibrary,
 SearchFiles,
 FindStringInFile,
 FindByteArrayInFile
 ;

begin
end.
