unit kMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.IniFiles,
  System.IOUtils,
  System.StrUtils,
  Clipbrd, Vcl.Tabs, Vcl.ExtCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg,
  Vcl.ExtDlgs;

type
  TResultType = (rtText, rtImage);

type
  TFrmMain = class(TForm)
    edtAsk: TEdit;
    btnSubmit: TButton;
    memResult: TMemo;
    btnClear: TButton;
    Label1: TLabel;
    btnCopyToClipbrd: TButton;
    pnlResult: TPanel;
    imgResult: TImage;
    btnImage: TButton;
    IdHTTP: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    SavePictureDialog: TSavePictureDialog;
    procedure btnSubmitClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnCopyToClipbrdClick(Sender: TObject);
    procedure btnImageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fAPIKey    : String;
    fResultType: TResultType;

    function ReadIniFile: Boolean;
    procedure SendTextRequest;
    procedure SendImgRequest;
    procedure AdjustPanel;
  public
    property ResultType: TResultType read fResultType write fResultType;
  end;

var
  FrmMain: TFrmMain;
  IsImage: Boolean;
  DllPath: String;

implementation

uses
  OpenAI,
  OpenAI.Completions,
  OpenAI.Images,
  IdSSLOpenSSLHeaders;

{$R *.dfm}

{ TFrmMain }

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  pnlResult.Caption:='Result shows here...';
  memResult.Visible:=False;
  imgResult.Visible:=False;
  IsImage:=False;
  DllPath:='';
end;
{______________________________________________________________________________}
procedure TFrmMain.AdjustPanel;
begin
  if (ResultType=rtImage) then begin
    imgResult.Visible:= True;
    imgResult.Align:= alClient;
    memResult.Visible:= False;
  end else
  if (ResultType=rtText) then begin
    imgResult.Visible:= False;
    memResult.Align:= alClient;
    memResult.Visible:= true;
  end;

end;
{______________________________________________________________________________}
procedure TFrmMain.btnClearClick(Sender: TObject);
begin
  memResult.Clear;
  imgResult.Picture:=nil;
  btnCopyToClipbrd.Enabled:=False;
  IsImage:=False;
  edtAsk.Clear;
  pnlResult.Caption:='Result shows here...'
end;
{______________________________________________________________________________}
procedure TFrmMain.btnCopyToClipbrdClick(Sender: TObject);
  // copy text result to clipboard
  procedure CopyText;
  begin
    if (memResult.Lines.Text <> '') then
      Clipboard.AsText:= memResult.Lines.Text;
  end;

  procedure DownloadImage;
  begin
    SavePictureDialog.Execute;
    if SavePictureDialog.FileName <> '' then
      imgResult.Picture.SaveToFile(SavePictureDialog.FileName);
  end;
begin
  case ResultType of
    rtText :CopyText;
    rtImage:
      if (imgResult.Picture <> nil) then
        DownloadImage;
  end;

end;
{______________________________________________________________________________}
procedure TFrmMain.btnImageClick(Sender: TObject);
begin
  IsImage:= True;
  ResultType:= rtImage;
  if (edtAsk.Text <> '')then begin
    Self.SendImgRequest
  end else
    ShowMessage('Please fill the input field!')
end;
{______________________________________________________________________________}
procedure TFrmMain.btnSubmitClick(Sender: TObject);
begin
  IsImage:=False;
  ResultType:= rtText;
  if (edtAsk.Text <> '')then
    Self.SendTextRequest
  else
    ShowMessage('Please fill the input field!')
end;
{______________________________________________________________________________}
function TFrmMain.ReadIniFile: Boolean;
var
  iniFile: TIniFile;
  Path: String;
  ImgPath: String;
begin

  // get file path
  Path:= ExtractFileDir(ParamStr(0));
  Path:= ReplaceText(Path, '\Win32\Debug',   '\APIKey.ini');
  Path:= ReplaceText(Path, '\Win32\Release', '\APIKey.ini');
  // SSL library path
  DllPath:= ReplaceText(Path, '\APIKey.ini', '');

  // Default image path
  // initiallize with default image.
  // otherwise image result from stream does not load!!
  ImgPath:= ReplaceText(Path, '\APIKey.ini', '\delphi.jpeg');
  imgResult.Picture.LoadFromFile(ImgPath);


  // create & read ini file
  iniFile:= TIniFile.Create(Path);
  fAPIKey:= iniFile.ReadString('key', 'apikey', '');

  if (fAPIKey <> '') then
    Result:=True
  else Begin
    raise Exception.Create('Fail to read ini file');
  End;

  iniFile.Free;
end;

procedure TFrmMain.SendImgRequest;
var
  OpenAI: TOPenAI;
  Image: TImageGenerations;
  Images: TImageData;
  Stream: TMemoryStream;
  URL: String;
  Img: TPicture;
begin
  Self.ReadIniFile;
  Self.AdjustPanel;
  OpenAI:= TOpenAI.Create(fAPIKey);
  Stream:= TMemoryStream.Create;
  Img:= TPicture.Create;
  // tell Indy to load dlls from given path
  IdOpenSSLSetLibPath(DllPath);
  Image:= OpenAI.Image.Create(
            procedure(Params: TImageCreateParams)
            begin
              Params.Prompt(edtAsk.Text);
              Params.Size('1024x1024');
              Params.N(1);
              Params.ResponseFormat('url');
            end);
    try
      if (Image.Data <> nil) then Begin
        // we select only one image. not multiples
        URL:= Image.Data[0].Url;
        IdHTTP.Get(URL, Stream);
        Stream.Seek(0, soFromBeginning);
        imgResult.Picture.LoadFromStream(Stream);
        imgResult.Stretch:=True;

        btnCopyToClipbrd.Enabled:= True;
        btnCopyToClipbrd.Caption:= 'Download Image';
      End
      else Begin
        imgResult.Visible:=False;
        pnlResult.Caption:='Err: No Image result!';
      End;
    finally
      Image.Free;
      Stream.Free;
      Img.Free;
    end;
end;
{______________________________________________________________________________}
procedure TFrmMain.SendTextRequest;
var
  OpenAI: TOPenAI;
  Completion: TCompletions;
  Choices: TCompletionChoices;
  // image related
  Image: TImageGenerations;
  Images: TImageData;
  Stream: TMemoryStream;
  URL: String;

begin
  Self.ReadIniFile;
  OpenAI:= TOpenAI.Create(fAPIKey);

  // response
  Self.AdjustPanel;
  Completion:= OpenAI.Completion.Create(
               procedure(Params: TCompletionParams)
               begin
                 // question to be asked
                 Params.Prompt(edtAsk.Text);
                 // AI model
                 Params.Model('text-davinci-003');
                 Params.MaxTokens(1000);
               end);

  try
    if Completion <> nil then Begin
      for Choices in Completion.Choices do Begin
        memResult.Lines.Text := Choices.Text;
        break;
        End;
        btnCopyToClipbrd.Enabled:= True;
        btnCopyToClipbrd.Caption:= 'Copy To Clipboard';
      End
      else Begin
        memResult.Lines.Text:='No Result!';
        Completion.Free;
        Exit
      End;
  finally
    Completion.Free;
  end;

end;

end.
