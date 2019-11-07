unit FrameCardHand;

{$MODE DELPHI}
{$H+}

interface

uses
	Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, CardTypes,
	CardClasses;

type

	{ TCardHandFrame }
 	TCardHandFrame = class(TFrame)
		Shape1: TShape;
	private
		FSize: TPoint;
        FAllowChange: Boolean;
		FYOffs,
		FLrgHeight: Integer;
        FCards: array of TCardIndex;
		FImages: array of TImage;
		FSelected: TCardSet;
		FSelCount: Integer;
		FLastHot: Integer;
		FDrag,
		FDidDrag: Boolean;
		FDragStart,
		FDragEnd: Integer;
		FOnSelect: TNotifyEvent;

		procedure UpdateDragPos;
		procedure CalcDragPos(const AX: Integer);

		function  GetCardCount: Integer;
		function  GetCards(AIndex: Integer): TCardIndex;

	protected
        procedure SetAllowChange(AValue: Boolean);

		procedure OnCardMouseEnter(Sender: TObject);
		procedure OnCardMouseLeave(Sender: TObject);
		procedure OnCardMouseDown(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);
		procedure OnCardMouseMove(Sender: TObject; Shift: TShiftState; X,
				Y: Integer);
		procedure OnCardMouseUp(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Integer);

	public
    	destructor  Destroy; override;

		procedure InitDeckSize(const ASize: TPoint);
        procedure AddCard(const ACardIndex: TCardIndex);
		procedure MoveCard(const ASource, ADest: TCardIndex);
		procedure SwapCards(const ASource, ADest: TCardIndex);
		procedure DeleteCard(const ACard: TCardIndex);
		procedure ClearSelection;
		procedure ClearCards;
		procedure SetSelected(const AIndex: Integer; const ASelect: Boolean);

        property  OnSelect: TNotifyEvent read FOnSelect write FOnSelect;

        property  AllowChange: Boolean read FAllowChange write SetAllowChange;

		property  SelCount: Integer read FSelCount;
		property  Selected: TCardSet read FSelected;

		property  CardCount: Integer read GetCardCount;
		property  Cards[AIndex: Integer]: TCardIndex read GetCards;
    end;

implementation

{$R *.lfm}

{ TCardHandFrame }

procedure TCardHandFrame.OnCardMouseLeave(Sender: TObject);
	begin
    if  FLastHot = TImage(Sender).Tag then
		begin
		if  not (FLastHot in FSelected) then
			begin
			FImages[FLastHot].Height:= FSize.y;
            FImages[FLastHot].Top:= FYOffs;
			end;

		FLastHot:= -1;
		end;
	end;

procedure TCardHandFrame.OnCardMouseDown(Sender: TObject; Button: TMouseButton;
		Shift: TShiftState; X, Y: Integer);
    var
	i: TCardIndex;

	begin
	if  Button = mbLeft then
		begin
	    i:= TImage(Sender).Tag;

		FDrag:= True;
		FDidDrag:= False;
		FDragStart:= i;
		FDragEnd:= i;

		if  i in FSelected then
			begin
	        Exclude(FSelected, i);
			Dec(FSelCount);
			FImages[i].Height:= FSize.y;
            FImages[i].Top:= FYOffs;

			if  Assigned(FOnSelect) then
				FOnSelect(Self);
			end
		else
			begin
			Inc(FSelCount);
	        Include(FSelected, i);
			FImages[i].Height:= FLrgHeight;
			FImages[i].Top:= 0;

			if  Assigned(FOnSelect) then
				FOnSelect(Self);
			end;
		end;
	end;

procedure TCardHandFrame.OnCardMouseMove(Sender: TObject; Shift: TShiftState;
		X, Y: Integer);
    var
	p: TPoint;

	begin
	if  FDrag then
		begin
        p:= TImage(Sender).ClientToParent(Point(X, Y));

    	CalcDragPos(p.x);
		UpdateDragPos;
		end;
	end;

procedure TCardHandFrame.OnCardMouseUp(Sender: TObject; Button: TMouseButton;
		Shift: TShiftState; X, Y: Integer);
    var
	p: TPoint;

	begin
    if  FDrag then
		begin
        p:= TImage(Sender).ClientToParent(Point(X, Y));

		CalcDragPos(p.x);

		if  FDragStart <> FDragEnd then
			MoveCard(FDragStart, FDragEnd)
		else if FDidDrag then
			begin
			if  FDragStart in FSelected then
				begin
				Dec(FSelCount);
				Exclude(FSelected, FDragStart);
				if  Assigned(FOnSelect) then
					FOnSelect(Self);
				end;
			end;

        FDrag:= False;
		FDidDrag:= False;
		UpdateDragPos;
		end;
	end;

