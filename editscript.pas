unit editscript;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ComCtrls, ExtCtrls, SynMemo, SynHighlighterPas, uPSComponent,
  uPSComponent_Default, uPSC_StrUtils, rxspin;

type

  { TfrmScriptEditor }

  TfrmScriptEditor = class(TForm)
    btnHelp: TBitBtn;
    btnLoadScript: TBitBtn;
    btnSaveScript: TBitBtn;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    cbScriptCategory: TComboBox;
    edScriptName: TEdit;
    edDescription: TEdit;
    lblScriptName: TLabel;
    lblDescription: TLabel;
    lblScriptCategory: TLabel;
    lblSelectedScript: TLabel;
    dlgOpen: TOpenDialog;
    pascalSyntaxHighlighter: TSynPasSyn;
    PSImport_Classes1: TPSImport_Classes;
    PSImport_StrUtils1: TPSImport_StrUtils;
    dlgSave: TSaveDialog;
    TestScript: TPSScript;
    PSImport_DateUtils1: TPSImport_DateUtils;
    cbScriptType: TComboBox;
    lblScriptType: TLabel;
    pnlScriptAndTestArea: TPanel;
    synmemCodeEditor: TSynMemo;
    Splitter2: TSplitter;
    pnlTestArea: TPanel;
    pnlTestPanels: TPanel;
    memoSource: TMemo;
    memoTarget: TMemo;
    pnlTestButton: TPanel;
    spdbtnTest: TSpeedButton;
    pnlTestAreaLabels: TPanel;
    lblInputData: TLabel;
    lblOutput: TLabel;
    Splitter1: TSplitter;
    sbar: TStatusBar;
    procedure btnHelpClick(Sender: TObject);
    procedure btnLoadScriptClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnSaveScriptClick(Sender: TObject);
    procedure spdbtnTestClick(Sender: TObject);
    procedure TestScriptAfterExecute(Sender: TPSScript);
    procedure TestScriptCompile(Sender: TPSScript);
    procedure TestScriptExecute(Sender: TPSScript);
    function ShowSaveDialog:string;
    function ShowOpenDialog:string;
    function IfFileExists(Filename:string):boolean;
    procedure ShowMessageDialog(Msg:String);
    procedure ErrorMessageDialog(Msg:string);
    function ConfirmationDialog(Msg:string):boolean;
    function InputBoxDialog(Title, Msg, DefaultText :String):string;
    procedure SetupSourceTestAreas;
    procedure SetupTargetTestAreas;
    procedure SetupScriptArea;
    procedure synmemCodeEditorClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Clippy:TStringList;
    ScriptID:Integer;
  end; 

var
  frmScriptEditor: TfrmScriptEditor;

implementation

uses main, db, options, EngLangRes;

{$R *.lfm}

{ TfrmScriptEditor }

procedure TfrmScriptEditor.TestScriptAfterExecute(Sender: TPSScript);
begin
  memoTarget.Text := Clippy.Text;
  Clippy.Free;
end;

procedure TfrmScriptEditor.spdbtnTestClick(Sender: TObject);
var idx:integer;
  Compiled:boolean;
  X:Integer;
  Y:Integer;
begin
  TestScript.Script.Text := synmemCodeEditor.Text;
  Compiled := TestScript.Compile;
  if Compiled then begin
    if not TestScript.Execute
      then MessageDlg(msgExecutionError, mtError, [mbOK], 0);
  end else begin
    for idx := 0 to TestScript.CompilerMessageCount-1
      do begin
        MessageDlg(msgErrorCompiling+':'+TestScript.CompilerMessages[idx].MessageToString, mtError, [mbOK], 0);
        X := TestScript.CompilerMessages[0].Col;
        Y := TestScript.CompilerMessages[0].Row;
        synmemCodeEditor.CaretX:=X;
        synmemCodeEditor.CaretY:=Y;
      end;
  end;
end;

procedure TfrmScriptEditor.btnOKClick(Sender: TObject);
begin
  ModalResult := mrNone;
  if (frmMain.Scripts.Locate('ScriptName',edScriptName.Text,[locaseinsensitive])) then begin
    //got one with the same name but it maybe the one we're editing in which case we're ok!
    if frmMain.Scripts.FieldByName('ScriptIndex').asInteger = ScriptID then begin
      ModalResult := mrOK;
    end else begin
      MessageDlg(msgScriptAlreadyExists, mtError, [mbOK], 0);
    end;
  end else begin
    ModalResult := mrOK;
  end;
