unit GinServer;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}

interface

uses
	SyncObjs, Generics.Collections, Classes, TCPTypes, TCPServer, GinClasses,
	CardTypes;

type

	{ TServerDispatcher }
	TServerDispatcher = class(TThread)
	protected
		procedure Execute; override;

	public
		ReadMessages: TIdentMessages;

		constructor Create;
		destructor  Destroy; override;
	end;

	TPlayer = class;
	TPlayersList = TThreadList<TPlayer>;

	TMessageTemplate = record
		Category: TMsgCategory;
		Method: Byte;
	end;

	TMessageList = class(TObject)
		Player: TPlayer;
		Name: AnsiString;
		Template: TMessageTemplate;
		Data: TQueue<AnsiString>;
		Process: Boolean;
		Complete: Boolean;
		Counter: Cardinal;

		constructor Create(APlayer: TPlayer);
		destructor  Destroy; override;

		procedure ProcessList;
		procedure Elapsed;
	end;

	TMessageLists = TThreadList<TMessageList>;

	TZone = class(TObject)
	protected
		FPlayers: TPlayersList;

		function  GetCount: Integer;
		function  GetPlayers(AIndex: Integer): TPlayer;

	public
		Desc: AnsiString;

		constructor Create; virtual;
		destructor  Destroy; override;

		class function  Name: AnsiString; virtual; abstract;

		procedure Remove(APlayer: TPlayer); virtual;
		procedure Add(APlayer: TPlayer); virtual;

		function  PlayerByIdent(const AIdent: TGUID): TPlayer;

		procedure ProcessPlayerMessage(APlayer: TPlayer; AMessage: TBaseMessage;
				var AHandled: Boolean); virtual; abstract;

		property PlayerCount: Integer read GetCount;
		property Players[AIndex: Integer]: TPlayer read GetPlayers; default;
	end;

	TSystemZone = class(TZone)
	public
		destructor  Destroy; override;

		class function  Name: AnsiString; override;

		procedure Remove(APlayer: TPlayer); override;
		procedure Add(APlayer: TPlayer); override;

		function  PlayerByName(AName: AnsiString): TPlayer;

		procedure ProcessPlayerMessage(APlayer: TPlayer; AMessage: TBaseMessage;
				var AHandled: Boolean); override;

		procedure PlayersKeepAliveDecrement(Ams: Integer);
		procedure PlayersKeepAliveExpire;
	end;

	TLimboZone = class(TZone)
	public
		class function  Name: AnsiString; override;

		procedure Remove(APlayer: TPlayer); override;
		procedure Add(APlayer: TPlayer); override;

		procedure BumpCounter;
		procedure ExpirePlayers;

		procedure ProcessPlayerMessage(APlayer: TPlayer; AMessage: TBaseMessage;
				var AHandled: Boolean); override;
	end;

	TLobbyZone = class;

	TLobbyRoom = class(TZone)
	public
		Lobby: TLobbyZone;
		Password: AnsiString;

		destructor  Destroy; override;

		class function  Name: AnsiString; override;

		procedure Remove(APlayer: TPlayer); override;
		procedure Add(APlayer: TPlayer); override;

		procedure ProcessPlayerMessage(APlayer: TPlayer; AMessage: TBaseMessage;
				var AHandled: Boolean); override;
	end;

	TLobbyRooms = TThreadList<TLobbyRoom>;

	TLobbyZone = class(TZone)
	private
		FRooms: TLobbyRooms;

	public
		constructor Create; override;
		destructor  Destroy; override;

		class function  Name: AnsiString; override;

		function  RoomByName(ADesc: AnsiString): TLobbyRoom;

		procedure RemoveRoom(ADesc: AnsiString);
		function  AddRoom(ADesc, APassword: AnsiString): TLobbyRoom;

		procedure Remove(APlayer: TPlayer); override;
		procedure Add(APlayer: TPlayer); override;

		procedure ProcessPlayerMessage(APlayer: TPlayer; AMessage: TBaseMessage;
				var AHandled: Boolean); override;
	end;

	TPlayZone = class;

	TPlaySlot = record
		Player: TPlayer;
		Name: AnsiString;
		State: TPlayerState;
		Score: Byte;
//		First: Boolean;
		FirstCard: TCardIndex;
		Cards: array[0..10] of TCardIndex;
		Drawn: Boolean;
	end;

	{ TPlayGame }

 	TPlayGame = class(TZone)
	public
		Play: TPlayZone;
		Password: AnsiString;
		Lock: TCriticalSection;
		State: TGameState;
		Round: Byte;
		LastRound: Byte;
        First,
        Turn: Integer;
		Slots: array[0..3] of TPlaySlot;
		SlotCount: Integer;
		ReadyCount: Integer;
		Deck: TStandardDeck;
		Index: TCardIndex;
		LastDiscard: TCardIndex;

		constructor Create; override;
		destructor  Destroy; override;

		class function  Name: AnsiString; override;

		procedure Remove(APlayer: TPlayer); override;
		procedure Add(APlayer: TPlayer); override;

		procedure ProcessPlayerMessage(APlayer: TPlayer; AMessage: TBaseMessage;
				var AHandled: Boolean); override;

		procedure SendGameStatus(APlayer: TPlayer);
		procedure SendSlotStatus(APlayer: TPlayer; ASlot: Integer);
        procedure SendLastDiscard(APlayer: TPlayer; ASlot: Integer);

		procedure NopPlayerCards;
		procedure AddPlayerCard(const APlayer: Integer; const ACard: TCardIndex);
		function  RemovePlayerCard(const APlayer: Integer;
				const ACard: TCardIndex): Boolean;
		procedure DealToPlayers;
        procedure ReshuffleDeck;

        function  CheckForGin(const ASlot: Integer): Boolean;
        procedure HandleGin(const ASlot: Integer);
	end;

	TPlayGames = TThreadList<TPlayGame>;

	TPlayZone = class(TZone)
	private
		FGames: TPlayGames;

	public
		constructor Create; override;
		destructor  Destroy; override;

		class function  Name: AnsiString; override;

		function  GameByName(ADesc: AnsiString): TPlayGame;

		procedure RemoveGame(ADesc: AnsiString);
		function  AddGame(ADesc, APassword: AnsiString): TPlayGame;

		procedure Remove(APlayer: TPlayer); override;
		procedure Add(APlayer: TPlayer); override;

		procedure ProcessPlayerMessage(APlayer: TPlayer; AMessage: TBaseMessage;
				var AHandled: Boolean); override;
	end;

	TZoneClass = class of TZone;

	TZones = TThreadList<TZone>;

	TExpireZones = TThreadList<TZone>;
    TExpirePlayers = TThreadList<TPlayer>;

	{ TPlayer }

    TPlayer = class(TObject)
	public
		Ident: TGUID;
		Ticket: string;
//		Connection: TTCPConnection;

		Zones: TZones;

        Lock: TCriticalSection;
		Name: AnsiString;
		Client: TNamedHost;

		Counter: Integer;
		KeepAliveCntr: Integer;
		NeedKeepAlive: Integer;
		SendKeepAlive: Boolean;

//		Messages: TMessages;

		InputBuffer: TMsgData;

		constructor Create(AIdent: TGUID);
		destructor  Destroy; override;

		procedure AddZone(AZone: TZone);
		procedure RemoveZone(AZone: TZone);
		procedure RemoveZoneByClass(AZoneClass: TZoneClass);
		procedure ClearZones;

		function  FindZoneByClass(AZoneClass: TZoneClass): TZone;
		function  FindZoneByNameDesc(AName, ADesc: AnsiString): TZone;

		procedure SendServerError(AMessage: AnsiString);

		procedure AddSendMessage(var AMessage: TBaseMessage);

		procedure KeepAliveReset;
		procedure KeepAliveDecrement(Ams: Integer);
	end;

var
	SystemZone: TSystemZone;
	LimboZone: TLimboZone;
	LobbyZone: TLobbyZone;
	PlayZone: TPlayZone;

	ServerDisp: TServerDispatcher;

	ListMessages: TMessageLists;

	ExpireZones: TExpireZones;
    ExpirePlayers: TExpirePlayers;


const
	LIT_SYS_VERNAME: AnsiString = 'alpha';
{$IFDEF ANDROID}
	LIT_SYS_PLATFRM: AnsiString = 'android';
{$ELSE}
	{$IFDEF UNIX}
		{$IFDEF LINUX}
   	LIT_SYS_PLATFRM: AnsiString = 'linux';
		{$ELSE}
   	LIT_SYS_PLATFRM: AnsiString = 'unix';
		{$ENDIF}
	{$ELSE}
	LIT_SYS_PLATFRM: AnsiString = 'mswindows';
	{$ENDIF}
{$ENDIF}
	LIT_SYS_VERSION: AnsiString = '0.00.01A';


implementation

uses
	SysUtils;

const
	ARR_LIT_SYS_INFO: array[0..4] of AnsiString = (
			'Gin development system',
			'--------------------------',
			'Early alpha stage',
			'By Daniel England',
			'For Ecclestial Solutions');

	LIT_ERR_CLIENTID: AnsiString = 'Invalid client ident';
	LIT_ERR_CONNCTID: AnsiString = 'Invalid connect ident';
	LIT_ERR_SERVERUN: AnsiString = 'Unrecognised command';
	LIT_ERR_LBBYJINV: AnsiString = 'Invalid lobby join';
	LIT_ERR_LBBYPINV: AnsiString = 'Invalid lobby part';
	LIT_ERR_LBBYLINV: AnsiString = 'Invalid lobby list';
	LIT_ERR_TEXTPINV: AnsiString = 'Invalid text peer';
	LIT_ERR_PLAYJINV: AnsiString = 'Invalid play join';
	LIT_ERR_PLAYPINV: AnsiString = 'Invalid play part';
	LIT_ERR_PLAYLINV: AnsiString = 'Invalid play list';
	LIT_ERR_PLAYPWDR: AnsiString = 'Play password mismatch';
	LIT_ERR_PLAYGMST: AnsiString = 'Play in progress or full';
	LIT_ERR_PLAYNODR: AnsiString = 'Play draw complete';


