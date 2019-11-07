unit FormClientMain;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}
{$H+}


interface

uses
	Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
	Dialogs, ComCtrls, ExtCtrls, StdCtrls, Buttons, LMessages, Grids, Types,
	CardTypes, GinClient, DModClientMain, FrameCardHand;

type

	{ TClientMainForm }
	TClientMainForm = class(TForm)
		Button1: TButton;
		BtnHostCntrl: TButton;
		Button2: TButton;
		Button4: TButton;
		Button5: TButton;
		Button6: TButton;
		Button7: TButton;
		Button8: TButton;
		ButtonRoomJoin: TButton;
		Button3: TButton;
		ButtonGameJoin: TButton;
		CardHandFrame1: TCardHandFrame;
		CardHandFrame2: TCardHandFrame;
		DrawGrid1: TDrawGrid;
		EditGame: TEdit;
		EditGamePwd: TEdit;
		EditRoomText: TEdit;
		EditRoomPwd: TEdit;
		EditHost: TEdit;
		EditRoom: TEdit;
		EditGameText: TEdit;
		EditUserName: TEdit;
		EditHostInfo: TEdit;
		Image1: TImage;
		Image2: TImage;
		Label1: TLabel;
		Label10: TLabel;
		Label11: TLabel;
		Label12: TLabel;
		Label13: TLabel;
		Label14: TLabel;
		Label15: TLabel;
		Label16: TLabel;
		Label17: TLabel;
		Label18: TLabel;
		Label19: TLabel;
		Label2: TLabel;
		Label20: TLabel;
		Label21: TLabel;
        Label25: TLabel;
        Label26: TLabel;
		LabelGameRound: TLabel;
		Label22: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		Label7: TLabel;
		Label8: TLabel;
		Label9: TLabel;
		ListBox1: TListBox;
		LstbxRoomUsers: TListBox;
		MemoRoom: TMemo;
		MemoGame: TMemo;
		MemoRoomList: TMemo;
		MemoDebug: TMemo;
		MemoHost: TMemo;
		MemoGameList: TMemo;
		Panel10: TPanel;
		Panel11: TPanel;
		Panel12: TPanel;
		Panel13: TPanel;
		Panel14: TPanel;
		Panel15: TPanel;
		Panel16: TPanel;
		Panel17: TPanel;
		Panel18: TPanel;
		Panel4: TPanel;
		Panel5: TPanel;
		Panel6: TPanel;
		Panel7: TPanel;
		Panel8: TPanel;
		Panel9: TPanel;
		PanelRoomUsers: TPanel;
		PgctrlChat: TPageControl;
		PgctrlDeal: TPageControl;
		PgctrlPlay: TPageControl;
		PgctrlMain: TPageControl;
		PgctrlConnect: TPageControl;
		Panel1: TPanel;
		Panel2: TPanel;
		Panel3: TPanel;
		TbshtGin: TTabSheet;
		TbshtDetail: TTabSheet;
		TbshtDraw: TTabSheet;
		TbshtLobby: TTabSheet;
		TbshtStart: TTabSheet;
		TbshtRoom: TTabSheet;
		TbshtConnect: TTabSheet;
		TbshtChat: TTabSheet;
		TbshtPlay: TTabSheet;
		TbshtConfigure: TTabSheet;
		TbshtHost: TTabSheet;
		TbshtDebug: TTabSheet;
		TbshtOverview: TTabSheet;
		TlbrMain: TToolBar;
		ToolBar2: TToolBar;
		ToolBar3: TToolBar;
		ToolBar4: TToolBar;
		ToolBar5: TToolBar;
		ToolBar6: TToolBar;
		ToolBar7: TToolBar;
		ToolBar8: TToolBar;
		ToolButton1: TToolButton;
		ToolButton10: TToolButton;
		ToolButton11: TToolButton;
		ToolButton12: TToolButton;
		ToolButton13: TToolButton;
		ToolButton2: TToolButton;
		ToolButton3: TToolButton;
		ToolButton4: TToolButton;
		ToolButton5: TToolButton;
		ToolButton6: TToolButton;
		ToolButton7: TToolButton;
		ToolButton8: TToolButton;
		ToolButton9: TToolButton;
  		procedure DrawGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
				aRect: TRect; aState: TGridDrawState);
  		procedure EditRoomTextKeyPress(Sender: TObject; var Key: char);
		procedure FormCreate(Sender: TObject);
  		procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
	private
        FDiscardLast,
        FDiscardThis: TCardIndex;

        procedure AddGameInfo(const AString: string);

	protected
		procedure HandOnSelect(ASender: TObject);

        procedure MsgUpdateHost(var AMessage: TLMessage); message YCM_UPDATEHOST;
        procedure MsgUpdateIdent(var AMessage: TLMessage); message YCM_UPDATEIDENT;
		procedure MsgUpdateRoomList(var AMessage: TLMessage); message YCM_UPDATEROOMLIST;
		procedure MsgUpdateRoom(var AMessage: TLMessage); message YCM_UPDATEROOM;
		procedure MsgUpdateRoomUsers(var AMessage: TLMessage); message YCM_UPDATEROOMUSERS;
		procedure MsgUpdateSlotState(var AMessage: TLMessage); message YCM_UPDATESLOTSTATE;
		procedure MsgUpdateGameList(var AMessage: TLMessage); message YCM_UPDATEGAMELIST;
		procedure MsgUpdateOurState(var AMessage: TLMessage); message YCM_UPDATEOURSTATE;
		procedure MsgUpdateGame(var AMessage: TLMessage); message YCM_UPDATEGAME;
        procedure MsgUpdateNewDeal(var AMessage: TLMessage); message YCM_UPDATENEWDEAL;
		procedure MsgUpdateDrawCard(var AMessage: TLMessage); message YCM_UPDATEDRAWCARD;
        procedure MsgUpdateDrawInfo(var AMessage: TLMessage); message YCM_UPDATEDRAWINFO;
        procedure MsgUpdateDiscard(var AMessage: TLMessage); message YCM_UPDATEDISCARD;
        procedure MsgUpdateShuffled(var AMessage: TLMessage); message YCM_UPDATESHUFFLED;
        procedure MsgUpdateNewFirst(var AMessage: TLMessage); message YCM_UPDATENEWFIRST;
        procedure MsgUpdateHaveGin(var AMessage: TLMessage); message YCM_UPDATEHAVEGIN;
        procedure MsgUpdateBeginNew(var AMessage: TLMessage); message YCM_UPDATEBEGINNEW;

	public

	end;

