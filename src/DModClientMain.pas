unit DModClientMain;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}
{$H+}


interface

uses
	Classes, SysUtils, FileUtil, Controls, ActnList, ExtCtrls, GinClient;

type

	{ TClientMainDMod }
	TClientMainDMod = class(TDataModule)
		ActHostConnect: TAction;
		ActHostDisconnect: TAction;
		ActGameJoin: TAction;
		ActGamePart: TAction;
		ActGameList: TAction;
		ActGameControl: TAction;
		ActGameDrawDeck: TAction;
		ActGameDrawDiscard: TAction;
		ActGameDiscard: TAction;
		ActGameBegin: TAction;
		ActNavDetail: TAction;
		ActNavReturn: TAction;
		ActNavStart: TAction;
		ActNavOverview: TAction;
		ActRoomMsg: TAction;
		ActRoomUsers: TAction;
		ActRoomList: TAction;
		ActRoomPart: TAction;
		ActRoomJoin: TAction;
		ActNavLobby: TAction;
		ActNavRoom: TAction;
		ActlstMain: TActionList;
		ActNavHost: TAction;
		ActNavDebug: TAction;
		ActNavConfigure: TAction;
		ActNavPlay: TAction;
		ActNavChat: TAction;
		ActNavConnect: TAction;
		ActlstNavigate: TActionList;
		ImageList1: TImageList;
		ImageList2: TImageList;
		TimerGIN: TTimer;
		TimerMain: TTimer;
		procedure ActGameBeginExecute(Sender: TObject);
  		procedure ActGameControlExecute(Sender: TObject);
		procedure ActGameDiscardExecute(Sender: TObject);
		procedure ActGameDrawDeckExecute(Sender: TObject);
		procedure ActGameDrawDiscardExecute(Sender: TObject);
  		procedure ActGameJoinExecute(Sender: TObject);
		procedure ActGameListExecute(Sender: TObject);
		procedure ActGamePartExecute(Sender: TObject);
  		procedure ActHostConnectExecute(Sender: TObject);
		procedure ActHostDisconnectExecute(Sender: TObject);
  		procedure ActNavChatExecute(Sender: TObject);
		procedure ActNavConfigureExecute(Sender: TObject);
  		procedure ActNavConnectExecute(Sender: TObject);
  		procedure ActNavDebugExecute(Sender: TObject);
		procedure ActNavDetailExecute(Sender: TObject);
  		procedure ActNavHostExecute(Sender: TObject);
		procedure ActNavLobbyExecute(Sender: TObject);
		procedure ActNavOverviewExecute(Sender: TObject);
  		procedure ActNavPlayExecute(Sender: TObject);
		procedure ActNavReturnExecute(Sender: TObject);
		procedure ActNavRoomExecute(Sender: TObject);
		procedure ActNavStartExecute(Sender: TObject);
		procedure ActRoomJoinExecute(Sender: TObject);
		procedure ActRoomListExecute(Sender: TObject);
		procedure ActRoomMsgExecute(Sender: TObject);
		procedure ActRoomPartExecute(Sender: TObject);
		procedure ActRoomUsersExecute(Sender: TObject);
		procedure TimerGINTimer(Sender: TObject);
		procedure TimerMainTimer(Sender: TObject);
	private
        procedure ConnectForwardBack(const AForward, ABack: TAction);

        procedure OnAfterConnect(ASender: TObject);
        procedure DoHandleDisconnected;

		procedure ProcessRoomLogMessages;
		procedure ProcessGameLogMessages;

	protected
		procedure DoConnect;
		procedure DoDisconnect;

	public
      	constructor Create(AOwner: TComponent); override;
		destructor  Destroy; override;
	end;

var
	ClientMainDMod: TClientMainDMod;


implementation

{$R *.lfm}

uses
	LCLIntf, Forms, TCPTypes, FormClientMain, CardTypes, GinClasses;


{ TClientMainDMod }

