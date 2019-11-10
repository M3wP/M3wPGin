unit FormClientMain;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
	FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
	FMX.StdCtrls, FMX.Controls.Presentation, FMX.Gestures, System.Actions,
	FMX.ActnList, FMX.ScrollBox, FMX.Memo, IdBaseComponent, IdComponent,
	IdTCPConnection, IdTCPClient, FMX.Edit, FMX.Layouts, FMX.ListBox, System.Rtti,
	FMX.Grid, System.ImageList, FMX.ImgList, FrameCardHand, GinTypes, DModClientMain,
	FMX.Objects, CardTypes;

type
	TGinReflector = class;

	TClientMainForm = class(TForm)
		TbctrlMain: TTabControl;
		TabItem1: TTabItem;
		TbctrlConnect: TTabControl;
		TabItem5: TTabItem;
		ToolBar1: TToolBar;
		lblTitle1: TLabel;
		btnNext: TSpeedButton;
		TabItem6: TTabItem;
		ToolBar2: TToolBar;
		lblTitle2: TLabel;
		btnBack: TSpeedButton;
		TabItem2: TTabItem;
		TabItem3: TTabItem;
		TabItem4: TTabItem;
		ToolBar5: TToolBar;
		lblTitle5: TLabel;
		GestureManager1: TGestureManager;
		Panel1: TPanel;
		MemoHost: TMemo;
		TbctrlChat: TTabControl;
		TabItem7: TTabItem;
		ToolBar3: TToolBar;
		Label4: TLabel;
		SpeedButton1: TSpeedButton;
		Panel2: TPanel;
		TabItem8: TTabItem;
		ToolBar6: TToolBar;
		Label8: TLabel;
		SpeedButton2: TSpeedButton;
    MemoRoomList: TMemo;
		Panel3: TPanel;
		MemoRoom: TMemo;
		Edit5: TEdit;
		SpeedButton3: TSpeedButton;
		PanelUsers: TPanel;
    LstbxRoomUsers: TListBox;
		TbctrlPlay: TTabControl;
		TabItem9: TTabItem;
		ToolBar4: TToolBar;
		Label6: TLabel;
		Panel5: TPanel;
    MemoGameList: TMemo;
    TbitmOverview: TTabItem;
		ToolBar7: TToolBar;
		Label9: TLabel;
		SpeedButton5: TSpeedButton;
		Panel6: TPanel;
		Panel7: TPanel;
		ListBox2: TListBox;
    TbitmDetail: TTabItem;
		ToolBar8: TToolBar;
		Label10: TLabel;
		SpeedButton7: TSpeedButton;
		Panel10: TPanel;
		MemoDebug: TMemo;
		ListBox4: TListBox;
		Label13: TLabel;
    MemoGame: TMemo;
		Label14: TLabel;
    LabelGameRound: TLabel;
		Edit9: TEdit;
		Label16: TLabel;
		Label17: TLabel;
		Button7: TButton;
		ListBoxItem1: TListBoxItem;
		ListBoxItem2: TListBoxItem;
		ListBoxItem3: TListBoxItem;
		ListBoxItem4: TListBoxItem;
		StyleBook1: TStyleBook;
		SpeedButton4: TSpeedButton;
		SpeedButton6: TSpeedButton;
		ActionList1: TActionList;
		NextTabAction1: TNextTabAction;
		PreviousTabAction1: TPreviousTabAction;
		actConnectConnect: TAction;
		actConnectSetName: TAction;
		NextTabAction2: TNextTabAction;
		PreviousTabAction2: TPreviousTabAction;
		NextTabAction3: TNextTabAction;
		actRoomJoin: TAction;
		actRoomSend: TAction;
		actRoomList: TAction;
		actRoomToggleMembers: TAction;
		PreviousTabAction3: TPreviousTabAction;
		actGameJoin: TAction;
		actGameList: TAction;
		actGameControl: TAction;
		NextTabAction4: TNextTabAction;
		PreviousTabAction4: TPreviousTabAction;
		ActConnectDisconnect: TAction;
		imgListZones: TImageList;
		imgLstGamePlayer: TImageList;
		Panel4: TPanel;
		Panel8: TPanel;
		CardHandFrame1: TCardHandFrame;
		TbctrlDeal: TTabControl;
		TbitmDraw: TTabItem;
		TbitmGin: TTabItem;
		Panel9: TPanel;
		Panel11: TPanel;
		ListBox3: TListBox;
		Button2: TButton;
		Image1: TImage;
		Image2: TImage;
		Button8: TButton;
		Button9: TButton;
		Button10: TButton;
		Panel12: TPanel;
		CardHandFrame2: TCardHandFrame;
		ActRoomPart: TAction;
	ActGameDrawDeck: TAction;
	ActGameDrawDiscard: TAction;
	ActGamePart: TAction;
	ActGameBegin: TAction;
	ActGameDiscard: TAction;
	TimerGin: TTimer;
    Panel13: TPanel;
    EditHostName: TEdit;
    Label1: TLabel;
    EditUserName: TEdit;
    Label2: TLabel;
    Button1: TButton;
    BtnHostCntrl: TButton;
    Label3: TLabel;
    EditHostInfo: TEdit;
    Panel14: TPanel;
    Label5: TLabel;
    EditRoom: TEdit;
    Label11: TLabel;
    EditRoomPwd: TEdit;
    ButtonRoomJoin: TButton;
    Button4: TButton;
    Panel15: TPanel;
    Label7: TLabel;
    EditGame: TEdit;
    Label12: TLabel;
    EditGamePwd: TEdit;
    ButtonGameJoin: TButton;
    Button6: TButton;
		procedure GestureDone(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
		procedure FormCreate(Sender: TObject);
		procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
		procedure actConnectConnectExecute(Sender: TObject);
		procedure ActConnectDisconnectExecute(Sender: TObject);
		procedure actRoomToggleMembersExecute(Sender: TObject);
	procedure TimerGinTimer(Sender: TObject);
	procedure actGameJoinExecute(Sender: TObject);
	procedure ActGamePartExecute(Sender: TObject);
	procedure actGameControlExecute(Sender: TObject);
	procedure ActGameDrawDeckExecute(Sender: TObject);
	procedure ActGameDrawDiscardExecute(Sender: TObject);
	procedure ActGameDiscardExecute(Sender: TObject);
	procedure ActGameBeginExecute(Sender: TObject);
	procedure Image1Gesture(Sender: TObject; const EventInfo: TGestureEventInfo;
	  var Handled: Boolean);
	procedure Image2Gesture(Sender: TObject; const EventInfo: TGestureEventInfo;
	  var Handled: Boolean);
	private
		FRefelector: TGinReflector;
		FDiscardThis,
		FDiscardLast: TCardIndex;
	protected
		procedure HandOnSelect(ASender: TObject);
		procedure HandOnFlickCard(ACard: TCardIndex);
	public
		procedure AddGameInfo(AMessage: string);
	end;

	TGinReflector = class(TMessageReflector)
	protected
		FForm: TClientMainForm;

		procedure MsgUpdateHost(AWParam, ALParam: IntPtr);
		procedure MsgUpdateIdent(AWParam, ALParam: IntPtr);
		procedure MsgUpdateRoomList(AWParam, ALParam: IntPtr);
		procedure MsgUpdateRoom(AWParam, ALParam: IntPtr);
		procedure MsgUpdateRoomUsers(AWParam, ALParam: IntPtr);
		procedure MsgUpdateSlotState(AWParam, ALParam: IntPtr);
		procedure MsgUpdateGameList(AWParam, ALParam: IntPtr);
		procedure MsgUpdateOurState(AWParam, ALParam: IntPtr);
		procedure MsgUpdateGame(AWParam, ALParam: IntPtr);
		procedure MsgUpdateNewDeal(AWParam, ALParam: IntPtr);
		procedure MsgUpdateDrawCard(AWParam, ALParam: IntPtr);
		procedure MsgUpdateDrawInfo(AWParam, ALParam: IntPtr);
		procedure MsgUpdateDiscard(AWParam, ALParam: IntPtr);
		procedure MsgUpdateShuffled(AWParam, ALParam: IntPtr);
		procedure MsgUpdateNewFirst(AWParam, ALParam: IntPtr);
		procedure MsgUpdateHaveGin(AWParam, ALParam: IntPtr);
		procedure MsgUpdateBeginNew(AWParam, ALParam: IntPtr);

	public
		procedure SendMessage(const AMessage:Cardinal; AWParam, ALParam: IntPtr); override;
	end;


var
	ClientMainForm: TClientMainForm;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiTb.fmx ANDROID}
{$R *.XLgXhdpiTb.fmx ANDROID}

