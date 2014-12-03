package
{
	import flash.display.Stage3D;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	
	import citrus.core.CitrusObject;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.starling.ViewportMode;
	import citrus.physics.PhysicsCollisionCategories;
	
	import core.decors.Door;
	import core.hero.Player;
	import core.objects.grabbable.Treasure;
	import core.objects.hook.Hook;
	
	import levels.Credit;
	import levels.LoadingScreen;
	import levels.MVLevel;
	import levels.MainLevel;
	import levels.Progression;
	import levels.TitleScreen;
	
	import starling.core.Starling;
	import starling.utils.AssetManager;
	
	
	[SWF(width="800", height="640", frameRate="60", backgroundColor="#000000")]
	public class Gravity extends StarlingCitrusEngine 
	{
		public static var assets:AssetManager;
		private var dossier:String;
		
		public function Gravity()
		{
			assets = new AssetManager(1);
			assets.enqueue(File.applicationDirectory.resolvePath("utils/assets/"));
			assets.enqueue(File.applicationDirectory.resolvePath("utils/maps/"));
			
			_baseWidth = 800;
			_baseHeight = 640;
			_viewportMode = ViewportMode.LETTERBOX;
			fullScreen = true;
			
			setUpStarling(false, 4);
		}
		
		override public function setUpStarling(debugMode:Boolean=false, antiAliasing:uint=1,   viewPort:flash.geom.Rectangle=null, stage3D:Stage3D=null):void
		{
			super.setUpStarling(debugMode, antiAliasing, viewPort, stage3D);
			setUpFilters();
			this.starling.addEventListener("context3DCreate", function(e:*):void {
				loadLevel(LoadingScreen);
			});
		}
		
		private function loadLevel(level:Class, isRestart:Boolean=false):void {
			// Set to TRUE to have the commands like "goto" & others ( for testing only )
			console.enabled = false;
			if ( console.enabled ) {
				addConsoleCommands();
			}
			
			if (state != null) {
				if ( state is LoadingScreen ) {
					(state as LoadingScreen).loadingEnded.removeAll();
				} else if ( state is TitleScreen ) {
					(state as TitleScreen).startGameSignal.removeAll();
				}
			}
			
			Starling.current.stage.alpha = 1;
			
			// Load the new Screen
			state = new level();
			
			if ( state is MainLevel ) {
				(state as MainLevel).lvlEnded.add(ended);
			} else if ( state is LoadingScreen ) {
				assets.verbose = true;
				(state as LoadingScreen).loadingEnded.add(function():void { loadLevel(TitleScreen); });
			} else if ( state is TitleScreen ) {
				(state as TitleScreen).startGameSignal.add( function():void { loadLevel(MainLevel); });
			} else if ( state is Credit ) {
				(state as Credit).alpha = 0;
			} else {
				trace("Unknown level");
			}
		}
		
		private function ended(type:String="credit"):void
		{
			if ( type == "credit" ) {
				loadLevel(Credit);
			} else if ( type == "titlescreen" ) {
				loadLevel(TitleScreen);
			} else {
				loadLevel(TitleScreen); // By default we go back to titlescreen
			}
		}
		
		private function setUpFilters():void
		{
			PhysicsCollisionCategories.Add("Bullets");
			PhysicsCollisionCategories.Add("Hook");
		}
		
		private function addConsoleCommands():void
		{
			console.addCommand("progression", function():void {
				trace(Progression.getAvancement());
			});
			console.addCommand("nape", function():void {
				if ( state != null ) (state as MVLevel).nape.visible = !(state as MVLevel).nape.visible;
			});
			
			console.addCommand("goto", function(x:int = 0, y:int = 0):void {
				if ( state != null ) {
					(state as MVLevel).player.x = 1024 * (x - 0.5);
					(state as MVLevel).player.y = 1024 * (y - 0.5);
				}
			});
			
			console.addCommand("setxy", function(x:int = 0, y:int = 0):void {
				if ( Player.instance != null ) {
					Player.instance.x = x;
					Player.instance.y = y;
				}
			});
			
			console.addCommand("getxy", function():void {
				if ( Player.instance != null ) {
					trace("Player (x, y) : ( " + Player.instance.x + ", " + Player.instance.y + " )");
				}
			});
			
			console.addCommand("give", function(item:String, property:String = ""):void {
				if ( item == "hook" ) {
					Player.hookUnlocked = true;
					Player.instance.hook = new Hook(Player.instance);
					Player.instance.hook.addHook(state as MainLevel)
				} else if ( item == "key" ) {
					if ( property == "cyan" || property == "yellow" || property == "blue" || property == "red" ) {
						Door.desactivateDoor(property);
					}
				} else if ( item == "booster" ) {
					Player.instance.addBooster();
				}
			});
			
			console.addCommand("boss", function():void {
				if ( _state is MainLevel && Player.instance != null ) {
					/*_state.add(new Boss("Artifact Guardian", {
						x: Player.instance.x + 80,
						y: Player.instance.y + 80
					}));*/
					var treasures:Vector.<CitrusObject> = state.getObjectsByType(Treasure);
					for each ( var treasure:Treasure in treasures ) {
						treasure.gather();
					}
				}
			});
		}
	}
}