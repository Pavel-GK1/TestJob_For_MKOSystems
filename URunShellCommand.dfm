object FmRunShellCommand: TFmRunShellCommand
  Left = 0
  Top = 0
  Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1074#1085#1077#1096#1085#1102#1102' '#1082#1086#1084#1072#1085#1076#1091
  ClientHeight = 411
  ClientWidth = 624
  Color = clBtnFace
  Constraints.MinHeight = 450
  Constraints.MinWidth = 640
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    624
    411)
  TextHeight = 15
  object BtnClose: TButton
    Left = 511
    Top = 379
    Width = 98
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = BtnCloseClick
    ExplicitLeft = 569
    ExplicitTop = 304
  end
  object PC_ShellCommand: TPageControl
    Left = 8
    Top = 10
    Width = 613
    Height = 363
    ActivePage = TS1_RunCommandLine
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object TS1_RunCommandLine: TTabSheet
      Caption = #1050#1086#1084#1072#1085#1076#1085#1072#1103' '#1089#1090#1088#1086#1082#1072
      DesignSize = (
        605
        333)
      object Label1: TLabel
        Left = 8
        Top = 64
        Width = 192
        Height = 15
        Caption = #1057#1090#1088#1086#1082#1072' '#1082#1086#1084#1072#1085#1076#1099' '#1076#1083#1103' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103' :'
      end
      object Label2: TLabel
        Left = 8
        Top = 114
        Width = 241
        Height = 15
        AutoSize = False
        Caption = #1053#1072#1087#1088#1080#1084#1077#1088' :  tar -cvf PasFiles.tar *.pas'
        WordWrap = True
      end
      object Label3: TLabel
        Left = 8
        Top = 140
        Width = 117
        Height = 15
        Caption = #1053#1072#1073#1088#1072#1085#1085#1099#1077' '#1082#1086#1084#1072#1085#1076#1099
      end
      object sbGetDirPath: TSpeedButton
        Left = 500
        Top = 24
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
      end
      object Label4: TLabel
        Left = 8
        Top = 3
        Width = 192
        Height = 15
        Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1090#1077#1082#1091#1097#1077#1081' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1102' : '
      end
      object BtnRunCommand: TButton
        Left = 504
        Top = 84
        Width = 98
        Height = 25
        Anchors = [akTop, akRight]
        Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
        TabOrder = 0
        OnClick = BtnRunCommandClick
        ExplicitLeft = 557
      end
      object BtnClearCommandsList: TButton
        Left = 8
        Top = 301
        Width = 145
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
        TabOrder = 1
        OnClick = BtnClearCommandsListClick
        ExplicitTop = 323
      end
      object EdCommandLine: TEdit
        Left = 8
        Top = 85
        Width = 486
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        Text = 'tar -cvf PasFiles.tar *.pas'
        ExplicitWidth = 539
      end
      object LB_EnteredCommands: TListBox
        Left = 8
        Top = 160
        Width = 594
        Height = 135
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = clBlack
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ItemHeight = 15
        ParentFont = False
        TabOrder = 3
        OnClick = LB_EnteredCommandsClick
      end
      object EdDirPath: TEdit
        Left = 8
        Top = 24
        Width = 486
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
        Text = 'd:\My_Projects\TestJob_For_MKOSystems'
        ExplicitWidth = 539
      end
    end
    object TS2_RunCommandsResults: TTabSheet
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103
      ImageIndex = 1
      DesignSize = (
        605
        333)
      object LBResults: TListBox
        Left = 3
        Top = 16
        Width = 599
        Height = 283
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 15
        TabOrder = 0
      end
      object BtnClearResulrsList: TButton
        Left = 3
        Top = 305
        Width = 129
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
        TabOrder = 1
        OnClick = BtnClearResulrsListClick
      end
    end
    object TS3_Logs: TTabSheet
      Caption = #1051#1086#1075#1080' '#1087#1086' '#1079#1072#1076#1072#1095#1077
      ImageIndex = 2
      DesignSize = (
        605
        333)
      object MemoLog: TMemo
        Left = 3
        Top = 3
        Width = 598
        Height = 327
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
end