uses
{$IFDEF ANDROID}
	ORawByteString,
{$ENDIF}
	FMX.Platform,
	System.Devices,
	TCPTypes, CardClasses, GinClasses, GinClient;

procedure TClientMainForm.actConnectConnectExecute(Sender: TObject);
	begin
	if  not Connection.Connected then
		begin
		if  Length(ClientMainForm.EditUserName.Text) > 0 then
			begin
			Client.OurIdent:= AnsiString(ClientMainForm.EditUserName.Text);
			ClientMainDMod.DoConnect;
			end
		else
			ClientMainForm.ActiveControl:= ClientMainForm.EditUserName;
		end;
	end;

procedure TClientMainForm.ActConnectDisconnectExecute(Sender: TObject);
	begin
	if  Connection.Connected then
		ClientMainDMod.DoDisconnect
	else
		ClientMainDMod.DoHandleDisconnected;
	end;

procedure TClientMainForm.ActGameBeginExecute(Sender: TObject);
	begin
	Client.SendGameBegin(Connection, Client.Game.OurSlot);
	end;

procedure TClientMainForm.actGameControlExecute(Sender: TObject);
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

procedure TClientMainForm.ActGameDiscardExecute(Sender: TObject);
	var
	i,
	s: TCardIndex;

	begin
	s:= 0;
	for i:= Low(TCardIndex) to High(TCardIndex) do
		if  i in CardHandFrame1.Selected then
			begin
			s:= i;
			Break;
			end;

	Client.SendGameDiscard(Connection, Client.Game.OurSlot, CardHandFrame1.Cards[s]);
	end;

