unit Importer.Framework.Source;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.Script,
  Importer.Framework.Interfaces;

type
  TSource = class
    function Prepare: Boolean; virtual; abstract;
    procedure ExecuteProcess(const ADestination: IDestination); virtual; abstract;
  end;

  TSourceFile = class(TSource)
  private
    FFileName: String;
    FFile: TStringList;
    FRejectedRecords: TStringList;
    procedure SetFileName(const Value: String);
  protected
    procedure SetRejectecRecord(const ARecord: String; const AReasonForRejection: String);
    procedure SaveRejectedRecordsToDisk(const AFileName: String);
  public
    constructor Create;
    destructor Destroy; override;
    function SplitRow(const ARecord: String; var ARecordContent: TArray<String>;
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
    FFileDefinition: IFileDefinition;
    FFileStructure: IRow;
    FHasHeader: Boolean;
    function ValidateFileDefinition(var AReasonForRejection: String): Boolean;
    function ProcessFileWithHeader(const ADestination: IDestination): Boolean;
    function ProcessFileWithoutHeader(const ADestination: IDestination): Boolean;
    procedure SetHasHeader(const Value: Boolean);
    function GetFieldDelimiter: Char;
    function GeTRowDelimiter: Char;
    function GetTextDelimiter: Char;
    procedure SetFieldDelimiter(const Value: Char);
    procedure SeTRowDelimiter(const Value: Char);
    procedure SetTextDelimiter(const Value: Char);
  public
    constructor Create(const AFileDefinitionName: String); overload;

    function SplitRow(const ARecord: String; var ARecordContent: TArray<String>;
      const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean; override;
    function ValidateRecord(const ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean; override;
    function ValidateRecord(const ARecordHeader: TArray<String>; const ARecordContent: TArray<String>;
      var AReasonForRejection: String): Boolean; override;
    function ParseRecord(const ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean; override;
    function ParseRecord(const ARecordHeader: TArray<String>; const ARecordContent: TArray<String>; var AReasonForRejection: String): Boolean; override;
    function Prepare: Boolean; override;
    procedure ExecuteProcess(const ADestination: IDestination); override;
    property HasHeader: Boolean read FHasHeader write SetHasHeader;
    property RecordDelimiter: Char read GeTRowDelimiter write SeTRowDelimiter;
    property FieldDelimiter: Char read GetFieldDelimiter write SetFieldDelimiter;
    property TextDelimiter: Char read GetTextDelimiter write SetTextDelimiter;
  end;

implementation

uses
  Importer.Framework.FileDefinition,
  Importer.Framework.ValidationRule,
  Importer.Framework.Field,
  Importer.Framework.Row,
  Importer.Framework.Destination;

{ TCSVSourceFile }

constructor TCSVSourceFile.Create(const AFileDefinitionName: String);
begin
  inherited Create;
  FHasHeader := True;
  FFileDefinition := TFileDefinition.Create(AFileDefinitionName);
  FFileStructure := TRow.Create;
end;

procedure TCSVSourceFile.ExecuteProcess(const ADestination: IDestination);
begin
  if HasHeader then
    ProcessFileWithHeader(ADestination)
  else
    ProcessFileWithoutHeader(ADestination);
  SaveRejectedRecordsToDisk(FileName);
end;

function TCSVSourceFile.GetFieldDelimiter: Char;
begin
  Result := FFileDefinition.TextDelimiter;
end;

function TCSVSourceFile.GeTRowDelimiter: Char;
begin
  Result := FFileDefinition.GeTRowDelimiter;
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

function TCSVSourceFile.ProcessFileWithHeader(const ADestination: IDestination): Boolean;
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
    Result := SpliTRow(FFile[FileIndex], AuxRecord, FFileDefinition.RowDelimiter,
      FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
    if Result then
    begin
      //Reading the record found on source file's line
      for RecordIndex := 0 to Length(AuxRecord) -1 do
      begin
        if (FileIndex = 0) and (RecordIndex = 0) then
        begin
          Result := SpliTRow(AuxRecord[RecordIndex], AuxRecordHeader, FFileDefinition.FieldDelimiter,
            FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
        end
        else
        begin
          Result := SpliTRow(AuxRecord[RecordIndex], AuxRecordContent, FFileDefinition.FieldDelimiter,
            FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
          if Result then
            Result := ValidateRecord(AuxRecordHeader, AuxRecordContent, AuxReasonForRejection);
          if Result then
            Result := ParseRecord(AuxRecordHeader, AuxRecordContent, AuxReasonForRejection);
          if Result then
            Result := ADestination.PersistRow(AuxRecordHeader, FFileStructure, AuxReasonForRejection);
        end;
        if not Result then
          SetRejectecRecord(AuxRecord[RecordIndex], AuxReasonForRejection);
      end;
    end;
  end;
end;

function TCSVSourceFile.ProcessFileWithoutHeader(const ADestination: IDestination): Boolean;
var
  FileIndex: Integer;
  RecordIndex: Integer;
  AuxRecord: TArray<String>;
  AuxRecordContent: TArray<String>;
  AuxReasonForRejection: String;
begin
  for FileIndex := 0 to FFile.Count -1 do
  begin
    Result := SpliTRow(FFile[FileIndex], AuxRecord, FFileDefinition.RowDelimiter,
      FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
    if Result then
    begin
      //Reading the record found on source file's line
      for RecordIndex := 0 to Length(AuxRecord) -1 do
      begin
        Result := SpliTRow(AuxRecord[RecordIndex], AuxRecordContent, FFileDefinition.FieldDelimiter,
          FFileDefinition.FieldDelimiter, FFileDefinition.TextDelimiter);
        if Result then
          Result := ValidateRecord(AuxRecordContent, AuxReasonForRejection);
        if Result then
          Result := ParseRecord(AuxRecordContent, AuxReasonForRejection);
        if Result then
          Result := ADestination.PersisTRow(FFileStructure, AuxReasonForRejection);
        if not Result then
          SetRejectecRecord(AuxRecord[RecordIndex], AuxReasonForRejection);
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

procedure TCSVSourceFile.SeTRowDelimiter(const Value: Char);
begin
  FFileDefinition.SeTRowDelimiter(Value);
end;

procedure TCSVSourceFile.SetTextDelimiter(const Value: Char);
begin
  FFileDefinition.SetTextDelimiter(Value);
end;

function TCSVSourceFile.SplitRow(const ARecord: String; var ARecordContent: TArray<String>;
  const ADelimiter: Char; const AFieldDelimiter: Char; const ATextDelimiter: Char): Boolean;
begin
  Result := FFileDefinition.SplitRow(ARecord, ARecordContent, ADelimiter, AFieldDelimiter, ATextDelimiter);
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

{ TSourceFile }

constructor TSourceFile.Create;
begin
  inherited Create;
  FFile := TStringList.Create;
  FRejectedRecords := TStringList.Create;
end;

destructor TSourceFile.Destroy;
begin
  FRejectedRecords.Free;
  FFile.Free;
  inherited Destroy;
end;

procedure TSourceFile.SaveRejectedRecordsToDisk(const AFileName: String);
var
  AuxFileName: String;
  AuxDateTimeFileName: String;
begin
  DateTimeToString(AuxDateTimeFileName, 'yyyy-mm-dd_hhnn', Now);
  AuxFileName := ExtractFilePath(AFileName) + 'REJECTED_RECORDS_' + AuxDateTimeFileName + '.txt';
  FRejectedRecords.SaveToFile(AuxFileName);
end;

procedure TSourceFile.SetFileName(const Value: String);
begin
  FFileName := Value;
  FFile.Clear;
end;

procedure TSourceFile.SetRejectecRecord(const ARecord, AReasonForRejection: String);
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

end.
