program PaperPlane;
uses SwinGame, sgTypes, SysUtils;

const
	MAX_DOWN = 4;
	ACCELERAION = 1;

type
	PlaneData= record 												//plane has these values 
		bmp: Bitmap;												//Bitmap
		x,y : Integer;												//a location
		dx, dy: Integer;											// x y Movement
	end;

	BackgroundData = record  										//Background has these values
		bmp : Bitmap; 												//Bitmap
		x: Integer;		 											//x location
	end;

	ObjKind = (BurjKhalifa, Thunder); 								//Kinds of obstructions

	ObjData = record 												//Obstructions has these values
		bmp: Bitmap;												//Bitmap
		kind: ObjKind; 												//Kind
		x,y: Integer; 												// x, y location
	end;

	Obj = Array[0..3] of ObjData;									//Array of obstructions

	GameData = record 												//The game has these values
		obstruction : Obj; 											//Array of obstructions
		plane: PlaneData;											//Plane
		background: BackgroundData;  								//Background
		score: Integer;												//Score
	end;

procedure LoadResources();											//Loading the resources
begin
	LoadBitmapNamed('background', 'background.png');
	LoadBitmapNamed('BurjKhalifa', 'BurjKhalifa.png');
	LoadBitmapNamed('Thunder', 'Thunder.png');
	LoadBitmapNamed('PaperPlane', 'PaperPlane.png');
	LoadSoundEffectNamed('Wind', 'wind.wav');
	LoadSoundEffectNamed('Ding', 'ding.wav');
end;

procedure CreateObstructionOne(var bg:ObjData);						//Creating obstruction 1 (Thunder)
begin
	bg.bmp:= BitmapNamed('Thunder');
	bg.x:= 800;
	bg.y:= 0;
end;

procedure CreateObstructionTwo(var bg:ObjData);						//Creating obstruction 2 (Burjkhalifa)
begin
	bg.bmp:= BitmapNamed('BurjKhalifa');
	bg.x:= 800;
	bg.y:= 220;
end;

procedure CreateObstructionThree(var bg:ObjData);					//Creating obstruction 3 (Thunder)
begin
	bg.bmp:= BitmapNamed('Thunder');
	bg.x:= 1200;
	bg.y:= Rnd(50);
end;

procedure CreateObstructionFour(var bg:ObjData);					//Creating obstruction 4 (burjkhalifa)
begin
	bg.bmp:= BitmapNamed('BurjKhalifa');
	bg.x:= 1200;
	bg.y:= 220;
end;

procedure CreateObstruct(var o:Obj);
begin
	CreateObstructionOne(o[0]);
	CreateObstructionTwo(o[1]);
	CreateObstructionThree(o[2]);
	CreateObstructionFour(o[3]);
end;

procedure CreateObstructions(var objs:Array of Obj);
var
	i: Integer;
begin
	for i := Low(objs) to High(objs) do
	begin
		CreateObstruct(objs[i]);
	end;
end;

procedure CreatePlane(var plane:PlaneData);
begin
	plane.bmp:= BitmapNamed('PaperPlane');			
	plane.x:=Round(ScreenWidth()/3);					// planes x location at 1/3rd of screen width
	plane.y:=Round(ScreenHeight()/2);					// Planes y location at half of screen height

	plane.dx:=0;
	plane.dy:=0;
end;

procedure CreateBackground(var bg:BackgroundData);
begin
	bg.bmp:= BitmapNamed('background');
	bg.x:= 0;
end;

procedure CreateGame(var game:GameData);
begin
	game.score := 0;
	CreatePlane(game.plane);
	CreateObstructions(game.obstruction);
	CreateBackground(game.background);
end;

// Control plane and ensure it does not go beyond screen height
procedure HandlePlane(var plane:PlaneData);
begin
	if KeyDown(VK_SPACE) AND (plane.y > 10) then 	
	begin
		plane.dy:=-10;  						 				
	end;
end;

procedure HandleInput(var game:GameData);
begin
	ProcessEvents();
	HandlePlane(game.plane);
end;

procedure UpdatePlane(var plane:PlaneData);							// Update the plane 
begin
	plane.x += plane.dx;
	plane.y += plane.dy;
	//plane.bmp:=RotateScaleBitmap(BitmapNamed('PaperPlane'),-plane.dy*4,1);			
	if(plane.dy < MAX_DOWN) then 
	begin
		plane.dy += ACCELERAION;
	end;
end;

procedure UpdateobstructionOne(var bg:ObjData);
begin
	bg.x-=2;
	if(bg.x<- 20) then 
	begin
		bg.x:= 800;
		bg.y:= Rnd(50);
	end;
end;

