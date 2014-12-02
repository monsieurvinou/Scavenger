package levels
{
	import citrus.sounds.CitrusSound;
	import com.greensock.TweenLite;
	import flash.media.Sound;
	
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.sounds.CitrusSoundGroup;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;
	
	import utils.assets.Assets;
	
	public class LoadingScreen extends StarlingState
	{
		private var _background:CitrusSprite;
		private var _loadingBarBg:Quad;
		private var _loadingBar:Quad;
		
		public var loadingEnded:Signal;
		
		public function LoadingScreen()
		{
			super();
			loadingEnded = new Signal();
			_background = new CitrusSprite("loading_screen", {width: 800, height: 640, 
				view: new Image(Texture.fromBitmap(new Assets.LoadingScreen())) });
			
			_loadingBarBg = new Quad(800, 24, 0x484848);
		}
		
		override public function initialize():void
		{
			super.initialize();
			alpha = 0;
			_loadingBarBg.alpha = 0;
			add(_background);
			Starling.current.stage.addChild(_loadingBarBg);
			_loadingBarBg.x = 0;
			_loadingBarBg.y = 640-_loadingBarBg.height;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			if ( alpha == 0 ) {
				TweenLite.to ( _loadingBarBg, 1.3, {alpha: 1});
				TweenLite.to(this, 1.3, {alpha: 1, onComplete: loadAssets});
			}
		}
		
		private function loadAssets():void
		{
			// We load the assets
			Gravity.assets.verbose = true;
			Gravity.assets.loadQueue(function(ratio:Number):void
			{
				if ( _loadingBar != null ) _loadingBar.removeFromParent();
				_loadingBar = new Quad(800*ratio + 1, 24, 0xD7D7D7);
				
				_loadingBar.x = _loadingBarBg.x;
				_loadingBar.y = _loadingBarBg.y;
				Starling.current.stage.addChild(_loadingBar);
				
				if ( ratio == 1 ) {
					loadAllSounds();
				}
			});
		}
		
		private function loadAllSounds():void
		{
			_ce.sound.masterVolume = 0.7;
			_ce.sound.getGroup(CitrusSoundGroup.BGM).volume = 0.4;
			_ce.sound.getGroup(CitrusSoundGroup.SFX).volume = 0.5;
			
			var sfxSounds:Array = new Array(
				"missile_explode", "fire_from_turret", "turret_explode", "hero_explode", "boss_explode", "fire_hook", 
				"grab_something", "hit_wall", "message_in", "message_out", "transformation_shipwreck", "healing" , "player_forward"
			);
			
			var bgmSounds:Array = new Array(
				"empty", "title", "part_1", "part_2", "part_3", "part_4", "part_5", "credit"
			);
			
			for each ( var sfxSound:String in sfxSounds ) {
				var loop:int = 0;
				if ( sfxSound == "healing" || sfxSound == "player_forward") loop = -1;
				
				var cSound:Sound = Gravity.assets.getSound(sfxSound);
				trace("Sound : " + sfxSound);
				trace("File : " + cSound);
				
				_ce.sound.addSound(sfxSound, {
					sound: Gravity.assets.getSound(sfxSound),
					group: CitrusSoundGroup.SFX,
					loops: loop
				});
			}
			
			for each ( var bgmSound:String in bgmSounds ) {
				_ce.sound.addSound(bgmSound, {
					sound: Gravity.assets.getSound(bgmSound),
					group: CitrusSoundGroup.BGM,
					loops: 0
				});
			}
			
			TweenLite.to(_loadingBarBg, 1.4, {alpha: 0, onComplete: function():void { _loadingBarBg.removeFromParent(true); }} );
			TweenLite.to(_loadingBar, 1.4, {alpha: 0, onComplete: function():void { _loadingBar.removeFromParent(true); }} );
			TweenLite.to( (_ce.state as LoadingScreen), 2, {alpha: 0, onComplete: function():void {
				loadingEnded.dispatch();
			}});
		}
	}
}