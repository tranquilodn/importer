unit Importer.Framework.Row;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.Script,
  Importer.Framework.Interfaces,
  Importer.Framework.Defines;

type
  TRow = class(TInterfacedObject, IRow)
  private
    FFields: TList<IField>;
    function FieldNameAlreadyExists(const AFieldName: String): Boolean;
    function GetFields: TList<IField>;
  public
    constructor Create;
    destructor Destroy; override;
    function FieldByName(AFieldName: String): IField;
    procedure AddField(AField: IField);
    property Fields: TList<IField> read GetFields;
  end;

implementation

uses
  Importer.Framework.ValidationRule,
  Importer.Framework.Field;

{ TRow }

procedure TRow.AddField(AField: IField);
begin
  if AField = nil then
    raise ENullPointerException.Create(ENullPointerException.NULL_POINTER_EXCEPTION_MESSAGE);
  if FFields = nil then
    FFields := TList<IField>.Create;
  if FieldNameAlreadyExists(AField.Name) then
    raise EFieldNameMustBeUniqueException.Create(EFieldNameMustBeUniqueException.FIELD_NAME_MUST_BE_UNIQUE_MESSAGE);
  FFields.Add(AField);
end;

constructor TRow.Create;
begin
  inherited Create;
  FFields := Nil;
end;

destructor TRow.Destroy;
begin
  if Assigned(FFields) then
    FFields.Free;
  inherited;
end;

function TRow.FieldByName(AFieldName: String): IField;
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

function TRow.FieldNameAlreadyExists(const AFieldName: String): Boolean;
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

function TRow.GetFields: TList<IField>;
begin
  Result := FFields;
end;

end.