procedure TClientMainForm.ActGameDrawDeckExecute(Sender: TObject);
	begin
	Client.SendGameDrawCard(Connection, Client.Game.OurSlot, False);
	end;

procedure TClientMainForm.ActGameDrawDiscardExecute(Sender: TObject);
	begin
	Client.SendGameDrawCard(Connection, Client.Game.OurSlot, True);
	end;

procedure TClientMainForm.actGameJoinExecute(Sender: TObject);
	begin
	if  not Assigned(Client.Game) then
		if  Length(EditGame.Text) > 0 then
			Client.SendGameJoin(Connection,
					AnsiString(EditGame.Text),
					AnsiString(EditGamePwd.Text))
		else
			ActiveControl:= EditGame;
	end;

procedure TClientMainForm.ActGamePartExecute(Sender: TObject);
	begin
	if  Assigned(Client.Game) then
		Client.SendGamePart(Connection);
	end;

procedure TClientMainForm.actRoomToggleMembersExecute(Sender: TObject);
	begin
	PanelUsers.Visible:= not PanelUsers.Visible;
	end;

procedure TClientMainForm.AddGameInfo(AMessage: string);
	begin
	ListBox3.Items.Insert(0, AMessage);
	end;

procedure TClientMainForm.FormCreate(Sender: TObject);
	var
	sz: TPointF;
	dc: TDeviceInfo.TDeviceClass;
	cs: TCardImageSize;
	ds: IFMXDeviceService;

	begin
	FRefelector:= TGinReflector.Create;
	FRefelector.FForm:= Self;

	Client.Reflector:= FRefelector;

	{ This defines the default active tab at runtime }
	TbctrlMain.ActiveTab := TabItem1;

	cs:= TCardImageSize.cisSmall;

	TPlatformServices.Current.SupportsPlatformService(IFMXDeviceService, ds);

