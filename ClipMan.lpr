
program ClipMan;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  main, editscript, aboutform, options, splashscreen, sysutils,
  //DefaultTranslator; //,
  Translations, LCLProc, pl_rx, pl_pascalscript;

{$R *.res}

  procedure TranslateLCL;
  var
    PODirectory, POFile, Lang, FallbackLang: String;
  begin
    PODirectory := 'other/languages/';
    POFile := PODirectory+ChangeFileExt(ExtractFileName(Application.ExeName),'.')+'%s.po';
    Lang:='en';
    FallbackLang:='en';
    LCLGetLanguageIDs(Lang,FallbackLang);
    Translations.TranslateUnitResourceStrings('EngLangRes', POFile, Lang, FallbackLang);
  end;

begin
  TranslateLCL;
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.ShowMainForm := False;
  Application.CreateForm(TfrmSplashScreen, frmSplashScreen);
  frmSplashScreen.Show;
  frmSplashScreen.imgTimer.Enabled:=True;
  Application.CreateForm(TfrmScriptEditor, frmScriptEditor);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.Run;
end.

