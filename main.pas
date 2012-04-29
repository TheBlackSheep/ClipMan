unit main; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, Menus, DbCtrls, DBGrids, db, uPSUtils,
  uPSComponent_Default, uPSComponent, uPSC_strutils, RxMemDS, LCLIntf;

type

  { TfrmMain }
  TfrmMain = class(TForm)
    btnAdd: TBitBtn;
    btnEdit: TBitBtn;
    btnDelete: TBitBtn;
    btnClose: TBitBtn;
    cbScriptCategory: TComboBox;
    dbgridScripts: TDBGrid;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    dsScripts: TDatasource;
    Scripts: TRxMemoryData;
    ScriptsCategory: TStringField;
    ScriptsDescription: TStringField;
    ScriptsScript1: TMemoField;
    ScriptsScriptIndex1: TLongintField;
    ScriptsScriptName: TStringField;
    ScriptsScriptType: TLongintField;
    lblScriptCategory: TLabel;
    MenuItem1: TMenuItem;
    miOptions: TMenuItem;
    miLoadFromFile: TMenuItem;
    miSaveToFile: TMenuItem;
    MenuItem9: TMenuItem;
    miClearClipbrd: TMenuItem;
    miAbout: TMenuItem;
    MenuItem2: TMenuItem;
    miExit: TMenuItem;
    MenuItem4: TMenuItem;
    miScripts: TMenuItem;
    miEditScripts: TMenuItem;
    popupClipManMenu: TPopupMenu;
    PSImport_Classes1: TPSImport_Classes;
    PSImport_DateUtils1: TPSImport_DateUtils;
    PSImport_StrUtils1: TPSImport_StrUtils;
    RuntimeScript: TPSScript;
    ScriptsTestData1: TMemoField;
    tryicnClipman: TTrayIcon;
    BalloonTimer: TTimer;
    btnHelp: TBitBtn;
    miHelp: TMenuItem;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure cbScriptCategoryChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miClearClipbrdClick(Sender: TObject);
    procedure miLoadFromFileClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miEditScriptsClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure miSaveToFileClick(Sender: TObject);
    procedure popupClipManMenuPopup(Sender: TObject);
    procedure popupScriptsClick(Sender: TObject);
    procedure RuntimeScriptAfterExecute(Sender: TPSScript);
    procedure RuntimeScriptCompile(Sender: TPSScript);
    procedure RuntimeScriptExecute(Sender: TPSScript);
    procedure UpdateScriptNames;
    function ShowSaveDialog:string;
    function ShowOpenDialog:string;
    function IfFileExists(Filename:string):boolean;
    procedure ShowMessageDialog(Msg:string);
    function InputBoxDialog(Title, Msg, DefaultText :String):string;
    function ConfirmationDialog(Msg:string):boolean;
    procedure ErrorMessageDialog(Msg:string);
    procedure BalloonTimerTimer(Sender: TObject);
    procedure populateCategoryCombo(Strings:TStrings);
    procedure RefreshCombo;
  private
    { private declarations }
    ScriptsDAT:String;
    ScriptInProgress:boolean;
    WindowBeingShown:boolean;
  public
    { public declarations }
    Clippy:TStringList;
  end;

var
  frmMain: TfrmMain;

implementation

uses LCLType, Clipbrd, editscript, aboutform, fpimage, FPDitherer,
     FPQuantizer, FPReadBMP, FPWriteBMP, options, LResources, EngLangRes;

{$R *.lfm}

  { TfrmMain }

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Hide;
end;

procedure TfrmMain.populateCategoryCombo(Strings:TStrings);
var Category:String;
    FilterState:Boolean;
begin
  Scripts.DisableControls;
  FilterState := Scripts.Filtered;
  Scripts.Filtered := False;
  Strings.Clear;
  Scripts.First;
  while not Scripts.EOF do begin
    Category := Scripts.FieldByName('category').AsString;
    if (Category <> '') and (Strings.IndexOf(Category) = -1)
       then Strings.Add(Category);
    Scripts.Next;
  end;
  Scripts.Filtered := FilterState;
  Scripts.EnableControls;