{$IFDEF ANDROID}
	if Assigned(ds) then
		begin
		dc:= ds.GetDeviceClass;

		if  dc = TDeviceInfo.TDeviceClass.Tablet then
			cs:= TCardImageSize.cisMedium;
		end;

{$ELSE}
	TabItem1.StyleLookup:= 'TabItem1Style1';
	TabItem2.StyleLookup:= 'TabItem1Style1';
	TabItem3.StyleLookup:= 'TabItem1Style1';
	TabItem4.StyleLookup:= 'TabItem1Style1';

{$ENDIF}

	sz:= InitialiseCardGraphics(cs);

	Image1.Width:= sz.x;
	Image1.Height:= sz.y;
	Image2.Width:= sz.x;
	Image2.Height:= sz.y;

	CardHandFrame1.InitDeckSize(sz);
	CardHandFrame1.AllowChange:= True;
	CardHandFrame1.OnSelect:= HandOnSelect;
    CardHandFrame1.OnFlickCard:= HandOnFlickCard;

	CardHandFrame2.InitDeckSize(sz);
	CardHandFrame2.AllowChange:= False;

	FDiscardThis:= High(TCardIndex);
	FDiscardLast:= High(TCardIndex);

	Image1.Bitmap.Assign(CardGraphics[Low(TCardIndex)]);
	Image2.Bitmap.Assign(CardGraphics[FDiscardThis]);
	end;

procedure TClientMainForm.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
	begin
	if Key = vkHardwareBack then
		begin
		if  (TbctrlMain.ActiveTab = TabItem1)
		and (TbctrlConnect.ActiveTab = TabItem6) then
			begin
			TbctrlConnect.Previous;
			Key := 0;
			end;
		end;
	end;

procedure TClientMainForm.GestureDone(Sender: TObject;
		const EventInfo: TGestureEventInfo; var Handled: Boolean);
	begin
	case EventInfo.GestureID of
		sgiLeft:
			begin
			if 	TbctrlMain.ActiveTab <> TbctrlMain.Tabs[TbctrlMain.TabCount - 1] then
				TbctrlMain.ActiveTab := TbctrlMain.Tabs[TbctrlMain.TabIndex + 1];
			Handled := True;
			end;

		sgiRight:
			begin
			if  TbctrlMain.ActiveTab <> TbctrlMain.Tabs[0] then
				TbctrlMain.ActiveTab := TbctrlMain.Tabs[TbctrlMain.TabIndex - 1];
			Handled := True;
			end;
		end;
	end;

procedure TClientMainForm.HandOnFlickCard(ACard: TCardIndex);
	begin
	Client.SendGameDiscard(Connection, Client.Game.OurSlot,
			CardHandFrame1.Cards[ACard]);
	end;

procedure TClientMainForm.HandOnSelect(ASender: TObject);
    var
	i: Integer;
	s,
	e: Integer;

	begin
	ActGameDiscard.Enabled:= (CardHandFrame1.SelCount = 1) and
			(CardHandFrame1.CardCount = 11);

    if  CardHandFrame1.SelCount = 2 then
		begin
        s:= -1;
		e:= -1;

		for i:= 0 to CardHandFrame1.CardCount - 1 do
			if  i in CardHandFrame1.Selected then
				if  s = -1 then
					s:= i
				else
					e:= i;

		CardHandFrame1.ClearSelection;
		CardHandFrame1.SwapCards(s, e);
		end;
	end;