procedure UpdateobstructionTwo(var bg:ObjData);
begin
	bg.x-=2;
	if(bg.x<- 20) then 
	begin
		bg.x:= 800;
		bg.y:= 220;
	end;
end;

procedure UpdateobstructionThree(var bg:ObjData);
begin
	bg.x-=2;
	if(bg.x<- 20) then 
	begin
		bg.x:= 800;
		bg.y:= Rnd(50);
	end;
end;

procedure UpdateobstructionFour(var bg:ObjData);
begin
	bg.x-=2;
	if(bg.x<- 20) then 
	begin
		bg.x:= 800;
		bg.y:= 220;
	end;
end;

procedure UpdateObstruct(var o:Obj);
begin
	UpdateObstructionOne(o[0]);
	UpdateObstructionTwo(o[1]);
	UpdateobstructionThree(o[2]);
	UpdateObstructionFour(o[3]);
end;

procedure UpdateObstructions(var objs: Array of Obj);
var
	i: Integer;
begin
	for i := Low(objs) to High(objs) do
	begin
		UpdateObstruct(objs[i]);
	end;
end;

procedure UpdateBackGround(var bg:BackgroundData);
begin
	bg.x -= 4;
	if(bg.x < -Round(BitmapWidth(bg.bmp)/2)) then 
	begin
		bg.x:=0;
	end;
end;

// check bitmap collision between plane and obstruction
function collision(var obstruction: ObjData; var plane: PlaneData): Boolean;      
begin
	if BitmapCollision(obstruction.bmp, obstruction.x, obstruction.y, plane.bmp, plane.x, plane.y) then 
	begin
		result := true;
	end
	else
	begin
		result := false;
	end;
		// WriteLn(result);
		// WriteLn(obstruction.x);
		// WriteLn(obstruction.y);
		// WriteLn(plane.x);
		// WriteLn(plane.y);
end;

procedure scoring(var obstruction: Obj; var plane: PlaneData; var score:Integer); 		// Apply the Scoring
var 
	i : Integer;
begin
	for i:= Low(obstruction) to High(obstruction) do 
	begin
		if (obstruction[i].x = 230) then
		begin
			score += 1;
			PlaySoundEffect('Ding', 0.5);
		end;
		if (collision(obstruction[i], plane))then 
		begin
			score := -1;
		end;
		if (plane.y > 480) then
		begin
			score := -1;
		end;
	end;
end;

procedure UpdateGame(var game:GameData);
begin
	UpdatePlane(game.plane);
	UpdateObstructions(game.obstruction);
	scoring(game.obstruction, game.plane, game.score);
	UpdateBackGround(game.background);
end;

procedure DrawPlane(const plane:PlaneData);
begin
	DrawBitmap(plane.bmp,plane.x,plane.y);	
end;

procedure DrawobstructionOne(const bg:ObjData);
begin
	DrawBitmap(bg.bmp,bg.x,bg.y);
end;

procedure DrawobstructionTwo(const bg:ObjData);
begin
	DrawBitmap(bg.bmp,bg.x,bg.y);
end;

procedure DrawobstructionThree(const bg:ObjData);
begin
	DrawBitmap(bg.bmp,bg.x,bg.y);
end;

procedure DrawobstructionFour(const bg:ObjData);
begin
	DrawBitmap(bg.bmp,bg.x,bg.y);
end;

procedure DrawObstruct(const o:Obj);
begin
	DrawObstructionOne(o[0]);
	DrawObstructionTwo(o[1]);
	DrawobstructionThree(o[2]);
	DrawObstructionFour(o[3]);
end;

procedure DrawObstructions(const objs: Array of Obj);
var
	i: Integer;
begin
	for i := Low(objs) to High(objs) do
	begin
		DrawObstruct(objs[i]);
	end;
end;

procedure DrawBackground(const bg:BackgroundData);
begin
	DrawBitmap(bg.bmp,bg.x,0);
end;

procedure DrawGame(const game:GameData);
begin
	ClearScreen(ColorWhite);
	DrawBackground(game.background);
	DrawObstructions(game.obstruction);
	DrawPlane(game.plane);
	DrawText('Score: ' + IntToStr(game.score) , ColorWhite, 10, 10);
	RefreshScreen(60);
end;

procedure Main();
var
	game: GameData;
begin
	
	OpenGraphicsWindow('PaperPlane', 800, 500);
	LoadDefaultColors();
	LoadResources();
	PlaySoundEffect('Wind', -1);
	CreateGame(game);
	repeat
		HandleInput(game);
		UpdateGame(game);
		DrawGame(game);	
	until (game.score = -1) or WindowCloseRequested();
end;

begin
	Main();
end.