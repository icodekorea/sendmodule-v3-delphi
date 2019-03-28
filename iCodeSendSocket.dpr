program iCodeSendSocket;

uses
  Vcl.Forms,
  Main in 'Main.pas' {frmForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmForm, frmForm);
  Application.Run;
end.
