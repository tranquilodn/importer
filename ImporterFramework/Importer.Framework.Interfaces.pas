unit Importer.Framework.Interfaces;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

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

  IRow = interface
    ['{8DAA47BA-0570-4D9B-A4D6-C0E29FAD39A3}']

    function GetFields: TList<IField>;

    function FieldByName(AFieldName: String): IField;
    procedure AddField(AField: IField);

    property Fields: TList<IField> read GetFields;
  end;

  IFileDefinition = interface
    ['{E86FE944-B758-41B3-926E-376FCB5FD147}']

    function GetRowDelimiter: Char;
    procedure SetRowDelimiter(const Value: Char);

    function GetFieldDelimiter: Char;
    procedure SetFieldDelimiter(const Value: Char);

    function GetTextDelimiter: Char;
    procedure SetTextDelimiter(const Value: Char);

    function SplitRow(const ARecord: String; var ARecordContent: TArray<String>;
      const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean;

    function ValidateFileDefinition(var AFileStructure: IRow; var AReasonForRejection: String): Boolean;

    property RowDelimiter: Char read GetRowDelimiter write SetRowDelimiter;
    property FieldDelimiter: Char read GetFieldDelimiter write SetFieldDelimiter;
    property TextDelimiter: Char read GetTextDelimiter write SetTextDelimiter;
  end;

  ISource = interface
    ['{D95827D5-2B42-4BFF-B8AC-9D6C2A3A5E71}']


  end;

  IDestination = interface
    ['{C2B41826-654E-4C87-BD7B-8D21B0639247}']


    function GetTableName: String;
    procedure SetTableName(const Value: String);
    function GetSQLAssembly: TStringBuilder;

    function PersistRow(const AHeader: TArray<String>; const ARecord: IRow; var AReasonForRejection: String): Boolean; overload;
    function PersistRow(const ARecord: IRow; var AReasonForRejection: String): Boolean; overload;
    function Prepare: Boolean;

    property TableName: String read GetTableName write SetTableName;
    property SQLAssembly: TStringBuilder read GetSQLAssembly;
  end;

  IImportEngine = interface
    ['{E711B0B1-D1FB-491F-AD13-75772B312027}']

    function GetPrepared: Boolean;
    procedure SetPrepared(const Value: Boolean);

    procedure Prepare;
    procedure Reset;
    procedure Execute;

    function WithFileDefinition(const AValidator: IFileDefinition): IImportEngine;

    property Prepared: Boolean read GetPrepared write SetPrepared;
  end;

implementation

end.
