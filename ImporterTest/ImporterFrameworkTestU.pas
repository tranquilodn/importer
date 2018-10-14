unit ImporterFrameworkTestU;

interface

uses
  DUnitX.TestFramework, ImporterFrameworkU;

type

  [TestFixture]
  ImporterFrameworkTest = class(TObject)
  private
    StringField: TField;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  end;

implementation

procedure ImporterFrameworkTest.Setup;
begin
  StringField := TField.Create;

end;

procedure ImporterFrameworkTest.TearDown;
begin
  StringField.Free;

end;

initialization
  TDUnitX.RegisterTestFixture(ImporterFrameworkTest);
end.