end;

procedure TfrmScriptEditor.SetupScriptArea;
begin
  synmemCodeEditor.Lines.Assign(frmOptions.memoInitScript.Lines);
end;

procedure TfrmScriptEditor.synmemCodeEditorClick(Sender: TObject);
begin
  sbar.Panels[1].Text:= '['+IntToStr( synmemCodeEditor.CaretY )+':'+ IntToStr( synmemCodeEditor.CaretX )+']';
end;

procedure TfrmScriptEditor.SetupSourceTestAreas;
begin
  memoSource.Lines.Assign(frmOptions.memoInitData.Lines);
end;

procedure TfrmScriptEditor.SetupTargetTestAreas;
begin
  memoTarget.Lines.Clear;
end;

procedure TfrmScriptEditor.btnSaveScriptClick(Sender: TObject);
begin
  dlgSave.Filter := msgAllFiles;
  if dlgSave.Execute then begin
    synmemCodeEditor.Lines.SaveToFile(dlgOpen.Filename);
  end;
end;

procedure TfrmScriptEditor.btnLoadScriptClick(Sender: TObject);
begin
  dlgOpen.Filter := msgAllFiles;
  if dlgOpen.Execute then begin
    synmemCodeEditor.Lines.LoadFromFile(dlgOpen.Filename);
  end;
end;

procedure TfrmScriptEditor.btnHelpClick(Sender: TObject);
begin
  frmMain.btnHelpClick(Self);
end;

procedure TfrmScriptEditor.TestScriptCompile(Sender: TPSScript);
begin
  Clippy := TStringList.Create;
  Clippy.Text := memoSource.Text;
  Sender.AddRegisteredPTRVariable('Clippy','TStringList');
  Sender.AddMethod(Self, @TfrmScriptEditor.ShowSaveDialog, 'function ShowSaveDialog:string;');
  Sender.AddMethod(Self, @TfrmScriptEditor.ShowOpenDialog, 'function ShowOpenDialog:string;');
  Sender.AddMethod(Self, @TfrmScriptEditor.IfFileExists, 'function IfFileExists(Filename:String):boolean;');
  Sender.AddMethod(Self, @TfrmScriptEditor.ShowMessageDialog, 'procedure ShowMessage(Msg:string)');
  Sender.AddMethod(Self, @TfrmScriptEditor.ErrorMessageDialog, 'procedure ErrorMessage(Msg:string)');
  Sender.AddMethod(Self, @TfrmScriptEditor.ConfirmationDialog, 'function IsConfirmed(Msg:string):boolean;');
  Sender.AddMethod(Self, @TfrmScriptEditor.InputBoxDialog, 'function InputBox(Title, Msg, DefaultText :String):string;');
end;

procedure TfrmScriptEditor.TestScriptExecute(Sender: TPSScript);
begin
  Sender.SetPointerToData('Clippy',@Clippy, Sender.FindNamedType('TStringList'));
end;

function TfrmScriptEditor.ShowSaveDialog:string;
begin
  Result := '';
  dlgSave.Filter := msgAllFiles;
  if dlgSave.Execute then begin
    Result := dlgSave.FileName;
  end;
end;

function TfrmScriptEditor.ShowOpenDialog: string;
begin
  Result := '';
  dlgOpen.Filter := msgAllFiles;
  if dlgOpen.Execute then begin
    Result := dlgOpen.FileName;
  end;
end;

function TfrmScriptEditor.IfFileExists(Filename:string):boolean;
begin
  Result := FileExists(Filename);
end;

procedure TfrmScriptEditor.ShowMessageDialog(Msg:string);
begin
  MessageDlg(Msg, mtInformation, [mbOK], 0);
end;

procedure TfrmScriptEditor.ErrorMessageDialog(Msg:string);
begin
  MessageDlg(Msg, mtError, [mbOK], 0);
end;

function TfrmScriptEditor.ConfirmationDialog(Msg:string):boolean;
begin
  Result := MessageDlg(Msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

function TfrmScriptEditor.InputBoxDialog(Title, Msg, DefaultText :String):string;
begin
  Result := InputBox(Title, Msg, DefaultText);
end;

end.