procedure TCardHandFrame.UpdateDragPos;
	begin
    if  (not FDrag)
	or  (FDragStart = FDragEnd) then
		Shape1.Visible:= False
	else if FDrag then
		begin
		FDidDrag:= True;
        Shape1.Left:= FDragEnd * Trunc(FSize.x * 0.5);
        Shape1.Visible:= True;
		Shape1.BringToFront;
		end;
	end;

procedure TCardHandFrame.CalcDragPos(const AX: Integer);
	begin
    FDragEnd:= AX div Trunc(FSize.x * 0.5);
    if  FDragEnd > High(FCards) then
		FDragEnd:= High(FCards);
	if  FDragEnd < 0 then
		FDragEnd:= 0;
	end;

function TCardHandFrame.GetCardCount: Integer;
	begin
    Result:= Length(FCards);
	end;

function TCardHandFrame.GetCards(AIndex: Integer): TCardIndex;
	begin
    Result:= FCards[AIndex];
	end;

procedure TCardHandFrame.SetAllowChange(AValue: Boolean);
	begin
    FAllowChange:= AValue;
	end;

procedure TCardHandFrame.OnCardMouseEnter(Sender: TObject);
	begin
    if  not FDrag then
        begin
	    if  FLastHot > -1 then
			if  not (FLastHot in FSelected) then
				begin
				FImages[FLastHot].Top:= FYOffs;
				FImages[FLastHot].Height:= FSize.y;
				end;

	    FLastHot:= TImage(Sender).Tag;
		FImages[FLastHot].Top:= 0;
		FImages[FLastHot].Height:= FLrgHeight;
		end;
	end;

destructor TCardHandFrame.Destroy;
    var
	i: Integer;

	begin
    for i:= 0 to High(FImages) do
		FImages[i].Free;

	inherited Destroy;
	end;

procedure TCardHandFrame.InitDeckSize(const ASize: TPoint);
    var
	i: Integer;

	begin
	FSize:= ASize;

    FYOffs:= Trunc(FSize.y * 0.3);
	FLrgHeight:= FSize.y + FYOffs;

    Height:= FSize.y + FYOffs;
	Shape1.Height:= FYOffs;

	ClearCards;
	end;

procedure TCardHandFrame.AddCard(const ACardIndex: TCardIndex);
    var
	i: Integer;

	begin
    i:= Length(FCards);

	SetLength(FCards, i + 1);
	FCards[i]:= ACardIndex;

	SetLength(FImages, i + 1);
	FImages[i]:= TImage.Create(Self);

    FImages[i].Parent:= Self;
	FImages[i].Width:= FSize.x;
	FImages[i].Height:= FSize.y;

    FImages[i].Left:= i * Trunc(FSize.x * 0.5);


	FImages[i].Tag:= i;
	FImages[i].Picture.Assign(CardGraphics[ACardIndex]);

    if  FAllowChange then
        begin
        FImages[i].Top:= FYOffs;

	    FImages[i].OnMouseEnter:= OnCardMouseEnter;
    	FImages[i].OnMouseLeave:= OnCardMouseLeave;
		FImages[i].OnMouseDown:= OnCardMouseDown;
		FImages[i].OnMouseMove:= OnCardMouseMove;
		FImages[i].OnMouseUp:= OnCardMouseUp;
		end
	else
    	FImages[i].Top:= 0;

	FImages[i].Visible:= True;
	end;

procedure TCardHandFrame.MoveCard(const ASource, ADest: TCardIndex);
    var
	i,
	j: Integer;
	h: TImage;

	begin
    if  (ASource <> ADest) then
		begin
		h:= FImages[ASource];
		j:= FCards[ASource];

        if  ASource > ADest then
            begin
			for  i:= ASource downto ADest + 1 do
				begin
                FImages[i]:= FImages[i - 1];
				FCards[i]:= FCards[i - 1];

                if  TCardIndex(i - 1) in FSelected then
					begin
					Exclude(FSelected, i - 1);
					Include(FSelected, i);
					end;
				end;
			end
		else
			begin
			for i:= ASource + 1 to ADest do
				begin
				FImages[i - 1]:= FImages[i];
				FCards[i - 1]:= FCards[i];

                if  i in FSelected then
					begin
					Exclude(FSelected, i);
					Include(FSelected, i - 1);
					end;
				end;
			end;

    	FImages[ADest]:= h;
    	FCards[ADest]:= j;

		if  ASource in FSelected then
			begin
        	Exclude(FSelected, ASource);
			Dec(FSelCount);