var
	ClientMainForm: TClientMainForm;

implementation

{$R *.lfm}

uses
	LCLIntf, TCPTypes, CardClasses, GinClasses;


{ TClientMainForm }

procedure TClientMainForm.FormKeyDown(Sender: TObject; var Key: Word;
		Shift: TShiftState);
    var
	lmkey: TLMKey;

	begin
    lmkey.CharCode:= Key;
	lmkey.KeyData:= 0;

	ClientMainDMod.ActlstNavigate.IsShortCut(lmkey);
	end;

procedure TClientMainForm.AddGameInfo(const AString: string);
	begin
    ListBox1.Items.Insert(0, AString);
	end;


procedure TClientMainForm.HandOnSelect(ASender: TObject);
    var
	i: Integer;
	s,
	e: Integer;

	begin
    ClientMainDMod.ActGameDiscard.Enabled:= (CardHandFrame1.SelCount = 1)
    		and (CardHandFrame1.CardCount = 11);

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

procedure TClientMainForm.EditRoomTextKeyPress(Sender: TObject; var Key: char);
	begin
    if  Key = #13 then
		begin
		ClientMainDMod.ActRoomMsg.Execute;
		Key:= #0;
		end;
	end;

procedure TClientMainForm.FormCreate(Sender: TObject);
    var
	sz: TPoint;

	begin
    sz:= InitialiseCardGraphics(cisDefault);

	Image1.Width:= sz.x;
	Image1.Height:= sz.y;
	Image2.Width:= sz.x;
	Image2.Height:= sz.y;

    CardHandFrame1.InitDeckSize(sz);
	CardHandFrame1.OnSelect:= HandOnSelect;
    CardHandFrame1.AllowChange:= True;

    CardHandFrame2.InitDeckSize(sz);
    CardHandFrame2.AllowChange:= False;

    FDiscardThis:= High(TCardIndex);
    FDiscardLast:= High(TCardIndex);

 	Image1.Picture.Assign(CardGraphics[Low(TCardIndex)]);
 	Image2.Picture.Assign(CardGraphics[FDiscardThis]);
	end;

