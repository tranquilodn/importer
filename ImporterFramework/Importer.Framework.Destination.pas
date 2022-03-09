unit Importer.Framework.Destination;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.Script,
  Importer.Framework.Interfaces,
  Importer.Framework.Defines,
  Importer.Framework.FileDefinition;

type
  TDestination = class(TInterfacedObject, IDestination)
  private
    FSQLAssembly: TStringBuilder;
    FSQLScript: TFDScript;
    FTableName: String;
    function PersistWithFireDACSQLScript(const ARecord: IRow; ASQLScript: TFDScript; var AReasonForRejection: String): Boolean; overload;
    function PersistWithFireDACSQLScript(const AHeader: TArray<String>; const ARecord: IRow; ASQLScript: TFDScript; var AReasonForRejection: String): Boolean; overload;
    function AssemblyScriptToPersisTRow(const ARecord: IRow): String; overload;
    function AssemblyScriptToPersisTRow(const AHeader: TArray<String>; const ARecord: IRow): String; overload;
    function GetDataToAssemlySQL(const AField: IField): String;
    function BooleanToBit(const ABooleanValue: Boolean): Integer;
    function GetTableName: String;
    procedure SetTableName(const Value: String);
    function GetSQLAssembly: TStringBuilder;
  public
    constructor Create(const ASQLScript: TFDScript; const ATableName: string);
    destructor Destroy; override;

    function PersistRow(const AHeader: TArray<String>; const ARecord: IRow; var AReasonForRejection: String): Boolean; overload;
    function PersistRow(const ARecord: IRow; var AReasonForRejection: String): Boolean; overload;
    function Prepare: Boolean;

    property TableName: String read GetTableName write SetTableName;
    property SQLAssembly: TStringBuilder read GetSQLAssembly;
  end;

implementation

uses
  Importer.Framework.ValidationRule,
  Importer.Framework.Field,
  Importer.Framework.Row;

{ TDestination }

function TDestination.AssemblyScriptToPersisTRow(
  const AHeader: TArray<String>; const ARecord: IRow): String;
var
  AuxFieldList: String;
  AuxFieldData: String;
  Index: Integer;
begin
  SQLAssembly.Clear;
  AuxFieldList := '';
  AuxFieldData := '';
  for Index := 0 to Length(AHeader) -1 do
  begin
    if AuxFieldList <> '' then
      AuxFieldList := AuxFieldList + ', ' + ARecord.FieldByName(AHeader[Index]).DestinationField
    else
      AuxFieldList := ARecord.FieldByName(AHeader[Index]).DestinationField;
    if AuxFieldData <> '' then
      AuxFieldData := AuxFieldData + ', ' + GetDataToAssemlySQL(ARecord.FieldByName(AHeader[Index]))
    else
      AuxFieldData := GetDataToAssemlySQL(ARecord.FieldByName(AHeader[Index]));
  end;
  SQLAssembly.Append('INSERT INTO ').Append(FTableName);
  SQLAssembly.AppendLine.Append('  (').Append(AuxFieldList).Append(')');
  SQLAssembly.AppendLine.Append('VALUES');
  SQLAssembly.AppendLine.Append('(').Append(AuxFieldData).Append(');');
  Result := SQLAssembly.ToString;
end;

function TDestination.AssemblyScriptToPersisTRow(
  const ARecord: IRow): String;
var
  AuxFieldList: String;
  AuxFieldData: String;
  Index: Integer;
begin
  SQLAssembly.Clear;
  AuxFieldList := '';
  AuxFieldData := '';
  for Index := 0 to ARecord.Fields.Count -1 do
  begin
    if AuxFieldList <> '' then
      AuxFieldList := AuxFieldList + ', ' + ARecord.Fields[Index].DestinationField
    else
      AuxFieldList := ARecord.Fields[Index].DestinationField;
    if AuxFieldData <> '' then
      AuxFieldData := AuxFieldData + ', ' + GetDataToAssemlySQL(ARecord.Fields[Index])
    else
      AuxFieldData := GetDataToAssemlySQL(ARecord.Fields[Index]);
  end;
  SQLAssembly.Append('INSERT INTO ').Append(FTableName);
  SQLAssembly.AppendLine.Append('  (').Append(AuxFieldList).Append(')');
  SQLAssembly.AppendLine.Append('VALUES');
  SQLAssembly.AppendLine.Append('(').Append(AuxFieldData).Append(');');
  Result := SQLAssembly.ToString;