procedure DoDestroyListMessages;
	var
	i: Integer;

	begin
	with ListMessages.LockList do
		try
		for i:= Count - 1 downto 0 do
			Items[i].Free;

        Clear;

		finally
		ListMessages.UnlockList;
		end;

	ListMessages.Free;
	end;


{ TZone }

procedure TZone.Add(APlayer: TPlayer);
	begin
	FPlayers.Add(APlayer);
	APlayer.Zones.Add(Self);

	AddLogMessage(slkInfo, '"' + APlayer.Ticket + '" added to zone ' +
            Name + ' (' + Desc + ').');
	end;

constructor TZone.Create;
	begin
	inherited Create;

	FPlayers:= TPlayersList.Create;
	end;

destructor TZone.Destroy;
	var
	i: Integer;

	begin
	AddLogMessage(slkInfo, 'Destroying zone ' + Name + ' (' + Desc + ')');

	with FPlayers.LockList do
		try
		for i:= Count - 1 downto 0 do
			Remove(Items[i]);

		finally
		FPlayers.UnlockList;
		end;

	FPlayers.Free;

	inherited;
	end;

function TZone.GetCount: Integer;
	begin
	with FPlayers.LockList do
		try
		Result:= Count;

		finally
		FPlayers.UnlockList;
		end;
	end;

function TZone.GetPlayers(AIndex: Integer): TPlayer;
	begin
	with FPlayers.LockList do
		try
		Result:= Items[AIndex];

		finally
		FPlayers.UnlockList;
		end;
	end;

function TZone.PlayerByIdent(const AIdent: TGUID): TPlayer;
	var
	i: Integer;

	begin
	Result:= nil;

	with FPlayers.LockList do
		try
		for i:= 0 to Count - 1 do
			if  CompareMem(@Items[i].Ident, @AIdent, SizeOf(TGUID)) then
				begin
				Result:= Items[i];
				Exit;
				end;

		finally
		FPlayers.UnlockList;
		end;

	end;

procedure TZone.Remove(APlayer: TPlayer);
	begin
	FPlayers.Remove(APlayer);
	APlayer.Zones.Remove(Self);

	AddLogMessage(slkInfo, '"' + APlayer.Ticket + '" removed from zone ' +
            Name + '(' + Desc + ').');
	end;

{ TSystemZone }

procedure TSystemZone.Add(APlayer: TPlayer);
	begin
	inherited;

	LimboZone.Add(APlayer);
	end;

destructor TSystemZone.Destroy;
	begin

	inherited;
	end;

class function TSystemZone.Name: AnsiString;
	begin
	Result:= 'system';
	end;

function TSystemZone.PlayerByName(AName: AnsiString): TPlayer;
	var
	i: Integer;

	begin
	Result:= nil;

	with FPlayers.LockList do
		try
		for i:= 0 to Count - 1 do
			if  CompareText(string(Items[i].Name), string(AName)) = 0 then
				begin
				Result:= Items[i];
				Exit;
				end;

		finally
		FPlayers.UnlockList;
		end;
	end;

procedure TSystemZone.PlayersKeepAliveDecrement(Ams: Integer);
	var
	i: Integer;

	begin
	with FPlayers.LockList do
		try
		for i:= 0 to Count - 1 do
			if  not Assigned(LimboZone.PlayerByIdent(Items[i].Ident)) then
				Items[i].KeepAliveDecrement(Ams);

		finally
		FPlayers.UnlockList;
		end;
	end;

procedure TSystemZone.PlayersKeepAliveExpire;
	var
	i: Integer;

	begin
	with FPlayers.LockList do
		try
		for i:= Count - 1 downto 0 do
			if  Items[i].NeedKeepAlive <= 0 then
				Self.Remove(Items[i]);

		finally
		FPlayers.UnlockList;
		end;
	end;

procedure TSystemZone.ProcessPlayerMessage(APlayer: TPlayer;
        AMessage: TBaseMessage; var AHandled: Boolean);
	var
	i: Integer;
	a: TPlayer;
	m: TBaseMessage;
	n: AnsiString;
	ml: TMessageList;

	begin
	if  (AMessage.Category = mcText)
	and (AMessage.Method = 0) then
		begin
		ml:= TMessageList.Create(APlayer);

		for i:= 0 to High(ARR_LIT_SYS_INFO) do
			ml.Data.Enqueue(ARR_LIT_SYS_INFO[i]);

		m:= TBaseMessage.Create;
		m.Category:= mcText;
		m.Method:= $01;
		m.Params.Add(ml.Name);
		m.Params.Add(AnsiString(ARR_LIT_NAM_CATEGORY[mcSystem]));
		m.DataFromParams;

		APlayer.AddSendMessage(m);

		ListMessages.Add(ml);

		AHandled:= True;
		end
	else if (AMessage.Category = mcSystem) then
		begin
		TCPServer.TCPServer.DisconnectByIdent(APlayer.Ident);

		AHandled:= True;
		end
	else if  (AMessage.Category = mcText)
	and (AMessage.Method = $02) then
		begin
		AHandled:= True;
		AMessage.ExtractParams;

		if  AMessage.Params.Count > 0 then
			begin
			n:= Copy(AMessage.Params[0], 1, 8);

			with ListMessages.LockList do
				try
				for i:= 0 to Count - 1 do
					begin
					ml:= Items[i];

					if  CompareText(string(ml.Name), string(n)) = 0 then
						begin
						if  not ml.Complete then
							ml.Process:= True;

						Break;
						end;
					end;

				finally
				ListMessages.UnlockList;
				end;
			end;
		end
	else if  (AMessage.Category = mcText)
	and (AMessage.Method = $04) then
		begin
		AMessage.ExtractParams;

		if  AMessage.Params.Count > 0 then
			begin
			n:= Copy(AMessage.Params[0], 1, 8);
			a:= PlayerByName(n);

			if  Assigned(a) then
				begin
				m:= TBaseMessage.Create;
				m.Assign(AMessage);
				m.Params[0]:= APlayer.Name;
				m.DataFromParams;

				a.AddSendMessage(m);
				end;
			end
		else
			APlayer.SendServerError(LIT_ERR_TEXTPINV);

		AHandled:= True;
		end
	else if (AMessage.Category = mcConnect)
	and (AMessage.Method = 1) then
		begin
		AMessage.ExtractParams;
		if  (AMessage.Params.Count = 1)
		and (Length(AMessage.Params[0]) > 1) then
			begin
			n:= Copy(AMessage.Params[0], 1, 8);

			with FPlayers.LockList do
				try
					a:= PlayerByName(n);

					if  not Assigned(a) then
						begin
						m:= TBaseMessage.Create;
						m.Assign(AMessage);
						m.Params.Add(APlayer.Name);
						m.DataFromParams;

						APlayer.AddSendMessage(m);

						APlayer.Name:= n;
						end
					else
						APlayer.SendServerError(LIT_ERR_CONNCTID);
				finally
                FPlayers.UnlockList;
				end;
			end
		else
			APlayer.SendServerError(LIT_ERR_CONNCTID);

		AHandled:= True;
		end
	else if (AMessage.Category = mcClient)
	and (AMessage.Method = 2) then
		begin
		APlayer.KeepAliveReset;
		AHandled:= True;
		end;
	end;

procedure TSystemZone.Remove(APlayer: TPlayer);
	begin
	inherited;

	APlayer.ClearZones;

	ExpirePlayers.Add(APlayer);
	end;

{ TLimboZone }

procedure TLimboZone.Add(APlayer: TPlayer);
	begin
	inherited;

	APlayer.Counter:= 0;
	end;

procedure TLimboZone.BumpCounter;
	var
	i: Integer;
	p: TPlayer;

	begin
	with FPlayers.LockList do
		try
		for i:= 0 to Count - 1 do
			begin
			p:= Items[i];
            p.Lock.Acquire;
            try
			    p.Counter:= p.Counter + 1;

                if  p.Counter mod 100 = 0 then
				    AddLogMessage(slkInfo, '"' + p.Ticket +
							'" bumping auth wait count: ' + IntToStr(p.Counter));

                finally
                p.Lock.Release;
                end;
            end;

		finally
		FPlayers.UnlockList;
		end;
	end;

procedure TLimboZone.ExpirePlayers;
	var
	i: Integer;
	p: TPlayer;

	begin
	with FPlayers.LockList do
		try
		for i:= Count - 1 downto 0 do
			begin
			p:= Items[i];

            p.Lock.Acquire;
            try
			    if  Assigned(p.Client)
			    and (Length(p.Name) > 0) then
				    begin
				    AddLogMessage(slkInfo, '"' + p.Ticket +
							'" authenticated, move to lobby/play.');

                    LimboZone.Remove(p);

				    LobbyZone.Add(p);
				    PlayZone.Add(p);
				    end
			    else if p.Counter >= 600 then
				    begin
                    AddLogMessage(slkInfo, '"' + p.Ticket + '" auth failure.');

                    SystemZone.Remove(p);
				    end;

                finally
                p.Lock.Release;
                end;
            end;

		finally
		FPlayers.UnlockList;
		end;
	end;

class function TLimboZone.Name: AnsiString;
	begin
	Result:= 'limbo';
	end;

procedure TLimboZone.ProcessPlayerMessage(APlayer: TPlayer;
        AMessage: TBaseMessage; var AHandled: Boolean);
	var
	c: TNamedHost;

	begin
	if  (AMessage.Category = mcClient)
	and (AMessage.Method = 1) then
		begin
        APlayer.Lock.Acquire;
        try
		if not Assigned(APlayer.Client) then
			begin
			AMessage.ExtractParams;

			if  AMessage.Params.Count = 3 then
				begin
				c:= TNamedHost.Create;

				c.Name:= AMessage.Params[0];
				c.Host:= AMessage.Params[1];
				c.Version:= AMessage.Params[2];

				APlayer.Client:= c;
				end
			else
				APlayer.SendServerError(LIT_ERR_CLIENTID);
			end
		else
			APlayer.SendServerError(LIT_ERR_CLIENTID);


        finally
        APlayer.Lock.Release;
        end;

        AHandled:= True;
		end;
	end;

