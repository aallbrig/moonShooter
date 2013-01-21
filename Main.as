package {
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.utils.Timer;
	import flash.display.Sprite;
	import flash.utils.*;
	
    public class Main extends MovieClip {
        //properties
		public var mySound:Sound;
		public var goingDown:Number = 275;	//"player" goingDown: lower third to make the stage go up
		public var goingUp:Number = 100;	//"player" goingUp:   upper third to make the stage go down
		public var ploc:Number;
		public var endTime:Number;
		public var getFirstLife:Number = 1000;
		public var getLifeEvery:Number = 5000;
		public var score:Number = 0;
		public var hiScore:Number = 0;
		public var lives:Number;
		public var levelMoving:Boolean;

		//player
		public var fireRate:Number;	//how many bullets?
		public var moveSpeed:Number = 5;
		public var repeatTime:Number;
		public var firing:Boolean;		//is the player firing?
		public var forward:Boolean = false;
		public var back:Boolean = false;
		public var up:Boolean = false;
		public var down:Boolean = false;
		public var firstLife:Boolean = true;
		public var cantAct:Boolean;
		public var keyWentUp:Boolean;

		//enemies
		public var enemyTime:Number;	//how much time between enemy waves
		public var enemyRate:Number;	//how many enemies allowed on screen
		public var enemyCount:Number;	//how many enemies?


		//general
		public var counter:Number;		//how much time you have in game
		public var GAMESTATE:Number = 0;//0 = menus 1 = playing
		public var gameTimer:Timer;
		public var LevelX:Number;
		public var LevelY:Number;
		public var ForegroundX:Number;
		public var ForegroundY:Number;
		public var MiddlegroundX:Number;
		public var MiddlegroundY:Number;

		//holders
		public var enemyLayer:MovieClip;
		public var projectileLayer:Sprite;

		//powerup code
		public var powerupLayer:MovieClip; //New Code
		public var powerupCount:Number;
		public var beamFired:Boolean; //NEW CODE//
		public var havePowerup1:Boolean;
		public var havePowerup2:Boolean;
		public var percentDrop:Number = .25;

		//bullet 
		public var bulWidth:Number = 8;
		public var bulHeight:Number = 8;
		public var projectileCount:Number;//how much s*** on screen
		public var countID:Number;		//timer stuff

		//Menu Stuff
		public var selectionArray:Array = [
		    [">>PLAY!<<","How To Play","Mission","HiScores"],
		    ["PLAY!",">>How To Play<<","Mission","HiScores"],
		    ["PLAY!","How To Play",">>Mission<<","HiScores"],
		    ["PLAY!","How To Play","Mission",">>HiScores<<"]							
									]
		public var selectIndex:Number = 0;
		public var currentSelection:String = selectionArray[selectIndex][selectIndex];
		

		//boss variables
/////////////
		//boss infor <-- infor? Derp
		public var bossHp:Number = 30;  //how much hp
		public var right:Boolean = false;  //This is for movement ai
		public var bossSideScrolling:Boolean = true;  //is your boss on the side or top?
		public var bossLayer:MovieClip; //holds the boss
		public var bossSpeed = 8;  //how fast the boss moves
		public var bossProjectileLayer:MovieClip;  //holds boss Bullets
		public var bossActive:Boolean = false;
		public var gameCounter:Number;
		public var enemyActive:Boolean = true;
		public var endGameE:Boolean;

		//Stage
		public var stageWidth:Number = stage.stageWidth;
		public var stageHeight:Number = stage.stageHeight;
///////////////////////
		//methods
		//constructor method
		public function Main() {
			stop();
			mySound = new IslandMusic();
			mySound.play();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKUp);

			startScreen(null);
        }//e Main()

		function startGame(e:MouseEvent):void {
		  Start.visible = false;
		  Start.removeEventListener(MouseEvent.CLICK, startGame);
		  setupGame();
		}

		function setupGame():void{
		  //reset boss variables
		  bossActive = false;
		  enemyActive = true;
	  	  endGameE =  false;
	  	  //create a layer for the boss
		  bossLayer = new MovieClip()
		  addChild(bossLayer);
		  bossProjectileLayer = new MovieClip();
		  addChild(bossProjectileLayer);
		  gameCounter = 50;
////////////////////////////////////////////////////

		  //reset variables
		  score = 0;
		  lives = 1;
		  //handleLives(0);
		  UI.Lives.gotoAndStop(lives);
		  firstLife = true;
		  //trace(lives);
		  handleScore(score);
		  endTime = 35;

		  //below is just a catch-all
		  //startScreen.visible = false;
		  winScreen.visible = false;
		  loseScreen.visible = false;
		  InstructScreen.visible = false;
		  StoryScreen.visible = false;
		  HiScoreScreen.visible = false;

		  //re/set player loc
		  player.x = 100;
		  player.y = 200;
		  cantAct = false;

		  LevelX = Level.x;
		  LevelY = Level.y;
		  ForegroundX = Foreground.x;
		  ForegroundY = Foreground.y;
		  MiddlegroundX = Middleground.x;
		  MiddlegroundY = Middleground.y;
		  
		///////////////////////////////////////////////////////
		  beamFired = false; //NEW CODE//
		  havePowerup1 = false;
		  havePowerup2 = false;
		  ////////////////////////////
		  //NEW CODE
		  powerupLayer = new MovieClip()
		  this.addChild(powerupLayer);
		  powerupCount = 0;
		///////////////////////////////////////////////////////
		  //reset variables
		  repeatTime = 0;
		  firing = false;		
		  fireRate = 10;		//in FPS
		  enemyTime = 0;
		  enemyRate = 30;		// in FPS
		  enemyLayer = new MovieClip();
		  addChild(enemyLayer);
		  enemyCount = 0;
		  projectileLayer = new Sprite();
		  this.addChild(projectileLayer);
		  projectileCount = 0;
		  stage.addEventListener(Event.ENTER_FRAME, gameControl);
		
			
		  //addEventListeners
		  stage.addEventListener(Event.ENTER_FRAME, levelMove);
		  stage.addEventListener(Event.ENTER_FRAME, friction);
			
		  //timer
		  gameTimer = new Timer(1000);
		  gameTimer.start();
		  //run 'doCounter' every second
			countID = setInterval(updateTimer, 1000);
		  //this.addEventListener(Event.ENTER_FRAME, updateTimer);

		  
		  GAMESTATE = 1;
		}
		function updateTimer():void{
		  gameCounter--;
		  var eTime:Number = endTime - gameTimer.currentCount;
		  if(eTime <= 0)
		  {  
		  	//endGame("win"); 
		  	if(enemyActive){
				//turn off enemies so they don't spawn
				enemyActive = false;
			}//end of ifEnemyActive
				
			//boss has not Spawned	
			if(!bossActive){
				//wait till all Enemies are off of stage
				if(enemyLayer.numChildren == 0){
					//boss is now active
					bossActive = true;
						//check to see if the game has ended
						if(!endGameE){
							//spawn boss
							boss();					
							
						}//end if not EndGame
				}//end of enemyGone
			}//end of Not BossActive
		  }
		  /*else{ */ UI.Time.text = gameCounter.toString();  //}
		  //else{  UI.Time.text = eTime.toString();  }
		  //trace(eTime.toString());
		}
		function levelMove(e:Event):void{
		  ploc = Number(player.y);

		  //going down
		  if(ploc >= goingDown && down){
		    Level.y -= moveSpeed;
		    levelMoving = true;
		    if(Level.y >= -30)	{		player.y = goingDown;	}
		    if(Level.y <= -30){
		      Level.y = -30;
		      levelMoving = false;
		    }
		  }
		  //going up
		  if(ploc <= goingUp && up){
		    Level.y += moveSpeed;
		    levelMoving = true;
		    if(Level.y <= 305)	{		player.y = goingUp;		}
		    if(Level.y >= 305){
		      Level.y = 305;
		      levelMoving = false;
		    }
		  }
		  if(levelMoving && down){
			Middleground.y -= (moveSpeed * 0.5);
			Foreground.y -= (moveSpeed * 0.8);
		  }
		  //going up
		  if(levelMoving && up){
			Middleground.y += (moveSpeed * 0.5);
			Foreground.y += (moveSpeed * 0.8);
		  }
		}
		function updateSelection():void{
		  Start.Option_PLAY.text = selectionArray[selectIndex][0];
		  Start.Option_INSTRUCT.text = selectionArray[selectIndex][1];
		  Start.Option_STORY.text = selectionArray[selectIndex][2];
		  Start.Option_SCORE.text = selectionArray[selectIndex][3];
		  
		  currentSelection = selectionArray[selectIndex][selectIndex];
		}
///////////////////////////////////////////////////////////////////////
		//////////////////////////////////////
		//BOSS
		////////////////////

		function boss():void{
			
			//makes a holder for the boss
			var theBoss:MovieClip = new Boss();
			
			//give the Boss hp
			theBoss.hp = bossHp;
			theBoss.name = "theBoss";
			//this postitions the boss
			//puts the boss on the right
			if(bossSideScrolling){
				theBoss.x = stageWidth - theBoss.width/2 ;
			}//end of sideScroll

			//puts the boss at the top the screen
			else{
				theBoss.y = 0+ theBoss.height/2;
			}//end of else
			
			theBoss.addEventListener(Event.ENTER_FRAME, bossAI);
			//adds the boss to the stage
			bossLayer.addChild(theBoss);
		}//end of boss



		///////////////////////////
		//This is the Boss AI
		function bossAI(e:Event):void{
			
			var boss:MovieClip = MovieClip(e.currentTarget);
			if(levelMoving && down)  {  boss.y -= moveSpeed;  }
		    if(levelMoving && up)    {  boss.y += moveSpeed;  }
			//check for sideScrolling
			//now for ai movement
			if(bossSideScrolling){

					if(boss.y < 0 + boss.height/2){
						 right = true;
					}//end of x < 0
					
					else if(boss.y > (stageHeight - boss.height/2) ){
						right = false;
						
					}//end of  x 500
					
					if (right){
						boss.y += bossSpeed;
					}//end of right
					
					else{
						boss.y -= bossSpeed;
					}//end of  left
					
					
					///////////////////////////
					//BOSs FIRiNG
					var aiSide:Number = Math.random()*100
					if(aiSide<2){
						createBossProjectile("bossBullet", boss.x,  boss.y - 5, -15, 0);
						boss.BOSSMAN.gotoAndPlay("Firing");
						mySound = new AlienGunShot();
						mySound.play();
					}//end of less than 2%
					
					
				}//end of side Scrooling
				
			else{
					if(boss.x < 0 + boss.width/2){
						 right = true;
					}//end of x < 0
					
					else if(boss.x > (stageWidth - boss.width/2) ){
						right = false;
						
					}//end of  x 500
					
					if (right){
						boss.x += bossSpeed;
					}//end of right
					
					else{
						boss.x -= bossSpeed;
					}//end of  left
					
					
					///////////////////////////
					//BOSs FIRiNG
					var ai:Number = Math.random()*100
					if(ai<2){
						createBossProjectile("bossBullet", boss.x,  boss.y - 5, 0, 15);
						mySound = new GunShot();
						mySound.play();
					}//end of less than 2%
					
			}//end of else

			
		}//end of bossMovement

		////////////////////////
		//BOSS PROJECTILES

		//creates a bullet at X, Y, moving  in the dx, dy directoion
		function createBossProjectile(type:String, X:Number, Y:Number, dx:Number, dy:Number):void {
			
			//create a new projectile graphic
			var newBullet:MovieClip = new BossBullet();
			
			//set its position
			newBullet.x = X;
			newBullet.y = Y;
			
			//set it velocity
			newBullet.dx = dx;
			newBullet.dy = dy;
			
			//add it to the projectile layer
			bossProjectileLayer.addChild(newBullet);
			
			//call onBulletEnterFrame once per frame
			newBullet.addEventListener(Event.ENTER_FRAME, onBossBulletEnterFrame);

			//increase projectile count (could be used to limit projectiles if needed)
			projectileCount ++;
			projectileCount %= 10;

		}//end of create Projectile


		//whenver a projectile enters the frame
		function onBossBulletEnterFrame(e:Event):void {

			//get a reference to the projectile
			var targetBullet:MovieClip = MovieClip(e.currentTarget);
			
			//move the projectile by its velocity
			targetBullet.x += targetBullet.dx;
			//targetBullet.y += targetBullet.dy;
			if(levelMoving && down)  {  targetBullet.y -= moveSpeed;  }
		    if(levelMoving && up)    {  targetBullet.y += moveSpeed;  }
			
			
			if(bossSideScrolling){
				//if the proectile is off the screen
				if (targetBullet.x < 0) {
						//stop updating it
						targetBullet.removeEventListener(Event.ENTER_FRAME, onBossBulletEnterFrame);
						//remove it from the screen
						//bossProjectileLayer.removeChild(targetBullet);
						targetBullet.parent.removeChild(targetBullet);
						
				}//end of if y<0 
					
					else {
						//if the bullet is overlapping the enmy & the enemy is on frame one
							if (targetBullet.hitTestObject(player))
							{
								//play the enemy death 
								targetBullet.removeEventListener(Event.ENTER_FRAME, onBossBulletEnterFrame);
								//remove bullet from the screen
								//bossProjectileLayer.removeChild(targetBullet);
								targetBullet.parent.removeChild(targetBullet);
								
								endGame("lose");
								
							}//end of if hittest
								
				}//end of else
			}//end of if sideScrolling
			
			
			else{
				//if the proectile is off the screen
				if (targetBullet.x < 0) {
					//stop updating it
					targetBullet.removeEventListener(Event.ENTER_FRAME, onBulletEnterFrame);
					//remove it from the screen
					//bossProjectileLayer.removeChild(targetBullet);
					targetBullet.parent.removeChild(targetBullet);
					}//end of if y<0 
					
					else {					
							
							//if the bullet is overlapping the enmy & the enemy is on frame one
								if (targetBullet.hitTestObject(player))
								{
									//play the enemy death
									
									targetBullet.removeEventListener(Event.ENTER_FRAME, onBossBulletEnterFrame);
									//remove bullet from the screen
									//bossProjectileLayer.removeChild(targetBullet);
									targetBullet.parent.removeChild(targetBullet);
									//bullet's gone, we don't want to check any other enemies
									
									endGame("lose");
									
								}//end of if hittest
								
				}//end of else
			}//end of else sideScrolling
		}//end of onBulletEnterFrame
///////////////////////////////////////////////////////////////////////		

		function handleSelection( SELECTINDEX ):void{
		  switch( SELECTINDEX ){
			case 0://PLAY!
			  startGame(null);
			  break;
			case 1://INSTRUCT
			  InstructScreen.visible = true;
			  GAMESTATE = 2;
			  break;
			case 2://STORY
			  StoryScreen.visible = true;
			  GAMESTATE = 2;
			  break;
			case 3://HiSCORES
			  HiScoreScreen.visible = true;
			  GAMESTATE = 2;
			  break;
		  }
		}

		function onKDown(e:KeyboardEvent):void{
		  //trace(e.keyCode);
		  if(GAMESTATE == 2){//when the game is on a pop-up
		    switch(e.keyCode){
		      case 87: //W
		        break;
		      case 65: //A
		        break;
		      case 83: //S
		        break;
		      case 68: //D
		        //trace('D');
		        break;
		      case 32: //SPACE
			    startScreen(null);
				GAMESTATE = 0;
		        break;
			}
		  }
		  else if(GAMESTATE == 0){//when the game is on the start screen
		    switch(e.keyCode){
		      case 87: //W
				selectIndex--;
				if(selectIndex < 0){  selectIndex = selectionArray.length-1;  }
				updateSelection();
		        break;
		      case 65: //A
		        break;
		      case 83: //S
				selectIndex++;
				if(selectIndex > selectionArray.length-1){  selectIndex = 0;  }
				updateSelection();
		        break;
		      case 68: //D
		        break;
		      case 32: //SPACE
			    handleSelection(selectIndex);
		        break;
			}
		  }
		  else if(GAMESTATE == 1){//when its on the game
		    levelMoving = false;
		    switch(e.keyCode){
		      case 87: //W
		        if(cantAct){break;}
		        up = true;
		        player.gotoAndPlay("Up");
		        break;
		      case 65: //A
		        if(cantAct){break;}
		        forward = true;
		        break;
		      case 83: //S
		        if(cantAct){break;}
		        down = true;
		        player.gotoAndPlay("Down");
		        break;
		      case 68: //D
		        if(cantAct){break;}
		        back = true;
		        break;
		      case 32: //SPACE
		        if(cantAct){break;}
		        firing = true;
		        if(keyWentUp){ repeatTime = 0; }
		        keyWentUp = false;
		        break;
		    }
		    player.addEventListener(Event.ENTER_FRAME, moveMe);
		  }
		}
		function onKUp(e:KeyboardEvent):void{
		  player.gotoAndStop(1);
		  switch(e.keyCode){
		    case 87: //W
		      up = false;
		      break;
		    case 65: //A
		      forward = false;
		      break;
		    case 83: //S
		      down = false;
		      break;
		    case 68: //D
		      back = false;
		      break;
		    case 32: //SPACE
		      firing = false;
		      keyWentUp = true;
		      break;
		  }
		}
		function createProjectile(THING:MovieClip, X:Number, Y:Number, dx:Number, dy:Number,THINGCANHASPOWERUP):void {
		  THING.gotoAndPlay("Firing");
		  var newBullet:Bullet = new Bullet();
		  newBullet.x = X;
		  newBullet.y = Y;
		  newBullet.canAttack = true;
		  newBullet.width = bulWidth;
		  newBullet.height = bulHeight;
		  newBullet.dx = dx;
		  newBullet.dy = dy;
		  projectileLayer.addChild(newBullet);
		  newBullet.addEventListener(Event.ENTER_FRAME, onBulletEnterFrame);
		  //trace(THING);
		  //if powerup 2 is active time to make bullets BIGGER
		  if(havePowerup2 && THINGCANHASPOWERUP){
			newBullet.width = bulWidth * 5;
			newBullet.height = bulHeight * 5;
			newBullet.x += newBullet.width;
		  }//end of powrup2 true

		  projectileCount ++;
		  projectileCount %= 10;
		}
		function onBulletEnterFrame(e:Event):void {
		  var targetBullet:MovieClip = MovieClip(e.currentTarget);

		  targetBullet.x += targetBullet.dx;
		  targetBullet.y += targetBullet.dy;

		  if(levelMoving && down)  {  targetBullet.y -= moveSpeed;  }
		  if(levelMoving && up)    {  targetBullet.y += moveSpeed;  }
		  if(targetBullet.x < 0) {
		    targetBullet.removeEventListener(Event.ENTER_FRAME, onBulletEnterFrame);
		    targetBullet.parent.removeChild(targetBullet);
		  } else if(targetBullet.x > 800) {
		    targetBullet.removeEventListener(Event.ENTER_FRAME, onBulletEnterFrame);
		    targetBullet.parent.removeChild(targetBullet);
		  } else {
////////////////////////////////////////////////////////
		  	if(bossActive){
				var boss:MovieClip = MovieClip(bossLayer.getChildByName("theBoss"));
				
					if(bossActive){
						if (targetBullet.hitTestObject(boss)){
							//trace("bossHit")
							
							boss.hp--;
							handleScore(82);
							//trace(boss.hp);
							
							//bossLayer.removeChild(boss);
								//enm.removeEventListener(Event.ENTER_FRAME, onEnemyEnterFrame);
								
								//more score (and seven years ago) har har har hurrrrr
								handleScore(283);
								//stop updating the bullet
								targetBullet.removeEventListener(Event.ENTER_FRAME, onBulletEnterFrame);
								//remove bullet from the screen
								projectileLayer.removeChild(targetBullet);
								
								//THIS KILLS BOSS
								if(boss.hp <= 0){
									endGame("win");

								}//end of boss HP
							}//end of targetBullet
					}//end of active
				
			}//active
////////////////////////////////////////////////////////
		    for(var i:Number = enemyLayer.numChildren-1; i>= 0; i--){
		      var enm:MovieClip = MovieClip(enemyLayer.getChildAt(i));
		      if(targetBullet.hitTestObject(enm) && enm.CanBeAttacked == true /*&& enm.currentFrame == 1*/){
				enm.CanBeAttacked = false;
		        enm.gotoAndPlay("Explode");
				mySound = new AlienExplosion();
				mySound.play();
				//You killed an Eemy now your prize
				var chanceForPowerup:Number = Math.random();
				//trace(chanceForPowerup);
				//25 percent chance for powerup
				if(chanceForPowerup < percentDrop) {
					createPowerup(enm.x, enm.y);
				}//end of chance
				enm.isDead = true;
		        if(targetBullet.width >= bulHeight){
		        	handleScore(250);
		        } 
		        else{
		        	handleScore(100);
		        }
		        targetBullet.removeEventListener(Event.ENTER_FRAME, onBulletEnterFrame)
		        targetBullet.parent.removeChild(targetBullet);
		        break
		      }
			  if(targetBullet.hitTestObject(player) && targetBullet.canAttack){
			  	targetBullet.canAttack = false;
			  	targetBullet.removeEventListener(Event.ENTER_FRAME, onBulletEnterFrame)
			  	targetBullet.parent.removeChild(targetBullet);

				blowUpPlayer();
			  }

		    }//e else
		  }
		}
////////////////////////////////////////////////////////////////////////////////
		//You can no longr use strings to make movies so this is the fancy way to do it now
		function generateMCByString(id:String):MovieClip
		{
			var mcObj:Object = null;
			mcObj = getDefinitionByName(id.toString());
			return (new mcObj()) as MovieClip;
		}//end of generateByString
		function createPowerup(X:Number, Y:Number){
			
							
			//two powerups in the library and named
			//them powerup_1 and powerup_2, so choose 1 or 2
			
			//now i need to pick what type of powerup
			var whichPowerup:Number = Math.floor(Math.random() * 2) + 1;
			
			//this is how you hav to name it now
			var powerUpName:String = "Power" + whichPowerup;
			var thePowerUpIcon:MovieClip = generateMCByString(powerUpName);
			
			//gets the enemy location to drop it
			thePowerUpIcon.x = X;
			thePowerUpIcon.y = Y;
			//this is the spead
			thePowerUpIcon.dx = -5;
			//this says what powerup it is
			thePowerUpIcon.powerUp = whichPowerup;
			

			//create the enterframe for the powerup
			thePowerUpIcon.addEventListener(Event.ENTER_FRAME, powerUpIconEnterFrame);
			
			//addit to the Screen
			powerupLayer.addChild(thePowerUpIcon);
			
			
		}//end of create Powerup


		function powerUpIconEnterFrame(e:Event):void{
				
				var currentPowerUpIcon:MovieClip = MovieClip(e.currentTarget);
				//if the game isn't actually playing
				if(GAMESTATE != 1){ 
					currentPowerUpIcon.parent.removeChild(currentPowerUpIcon);
					currentPowerUpIcon.removeEventListener(Event.ENTER_FRAME, powerUpIconEnterFrame);
				}
				if(levelMoving && down)  {  currentPowerUpIcon.y -= moveSpeed;  }
				if(levelMoving && up)    {  currentPowerUpIcon.y += moveSpeed;  }
				//currentPowerUpIcon._x += currentPowerUpIcon.dx;
				currentPowerUpIcon.x += currentPowerUpIcon.dx;
				
				
				//if its out of the Screen it needs to me removed
				if(currentPowerUpIcon.x <= 0) {
					currentPowerUpIcon.removeEventListener(Event.ENTER_FRAME, powerUpIconEnterFrame);
					currentPowerUpIcon.parent.removeChild(currentPowerUpIcon);
				}
				
				
				//Check to see if the ship picks up the icon
				if(player.hitTestObject(currentPowerUpIcon)) {
					handleScore(Math.round( Math.random() * 600 ));

					//we don't want anything to reset or have it stop early
					//so if you don't have a powerup right now we will allow you get get it
					if(!havePowerup1 && !havePowerup2){
						
						 if(currentPowerUpIcon.powerUp == 1){
							havePowerup2 = false;
							havePowerup1 = true;
							
							//it is function name, millaseconds, arguments 
							setTimeout(turnOffPowerup, 2000);
						}//end of else
						else if(currentPowerUpIcon.powerUp == 2) {
							//trace("i has 2")
							havePowerup2 = true;
							havePowerup1 = false;
							//it is function name, millaseconds, arguments
							setTimeout(turnOffPowerup, 2000);
						
							//setTimeout(_root, "turnOffPowerup", 2000, 2);
						}//end if else
					}//end of don't have powerups
					//remove it, the player has it need to get ride of event listener as well
					currentPowerUpIcon.removeEventListener(Event.ENTER_FRAME, powerUpIconEnterFrame);
					currentPowerUpIcon.parent.removeChild(currentPowerUpIcon);

			}//end of hittest
			
			powerupCount++;
		}//end of powerupenterFrame


		//ned to tunr off the powerups
		function turnOffPowerup():void{

			//jus going to turn them both off
			havePowerup1 = false;
			havePowerup2 = false;
			
			//just a catch
			beamFired = false;
		}//end of powerup


		function createBeam(type:String, X:Number, Y:Number):void{

			//create a new projectile graphic
			var newBeam:Beam = new Beam();
			
			//set its position
			newBeam.x = player.x;
			newBeam.y = player.y;
			newBeam.countdown = 45;

			//add it to the projectile layer
			powerupLayer.addChild(newBeam);
			
			//call onBulletEnterFrame once per frame
			newBeam.addEventListener(Event.ENTER_FRAME, beamOnEnter);

			//increase projectile count (could be used to limit projectiles if needed)
			powerupCount ++;
			powerupCount %= 10;
			
		}//end of createBeam

		function beamOnEnter(e:Event):void{
			
			//gets the beam and puts it in a movieClips
			var targetBeam:MovieClip = MovieClip(e.currentTarget);
			if(levelMoving && down)  {  targetBeam.y -= moveSpeed;  }
			if(levelMoving && up)    {  targetBeam.y += moveSpeed;  }
			//follows the ship
			targetBeam.x = player.x + player.width;
			targetBeam.y = player.y;
			
			//BEAM FIRING
			beamFired = true;
			
			//iterate through every enemy
				for (var i:Number = enemyLayer.numChildren-1; i >= 0; i--)
				{
					//get a refernce to that enemy
					var enm:MovieClip = MovieClip(enemyLayer.getChildAt(i));
					
					//if the bullet is overlapping the enmy & the enemy is on frame one
					if (targetBeam.hitTestObject(enm) && enm.CanBeAttacked == true)
					{
						//play the enemy death
						enm.gotoAndPlay("Explode");
						enm.CanBeAttacked = false;
						mySound = new AlienExplosion();
						mySound.play();
						//more score (and seven years ago)
						score++;
						//update the score on the screen
						handleScore(Math.round(Math.random() * 250) + 50);
						
						var chanceForPowerup:Number = Math.random();
						//25 percent chance for powerup
						if(chanceForPowerup < percentDrop) {
							createPowerup(enm.x, enm.y);
						}//end of chance
						//this will stop the for loop
						break;
					}//end of hitTest
				}//end of forLoop
			
			
				
				///////////////////////////////////////
				//The BEAM
				//the beam kills ALL ENEMIES it hits and is on a timer then it vanishes
				//count down
				targetBeam.countdown--;
						
				//end of countDown
				if(targetBeam.countdown <= 0) {
					targetBeam.parent.removeChild(targetBeam);
					targetBeam.removeEventListener(Event.ENTER_FRAME, beamOnEnter);
					beamFired = false;
					havePowerup1 = false;
				}//end of if

		}//end onPowerEnterFrame
////////////////////////////////////////////////////////////////////////////////
		function gameControl(e:Event):void{
		  if(player.x <= 40){
		  	player.x = 40;
		  }
		  if(player.x >= 750){
		  	player.x = 750;
		  }
		  if(player.y <= 50){
		  	player.y = 50;
		  }
		  if(player.y >= 360){
		  	player.y = 360;
		  }
		  if(enemyActive){
			  //if the enemy
			  if(enemyTime == 0){
			    var sx = Math.random() * 100 + 80; //x between 80 & 180
			    createEnemy("alien",stage.stageWidth + 100, Math.random() * stage.stageHeight);
			    createEnemy("alien",stage.stageWidth + 100, Math.random() * stage.stageHeight);
			    createEnemy("alien",stage.stageWidth + 100, Math.random() * stage.stageHeight);
			  }
			}
		  enemyTime++;
		  enemyTime %= 45;

		  if (firing && repeatTime == 0)
		  {
		    if(havePowerup1) {
				//check if the beam is already being fired
				if(!beamFired) {
					createBeam("beam", player.x, player.y);
				}//end of ifBeam
			}//end of if shipPowerUp
			else{
				createProjectile(player, player.x + 70 + moveSpeed,player.y - 5,10,0,true);
				mySound = new GunShot();
				mySound.play();
			}//end of else
		  }
		  repeatTime ++;  //increase repeat time
		  repeatTime %= fireRate;  //repeatTime is equal to remainder of what is currently in repeatTime when divided by fireRate
		}
		function createEnemy(type:String, X:Number, Y:Number):void {
		  //var currentEnemy:Enemy = new Enemy();
		  var currentEnemy:AlienShipResize = new AlienShipResize();
		  currentEnemy.gotoAndStop(1);
		  currentEnemy.x = X;
		  currentEnemy.y = Y;
		  currentEnemy.scaleX = 0.7;
		  currentEnemy.scaleY = 0.7;
		  currentEnemy.isDead = false;
		  currentEnemy.yline = Math.random() * stage.stageHeight;
		  currentEnemy.dx = Math.random() * 3 + 10;
		  currentEnemy.CanAttack = true;
		  currentEnemy.CanBeAttacked = true;

		  currentEnemy.t = Math.random() * 6;			//these numbers can change
		  enemyLayer.addChild(currentEnemy);
		  currentEnemy.addEventListener(Event.ENTER_FRAME, onEnemyEnterFrame);
		  enemyCount ++;
		  enemyCount %= 10;
		}
		function onEnemyEnterFrame(e:Event):void {
		  var currentEnemy:MovieClip = MovieClip(e.currentTarget);
		  if((Math.random() > 0.99) && currentEnemy.isDead == false){
			createProjectile(currentEnemy, currentEnemy.x - currentEnemy.width, currentEnemy.y, ((-1 * currentEnemy.dx)-5),0,false);
			mySound = new AlienGunShot();
			mySound.play();
		  }
		  var goingDown:Number = 0;
		  var goingUp:Number = 0;
		  //currentEnemy.y = currentEnemy.yline + Math.sin(currentEnemy.t) * 50;
		  if(levelMoving && down)	{		currentEnemy.y -= moveSpeed;		}
		  if(levelMoving && up)		{		currentEnemy.y += moveSpeed;		}
		  //currentEnemy.y = currentEnemy.yline + Math.sin(currentEnemy.t) * 50;

		  currentEnemy.t += 0.1;
		  currentEnemy.x -= currentEnemy.dx;
		  
		  if(/*currentEnemy.currentFrame == 1 &&*/ currentEnemy.CanAttack == true && player.hitTestPoint(currentEnemy.x, currentEnemy.y, true)){
		    currentEnemy.CanAttack = false;
		    currentEnemy.gotoAndPlay("Explode");
			mySound = new AlienExplosion();
			mySound.play();
		   	blowUpPlayer();
		  }
		  if(currentEnemy.x < (0 - currentEnemy.width)){
		    currentEnemy.removeEventListener(Event.ENTER_FRAME, onEnemyEnterFrame);
		    currentEnemy.parent.removeChild(currentEnemy);
		  }
		  if(currentEnemy.currentFrame == currentEnemy.totalFrames){
		    currentEnemy.removeEventListener(Event.ENTER_FRAME, onEnemyEnterFrame);
		    currentEnemy.parent.removeChild(currentEnemy);
		  }
		}
		function blowUpPlayer():void{
			handleLives(-1);
		    cantAct = true;
		    player.gotoAndPlay("Explode");
			mySound = new Explosion();
			mySound.play();
		    stage.addEventListener(Event.ENTER_FRAME, onExplodeEnd);
		}
		function onExplodeEnd(e:Event):void{
		  if(player.currentFrame <= 44/*player.totalFrames*/){
		    if(lives <= 0){
		      stage.removeEventListener(Event.ENTER_FRAME, onExplodeEnd);
		      endGame("lose");
		    }
		    else{
		      cantAct = false;
		      player.gotoAndStop(1);
		      stage.removeEventListener(Event.ENTER_FRAME, onExplodeEnd);
		    }
		  }
		}
		function clearGame():void {
		  stage.removeEventListener(Event.ENTER_FRAME, gameControl);
		  var i:Number = 0;
		  for(i = enemyLayer.numChildren-1; i>=0; i--){
		    var whatever = enemyLayer.getChildAt(i);
		    whatever.removeEventListener(Event.ENTER_FRAME, onEnemyEnterFrame);
		    //enemyLayer.removeChildAt(i);
		    whatever.parent.removeChild(whatever);
		  }
		  for(i = projectileLayer.numChildren; i >= 0; i--){
		    /*projectileLayer.getChildAt(i).removeEventListener(Event.ENTER_FRAME, onBulletEnterFrame);
		    projectileLayer.removeChildAt(i);*/
			//trace(projectileLayer.getChildAt(i));
		  }
		  for(i = bossProjectileLayer.numChildren-1; i >=0; i--){
			var bossMan = bossProjectileLayer.getChildAt(i);
			bossMan.removeEventListener(Event.ENTER_FRAME, onBossBulletEnterFrame);
			//trace(bossProjectileLayer.getChildAt(i).name)
			bossMan.parent.removeChild(bossMan);
			
		  }//end of bullet
		  for(i = 0; i<= bossLayer.numChildren-1; i++){
		  	var bossManBullet = bossLayer.getChildAt(i)
			bossManBullet.removeEventListener(Event.ENTER_FRAME, bossAI);
			//trace(bossLayer.getChildAt(i).name)
			bossManBullet.parent.removeChild(bossManBullet);
			
		  }//end of bullet 

		  removeChild(enemyLayer);
		  removeChild(projectileLayer);
		  removeChild(bossProjectileLayer);
		  removeChild(bossLayer);

		  //the game is over
		  endGameE = true;
		  bossActive = false;
		  enemyActive = true;
		
		  //clearInterval(gameTimer);
		}
		function moveMe(e:Event):void{
		  moveSpeed+= 0.5;
		  if(moveSpeed > 10){ moveSpeed = 10; }
		  if(up)	 {		movePlayer("y", -moveSpeed);	}
		  if(down)	 {		movePlayer("y", moveSpeed);		}
		  if(forward){		movePlayer("x", -moveSpeed);	}
		  if(back)	 {		movePlayer("x", moveSpeed);		}
		  handleCollisions();
		}
		function friction(e:Event):void{
		  moveSpeed-= 0.25;
		  if(moveSpeed < 5){ moveSpeed = 5; }
		}
		function movePlayer(xy:String, moveSpeed:Number):void{
		  if(xy == "x"){	player.x += moveSpeed;			}
		  if(xy == "y"){	player.y += moveSpeed;			}
		}
		function handleCollisions():void{
		  /*if(player.hitTestPoint(Level.x, Level.y, true)){
		    blowUpPlayer();
		  }*/
		  //hahahahaha this function caused more problems than it solved.
		}
		function handleScore(scoreValue:Number):void{
		  score += scoreValue;
		  if( hiScore < score ){
		    hiScore = score;
			UI.HiScore.text = hiScore;
		  }
		  UI.Score.text = score;
		  checkLives();
		}
		function handleLives( a:Number ):void{
		  lives += a; 
		  UI.Lives.gotoAndStop(lives);
		}
		function checkLives():void{
		  if( lives <= 0 )	{	endGame("lose");	}
		  else if( (firstLife == true) &&(score % getFirstLife == 0) && !(score == 0) ){
		    firstLife = false;
		    handleLives(1);
		  }
		  else if( (score % getLifeEvery == 0)){  handleLives(1);  }
		}
		function endGame(winOrLose):void{
		  //stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKDown);
		  //stage.removeEventListener(KeyboardEvent.KEY_UP, onKUp);
		  stage.removeEventListener(Event.ENTER_FRAME, levelMove);
		  player.removeEventListener(Event.ENTER_FRAME, moveMe);
		  this.removeEventListener(Event.ENTER_FRAME, updateTimer);
		  UI.Time.text = 0;
		  
		  //reset Level loc
		  Level.x = LevelX;
		  Level.y = LevelY;
		  Foreground.x = ForegroundX;
		  Foreground.y = ForegroundY;
		  Middleground.x = MiddlegroundX;
		  Middleground.y = MiddlegroundY;

		  
		  if( winOrLose == "win" ){
		    winScreen.visible = true; 
		  } else if( winOrLose == "lose" ){
			loseScreen.visible = true;
		  }
		  addEventListener(MouseEvent.CLICK, startScreen);
		  stage.removeEventListener(Event.ENTER_FRAME, friction);
		  clearInterval(countID);
		  clearGame();

		  up = false;
		  down = false;
		  back = false;
		  forward = false;
		  
		  GAMESTATE = 2;
		}
		function startScreen(e):void{
		  winScreen.visible = false;
		  loseScreen.visible = false;
		  InstructScreen.visible = false;
		  StoryScreen.visible = false;
		  HiScoreScreen.visible = false;
		  removeEventListener(MouseEvent.CLICK, startScreen);
		  Start.visible = true;
		  Start.addEventListener(MouseEvent.CLICK, startGame);
		}
    }
}