end;

procedure TfrmMain.btnEditClick(Sender: TObject);
var ScriptIndex:Integer;
    ScriptCategory:String;
begin
  if Scripts.RecordCount > 0 then begin
    //need to get the Index of the currently selected script (or the one doubleclicked upon)
    ScriptCategory := cbScriptCategory.Text;
    ScriptIndex := Scripts.FieldByName('ScriptIndex').asInteger;
    frmScriptEditor.ScriptID := ScriptIndex;
    frmScriptEditor.edScriptName.Text := Scripts.FieldByName('ScriptName').asString;
    frmScriptEditor.cbScriptCategory.Text := Scripts.FieldByName('Category').asString;
    frmScriptEditor.edDescription.Text := Scripts.FieldByName('Description').asString;
    frmScriptEditor.synmemCodeEditor.Text := Scripts.FieldByName('Script').asString;
    frmScriptEditor.memoSource.Text := Scripts.FieldByName('TestData').asString;
    frmScriptEditor.SetupTargetTestAreas;

    populateCategoryCombo(frmScriptEditor.cbScriptCategory.Items);

    if frmScriptEditor.ShowModal = mrOK then begin
      //need to find the original in case the search
      //for a scriptname conflict on the edit page moved the database cursor
      Scripts.Locate('ScriptIndex',frmScriptEditor.ScriptID,[]);
      Scripts.Edit;
      Scripts.FieldByName('ScriptName').asString := frmScriptEditor.edScriptName.Text;
      Scripts.FieldByName('Category').asString := frmScriptEditor.cbScriptCategory.Text;
      Scripts.FieldByName('Script').asString := frmScriptEditor.synmemCodeEditor.Text;
      Scripts.FieldByName('TestData').AsString := frmScriptEditor.memoSource.Lines.Text;
      Scripts.FieldByName('Description').asString := frmScriptEditor.edDescription.Text;
      Scripts.Post;
    end;
  end;
  Scripts.SaveToFile(ScriptsDAT);
  RefreshCombo;
  cbScriptCategory.Text := ScriptCategory;
  UpdateScriptNames;
  //relocate the script we edited!
  Scripts.Locate('ScriptIndex',ScriptIndex,[]);
end;

procedure TfrmMain.btnHelpClick(Sender: TObject);
var clippyHelpFile:String;
begin
  clippyHelpFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))
             +IncludeTrailingPathDelimiter('Other')+IncludeTrailingPathDelimiter('Help')+'ClipmanHelp.html';
  if FileExists(clippyHelpFile) then begin
    OpenURL(clippyHelpFile);
  end else begin

  end;
end;

procedure TfrmMain.cbScriptCategoryChange(Sender: TObject);
begin
  if cbScriptCategory.Text <> '' then begin
    Scripts.Filter := 'Category = '+#39+cbScriptCategory.Text+#39;
    Scripts.Filtered := True;
  end else begin
    Scripts.Filtered := False;
    Scripts.Filter := '';
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ScriptsDAT := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))
                +IncludeTrailingPathDelimiter('Data')+'Scripts.DAT';
  Scripts.Active := True;
  if FileExists(ScriptsDAT) then begin
    Scripts.LoadFromFile(ScriptsDAT);
  end;
  UpdateScriptNames;
end;

procedure TfrmMain.RefreshCombo;
begin
  populateCategoryCombo(cbScriptCategory.Items);
  cbScriptCategory.Items.Insert(0,'');
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  RefreshCombo;
  Scripts.First;
end;

procedure TfrmMain.btnDeleteClick(Sender: TObject);
var ScriptName:String;
    ScriptCategory:String;