procedure TLimboZone.Remove(APlayer: TPlayer);
	begin
	inherited;

	end;

{ TLobbyRoom }

procedure TLobbyRoom.Add(APlayer: TPlayer);
	var
	i: Integer;

	procedure JoinMessageFromPeer(APeer: TPlayer; AName: AnsiString);
		var
		m: TBaseMessage;

		begin
		m:= TBaseMessage.Create;

		m.Category:= mcLobby;
		m.Method:= $01;

		m.Params.Add(Desc);
		m.Params.Add(AName);

		m.DataFromParams;

        APeer.AddSendMessage(m);
		end;

	begin
	inherited;

	with FPlayers.LockList do
		try
		for i:= 0 to Count - 1 do
			JoinMessageFromPeer(Items[i], APlayer.Name);

		finally
		FPlayers.UnlockList;
		end;
	end;

destructor TLobbyRoom.Destroy;
	begin
//	FDisposing:= True;

	if  Assigned(Lobby) then
		Lobby.RemoveRoom(Desc);

	inherited;
	end;

class function TLobbyRoom.Name: AnsiString;
	begin
	Result:= 'room';
	end;

procedure TLobbyRoom.ProcessPlayerMessage(APlayer: TPlayer;
        AMessage: TBaseMessage; var AHandled: Boolean);
	var
	i: Integer;

	procedure PeerMessageFromPlayer(APeer: TPlayer; AMessage: TBaseMessage);
		var
		m: TBaseMessage;

		begin
		m:= TBaseMessage.Create;

		m.Assign(AMessage);

		m.Category:= mcLobby;
		m.Method:= $04;

        APeer.AddSendMessage(m);
		end;

	begin
	if  AMessage.Category = mcLobby then
		if  AMessage.Method = 4 then
			begin
			AMessage.ExtractParams;
			if  (AMessage.Params.Count > 2)
			and (CompareText(string(Desc), string(AMessage.Params[0])) = 0) then
				begin
				AMessage.Params[1]:= Copy(AMessage.Params[1], Low(AnsiString), 8);

				AMessage.DataFromParams;

				with FPlayers.LockList do
					try
					for i:= 0 to Count - 1 do
						PeerMessageFromPlayer(Items[i], AMessage);

					finally
					FPlayers.UnlockList;
					end;

				AHandled:= True;
				end;
		end;
	end;

procedure TLobbyRoom.Remove(APlayer: TPlayer);
	var
	i: Integer;

	procedure PartMessageFromPeer(APeer: TPlayer; AName: AnsiString);
		var
		m: TBaseMessage;

		begin
		m:= TBaseMessage.Create;
		m.Category:= mcLobby;
		m.Method:= $02;

		m.Params.Add(Desc);
		m.Params.Add(AName);

		m.DataFromParams;

        APeer.AddSendMessage(m);
		end;

	begin
	with FPlayers.LockList do
		try
		for i:= 0 to Count - 1 do
			PartMessageFromPeer(Items[i], APlayer.Name);

		finally
		FPlayers.UnlockList;
		end;

	inherited;

	if  PlayerCount = 0 then
		ExpireZones.Add(Self);
	end;

{ TPlayer }

procedure TPlayer.AddZone(AZone: TZone);
	begin
	Zones.Add(AZone);
	end;

procedure TPlayer.ClearZones;
	var
	i: Integer;
	z: TZone;

	begin
	with Zones.LockList do
		try
		for i:= Count - 1 downto 0 do
			begin
			z:= Items[i];
			z.Remove(Self);
			end;
		finally
		Zones.UnlockList;
		end;
	end;

constructor TPlayer.Create(AIdent: TGUID);
	begin
	inherited Create;

    Lock:= TCriticalSection.Create;

	Zones:= TZones.Create;
	Zones.Duplicates:= dupError;

	Ident:= AIdent;

	Name:= '';
	Client:= nil;

	KeepAliveReset;
	end;

destructor TPlayer.Destroy;
	begin
    Lock.Acquire;
    try
        if  Assigned(Client) then
            Client.Free;

        finally
        Lock.Release;
        end;

    Zones.Free;

    Lock.Free;

	inherited;
	end;

function TPlayer.FindZoneByClass(AZoneClass: TZoneClass): TZone;
	var
	i: Integer;

	begin
	Result:= nil;

	with Zones.LockList do
		try
		for i:= 0 to Count - 1 do
			if  Items[i] is AZoneClass then
				begin
				Result:= Items[i];
				Exit;
				end;
		finally
		Zones.UnlockList;
		end;
	end;

function TPlayer.FindZoneByNameDesc(AName, ADesc: AnsiString): TZone;
	var
	i: Integer;

	begin
	Result:= nil;

	with Zones.LockList do
		try
		for i:= 0 to Count - 1 do
			if  (CompareText(string(Items[i].Name), string(AName)) = 0)
			and (CompareText(string(Items[i].Desc), string(ADesc)) = 0) then
				begin
				Result:= Items[i];
				Exit;
				end;
		finally
		Zones.UnlockList;
		end;
	end;

procedure TPlayer.KeepAliveDecrement(Ams: Integer);
	var
	m: TBaseMessage;

	begin
	if  KeepAliveCntr > 0 then
		Dec(KeepAliveCntr, Ams)
	else
		begin
		if  SendKeepAlive then
			begin
			SendKeepAlive:= False;

			m:= TBaseMessage.Create;

			m.Category:= mcServer;
			m.Method:= 2;

			AddSendMessage(m);
			end;

		Dec(NeedKeepAlive, Ams);
		end;
	end;

procedure TPlayer.KeepAliveReset;
	begin
	KeepAliveCntr:= 10000;
	NeedKeepAlive:= 5000;
	SendKeepAlive:= True;
	end;

procedure TPlayer.RemoveZone(AZone: TZone);
	begin
	AZone.Remove(Self);
	end;

procedure TPlayer.RemoveZoneByClass(AZoneClass: TZoneClass);
	var
	z: TZone;

	begin
	repeat
		z:= FindZoneByClass(AZoneClass);
		if  Assigned(z) then
			z.Remove(Self);

		until not Assigned(z);
	end;

procedure TPlayer.SendServerError(AMessage: AnsiString);
	var
	m: TBaseMessage;

	begin
	m:= TBaseMessage.Create;

	m.Category:= mcServer;
	m.Method:= 0;
	m.Params.Add(AMessage);
	m.DataFromParams;

	AddSendMessage(m);
	end;

procedure TPlayer.AddSendMessage(var AMessage: TBaseMessage);
	begin
    AMessage.Ident:= Ident;
	TCPServer.TCPServer.AddSendMessage(Ident, AMessage);
	end;

{ TLobbyZone }

procedure TLobbyZone.Add(APlayer: TPlayer);
	begin
	inherited;

	end;

function TLobbyZone.AddRoom(ADesc, APassword: AnsiString): TLobbyRoom;
	begin
	with  FRooms.LockList do
		try
			Result:= RoomByName(ADesc);
			if  not Assigned(Result) then
				begin
				Result:= TLobbyRoom.Create;

				Result.Desc:= ADesc;
				Result.Lobby:= Self;
				Result.Password:= APassword;

				FRooms.Add(Result);
				end;

			finally
            FRooms.UnlockList;
			end;
	end;

constructor TLobbyZone.Create;
	begin
	inherited;

	FRooms:= TLobbyRooms.Create;
	end;

destructor TLobbyZone.Destroy;
	var
	i: Integer;

	begin
	with FRooms.LockList do
		try
		for i:= Count - 1 downto 0 do
			begin
			Items[i].Lobby:= nil;
			Items[i].Free;
			end;

		finally
		FRooms.UnlockList;
		end;

	FRooms.Free;

	inherited;
	end;

class function TLobbyZone.Name: AnsiString;
	begin
	Result:= 'lobby';
	end;

procedure TLobbyZone.ProcessPlayerMessage(APlayer: TPlayer;
        AMessage: TBaseMessage; var AHandled: Boolean);
	var
	r: TLobbyRoom;
	s: AnsiString;
	m: TBaseMessage;
	ml: TMessageList;
	i: Integer;
	p: AnsiString;

	begin
	if  AMessage.Category = mcLobby then
		if  AMessage.Method = 1 then
			begin
			AMessage.ExtractParams;

			if  (AMessage.Params.Count > 0)
			and (AMessage.Params.Count < 3) then
				begin
				s:= Copy(AMessage.Params[0], Low(AnsiString), 8);
				r:= RoomByName(AMessage.Params[0]);

				if  AMessage.Params.Count = 2 then
					p:= AMessage.Params[1]
				else
					p:= '';

				if  not Assigned(r) then
					r:= AddRoom(s, p);

				if  CompareText(string(p), string(r.Password)) = 0 then
					with APlayer.Zones.LockList do
						try
						if  not Contains(r) then
							r.Add(APlayer);

						finally
						APlayer.Zones.UnlockList;
						end
				else
					begin
					m:= TBaseMessage.Create;
					m.Category:= mcLobby;
					m.Method:= $00;

					APlayer.AddSendMessage(m);
					end;
				end
			else
				APlayer.SendServerError(LIT_ERR_LBBYJINV);

			AHandled:= True;
			end
		else if AMessage.Method = 2 then
			begin
			AMessage.ExtractParams;

			r:= RoomByName(AMessage.Params[0]);

			if  Assigned(r) then
				r.Remove(APlayer)
			else
				APlayer.SendServerError(LIT_ERR_LBBYPINV);

			AHandled:= True;
			end
		else if AMessage.Method = $03 then
			begin
			AHandled:= True;

			AMessage.ExtractParams;

			r:= nil;

			if  AMessage.Params.Count > 0 then
				begin
				r:= RoomByName(AMessage.Params[0]);
				if  not Assigned(r) then
					begin
					APlayer.SendServerError(LIT_ERR_LBBYLINV);
					Exit;
					end;
				end;

			ml:= TMessageList.Create(APlayer);

			if  AMessage.Params.Count > 0 then
				with r.FPlayers.LockList do
					try
					if  (Length(r.Password) = 0)
					or  Contains(APlayer) then
						for i:= 0 to Count - 1 do
							ml.Data.Enqueue(Items[i].Name);

					finally
					r.FPlayers.UnlockList;
					end
			else
				with FRooms.LockList do
					try
					for i:= 0 to Count - 1 do
						if  Length(Items[i].Password) = 0 then
							ml.Data.Enqueue(Items[i].Desc);

					finally
					FRooms.UnlockList;
					end;

			m:= TBaseMessage.Create;
			m.Category:= mcText;
			m.Method:= $01;
			m.Params.Add(ml.Name);
			m.Params.Add(AnsiString(ARR_LIT_NAM_CATEGORY[mcLobby]));

			if  AMessage.Params.Count > 0 then
				m.Params.Add(r.Desc);

			m.DataFromParams;

			APlayer.AddSendMessage(m);

			ListMessages.Add(ml);
			end
	end;

