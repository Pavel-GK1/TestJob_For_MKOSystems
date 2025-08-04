object FmMain: TFmMain
  Left = 0
  Top = 0
  Caption = #1058#1077#1089#1090#1086#1074#1086#1077' '#1079#1072#1076#1072#1085#1080#1077
  ClientHeight = 238
  ClientWidth = 783
  Color = clBtnFace
  Constraints.MinHeight = 270
  Constraints.MinWidth = 700
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  DesignSize = (
    783
    238)
  TextHeight = 15
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 422
    Height = 15
    Caption = 
      #1057#1087#1080#1089#1086#1082' '#1079#1072#1076#1072#1095', '#1088#1072#1079#1084#1077#1097#1105#1085#1085#1099#1093' '#1074' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1085#1099#1093' '#1082' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1102' '#1073#1080#1073#1083#1080#1086#1090#1077#1082#1072 +
      #1093' :'
  end
  object BtnRunTask: TButton
    Left = 693
    Top = 40
    Width = 75
    Height = 22
    Anchors = [akTop, akRight]
    Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
    TabOrder = 0
    OnClick = BtnRunTaskClick
    ExplicitLeft = 648
  end
  object LvTasksList: TListView
    Left = 16
    Top = 40
    Width = 654
    Height = 150
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #1047#1072#1076#1072#1095#1072
        Width = 400
      end
      item
        Alignment = taCenter
        Caption = #1057#1090#1072#1090#1091#1089
        Width = 130
      end
      item
        Alignment = taCenter
        Caption = #1058#1077#1082'. '#1074#1088#1077#1084#1103
        Width = 130
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = LvTasksListDblClick
  end
  object BtnClose: TButton
    Left = 693
    Top = 205
    Width = 75
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 2
    OnClick = BtnCloseClick
    ExplicitLeft = 648
  end
end
