unit Importer.Framework.Defines;

interface

uses
  System.SysUtils;

type
  EImporterFrameworkException = class(Exception);

  EFileDefinitionNotAssignedException = class(EImporterFrameworkException);

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

  TFileDefinitionFieldNames = record
  const
    FD_FIELD_NAME = 'FIELD_NAME';
    FD_DATA_TYPE = 'DATA_TYPE';
    FD_ACCEPT_EMPTY = 'ACCEPT_EMPTY';
    FD_VALIDATE_LENGTH = 'VALIDATE_LENGTH';
    FD_MAX_LENGTH = 'MAX_LENGTH';
    FD_DESTINATION_FIELD = 'DESTINATION_FIELD';
  end;

  TValidateMessage = class
  const
    FIELD_EMPTY_MESSAGE = 'Field must have a value';
    INVALID_BOOLEAN_MESSAGE = 'Invalid boolean';
    INVALID_INTEGER_MESSAGE = 'Invalid integer value';
    INVALID_NUMERIC_MESSAGE = 'Invalid numeric value';
    INVALID_STRING_MESSAGE = 'Invalid string';
    INVALID_LENGTH_MESSAGE = 'Invalid field length';
    INVALID_CURRENCY_MESSAGE = 'Invalid currency value';
  end;

implementation

end.
