unit Importer.Framework.Field;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.Script,
  Importer.Framework.Interfaces,
  Importer.Framework.Defines;

type
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

implementation

uses
  Importer.Framework.ValidationRule;

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

end.
