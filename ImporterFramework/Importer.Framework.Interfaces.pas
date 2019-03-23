unit Importer.Framework.Interfaces;

interface

type
  IValidationRule = interface(IInterface)
    ['{884BB8E4-AD12-458B-BC41-3AEFF1692B84}']

    function GetAcceptEmpty: Boolean;
    procedure SetAcceptEmpty(const Value: Boolean);
    function GetMaxLength: Integer;
    procedure SetMaxLength(const Value: Integer);
    function GetValidateLength: Boolean;
    procedure SetValidateLength(const Value: Boolean);
    function Parse(const AValue: Variant; var AReasonForRejection: String): Boolean;
    property AcceptEmpty: Boolean read GetAcceptEmpty write SetAcceptEmpty;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
    property ValidateLength: Boolean read GetValidateLength write SetValidateLength;
  end;

  IField = interface(IInterface)
    ['{BBB4DF89-5F6D-47E9-9DA8-55C3B5A91987}']

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

    function Parse(var AReasonForRejection: String): Boolean;
    function GetRule: IValidationRule;

    property Name: String read GetFieldName write SetFieldName;
    property DestinationField: String read GetDestinationField write SetDestinationField;
    property IsValid: Boolean read GetFieldIsValid write SetFieldIsValid;
    property Value: Variant read GetValue write SetValue;
    property AcceptEmpty: Boolean read GetAcceptEmpty write SetAcceptEmpty;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
    property ValidateLength: Boolean read GetValidateLength write SetValidateLength;
  end;

implementation

end.