procedure TClientMainForm.DrawGrid1DrawCell(Sender: TObject; aCol,
		aRow: Integer; aRect: TRect; aState: TGridDrawState);
    var
	s,
	i: Integer;
	n,
	v: string;

	begin
	if  Assigned(ClientMainDMod.Client.Game) then
		begin
        s:= ACol;

    	i:= Ord(ClientMainDMod.Client.Game.Slots[s].State);
    	if  ClientMainDMod.Client.Game.Slots[s].State > psNone then
    		n:= string(ClientMainDMod.Client.Game.Slots[s].Name)
    	else
    		n:= '';

    	case ClientMainDMod.Client.Game.Slots[s].State of
    		psNone:
    			if  ClientMainDMod.Client.Game.State >= gsPreparing then
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
    			if  (ClientMainDMod.Client.Game.Slots[s].State = psWaiting)
    			and (ClientMainDMod.Client.Game.Round = 0) then
    				v:= 'Drew:  ' + CardIndexToText(
							ClientMainDMod.Client.Game.Slots[s].FirstCard)
    			else
    				v:= 'Score:  ' +
							IntToStr(ClientMainDMod.Client.Game.Slots[s].Score);
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

	DrawGrid1.Canvas.Changing;
	try
    	DrawGrid1.Canvas.Brush.Color:= clWindow;
        DrawGrid1.Canvas.Brush.Style:= bsSolid;
        DrawGrid1.Canvas.FillRect(ARect);

        ClientMainDMod.ImageList2.Draw(DrawGrid1.Canvas, ARect.Left + 8,
				ARect.Top + 2, i, True);

        DrawGrid1.Canvas.Font.Color:= clBlack;
        DrawGrid1.Canvas.TextOut(ARect.Left + 48, ARect.Top + 4, n);

        DrawGrid1.Canvas.Font.Color:= clGray;
        DrawGrid1.Canvas.TextOut(ARect.Left + 48, ARect.Top + 18, v);

		finally
        DrawGrid1.Canvas.Changed;
		end;
	end;

procedure TClientMainForm.MsgUpdateHost(var AMessage: TLMessage);
	begin
	if  Assigned(ClientMainDMod.Client.Server) then
		EditHostInfo.Text:= ClientMainDMod.Client.Server.Name + ' ' +
				ClientMainDMod.Client.Server.Host + ' ' +
				ClientMainDMod.Client.Server.Version
	else
		EditHostInfo.Text:= '';
	end;

procedure TClientMainForm.MsgUpdateIdent(var AMessage: TLMessage);
	begin
    EditUserName.Text:= ClientMainDMod.Client.OurIdent;
	end;

procedure TClientMainForm.MsgUpdateRoomList(var AMessage: TLMessage);
	begin
    if  AMessage.lParam = 0 then
		MemoRoomList.Clear
	else
		MemoRoomList.Lines.Add(PString(AMessage.WParam)^);
	end;

procedure TClientMainForm.MsgUpdateRoom(var AMessage: TLMessage);
	begin
    if  AMessage.lParam = 0 then
		begin
        EditRoom.Enabled:= True;
		EditRoomPwd.Enabled:= True;
		ButtonRoomJoin.Action:= ClientMainDMod.ActRoomJoin;

		LstbxRoomUsers.Clear;
		end
	else
		begin
        EditRoom.Text:= ClientMainDMod.Client.Room;

        EditRoom.Enabled:= False;
		EditRoomPwd.Enabled:= False;
		ButtonRoomJoin.Action:= ClientMainDMod.ActRoomPart;
		end;
	end;

procedure TClientMainForm.MsgUpdateRoomUsers(var AMessage: TLMessage);
    var
	i: Integer;
	s: string;

	begin
    if  AMessage.lParam = 0 then
		LstbxRoomUsers.Clear
	else if AMessage.lParam = 1 then
		begin
        s:= PString(AMessage.wParam)^;
		i:= LstbxRoomUsers.Items.IndexOf(s);
		if  i = -1 then
        	LstbxRoomUsers.Items.Add(s);
		end
	else
		begin
        s:= PString(AMessage.wParam)^;
		i:= LstbxRoomUsers.Items.IndexOf(s);
		if  i > -1 then
        	LstbxRoomUsers.Items.Delete(i);
		end;
	end;

procedure TClientMainForm.MsgUpdateSlotState(var AMessage: TLMessage);
	begin
    DrawGrid1.Invalidate;
	end;