procedure TLobbyZone.Remove(APlayer: TPlayer);
	begin
	inherited;

	APlayer.RemoveZoneByClass(TLobbyRoom);
	end;

procedure TLobbyZone.RemoveRoom(ADesc: AnsiString);
	var
	r: TLobbyRoom;

	begin
	r:= RoomByName(ADesc);
	if  Assigned(r) then
		FRooms.Remove(r);
	end;

function TLobbyZone.RoomByName(ADesc: AnsiString): TLobbyRoom;
	var
	i: Integer;

	begin
	Result:= nil;
	with FRooms.LockList do
		try
		for i:= 0 to Count - 1 do
			if  CompareText(string(Items[i].Desc), string(ADesc)) = 0 then
				begin
				Result:= Items[i];
				Exit;
				end;
		finally
		FRooms.UnlockList;
		end;
	end;


{ TServerDispatcher }

procedure TServerDispatcher.Execute;
	var
//	cm: TConnectMessage;
	im: TBaseIdentMessage;
	p: TPlayer;
	handled: Boolean;
	z: TZone;
	i: Integer;

	begin
	while not Terminated do
		try
		Sleep(100);

		im:= nil;
		try
			with ReadMessages.LockList do
				try
				if  Count > 0 then
					begin
					im:= Items[0];
					Delete(0);
					end;
				finally
				ReadMessages.UnlockList;
				end;

			except
			AddLogMessage(slkError, 'Dispatcher cannot read messages!');
			end;

		if  Assigned(im) then
			try
				p:= SystemZone.PlayerByIdent(im.Ident);

                if  not Assigned(p) then
					Continue;

				try
					handled:= False;
					z:= nil;

					with p.Zones.LockList do
						try
						for i:= 0 to Count - 1 do
							begin
							z:= Items[i];

							z.ProcessPlayerMessage(p, TBaseMessage(im), handled);
							if  handled then
								Break;

							z:= nil;
							end;

						finally
						p.Zones.UnlockList;
						end;

					if  handled then
						begin
						p.KeepAliveReset;
						AddLogMessage(slkDebug, '"' + p.Ticket +
								'" handled in ' + z.Name + ' zone.');
						end
					else
						begin
						p.SendServerError(LIT_ERR_SERVERUN);

						AddLogMessage(slkDebug, '"' + p.Ticket +
								'" unhandled message.');
						end;

					except
					AddLogMessage(slkError, '"' + p.Ticket +
								'" error processing player message!');
					end;

				finally
				im.Free;
				end;
        except
		AddLogMessage(slkError, 'Unknown dispatcher error!');
		end;
	end;

constructor TServerDispatcher.Create;
	begin
	ReadMessages:= TIdentMessages.Create;

	inherited Create(False);
	end;

destructor TServerDispatcher.Destroy;
	begin
    with ReadMessages.LockList do
		try
        	while Count > 0 do
				begin
				Items[Count - 1].Free;
				Delete(Count - 1);
				end;

			finally
            ReadMessages.UnlockList;
			end;

    ReadMessages.Free;

	inherited Destroy;
	end;

{ TMessageList }

constructor TMessageList.Create(APlayer: TPlayer);
	var
	s: AnsiString;
	i,
	u,
	p: Integer;
	f: Boolean;

	begin
	inherited Create;

	Player:= APlayer;

	s:= APlayer.Name;
	p:= Length(s) + 1;
	if  p > 8 then
		p:= 8;

	if  Length(s) < p then
		SetLength(s, p);

	Dec(p);

	u:= 0;
	repeat
		s[p + Low(AnsiString)]:= AnsiChar(u + Ord(AnsiChar('0')));

		f:= False;
		with ListMessages.LockList do
			try
			for i:= 0 to Count - 1 do
				if  CompareText(string(Items[i].Name), string(s)) = 0 then
					begin
					f:= True;
					Break;
					end;
			finally
			ListMessages.UnlockList;
			end;

		if  not f then
			begin
			Name:= s;
			end
		else
			Inc(u);

		until (not f) or (u > 9);

	if  u > 9 then
        begin
		AddLogMessage(slkInfo, '"' + APlayer.Ticket +
				'" out of room for new Message List!');
        Exit;
        end;

	Data:= TQueue<AnsiString>.Create;

	Template.Category:= mcText;
	Template.Method:= $03;

	Process:= True;
	Complete:= False;
	end;

destructor TMessageList.Destroy;
	begin
	Data.Free;

	inherited;
	end;

procedure TMessageList.Elapsed;
	begin
	Inc(Counter);

	if  Counter >= 6000 then
		Complete:= True;
	end;

procedure TMessageList.ProcessList;
	var
	c: Integer;
	m: TBaseMessage;

	begin
	c:= 0;
	while (Data.Count > 0) and (c < 15) do
		begin
		m:= TBaseMessage.Create;

		m.Category:= Template.Category;
		m.Method:= Template.Method;

		m.Params.Add(Name);
		m.Params.Add(Data.Dequeue);

		m.DataFromParams;

        Player.AddSendMessage(m);

		Inc(c);
		end;

	m:= TBaseMessage.Create;

	m.Category:= mcText;
	m.Method:= $02;

	m.Params.Add(Name);
	m.Params.Add(AnsiString(IntToStr(Data.Count)));

	m.DataFromParams;

	Player.AddSendMessage(m);

	Process:= False;
	Complete:= Data.Count = 0;
    Counter:= 0;
	end;

{ TPlayGame }

procedure TPlayGame.Add(APlayer: TPlayer);
	var
	i: Integer;
	s: Integer;
//	m: TMessage;

	procedure JoinMessageFromPeer(APeer: TPlayer; AName: AnsiString; ASlot: Integer);
		var
		m: TBaseMessage;

		begin
		m:= TBaseMessage.Create;

		m.Category:= mcPlay;
		m.Method:= $01;

		m.Params.Add(Desc);
		m.Params.Add(AName);
		m.Params.Add(AnsiChar(ASlot + $30));
//		m.Params.Add(AnsiChar(Ord(State)));

		m.DataFromParams;

		APeer.AddSendMessage(m);
		end;

	begin
	Lock.Acquire;
		try
		if  SlotCount < Length(Slots) then
			begin
			Inc(SlotCount);

			inherited;

			s:= -1;
			for i:= 0 to High(Slots) do
				if  not Assigned(Slots[i].Player) then
					begin
					s:= i;

					FillChar(Slots[i], SizeOf(TPlaySlot), 0);

					Slots[i].Player:= APlayer;
					Slots[i].Name:= APlayer.Name;

					Slots[i].State:= psIdle;

					Break;
					end;

			Assert(s > -1, 'Failure in Play Game Add Player');

			for i:= 0 to High(Slots) do
				if  Assigned(Slots[i].Player) then
					JoinMessageFromPeer(Slots[i].Player, APlayer.Name, s);


			SendGameStatus(APlayer);
			end;

		finally
		Lock.Release;
		end;
	end;

constructor TPlayGame.Create;
	begin
	inherited;

	Lock:= TCriticalSection.Create;

	LastRound:= 5;

	ShuffleStandardDeck(Deck);
    Index:= Low(TPlayingCard);
	end;

destructor TPlayGame.Destroy;
	begin
	if  Assigned(Play) then
		Play.RemoveGame(Desc);

	Lock.Free;

	inherited;
	end;

class function TPlayGame.Name: AnsiString;
	begin
	Result:= 'game';
	end;

