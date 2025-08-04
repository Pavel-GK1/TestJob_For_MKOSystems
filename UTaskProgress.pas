unit UTaskProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls;

type
  TfmTaskProgress = class(TForm)
    pbProcess: TProgressBar;
    tmrAnimate: TTimer;
    Button1: TButton;
    LblTaskDescription: TLabel;
    procedure tmrAnimateTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FCounter : integer; // ������� ��������, ����� ������������� ��������
                        // ����������� ����� � ������������ ������
  public
    { Public declarations }

  end;

var
  fmTaskProgress: TfmTaskProgress;

implementation


{$R *.dfm}

{-------------------------------------------------------------------------------
    �������� ������� ��������
}
procedure TfmTaskProgress.tmrAnimateTimer(Sender: TObject);
begin
  inc( FCounter );
  pbProcess.Position := pbProcess.Position + 5;
  if pbProcess.Position = pbProcess.Max then
    pbProcess.Position := pbProcess.Min;

  // ������ ������ 200 ������ - ������� ���� �������������
  if FCounter >= 400 then
    Close;
end;


{-------------------------------------------------------------------------------
    ���������� �����. ��������� ������ ��������
}
procedure TfmTaskProgress.FormShow(Sender: TObject);
begin
  FCounter := 0;
  pbProcess.Position := 0;
  tmrAnimate.Enabled := true;
end;


{-------------------------------------------------------------------------------
    ����������� �����. ������������� ������ ��������
}
procedure TfmTaskProgress.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tmrAnimate.Enabled := false;
end;

end.

