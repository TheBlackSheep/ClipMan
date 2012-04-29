unit EngLangRes; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

resourcestring
  msgConfirmDelete = 'Are you sure you want to delete the script named';
  msgFormatNotRecognisedTitle = 'File format not recognised';
  msgFormatNotRecognised = 'Sorry, unable to recognise that particular filetype!';
  msgFormatNotRecognisedTryToLoad = 'Do you want to try and load it as a text file anyway?';
  msgImageFormatNotSupported = 'Sorry, image type not supported';
  msgExecutionError = 'Execution Error: Something went wrong executing script!';
  msgErrorCompiling = 'Error compiling:';
  msgClpbrdFrmtNotSpprtdForScriptsTitle = 'Clipboard format not supported for scripts!';
  msgClpbrdFrmtNotSpprtdForScripts = 'Sorry, the clipboard contains data of a format that is currently unsupported for using with a script!';
  msgClipboardCleared = 'Clipboard cleared!';
  msgAllFiles = 'All files (*.*)|*.*';
  msgLoadFileTitle = 'Load a file to the clipboard...';
  msgLoadFiles = 'Text files (*.txt, *.csv, *.tab)|*.TXT;*.CSV;*.TAB|Images (*.bmp, *.jpg, *.png)|*.BMP;*.JPG;*.PNG;|All Files (*.*)|*.*';
  msgScriptExecutedTitle = 'Clipman script "';
  msgScriptExecutedSuccess = '" executed ok!';
  msgSaveImgClipboardTitle = 'Save image on clipboard as...';
  msgSaveImgClipboardFilter = 'Bitmap images (*.bmp)|*.BMP|JPEG Images (*.jpg)|*.JPG|Portable Network Graphic Image (*.png)|*.PNG|[Experimental] 256 Color Bitmap (*.bmp)|*.bmp|X Pixmap File (*.xpm)|*.XPM';
  msgSaveTxtClipboardTitle = 'Save text on clipboard as...';
  msgSaveTxtClipboardFilter = 'Text files (*.txt)|*.TXT|CSV Files (*.csv)|*.CSV|Tab Files (*.tab)|*.TAB';
  msgScriptAlreadyExists = 'A script with this name already exists!';

  msgAboutMessageLine1 = 'Written by TheBlackSheep using FreePascal && Lazarus ';
  msgAboutMessageLine2 = 'as a demonstration of some of the components and to ';
  msgAboutMessageLine3 = 'make something useful for all Pascal developers ';
  msgAboutMessageLine4 = '(and other geeks) out there!';
  msgAboutCreditsLine1 = 'Credits go to;';
  msgAboutCreditsLine2 = '  the Awesome FPC/Lazarus team';
  msgAboutCreditsLine3 = '  PilotLogic for CodeTyphon';
  msgAboutCreditsLine4 = '  Carlo Kok (RemObjects) for the Open Source PascalScript';
  msgAboutCreditsLine5 = '  && the excellent SynEditor components';
  msgAboutUseLine1 = 'Free for all uses!';
  msgAboutUseLine2 = 'Please make suggestions for improvements!';

implementation

end.

