object ClientMainDMod: TClientMainDMod
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 281
  Width = 419
  object TimerMain: TTimer
    Interval = 100
    OnTimer = TimerMainTimer
    Left = 324
    Top = 5
  end
end
