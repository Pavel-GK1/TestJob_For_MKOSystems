unit USelectDirectory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, Buttons, ExtCtrls, Vcl.ComCtrls, Vcl.WinXPickers,
  System.DateUtils;

type
  TSelectDirectory = class(TForm)
    DirectoryListBox: TDirectoryListBox;
    bnCancel: TButton;
    bnOK: TButton;
    Label1: TLabel;
    cbDrive: TDriveComboBox;
    Label2: TLabel;
    FileListBox: TFileListBox;
    FilesCountLabel: TLabel;
    procedure DirectoryListBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure YearDataFilePickerChange(Sender: TObject);
    procedure FileListBoxDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  SelectDirectory: TSelectDirectory;

implementation

{$R *.dfm}

procedure TSelectDirectory.DirectoryListBoxChange(Sender: TObject);
begin
  FilesCountLabel.Caption := 'װאיכמג : ';
  if FileListBox.Count > 0 then
    FilesCountLabel.Caption := FilesCountLabel.Caption + IntToStr(FileListBox.Count);
end;

procedure TSelectDirectory.FileListBoxDblClick(Sender: TObject);
begin
  if FileListBox.Count >0 then
    ModalResult := MrOk;
end;

procedure TSelectDirectory.FormCreate(Sender: TObject);
begin
  FileListBox.Mask := '*.*';
  bnOK.Enabled := FileListBox.Count > 0;
end;

procedure TSelectDirectory.YearDataFilePickerChange(Sender: TObject);
begin
  FileListBox.Mask := '*.*';
  bnOK.Enabled := FileListBox.Count > 0;

  FilesCountLabel.Caption := 'װאיכמג : ';
  if FileListBox.Count > 0 then
    FilesCountLabel.Caption := FilesCountLabel.Caption + IntToStr(FileListBox.Count);
end;

end.
