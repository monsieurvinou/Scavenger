package levels
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import flash.geom.Point;
	
	import citrus.core.CitrusObject;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.events.CitrusSoundEvent;
	import citrus.objects.platformer.nape.Platform;
	
	import core.decors.Decors;
	import core.decors.Door;
	import core.decors.ZoneBase;
	import core.ennemies.Boss;
	import core.ennemies.Turret;
	import core.hero.HealthBar;
	import core.hero.Player;
	import core.objects.Collectible;
	import core.objects.grabbable.Grabbable;
	import core.objects.grabbable.Missile;
	import core.objects.grabbable.Shipwreck;
	import core.objects.grabbable.Treasure;
	
	import nape.geom.Vec2;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import utils.Background;
	import utils.MessageBox;
	import utils.assets.Assets;
	
	public class MainLevel extends MVLevel
	{

		// UI
		private var _position:TextField;
		private var _healthBar:HealthBar;
		private var _bossBarHealth:HealthBar 
		
		// MAP
		public var isMapShowed:Boolean = false;
		private var _modal:Quad;
		private var _map:Image;
		private var _hidderMap:MapHidder;
		private var _cursor:MovieClip;
		
		/// ANIMATION
		private var _whiteScreen:Quad;
		public var isShaking:Boolean = false;
		public var shakeFactor:Number = 5;
		
		
		public var songPlaying:String = "empty";
		
		public function MainLevel()
		{
			super();
			var object:Object = [Decors, Platform, Collectible, Shipwreck, Missile, Turret, Door, Treasure, ZoneBase];
			_position = new TextField(400, 64, "", "Courier", 24, 0xFFFFFF, true);
			Progression.initGame();
			_map = new Image ( Gravity.assets.getTexture("map") );
			_map.alpha = 0;
			_modal = new Quad( 
				Starling.current.stage.stageWidth,
				Starling.current.stage.stageHeight,
				0x000000
			);
			_modal.alpha = 0;
			
			// Hidders
			_hidderMap = new MapHidder();
			_hidderMap.alpha = 0;
			
			// Cursor
			var ta:TextureAtlas = new TextureAtlas( 
				Texture.fromBitmap(new Assets.SpriteSheetCursorMapTexture() ),
				new XML( new Assets.SpriteSheetCursorMapXml() )
			);
			_cursor = new MovieClip(ta.getTextures("cursor_map"), 2);
			Starling.juggler.add(_cursor);
			_cursor.alpha = 0;
			
			// Position
			_map.x = Starling.current.stage.stageWidth/2 - _map.width/2;
			_map.y = Starling.current.stage.stageHeight/2 - _map.height/2;
			
			_hidderMap.x = _map.x;
			_hidderMap.y = _map.y;
			
			Treasure.triggerBoss.add( triggerBoss );
		}
		
		public function removeUI():void
		{
			_cursor.removeFromParent();
			_map.removeFromParent();
			_healthBar.removeFromParent();
			if ( _bossBarHealth != null ) _bossBarHealth.removeFromParent();
			_hidderMap.removeFromParent();
			_position.removeFromParent();
		}
		
		public function goToCredit():void
		{
			endLevel("credit");
		}
		
		public function goToTitle():void
		{
			// ROLL BACK TO 0 before going to title screen
			// Remove Progression
			Progression.reboot();
			// Remove Treasure Found
			Treasure.reboot();
			// Remove all the Messages that have been displayed
			MessageBox.instance.reboot();
			// Player reboot
			Player.instance.reboot();
			
			endLevel("titlescreen");
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			handleSong(true);
		}
		
		private function playSound(song:String):void 
		{
			_ce.sound.getSound(songPlaying).volume = 0;
			_ce.sound.getSound(songPlaying).stop();
			_ce.sound.getSound(song).volume = 0;
			_ce.sound.playSound(song);
			TweenLite.to(_ce.sound.getSound(song), 4, {volume: 1});
			if ( ! _ce.sound.getSound(song).hasEventListener(CitrusSoundEvent.SOUND_END) ) {
				_ce.sound.getSound(song).addEventListener(CitrusSoundEvent.SOUND_END, handleSong);
			}
			songPlaying = song;
		}
		
		private function handleSong(firstPlay:Boolean=false):void
		{
			var songName:String = "empty";
			if ( songPlaying == "empty" ) {
				if ( Progression.getAvancement() < 2 ) {
					songName = "part_1";
				} else if ( Progression.getAvancement() < 4 ) {
					songName = "part_2";
				} else if ( Progression.getAvancement() < 6 ) {
					songName = "part_3";
				} else if ( Progression.getAvancement() < 8 ) {
					songName = "part_4";
				} else {
					songName = "part_5";
				}
			} else {
				songName = "empty";
			}
			
			if ( songName != "" ) {
				if ( firstPlay ) {
					playSound(songName);
				} else {
					Starling.juggler.delayCall(playSound, (Math.random() * 80), songName);
				}
			}
		}
		
		private function triggerBoss(state:String = ""):void
		{
			if ( state == "" ) {
				MessageBox.instance.messageEnding.add( function startBossAnimation():void {
					triggerBoss("animation");
					MessageBox.instance.messageEnding.remove(startBossAnimation);
				});
				MessageBox.instance.affiche("Pilot.\n" +
					"Everyone here is congratuling you. You did a really good job gathering all those artifacts.\n\n" +
					"We will try to suck the power out of them and then teleport you back to our mothership.\n\n" +
					"Nothing to worry about.\n\n" +
					"Nothing's going to happen.\n" +
					"But stay on guard. You know... just in case.\n\n" +
					"Over & out.");
			} else if ( state == "animation") {
				_ce.sound.getSound(songPlaying).removeEventListeners();
				TweenLite.to( _ce.sound.getSound(songPlaying), 6, {volume: 0, onComplete: function ():void {
					_ce.sound.getSound(songPlaying).stop();
				}});
				Player.instance.controlsEnabled = false;
				Player.instance.body.velocity = new Vec2();
				
				var trianglePos:Vec2 = new Vec2(11722, 1648);
				var listTreasure:Vector.<CitrusObject> = getObjectsByType(Treasure);
				for each ( var treasure:Treasure in listTreasure ) {
					treasure.desactivatePhysic();
					if ( treasure.id == 1 ) {
						view.camera.target = null;
						view.camera.manualPosition = new Point(Player.instance.x, Player.instance.y);
						TweenLite.to(view.camera.manualPosition, 9, { x: trianglePos.x, y: trianglePos.y});
						TweenLite.to( treasure, 8, {x: trianglePos.x, y: trianglePos.y, rotation: 0, ease: Cubic.easeOut, onComplete: function():void {
							_whiteScreen = new Quad(800,640, 0xFFFFFF);
							_whiteScreen.alpha = 0;
							Starling.current.stage.addChild(_whiteScreen);
							
							isShaking = true;
							shakeFactor = 1;
							TweenLite.to( _ce.state, 4, {shakeFactor: 10});
							
							TweenLite.to( _whiteScreen, 5, {alpha: 1, ease: Cubic.easeIn, onComplete: function():void{
								isShaking = false;
								shakeFactor = 5;
								activeBoss(trianglePos);
							}});
						}});
					} else {
						TweenLite.to( treasure, 8, {x: trianglePos.x, y: trianglePos.y, rotation: 0, ease: Cubic.easeOut});
					}
				}
			}
		}
		
		public function activeBoss(position:Vec2):void {
			playSound("part_5");
			// We remove all the treasures
			// We create the boss
			var boss:Boss = new Boss("Artifact Guardian");
			add(boss);
			
			var listTreasures:Vector.<CitrusObject> = getObjectsByType(Treasure);
			for each ( var treasure:Treasure in listTreasures ) {
				treasure.kill = true;
			}
			
			boss.x = position.x;
			boss.y = position.y;
			
			x = 0; y = 0;
			
			TweenLite.to( _whiteScreen, 3, {alpha: 0, onComplete: function():void {
				TweenLite.to( view.camera.manualPosition, 3, {x: Player.instance.x, y: Player.instance.y, 
					onComplete: function():void {
						view.camera.target = Player.instance;
						_bossBarHealth = new HealthBar("boss", boss);
						_bossBarHealth.x = 0;
						_bossBarHealth.y = 0;
						_bossBarHealth.alpha = 0;
						Starling.current.stage.addChild(_bossBarHealth);
						TweenLite.to(_bossBarHealth, 0.5, {alpha: 1});
						Player.instance.controlsEnabled = true;
				}});
			}});
		}
		
		override protected function addElements():void
		{
			super.addElements();
			
			// We add the UI
			_position.x = 400 - _position.width/2;
			_position.y = 640 - _position.height;
			_position.alpha = 0.75;
			Starling.current.stage.addChild(_position);
			
			_healthBar = new HealthBar("hero", Player.instance);
			_healthBar.x = 15;
			_healthBar.y = 598;
			Starling.current.stage.addChild(_healthBar);
			
			player.x = 11776;
			player.y = 512;
			player.rotation = 160;
			
			// On ajoute le background
			bg = new Background("Background", {
				tiles: Gravity.assets.getTexture("star_1"), 
				widthScene: 800,
				heightScene: 640
			});
			add(bg);
			
			createMap();
			
			bg.x = player.x - bg.widthScene/2;
			bg.y = player.y - bg.heightScene/2;
			
			// MAP
			Starling.current.stage.addChild( _modal );
			Starling.current.stage.addChild( _map );
			Starling.current.stage.addChild(_cursor);
			Starling.current.stage.addChild(_hidderMap);
		}
		
		protected function createMap():void
		{
			// Generate the bounds
			createBounds();
			
			var specialChunk:Chunk;
			var mapName:String = "";
			// Each line
			for ( var x:int = 0; x<24; x++ ) {
				// Each column
				for ( var y:int = 0; y<24; y++ ) {
					/********** SPECIAL CHUNKS ***********/ 
					if ( x==11 && y==0 ) { // Start / Garage
						mapName = "S";
					} else if(x==15 && y==9) { // HOOK
						mapName = "H";
					} else if (x==4 && y==10) { // Phaser A
						mapName = "PA";
					} else if (x==13 && y==22) { // Phaser B
						mapName = "PB";
					}
					
					/****** SHIP WRECK *********/
					else if (x==8 && y==4) { // epave RED
						mapName = "E1";
					} else if (x==5 && y==17) { // epave BLUE
						mapName = "E2";
					} else if (x==20 && y==5) { // epave YELLOW
						mapName = "E3";
					} else if (x==18 && y==13) { // epave CYAN
						mapName = "E4";
					}
					
					/********* TREASURES ***********/
					else if (x==14 && y==3) { // Treasure 1
						mapName = "T1";
					} else if (x==22 && y==3) { // Treasure 2
						mapName = "T2";
					} else if (x==9 && y==16) { // Treasure 3
						mapName = "T3";
					} else if (x==2 && y==1) { // Treasure 4
						mapName = "T4";
					} else if (x==1 && y==22) { // Treasure 5
						mapName = "T5";
					} else if (x==2 && y==13) { // Treasure 6
						mapName = "T6";
					} else if (x==21 && y==20) { // Treasure 7
						mapName = "T7";
					} else if (x==11 && y==11) { // Treasure 8
						mapName = "T8";
					} else {
						mapName = "";
					}
					
					if ( mapName != "" ) {
						specialChunk = new Chunk(mapName, x*1024, y*1024);
						specialChunk.addElements();
					}
				}
			}
		}
		
		public function getGrabbable():Vector.<CitrusObject>
		{
			return this.getObjectsByType(Grabbable);
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			if ( isShaking ) {
				x = Math.random() * shakeFactor - shakeFactor;
				y = Math.random() * shakeFactor - shakeFactor;
			}
			
			// We find where the player is
			var coords:Vec2 = new Vec2(player.x, player.y);
			coords.x /= 1024; coords.y /= 1024;
			coords.x = Math.floor(coords.x) + 1;
			coords.y = Math.floor(coords.y) + 1;
			_position.text = "( " + coords.x + " : " + coords.y + " )";
			// Hidder map handler
			if ( !_hidderMap.isExplored(coords.x, coords.y) ) {
				_hidderMap.explore(coords.x, coords.y);
			}
			// Cursor position update
			_cursor.x = _map.x + (coords.x - 1) * 21 + 1;
			_cursor.y = _map.y + (coords.y - 1) * 21 + 1;
			
			if ( _ce.input.justDid("map", 1) && Player.instance.controlsEnabled) {
				if ( MessageBox.mapMessage < 3 ) MessageBox.mapMessage = 10; // No need to explain them the map
				if ( _map.alpha == 1 ) {
					isMapShowed = false;
					TweenLite.to ( _map, 0.05, {alpha: 0});
					TweenLite.to ( _cursor, 0.05, {alpha: 0});
					TweenLite.to ( _modal, 0.2, {alpha: 0});
					TweenLite.to ( _hidderMap, 0.2, {alpha: 0});
				} else {
					isMapShowed = true;
					TweenLite.to ( _map, 0.3, {alpha: 1});
					TweenLite.to ( _cursor, 0.3, {alpha: 1});
					TweenLite.to ( _modal, 0.2, {alpha: 0.75});
					TweenLite.to ( _hidderMap, 0.05, {alpha: 1});
				}
			}
		}
		
		public function pause():void
		{
			_ce.playing = !_ce.playing;
		}
	}
}