procedure TClientMainForm.MsgUpdateGameList(var AMessage: TLMessage);
	begin
    if  AMessage.lParam = 0 then
		MemoGameList.Clear
	else
		MemoGameList.Lines.Add(PString(AMessage.WParam)^);
	end;

procedure TClientMainForm.MsgUpdateOurState(var AMessage: TLMessage);
	begin
	AddLogMessage(slkDebug, 'UpdateOurState.');

    if  Assigned(ClientMainDMod.Client.Game) then
		begin
		if  ClientMainDMod.Client.Game.State > gsPreparing then
			LabelGameRound.Caption:= IntToSTr(ClientMainDMod.Client.Game.Round)
		else if ClientMainDMod.Client.Game.State = gsWaiting then
			LabelGameRound.Caption:= 'Waiting for all Ready...'
		else
  			LabelGameRound.Caption:= 'Waiting for all Draw First...';

        if  ClientMainDMod.Client.Game.State = gsPlaying then
			begin
			ClientMainDMod.ActGameControl.Tag:= 4;
			ClientMainDMod.ActGameControl.Caption:= 'Playing';

            ClientMainDMod.ActGameDrawDeck.Enabled:=
            		(ClientMainDMod.Client.Game.Slots[
                    ClientMainDMod.Client.Game.OurSlot].State = psPlaying) and
                    (not ClientMainDMod.Client.Game.Drawn);

            ClientMainDMod.ActGameDrawDiscard.Enabled:=
            		ClientMainDMod.ActGameDrawDeck.Enabled;

			end
		else if  (ClientMainDMod.Client.Game.OurSlot = -1)
		or  (ClientMainDMod.Client.Game.Slots[
				ClientMainDMod.Client.Game.OurSlot].State in [psNone, psWaiting]) then
			begin
			ClientMainDMod.ActGameControl.Tag:= 0;
			ClientMainDMod.ActGameControl.Caption:= 'Waiting';
			end
		else if ClientMainDMod.Client.Game.Slots[
				ClientMainDMod.Client.Game.OurSlot].State = psIdle then
			begin
			ClientMainDMod.ActGameControl.Tag:= 1;
			ClientMainDMod.ActGameControl.Caption:= 'Ready';
			end
		else if ClientMainDMod.Client.Game.Slots[
				ClientMainDMod.Client.Game.OurSlot].State = psReady then
			begin
			ClientMainDMod.ActGameControl.Tag:= 2;
			ClientMainDMod.ActGameControl.Caption:= 'Not Ready';
			end
		else if ClientMainDMod.Client.Game.Slots[
				ClientMainDMod.Client.Game.OurSlot].State = psPreparing then
			begin
			ClientMainDMod.ActGameControl.Tag:= 3;
			ClientMainDMod.ActGameControl.Caption:= 'Draw for First';
			end
		end
	else
		begin
//TODO
        end;
	end;

procedure TClientMainForm.MsgUpdateGame(var AMessage: TLMessage);
	begin
    if  AMessage.lParam = 0 then
		begin
        EditGame.Enabled:= True;
		EditGamePwd.Enabled:= True;
		ButtonGameJoin.Action:= ClientMainDMod.ActGameJoin;

		if  PgctrlPlay.ActivePage = TbshtDetail then
			PgctrlPlay.ActivePage:= TbshtOverview;

        CardHandFrame1.ClearCards;
		end
	else
		begin
        EditGame.Text:= ClientMainDMod.Client.Game.Ident;

        EditGame.Enabled:= False;
		EditGamePwd.Enabled:= False;
		ButtonGameJoin.Action:= ClientMainDMod.ActGamePart;
		end;
	end;

procedure TClientMainForm.MsgUpdateNewDeal(var AMessage: TLMessage);
	begin
//	FDiscardThis:= High(TCardIndex);
//	FDiscardLast:= High(TCardIndex);
//
//	Image1.Picture.Assign(CardGraphics[Low(TCardIndex)]);
// 	Image2.Picture.Assign(CardGraphics[FDiscardThis]);
//
//	CardHandFrame1.ClearCards;

    ListBox1.Items.Clear;
    AddGameInfo('A hand was dealt');
    end;

