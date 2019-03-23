unit ImporterFrameworkU;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.Script,
  Importer.Framework.Interfaces;

type
  EImporterFrameworkException = class(Exception);

  EValueNotAcceptedException = class(EImporterFrameworkException);

  EEmptyFieldNameException = class(EImporterFrameworkException)
  const
    EMPTY_FIELD_NAME_MESSAGE = 'Field must have a name';
  end;

  EFieldNameMustBeUniqueException = class(EImporterFrameworkException)
  const
    FIELD_NAME_MUST_BE_UNIQUE_MESSAGE = 'Field Name must be unique';
  end;

  EIncompatibleValidationRuleException = class(EImporterFrameworkException)
  const
    INCOMPATIBLE_VALIDATION_RULE_MESSAGE = 'Validation Rule is incompatible';
  end;

  ENullPointerException = class(EImporterFrameworkException)
  const
    NULL_POINTER_EXCEPTION_MESSAGE = 'Null Pointer Exception';
  end;

  TDataType = record
  const
    dtString = 'String';
    dtCurrency = 'Currency';
    dtInteger = 'Integer';
    dtNumeric = 'Numeric';
    dtDateTime = 'DateTime';
    dtBoolean = 'Boolean';
  end;

  TValidationRule = class(TInterfacedObject)
  const
    FIELD_EMPTY_MESSAGE = 'Field must have a value';
  private
    FAcceptEmpty: Boolean;
    FMaxLength: Integer;
    FValidateLength: Boolean;
    function Parse(const AValue: Variant;
      var AReasonForRejection: String): Boolean;
  protected
    function GetAcceptEmpty: Boolean;
    procedure SetAcceptEmpty(const Value: Boolean);
    function GetMaxLength: Integer;
    procedure SetMaxLength(const Value: Integer);
    function GetValidateLength: Boolean;
    procedure SetValidateLength(const Value: Boolean);
    function FieldIsEmpty(const AValue: String): Boolean; overload;
    function FieldIsEmpty(const AValue: String; var AReasonForRejection: String): Boolean; overload;
    function IsValidateLength(const AValue: String; var AReasonForRejection: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    property AcceptEmpty: Boolean read GetAcceptEmpty write SetAcceptEmpty;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
    property ValidateLength: Boolean read GetValidateLength write SetValidateLength;
  end;

  TStringValidationRule = class(TValidationRule, IValidationRule)
  const
    INVALID_STRING_MESSAGE = 'Invalid string';
    INVALID_LENGTH_MESSAGE = 'Invalid field length';
  private
    FValue: String;
    function VarTypeIsString(const AVarType: TVarType; var AReasonForRejection: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Parse(const AValue: Variant; var AReasonForRejection: String): Boolean;
    function GetValue: String;
  end;

  TCurrencyValidationRule = class(TValidationRule, IValidationRule)
  const
    INVALID_CURRENCY_MESSAGE = 'Invalid currency value';
  private
    FValue: Currency;
    function IsCurrency(const AValue: Variant; var AReasonForRejection: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Parse(const AValue: Variant; var AReasonForRejection: String): Boolean;
    function GetValue: Currency;
  end;

  TNumericValidationRule = class(TValidationRule, IValidationRule)
  const
    INVALID_NUMERIC_MESSAGE = 'Invalid numeric value';
  private
    FValue: Double;
    function IsNumeric(const AValue: Variant; var AReasonForRejection: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Parse(const AValue: Variant; var AReasonForRejection: String): Boolean;
    function GetValue: Double;
  end;

  TIntegerValidationRule = class(TValidationRule, IValidationRule)
  const
    INVALID_INTEGER_MESSAGE = 'Invalid integer value';
  private
    FValue: Integer;
    function IsInteger(const AValue: Variant; var AReasonForRejection: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Parse(const AValue: Variant; var AReasonForRejection: String): Boolean;
    function GetValue: Integer;
  end;

  TDateTimeValidationRule = class(TValidationRule, IValidationRule)
  const
    INVALID_DATETIME_MESSAGE = 'Invalid date';
  private
    FValue: TDateTime;
    function IsDateTime(const AValue: Variant; var AReasonForRejection: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Parse(const AValue: Variant; var AReasonForRejection: String): Boolean;
    function GetValue: TDateTime;
  end;

  TBooleanValidationRule = class(TValidationRule, IValidationRule)
  const
    INVALID_BOOLEAN_MESSAGE = 'Invalid boolean';
  private
    FValue: Boolean;
    function IsBoolean(const AValue: Variant; var AReasonForRejection: String): Boolean;
  public
    destructor Destroy; override;
    function Parse(const AValue: Variant; var AReasonForRejection: String): Boolean;
    function GetValue: Boolean;
  end;

  TField = class(TInterfacedObject, IField)
  private
    FFieldName: String;
    FFieldIsValid: Boolean;
    FFieldValue: Variant;
    FValidationRule: IValidationRule;
    FDestinationField: String;

    function GetFieldName: String;
    procedure SetFieldName(const Value: String);
    function GetDestinationField: String;
    procedure SetDestinationField(const Value: String);
    function GetFieldIsValid: Boolean;
    procedure SetFieldIsValid(const Value: Boolean);
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
    function GetAcceptEmpty: Boolean;
    procedure SetAcceptEmpty(const Value: Boolean);
    function GetMaxLength: Integer;
    procedure SetMaxLength(const Value: Integer);
    function GetValidateLength: Boolean;
    procedure SetValidateLength(const Value: Boolean);

    function GetRule: IValidationRule;
    procedure CreateValidationRule(const ADataType: String);
  public
    constructor Create(const AFieldName: String; const ADataType: String); overload;
    destructor Destroy; override;
    function Parse(var AReasonForRejection: String): Boolean;
    property Name: String read GetFieldName write SetFieldName;
    property DestinationField: String read GetDestinationField write SetDestinationField;
    property IsValid: Boolean read GetFieldIsValid write SetFieldIsValid;
    property Value: Variant read GetValue write SetValue;
    property AcceptEmpty: Boolean read GetAcceptEmpty write SetAcceptEmpty;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
    property ValidateLength: Boolean read GetValidateLength write SetValidateLength;
    class procedure ParseValue(const ASourceField: IField; var ATarget: IField); overload;
    class procedure ParseValue(const ASourceField: IField; var ATarget: String); overload;
    class procedure ParseValue(const ASourceField: IField; var ATarget: Integer); overload;
    class procedure ParseValue(const ASourceField: IField; var ATarget: Boolean); overload;
  end;

  TRecord = class
  private
    FFields: TList<IField>;
    function FieldNameAlreadyExists(const AFieldName: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function FieldByName(AFieldName: String): IField;
    procedure AddField(AField: IField);
    property Fields: TList<IField> read FFields;
  end;

  TFileDefinitionFieldNames = record
  const
    FD_FIELD_NAME = 'FIELD_NAME';
    FD_DATA_TYPE = 'DATA_TYPE';
    FD_ACCEPT_EMPTY = 'ACCEPT_EMPTY';
    FD_VALIDATE_LENGTH = 'VALIDATE_LENGTH';
    FD_MAX_LENGTH = 'MAX_LENGTH';
    FD_DESTINATION_FIELD = 'DESTINATION_FIELD';
  end;

  TFileDefinition = class
  private
    FRecord: TRecord;
    FFile: TStringList;
    FFieldName: IField;
    FFieldDataType: IField;
    FFieldAcceptEmpty: IField;
    FFieldMaxLength: IField;
    FFieldValidateLength: IField;
    FFieldDestinationFieldName: IField;
    procedure InitializeFileDefinitionStructure;
    procedure Split(const ARecord: String; var ARecordContent: TArray<String>;
      const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char);
    function CreateDataField(const ARecord: TRecord; var AFileStructure: TRecord): Boolean;
  public
    constructor Create(const AFileName: String);
    destructor Destroy; override;
    function SplitRecord(const ARecord: String; var ARecordContent: TArray<String>;
      const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean;
    function ValidateFileDefinition(var AFileStructure: TRecord; var AReasonForRejection: String): Boolean; virtual; abstract;
  end;

  TCSVFileDefinition = class(TFileDefinition)
  private
    FFieldDelimiter: Char;
    FRecordDelimiter: Char;
    FTextDelimiter: Char;
  public
    procedure SetFieldDelimiter(const Value: Char);
    procedure SetRecordDelimiter(const Value: Char);
    procedure SetTextDelimiter(const Value: Char);
    function GetFieldDelimiter: Char;
    function GetRecordDelimiter: Char;
    function GetTextDelimiter: Char;
    constructor Create(const AFileName: String);
    destructor Destroy; override;
    function ValidateFileDefinition(var AFileStructure: TRecord; var AReasonForRejection: String): Boolean; override;
    property RecordDelimiter: Char read FRecordDelimiter write SetRecordDelimiter;
    property FieldDelimiter: Char read FFieldDelimiter write SetFieldDelimiter;
    property TextDelimiter: Char read FTextDelimiter write SetTextDelimiter;
  end;

  TDestination = class
  private
    FSQLAssembly: TStringBuilder;
    FRejectedRecords: TStringList;
    function PersistRecord(const ARecord: TRecord; var AReasonForRejection: String): Boolean; overload; virtual; abstract;
    function PersistRecord(const AHeader: TArray<String>; const ARecord: TRecord; var AReasonForRejection: String): Boolean; overload; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    function Prepare: Boolean; virtual; abstract;
    procedure SetRejectecRecord(const ARecord: String; const AReasonForRejection: String);
    procedure SaveRejectedRecordsToDisk(const AFileName: String);
    property SQLAssembly: TStringBuilder read FSQLAssembly;
  end;

  TDatabaseDestination = class(TDestination)
  private
    FSQLScript: TFDScript;
    FTableName: String;
    function PersistWithFireDACSQLScript(const ARecord: TRecord; ASQLScript: TFDScript; var AReasonForRejection: String): Boolean; overload;
    function PersistWithFireDACSQLScript(const AHeader: TArray<String>; const ARecord: TRecord; ASQLScript: TFDScript; var AReasonForRejection: String): Boolean; overload;
    function AssemblyScriptToPersistRecord(const ARecord: TRecord): String; overload;
    function AssemblyScriptToPersistRecord(const AHeader: TArray<String>; const ARecord: TRecord): String; overload;
    function GetDataToAssemlySQL(const AField: IField): String;
    procedure SetTableName(const Value: String);
    function PersistRecord(const AHeader: TArray<String>; const ARecord: TRecord; var AReasonForRejection: String): Boolean; override;
    function PersistRecord(const ARecord: TRecord; var AReasonForRejection: String): Boolean; override;
    function BooleanToBit(const ABooleanValue: Boolean): Integer;
  public
    constructor Create(const ASQLScript: TFDScript; const ATableName: String);
    destructor Destroy; override;
    function Prepare: Boolean; override;
    property TableName: String read FTableName write SetTableName;
  end;

  TSource = class
    function Prepare: Boolean; virtual; abstract;
    procedure ExecuteProcess(const ADestination: TDestination); virtual; abstract;
  end;

  TSourceFile = class(TSource)
  private
    FFileName: String;
    FFile: TStringList;
    procedure SetFileName(const Value: String);
  public
    constructor Create;
    destructor Destroy; override;
    function SplitRecord(const ARecord: String; var ARecordContent: TArray<String>;
      const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean; virtual; abstract;
    function ValidateRecord(const ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean;  overload; virtual; abstract;
    function ValidateRecord(const ARecordHeader: TArray<String>; const ARecordContent: TArray<String>;
      var AReasonForRejection: String): Boolean;  overload; virtual; abstract;
    function ParseRecord(const ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean; overload; virtual; abstract;
    function ParseRecord(const ARecordHeader: TArray<String>; const ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean; overload; virtual; abstract;
    property FileName: String read FFileName write SetFileName;
  end;

  TCSVSourceFile = class(TSourceFile)
  private
    FFileDefinition: TCSVFileDefinition;
    FFileStructure: TRecord;
    FHasHeader: Boolean;
    function ValidateFileDefinition(var AReasonForRejection: String): Boolean;
    function ProcessFileWithHeader(const ADestination: TDestination): Boolean;
    function ProcessFileWithoutHeader(const ADestination: TDestination): Boolean;
    procedure SetHasHeader(const Value: Boolean);
    function GetFieldDelimiter: Char;
    function GetRecordDelimiter: Char;
    function GetTextDelimiter: Char;
    procedure SetFieldDelimiter(const Value: Char);
    procedure SetRecordDelimiter(const Value: Char);
    procedure SetTextDelimiter(const Value: Char);
  public
    constructor Create(const AFileDefinitionName: String); overload;
    destructor Destroy; override;
    function SplitRecord(const ARecord: String; var ARecordContent: TArray<String>;
      const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean; override;
    function ValidateRecord(const ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean; override;
    function ValidateRecord(const ARecordHeader: TArray<String>; const ARecordContent: TArray<String>;
      var AReasonForRejection: String): Boolean; override;
    function ParseRecord(const ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean; override;
    function ParseRecord(const ARecordHeader: TArray<String>; const ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean; override;
    function Prepare: Boolean; override;
    procedure ExecuteProcess(const ADestination: TDestination); override;
    property HasHeader: Boolean read FHasHeader write SetHasHeader;
    property RecordDelimiter: Char read GetRecordDelimiter write SetRecordDelimiter;
    property FieldDelimiter: Char read GetFieldDelimiter write SetFieldDelimiter;
    property TextDelimiter: Char read GetTextDelimiter write SetTextDelimiter;
  end;

  TFlatSourceFile = class(TSourceFile)
  public
    constructor Create(const AFileDefinitionName: String); overload;
    destructor Destroy; override;
  end;

  TImportEngine = class
  private
    FCSVSource: TCSVSourceFile;
    FDestination: TDestination;
    FPrepared: Boolean;
    procedure SetSource(const ASource: TCSVSourceFile);
    procedure SetDestination(const ADestination: TDestination);
    procedure SetPrepared(const Value: Boolean);
  public
    constructor Create(const ASource: TCSVSourceFile; const ADestination: TDestination);
    destructor Destroy; override;
    procedure Prepare;
    procedure Reset;
    procedure Execute;
    property Prepared: Boolean read FPrepared write SetPrepared;
  end;

implementation

{ TField }

constructor TField.Create(const AFieldName, ADataType: String);
begin
  inherited Create;
  SetFieldName(AFieldName);
  CreateValidationRule(ADataType);
end;

procedure TField.CreateValidationRule(const ADataType: String);
begin
  if UpperCase(ADataType) = UpperCase(TDataType.dtString) then
    FValidationRule := TStringValidationRule.Create
  else if UpperCase(ADataType) = UpperCase(TDataType.dtCurrency) then
    FValidationRule := TCurrencyValidationRule.Create
  else if UpperCase(ADataType) = UpperCase(TDataType.dtInteger) then
    FValidationRule := TIntegerValidationRule.Create
  else if UpperCase(ADataType) = UpperCase(TDataType.dtDateTime) then
    FValidationRule := TDateTimeValidationRule.Create
  else if UpperCase(ADataType) = UpperCase(TDataType.dtNumeric) then
    FValidationRule := TNumericValidationRule.Create
  else if UpperCase(ADataType) = UpperCase(TDataType.dtBoolean) then
    FValidationRule := TBooleanValidationRule.Create
  else
    raise Exception.Create('Data type not found. Check your File Definition''s file');
end;

destructor TField.Destroy;
begin

  inherited;
end;

function TField.Parse(var AReasonForRejection: String): Boolean;
begin
  Result := FValidationRule.Parse(FFieldValue, AReasonForRejection);
end;

class procedure TField.ParseValue(const ASourceField: IField;
  var ATarget: Integer);
var
  AuxRule: IValidationRule;
begin
  AuxRule := ASourceField.GetRule;
  if (AuxRule is TIntegerValidationRule) then
    ATarget := TIntegerValidationRule(AuxRule).GetValue
  else
    ATarget := 0;
end;

class procedure TField.ParseValue(const ASourceField: IField; var ATarget: IField);
var
  AuxRule: IValidationRule;
begin
  AuxRule := ASourceField.GetRule;
  if (AuxRule is TStringValidationRule) then
    ATarget.Value := TStringValidationRule(AuxRule).GetValue
  else if (AuxRule is TCurrencyValidationRule) then
    ATarget.Value := TCurrencyValidationRule(AuxRule).GetValue
  else if (AuxRule is TNumericValidationRule) then
    ATarget.Value := TNumericValidationRule(AuxRule).GetValue
  else if (AuxRule is TIntegerValidationRule) then
    ATarget.Value := TIntegerValidationRule(AuxRule).GetValue
  else if (AuxRule is TDateTimeValidationRule) then
    ATarget.Value := TDateTimeValidationRule(AuxRule).GetValue
  else if (AuxRule is TBooleanValidationRule) then
    ATarget.Value := TBooleanValidationRule(AuxRule).GetValue;
end;

class procedure TField.ParseValue(const ASourceField: IField; var ATarget: String);
var
  AuxRule: IValidationRule;
begin
  AuxRule := ASourceField.GetRule;
  if (AuxRule is TStringValidationRule) then
    ATarget := TStringValidationRule(AuxRule).GetValue
  else
    ATarget := '';
end;

procedure TField.SetAcceptEmpty(const Value: Boolean);
begin
  FValidationRule.AcceptEmpty := Value;
end;

procedure TField.SetDestinationField(const Value: String);
begin
  FDestinationField := Value;
end;

function TField.GetAcceptEmpty: Boolean;
begin
  Result := FValidationRule.AcceptEmpty;
end;

function TField.GetDestinationField: String;
begin
  Result := FDestinationField;
end;

function TField.GetFieldIsValid: Boolean;
begin
  Result := FFieldIsValid;
end;

function TField.GetFieldName: String;
begin
  Result := FFieldName;
end;

function TField.GetMaxLength: Integer;
begin
  Result := FValidationRule.MaxLength;
end;

function TField.GetRule: IValidationRule;
begin
  Result := FValidationRule;
end;

function TField.GetValidateLength: Boolean;
begin
  Result := FValidationRule.ValidateLength;
end;

function TField.GetValue: Variant;
begin
  Result := FFieldValue
end;

procedure TField.SetFieldIsValid(const Value: Boolean);
begin
  FFieldIsValid := Value;
end;

procedure TField.SetFieldName(const Value: String);
begin
  if Value = '' then
    raise EEmptyFieldNameException.Create(EEmptyFieldNameException.EMPTY_FIELD_NAME_MESSAGE);
  FFieldName := Value
end;

procedure TField.SetMaxLength(const Value: Integer);
begin
  FValidationRule.MaxLength := Value;
end;

procedure TField.SetValidateLength(const Value: Boolean);
begin
  FValidationRule.ValidateLength := Value;
end;

class procedure TField.ParseValue(const ASourceField: IField; var ATarget: Boolean);
var
  AuxRule: IValidationRule;
begin
  AuxRule := ASourceField.GetRule;
  if (AuxRule is TBooleanValidationRule) then
    ATarget := TBooleanValidationRule(AuxRule).GetValue
  else
    ATarget := Null;
end;

procedure TField.SetValue(const Value: Variant);
begin
  FFieldValue := Value;
end;

{ TRecord }

procedure TRecord.AddField(AField: IField);
begin
  if AField = Nil then
    raise ENullPointerException.Create(ENullPointerException.NULL_POINTER_EXCEPTION_MESSAGE);
  if FFields = Nil then
    FFields := TList<IField>.Create;
  if FieldNameAlreadyExists(AField.Name) then
    raise EFieldNameMustBeUniqueException.Create(EFieldNameMustBeUniqueException.FIELD_NAME_MUST_BE_UNIQUE_MESSAGE);
  FFields.Add(AField);
end;

constructor TRecord.Create;
begin
  inherited Create;
  FFields := Nil;
end;

destructor TRecord.Destroy;
begin
  if Assigned(FFields) then
    FFields.Free;
  inherited;
end;

function TRecord.FieldByName(AFieldName: String): IField;
var
  Index: Integer;
begin
  Result := Nil;
  for Index := 0 to FFields.Count - 1 do
    if (UpperCase(FFields[Index].Name) = UpperCase(Trim(AFieldName))) then
    begin
      Result := FFields[Index];
      Break;
    end;
  if Result = Nil then
  begin
    raise Exception.Create('Field not Found. Please, check your File Definition');
    Abort;
  end;
end;

function TRecord.FieldNameAlreadyExists(const AFieldName: String): Boolean;
var
  Index: Integer;
begin
  Result := False;
  for Index := 0 to FFields.Count - 1 do
  begin
    Result := UpperCase(Trim(TField(FFields[Index]).Name)) = UpperCase(Trim(AFieldName));
    if Result then
      Break;
  end;
end;

{ TValidationRule }

function TValidationRule.FieldIsEmpty(const AValue: String): Boolean;
begin
  Result := (Trim(AValue) = '');
end;

procedure TValidationRule.SetAcceptEmpty(const Value: Boolean);
begin
  if FAcceptEmpty <> Value then
    FAcceptEmpty := Value;
end;

constructor TValidationRule.Create;
begin
  inherited;
end;

destructor TValidationRule.Destroy;
begin
  inherited;
end;

function TValidationRule.FieldIsEmpty(const AValue: String;
  var AReasonForRejection: String): Boolean;
begin
  Result := (Trim(AValue) = '');
  if Result then
    AReasonForRejection := TStringValidationRule.FIELD_EMPTY_MESSAGE;
end;

function TValidationRule.GetAcceptEmpty: Boolean;
begin
  Result := FAcceptEmpty;
end;

function TValidationRule.GetMaxLength: Integer;
begin
  Result := FMaxLength;
end;

function TValidationRule.GetValidateLength: Boolean;
begin
  Result := FValidateLength;
end;

constructor TStringValidationRule.Create;
begin
  inherited;
end;

destructor TStringValidationRule.Destroy;
begin
  inherited;
end;

function TStringValidationRule.GetValue: String;
begin
  Result := FValue;
end;

function TValidationRule.IsValidateLength(const AValue: String;
  var AReasonForRejection: String): Boolean;
begin
  Result := (Length(Trim(AValue)) <= FMaxLength);
  if not Result then
    AReasonForRejection := TStringValidationRule.INVALID_LENGTH_MESSAGE;
end;

function TValidationRule.Parse(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
begin
  AReasonForRejection := '';
  Result := True;
end;

function TStringValidationRule.Parse(const AValue: Variant; var AReasonForRejection: String): Boolean;
begin
  AReasonForRejection := '';
  if AcceptEmpty then
  begin
    if not FieldIsEmpty(AValue) then
      Result := VarTypeIsString(FindVarData(AValue).VType, AReasonForRejection)
    else
      Result := True;
  end
  else
  begin
    Result := not FieldIsEmpty(AValue, AReasonForRejection);
    if Result then
      Result := VarTypeIsString(FindVarData(AValue)^.VType, AReasonForRejection);
    if Result and FValidateLength then
      Result := IsValidateLength(AValue, AReasonForRejection);
  end;
  if Result then
    FValue := AValue;
end;

procedure TValidationRule.SetMaxLength(const Value: Integer);
begin
  if FMaxLength <> Value then
    FMaxLength := Value;
end;

procedure TValidationRule.SetValidateLength(const Value: Boolean);
begin
  if FValidateLength <> Value then
    FValidateLength := Value;
end;

function TStringValidationRule.VarTypeIsString(const AVarType: TVarType; var AReasonForRejection: String): Boolean;
begin
  Result := (AVarType = varOleStr) or (AVarType = varString) or (AVarType = varUString);
  if not Result then
    AReasonForRejection := TStringValidationRule.INVALID_STRING_MESSAGE;
end;

{ TIntegerValidationRule }

constructor TIntegerValidationRule.Create;
begin
  inherited;
end;

destructor TIntegerValidationRule.Destroy;
begin
  inherited;
end;

function TIntegerValidationRule.GetValue: Integer;
begin
  Result := FValue;
end;

function TIntegerValidationRule.IsInteger(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
var
  AuxResult: Integer;
  AuxIsValid: Integer;
begin
  Val(AValue, AuxResult, AuxIsValid);
  Result := (AuxIsValid = 0);
  if not Result then
    AReasonForRejection := Self.INVALID_INTEGER_MESSAGE
  else
    FValue := AuxResult;
end;

function TIntegerValidationRule.Parse(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
begin
  AReasonForRejection := '';
  if AcceptEmpty then
  begin
    if not FieldIsEmpty(AValue) then
      Result := IsInteger(AValue, AReasonForRejection)
    else
      Result := True;
  end
  else
  begin
    Result := not FieldIsEmpty(AValue, AReasonForRejection);
    if Result then
      Result := IsInteger(AValue, AReasonForRejection);
  end;
end;

{ TCurrencyValidationRule }

constructor TCurrencyValidationRule.Create;
begin
  inherited;
end;

destructor TCurrencyValidationRule.Destroy;
begin
  inherited;
end;

function TCurrencyValidationRule.GetValue: Currency;
begin
  Result := FValue;
end;

function TCurrencyValidationRule.IsCurrency(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
var
  AuxResult: Currency;
  AuxIsValid: Integer;
begin
  Val(AValue, AuxResult, AuxIsValid);
  Result := (AuxIsValid = 0);
  if not Result then
    AReasonForRejection := Self.INVALID_CURRENCY_MESSAGE
  else
    FValue := AuxResult;
end;

function TCurrencyValidationRule.Parse(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
begin
  AReasonForRejection := '';
  if AcceptEmpty then
  begin
    if not FieldIsEmpty(AValue) then
      Result := IsCurrency(AValue, AReasonForRejection)
    else
      Result := True;
  end
  else
  begin
    Result := not FieldIsEmpty(AValue, AReasonForRejection);
    if Result then
      Result := IsCurrency(AValue, AReasonForRejection);
  end;
end;

{ TBooleanValidationRule }

destructor TBooleanValidationRule.Destroy;
begin
  inherited;
end;

function TBooleanValidationRule.GetValue: Boolean;
begin
  Result := FValue;
end;

function TBooleanValidationRule.IsBoolean(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
begin
  Result := (
    (String.UpperCase(Trim(AValue)) = 'TRUE') or
    (String.UpperCase(Trim(AValue)) = 'FALSE')
  );
  if not Result then
    AReasonForRejection := Self.INVALID_BOOLEAN_MESSAGE
  else
    FValue := (UpperCase(AValue) = 'TRUE');
end;

function TBooleanValidationRule.Parse(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
begin
  AReasonForRejection := '';
  if AcceptEmpty then
  begin
    if not FieldIsEmpty(AValue) then
      Result := IsBoolean(AValue, AReasonForRejection)
    else
      Result := True;
  end
  else
  begin
    Result := not FieldIsEmpty(AValue, AReasonForRejection);
    if Result then
      Result := IsBoolean(AValue, AReasonForRejection)
  end;
end;

{ TDateTimeValidationRule }

constructor TDateTimeValidationRule.Create;
begin
  inherited;
end;

destructor TDateTimeValidationRule.Destroy;
begin
  inherited;
end;

function TDateTimeValidationRule.GetValue: TDateTime;
begin
  Result := FValue;
end;

function TDateTimeValidationRule.IsDateTime(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
var
  AuxResult: TDateTime;
begin
  AuxResult := StrToDateTimeDef(AValue, -1);
  Result := (AuxResult > -1);
  if not Result then
    AReasonForRejection := Self.INVALID_DATETIME_MESSAGE
  else
    FValue := AuxResult;
end;

function TDateTimeValidationRule.Parse(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
begin
  AReasonForRejection := '';
  if AcceptEmpty then
  begin
    if not FieldIsEmpty(AValue) then
      Result := IsDateTime(AValue, AReasonForRejection)
    else
      Result := True;
  end
  else
  begin
    Result := not FieldIsEmpty(AValue, AReasonForRejection);
    if Result then
      Result := IsDateTime(AValue, AReasonForRejection);
  end;
end;

{ TCSVSourceFile }

constructor TCSVSourceFile.Create(const AFileDefinitionName: String);
begin
  inherited Create;
  FHasHeader := True;
  FFileDefinition := TCSVFileDefinition.Create(AFileDefinitionName);
  FFileStructure := TRecord.Create;
end;

destructor TCSVSourceFile.Destroy;
begin
  if FFileDefinition <> Nil then
    FFileDefinition.Destroy;
  if FFileStructure <> Nil then
    FFileStructure.Destroy;
  inherited;
end;

procedure TCSVSourceFile.ExecuteProcess(const ADestination: TDestination);
begin
  if HasHeader then
    ProcessFileWithHeader(ADestination)
  else
    ProcessFileWithoutHeader(ADestination);
  ADestination.SaveRejectedRecordsToDisk(FileName);
end;

function TCSVSourceFile.GetFieldDelimiter: Char;
begin
  Result := FFileDefinition.GetTextDelimiter;
end;

function TCSVSourceFile.GetRecordDelimiter: Char;
begin
  Result := FFileDefinition.GetRecordDelimiter;
end;

function TCSVSourceFile.GetTextDelimiter: Char;
begin
  Result := FFileDefinition.GetTextDelimiter;
end;

function TCSVSourceFile.Prepare: Boolean;
var
  AuxReasonForRejection: String;
begin
  Result := FileExists(FFileName);
  if Result then
    FFile.LoadFromFile(FFileName)
  else
    raise EFileNotFoundException.Create('A valid path and source file must be informed');
  Result := ValidateFileDefinition(AuxReasonForRejection);
  if not Result then
     raise Exception.Create('Invalid File Definition structure'+#13#10+AuxReasonForRejection);
end;

function TCSVSourceFile.ProcessFileWithHeader(const ADestination: TDestination): Boolean;
var
  FileIndex: Integer;
  RecordIndex: Integer;
  AuxRecord: TArray<String>;
  AuxRecordHeader: TArray<String>;
  AuxRecordContent: TArray<String>;
  AuxReasonForRejection: String;
begin
  Result := True;
  for FileIndex := 0 to FFile.Count -1 do
  begin
    Result := SplitRecord(FFile[FileIndex], AuxRecord, FFileDefinition.RecordDelimiter,
      FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
    if Result then
    begin
      //Reading the record found on source file's line
      for RecordIndex := 0 to Length(AuxRecord) -1 do
      begin
        if (FileIndex = 0) and (RecordIndex = 0) then
        begin
          Result := SplitRecord(AuxRecord[RecordIndex], AuxRecordHeader, FFileDefinition.FieldDelimiter,
            FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
        end
        else
        begin
          Result := SplitRecord(AuxRecord[RecordIndex], AuxRecordContent, FFileDefinition.FieldDelimiter,
            FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
          if Result then
            Result := ValidateRecord(AuxRecordHeader, AuxRecordContent, AuxReasonForRejection);
          if Result then
            Result := ParseRecord(AuxRecordHeader, AuxRecordContent, AuxReasonForRejection);
          if Result then
            Result := ADestination.PersistRecord(AuxRecordHeader, FFileStructure, AuxReasonForRejection);
        end;
        if not Result then
          ADestination.SetRejectecRecord(AuxRecord[RecordIndex], AuxReasonForRejection);
      end;
    end;
  end;
end;

function TCSVSourceFile.ProcessFileWithoutHeader(const ADestination: TDestination): Boolean;
var
  FileIndex: Integer;
  RecordIndex: Integer;
  AuxRecord: TArray<String>;
  AuxRecordContent: TArray<String>;
  AuxReasonForRejection: String;
begin
  for FileIndex := 0 to FFile.Count -1 do
  begin
    Result := SplitRecord(FFile[FileIndex], AuxRecord, FFileDefinition.RecordDelimiter,
      FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
    if Result then
    begin
      //Reading the record found on source file's line
      for RecordIndex := 0 to Length(AuxRecord) -1 do
      begin
        Result := SplitRecord(AuxRecord[RecordIndex], AuxRecordContent, FFileDefinition.FieldDelimiter,
          FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
        if Result then
          Result := ValidateRecord(AuxRecordContent, AuxReasonForRejection);
        if Result then
          Result := ParseRecord(AuxRecordContent, AuxReasonForRejection);
        if Result then
          Result := ADestination.PersistRecord(FFileStructure, AuxReasonForRejection);
        if not Result then
          ADestination.SetRejectecRecord(AuxRecord[RecordIndex], AuxReasonForRejection);
      end;
    end;
  end;
  Result := True;
end;

procedure TCSVSourceFile.SetFieldDelimiter(const Value: Char);
begin
  FFileDefinition.SetFieldDelimiter(Value);
end;

procedure TCSVSourceFile.SetHasHeader(const Value: Boolean);
begin
  FHasHeader := Value;
end;

procedure TCSVSourceFile.SetRecordDelimiter(const Value: Char);
begin
  FFileDefinition.SetRecordDelimiter(Value);
end;

procedure TCSVSourceFile.SetTextDelimiter(const Value: Char);
begin
  FFileDefinition.SetTextDelimiter(Value);
end;

function TCSVSourceFile.SplitRecord(const ARecord: String; var ARecordContent: TArray<String>;
  const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean;
begin
  Result := FFileDefinition.SplitRecord(ARecord, ARecordContent, ADelimiter, AFieldDelimiter, ATextDelimiter);
end;

function TCSVSourceFile.ValidateFileDefinition(var AReasonForRejection: String): Boolean;
begin
  Result := FFileDefinition.ValidateFileDefinition(FFileStructure, AReasonForRejection);
end;

function TCSVSourceFile.ValidateRecord(const ARecordContent: TArray<String>;
  var AReasonForRejection: String): Boolean;
begin
  Result := (Length(ARecordContent) = FFileStructure.Fields.Count);
  if not Result then
    AReasonForRejection := 'Invalid Record: incorrect number of fields.';
end;

function TCSVSourceFile.ValidateRecord(const ARecordHeader: TArray<String>; const ARecordContent: TArray<String>;
  var AReasonForRejection: String): Boolean;
begin
  Result := (Length(ARecordHeader) = Length(ARecordContent));
  if not Result then
    AReasonForRejection := 'Invalid Record: incorrect number of fields.';
end;

function TCSVSourceFile.ParseRecord(const ARecordHeader,
  ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean;
var
  RecordIndex: Integer;
begin
  Result := False;
  for RecordIndex := 0 to Length(ARecordHeader) -1 do
  begin
    FFileStructure.FieldByName(ARecordHeader[RecordIndex]).Value := ARecordContent[RecordIndex];
    Result := FFileStructure.FieldByName(ARecordHeader[RecordIndex]).Parse(AReasonForRejection);
    if not Result then
      Break;
  end;
end;

function TCSVSourceFile.ParseRecord(const ARecordContent: TArray<String>;
  var AReasonForRejection: String): Boolean;
var
  RecordIndex: Integer;
begin
  Result := False;
  for RecordIndex := 0 to Length(ARecordContent) -1 do
  begin
    FFileStructure.Fields[RecordIndex].Value := ARecordContent[RecordIndex];
    Result := FFileStructure.Fields[RecordIndex].Parse(AReasonForRejection);
    if not Result then
      Break;
  end;
end;

{ TImportEngine }

constructor TImportEngine.Create(const ASource: TCSVSourceFile;
  const ADestination: TDestination);
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
    FCSVSource.ExecuteProcess(FDestination);
end;

procedure TImportEngine.Prepare;
begin
  FPrepared := FCSVSource.Prepare;
  if FPrepared then
    FPrepared := FDestination.Prepare;
end;

procedure TImportEngine.Reset;
begin
  Prepared := False;
end;

procedure TImportEngine.SetDestination(const ADestination: TDestination);
begin
  if ADestination = Nil then
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
  FCSVSource := ASource;
end;

{ TSourceFile }

constructor TSourceFile.Create;
begin
  inherited Create;
  FFile := TStringList.Create;
end;

destructor TSourceFile.Destroy;
begin
  FFile.Free;
  inherited Destroy;
end;

procedure TSourceFile.SetFileName(const Value: String);
begin
  FFileName := Value;
  FFile.Clear;
end;

{ TFileDefinition }

function TFileDefinition.CreateDataField(const ARecord: TRecord; var AFileStructure: TRecord): Boolean;
var
  AuxDataType: String;
  AuxStringValue: String;
  AuxIntegerValue: Integer;
  AuxBooleanValue: Boolean;
  AuxField: IField;
begin
  TField.ParseValue(ARecord.FieldByName(TFileDefinitionFieldNames.FD_DATA_TYPE), AuxDataType);
  AuxField := TField.Create(ARecord.FieldByName(TFileDefinitionFieldNames.FD_FIELD_NAME).Value, AuxDataType);
  TField.ParseValue(ARecord.FieldByName(TFileDefinitionFieldNames.FD_ACCEPT_EMPTY), AuxBooleanValue);
  AuxField.AcceptEmpty := AuxBooleanValue;
  TField.ParseValue(ARecord.FieldByName(TFileDefinitionFieldNames.FD_VALIDATE_LENGTH), AuxBooleanValue);
  AuxField.ValidateLength := AuxBooleanValue;
  TField.ParseValue(ARecord.FieldByName(TFileDefinitionFieldNames.FD_DESTINATION_FIELD), AuxStringValue);
  AuxField.DestinationField := AuxStringValue;
  if AuxField.DestinationField = '' then
  begin
    TField.ParseValue(ARecord.FieldByName(TFileDefinitionFieldNames.FD_FIELD_NAME), AuxStringValue);
    AuxField.DestinationField := AuxStringValue;
  end;
  if AuxDataType = TDataType.dtString then
  begin
    TField.ParseValue(ARecord.FieldByName(TFileDefinitionFieldNames.FD_MAX_LENGTH), AuxIntegerValue);
    AuxField.MaxLength := AuxIntegerValue;
  end;
  AFileStructure.AddField(AuxField);
  Result := True;
end;

constructor TFileDefinition.Create(const AFileName: String);
begin
  inherited Create;
  InitializeFileDefinitionStructure;
  FFile := TStringList.Create;
  FFile.LoadFromFile(AFileName);
end;

destructor TFileDefinition.Destroy;
begin
  if FRecord <> Nil then
    FRecord.Destroy;
  if FFile <> Nil then
    FFile.Free;
  inherited;
end;

procedure TFileDefinition.InitializeFileDefinitionStructure;
begin
  FRecord := TRecord.Create;
  FFieldName := TField.Create(TFileDefinitionFieldNames.FD_FIELD_NAME, TDataType.dtString);
  FFieldName.AcceptEmpty := False;
  FRecord.AddField(FFieldName);
  FFieldDataType := TField.Create(TFileDefinitionFieldNames.FD_DATA_TYPE, TDataType.dtString);
  FFieldDataType.AcceptEmpty := False;
  FRecord.AddField(FFieldDataType);
  FFieldAcceptEmpty := TField.Create(TFileDefinitionFieldNames.FD_ACCEPT_EMPTY, TDataType.dtBoolean);
  FFieldAcceptEmpty.AcceptEmpty := False;
  FRecord.AddField(FFieldAcceptEmpty);
  FFieldValidateLength := TField.Create(TFileDefinitionFieldNames.FD_VALIDATE_LENGTH, TDataType.dtBoolean);
  FFieldValidateLength.AcceptEmpty := False;
  FRecord.AddField(FFieldValidateLength);
  FFieldMaxLength := TField.Create(TFileDefinitionFieldNames.FD_MAX_LENGTH, TDataType.dtInteger);
  FFieldMaxLength.AcceptEmpty := True;
  FRecord.AddField(FFieldMaxLength);
  FFieldDestinationFieldName := TField.Create(TFileDefinitionFieldNames.FD_DESTINATION_FIELD, TDataType.dtString);
  FFieldDestinationFieldName.AcceptEmpty := True;
  FRecord.AddField(FFieldDestinationFieldName);
end;

procedure TFileDefinition.Split(const ARecord: String; var ARecordContent: TArray<String>;
  const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char);
var
  AuxString: String;
  AuxStringResult: String;
  StringIndex: Integer;
  StringStarted: Boolean;
begin
  StringStarted := False;
  for StringIndex := 1 to ARecord.Length do
  begin
    AuxString := Copy(ARecord, StringIndex, 1);
    if (AuxString = ATextDelimiter) and (not StringStarted) then
    begin
      AuxString := AuxString.Replace(ATextDelimiter, '');
      StringStarted := True;
    end
    else
    begin
      if StringStarted then
      begin
        if AuxString = AFieldDelimiter then
          AuxString := AuxString.Replace(AFieldDelimiter, '')
        else if AuxString = ATextDelimiter then
        begin
          AuxString := AuxString.Replace(ATextDelimiter, '');
          StringStarted := False;
        end;
      end;
    end;
    AuxStringResult := AuxStringResult + AuxString;
  end;
  ARecordContent := AuxStringResult.Split([ADelimiter]);
end;

function TFileDefinition.SplitRecord(const ARecord: String; var ARecordContent: TArray<String>;
  const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean;
begin
  if System.Pos(ATextDelimiter, ARecord) > 0 then
    Split(ARecord, ARecordContent, ADelimiter, AFieldDelimiter, ATextDelimiter)
  else
    ARecordContent := ARecord.Split([ADelimiter]);
  Result := (Length(ARecordContent) > 0);
end;

{ TFlatSourceFile }

constructor TFlatSourceFile.Create(const AFileDefinitionName: String);
begin
  inherited Create;
end;

destructor TFlatSourceFile.Destroy;
begin
  inherited;
end;

{ TCSVFileDefinition }

constructor TCSVFileDefinition.Create(const AFileName: String);
begin
  inherited Create(AFileName);
  SetFieldDelimiter(',');
  SetRecordDelimiter(';');
  SetTextDelimiter('"');
end;

destructor TCSVFileDefinition.Destroy;
begin
  inherited;
end;

function TCSVFileDefinition.GetFieldDelimiter: Char;
begin
  Result:= FFieldDelimiter;
end;

function TCSVFileDefinition.GetRecordDelimiter: Char;
begin
  Result := FRecordDelimiter;
end;

function TCSVFileDefinition.GetTextDelimiter: Char;
begin
  Result := FTextDelimiter;
end;

procedure TCSVFileDefinition.SetFieldDelimiter(const Value: Char);
begin
  FFieldDelimiter := Value;
end;

procedure TCSVFileDefinition.SetRecordDelimiter(const Value: Char);
begin
  FRecordDelimiter := Value;
end;

procedure TCSVFileDefinition.SetTextDelimiter(const Value: Char);
begin
  FTextDelimiter := Value;
end;

function TCSVFileDefinition.ValidateFileDefinition(
  var AFileStructure: TRecord; var AReasonForRejection: String): Boolean;
var
  AuxFieldNamesList: TArray<String>;
  AuxRecordContent: TArray<String>;
  AuxRecord: TArray<String>;
  IndexFile: Integer;
  IndexField: Integer;
begin
  Result := True;
  SplitRecord(FFile[0], AuxRecord, FRecordDelimiter, FFieldDelimiter, FTextDelimiter);
  SplitRecord(AuxRecord[0], AuxFieldNamesList, FFieldDelimiter, FFieldDelimiter, FTextDelimiter);
  for IndexFile := 1 to FFile.Count -1 do
  begin
    SplitRecord(FFile[IndexFile], AuxRecord, FRecordDelimiter, FFieldDelimiter, FTextDelimiter);
    if Length(AuxRecord) > 0 then
    begin
      SplitRecord(AuxRecord[0], AuxRecordContent, FFieldDelimiter, FFieldDelimiter, FTextDelimiter);
      for IndexField := 0 to Length(AuxFieldNamesList) -1 do
      begin
        FRecord.FieldByName(AuxFieldNamesList[IndexField]).Value := Trim(AuxRecordContent[IndexField]);
        if not FRecord.FieldByName(AuxFieldNamesList[IndexField]).Parse(AReasonForRejection) then
        begin
          Result := False;
          Break;
        end
        else
        begin
          if AuxFieldNamesList[IndexField] = TFileDefinitionFieldNames.FD_VALIDATE_LENGTH then
            FRecord.FieldByName(TFileDefinitionFieldNames.FD_MAX_LENGTH).AcceptEmpty :=
              not TBooleanValidationRule(FRecord.FieldByName(AuxFieldNamesList[IndexField]).GetRule).GetValue;
        end;
      end;
      if Result then
        Result := CreateDataField(FRecord, AFileStructure);
      if not Result then
        Break;
    end;
  end;
end;

{ TNumericValidationRule }

constructor TNumericValidationRule.Create;
begin
  inherited;
end;

destructor TNumericValidationRule.Destroy;
begin
  inherited;
end;

function TNumericValidationRule.GetValue: Double;
begin
  Result := FValue;
end;

function TNumericValidationRule.IsNumeric(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
var
  AuxResult: Double;
  AuxIsValid: Integer;
begin
  Val(AValue, AuxResult, AuxIsValid);
  Result := (AuxIsValid = 0);
  if not Result then
    AReasonForRejection := Self.INVALID_NUMERIC_MESSAGE
  else
    FValue := AuxResult;
end;

function TNumericValidationRule.Parse(const AValue: Variant;
  var AReasonForRejection: String): Boolean;
begin
  AReasonForRejection := '';
  if AcceptEmpty then
  begin
    if not FieldIsEmpty(AValue) then
      Result := IsNumeric(AValue, AReasonForRejection)
    else
      Result := True;
  end
  else
  begin
    Result := not FieldIsEmpty(AValue, AReasonForRejection);
    if Result then
      Result := IsNumeric(AValue, AReasonForRejection);
  end;
end;

{ TDatabaseDestination }

function TDatabaseDestination.AssemblyScriptToPersistRecord(
  const AHeader: TArray<String>; const ARecord: TRecord): String;
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

function TDatabaseDestination.AssemblyScriptToPersistRecord(
  const ARecord: TRecord): String;
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

function TDatabaseDestination.BooleanToBit(
  const ABooleanValue: Boolean): Integer;
begin
  if ABooleanValue then
    Result := 1
  else
    Result := 0;
end;

constructor TDatabaseDestination.Create(const ASQLScript: TFDScript; const ATableName: String);
begin
  inherited Create;
  if ASQLScript <> Nil then
    FSQLScript := ASQLScript;
  SetTableName(ATableName);
end;

destructor TDatabaseDestination.Destroy;
begin
  inherited;
end;

function TDatabaseDestination.GetDataToAssemlySQL(const AField: IField): String;
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

function TDatabaseDestination.PersistRecord(const AHeader: TArray<String>;
  const ARecord: TRecord; var AReasonForRejection: String): Boolean;
begin
  Result := PersistWithFireDACSQLScript(AHeader, ARecord, FSQLScript, AReasonForRejection);
end;

function TDatabaseDestination.PersistRecord(const ARecord: TRecord; var AReasonForRejection: String): Boolean;
begin
  Result := PersistWithFireDACSQLScript(ARecord, FSQLScript, AReasonForRejection);
end;

function TDatabaseDestination.PersistWithFireDACSQLScript(
  const ARecord: TRecord; ASQLScript: TFDScript; var AReasonForRejection: String): Boolean;
var
  AuxScript: String;
begin
  AuxScript := AssemblyScriptToPersistRecord(ARecord);
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

function TDatabaseDestination.PersistWithFireDACSQLScript(const AHeader: TArray<String>;
  const ARecord: TRecord; ASQLScript: TFDScript; var AReasonForRejection: String): Boolean;
var
  AuxScript: String;
begin
  AuxScript := AssemblyScriptToPersistRecord(AHeader, ARecord);
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

function TDatabaseDestination.Prepare: Boolean;
begin
  Result := FSQLScript.Connection.Connected;
end;

procedure TDatabaseDestination.SetTableName(const Value: String);
begin
  FTableName := Value;
end;

{ TDestination }

constructor TDestination.Create;
begin
  inherited;
  FSQLAssembly := TStringBuilder.Create;
  FRejectedRecords := TStringList.Create;
end;

destructor TDestination.Destroy;
begin
  FRejectedRecords.Free;
  FSQLAssembly.Free;
  inherited;
end;

procedure TDestination.SaveRejectedRecordsToDisk(const AFileName: String);
var
  AuxFileName: String;
  AuxDateTimeFileName: String;
begin
  DateTimeToString(AuxDateTimeFileName, 'yyyy-mm-dd_hhnn', Now);
  AuxFileName := ExtractFilePath(AFileName) + 'REJECTED_RECORDS_' + AuxDateTimeFileName + '.txt';
  FRejectedRecords.SaveToFile(AuxFileName);
end;

procedure TDestination.SetRejectecRecord(const ARecord,
  AReasonForRejection: String);
var
  AuxAssemblyRejectedRecord: TStringBuilder;
begin
  AuxAssemblyRejectedRecord := TStringBuilder.Create;
  try
    AuxAssemblyRejectedRecord.Append('[').Append(ARecord).Append(']');
    AuxAssemblyRejectedRecord.Append(': ').Append(AReasonForRejection);
  finally
    FRejectedRecords.Add(AuxAssemblyRejectedRecord.ToString);
    AuxAssemblyRejectedRecord.Free;
  end;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;
end.
