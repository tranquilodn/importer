object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'CSV Importer'
  ClientHeight = 391
  ClientWidth = 737
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object eFileName: TLabeledEdit
    Left = 97
    Top = 61
    Width = 274
    Height = 21
    TabStop = False
    EditLabel.Width = 82
    EditLabel.Height = 13
    EditLabel.Caption = 'Source File Name'
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object bSelectFile: TBitBtn
    Left = 374
    Top = 59
    Width = 63
    Height = 25
    Caption = 'Select File'
    TabOrder = 3
    OnClick = bSelectFileClick
  end
  object bExecute: TButton
    Left = 241
    Top = 93
    Width = 100
    Height = 25
    Caption = 'Execute'
    Enabled = False
    TabOrder = 5
    OnClick = bExecuteClick
  end
  object bValidate: TBitBtn
    Left = 443
    Top = 59
    Width = 63
    Height = 25
    Caption = 'Validate'
    TabOrder = 4
    OnClick = bValidateClick
  end
  object bReset: TButton
    Left = 135
    Top = 93
    Width = 100
    Height = 25
    Caption = 'Reset'
    Enabled = False
    TabOrder = 6
    OnClick = bResetClick
  end
  object eFileDefinition: TLabeledEdit
    Left = 97
    Top = 28
    Width = 274
    Height = 21
    TabStop = False
    EditLabel.Width = 64
    EditLabel.Height = 13
    EditLabel.Caption = 'File Definition'
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 0
  end
  object bSelectFileDefinition: TBitBtn
    Left = 374
    Top = 26
    Width = 63
    Height = 25
    Caption = 'Select File'
    TabOrder = 1
    OnClick = bSelectFileDefinitionClick
  end
  object gbProgress: TGroupBox
    Left = 48
    Top = 133
    Width = 425
    Height = 72
    Caption = ' Progress '
    TabOrder = 7
    Visible = False
    object lImporting: TLabel
      Left = 44
      Top = 47
      Width = 269
      Height = 13
      AutoSize = False
      Caption = 'Importing file. Please wait...'
      Visible = False
    end
    object pbImportFile: TProgressBar
      Left = 32
      Top = 25
      Width = 361
      Height = 17
      TabOrder = 0
      Visible = False
    end
  end
  object chkHasHeader: TCheckBox
    Left = 374
    Top = 97
    Width = 97
    Height = 17
    Caption = 'File Has Header'
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object dlgOpenFile: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 560
    Top = 24
  end
  object dbConnection: TFDConnection
    Params.Strings = (
      'SERVER=TRANQUILODN-LT\MSSQL2017'
      'User_Name=sa'
      'Password=sql'
      'ApplicationName=CSVImporter'
      'Workstation=TRANQUILODN-LT'
      'DATABASE=TestDB'
      'MARS=yes'
      'DriverID=MSSQL')
    Connected = True
    LoginPrompt = False
    Transaction = dbTransaction
    Left = 632
    Top = 24
  end
  object dbTransaction: TFDTransaction
    Connection = dbConnection
    Left = 632
    Top = 72
  end
  object fdScript: TFDScript
    SQLScripts = <>
    Connection = dbConnection
    Transaction = dbTransaction
    Params = <>
    Macros = <>
    Left = 632
    Top = 120
  end
end
