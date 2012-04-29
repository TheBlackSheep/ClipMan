unit options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, XMLPropStorage, Spin;

type

  { TfrmOptions }

  TfrmOptions = class(TForm)
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    spineditPeriod: TFloatSpinEdit;
    lblScriptAddNew: TLabel;
    lblInitialTestData: TLabel;
    memoInitScript: TMemo;
    memoInitData: TMemo;
    frmStorage: TXMLPropStorage;
    chkbxShowBalloon: TCheckBox;
    lblPeriod: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure chkbxShowBalloonChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    OptionsCFG:String;
  end; 

var
  frmOptions: TfrmOptions;

implementation

{$R *.lfm}

{ TfrmOptions }

procedure TfrmOptions.FormCreate(Sender: TObject);
begin
  OptionsCFG := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))
                +IncludeTrailingPathDelimiter('Data')+'ClipMan.cfg';
  frmStorage.FileName := OptionsCFG;
  frmStorage.Restore;
end;

procedure TfrmOptions.FormDestroy(Sender: TObject);
begin
  frmStorage.Save;
end;

procedure TfrmOptions.btnOkClick(Sender: TObject);
begin
  frmStorage.Save;
end;

procedure TfrmOptions.chkbxShowBalloonChange(Sender: TObject);
begin
  spineditPeriod.Enabled := chkbxShowBalloon.Checked;
end;

procedure TfrmOptions.btnCancelClick(Sender: TObject);
begin
  frmStorage.Restore;
end;

end.