procedure TClientMainDMod.ActNavConnectExecute(Sender: TObject);
	begin
    if  ClientMainForm.PgctrlConnect.ActivePage = ClientMainForm.TbshtDebug then
		ConnectForwardBack(nil, ActNavHost)
	else
  		ConnectForwardBack(ActNavDebug, nil);

    ClientMainForm.PgctrlMain.ActivePage:= ClientMainForm.TbshtConnect;
	ActNavConnect.Checked:= True;
	end;

procedure TClientMainDMod.ActNavDebugExecute(Sender: TObject);
	begin
  	ConnectForwardBack(nil, ActNavHost);
    ClientMainForm.PgctrlConnect.ActivePage:= ClientMainForm.TbshtDebug;
	end;

procedure TClientMainDMod.ActNavDetailExecute(Sender: TObject);
	begin
    ConnectForwardBack(nil, ActNavOverview);
	ClientMainForm.PgctrlPlay.ActivePage:= ClientMainForm.TbshtDetail;
	end;

procedure TClientMainDMod.ActNavHostExecute(Sender: TObject);
	begin
  	ConnectForwardBack(ActNavDebug, nil);
    ClientMainForm.PgctrlConnect.ActivePage:= ClientMainForm.TbshtHost;
	end;

procedure TClientMainDMod.ActNavLobbyExecute(Sender: TObject);
	begin
  	ConnectForwardBack(ActNavRoom, nil);
    ClientMainForm.PgctrlChat.ActivePage:= ClientMainForm.TbshtLobby;
	end;

procedure TClientMainDMod.ActNavOverviewExecute(Sender: TObject);
	begin
    ConnectForwardBack(ActNavDetail, ActNavStart);
	ClientMainForm.PgctrlPlay.ActivePage:= ClientMainForm.TbshtOverview;
	end;

procedure TClientMainDMod.ActNavPlayExecute(Sender: TObject);
	begin
    if  ClientMainForm.PgctrlPlay.ActivePage = ClientMainForm.TbshtStart then
		ConnectForwardBack(ActNavOverview, nil)
	else if ClientMainForm.PgctrlPlay.ActivePage = ClientMainForm.TbshtOverview then
  		ConnectForwardBack(nil, ActNavStart)
	else
		ConnectForwardBack(nil, ActNavReturn);

    ClientMainForm.PgctrlMain.ActivePage:= ClientMainForm.TbshtPlay;
	ActNavPlay.Checked:= True;
	end;

procedure TClientMainDMod.ActNavReturnExecute(Sender: TObject);
	begin
    ConnectForwardBack(nil, ActNavStart);
	ClientMainForm.PgctrlPlay.ActivePage:= ClientMainForm.TbshtOverview;
	end;

procedure TClientMainDMod.ActNavRoomExecute(Sender: TObject);
	begin
  	ConnectForwardBack(nil, ActNavLobby);
    ClientMainForm.PgctrlChat.ActivePage:= ClientMainForm.TbshtRoom;
	end;

procedure TClientMainDMod.ActNavStartExecute(Sender: TObject);
	begin
    ConnectForwardBack(ActNavOverview, nil);
    ClientMainForm.PgctrlPlay.ActivePage:= ClientMainForm.TbshtStart;
	end;

procedure TClientMainDMod.ActRoomJoinExecute(Sender: TObject);
	begin
    if  Length(Client.Room) = 0 then
		if  Length(ClientMainForm.EditRoom.Text) > 0 then
			Client.SendRoomJoin(Connection,
					AnsiString(ClientMainForm.EditRoom.Text),
					AnsiString(ClientMainForm.EditRoomPwd.Text))
		else
         	ClientMainForm.ActiveControl:= ClientMainForm.EditRoom;
	end;

procedure TClientMainDMod.ActRoomListExecute(Sender: TObject);
	begin
    Client.SendRoomList(Connection);
	end;

procedure TClientMainDMod.ActRoomMsgExecute(Sender: TObject);
	begin
    Client.SendRoomMessage(Connection,
			AnsiString(ClientMainForm.EditRoomText.Text));
	ClientMainForm.EditRoomText.Text:= '';
	end;

