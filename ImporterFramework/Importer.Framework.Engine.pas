unit Importer.Framework.Engine;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.Script,
  Importer.Framework.Interfaces,
  Importer.Framework.Defines,
  Importer.Framework.Source;

type
  TImportEngine = class(TInterfacedObject, IImportEngine)
  private
    FSource: TCSVSourceFile;
    FDestination: IDestination;
    FValidator: IFileDefinition;
    FPrepared: Boolean;
    procedure SetSource(const ASource: TCSVSourceFile);
    procedure SetDestination(const ADestination: IDestination);
    function GetPrepared: Boolean;
    procedure SetPrepared(const Value: Boolean);
    function CanPrepare: Boolean;
  public
    constructor Create(const ASource: TCSVSourceFile; const ADestination: IDestination);
    destructor Destroy; override;

    procedure Prepare;
    procedure Reset;
    procedure Execute;

    function WithFileDefinition(const AValidator: IFileDefinition): IImportEngine;

    property Prepared: Boolean read GetPrepared write SetPrepared;
  end;

implementation

{ TImportEngine }

function TImportEngine.CanPrepare: Boolean;
begin
  if not Assigned(FValidator) then
    raise EFileDefinitionNotAssignedException.Create('Please, assign a File Definition');
  Result := True;
end;

constructor TImportEngine.Create(const ASource: TCSVSourceFile; const ADestination: IDestination);
begin
  inherited Create;
  SetSource(ASource);
  SetDestination(ADestination);
end;

destructor TImportEngine.Destroy;
begin
  inherited;
end;

procedure TImportEngine.Execute;
begin
  if not FPrepared then
    Prepare;
  if FPrepared then
    FSource.ExecuteProcess(FDestination);
end;

function TImportEngine.GetPrepared: Boolean;
begin
  Result := FPrepared;
end;

procedure TImportEngine.Prepare;
begin
  if CanPrepare then
  begin
    FPrepared := FSource.Prepare;
    if FPrepared then
      FPrepared := FDestination.Prepare;
  end;
end;

procedure TImportEngine.Reset;
begin
  Prepared := False;
end;

procedure TImportEngine.SetDestination(const ADestination: IDestination);
begin
  if not Assigned(ADestination) then
    raise ENullPointerException.Create(ENullPointerException.NULL_POINTER_EXCEPTION_MESSAGE);
  FDestination := ADestination;
end;

procedure TImportEngine.SetPrepared(const Value: Boolean);
begin
  FPrepared := Value;
end;

procedure TImportEngine.SetSource(const ASource: TCSVSourceFile);
begin
  if ASource = Nil then
    raise ENullPointerException.Create(ENullPointerException.NULL_POINTER_EXCEPTION_MESSAGE);
  FSource := ASource;
end;

function TImportEngine.WithFileDefinition(const AValidator: IFileDefinition): IImportEngine;
begin
  FValidator := AValidator;
  Result := Self;
end;

end.
