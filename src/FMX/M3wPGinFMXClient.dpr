program M3wPGinFMXClient;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormClientMain in 'FormClientMain.pas' {ClientMainForm},
  DModClientMain in 'DModClientMain.pas' {ClientMainDMod: TDataModule},
  CardClasses in 'CardClasses.pas',
  CardTypes in 'CardTypes.pas',
  FrameCardHand in 'FrameCardHand.pas' {CardHandFrame: TFrame},
  GinClasses in 'GinClasses.pas',
  TCPTypes in 'TCPTypes.pas',
  GinClient in 'GinClient.pas',
  GinTypes in 'GinTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TClientMainDMod, ClientMainDMod);
  Application.CreateForm(TClientMainForm, ClientMainForm);
  Application.Run;
end.
