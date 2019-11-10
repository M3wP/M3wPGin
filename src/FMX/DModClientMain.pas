unit DModClientMain;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, System.ImageList, FMX.ImgList,
  FMX.ActnList, FMX.TabControl, System.Actions;

type
	TClientMainDMod = class(TDataModule)
		TimerMain: TTimer;
		procedure DataModuleCreate(Sender: TObject);
		procedure TimerMainTimer(Sender: TObject);
	private
		procedure OnConnectionConnected(ASender: TObject);
		procedure OnConnectionDisconnected(ASender: TObject);


		procedure ProcessRoomLogMessages;
		procedure ProcessGameLogMessages;

	protected
	public
		procedure DoHandleDisconnected;

		procedure DoConnect;
		procedure DoDisconnect;
	end;

var
	ClientMainDMod: TClientMainDMod;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
{$IFDEF ANDROID}
	ORawByteString,
{$ENDIF}
	FMX.Forms, System.UITypes, TCPTypes, GinClient, FormClientMain;

procedure TClientMainDMod.DataModuleCreate(Sender: TObject);
	begin
	Connection:= TTCPConnection.Create;
	Client:= TGinClient.Create;

	Connection.OnConnected:= OnConnectionConnected;
	Connection.OnDisconnected:= OnConnectionDisconnected;
	end;

procedure TClientMainDMod.DoConnect;
	var
	cr: TCursor;

	begin
	cr:= ClientMainForm.Cursor;

	ClientMainForm.Cursor:= crHourGlass;
	try
		Connection.Connected:= False;

		if  Assigned(Client.Server) then
			begin
			Client.Server.Free;
			Client.Server:= nil;
			end;

		ClientMainForm.EditHostInfo.Text:= '';

		Connection.Socket.ConnectTimeout:= 5000;
		Connection.Socket.Host:= ClientMainForm.EditHostName.Text;
		Connection.Socket.Port:= 7520;

		try
			Connection.Socket.Connect;

			except

			end;

		finally
		ClientMainForm.Cursor:= cr;
		end;
	end;

procedure TClientMainDMod.DoDisconnect;
	begin
	try
		Connection.Socket.Socket.CloseGracefully;

		except
		end;

	Connection.Connected:= False;

	DoHandleDisconnected;
	end;

procedure TClientMainDMod.DoHandleDisconnected;
	begin
	Connection.Connected:= False;
	Connection.Purge;

	ClientMainForm.BtnHostCntrl.Action:= ClientMainForm.ActConnectConnect;
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

procedure TClientMainDMod.OnConnectionConnected(ASender: TObject);
	begin
	ClientMainForm.BtnHostCntrl.Action:= ClientMainForm.ActConnectDisconnect;

	AddLogMessage(slkInfo, 'Client connected...');

	HostLogMessages.Add('! Connected to host.');
	HostLogMessages.Add('');
	end;

procedure TClientMainDMod.OnConnectionDisconnected(ASender: TObject);
	begin
	DoHandleDisconnected;
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

			Client.LastGameSpeak:= AnsiString('');
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

			if  CompareText(u, string(Client.LastSpeak)) <> 0 then
				begin
				Client.LastGameSpeak:= AnsiString(u);

				ClientMainForm.MemoGame.Lines.Add(u + ':');
				end;

			ClientMainForm.MemoGame.Lines.Add(#9 + s);
			Client.GameHaveSpc:= False;
			end;
		end;
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

			Client.LastSpeak:= AnsiString('');
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

			if  CompareText(u, string(Client.LastSpeak)) <> 0 then
				begin
				Client.LastSpeak:= AnsiString(u);

				ClientMainForm.MemoRoom.Lines.Add(u + ':');
				end;

			ClientMainForm.MemoRoom.Lines.Add(#9 + s);
			Client.RoomHaveSpc:= False;
			end;
		end;
	end;

procedure TClientMainDMod.TimerMainTimer(Sender: TObject);
	var
	i: Integer;
	buf: TMsgData;

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

	ClientMainForm.MemoDebug.ScrollBy(0, MaxInt, False);

	while  HostLogMessages.Count > 0 do
		begin
		ClientMainForm.MemoHost.Lines.Add(HostLogMessages[0]);
		HostLogMessages.Delete(0);
		end;

	ClientMainForm.MemoHost.ScrollBy(0, MaxInt, False);

	ProcessRoomLogMessages;
	ProcessGameLogMessages;

	if  Connection.Connected then
		begin
		SetLength(buf, 0);

		i:= Connection.PrepareRead(buf);

		if  i < 0 then
			DoDisconnect
		else
			begin
			if  i > 0 then
				if  not Client.ReadConnectionData(Connection, buf, i) then
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

end.
