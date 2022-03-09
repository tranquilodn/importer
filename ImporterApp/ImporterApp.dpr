program ImporterApp;

uses
  Vcl.Forms,
  Form.Main in 'Form.Main.pas' {MainForm},
  Importer.Framework.Engine in '..\ImporterFramework\Importer.Framework.Engine.pas',
  Importer.Framework.Interfaces in '..\ImporterFramework\Importer.Framework.Interfaces.pas',
  Importer.Framework.Defines in '..\ImporterFramework\Importer.Framework.Defines.pas',
  Importer.Framework.ValidationRule in '..\ImporterFramework\Importer.Framework.ValidationRule.pas',
  Importer.Framework.Field in '..\ImporterFramework\Importer.Framework.Field.pas',
  Importer.Framework.Row in '..\ImporterFramework\Importer.Framework.Row.pas',
  Importer.Framework.FileDefinition in '..\ImporterFramework\Importer.Framework.FileDefinition.pas',
  Importer.Framework.Destination in '..\ImporterFramework\Importer.Framework.Destination.pas',
  Importer.Framework.Source in '..\ImporterFramework\Importer.Framework.Source.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
