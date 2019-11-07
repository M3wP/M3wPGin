program M3wPGinClient;

{$mode objfpc}{$H+}

uses
	{$IFDEF UNIX}{$IFDEF UseCThreads}
	cthreads,
	{$ENDIF}{$ENDIF}
	Interfaces, // this includes the LCL widgetset
	Forms, anchordockpkg, FormClientMain, DModClientMain, GinClient;

{$R *.res}

begin
	RequireDerivedFormResource:=True;
	Application.Initialize;
	Application.CreateForm(TClientMainForm, ClientMainForm);
	Application.CreateForm(TClientMainDMod, ClientMainDMod);
	Application.Run;
end.