procedure TPlayGame.ProcessPlayerMessage(APlayer: TPlayer;
        AMessage: TBaseMessage; var AHandled: Boolean);
	var
	s,
	i,
	j: Integer;
	p: TPlayerState;
	m: TBaseMessage;
	f: Boolean;
	c: TCardIndex;

	procedure PeerMessageFromPlayer(APeer: TPlayer; AMessage: TBaseMessage);
		var
		m: TBaseMessage;

		begin
		m:= TBaseMessage.Create;

		m.Assign(AMessage);

		m.Category:= mcPlay;
		m.Method:= $04;

		APeer.AddSendMessage(m);
		end;

	begin
	if  AMessage.Category = mcPlay then
		if  AMessage.Method = 4 then
			begin
			AMessage.ExtractParams;
			if  (AMessage.Params.Count > 2)
			and (CompareText(string(Desc), string(AMessage.Params[0])) = 0) then
				begin
				AMessage.Params[1]:= Copy(AMessage.Params[1], Low(AnsiString), 8);

				AMessage.DataFromParams;

				with FPlayers.LockList do
					try
					for i:= 0 to Count - 1 do
						PeerMessageFromPlayer(Items[i], AMessage);

					finally
					FPlayers.UnlockList;
					end;

				AHandled:= True;
				end;
			end
		else if AMessage.Method = $07 then
			begin
			AHandled:= True;

			if  Length(AMessage.Data) = 2 then
				begin
				Lock.Acquire;
					try
					s:= AMessage.Data[0];

					if  (s > High(Slots))
					or  (s < 0) then
						Exit;

					p:= TPlayerState(AMessage.Data[1]);

					if  (State >= gsPreparing)
					or  (p = psNone) then
						Exit
					else if (p = psIdle)
					and (Slots[s].State = psReady) then
						Dec(ReadyCount)
					else if (p = psReady)
					and (Slots[s].State = psIdle) then
						Inc(ReadyCount);

					f:= False;

					if  (State = gsWaiting)
					and (SlotCount > 1)
					and (ReadyCount = SlotCount) then
						begin
						f:= True;
						State:= gsPreparing;
						p:= psPreparing;
						ReadyCount:= 0;
						for i:= 0 to High(Slots) do
							if  Slots[i].State = psReady then
								Slots[i].State:= p;
						end;

					Slots[s].State:= p;

					if  not f then
						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								SendSlotStatus(Slots[i].Player, s);

					if  f then
						begin
						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								for j:= 0 to High(Slots) do
									SendSlotStatus(Slots[i].Player, j);

						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								SendGameStatus(Slots[i].Player);
						end;

					finally
					Lock.Release;
					end;
				end;
			end
		else if AMessage.Method = $08 then
			begin
			AHandled:= True;

			if  Length(AMessage.Data) = 3 then
				begin
				Lock.Acquire;
				try
					s:= AMessage.Data[0];

                    if  (s < 0)
                    or  (s > High(Slots))
                    or  (not Assigned(Slots[s].Player))
                    or  ((Slots[s].State = psPlaying)
                    and  Slots[s].Drawn) then
						begin
						m:= TBaseMessage.Create;
						m.Category:= mcPlay;
						m.Method:= $00;

						m.Params.Add(LIT_ERR_PLAYNODR);
						m.DataFromParams;

		                APlayer.AddSendMessage(m);

						Exit;
						end;

					if  Slots[s].State = psPreparing then
						begin
	                    c:= Deck[Index];
						Inc(Index);

						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								begin
								m:= TBaseMessage.Create;
								m.Category:= mcPlay;
								m.Method:= $08;
								SetLength(m.Data, 3);
	                            m.Data[0]:= Byte(s);
								m.Data[1]:= Byte(c);
								m.Data[2]:= 0;

								Slots[i].Player.AddSendMessage(m);
								end;

                        Slots[s].FirstCard:= c;
						Inc(ReadyCount);
						end
					else if  not Slots[s].Drawn then
						begin
						if  AMessage.Data[2] = 0 then
							begin
		                    repeat
		                        c:= Deck[Index];
								Inc(Index);
								if  Index > High(TPlayingCard) then
									ReshuffleDeck;
								until c <> 0;
							end
						else
							c:= LastDiscard;

						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								begin
								m:= TBaseMessage.Create;
								m.Category:= mcPlay;
								m.Method:= $08;
								SetLength(m.Data, 3);
			                    m.Data[0]:= Byte(s);

	                            if  i = s then
									m.Data[1]:= Byte(c)
								else
									m.Data[1]:= 0;

								m.Data[2]:= AMessage.Data[2];

								Slots[i].Player.AddSendMessage(m);
								end;

						AddPlayerCard(s, c);

						Slots[s].Drawn:= True;
						end
					else
						begin
						m:= TBaseMessage.Create;
						m.Category:= mcPlay;
						m.Method:= $00;

						m.Params.Add(LIT_ERR_PLAYNODR);
						m.DataFromParams;

		                APlayer.AddSendMessage(m);

						Exit;
						end;

					if  Slots[s].State = psPreparing then
						begin
						Slots[s].State:= psWaiting;

						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								SendSlotStatus(Slots[i].Player, s);
						end;

					if  (State = gsPreparing)
					and (ReadyCount = SlotCount) then
						begin
						s:= 0;
						j:= Slots[0].FirstCard;

						for i:= 1 to High(Slots) do
							if  Slots[i].FirstCard > j then
								begin
								s:= i;
								j:= Slots[i].FirstCard;
								end;

						First:= s;
						Slots[s].State:= psPlaying;
						Round:= 1;
						Turn:= s;

						State:= gsPlaying;

						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								SendGameStatus(Slots[i].Player);


						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								SendSlotStatus(Slots[i].Player, s);

						DealToPlayers;

//						Check All GIN
						i:= Turn;
                        while True do
                        	begin
                            if  Assigned(Slots[i].Player)
                            and CheckForGin(i) then
                                begin
                                HandleGin(i);
                                Break;
								end;

                            Inc(i);
                            if  i = High(Slots) then
                                i:= 0;

                            if  i = Turn then
                                Break;
							end;
                        end;

					finally
	                Lock.Release;
					end;
				end;
			end
		else if AMessage.Method = $09 then
			begin
			AHandled:= True;

			if  Length(AMessage.Data) = 2 then
				begin
				Lock.Acquire;
				try
					s:= AMessage.Data[0];

                    if  (Turn = s)
                    and Slots[s].Drawn
                    and (LastDiscard <> AMessage.Data[1]) then
                    	begin
                        if  not RemovePlayerCard(s, AMessage.Data[1]) then
                            begin
//TODO:						Error message
	                        Exit;
							end;

						LastDiscard:= AMessage.Data[1];

                        for i:= 0 to High(Slots) do
                        	if  Assigned(Slots[i].Player) then
                                begin
                                m:= TBaseMessage.Create;
                                m.Assign(AMessage);

                                Slots[i].Player.AddSendMessage(m);
								end;

                        Slots[s].Drawn:= False;

                        if  CheckForGin(s) then
                            begin
                            HandleGin(s);

							end
						else
                            begin
	                        Slots[s].State:= psWaiting;

							for i:= 0 to High(Slots) do
								if  Assigned(Slots[i].Player) then
									SendSlotStatus(Slots[i].Player, s);

	                        repeat
	                            Inc(Turn);
	                            if 	Turn > High(Slots) then
	                                Turn:= 0;

								until Assigned(Slots[Turn].Player);

	                        Slots[Turn].State:= psPlaying;

							for i:= 0 to High(Slots) do
								if  Assigned(Slots[i].Player) then
									SendSlotStatus(Slots[i].Player, Turn);
							end;
						end
                    else
                    	begin
//TODO					Error message
						end;

					finally
                    Lock.Release;
                    end;
				end;
			end
		else if AMessage.Method = $0A then
			begin
			end
		else if AMessage.Method = $0B then
			begin
			end
		else if AMessage.Method = $0C then
            begin
			AHandled:= True;

            if  (Length(AMessage.Data) = 1)
            and (AMessage.Data[0] = First) then
                begin
				Lock.Acquire;
				try
		            for i:= 0 to High(Slots) do
		            	if  Assigned(Slots[i].Player) then
		                    begin
		                    m:= TBaseMessage.Create;
		                    m.Assign(AMessage);

		                    Slots[i].Player.AddSendMessage(m);
							end;

                    if  Round <= LastRound then
                    	begin
                        Slots[Turn].State:= psWaiting;

						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								SendSlotStatus(Slots[i].Player, Turn);


                        Turn:= First;

                        Slots[Turn].State:= psPlaying;

						for i:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								SendSlotStatus(Slots[i].Player, Turn);

                        DealToPlayers;

//						Check All GIN
						i:= Turn;
                    	while True do
	                    	begin
	                        if  Assigned(Slots[i].Player)
	                        and CheckForGin(i) then
	                        	begin
	                            HandleGin(i);
	                            Break;
								end;

	                        Inc(i);
	                        if  i = High(Slots) then
	                        	i:= 0;

	                        if  i = Turn then
	                        	Break;
							end;
						end;

                    if  Round > LastRound then
                    	begin
                        State:= gsFinished;

                        s:= Slots[0].Score;

                        for i:= 1 to High(Slots) do
                        	if  Slots[i].Score > s then
                                s:= Slots[i].Score;

                        for i:= 0 to High(Slots) do
                            if  Slots[i].Score = s then
                                Slots[i].State:= psWinner
                            else
                            	Slots[i].State:= psFinished;

                        for i:= 0 to High(Slots) do
                            if  Assigned(Slots[i].Player) then
                            	for j:= 0 to High(Slots) do
                                    if  Assigned(Slots[j].Player) then
                                		SendSlotStatus(Slots[i].Player, j);
						end;

		        	for i:= 0 to High(Slots) do
		        		if  Assigned(Slots[i].Player) then
		        			SendGameStatus(Slots[i].Player);

					finally
	                Lock.Release;
					end;
            	end;
			end;
	end;

procedure TPlayGame.Remove(APlayer: TPlayer);
	var
	i,
	j: Integer;
	s: Integer;
	f: Boolean;

	procedure PartMessageFromPeer(APeer: TPlayer; AName: AnsiString; ASlot: Integer);
		var
		m: TBaseMessage;

		begin
		m:= TBaseMessage.Create;
		m.Category:= mcPlay;
		m.Method:= $02;

		m.Params.Add(Desc);
		m.Params.Add(AName);
		m.Params.Add(AnsiString(IntToStr(ASlot)));

		m.DataFromParams;

		APeer.AddSendMessage(m);
		end;

	begin
	Lock.Acquire;
		try
		s:= -1;
		for i:= 0 to High(Slots) do
			if  Slots[i].Player = APlayer then
				begin
				s:= i;
				Break;
				end;

		if  s = -1 then
			Exit;

		Dec(SlotCount);

		for i:= 0 to High(Slots) do
			if  Assigned(Slots[i].Player) then
				PartMessageFromPeer(Slots[i].Player, APlayer.Name, s);

		Slots[s].Player:= nil;

		f:= False;

		if  State = gsFinished then
