unit UtilsU;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TStringUtils = class(TObject)
  private
    FSplit: TStringList;
    FList: TList<String>;
    FObjectsList: TList<TList<String>>;
  public
    constructor Create;
    destructor Destroy;
    function Split(const AString: String; const AFieldDelimiter: Char): TList<String>;
  end;

implementation

{ TStringUtils }

constructor TStringUtils.Create;
begin
  inherited Create;
  FSplit := TStringList.Create;
  FObjectsList := TList<TList<String>>.Create;
end;

destructor TStringUtils.Destroy;
var
  Index: Integer;
begin
  if Assigned(FSplit) then
    FreeAndNil(FSplit);
  if Assigned(FObjectsList) then
  begin
    for Index := 0 to FObjectsList.Count -1 do
      if Assigned(FObjectsList[Index]) then
        TList(FObjectsList[Index]).Free;
  end;
  inherited Destroy;
end;

function TStringUtils.Split(const AString: String;
  const AFieldDelimiter: Char): TList<String>;
var
  Index: Integer;
begin
  FSplit.Clear;
  FList := TList<String>.Create;
  FSplit.StrictDelimiter := True;
  FSplit.Delimiter := AFieldDelimiter;
  FSplit.DelimitedText := AString;
  for Index := 0 to FSplit.Count -1 do
    FList.Add(FSplit[Index]);
  FObjectsList.Add(FList);
  Result := FList;
end;

end.