begin
  ScriptCategory := cbScriptCategory.Text;
  if Scripts.RecordCount > 0 then begin
    ScriptName := Scripts.FieldByName('ScriptName').asString;
    if (MessageDlg(msgConfirmDelete+' "'+ ScriptName+'"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then begin
      Scripts.Delete;
    end;
  end;
  //deleting should position us on the next in the list/grid
  ScriptName := Scripts.FieldByName('ScriptName').asString;
  Scripts.SaveToFile(ScriptsDAT);
  RefreshCombo;
  cbScriptCategory.Text := ScriptCategory;
  UpdateScriptNames;
  //now we refind the "Next" one - just looks cleaner than going to the start of the list again
  Scripts.Locate('ScriptName', ScriptName, [locaseinsensitive]);
end;

procedure TfrmMain.btnAddClick(Sender: TObject);
var idx:integer;
    ScriptName:String;
    HashedScriptName:LongInt;
    ScriptCategory:String;
begin
  idx := 1;
  repeat
    ScriptName := 'NewScript'+IntToStr(idx);
    inc(idx);
  until not Scripts.Locate('ScriptName',ScriptName,[locaseinsensitive]);
  ScriptCategory := cbScriptCategory.Text;
  frmScriptEditor.edScriptName.Text := ScriptName;
  frmScriptEditor.edDescription.Text := '';
  populateCategoryCombo(frmScriptEditor.cbScriptCategory.Items);
  //assume that if we have the filter enabled then we want to add to that category
  frmScriptEditor.cbScriptCategory.Text := ScriptCategory;
  frmScriptEditor.SetupScriptArea;
  frmScriptEditor.SetupSourceTestAreas;
  frmScriptEditor.SetupTargetTestAreas;

  if frmScriptEditor.ShowModal = mrOK then begin
    ScriptName := frmScriptEditor.edScriptName.Text;
    //ensure it's got a unique index!
    HashedScriptName := Hash(Scriptname);
    while Scripts.Locate('ScriptIndex',HashedScriptName,[]) do begin
      HashedScriptName := Hash(Scriptname) + 1;
    end;
    Scripts.Append;
    Scripts.FieldByName('ScriptIndex').asInteger := HashedScriptName;
    Scripts.FieldByName('ScriptName').asString := Scriptname;
    Scripts.FieldByName('Category').asString := frmScriptEditor.cbScriptCategory.Text;
    Scripts.FieldByName('Description').asString := frmScriptEditor.edDescription.Text;
    Scripts.FieldByName('Script').AsString := frmScriptEditor.synmemCodeEditor.Lines.Text;
    Scripts.FieldByName('TestData').AsString := frmScriptEditor.memoSource.Lines.Text;
    Scripts.FieldByName('ScriptType').AsInteger := frmScriptEditor.cbScriptType.ItemIndex; //for potential different types of clipboard maniuplation in future
    Scripts.Post;
  end;
  Scripts.SaveToFile(ScriptsDAT);
  RefreshCombo;
  cbScriptCategory.Text := ScriptCategory;
  UpdateScriptNames;
  //find the one we've just added
  Scripts.Locate('ScriptIndex',HashedScriptName,[]);
end;

procedure TfrmMain.miAboutClick(Sender: TObject);
begin
  if WindowBeingShown then Exit;
  WindowBeingShown := True;
  frmAbout.ShowModal;
  WindowBeingShown := False;
end;

procedure TfrmMain.miClearClipbrdClick(Sender: TObject);
begin
  //this doesn't always work
  Clipboard.Clear;
  //so lets try this too!
  Clipboard.AsText := '';
  tryicnClipman.BalloonTitle := '';
  tryicnClipman.BalloonHint := msgClipboardCleared;
  tryicnClipman.ShowBalloonHint;
  BalloonTimer.Interval := Trunc(frmOptions.spineditPeriod.Value * 1000);
  BalloonTimer.Enabled:=true;
end;

procedure TfrmMain.miLoadFromFileClick(Sender: TObject);
var Filename, FileExt:String;
    Image:TImage;

  procedure LoadFileAsText(Filename:String);
  var
    T:TStringList;
  begin
    T := TStringList.Create;
    T.LoadFromFile(Filename);
    Clipboard.AsText:= T.Text;
    T.Free;
  end;

begin
  if WindowBeingShown then Exit;
  WindowBeingShown := True;

  dlgOpen.FileName:='';
  dlgOpen.Title:= msgLoadFileTitle;
  dlgOpen.Filter := msgLoadFiles;
  dlgOpen.FilterIndex := 1;
  if dlgOpen.Execute then begin
    Filename := dlgOpen.FileName;
    FileExt := ExtractFileExt(dlgOpen.FileName);
    if (CompareText(FileExt,'.txt') = 0) or (CompareText(FileExt,'.txt') = 0) or (CompareText(FileExt,'.txt') = 0) then begin
      LoadFileAsText(Filename);
    end else begin
      if (CompareText(FileExt,'.bmp') = 0) or (CompareText(FileExt,'.jpg') = 0) or (CompareText(FileExt,'.img') = 0) then begin
        Image := TImage.Create(self);
        Image.Picture.LoadFromFile(Filename);
        Clipboard.Assign(Image.picture.bitmap);
        Image.Free;
      end else begin
        if MessageDlg(msgFormatNotRecognisedTitle, msgFormatNotRecognised+#13#10+MsgFormatNotRecognisedTryToLoad, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
          LoadFileAsText(Filename);
        end;
      end;
    end;
  end;
  WindowBeingShown := False;
end;

procedure ReduceBitmapColors(BMPFile:String);
var
    SourceBitmap, TargetBitmap:  TFPMemoryImage;
    FPMedianCutQuantizer : TFPMedianCutQuantizer;
    FPPalette : TFPPalette;
    FPFloydSteinbergDitherer:TFPFloydSteinbergDitherer;
    ImageReader : TFPReaderBMP;
    ImageWriter : TFPWriterBMP;
begin
  if FileExists(BMPFile) then begin
    SourceBitmap := TFPMemoryImage.Create(0,0);
    TargetBitmap := TFPMemoryImage.Create(0,0);
    ImageReader := TFPReaderBMP.Create;
    ImageWriter := TFPWriterBMP.create;
    try
      SourceBitmap.LoadFromFile(BMPFile);
      FPMedianCutQuantizer  := TFPMedianCutQuantizer.Create;
      FPMedianCutQuantizer.Add(SourceBitmap);
      FPPalette := FPMedianCutQuantizer.Quantize;
      FPFloydSteinbergDitherer := TFPFloydSteinbergDitherer.Create(FPPalette);
      FPFloydSteinbergDitherer.Dither(SourceBitmap, TargetBitmap);
      ImageWriter.BitsPerPixel:=8;
      TargetBitmap.SaveToFile(BMPFile, ImageWriter);
    finally
      SourceBitmap.Free;
      TargetBitmap.Free;
      FPMedianCutQuantizer.Free;
      FPFloydSteinbergDitherer.Free;
      ImageReader.Free;
      ImageWriter.Free;
    end;
  end;
end;

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.UpdateScriptNames;
var NewMenuItem:TMenuItem;
    SubMenu:TMenuItem;
    ScriptIndex:Integer;
    Category:String;
    LastCategory:String;
    FilterState:Boolean;
begin
  FilterState := Scripts.Filtered;
  if Filterstate then begin
    Scripts.Filtered := False;
  end;
  ScriptIndex := Scripts.FieldByName('ScriptIndex').asInteger;
  Scripts.SortOnFields('Category;ScriptName');
  LastCategory := '';
  miScripts.Clear;
  Scripts.First;
  while not Scripts.EOF do begin
    //need to create a category submenu if this isn't blank
    Category := Scripts.FieldByName('Category').asString;
    if Category <> '' then begin
      if Category <> LastCategory then begin
        //create new submenu
        SubMenu := TMenuItem.Create(miScripts);
        SubMenu.Caption := Category;
        miScripts.Add(SubMenu);
      end;
      NewMenuItem := TMenuItem.Create(SubMenu);
      NewMenuItem.Caption := Scripts.FieldByName('ScriptName').asString;;
      NewMenuItem.Tag := Scripts.FieldByName('ScriptIndex').asInteger;
      NewMenuItem.Hint := Scripts.FieldByName('Description').asString;
      NewMenuItem.OnClick := @popupScriptsClick;
      SubMenu.Add(NewMenuItem);
    end else begin
      NewMenuItem := TMenuItem.Create(miScripts);
      NewMenuItem.Caption := Scripts.FieldByName('ScriptName').asString;;
      NewMenuItem.Tag := Scripts.FieldByName('ScriptIndex').asInteger;
      NewMenuItem.Hint := Scripts.FieldByName('Description').asString;
      NewMenuItem.OnClick := @popupScriptsClick;
      miScripts.Add(NewMenuItem);
    end;
    Scripts.Next;
    LastCategory := Category;
  end;
  Scripts.Locate('ScriptIndex',ScriptIndex,[]);
  if FilterState then begin
    Scripts.Filtered := True;
  end;
end;

procedure TfrmMain.miEditScriptsClick(Sender: TObject);
begin
  if WindowBeingShown then Exit;
  WindowBeingShown := True;
  //make sure filter is turned off before displaying the window!
  Scripts.Filtered := False;
  Scripts.Filter := '';
  UpdateScriptNames;
  ShowModal;
  WindowBeingShown := False;
  //make sure filter is turned off again after window closes!
  Scripts.Filtered := False;
  Scripts.Filter := '';
end;

procedure TfrmMain.miOptionsClick(Sender: TObject);
begin
  if WindowBeingShown then Exit;
  WindowBeingShown := True;
  frmOptions.ShowModal;
  WindowBeingShown := False;
end;

procedure TfrmMain.miSaveToFileClick(Sender: TObject);
var FileExt:String;
    Filename:String;

  procedure SaveClipboardAsText(Filename:String);
  var
    T:TStringList;
  begin
    T := TStringList.Create;
    T.Text := Clipboard.AsText;
    T.SaveToFile(Filename);
    T.Free;
  end;

  procedure SaveClipboardAsImage(Filename:String; FileExt:String; LimitColors:Boolean);
  var cfPng:TClipboardFormat;
      cfJpg:TClipboardFormat;
      strm:TMemoryStream;
      Image:TImage;
     // SupportedFormats:TStringList;
  begin
    {SupportedFormats := TStringList.Create;
    Clipboard.SupportedFormats(SupportedFormats); //see what's there
    ShowMessage(SupportedFormats.Text);
    SupportedFormats.Free;        }

    Image := TImage.Create(Self);

    cfPng:=RegisterClipboardFormat('image/png');
    cfJpg:=RegisterClipboardFormat('image/jpeg');

    strm:=TMemoryStream.create;
     if Clipboard.HasFormat(cf_bitmap) then begin    //this doesn't appear to work in windows
       Clipboard.GetFormat(cf_bitmap,strm);
       strm.Position:=0;
       Image.Picture.LoadFromStream(strm);
    end else begin
        if Clipboard.HasFormat(cfPng) then begin
          Clipboard.GetFormat(cfPng,strm);
          strm.Position:=0;
          Image.Picture.LoadFromStream(strm);
        end else begin
            if Clipboard.HasFormat(cfJpg) then begin
              Clipboard.GetFormat(cfJpg,strm);
              strm.Position:=0;
              Image.Picture.LoadFromStream(strm);
            end else begin
              try
                Image.Picture.LoadFromClipboardFormat(cf_bitmap); //but this does and on Linux we've already taken a different route
              except
                MessageDlg(msgImageFormatNotSupported, mtInformation, [mbOK] ,0);
                Exit;
              end;
            end;
        end;
    end;
    strm.free;

    Image.Picture.SaveToFile(Filename, FileExt);
    Image.Free;

    if LimitColors then begin
      ReduceBitmapColors(Filename);
    end;
  end;

begin
  if WindowBeingShown then Exit;
  WindowBeingShown := True;

  dlgSave.FileName:='';
  if Clipboard.HasPictureFormat then begin
    dlgSave.Title:= msgSaveImgClipboardTitle;
    dlgSave.Filter := msgSaveImgClipboardFilter;
  end else begin
    dlgSave.Title := msgSaveTxtClipboardTitle;
    dlgSave.Filter := msgSaveTxtClipboardFilter ;
  end;
  dlgSave.FilterIndex := 1;
  if dlgSave.Execute then begin
    //Save Clipboard contents to filetype
    Filename := dlgSave.FileName;
    if Clipboard.HasPictureFormat then begin
      if ((CompareText(ExtractFileExt(Filename),'.bmp') = 0)
       or (CompareText(ExtractFileExt(FileName),'.jpg') = 0)
       or (CompareText(ExtractFileExt(FileName),'.png') = 0)
       or (CompareText(ExtractFileExt(FileName),'.xpm') = 0)
       ) then begin
        FileExt := ExtractFileExt(Filename);
      end else begin
        case dlgSave.FilterIndex of
          1,4 : FileExt := '.bmp';
          2   : FileExt := '.jpg';
          3   : FileExt := '.png';
          5   : FileExt := '.xpm';
        end;
        Filename := ChangeFileExt(Filename, FileExt);
      end;
      SaveClipboardAsImage(FileName, FileExt, dlgSave.FilterIndex = 4);
    end else begin
      if ((CompareText(ExtractFileExt(Filename),'.txt') = 0)
       or (CompareText(ExtractFileExt(FileName),'.csv') = 0)
       or (CompareText(ExtractFileExt(FileName),'.tab') = 0)) then begin
        FileExt := ExtractFileExt(Filename);
      end else begin
        case dlgSave.FilterIndex of
          1 : FileExt := '.txt';
          2 : FileExt := '.csv';
          3 : FileExt := '.tab';
        end;
        Filename := ChangeFileExt(Filename, FileExt);
      end;
      SaveClipboardAsText(FileName);
    end;
  end;
  WindowBeingShown := False;
end;

procedure TfrmMain.popupClipManMenuPopup(Sender: TObject);
begin
  //reserved for future use!!!
  //check what's on the clipboard - if it's a bitmap then only enable the bitmapscripts (scripttype = 1)
  //else if it's text then only scripts of scripttype = 0
end;

procedure TfrmMain.popupScriptsClick(Sender: TObject);
var ScriptMenuItem:TMenuItem;
    ScriptIndex:Integer;
    Compiled:boolean;
    idx:integer;
begin
  if WindowBeingShown then Exit;
  WindowBeingShown := True;
  if ScriptInProgress then exit;
  ScriptInProgress := True;

  BalloonTimer.Enabled:=False;
  if Clipboard.HasFormat(cf_text) or (not (Clipboard.HasFormat(cf_bitmap) or Clipboard.HasFormat(cf_picture) or Clipboard.HasFormat(cf_metafilepict))) then begin
    ScriptMenuItem := Sender as TMenuItem;
    ScriptIndex := ScriptMenuItem.Tag;;
    if Scripts.Locate('ScriptIndex',ScriptIndex,[]) then begin
      RuntimeScript.Script.Text := Scripts.FieldByName('Script').asString;
      Compiled := RuntimeScript.Compile;
      if Compiled then begin
        if not RuntimeScript.Execute
          then MessageDlg(msgExecutionError, mtError, [mbOK], 0);
      end else begin
        for idx := 0 to RuntimeScript.CompilerMessageCount-1
          do MessageDlg(msgErrorCompiling+':'+RuntimeScript.CompilerMessages[idx].MessageToString, mtError, [mbOK], 0);
      end;
    end;
  end else begin
    MessageDlg(msgClpbrdFrmtNotSpprtdForScriptsTitle, msgClpbrdFrmtNotSpprtdForScripts, mtInformation, [mbOK], 0);
  end;
  WindowBeingShown := False;
  ScriptInProgress := False;
end;

procedure TfrmMain.RuntimeScriptAfterExecute(Sender: TPSScript);
var T:TStringList;
    ScriptName:String;
begin
  Clipboard.AsText := Clippy.Text;
  Clippy.Free;
  if frmOptions.chkbxShowBalloon.Checked then begin
    ScriptName := Scripts.FieldByName('ScriptName').AsString;
    tryicnClipman.BalloonTitle := msgScriptExecutedTitle +ScriptName+ msgScriptExecutedSuccess;
    T := TStringList.Create;
    T.Text := Clipboard.AsText;
    if T.Count > 5 then begin
      while T.Count > 5 do T.Delete(T.Count-1); //only show the 1st 5 lines
      T.Add('...');  //indicate there's more!
    end;
    tryicnClipman.BalloonHint := T.Text;
    T.Free;
    tryicnClipman.ShowBalloonHint;
    BalloonTimer.Interval := Trunc(frmOptions.spineditPeriod.Value * 1000);
    BalloonTimer.Enabled:=true;
  end;
end;

procedure TfrmMain.RuntimeScriptCompile(Sender: TPSScript);
begin
  Clippy := TStringList.Create;
  Clippy.Text := Clipboard.AsText;
  Sender.AddRegisteredPTRVariable('Clippy','TStringList');
  Sender.AddMethod(Self, @TfrmMain.ShowSaveDialog, 'function ShowSaveDialog:string;');
  Sender.AddMethod(Self, @TfrmMain.ShowOpenDialog, 'function ShowOpenDialog:string;');
  Sender.AddMethod(Self, @TfrmMain.IfFileExists, 'function IfFileExists(Filename:String):boolean;');
  Sender.AddMethod(Self, @TfrmMain.ShowMessageDialog, 'procedure ShowMessage(Msg:string)');
  Sender.AddMethod(Self, @TfrmMain.ErrorMessageDialog, 'procedure ErrorMessage(Msg:string)');
  Sender.AddMethod(Self, @TfrmMain.ConfirmationDialog, 'function IsConfirmed(Msg:string):boolean;');
  Sender.AddMethod(Self, @TfrmMain.InputBoxDialog, 'function InputBox(Title, Msg, DefaultText :String):string;');
end;

procedure TfrmMain.RuntimeScriptExecute(Sender: TPSScript);
begin
  Sender.SetPointerToData('Clippy',@Clippy, Sender.FindNamedType('TStringList'));
end;

function TfrmMain.ShowSaveDialog:string;
begin
  Result := '';
  dlgSave.FilterIndex:=1;
  dlgSave.Filter := msgAllFiles;
  if dlgSave.Execute then begin
    Result := dlgSave.FileName;
  end;
end;

function TfrmMain.ShowOpenDialog: string;
begin
  Result := '';
  dlgOpen.FilterIndex:=1;
  dlgOpen.Filter := msgAllFiles;
  if dlgOpen.Execute then begin
    Result := dlgOpen.FileName;
  end;
end;

procedure TfrmMain.ShowMessageDialog(Msg:string);
begin
  MessageDlg(Msg, mtInformation, [mbOK], 0);
end;

function TfrmMain.IfFileExists(Filename:string):boolean;
begin
  Result := FileExists(Filename);
end;

procedure TfrmMain.ErrorMessageDialog(Msg:string);
begin
  MessageDlg(Msg, mtError, [mbOK], 0);
end;

function TfrmMain.ConfirmationDialog(Msg:string):boolean;
begin
  Result := MessageDlg(Msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

function TfrmMain.InputBoxDialog(Title, Msg, DefaultText :String):string;
begin
  Result := InputBox(Title, Msg, DefaultText);
end;

procedure TfrmMain.BalloonTimerTimer(Sender: TObject);
begin
  //a blank Balloonhint closes the hint window
  tryicnClipman.BalloonHint :='';
  tryicnClipman.ShowBalloonHint;
  BalloonTimer.Enabled:=false;
end;

end.

