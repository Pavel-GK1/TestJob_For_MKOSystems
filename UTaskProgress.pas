unit UTaskProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,

  UAppTypes;

type
  TfmTaskProgress = class(TForm)
    pbProcess: TProgressBar;
    tmrAnimate: TTimer;
    BtnAbortTask: TButton;
    LblTaskDescription: TLabel;
    procedure tmrAnimateTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnAbortTaskClick(Sender: TObject);
  private
    { Private declarations }
    FCounter : integer; // счетчик сработок, после определенного значения
                        // закрывается форма и показывается ошибка
  public
    { Public declarations }

    // процедура, передаваемая из родительской формы,
    // которая будет получать результат выполнения этой формы по её закрытию
    OnTaskAbort : TOnTaskAbort;
  end;

var
  fmTaskProgress: TfmTaskProgress;

implementation


{$R *.dfm}

{-------------------------------------------------------------------------------
    Сработка таймера анимации
}
procedure TfmTaskProgress.tmrAnimateTimer(Sender: TObject);
begin
  inc( FCounter );
  pbProcess.Position := pbProcess.Position + 1;
  if pbProcess.Position >= pbProcess.Max then
    pbProcess.Position := pbProcess.Min;

  // прошло больше 200 секунд - закроем окно принудительно
  if FCounter >= 400 then
    Close;
end;


{-------------------------------------------------------------------------------
    Показываем форму. Запускаем таймер анимации
}
procedure TfmTaskProgress.FormShow(Sender: TObject);
begin
  FCounter := 0;
  pbProcess.Position := 0;
  tmrAnimate.Enabled := true;
end;


{-------------------------------------------------------------------------------
    Закрывается форма. Останавливаем таймер анимации
}
procedure TfmTaskProgress.BtnAbortTaskClick(Sender: TObject);
begin
  // сообщаем форме владельцу о необходимости прервать задачу
  if assigned(OnTaskAbort) then
    OnTaskAbort;
end;

procedure TfmTaskProgress.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  OnTaskAbort := nil;
  tmrAnimate.Enabled := false;
end;

end.