procedure TClientMainDMod.ActRoomPartExecute(Sender: TObject);
	begin
    if  Length(Client.Room) > 0 then
		Client.SendRoomPart(Connection);
	end;

procedure TClientMainDMod.ActRoomUsersExecute(Sender: TObject);
	begin
    ClientMainForm.PanelRoomUsers.Visible:= not
			ClientMainForm.PanelRoomUsers.Visible;
	end;

procedure TClientMainDMod.TimerGINTimer(Sender: TObject);
	begin
    if  ClientMainForm.CardHandFrame1.SelCount > 0 then
  		begin
  		ClientMainForm.CardHandFrame1.SetSelected(TimerGIN.Tag, False);
  		TimerGIN.Tag:= TimerGIN.Tag + 1;
  		if  TimerGIN.Tag = ClientMainForm.CardHandFrame1.CardCount then
  			TimerGIN.Tag:= 0;
  		end
  	else
  		ClientMainForm.CardHandFrame1.SetSelected(TimerGIN.Tag, True);
	end;

procedure TClientMainDMod.TimerMainTimer(Sender: TObject);
	var
	i: Integer;

	begin
	with LogMessages.LockList do
		try
 			while Count > 0 do
				begin
				ClientMainForm.MemoDebug.Lines.Add(Items[0].Message);
                Items[0].Free;
				Delete(0)
				end;

			finally
            LogMessages.UnlockList;
			end;

    while  HostLogMessages.Count > 0 do
		begin
		ClientMainForm.MemoHost.Lines.Add(HostLogMessages[0]);
        HostLogMessages.Delete(0);
		end;

	ProcessRoomLogMessages;
	ProcessGameLogMessages;

	if  Connection.Connected then
		begin
	    i:= Connection.PrepareRead;

		if  i = -1 then
			DoDisconnect
		else
			begin
	        if  i > 0 then
				if  not Client.ReadConnectionData(Connection, i) then
					begin
					DoDisconnect;
					Exit;
					end;

	        Client.ProcessReadMessages(Connection);

            if  not Connection.ProcessSendMessages then
				begin
				DoDisconnect;
				Exit;
				end;
			end;
		end;
	end;

procedure TClientMainDMod.ConnectForwardBack(const AForward, ABack: TAction);
    var
	i: Integer;

	begin
    for i:= 0 to ActlstNavigate.ActionCount - 1 do
		if  ActlstNavigate.Actions[i].Category = 'NavBrowse' then
			TAction(ActlstNavigate.Actions[i]).ShortCut:= 0;

	if  Assigned(AForward) then
		AForward.Shortcut:= 118;

	if  Assigned(ABack) then
		ABack.Shortcut:= 119;
	end;

procedure TClientMainDMod.OnAfterConnect(ASender: TObject);
	begin
    Connection.Connected:= True;

	ClientMainForm.BtnHostCntrl.Action:= ActHostDisconnect;

	AddLogMessage(slkInfo, 'Client connected...');

	HostLogMessages.Add('! Connected to host.');
	HostLogMessages.Add('');
	end;

procedure TClientMainDMod.DoHandleDisconnected;
	begin
    Connection.Connected:= False;
	Connection.Purge;

	ClientMainForm.BtnHostCntrl.Action:= ActHostConnect;
	AddLogMessage(slkInfo, 'Client disconnected.');

	HostLogMessages.Add('');
	HostLogMessages.Add('! Disconnected from host.');
	HostLogMessages.Add('');

	if  Assigned(Client.Server) then
		begin
		Client.Server.Free;
        Client.Server:= nil;
		end;

	ClientMainForm.EditHostInfo.Text:= '';
	end;

