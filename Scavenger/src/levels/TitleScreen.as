package levels
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import citrus.core.starling.StarlingState;
	import citrus.sounds.CitrusSoundGroup;
	import citrus.sounds.SoundManager;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class TitleScreen extends StarlingState
	{
		private var _background:Image;
		private var _title:Image;
		private var _text:TextField;
		
		private var _animate:Boolean = false;
		private var _tweenText:TweenLite;
		private var _tweenTitle:TweenLite;
		
		public var startGameSignal:Signal;
		
		public function TitleScreen()
		{
			super();
			_background = new Image( Gravity.assets.getTexture("title_screen_bg") );
			_title = new Image( Gravity.assets.getTexture("title_screen_text") );
			_text = new TextField(400, 76, "<Press any key to start>", "Courier", 64, 0xCCCCCC, true);
			startGameSignal = new Signal();
		}
		
		override public function initialize():void
		{
			super.initialize();
			alpha = 1;
			Starling.current.stage.addChild(_background);
			Starling.current.stage.addChild(_title);
			Starling.current.stage.addChild(_text);
			_title.blendMode = BlendMode.SCREEN;
			_title.alpha = 0.9;
			_text.alpha = 0;
			_text.x = 200;
			_text.y = 500;
			_text.hAlign = HAlign.CENTER;
			_text.vAlign = VAlign.CENTER;
			
			Starling.current.stage.alpha = 0;
			TweenLite.to( Starling.current.stage, 2, {alpha: 1, onComplete: function():void { 
				_animate = true;
				_ce.input.keyboard.onKeyDown.add(startGame);
			}});
			
			_ce.sound.playSound("title");
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			if ( _animate ) {
				if ( _tweenText == null ) textMessageIn();
				if ( _tweenTitle == null ) titleMessageOut();
			}
		}
		
		private function startGame(keyCode:int,keyLocation:int):void 
		{
			TweenLite.to(_ce.sound.getSound("title"), 4, {volume: 0, onComplete: function():void {
				_ce.sound.stopSound("title");
			}});
			TweenLite.to( Starling.current.stage, 4, {alpha: 0, onComplete: function():void {
				// Destroy everything ( except the textures, we might need them if we die and want to go back to the title screen )
				_tweenText.kill();
				_tweenTitle.kill();
				_background.removeFromParent();
				_text.removeFromParent();
				_title.removeFromParent();
				_ce.input.keyboard.onKeyDown.remove(startGame);
				startGameSignal.dispatch();
			}});
		}
		
		private function textMessageOut():void { _tweenText = TweenLite.to( _text, 2, {alpha: 0, ease:Cubic.easeIn, onComplete: textMessageIn}); }
		private function textMessageIn():void { _tweenText = TweenLite.to( _text, 2, {alpha: 1, ease:Cubic.easeOut, onComplete: textMessageOut}); }
		private function titleMessageOut():void { _tweenTitle = TweenLite.to( _title, 9, {alpha: 0.6, ease:Cubic.easeIn, onComplete: titleMessageIn}); }
		private function titleMessageIn():void { _tweenTitle = TweenLite.to( _title, 2, {alpha: 0.86, ease:Cubic.easeInOut, onComplete: titleMessageOut}); }
		
	}
}