procedure TClientMainForm.Image1Gesture(Sender: TObject;
		const EventInfo: TGestureEventInfo; var Handled: Boolean);
	begin
	if  EventInfo.GestureID = sgiDown then
		begin
		Handled:= True;
		ActGameDrawDeck.Execute;
		end;
	end;

procedure TClientMainForm.Image2Gesture(Sender: TObject;
		const EventInfo: TGestureEventInfo; var Handled: Boolean);
	begin
	if  EventInfo.GestureID = sgiDown then
		begin
		Handled:= True;
		ActGameDrawDiscard.Execute;
		end;
	end;

procedure TClientMainForm.TimerGinTimer(Sender: TObject);
	begin
	if  CardHandFrame1.SelCount > 0 then
		begin
		CardHandFrame1.SetSelected(TimerGIN.Tag, False);
		TimerGIN.Tag:= TimerGIN.Tag + 1;
		if  TimerGIN.Tag = CardHandFrame1.CardCount then
			TimerGIN.Tag:= 0;
		end
	else
		CardHandFrame1.SetSelected(TimerGIN.Tag, True);
	end;

{ TGinReflector }

procedure TGinReflector.MsgUpdateBeginNew(AWParam, ALParam: IntPtr);
	begin
	if  ALParam = Client.Game.OurSlot then
		begin
		FForm.ActGameDrawDeck.Enabled:= True;
		FForm.ActGameDrawDiscard.Enabled:= True;
		end;

	FForm.ActGameBegin.Enabled:= False;
	FForm.ActGameDiscard.Enabled:= False;
	FForm.TimerGIN.Enabled:= False;

	FForm.CardHandFrame1.ClearCards;

	FForm.TbctrlDeal.ActiveTab:= FForm.TbitmDraw;

	FForm.AddGameInfo(IntToStr(ALParam + 1) + 'P begins round');
	end;

procedure TGinReflector.MsgUpdateDiscard(AWParam, ALParam: IntPtr);
    var
    s,
    i: TCardIndex;

    begin
	if  AWParam = $FF then
		begin
		FForm.FDiscardLast:= High(TCardIndex);
		FForm.FDiscardThis:= ALParam;
		end
	else
		begin
		FForm.FDiscardLast:= FForm.FDiscardThis;
		FForm.FDiscardThis:= ALParam;

		if  AWParam = Client.Game.OurSlot then
			begin
			i:= 0;
			for s:= 0 to FForm.CardHandFrame1.CardCount - 1 do
				if  FForm.CardHandFrame1.Cards[s] = FForm.FDiscardThis then
					begin
					i:= s;
					Break;
					end;

			FForm.CardHandFrame1.DeleteCard(i);

			Client.Game.Drawn:= False;

			FForm.AddGameInfo('You discard ' + CardIndexToText(ALParam));
			end
		else
			FForm.AddGameInfo(IntToStr(AWParam + 1) + 'P discards ' +
					CardIndexToText(ALParam));
		end;

	FForm.Image2.Bitmap.Assign(CardGraphics[FForm.FDiscardThis]);
	end;

procedure TGinReflector.MsgUpdateDrawCard(AWParam, ALParam: IntPtr);
	var
    cs: string;

    begin
	FForm.CardHandFrame1.AddCard(AWParam);

	if  Client.Game.Drawn then
		begin
		FForm.ActGameDrawDeck.Enabled:= False;
		FForm.ActGameDrawDiscard.Enabled:= False;
		end;

	if  ALParam > 0 then
		begin
		FForm.FDiscardThis:= FForm.FDiscardLast;
		FForm.FDiscardLast:= High(TCardIndex);
		FForm.Image2.Bitmap.Assign(CardGraphics[FForm.FDiscardThis]);
		end;

	if  ALParam = 0 then
		cs:= 'Deck'
	else
		cs:= 'Discard';

	FForm.AddGameInfo('You draw from ' + cs);
	end;

