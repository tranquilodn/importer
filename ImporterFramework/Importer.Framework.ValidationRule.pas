unit Importer.Framework.ValidationRule;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.Script,
  Importer.Framework.Interfaces,
  Importer.Framework.Defines;

type
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

implementation

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

end.
