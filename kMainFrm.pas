unit kMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.IniFiles,
  System.IOUtils,
  System.StrUtils,
  Clipbrd, Vcl.Tabs, Vcl.ExtCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP;

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
    procedure btnSubmitClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnCopyToClipbrdClick(Sender: TObject);
    procedure btnImageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fAPIKey: String;

    function ReadIniFile: Boolean;
    procedure SendTextRequest;
    procedure SendImgRequest;
    procedure AdjustPanel;
  public
  end;

var
  FrmMain: TFrmMain;
  IsImage: Boolean;

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
end;
{______________________________________________________________________________}
procedure TFrmMain.AdjustPanel;
begin
  if IsImage then begin
    imgResult.Visible:= True;
    imgResult.Align:= alClient;
    memResult.Visible:= False;
  end else begin
    imgResult.Visible:= False;
    memResult.Align:= alClient;
    memResult.Visible:= true;
  end;

end;
{______________________________________________________________________________}
procedure TFrmMain.btnClearClick(Sender: TObject);
begin
  memResult.Clear;
  IsImage:=False;
  edtAsk.Clear;
  pnlResult.Caption:='Result shows here...'
end;
{______________________________________________________________________________}
procedure TFrmMain.btnCopyToClipbrdClick(Sender: TObject);
begin
  if memResult.Lines.Text <> '' then
    Clipboard.AsText:= memResult.Lines.Text;
end;
{______________________________________________________________________________}
procedure TFrmMain.btnImageClick(Sender: TObject);
begin
  IsImage:= True;
  if (edtAsk.Text <> '')then
    Self.SendImgRequest
  else
    ShowMessage('Please fill the input field!')
end;
{______________________________________________________________________________}
procedure TFrmMain.btnSubmitClick(Sender: TObject);
begin
  IsImage:=False;
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
begin

  // get file path
  Path:= ExtractFileDir(ParamStr(0));
  Path:= ReplaceText(Path, '\Win32\Debug', '\APIKey.ini');
  Path:= ReplaceText(Path, '\Win32\Release', '\APIKey.ini');

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
begin
  Self.ReadIniFile;
  Self.AdjustPanel;
  OpenAI:= TOpenAI.Create(fAPIKey);
  Stream:= TMemoryStream.Create;
  IdOpenSSLSetLibPath('C:\Windows\SysWOW64\ssleay32.dll');
  Image:= OpenAI.Image.Create(
            procedure(Params: TImageCreateParams)
            begin
              Params.Prompt(edtAsk.Text);
              Params.ResponseFormat('url');
            end);
    try
      if Image <> nil then Begin
        // we select only one image. not multiple
        URL:= Image.Data[0].Url;
        IdHTTP.Get(URL, Stream);
        Stream.Seek(0, soFromBeginning);
        imgResult.Picture.Bitmap.LoadFromStream(Stream);
      End
      else Begin
        imgResult.Visible:=False;
        pnlResult.Caption:='Err: No Image result!';
      End;
    finally
      Image.Free;
      Stream.Free;
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
