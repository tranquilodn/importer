unit Importer.Framework.FileDefinition;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.Script,
  Importer.Framework.Interfaces,
  Importer.Framework.Defines;

type
  TFileDefinition = class(TInterfacedObject, IFileDefinition)
  private
    FRecord: IRow;
    FFile: TStringList;
    FFieldName: IField;
    FFieldDataType: IField;
    FFieldAcceptEmpty: IField;
    FFieldMaxLength: IField;
    FFieldValidateLength: IField;
    FFieldDestinationFieldName: IField;

    FFieldDelimiter: Char;
    FRowDelimiter: Char;
    FTextDelimiter: Char;

    function GetFieldDelimiter: Char;
    procedure SetFieldDelimiter(const Value: Char);
    function GetRowDelimiter: Char;
    procedure SetRowDelimiter(const Value: Char);
    function GetTextDelimiter: Char;
    procedure SetTextDelimiter(const Value: Char);

    procedure InitializeFileDefinitionStructure;
    procedure Split(const ARecord: String; var ARecordContent: TArray<String>;
      const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char);
    function CreateDataField(const ARecord: IRow; var AFileStructure: IRow): Boolean;
  public
    constructor Create(const AFileName: String);
    destructor Destroy; override;

    function SplitRow(const ARecord: String; var ARecordContent: TArray<String>;
      const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean;

    function ValidateFileDefinition(var AFileStructure: IRow; var AReasonForRejection: String): Boolean;

    property RowDelimiter: Char read GetRowDelimiter write SetRowDelimiter;
    property FieldDelimiter: Char read GetFieldDelimiter write SetFieldDelimiter;
    property TextDelimiter: Char read GetTextDelimiter write SetTextDelimiter;
  end;

implementation

uses
  Importer.Framework.ValidationRule,
  Importer.Framework.Field,
  Importer.Framework.Row;

{ TFileDefinition }

function TFileDefinition.CreateDataField(const ARecord: IRow; var AFileStructure: IRow): Boolean;
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
  SetFieldDelimiter(',');
  SetRowDelimiter(';');
  SetTextDelimiter('"');
end;

destructor TFileDefinition.Destroy;
begin
  if FFile <> Nil then
    FFile.Free;
  inherited;
end;

procedure TFileDefinition.InitializeFileDefinitionStructure;
begin
  FRecord := TRow.Create;
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

function TFileDefinition.SplitRow(const ARecord: String; var ARecordContent: TArray<String>;
  const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean;
begin
  if System.Pos(ATextDelimiter, ARecord) > 0 then
    Split(ARecord, ARecordContent, ADelimiter, AFieldDelimiter, ATextDelimiter)
  else
    ARecordContent := ARecord.Split([ADelimiter]);
  Result := (Length(ARecordContent) > 0);
end;

function TFileDefinition.GetFieldDelimiter: Char;
begin
  Result:= FFieldDelimiter;
end;

function TFileDefinition.GetRowDelimiter: Char;
begin
  Result := FRowDelimiter;
end;

function TFileDefinition.GetTextDelimiter: Char;
begin
  Result := FTextDelimiter;
end;

procedure TFileDefinition.SetFieldDelimiter(const Value: Char);
begin
  FFieldDelimiter := Value;
end;

procedure TFileDefinition.SetRowDelimiter(const Value: Char);
begin
  FRowDelimiter := Value;
end;

procedure TFileDefinition.SetTextDelimiter(const Value: Char);
begin
  FTextDelimiter := Value;
end;

function TFileDefinition.ValidateFileDefinition(var AFileStructure: IRow; var AReasonForRejection: String): Boolean;
var
  AuxFieldNamesList: TArray<String>;
  AuxRecordContent: TArray<String>;
  AuxRecord: TArray<String>;
  IndexFile: Integer;
  IndexField: Integer;
begin
  Result := True;
  SpliTRow(FFile[0], AuxRecord, FRowDelimiter, FFieldDelimiter, FTextDelimiter);
  SpliTRow(AuxRecord[0], AuxFieldNamesList, FFieldDelimiter, FFieldDelimiter, FTextDelimiter);
  for IndexFile := 1 to FFile.Count -1 do
  begin
    SpliTRow(FFile[IndexFile], AuxRecord, FRowDelimiter, FFieldDelimiter, FTextDelimiter);
    if Length(AuxRecord) > 0 then
    begin
      SpliTRow(AuxRecord[0], AuxRecordContent, FFieldDelimiter, FFieldDelimiter, FTextDelimiter);
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

end.
