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
  Generics.Collections,
  UappTypes
;

{$R *.res}


// �� ����� ������������, ������ ������ �������������� �� DLL �������
// �� ���������� �������������� ����� � �����������
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


function CompareLowerStr(const Left, Right: string): Integer;
begin
  Result := CompareStr(AnsiLowerCase(Left), AnsiLowerCase(Right));
end;


Function SearchFiles(StartDir : string; Masks: TStringDynArray;
                     out OutFiles: TstringList): boolean; stdcall;
var
  I: Integer;
  LSearchOption: TSearchOption;
  Files: TStringDynArray;

begin
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
  Result := false;

  { ����� ������ - �� ���� ����������� }
  LSearchOption := TSearchOption.soAllDirectories;

  try
    setlength(files, 0);
    // �������� ����� �� ������ ������
    for I := 0 to Length(Masks) -1 do
      files := files + TDirectory.GetFiles(StartDir, Masks[I], LSearchOption);

    // ����������� ������
    if Length(files) > 0 then
      TArray.Sort<String>(files, TComparer<String>.Construct(CompareLowerStr));

    for I := 0 to Length(files) -1 do
      OutFiles.Add(files[i]);

    setlength(files, 0);
    Result := OutFiles.Count > 0;

  except
    on E:exception do
    begin
      MessageDlg('������������ ���� ��� ����� ������ - ' + E.Message, mtError, [mbOK], 0);
      Exit;
    end;
  end;
end;


// ����� ��������� ������ � ��������� �����
// ����� �� ������� ���������
function FindStringInFile(const FileName, SearchString: string): Boolean; stdcall;
var
  Stream: TFileStream;
  Buffer: string;
  ChunkSize, BytesRead: Integer;
begin
  Result := False;

  ChunkSize := 1024 * 1024; // ������ � 1MB
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

function Find_BytesArray_InFile(const FileName: string; const SearchArray: array of Byte): TInt64Array;
var
  FS: TFileStream;
  Buffer: array of Byte;
  i, j, ReadBytes: Integer;
  Match: Boolean;
  BufSize: Integer;
  ResultArray: TInt64Array;
begin
  // ���� ������ �� �������
  setlength(ResultArray,0);

  // ������ ��� ���������, ����� � ������
  BufSize := 65536;
  SetLength(Buffer, BufSize + Length(SearchArray) - 1);

  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    while FS.Position < FS.Size do
    begin
      ReadBytes := FS.Read(Buffer[0], BufSize);

      for i := 0 to ReadBytes - Length(SearchArray) do
      begin
        // ��������� �������� ������������ - ���� ���� ���������
        Match := True;

        for j := 0 to High(SearchArray) do
        begin
          if Buffer[i + j] <> SearchArray[j] then
          begin
            // ��������� ���
            Match := False;
            Break;
          end;
        end;

        // ���� �� ������� ������ ��������� � match �� ��������� - ������� ���������
        if Match then
        begin
          // ��������� ������ ��������� ���������
          setLength(ResultArray, Length(ResultArray) + 1);
          ResultArray[Length(ResultArray) - 1] := FS.Position - ReadBytes + i;
        end;
      end;

      // ������������ ����� ��� ���������� ������
      if ReadBytes = BufSize then
        FS.Position := FS.Position - Length(SearchArray) + 1;
    end;

  finally
    FS.Free;
    Result := ResultArray;
  end;
end;

function FindByteArrayInFile(const FileName: string; const SearchArray: TStringDynArray;
                             out EntriesList: TResultEntiesSearchList): Boolean; stdcall;
var
  Entries: TInt64Array;
  I: Integer;
  EntriesRec: TEntriesRecort;
  Searchbytes: tbytes;
  Encoding: Tencoding;
begin
  // ������� ������ �����������
  EntriesList.Clear;
  Result := False;

  try
    // ���������� ������ �����, ��� ������� ���� ���������
    for I := 0 to Length(SearchArray) - 1 do
    begin
      // ����������� ������ � ������ ����
      Searchbytes := Encoding.Default.GetBytes(SearchArray[I]);

      // ���� ��������� � ����� ��� ������� ���� ������ ������
      Entries := Find_BytesArray_InFile(FileName, Searchbytes);

      // ��������� ������ ��� ������ �����������
      EntriesRec.Searchstring := SearchArray[i];
      EntriesRec.SearchBytesArray := Searchbytes;
      EntriesRec.ResultsArray := Entries;

      // ��������� ��������� � ������
      EntriesList.Add(EntriesRec);
    end;

    // ������ �� ���� - ������ ����� ������ :)
    Result := EntriesList.Count >0;

  except
    on E:exception do
    begin
      MessageDlg('������ ������ ��������� ������ � ����� -' + E.Message, mtError, [mbOK], 0);
      Exit;
    end;
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