procedure TGinReflector.MsgUpdateDrawInfo(AWParam, ALParam: IntPtr);
	var
	si: Integer;
	cs: string;

	begin
	if  ALParam = 0 then
		cs:= 'Deck'
	else
		cs:= 'Discard';

	si:= AWParam;

	FForm.AddGameInfo(IntToStr(si + 1) + 'P draws from ' + cs);

	if  ALParam > 0 then
		begin
		FForm.FDiscardThis:= FForm.FDiscardLast;
		FForm.FDiscardLast:= High(TCardIndex);
		FForm.Image2.Bitmap.Assign(CardGraphics[FForm.FDiscardThis]);
		end;
	end;

procedure TGinReflector.MsgUpdateGame(AWParam, ALParam: IntPtr);
	begin
	if  ALParam = 0 then
		begin
		FForm.EditGame.Enabled:= True;
		FForm.EditGamePwd.Enabled:= True;
		FForm.ButtonGameJoin.Action:= FForm.ActGameJoin;

		if  FForm.TbctrlPlay.ActiveTab = FForm.TbitmDetail then
			FForm.TbctrlPlay.ActiveTab:= FForm.TbitmOverview;

		FForm.TimerGin.Enabled:= False;
		end
	else
		begin
		FForm.EditGame.Text:= string(Client.Game.Ident);

		FForm.EditGame.Enabled:= False;
		FForm.EditGamePwd.Enabled:= False;
		FForm.ButtonGameJoin.Action:= FForm.ActGamePart;

		FForm.CardHandFrame1.ClearCards;
		FForm.CardHandFrame2.ClearCards;

		FForm.TbctrlDeal.ActiveTab:= FForm.TbitmDraw;
		end;
	end;

procedure TGinReflector.MsgUpdateGameList(AWParam, ALParam: IntPtr);
	begin
	if  ALParam = 0 then
		FForm.MemoGameList.Lines.Clear
	else
		FForm.MemoGameList.Lines.Add(PString(AWParam)^);
	end;

procedure TGinReflector.MsgUpdateHaveGin(AWParam, ALParam: IntPtr);
	var
	i: Integer;

	begin
	FForm.ActGameDrawDeck.Enabled:= False;
	FForm.ActGameDrawDiscard.Enabled:= False;
	FForm.ActGameDiscard.Enabled:= False;

	FForm.CardHandFrame1.ClearSelection;

	FForm.AddGameInfo(IntToStr(ALParam + 1) + 'P has GIN!!!');

	if  ALParam = Client.Game.OurSlot then
		begin
		FForm.CardHandFrame1.SetSelected(0, True);

		FForm.TimerGIN.Tag:= 0;
		FForm.TimerGIN.Enabled:= True;
		end
	else
		begin
		FForm.CardHandFrame2.ClearCards;

		for i:= 0 to 9 do
			FForm.CardHandFrame2.AddCard(Client.Game.GinCards[i]);

		FForm.TbctrlDeal.ActiveTab:= FForm.TbitmGin;
		end;
	end;

procedure TGinReflector.MsgUpdateHost(AWParam, ALParam: IntPtr);
	begin
	if  Assigned(Client.Server) then
		FForm.EditHostInfo.Text:= string(Client.Server.Name) + ' ' +
				string(Client.Server.Host) + ' ' +
				string(Client.Server.Version)
	else
		FForm.EditHostInfo.Text:= '';
	end;

procedure TGinReflector.MsgUpdateIdent(AWParam, ALParam: IntPtr);
	begin
	FForm.EditUserName.Text:= string(Client.OurIdent);
	end;

procedure TGinReflector.MsgUpdateNewDeal(AWParam, ALParam: IntPtr);
	begin
	FForm.ActGameBegin.Enabled:= False;

	FForm.ListBox3.Items.Clear;
	FForm.AddGameInfo('A hand was dealt');
	end;

