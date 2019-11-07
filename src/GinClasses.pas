unit GinClasses;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}
{$H+}

interface

uses
	Generics.Collections, Classes, TCPTypes;

type
    TMsgCategory = (mcSystem, mcText, mcLobby, mcConnect, mcClient, mcServer, mcPlay);

	TBaseMessage = class(TBaseIdentMessage)
	public
		Category: TMsgCategory;
		Method: Byte;
		Params: TList<AnsiString>;

		constructor Create; override;
		destructor  Destroy; override;

		procedure ExtractParams; virtual;
		procedure DataFromParams;

		function  DataToString: AnsiString;

		function  Encode: TMsgData; override;
		procedure Decode(const AData: TMsgData); override;

		procedure Assign(AMessage: TBaseMessage);
	end;

//	TMessages = TThreadList<TMessage>;

	TNamedHost = class(TObject)
	public
		Name: AnsiString;
		Host: AnsiString;
		Version: AnsiString;
	end;

	TGameState = (gsWaiting, gsPreparing, gsPlaying, gsPaused, gsFinished);
	TPlayerState = (psNone, psIdle, psReady, psPreparing, psWaiting, psPlaying,
			psFinished, psWinner);


const
	VAL_KND_SCOREINVALID = High(Byte);

	ARR_LIT_NAM_CATEGORY: array[TMsgCategory] of string = (
			'system', 'text', 'lobby', 'connect', 'client', 'server', 'play');


//  I think that 2 should be 5 but this is using RFC messages as a template.

//		0	-	System
//		00	- 	Hang up
//		0E	-	Invalid category
//		0F	-	Invalid empty
//
//		1	-	Text
//		10	-	Information
//		11	-	Begin
//		12	-	More
//		13	-	Data
//		14	-	Peer
//
//		2	-	Lobby
//		20 	- 	Error
//		21	-	Join
//		22	-	Part
//		23	-	List
//		24	-	Peer
//
//		3	-	Connection
//		30	-	Error
//		31	-	Identify
//
//		4	-	Client
//		40	-	Error
//		41	-	Identify
//		52	-	KeepAlive
//
//		5	-	Server
//		50	-	Error
//		51	-	Identify
//		52	-	Challenge
//
//		6	-	Play
//		60 	- 	Error
//		61	-	Join
//		62	-	Part
//		63	-	List
//		64	-	TextPeer
//		65	-	KickPeer
//		66	-	StatusGame
//		67	-	StatusPeer
//		68	-	DrawCardPeer
//		69	-	DiscardCardPeer
//		6A	-	GinPeer
//		6B	-	GameEvent (0 = Dealt; 1 = Shuffled; 2 = NewFirst)
//		6C	-	BeginRoundPeer
//		6D	-	GameOptionsPeer


implementation

uses
	SysUtils;

{ TMessage }

procedure TBaseMessage.Assign(AMessage: TBaseMessage);
	var
	i: Integer;

	begin
	Category:= AMessage.Category;
	Method:= AMessage.Method;

	SetLength(Data, Length(AMessage.Data));
	Move(AMessage.Data[0], Data[0], Length(AMessage.Data));

	Params.Clear;
	for i:= 0 to AMessage.Params.Count - 1 do
		Params.Add(AMessage.Params[i]);
	end;

constructor TBaseMessage.Create;
	begin
	inherited Create;

	Params:= TList<AnsiString>.Create;
	end;

procedure TBaseMessage.DataFromParams;
	var
	s: AnsiString;
	i: Integer;

	begin
	s:= AnsiString('');
	for i:= 0 to Params.Count - 1 do
		begin
		s:= s + Params[i];
		if  i < (Params.Count - 1) then
			s:= s + AnsiString(' ');
		end;

	SetLength(Data, Length(s));
	for i:= Low(s) to High(s) do
		Data[i - Low(s)]:= Ord(s[i]);
	end;

function TBaseMessage.DataToString: AnsiString;
	var
	i: Integer;

	begin
	Result:= AnsiString('');
	for i:= 0 to High(Data) do
		Result:= Result + AnsiChar(Data[i]);
	end;

procedure TBaseMessage.Decode(const AData: TMsgData);
	var
	i: Integer;
	c: Byte;

	begin
	if  (Length(AData) > 0)
	and (Length(AData) = AData[0] + 1) then
		begin
		SetLength(Data, Length(AData) - 2);

		c:= AData[1] shr 4;
		if  c in [Ord(Low(TMsgCategory))..Ord(High(TMsgCategory))] then
			begin
			Category:= TMsgCategory(AData[1] shr 4);
			Method:= AData[1] and $0F;
			end
		else
			begin
			Category:= mcSystem;
			Method:= $0E;
			end;

		for i:= 2 to High(AData) do
			Data[i - 2]:= AData[i]
		end
	else
		begin
		SetLength(Data, 0);
		Category:= mcSystem;
		Method:= $0F;
		end;
	end;

destructor TBaseMessage.Destroy;
    var
    s: AnsiString;

    begin
    with Params do
        while Count > 0 do
            begin
            s:= Items[0];
            Delete(0);
            end;

	Params.Free;

	inherited;
	end;

function TBaseMessage.Encode: TMsgData;
	var
	i: Integer;
	c: Byte;

	begin
	SetLength(Result, 2 + Length(Data));

	Result[0]:= Length(Data) + 1;

	c:= (Ord(Category) shl 4) or (Method and $0F);
	Result[1]:= c;

	for i:= 0 to High(Data) do
		Result[2 + i]:= Data[i];
	end;

procedure TBaseMessage.ExtractParams;
	var
	i: Integer;
	s: AnsiString;

	begin
    with Params do
        while Count > 0 do
            begin
            s:= Items[0];
            Delete(0);
            s:= AnsiString('');
            end;

//	Params.Clear;

    s:= AnsiString('');
	for i:= 0 to High(Data) do
		if  Data[i] = $20 then
			begin
			Params.Add(s);
			s:= AnsiString('');
			end
		else
			s:= s + AnsiChar(Data[i]);

	if  Length(s) > 0 then
		Params.Add(s);
	end;

end.
