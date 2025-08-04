object FmSearchEntriesSubstrInFile: TFmSearchEntriesSubstrInFile
  Left = 0
  Top = 0
  Caption = 'FmSearchEntriesSubstrInFile'
  ClientHeight = 221
  ClientWidth = 644
  Color = clBtnFace
  Constraints.MinHeight = 260
  Constraints.MinWidth = 660
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  DesignSize = (
    644
    221)
  TextHeight = 15
  object PC_SearchEntries: TPageControl
    Left = 8
    Top = 8
    Width = 627
    Height = 172
    ActivePage = TS2_ResultTask
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object TS1_ParamsTask: TTabSheet
      Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1080#1089#1082#1072
      DesignSize = (
        619
        142)
      object Label3: TLabel
        Left = 3
        Top = 58
        Width = 81
        Height = 15
        Caption = #1057#1090#1088#1086#1082#1072' '#1087#1086#1080#1089#1082#1072
      end
      object sbGetFilePath: TSpeedButton
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
        OnClick = sbGetFilePathClick
        ExplicitLeft = 503
      end
      object Label2: TLabel
        Left = 3
        Top = 8
        Width = 244
        Height = 15
        Caption = #1042#1099#1073#1086#1088' '#1092#1072#1081#1083#1072' '#1076#1083#1103' '#1087#1086#1080#1089#1082#1072' '#1074#1093#1086#1078#1076#1077#1085#1080#1081' '#1089#1090#1088#1086#1082#1080
      end
      object EdFilePath: TEdit
        Left = 3
        Top = 29
        Width = 555
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = 'd:\My_Projects\TestJob_For_MKOSystems\Test_ForSearch_Entries.bin'
      end
      object edSubStrForSearch: TEdit
        Left = 3
        Top = 79
        Width = 555
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        Text = 'abc'
        ExplicitWidth = 617
      end
      object BtnSearchEntries: TButton
        Left = 3
        Top = 110
        Width = 105
        Height = 24
        Anchors = [akLeft, akBottom]
        Caption = #1053#1072#1095#1072#1090#1100' '#1087#1086#1080#1089#1082
        TabOrder = 2
        OnClick = BtnSearchEntriesClick
        ExplicitTop = 146
      end
    end
    object TS2_ResultTask: TTabSheet
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103
      ImageIndex = 1
      DesignSize = (
        619
        142)
      object LblEntriesCount: TLabel
        Left = 192
        Top = 3
        Width = 84
        Height = 15
        Caption = 'LblEntriesCount'
      end
      object Label1: TLabel
        Left = 16
        Top = 3
        Width = 159
        Height = 15
        Caption = #1053#1072#1081#1076#1077#1085#1086' '#1074#1093#1086#1078#1076#1077#1085#1080#1081' '#1089#1090#1088#1086#1082#1080' :'
      end
      object LbResults: TListBox
        Left = 16
        Top = 24
        Width = 587
        Height = 108
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 15
        TabOrder = 0
        ExplicitWidth = 649
        ExplicitHeight = 137
      end
    end
  end
  object BtnClose: TButton
    Left = 486
    Top = 189
    Width = 105
    Height = 24
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 1
    OnClick = BtnCloseClick
    ExplicitLeft = 460
    ExplicitTop = 334
  end
  object TmrStartFillEntriesList: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TmrStartFillEntriesListTimer
    Left = 280
    Top = 152
  end
end
