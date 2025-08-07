unit ULog;

interface

uses SysUtils, Classes, StdCtrls;

// --------------- Класс для работы с Log файлами ------------------------------
type
  TLog = class
  private
    FileHandler: TFileStream;
    FMlog      : TMemo;

    FFile_Name : string;

  public
    constructor Create(FilePath: String; MLog: TMemo);
    destructor Destroy; override;

    procedure CreateFileStream(FilePath: String);
    procedure AddMes(MessageText: String; ToMemo: boolean = true);
  end;

var
  Log : TLog;


implementation


// -----------------------------------------------------------------------------
constructor TLog.Create(FilePath: String; MLog: TMemo);
begin
  FileHandler := nil;
  CreateFileStream(FilePath);

  FMLog := MLog;
end;

// .............................................................................
destructor TLog.Destroy;
begin
  FileHandler.Free;
end;


procedure Tlog.CreateFileStream(FilePath: String);
begin
  FFile_Name := FilePath;

  if FileHandler <> nil then
    FreeAndNil(FileHandler);

  if FileExists(FFile_Name) then
    self.FileHandler := TFileStream.Create(FFile_Name, fmOpenWrite or fmShareDenyNone)
  else
    self.FileHandler := TFileStream.Create(FFile_Name, fmCreate or fmOpenWrite or fmShareDenyNone);
end;

// .............................................................................
procedure TLog.AddMes(MessageText: String; ToMemo: boolean = true);
var
  MessageStrF, MessageStrM: String;
  CurrDate:TDateTime;
begin
  CurrDate := Now;
  MessageStrM := FormatDateTime('dd.mm.yyyy hh:mm:ss', CurrDate)+' : ' +
                 MessageText;
  MessageStrF := MessageStrM + #13#10;

  FileHandler.Seek(0, soFromEnd);
  FileHandler.Write(MessageStrF[1],Length(MessageStrF)*2);

  if ToMemo then
  begin
    if FmLog.Lines.Count >= 100 then
      FmLog.Lines.Delete(0);

    FmLog.Lines.add(MessageStrM);
  end;
end;


end.
