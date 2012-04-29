unit aboutform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    imgClipboard: TImage;
    lblUse: TLabel;
    lblTheByWhomWhatWhere: TLabel;
    lblCredits: TLabel;
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmAbout: TfrmAbout;

implementation

uses EngLangRes, VInfo, versiontypes, versionresource;

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.FormKeyPress(Sender: TObject; var Key: char);
begin
  Close;
end;

procedure TfrmAbout.FormClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
var Info: TVersionInfo;

  function ProductVersionToString(PV: TFileProductVersion): String;
  begin
    Result := Format('%d.%d.%d (Build: %d)', [PV[0],PV[1],PV[2],PV[3]])
  end;

begin
  Info := TVersionInfo.Create;
  Info.Load(HINSTANCE);

  lblUse.Caption :=  msgAboutUseLine1+#13#10+msgAboutUseLine2+#13#10+
                     Info.StringFileInfo[0].Values['ProductName']+' '
                     +ProductVersionToString(Info.FixedInfo.FileVersion);;
  Info.Free;

  lblTheByWhomWhatWhere.Caption:= msgAboutMessageLine1
                                 +msgAboutMessageLine2
                                 +msgAboutMessageLine3
                                 +msgAboutMessageLine4;

  lblCredits.Caption:= msgAboutCreditsLine1+#13#10
                      +msgAboutCreditsLine2+#13#10
                      +msgAboutCreditsLine3+#13#10
                      +msgAboutCreditsLine4+#13#10
                      +msgAboutCreditsLine5;
end;

end.