procedure TGinReflector.MsgUpdateNewFirst(AWParam, ALParam: IntPtr);
	begin
	FForm.ActGameBegin.Enabled:= ALParam = Client.Game.OurSlot;
	end;

procedure TGinReflector.MsgUpdateOurState(AWParam, ALParam: IntPtr);
	begin
	AddLogMessage(slkDebug, 'UpdateOurState.');

    if  Assigned(Client.Game) then
		begin
		if  Client.Game.State > gsPreparing then
			FForm.LabelGameRound.Text:= IntToSTr(Client.Game.Round)
		else if Client.Game.State = gsWaiting then
			FForm.LabelGameRound.Text:= 'Waiting for all Ready...'
		else
			FForm.LabelGameRound.Text:= 'Waiting for all Draw First...';

		if  Client.Game.State = gsPlaying then
			begin
			FForm.ActGameControl.Tag:= 4;
			FForm.ActGameControl.Caption:= 'Playing';

			FForm.ActGameDrawDeck.Enabled:=
					(Client.Game.Slots[Client.Game.OurSlot].State = psPlaying) and
					(not Client.Game.Drawn);

			FForm.ActGameDrawDiscard.Enabled:=
					FForm.ActGameDrawDeck.Enabled;

			end
		else if  (Client.Game.OurSlot = -1)
		or  (Client.Game.Slots[Client.Game.OurSlot].State in [psNone, psWaiting]) then
			begin
			FForm.ActGameControl.Tag:= 0;
			FForm.ActGameControl.Caption:= 'Waiting';
			end
		else if Client.Game.Slots[
				Client.Game.OurSlot].State = psIdle then
			begin
			FForm.ActGameControl.Tag:= 1;
			FForm.ActGameControl.Caption:= 'Ready';
			end
		else if Client.Game.Slots[Client.Game.OurSlot].State = psReady then
			begin
			FForm.ActGameControl.Tag:= 2;
			FForm.ActGameControl.Caption:= 'Not Ready';
			end
		else if Client.Game.Slots[
				Client.Game.OurSlot].State = psPreparing then
			begin
			FForm.ActGameControl.Tag:= 3;
			FForm.ActGameControl.Caption:= 'Draw for First';
			end
		end
	else
		begin
//TODO
		end;
	end;

procedure TGinReflector.MsgUpdateRoom(AWParam, ALParam: IntPtr);
	begin
	if  ALParam = 0 then
		begin
		FForm.EditRoom.Enabled:= True;
		FForm.EditRoomPwd.Enabled:= True;
		FForm.ButtonRoomJoin.Action:= FForm.ActRoomJoin;

		FForm.LstbxRoomUsers.Clear;
		end
	else
		begin
		FForm.EditRoom.Text:= string(Client.Room);

		FForm.EditRoom.Enabled:= False;
		FForm.EditRoomPwd.Enabled:= False;
		FForm.ButtonRoomJoin.Action:= FForm.ActRoomPart;
		end;
	end;

procedure TGinReflector.MsgUpdateRoomList(AWParam, ALParam: IntPtr);
	begin
	if  ALParam = 0 then
		FForm.MemoRoomList.Lines.Clear
	else
		FForm.MemoRoomList.Lines.Add(PString(AWParam)^);
	end;

procedure TGinReflector.MsgUpdateRoomUsers(AWParam, ALParam: IntPtr);
    var
	i: Integer;
	s: string;

	begin
	if  ALParam = 0 then
		FForm.LstbxRoomUsers.Clear
	else if ALParam = 1 then
		begin
		s:= PString(AWParam)^;
		i:= FForm.LstbxRoomUsers.Items.IndexOf(s);
		if  i = -1 then
			FForm.LstbxRoomUsers.Items.Add(s);
		end
	else
		begin
		s:= PString(AWParam)^;
		i:= FForm.LstbxRoomUsers.Items.IndexOf(s);
		if  i > -1 then
			FForm.LstbxRoomUsers.Items.Delete(i);
		end;
	end;

