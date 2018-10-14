program ImporterApp;

uses
  Vcl.Forms,
  MainFormU in 'MainFormU.pas' {MainForm},
  ImporterFrameworkU in '..\ImporterFramework\ImporterFrameworkU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