procedure TClientMainDMod.ProcessRoomLogMessages;
	var
	p: Integer;
	s,
	u,
	r: string;
	w: Boolean;

	begin
	while RoomLogMessages.Count > 0 do
		begin
		s:= RoomLogMessages.Items[0];
		RoomLogMessages.Delete(0);

		if  (s[Low(string)] = '<')
		or  (s[Low(string)] = '>') then
			begin
			if  not Client.RoomHaveSpc then
				ClientMainForm.MemoRoom.Lines.Add('');

			ClientMainForm.MemoRoom.Lines.Add(s);
			ClientMainForm.MemoRoom.Lines.Add('');

			Client.LastSpeak:= '';
			Client.RoomHaveSpc:= True;
			end
		else
			begin
			w:= s[Low(string)] = '!';

			s:= Copy(s, Low(string) + 1, MaxInt);

			if  not w then
				begin
				p:= Pos(' ', s);
				r:= Copy(s, Low(string), p - Low(string));
				s:= Copy(s, p + 1, MaxInt);
				end;

			p:= Pos(' ', s);
			u:= Copy(s, Low(string), p - Low(string));
			s:= Copy(s, p + 1, MaxInt);

			if  w then
				u:= u + ' whispers';

			if  CompareText(u, Client.LastSpeak) <> 0 then
				begin
				Client.LastSpeak:= u;

				ClientMainForm.MemoRoom.Lines.Add(u + ':');
				end;

			ClientMainForm.MemoRoom.Lines.Add(#9 + s);
			Client.RoomHaveSpc:= False;
			end;
		end;
	end;

procedure TClientMainDMod.ProcessGameLogMessages;
	var
	p: Integer;
	s,
	u,
	r: string;
	w: Boolean;

	begin
	while GameLogMessages.Count > 0 do
		begin
		s:= GameLogMessages.Items[0];
		GameLogMessages.Delete(0);

		if  (s[Low(string)] = '<')
		or  (s[Low(string)] = '>') then
			begin
			if  not Client.GameHaveSpc then
				ClientMainForm.MemoGame.Lines.Add('');

			ClientMainForm.MemoGame.Lines.Add(s);
			ClientMainForm.MemoGame.Lines.Add('');

			Client.LastGameSpeak:= '';
			Client.GameHaveSpc:= True;
			end
		else
			begin
			w:= s[Low(string)] = '!';

			s:= Copy(s, Low(string) + 1, MaxInt);

			if  not w then
				begin
				p:= Pos(' ', s);
				r:= Copy(s, Low(string), p - Low(string));
				s:= Copy(s, p + 1, MaxInt);
				end;

			p:= Pos(' ', s);
			u:= Copy(s, Low(string), p - Low(string));
			s:= Copy(s, p + 1, MaxInt);

			if  w then
				u:= u + ' whispers';

			if  CompareText(u, Client.LastSpeak) <> 0 then
				begin
				Client.LastGameSpeak:= u;

				ClientMainForm.MemoGame.Lines.Add(u + ':');
				end;

			ClientMainForm.MemoGame.Lines.Add(#9 + s);
			Client.GameHaveSpc:= False;
			end;
		end;
	end;

procedure TClientMainDMod.DoConnect;
    var
	cr: TCursor;

	begin
    cr:= Application.MainForm.Cursor;

	Application.MainForm.Cursor:= crHourGlass;
	try
	    Connection.Connected:= False;
	    Connection.Socket.ConnectionTimeout:= 5000;
	    Connection.Socket.Connect(ClientMainForm.EditHost.Text, '7520');

		if  Assigned(Client.Server) then
			begin
			Client.Server.Free;
			Client.Server:= nil;
			end;

		ClientMainForm.EditHostInfo.Text:= '';

		finally
        Application.MainForm.Cursor:= cr;
		end;
	end;

procedure TClientMainDMod.DoDisconnect;
	begin
	try
    	Connection.Socket.CloseSocket;
		except
		end;

	DoHandleDisconnected;
	end;

constructor TClientMainDMod.Create(AOwner: TComponent);
	begin
	inherited Create(AOwner);

    Connection:= TTCPConnection.Create;
	Client:= TGinClient.Create;

	Connection.Socket.OnAfterConnect:= OnAfterConnect;
	end;

destructor TClientMainDMod.Destroy;
	begin
    Client.Free;
	Connection.Free;

	inherited Destroy;
	end;

procedure TClientMainDMod.ActNavChatExecute(Sender: TObject);
	begin
    if  ClientMainForm.PgctrlChat.ActivePage = ClientMainForm.TbshtRoom then
		ConnectForwardBack(nil, ActNavLobby)
	else
  		ConnectForwardBack(ActNavRoom, nil);

    ClientMainForm.PgctrlMain.ActivePage:= ClientMainForm.TbshtChat;
	ActNavChat.Checked:= True;
	end;

procedure TClientMainDMod.ActHostConnectExecute(Sender: TObject);
	begin
    if  not Connection.Connected then
		begin
        if  Length(ClientMainForm.EditUserName.Text) > 0 then
        	begin
            Client.OurIdent:= ClientMainForm.EditUserName.Text;
			DoConnect;
			end
		else
			ClientMainForm.ActiveControl:= ClientMainForm.EditUserName;
		end;
	end;

procedure TClientMainDMod.ActGameJoinExecute(Sender: TObject);
	begin
    if  not Assigned(Client.Game) then
		if  Length(ClientMainForm.EditGame.Text) > 0 then
			Client.SendGameJoin(Connection,
					AnsiString(ClientMainForm.EditGame.Text),
					AnsiString(ClientMainForm.EditGamePwd.Text))
		else
         	ClientMainForm.ActiveControl:= ClientMainForm.EditGame;
	end;

procedure TClientMainDMod.ActGameListExecute(Sender: TObject);
	begin
    Client.SendGameList(Connection);
	end;

procedure TClientMainDMod.ActGameControlExecute(Sender: TObject);
	begin
	if  Assigned(Client.Game) then
		begin
		if  ActGameControl.Tag = 1 then
            Client.SendGameSlotStatus(Connection, Client.Game.OurSlot,
					psReady)
		else if ActGameControl.Tag = 2 then
            Client.SendGameSlotStatus(Connection, Client.Game.OurSlot,
					psIdle)
		else if ActGameControl.Tag = 3 then
			Client.SendGameDrawCard(Connection, Client.Game.OurSlot,
					False);
		end;
	end;

procedure TClientMainDMod.ActGameBeginExecute(Sender: TObject);
	begin
	Client.SendGameBegin(Connection, Client.Game.OurSlot);
	end;

procedure TClientMainDMod.ActGameDiscardExecute(Sender: TObject);
    var
    i,
    s: TCardIndex;

    begin
    s:= 0;
    for i:= Low(TCardIndex) to High(TCardIndex) do
		if  i in ClientMainForm.CardHandFrame1.Selected then
            begin
            s:= i;
            Break;
            end;

    Client.SendGameDiscard(Connection, Client.Game.OurSlot,
    		ClientMainForm.CardHandFrame1.Cards[s]);
	end;

procedure TClientMainDMod.ActGameDrawDeckExecute(Sender: TObject);
	begin
    Client.SendGameDrawCard(Connection, Client.Game.OurSlot, False);
	end;

procedure TClientMainDMod.ActGameDrawDiscardExecute(Sender: TObject);
	begin
    Client.SendGameDrawCard(Connection, Client.Game.OurSlot, True);
	end;

procedure TClientMainDMod.ActGamePartExecute(Sender: TObject);
	begin
    if  Assigned(Client.Game) then
		Client.SendGamePart(Connection);
	end;

procedure TClientMainDMod.ActHostDisconnectExecute(Sender: TObject);
	begin
    if  Connection.Connected then
		DoDisconnect
	else
		DoHandleDisconnected;
	end;

procedure TClientMainDMod.ActNavConfigureExecute(Sender: TObject);
	begin
    ClientMainForm.PgctrlMain.ActivePage:= ClientMainForm.TbshtConfigure;
	ActNavConfigure.Checked:= True;
	end;

end.