procedure TGinReflector.MsgUpdateShuffled(AWParam, ALParam: IntPtr);
	begin
    FForm.AddGameInfo('Discard was shuffled');
	end;

procedure TGinReflector.MsgUpdateSlotState(AWParam, ALParam: IntPtr);
    var
	s,
	i: Integer;
	n,
	v: string;
	itm: TListBoxItem;

	begin
	itm:= nil;

	case ALParam of
		0:
			itm:= FForm.ListBoxItem1;
		1:
			itm:= FForm.ListBoxItem2;
		2:
			itm:= FForm.ListBoxItem3;
		3:
			itm:= FForm.ListBoxItem4;
		end;

	if  not Assigned(itm) then
		Exit;

	if  Assigned(Client.Game) then
		begin
		s:= ALParam;

		i:= Ord(Client.Game.Slots[s].State);

		if  Client.Game.Slots[s].State > psNone then
			n:= string(Client.Game.Slots[s].Name)
		else
			n:= '';

		case Client.Game.Slots[s].State of
			psNone:
				if  Client.Game.State >= gsPreparing then
					v:= ''
				else
					v:= 'Available...';
			psIdle:
				v:= 'Not Ready...';
			psReady:
				v:= 'Waiting for all Ready';
			psPreparing:
				v:= 'Waiting for First Draw';
			psWaiting..psWinner:
				if  (Client.Game.Slots[s].State = psWaiting)
				and (Client.Game.Round = 0) then
					v:= 'Drew:  ' + CardIndexToText(
							Client.Game.Slots[s].FirstCard)
				else
					v:= 'Score:  ' +
							IntToStr(Client.Game.Slots[s].Score);
			else
				v:= '';
			end;
		end
	else
		begin
		i:= 0;
		n:= 'No Game!';
		v:= 'Start a game.';
		end;

	itm.ImageIndex:= i;
	itm.ItemData.Text:= n;
	itm.ItemData.Detail:= v;
	end;

procedure TGinReflector.SendMessage(const AMessage: Cardinal; AWParam,
		ALParam: IntPtr);
	begin
	case AMessage of
		YCM_UPDATEHOST:
			MsgUpdateHost(AWParam, ALParam);
		YCM_UPDATEIDENT:
			MsgUpdateIdent(AWParam, ALParam);
		YCM_UPDATEROOMLIST:
			MsgUpdateRoomList(AWParam, ALParam);
		YCM_UPDATEROOMUSERS:
			MsgUpdateRoomUsers(AWParam, ALParam);
		YCM_UPDATEGAMELIST:
			MsgUpdateGameList(AWParam, ALParam);
		YCM_UPDATESLOTSTATE:
			MsgUpdateSlotState(AWParam, ALParam);
		YCM_UPDATEROOM:
			MsgUpdateRoom(AWParam, ALParam);
		YCM_UPDATEGAME:
			MsgUpdateGame(AWParam, ALParam);
		YCM_UPDATEOURSTATE:
			MsgUpdateOurState(AWParam, ALParam);
		YCM_UPDATENEWDEAL:
			MsgUpdateNewDeal(AWParam, ALParam);
		YCM_UPDATESHUFFLED:
			MsgUpdateShuffled(AWParam, ALParam);
		YCM_UPDATENEWFIRST:
			MsgUpdateNewFirst(AWParam, ALParam);
		YCM_UPDATEDRAWCARD:
			MsgUpdateDrawCard(AWParam, ALParam);
		YCM_UPDATEDRAWINFO:
			MsgUpdateDrawInfo(AWParam, ALParam);
		YCM_UPDATEDISCARD:
			MsgUpdateDiscard(AWParam, ALParam);
		YCM_UPDATEHAVEGIN:
			MsgUpdateHaveGin(AWParam, ALParam);
		YCM_UPDATEBEGINNEW:
			MsgUpdateBeginNew(AWParam, ALParam);
		end;
	end;

end.