end;

function TDestination.BooleanToBit(
  const ABooleanValue: Boolean): Integer;
begin
  if ABooleanValue then
    Result := 1
  else
    Result := 0;
end;

function TDestination.GetDataToAssemlySQL(const AField: IField): String;
var
  AuxRule: IValidationRule;
begin
  AuxRule := AField.GetRule;
  if (AuxRule is TStringValidationRule) then
    Result := TStringValidationRule(AuxRule).GetValue.QuotedString
  else if (AuxRule is TCurrencyValidationRule) then
    Result := CurrToStr(TCurrencyValidationRule(AuxRule).GetValue)
  else if (AuxRule is TNumericValidationRule) then
    Result := TNumericValidationRule(AuxRule).GetValue.ToString
  else if (AuxRule is TIntegerValidationRule) then
    Result := TIntegerValidationRule(AuxRule).GetValue.ToString
  else if (AuxRule is TDateTimeValidationRule) then
    Result := DateTimeToStr(TDateTimeValidationRule(AuxRule).GetValue).QuotedString
  else if (AuxRule is TBooleanValidationRule) then
    Result := BooleanToBit(TBooleanValidationRule(AuxRule).GetValue).ToString;
end;

function TDestination.GetSQLAssembly: TStringBuilder;
begin
  Result := FSQLAssembly;
end;

function TDestination.GetTableName: String;
begin
  Result := FTableName;
end;

function TDestination.PersisTRow(const AHeader: TArray<String>;
  const ARecord: IRow; var AReasonForRejection: String): Boolean;
begin
  Result := PersistWithFireDACSQLScript(AHeader, ARecord, FSQLScript, AReasonForRejection);
end;

function TDestination.PersisTRow(const ARecord: IRow; var AReasonForRejection: String): Boolean;
begin
  Result := PersistWithFireDACSQLScript(ARecord, FSQLScript, AReasonForRejection);
end;

function TDestination.PersistWithFireDACSQLScript(
  const ARecord: IRow; ASQLScript: TFDScript; var AReasonForRejection: String): Boolean;
var
  AuxScript: String;
begin
  AuxScript := AssemblyScriptToPersisTRow(ARecord);
  with ASQLScript do
  begin
    SQLScripts.Clear;
    SQLScripts.Add;
    with SQLScripts[0].SQL do
    begin
      Add(AuxScript);
    end;
    Result := ValidateAll;
    if Result then
    begin
      try
        Transaction.StartTransaction;
        ExecuteAll;
        Transaction.Commit;
        Result := True;
      except
        on E: Exception do
        begin
          Transaction.Rollback;
          AReasonForRejection := E.Message;
          Result := False;
        end;
      end;
    end;
  end;
end;

function TDestination.PersistWithFireDACSQLScript(const AHeader: TArray<String>;
  const ARecord: IRow; ASQLScript: TFDScript; var AReasonForRejection: String): Boolean;
var
  AuxScript: String;
begin
  AuxScript := AssemblyScriptToPersisTRow(AHeader, ARecord);
  with ASQLScript do
  begin
    SQLScripts.Clear;
    SQLScripts.Add;
    with SQLScripts[0].SQL do
    begin
      Add(AuxScript);
    end;
    Result := ValidateAll;
    if Result then
    begin
      try
        Transaction.StartTransaction;
        ExecuteAll;
        Transaction.Commit;
        Result := True;
      except
        on E: Exception do
        begin
          Transaction.Rollback;
          AReasonForRejection := E.Message;
          Result := False;
        end;
      end;
    end;
  end;
end;

function TDestination.Prepare: Boolean;
begin
  Result := FSQLScript.Connection.Connected;
end;

procedure TDestination.SetTableName(const Value: String);
begin
  FTableName := Value;
end;

constructor TDestination.Create(const ASQLScript: TFDScript; const ATableName: string);
begin
  inherited Create;
  FSQLAssembly := TStringBuilder.Create;
  if Assigned(ASQLScript) then
    FSQLScript := ASQLScript;
  SetTableName(ATableName);
end;

destructor TDestination.Destroy;
begin
  FSQLAssembly.Free;
  inherited;
end;

end.