procedure TClientMainForm.MsgUpdateDrawCard(var AMessage: TLMessage);
	var
    cs: string;

    begin
    CardHandFrame1.AddCard(AMessage.WParam);

    if  ClientMainDMod.Client.Game.Drawn then
    	begin
    	ClientMainDMod.ActGameDrawDeck.Enabled:= False;
    	ClientMainDMod.ActGameDrawDiscard.Enabled:= False;
		end;

    if  AMessage.lParam > 0 then
    	begin
        FDiscardThis:= FDiscardLast;
        FDiscardLast:= High(TCardIndex);
     	Image2.Picture.Assign(CardGraphics[FDiscardThis]);
		end;

    if  AMessage.lParam = 0 then
		cs:= 'Deck'
    else
        cs:= 'Discard';

    AddGameInfo('You draw from ' + cs);
    end;

procedure TClientMainForm.MsgUpdateDrawInfo(var AMessage: TLMessage);
    var
    si: Integer;
    cs: string;

    begin
    if  AMessage.lParam = 0 then
		cs:= 'Deck'
    else
        cs:= 'Discard';

    si:= AMessage.wParam;

    AddGameInfo(IntToStr(si + 1) + 'P draws from ' + cs);

    if  AMessage.lParam > 0 then
    	begin
        FDiscardThis:= FDiscardLast;
        FDiscardLast:= High(TCardIndex);
     	Image2.Picture.Assign(CardGraphics[FDiscardThis]);
		end;
    end;

procedure TClientMainForm.MsgUpdateDiscard(var AMessage: TLMessage);
    var
    s,
    i: TCardIndex;

    begin
    if  AMessage.wParam = $FF then
    	begin
    	FDiscardLast:= High(TCardIndex);
    	FDiscardThis:= AMessage.lParam;
		end
	else
    	begin
    	FDiscardLast:= FDiscardThis;
    	FDiscardThis:= AMessage.lParam;

        if  AMessage.wParam = ClientMainDMod.Client.Game.OurSlot then
        	begin
            i:= 0;
            for s:= 0 to CardHandFrame1.CardCount - 1 do
            	if  CardHandFrame1.Cards[s] = FDiscardThis then
                	begin
                    i:= s;
                    Break;
    				end;

			CardHandFrame1.DeleteCard(i);

            ClientMainDMod.Client.Game.Drawn:= False;
			end;
		end;

 	Image2.Picture.Assign(CardGraphics[FDiscardThis]);
	end;

procedure TClientMainForm.MsgUpdateShuffled(var AMessage: TLMessage);
	begin
    AddGameInfo('Discard was shuffled');
	end;

procedure TClientMainForm.MsgUpdateNewFirst(var AMessage: TLMessage);
	begin

	end;

procedure TClientMainForm.MsgUpdateHaveGin(var AMessage: TLMessage);
    var
    i: Integer;

    begin
    ClientMainDMod.ActGameDrawDeck.Enabled:= False;
    ClientMainDMod.ActGameDrawDiscard.Enabled:= False;
    ClientMainDMod.ActGameDiscard.Enabled:= False;

    CardHandFrame1.ClearSelection;

    AddGameInfo(IntToStr(AMessage.lParam + 1) + 'P has GIN!!!');

    if  AMessage.lParam = ClientMainDMod.Client.Game.OurSlot then
        begin
	    CardHandFrame1.SetSelected(0, True);

		ClientMainDMod.TimerGIN.Tag:= 0;
		ClientMainDMod.TimerGIN.Enabled:= True;
		end
    else
    	begin
        CardHandFrame2.ClearCards;

        for i:= 0 to 9 do
        	CardHandFrame2.AddCard(ClientMainDMod.Client.Game.GinCards[i]);

        PgctrlDeal.ActivePage:= TbshtGin;
		end;
	end;

procedure TClientMainForm.MsgUpdateBeginNew(var AMessage: TLMessage);
	begin
//	ClientMainDMod.ActGameDrawDeck.Enabled:=
//			AMessage.lParam = ClientMainDMod.Client.Game.OurSlot;
//	ClientMainDMod.ActGameDrawDiscard.Enabled:=
//			AMessage.lParam = ClientMainDMod.Client.Game.OurSlot;

//  ClientMainDMod.ActGameDiscard.Enabled:= False;
//  ClientMainDMod.ActGameBegin.Enabled:= False;

    CardHandFrame1.ClearCards;

    PgctrlDeal.ActivePage:= TbshtDraw;

    AddGameInfo(IntToStr(AMessage.lParam + 1) + 'P begins round');
	end;

end.

