unit CardClasses;

{$MODE DELPHI}
{$H+}

interface

uses
	Classes, SysUtils, Graphics, CardTypes;

type
	TCardGraphics = array[TCardIndex] of TPortableNetworkGraphic;

var
  	CardGraphics: TCardGraphics;


function  InitialiseCardGraphics(const ASize: TCardImageSize = cisDefault;
		const ADeck: Char = 'a'): TPoint;
procedure FinaliseCardGraphics;


implementation

{$R deckA_small.RES}

uses
	LCLType;

function InitialiseCardGraphics(const ASize: TCardImageSize;
		const ADeck: Char): TPoint;
	var
	s: string;
    i: TCardIndex;
	r: TResourceStream;

	begin
    Assert(ASize in [cisDefault, cisSmall], 'Error determining card image size');
    Assert((ADeck = '') or (ADeck = 'a'), 'Error determining card image set');

    for i:= Low(TCardIndex) to High(TCardIndex) do
		begin
        s:= 'card_as_' + CardIndexToIdent(i);

		r:= TResourceStream.Create(HINSTANCE, s, RT_RCDATA);
		try
        	CardGraphics[i]:= TPortableNetworkGraphic.Create;
            CardGraphics[i].LoadFromStream(r);

			finally
            r.Free;
			end;
		end;

	Result:= Point(CardGraphics[0].Width, CardGraphics[0].Height);
	end;


procedure FinaliseCardGraphics;
	var
    i: TCardIndex;

	begin
    for i:= Low(TCardIndex) to High(TCardIndex) do
    	CardGraphics[i].Free;
	end;




end.

