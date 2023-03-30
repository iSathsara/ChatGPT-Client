program ChatGPT_Client;

uses
  Vcl.Forms,
  kMainFrm in 'kMainFrm.pas' {FrmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
