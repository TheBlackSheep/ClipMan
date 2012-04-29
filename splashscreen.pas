unit splashscreen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TfrmSplashScreen }

  TfrmSplashScreen = class(TForm)
    imgSplash: TImage;
    imgTimer: TTimer;
    procedure imgSplashClick(Sender: TObject);
    procedure imgTimerTimer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmSplashScreen: TfrmSplashScreen;

implementation

{$R *.lfm}

{ TfrmSplashScreen }

procedure TfrmSplashScreen.imgTimerTimer(Sender: TObject);
begin
  Hide;
end;

procedure TfrmSplashScreen.imgSplashClick(Sender: TObject);
begin
  imgTimer.Enabled := False;
  Hide;
end;

end.

