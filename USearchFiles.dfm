object FmSearchFiles: TFmSearchFiles
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #1047#1072#1076#1072#1095#1072' '#1087#1086#1080#1089#1082#1072' '#1092#1072#1081#1083#1086#1074' '#1074' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1103#1093
  ClientHeight = 261
  ClientWidth = 645
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 635
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  DesignSize = (
    645
    261)
  TextHeight = 15
  object BtnClose: TButton
    Left = 486
    Top = 229
    Width = 105
    Height = 24
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = BtnCloseClick
    ExplicitLeft = 460
    ExplicitTop = 334
  end
  object PCSearchFiles: TPageControl
    Left = 8
    Top = 8
    Width = 627
    Height = 208
    ActivePage = TS1_ParamsTask
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object TS1_ParamsTask: TTabSheet
      Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1080#1089#1082#1072
      DesignSize = (
        619
        178)
      object Label3: TLabel
        Left = 3
        Top = 85
        Width = 524
        Height = 15
        Caption = 
          #1052#1072#1089#1082#1072' '#1076#1083#1103' '#1087#1086#1080#1089#1082#1072' '#1092#1072#1081#1083#1086#1074' ('#1080#1083#1080' '#1085#1077#1089#1082#1086#1083#1100#1082#1086' '#1084#1072#1089#1086#1082' '#1095#1077#1088#1077#1079' '#1079#1072#1087#1103#1090#1091#1102', '#1085#1072#1087#1088 +
          '. *.txt '#1080#1083#1080' *.*, *.txt, *.bmp)'
      end
      object sbGetDirPath: TSpeedButton
        Left = 573
        Top = 29
        Width = 23
        Height = 23
        Hint = #1059#1082#1072#1079#1072#1090#1100' '#1087#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
        Anchors = [akTop, akRight]
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
          5555555555555555555555555555555555555555555555555555555555555555
          555555555555555555555555555555555555555FFFFFFFFFF555550000000000
          55555577777777775F55500B8B8B8B8B05555775F555555575F550F0B8B8B8B8
          B05557F75F555555575F50BF0B8B8B8B8B0557F575FFFFFFFF7F50FBF0000000
          000557F557777777777550BFBFBFBFB0555557F555555557F55550FBFBFBFBF0
          555557F555555FF7555550BFBFBF00055555575F555577755555550BFBF05555
          55555575FFF75555555555700007555555555557777555555555555555555555
          5555555555555555555555555555555555555555555555555555}
        NumGlyphs = 2
        ParentShowHint = False
        ShowHint = True
        OnClick = sbGetDirPathClick
        ExplicitLeft = 503
      end
      object Label2: TLabel
        Left = 3
        Top = 8
        Width = 351
        Height = 15
        Caption = #1042#1099#1073#1086#1088' '#1089#1090#1072#1088#1090#1086#1074#1086#1081' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1080' '#1076#1083#1103' '#1086#1073#1079#1086#1088#1072' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1081' '#1080' '#1092#1072#1081#1083#1086#1074
      end
      object EdDirPath: TEdit
        Left = 3
        Top = 29
        Width = 555
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = 'd:\My_Projects\TestJob_For_MKOSystems'
        ExplicitWidth = 485
      end
      object edFileMask: TEdit
        Left = 3
        Top = 106
        Width = 555
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        Text = '*.*'
        ExplicitWidth = 485
      end
      object cbDoRecursive: TCheckBox
        Left = 3
        Top = 58
        Width = 225
        Height = 17
        Caption = #1048#1089#1082#1072#1090#1100' '#1074#1086' '#1074#1083#1086#1078#1077#1085#1085#1099#1093' '#1087#1072#1087#1082#1072#1093
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object BtnSearchFiles: TButton
        Left = 3
        Top = 146
        Width = 105
        Height = 24
        Anchors = [akLeft, akBottom]
        Caption = #1048#1089#1082#1072#1090#1100' '#1092#1072#1081#1083#1099
        TabOrder = 3
        OnClick = BtnSearchFilesClick
        ExplicitTop = 147
      end
    end
    object TS2_ResultTask: TTabSheet
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103
      ImageIndex = 1
      DesignSize = (
        619
        178)
      object LblFilesCount: TLabel
        Left = 184
        Top = 3
        Width = 72
        Height = 15
        Caption = 'LblFilesCount'
      end
      object Label1: TLabel
        Left = 16
        Top = 3
        Width = 149
        Height = 15
        Caption = #1053#1072#1081#1076#1077#1085#1085#1099#1077' '#1092#1072#1081#1083#1099', '#1074#1089#1077#1075#1086' : '
      end
      object LbResults: TListBox
        Left = 16
        Top = 24
        Width = 587
        Height = 144
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 15
        TabOrder = 0
        ExplicitWidth = 657
        ExplicitHeight = 249
      end
    end
  end
  object TmrStartFillFilesList: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TmrStartFillFilesListTimer
    Left = 488
    Top = 8
  end
end