//          Do nothing - dummy message will be sent
		else if  State = gsPreparing then
			begin
			Slots[s].State:= psNone;

			if  SlotCount = 1 then
				begin
				ReadyCount:= 0;
				f:= True;
				State:= gsWaiting;
				for i:= 0 to 5 do
					if  Assigned(Slots[i].Player) then
						Slots[i].State:= psIdle;
				end;
			end
		else if  State > gsPreparing then
			begin
			if  Slots[s].State = psPlaying then
				begin
//dengland      Optimise this with handling in message $0B, above

				while True do
					begin
					Inc(Turn);
					if  Turn > High(Slots) then
						Turn:= 0;

					if  Assigned(Slots[Turn].Player)
					and (Slots[Turn].State = psWaiting) then
						Break;
					end;

				if  Turn > -1 then
					begin
					Slots[Turn].State:= psPlaying;
					end;

				if  f
				and (State = gsFinished) then
					begin
					for i:= 0 to High(Slots) do
						for j:= 0 to High(Slots) do
							if  Assigned(Slots[i].Player) then
								SendSlotStatus(Slots[i].Player, j);
					end
				else
					begin
					for i:= 0 to High(Slots) do
						if  Assigned(Slots[i].Player) then
							SendSlotStatus(Slots[i].Player, s);

					for i:= 0 to High(Slots) do
						if  Assigned(Slots[i].Player) then
							SendSlotStatus(Slots[i].Player, Turn);

					for i:= 0 to High(Slots) do
						if  Assigned(Slots[i].Player) then
							begin
							end;
					end;

				if  f then
					begin
					for i:= 0 to High(Slots) do
						if  Assigned(Slots[i].Player) then
							SendGameStatus(Slots[i].Player);
					end;
				end;

			if  State <> gsFinished then
				begin
				Slots[s].State:= psFinished;

				if  SlotCount = 1 then
					begin
					f:= True;
					State:= gsFinished;
					for i:= 0 to High(Slots) do
						if  Assigned(Slots[i].Player) then
							Slots[i].State:= psWinner;
					end;
				end;
			end
		else
			Slots[s].State:= psNone;

//dengland  This is really nasty when the game has ended or control otherwise changed
//      due to the currently playing player leaving
		if  not f then
			begin
			for i:= 0 to High(Slots) do
				if  Assigned(Slots[i].Player) then
					SendSlotStatus(Slots[i].Player, s);
			end
		else
			begin
			for i:= 0 to High(Slots) do
				if  Assigned(Slots[i].Player) then
					begin
					for j:= 0 to 5 do
						SendSlotStatus(Slots[i].Player, j);

					SendGameStatus(Slots[i].Player);
					end;
			end;

		finally
		Lock.Release;
		end;

	inherited;

	if  PlayerCount = 0 then
		ExpireZones.Add(Self);
	end;

procedure TPlayGame.SendGameStatus(APlayer: TPlayer);
	var
	m: TBaseMessage;

	begin
	m:= TBaseMessage.Create;
	m.Category:= mcPlay;
	m.Method:= $06;
	SetLength(m.Data, 2);
	m.Data[0]:= Ord(State);
	m.Data[1]:= Ord(Round);

    APlayer.AddSendMessage(m);
	end;

procedure TPlayGame.SendSlotStatus(APlayer: TPlayer; ASlot: Integer);
	var
	m: TBaseMessage;

	begin
	m:= TBaseMessage.Create;
	m.Category:= mcPlay;
	m.Method:= $07;

	SetLength(m.Data, 3);
	m.Data[0]:= ASlot;
	m.Data[1]:= Ord(Slots[ASlot].State);
	m.Data[2]:= Slots[ASlot].Score;

    APlayer.AddSendMessage(m);
	end;

procedure TPlayGame.SendLastDiscard(APlayer: TPlayer; ASlot: Integer);
    var
    m: TBaseMessage;

    begin
	m:= TBaseMessage.Create;
	m.Category:= mcPlay;
	m.Method:= $09;

	SetLength(m.Data, 2);
    if  ASlot = -1 then
		m.Data[0]:= $FF
    else
		m.Data[0]:= ASlot;
	m.Data[1]:= Ord(LastDiscard);

    APlayer.AddSendMessage(m);
	end;

procedure TPlayGame.NopPlayerCards;
    var
	i,
	j,
	k: Integer;
	c: TCardIndex;

	begin
    for i:= 0 to High(Slots) do
		for j:= 0 to High(Slots[i].Cards) do
			begin
			c:= Slots[i].Cards[j];

            if  c > 0 then
				for k:= Low(Deck) to High(Deck) do
            		if  Deck[k] = c then
						PCardIndex(@Deck[k])^:= 0;
			end;
	end;

procedure TPlayGame.AddPlayerCard(const APlayer: Integer;
		const ACard: TCardIndex);
    var
	i,
	j: Integer;

	begin
    j:= 10;

	for  i:= 0 to High(Slots[APlayer].Cards) do
		if  Slots[APlayer].Cards[i] = 0 then
			begin
			j:= i;
			Break;
			end;

    Slots[APlayer].Cards[j]:= ACard;
	end;

function TPlayGame.RemovePlayerCard(const APlayer: Integer;
		const ACard: TCardIndex): Boolean;
    var
	i: Integer;

	begin
    Result:= False;

	for  i:= 0 to High(Slots[APlayer].Cards) do
		if  Slots[APlayer].Cards[i] = ACard then
			begin
			Slots[APlayer].Cards[i]:= 0;
            Result:= True;
			Break;
			end;
	end;

procedure TPlayGame.DealToPlayers;
    var
	i,
	j: Integer;
	c: TCardIndex;

    procedure SendGameEventDeal(const ASlot: Integer);
    	var
        m: TBaseMessage;

        begin
        m:= TBaseMessage.Create;
        m.Category:= mcPlay;
		m.Method:= $0B;
		SetLength(m.Data, 2);
        m.Data[0]:= 0;
        m.Data[1]:= First;

		Slots[ASlot].Player.AddSendMessage(m);
		end;

	procedure SendPlayerDrawCard(const ASlot: Integer; const ACard: TCardIndex);
        var
		m: TBaseMessage;

		begin
        m:= TBaseMessage.Create;
        m.Category:= mcPlay;
		m.Method:= $08;
		SetLength(m.Data, 3);
        m.Data[0]:= Byte(ASlot);
		m.Data[1]:= Byte(ACard);
		m.Data[2]:= 0;

		Slots[ASlot].Player.AddSendMessage(m);

		AddPlayerCard(ASlot, ACard);
		end;

	begin
//	Nop all player cards
	for i:= 0 to High(Slots) do
		if  Assigned(Slots[i].Player) then
			for j:= 0 to High(Slots[i].Cards) do
				Slots[i].Cards[j]:= 0;

//	Prepare the deck
	ShuffleStandardDeck(Deck);
	Index:= Low(TPlayingCard);

//	First 3 - in play order
	i:= First;
	while True do
		begin
		if  Assigned(Slots[i].Player) then
			for j:= 0 to 2 do
                begin
                c:= Deck[Index];
                Inc(Index);

				SendPlayerDrawCard(i, c);
				end;
        Inc(i);
		if  i > High(Slots) then
			i:= 0;

		if  i = First then
			Break;
		end;

//	Then 4
	i:= First;
	while True do
		begin
		if  Assigned(Slots[i].Player) then
			for j:= 0 to 3 do
                begin
                c:= Deck[Index];
                Inc(Index);

				SendPlayerDrawCard(i, c);
				end;
        Inc(i);
		if  i > High(Slots) then
			i:= 0;

		if  i = First then
			Break;
		end;

//	Last 3
	i:= First;
	while True do
		begin
		if  Assigned(Slots[i].Player) then
			for j:= 0 to 2 do
                begin
                c:= Deck[Index];
                Inc(Index);

				SendPlayerDrawCard(i, c);
				end;
        Inc(i);
		if  i > High(Slots) then
			i:= 0;

		if  i = First then
			Break;
		end;

//	And flip discard
	LastDiscard:= Deck[Index];
	Inc(Index);

	for i:= 0 to High(Slots) do
		if  Assigned(Slots[i].Player) then
			SendLastDiscard(Slots[i].Player, -1);

//	Notify event dealt
	for i:= 0 to High(Slots) do
		if  Assigned(Slots[i].Player) then
			SendGameEventDeal(i);
    end;

procedure TPlayGame.ReshuffleDeck;
    var
    i: Integer;

    procedure SendGameEventShuffle(const ASlot: Integer);
    	var
        m: TBaseMessage;

        begin
        m:= TBaseMessage.Create;
        m.Category:= mcPlay;
		m.Method:= $0B;
		SetLength(m.Data, 2);
        m.Data[0]:= 1;
        m.Data[1]:= Turn;

		Slots[ASlot].Player.AddSendMessage(m);
		end;

    begin
	ShuffleStandardDeck(Deck);
	NopPlayerCards;

    Index:= Low(TPlayingCard);
    repeat
    	LastDiscard:= Deck[Index];
    	Inc(Index);
		until LastDiscard <> 0;

//	Notify event dealing
	for i:= 0 to High(Slots) do
		if  Assigned(Slots[i].Player) then
			SendGameEventShuffle(i);

	for i:= 0 to High(Slots) do
		if  Assigned(Slots[i].Player) then
			SendLastDiscard(Slots[i].Player, -1);
	end;

