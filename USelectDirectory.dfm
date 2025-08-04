object SelectDirectory: TSelectDirectory
  Left = 0
  Top = 0
  Anchors = [akLeft, akTop, akRight]
  Caption = #1054#1073#1079#1086#1088' '#1087#1072#1087#1086#1082
  ClientHeight = 380
  ClientWidth = 712
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    712
    380)
  TextHeight = 13
  object Label1: TLabel
    Left = 7
    Top = 24
    Width = 84
    Height = 13
    Caption = #1055#1091#1090#1100' '#1082' '#1082#1072#1090#1072#1083#1086#1075#1091
  end
  object Label2: TLabel
    Left = 8
    Top = 4
    Width = 35
    Height = 13
    Caption = #1044#1080#1089#1082' : '
  end
  object FilesCountLabel: TLabel
    Left = 229
    Top = 24
    Width = 45
    Height = 13
    Caption = #1060#1072#1081#1083#1086#1074' :'
  end
  object DirectoryListBox: TDirectoryListBox
    Left = 8
    Top = 43
    Width = 339
    Height = 294
    Anchors = [akLeft, akTop, akBottom]
    FileList = FileListBox
    TabOrder = 0
    OnChange = DirectoryListBoxChange
  end
  object bnCancel: TButton
    Left = 629
    Top = 347
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object bnOK: TButton
    Left = 492
    Top = 347
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object cbDrive: TDriveComboBox
    Left = 47
    Top = 1
    Width = 145
    Height = 19
    DirList = DirectoryListBox
    TabOrder = 3
  end
  object FileListBox: TFileListBox
    Left = 353
    Top = 47
    Width = 352
    Height = 294
    Anchors = [akLeft, akTop, akRight, akBottom]
    ExtendedSelect = False
    ItemHeight = 13
    Mask = '*.dat'
    TabOrder = 4
    OnDblClick = FileListBoxDblClick
  end
end
