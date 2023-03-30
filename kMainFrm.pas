unit kMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.IniFiles,
  System.IOUtils,
  System.StrUtils,
  Clipbrd;

type
  TFrmMain = class(TForm)
    edtAsk: TEdit;
    btnSubmit: TButton;
    memResult: TMemo;
    btnClear: TButton;
    Label1: TLabel;
    lblStatus: TLabel;
    btnCopyToClipbrd: TButton;
    procedure btnSubmitClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnCopyToClipbrdClick(Sender: TObject);
  private
    fAPIKey: String;

    function ReadIniFile: Boolean;
    procedure SendRequest;
  public
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  OpenAI,
  OpenAI.Completions;

{$R *.dfm}



{ TFrmMain }

procedure TFrmMain.btnClearClick(Sender: TObject);
begin
  lblStatus.Caption:='';
  memResult.Clear;
  edtAsk.Clear;
end;

procedure TFrmMain.btnCopyToClipbrdClick(Sender: TObject);
begin
  if memResult.Lines.Text <> '' then
    Clipboard.AsText:= memResult.Lines.Text;
end;

procedure TFrmMain.btnSubmitClick(Sender: TObject);
begin
  if (edtAsk.Text <> '')then
    Self.SendRequest
  else
    ShowMessage('Please fill the input field!')
end;

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

procedure TFrmMain.SendRequest;
var
  OpenAI: TOPenAI;
  Completion: TCompletions;
  Choices: TCompletionChoices;
begin
  lblStatus.Caption:= 'hang tight...';
  Self.ReadIniFile;
  OpenAI:= TOpenAI.Create(fAPIKey);    

  // response I guess
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
      lblStatus.Caption := 'Done!';
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