function TPlayGame.CheckForGin(const ASlot: Integer): Boolean;
	var
	i: Integer;
	j: TCardIndex;
	k: TCardSuit;
	l: TCardIndex;
	m,
	s: Integer;
	f: Boolean;
	n: TCardFace;
	spare: TCardSet;
	scnt: Integer;
	sets: array[TCardFace] of array of TCardIndex;
	strs: array of array of TCardIndex;
	suit: array[TCardSuit] of array of TCardIndex;
	t: string;

	procedure BubbleSwap(var a, b: TCardIndex);
		var
	  	temp: TCardIndex;

		begin
	  	temp:= a;
	  	a:= b;
	  	b:= temp;
		end;


	procedure BubbleSort(var a: array of TCardIndex);
		var
	  	n,
		newn,
		i: TCardIndex;

		begin
	  	n:= High(a);
	  	repeat
			newn:= 0;
			for i:= 1 to n do
	  			begin
	    		if a[i - 1] > a[i] then
	      			begin
	        		BubbleSwap(a[i - 1], a[i]);
	        		newn:= i;
	      			end;
	  			end;
			n:= newn;
	  		until n = 0;
		end;


	begin
	spare:= [];
	scnt:= 0;

    for k:= Low(TCardSuit) to High(TCardSuit) do
		SetLength(suit[k], 0);

    SetLength(strs, 0);

    for n:= Low(TCardFace) to High(TCardFace) do
    	SetLength(sets[n], 0);

//	We have to check if they are all sets first because otherwise, we'd need to
//	later check to completely dissolve straights, as well.

	for i:= 0 to High(Slots[ASlot].Cards) do
    	if  Slots[ASlot].Cards[i] <> 0 then
        	begin
			Include(spare, Slots[ASlot].Cards[i]);
            Inc(scnt);
			end;

//	Collate sets
   	for j:= Low(TCardIndex) to High(TCardIndex) do
   		if  j in spare then
   			begin
   	        n:= ARR_REC_DECKCARDS[j].Face;

   			SetLength(sets[n], Length(sets[n]) + 1);
   	        sets[n][High(sets[n])]:= j;

   			Exclude(spare, j);
   			Dec(scnt);
   			end;

    Assert(scnt = 0, 'Error in initial gin collation logic!');

   	AddLogMessage(slkDebug, 'Sets first pass');
   	for n:= Low(sets) to High(sets) do
   	    if  Length(sets[n]) > 0 then
   			begin
   			t:= #9;
   	        for j:= 0 to High(sets[n]) do
   	        	t:= t + CardIndexToIdent(sets[n][j]) + ' ';

   	        AddLogMessage(slkDebug, t);
   			end;

//	Check GIN at this point
	f:= True;

	for n:= Low(sets) to High(sets) do
		if  (Length(sets[n]) > 0)
		and (Length(sets[n]) < 3) then
			begin
			f:= False;
			Break;
			end;

    if  f then
        begin
    	Result:= f;
        Exit;
		end;

//	Continue processing...

	spare:= [];
	scnt:= 0;

    for n:= Low(TCardFace) to High(TCardFace) do
    	SetLength(sets[n], 0);

//	Collect them into suits
	for i:= 0 to High(Slots[ASlot].Cards) do
        if  Slots[ASlot].Cards[i] <> 0 then
			begin
		    k:= ARR_REC_DECKCARDS[Slots[ASlot].Cards[i]].Suit;

			SetLength(suit[k], Length(suit[k]) + 1);
			suit[k][High(suit[k])]:= Slots[ASlot].Cards[i];

			Include(spare, Slots[ASlot].Cards[i]);
            Inc(scnt);
			end;

//	Sort the suits
	for k:= Succ(Low(TCardSuit)) to High(TCardSuit) do
		if  Length(suit[k]) > 0 then
	    	BubbleSort(suit[k]);

//	Collect straights
	for k:= Succ(Low(TCardSuit)) to High(TCardSuit) do
		if  Length(suit[k]) > 0 then
			begin
//			Come back later for aces
			if  (ARR_REC_DECKCARDS[suit[k][0]].Face = cfkAce)
			and (Length(suit[k]) > 1) then
				l:= 2
			else
				l:= 1;

	        SetLength(strs, Length(strs) + 1);
			m:= High(strs);
			s:= m;
			j:= suit[k][l - 1];

			Assert(j > 0, 'Error in suits');

	        SetLength(strs[m], 1);
			strs[m][0]:= j;

			Exclude(spare, j);
			Dec(scnt);

//dengland	This is for i:= 'ell' to ... not one to...
			for i:= l to High(suit[k]) do
	        	if  suit[k][i] = (j + 1) then
					begin
					SetLength(strs[m], Length(strs[m]) + 1);
					j:= suit[k][i];

	    			Assert(j > 0, 'Error in suits');

					strs[m][High(strs[m])]:= j;

					Exclude(spare, j);
					Dec(scnt);
					end
				else
					begin
	                SetLength(strs, Length(strs) + 1);
	    			m:= High(strs);
	    			j:= suit[k][i];

	    			Assert(j > 0, 'Error in suits');

	                SetLength(strs[m], 1);
	    			strs[m][0]:= j;

					Exclude(spare, j);
					Dec(scnt);
					end;

			if  ARR_REC_DECKCARDS[suit[k][0]].Face = cfkAce then
				begin
				f:= False;

	            if  (ARR_REC_DECKCARDS[strs[s][0]].Face = cfkTwo)
				and (Length(strs[s]) > 1) then
					if  not ((ARR_REC_DECKCARDS[suit[k][High(suit[k])]].Face = cfkKing)
					and (Length(strs[m]) < 3)) then
						begin
						f:= True;
						SetLength(strs[s], Length(strs[s]) + 1);
						for i:= High(strs[s]) downto 1 do
							strs[s][i]:= strs[s][i - 1];

						strs[s][0]:= suit[k][0];
						Exclude(spare, suit[k][0]);
						Dec(scnt);
						end;

				if  (not f)
				and (ARR_REC_DECKCARDS[suit[k][High(suit[k])]].Face = cfkKing) then
					begin
	                SetLength(strs[m], Length(strs[m]) + 1);
					strs[m][High(strs[m])]:= suit[k][0];
					Exclude(spare, suit[k][0]);
					Dec(scnt);
					end;
				end;
			end;

	AddLogMessage(slkDebug, 'Strs first pass');
	for i:= 0 to High(strs) do
		if  Length(strs[i]) > 0 then
			begin
			t:= #9;
		    for j:= 0 to High(strs[i]) do
		    	t:= t + CardIndexToIdent(strs[i][j]) + ' ';

	    	AddLogMessage(slkDebug, t);
			end;

//	Collect back any strs that are not at least 3 in length
	for i:= 0 to High(strs) do
		if  Length(strs[i]) < 3 then
	        begin
			for j:= 0 to High(strs[i]) do
				begin
	            Include(spare, strs[i][j]);
				Inc(scnt);
				end;

			SetLength(strs[i], 0);
			end;

	AddLogMessage(slkDebug, 'Strs second pass');
	for i:= 0 to High(strs) do
		if  Length(strs[i]) > 0 then
			begin
			t:= #9;
	        for j:= 0 to High(strs[i]) do
	            t:= t + CardIndexToIdent(strs[i][j]) + ' ';

	        AddLogMessage(slkDebug, t);
			end;

//	Collate sets
	for j:= Low(TCardIndex) to High(TCardIndex) do
		if  j in spare then
			begin
	        n:= ARR_REC_DECKCARDS[j].Face;

			SetLength(sets[n], Length(sets[n]) + 1);
	        sets[n][High(sets[n])]:= j;

			Exclude(spare, j);
			Dec(scnt);
			end;

	Assert(scnt = 0, 'Error in gin collation logic!');

	AddLogMessage(slkDebug, 'Sets second pass');
	for n:= Low(sets) to High(sets) do
	    if  Length(sets[n]) > 0 then
			begin
			t:= #9;
	        for j:= 0 to High(sets[n]) do
	        	t:= t + CardIndexToIdent(sets[n][j]) + ' ';

	        AddLogMessage(slkDebug, t);
			end;

//	"Borrow" from strs (first)
	 for i:= 0 to High(strs) do
		while Length(strs[i]) > 3 do
			begin
	        n:= ARR_REC_DECKCARDS[strs[i][0]].Face;

			if  Length(sets[n]) = 2 then
				begin
				SetLength(sets[n], Length(sets[n]) + 1);
				sets[n][High(sets[n])]:= strs[i][0];

				for s:= 0 to High(strs[i]) - 1 do
					strs[i][s]:= strs[i][s + 1];

				SetLength(strs[i], Length(strs[i]) - 1);
				end
			else
				Break;
			end;

//	"Borrow" from strs (last)
	 for i:= 0 to High(strs) do
		while Length(strs[i]) > 3 do
			begin
	        n:= ARR_REC_DECKCARDS[strs[i][High(strs[i])]].Face;

			if  Length(sets[n]) = 2 then
				begin
				SetLength(sets[n], Length(sets[n]) + 1);
				sets[n][High(sets[n])]:= strs[i][High(strs[i])];
				SetLength(strs[i], Length(strs[i]) - 1);
				end
			else
				Break;
			end;

//	"Split" strs
	i:= 0;
	while i < High(strs) do
		begin
		if  Length(strs[i]) > 6 then
			begin
			f:= False;

			for s:= 3 to High(strs[i]) - 3 do
				begin
	            n:= ARR_REC_DECKCARDS[strs[i][s]].Face;

	    		if  Length(sets[n]) = 2 then
					begin
	    			SetLength(sets[n], Length(sets[n]) + 1);
	    			sets[n][High(sets[n])]:= strs[i][s];

					SetLength(strs, Length(strs) + 1);
					SetLength(strs[High(strs)], Length(strs[i]) - s - 1);

					Move(strs[i][s + 1], strs[High(strs)][0],
							Length(strs[High(strs)]));

					SetLength(strs[i], s);
					f:= True;
					end;
				end;

	        if  not f then
				Inc(i);
			end
		else
			Inc(i);
		end;

	AddLogMessage(slkDebug, 'Strs third pass');
	for i:= 0 to High(strs) do
		if  Length(strs[i]) > 0 then
			begin
			t:= #9;
	        for j:= 0 to High(strs[i]) do
	            t:= t + CardIndexToIdent(strs[i][j]) + ' ';

	        AddLogMessage(slkDebug, t);
			end;

	AddLogMessage(slkDebug, 'Sets third pass');
	for n:= Low(sets) to High(sets) do
	    if  Length(sets[n]) > 0 then
			begin
			t:= #9;
	        for j:= 0 to High(sets[n]) do
	        	t:= t + CardIndexToIdent(sets[n][j]) + ' ';

	        AddLogMessage(slkDebug, t);
			end;

