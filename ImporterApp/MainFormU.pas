unit MainFormU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB,
  Vcl.ExtCtrls, Vcl.Buttons, ImporterFrameworkU, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, System.UITypes, FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.Util, FireDAC.Comp.Script, FireDAC.Comp.Client, Vcl.ComCtrls;

type
  TImportProcess = class(TThread)
    FImportEngine: TImportEngine;
  public
    constructor Create(CreateSuspended: Boolean; AImportEngine: TImportEngine);
    destructor Destroy; override;
    procedure Execute; override;
  end;

  TMainForm = class(TForm)
    eFileName: TLabeledEdit;
    dlgOpenFile: TFileOpenDialog;
    bSelectFile: TBitBtn;
    bExecute: TButton;
    bValidate: TBitBtn;
    bReset: TButton;
    eFileDefinition: TLabeledEdit;
    bSelectFileDefinition: TBitBtn;
    dbConnection: TFDConnection;
    dbTransaction: TFDTransaction;
    fdScript: TFDScript;
    gbProgress: TGroupBox;
    pbImportFile: TProgressBar;
    lImporting: TLabel;
    chkHasHeader: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bSelectFileClick(Sender: TObject);
    procedure bExecuteClick(Sender: TObject);
    procedure bValidateClick(Sender: TObject);
    procedure bSelectFileDefinitionClick(Sender: TObject);
    procedure bResetClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FSourceFile: TCSVSourceFile;
    FDestination: TDatabaseDestination;
    ImportEngine: TImportEngine;
    InExecution: Boolean;
    procedure ResetStructure;
    procedure SelectFileDefinition;
    procedure SelectFile;
    procedure ExecuteProcess;
    procedure ValidateProcess;
    procedure FinalizeProcess;
    procedure UpdateUserInterface;
    function IsReady: Boolean;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

procedure TMainForm.bExecuteClick(Sender: TObject);
begin
  ExecuteProcess;
end;

procedure TMainForm.bResetClick(Sender: TObject);
begin
  ResetStructure;
end;

procedure TMainForm.bSelectFileClick(Sender: TObject);
begin
  SelectFile;
end;

procedure TMainForm.bSelectFileDefinitionClick(Sender: TObject);
begin
  SelectFileDefinition;
end;

procedure TMainForm.bValidateClick(Sender: TObject);
begin
  ValidateProcess;
end;

procedure TMainForm.ExecuteProcess;
var
  AuxThread: TImportProcess;
begin
  AuxThread := TImportProcess.Create(True, ImportEngine);
  try
    try
      InExecution := True;
      UpdateUserInterface;
      Application.ProcessMessages;
      if MessageDlg('Confirm the Process?', mtConfirmation, [mbYes,mbNo], mrNo) = mrNo then
        Exit;
      AuxThread.Execute;
    except
      on E: Exception do
      begin
        MessageDlg(E.Message, mtError, [mbOk], mrOk);
        InExecution := False;
      end;
    end;
  finally
    InExecution := False;
    ResetStructure;
    Application.ProcessMessages;
    AuxThread.Destroy;
  end;
end;

procedure TMainForm.FinalizeProcess;
begin
  FSourceFile.Destroy;
  FDestination.Destroy;
  ImportEngine.Destroy;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if bReset.Enabled then
    ResetStructure;
  CanClose := not bReset.Enabled;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  InExecution := False;
  Width := 530;
  Height := 250;
  Position := TPosition.poScreenCenter;
end;

function TMainForm.IsReady: Boolean;
begin
  Result := False;
  if Trim(eFileDefinition.Text) = '' then
  begin
    MessageDlg('Select the "File Definition" file first.', mtWarning, [mbOk], mrOk);
    bSelectFileDefinition.SetFocus;
    Exit;
  end;
  if Trim(eFileName.Text) = '' then
  begin
    MessageDlg('Select a " Source File" first.', mtWarning, [mbOk], mrOk);
    bSelectFile.SetFocus;
    Exit;
  end;
  Result := True;
end;

procedure TMainForm.ResetStructure;
begin
  ImportEngine.Reset;
  eFileDefinition.Clear;
  eFileName.Clear;
  UpdateUserInterface;
  bSelectFileDefinition.SetFocus;
  FinalizeProcess;
end;

procedure TMainForm.SelectFile;
begin
  if dlgOpenFile.Execute then
    eFileName.Text := dlgOpenFile.FileName;
end;

procedure TMainForm.SelectFileDefinition;
begin
  if dlgOpenFile.Execute then
    eFileDefinition.Text := dlgOpenFile.FileName;
end;

procedure TMainForm.UpdateUserInterface;
begin
  eFileName.Enabled := not ImportEngine.Prepared;
  eFileDefinition.Enabled := not ImportEngine.Prepared;
  bSelectFileDefinition.Enabled := not ImportEngine.Prepared;
  bSelectFile.Enabled := bSelectFileDefinition.Enabled;
  bValidate.Enabled := bSelectFile.Enabled;
  chkHasHeader.Enabled := bValidate.Enabled;
  bReset.Enabled := ImportEngine.Prepared and (not InExecution);
  bExecute.Enabled := ImportEngine.Prepared and (not InExecution);
  gbProgress.Visible := InExecution;
  pbImportFile.Visible := gbProgress.Visible;
  lImporting.Visible := gbProgress.Visible;
end;

procedure TMainForm.ValidateProcess;
begin
  if not IsReady then
    Exit;
  FSourceFile := TCSVSourceFile.Create(eFileDefinition.Text);
  FSourceFile.FileName := eFileName.Text;
  FSourceFile.HasHeader := chkHasHeader.Checked;
  FDestination := TDatabaseDestination.Create(fdScript, 'TestTable');
  ImportEngine := TImportEngine.Create(FSourceFile, FDestination, pbImportFile);
  //ImportEngine := TImportEngine.Create(FSourceFile, FDestination);
  try
    ImportEngine.Prepare;
    UpdateUserInterface;
    Application.ProcessMessages;
  except
    on E: Exception do
    begin
      MessageDlg(E.Message, mtError, [mbOk], mrOk);
      FSourceFile.Destroy;
      FDestination.Destroy;
      ImportEngine.Destroy;
    end;
  end;
end;

{ TImportProcess }

constructor TImportProcess.Create(CreateSuspended: Boolean;
  AImportEngine: TImportEngine);
begin
  inherited Create(CreateSuspended);
  FImportEngine := AImportEngine;
end;

destructor TImportProcess.Destroy;
begin
  inherited;
end;

procedure TImportProcess.Execute;
begin
  inherited;
  FImportEngine.Execute;
end;

end.