//			Include(FSelected, ADest);

			FImages[ADest].Height:= FSize.y;
			FImages[ADest].Top:= FYOffs;

			if  Assigned(FOnSelect) then
				FOnSelect(Self);
			end;

		for i:= 0 to High(FCards) do
			begin
			FImages[i].Tag:= i;
            FImages[i].Left:= i * Trunc(FSize.x * 0.5);
			FImages[i].BringToFront;
			end;
		end;
	end;

procedure TCardHandFrame.SwapCards(const ASource, ADest: TCardIndex);
	var
    i,
	j: Integer;
	h: TImage;
	ss,
	sd: Boolean;

	begin
	h:= FImages[ASource];
	j:= FCards[ASource];

    FImages[ASource]:= FImages[ADest];
	FCards[ASource]:= FCards[ADest];

    FImages[ADest]:= h;
	FCards[ADest]:= j;

	for i:= 0 to High(FCards) do
		begin
		FImages[i].Tag:= i;
        FImages[i].Left:= i * Trunc(FSize.x * 0.5);
		FImages[i].BringToFront;
		end;

	ss:= ASource in FSelected;
	sd:= ADest in FSelected;

	if  ss then
		begin
		if  not sd then
			Exclude(FSelected, ASource);

		Include(FSelected, ADest);
		end;

	if  sd then
		begin
		if  not ss then
        	Exclude(FSelected, ADest);

		Include(FSelected, ASource);
		end;

	if  ss or sd then
		if  Assigned(FOnSelect) then
			FOnSelect(Self);
	end;

procedure TCardHandFrame.DeleteCard(const ACard: TCardIndex);
	var
	i: Integer;
    ss: Boolean;

	begin
    ss:= ACard in FSelected;

	Exclude(FSelected, ACard);

	FImages[ACard].Free;

	for i:= ACard + 1 to High(FCards) do
		begin
		FImages[i - 1]:= FImages[i];
		FCards[i - 1]:= FCards[i];

        if  i in FSelected then
			begin
			Exclude(FSelected, i);
			Include(FSelected, i - 1);
			end;
		end;

	SetLength(FImages, Length(FCards) - 1);
	SetLength(FCards, Length(FCards) - 1);

	for i:= 0 to High(FCards) do
		begin
		FImages[i].Tag:= i;
        FImages[i].Left:= i * Trunc(FSize.x * 0.5);
		FImages[i].BringToFront;
		end;

    if  ss then
		begin
		Dec(FSelCount);
		if  Assigned(FOnSelect) then
			FOnSelect(Self);
		end;
	end;

procedure TCardHandFrame.ClearSelection;
    var
	i: Integer;

	begin
	FSelCount:= 0;
	FDrag:= False;
	FDidDrag:= False;
	UpdateDragPos;

    for i:= 0 to High(FCards) do
//		if  i in FSelected then
			begin
//          Exclude(FSelected, i);
			FImages[i].Height:= FSize.y;
            FImages[i].Top:= FYOffs;
			end;

	FSelected:= [];
	end;

procedure TCardHandFrame.ClearCards;
    var
	i: Integer;

	begin
    ClearSelection;

    for i:= 0 to High(FImages) do
		FImages[i].Free;

    SetLength(FCards, 0);
	SetLength(FImages, 0);

    FLastHot:= -1;
	end;

procedure TCardHandFrame.SetSelected(const AIndex: Integer;
		const ASelect: Boolean);
	begin
    if  ASelect then
		begin
		if  not (AIndex in FSelected) then
			begin
            Include(FSelected, AIndex);
			Inc(FSelCount);

			FImages[AIndex].Height:= FLrgHeight;
			FImages[AIndex].Top:= 0;
			end;
		end
	else
		if  AIndex in FSelected then
			begin
            Exclude(FSelected, AIndex);
			Dec(FSelCount);

			FImages[AIndex].Height:= FSize.y;
			FImages[AIndex].Top:= FYOffs;
			end;
	end;

end.