//	Check GIN
	f:= True;

    for i:= 0 to High(strs) do
		if  (Length(strs[i]) > 0)
		and (Length(strs[i]) < 3) then
			begin
			f:= False;
			Break;
			end;

	if  f then
	 	for n:= Low(sets) to High(sets) do
	        if  (Length(sets[n]) > 0)
			and (Length(sets[n]) < 3) then
				begin
				f:= False;
				Break;
				end;

	Result:= f;
	end;

procedure TPlayGame.HandleGin(const ASlot: Integer);
    var
    i: Integer;

    procedure SendHaveGin(ASlot: Integer; AGinSlot: Integer);
        var
        i,
        j: Integer;

        m: TBaseMessage;

        begin
        m:= TBaseMessage.Create;
        m.Category:= mcPlay;
        m.Method:= $0A;
        SetLength(m.Data, 11);
        m.Data[0]:= AGinSlot;

        j:= 1;
        for i:= 0 to High(Slots[AGinSlot].Cards) do
            if  Slots[AGinSlot].Cards[i] <> 0 then
                begin
                m.Data[j]:= Slots[AGinSlot].Cards[i];
                Inc(j);
                if  j = 11 then
                    Break;
                end;

        Slots[ASlot].Player.AddSendMessage(m);
        end;

    procedure SendGameEventNewFirst(const ASlot: Integer);
    	var
        m: TBaseMessage;

        begin
        m:= TBaseMessage.Create;
        m.Category:= mcPlay;
		m.Method:= $0B;
		SetLength(m.Data, 2);
        m.Data[0]:= 2;
        m.Data[1]:= First;

		Slots[ASlot].Player.AddSendMessage(m);
		end;

    begin
    Inc(Round);

    Inc(Slots[ASlot].Score);

    repeat
    	Inc(First);
    	if  First > High(Slots) then
    		First:= 0
        until Assigned(Slots[First].Player);

	for i:= 0 to High(Slots) do
		if  Assigned(Slots[i].Player) then
			SendSlotStatus(Slots[i].Player, ASlot);

    for i:= 0 to High(Slots) do
       	if  Assigned(Slots[i].Player) then
    		SendHaveGin(i, ASlot);

    for i:= 0 to High(Slots) do
       	if  Assigned(Slots[i].Player) then
            SendGameEventNewFirst(i);
    end;


{ TPlayZone }

procedure TPlayZone.Add(APlayer: TPlayer);
	begin
	inherited;

	end;

function TPlayZone.AddGame(ADesc, APassword: AnsiString): TPlayGame;
	begin
	with FGames.LockList do
		try
			Result:= GameByName(ADesc);

			if  not Assigned(Result) then
				begin
				Result:= TPlayGame.Create;

				Result.Desc:= ADesc;
				Result.Play:= Self;
				Result.Password:= APassword;

				FGames.Add(Result);
				end;

			finally
            FGames.UnlockList;
			end;
	end;

constructor TPlayZone.Create;
	begin
	inherited;

	FGames:= TPlayGames.Create;
	end;

destructor TPlayZone.Destroy;
	var
	i: Integer;

	begin
	with FGames.LockList do
		try
		for i:= Count - 1 downto 0 do
			begin
			Items[i].Play:= nil;
			Items[i].Free;
			end;

		finally
		FGames.UnlockList;
		end;

	FGames.Free;

    inherited;
	end;

function TPlayZone.GameByName(ADesc: AnsiString): TPlayGame;
	var
	i: Integer;

	begin
	Result:= nil;
	with FGames.LockList do
		try
		for i:= 0 to Count - 1 do
			if  CompareText(string(Items[i].Desc), string(ADesc)) = 0 then
				begin
				Result:= Items[i];
				Exit;
				end;
		finally
		FGames.UnlockList;
		end;
	end;

class function TPlayZone.Name: AnsiString;
	begin
	result:= 'play';
	end;

procedure TPlayZone.ProcessPlayerMessage(APlayer: TPlayer;
        AMessage: TBaseMessage; var AHandled: Boolean);
	var
	g: TPlayGame;
	d: AnsiString;
	m: TBaseMessage;
	ml: TMessageList;
	i: Integer;
	p: AnsiString;
	f: Boolean;
	s: Integer;

	begin
	if  AMessage.Category = mcPlay then
		if  AMessage.Method = 1 then
			begin
			AHandled:= True;
			AMessage.ExtractParams;

			if  (AMessage.Params.Count > 0)
			and (AMessage.Params.Count < 3) then
				begin
				d:= Copy(AMessage.Params[0], Low(AnsiString), 8);
				g:= GameByName(AMessage.Params[0]);

				if  AMessage.Params.Count = 2 then
					p:= AMessage.Params[1]
				else
					p:= '';

				if  not Assigned(g) then
					g:= AddGame(d, p);

				if  CompareText(string(p), string(g.Password)) = 0 then
					begin
					g.Lock.Acquire;
						try
						if  (g.State < gsPreparing)
						and (g.SlotCount < Length(g.Slots)) then
							begin
							g.Add(APlayer);

							s:= -1;
							for i:= 0 to High(g.Slots) do
								begin
								if  (Assigned(g.Slots[i].Player))
								or  (g.Slots[i].State > psPlaying) then
									g.SendSlotStatus(APlayer, i);

								if  g.Slots[i].Player = APlayer then
									s:= i;
								end;

							Assert(s > -1, 'Failure in handling join in play zone.');

							for i:= 0 to High(g.Slots) do
								if  (Assigned(g.Slots[i].Player))
								and (g.Slots[i].Player <> APlayer) then
									g.SendSlotStatus(g.Slots[i].Player, s);
							end
						else
							begin
							m:= TBaseMessage.Create;
							m.Category:= mcPlay;
							m.Method:= $00;

							m.Params.Add(LIT_ERR_PLAYGMST);
							m.DataFromParams;

                            APlayer.AddSendMessage(m);
							end;
						finally
						g.Lock.Release;
						end;
					end
				else
					begin
					m:= TBaseMessage.Create;
					m.Category:= mcPlay;
					m.Method:= $00;

					m.Params.Add(LIT_ERR_PLAYPWDR);
					m.DataFromParams;

                    APlayer.AddSendMessage(m);
					end;
				end
			else
				APlayer.SendServerError(LIT_ERR_PLAYJINV);
			end
		else if AMessage.Method = 2 then
			begin
			AMessage.ExtractParams;

			g:= GameByName(AMessage.Params[0]);

			if  Assigned(g) then
				begin
				g.Remove(APlayer);
				end
			else
				APlayer.SendServerError(LIT_ERR_PLAYPINV);

			AHandled:= True;
			end
		else if AMessage.Method = $03 then
			begin
			AHandled:= True;

			AMessage.ExtractParams;

			g:= nil;

			if  AMessage.Params.Count > 0 then
				begin
				g:= GameByName(AMessage.Params[0]);
				if  not Assigned(g) then
					begin
					APlayer.SendServerError(LIT_ERR_PLAYLINV);
					Exit;
					end;
				end;

			ml:= TMessageList.Create(APlayer);

			if  AMessage.Params.Count > 0 then
				begin
				g.Lock.Acquire;
					try
					f:= False;
					for i:= 0 to High(g.Slots) do
						if  g.Slots[i].Player = APlayer then
							begin
							f:= True;
							Break;
							end;

					if  f
					or  (Length(g.Password) = 0) then
						for i:= 0 to High(g.Slots) do
							if  Assigned(g.Slots[i].Player) then
								ml.Data.Enqueue(g.Slots[i].Name + ' ' +
										AnsiChar(i + $30));

					finally
					g.Lock.Release;
					end
				end
			else
				with FGames.LockList do
					try
					for i:= 0 to Count - 1 do
						if  Length(Items[i].Password) = 0 then
							ml.Data.Enqueue(Items[i].Desc);

					finally
					FGames.UnlockList;
					end;

			m:= TBaseMessage.Create;
			m.Category:= mcText;
			m.Method:= $01;
			m.Params.Add(ml.Name);
			m.Params.Add(AnsiString(ARR_LIT_NAM_CATEGORY[mcPlay]));

			if  AMessage.Params.Count > 0 then
				m.Params.Add(g.Desc);

			m.DataFromParams;

            APlayer.AddSendMessage(m);

            ListMessages.Add(ml);
			end
	end;

procedure TPlayZone.Remove(APlayer: TPlayer);
	begin
	APlayer.RemoveZoneByClass(TPlayGame);
	end;

procedure TPlayZone.RemoveGame(ADesc: AnsiString);
	var
	g: TPlayGame;

	begin
	g:= GameByName(ADesc);
	if  Assigned(g) then
		FGames.Remove(g);
	end;


initialization
    Randomize;

	ExpireZones:= TExpireZones.Create;
	ExpirePlayers:= TExpirePlayers.Create;

	ListMessages:= TMessageLists.Create;

	SystemZone:= TSystemZone.Create;
	LimboZone:= TLimboZone.Create;
	LobbyZone:= TLobbyZone.Create;
	PlayZone:= TPlayZone.Create;

finalization
	with ExpirePlayers.LockList do
		try
		while Count > 0 do
			begin
			Items[0].Free;
			Delete(0);
			end;
		finally
		ExpirePlayers.UnlockList;
		end;

	with ExpireZones.LockList do
		try
		while Count > 0 do
			begin
			Items[0].Free;
			Delete(0);
			end;
		finally
		ExpireZones.UnlockList;
		end;

	ServerDisp.Terminate;
	ServerDisp.WaitFor;
	ServerDisp.Free;

	DoDestroyListMessages;

	ExpireZones.Free;
    ExpirePlayers.Free;

	PlayZone.Free;
	LobbyZone.Free;
	LimboZone.Free;
	SystemZone.Free;

//	MessageLock.Free;

end.
