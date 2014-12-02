package utils
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Ease;
	
	import citrus.core.CitrusEngine;
	import citrus.events.CitrusSoundEvent;
	import citrus.input.controllers.Keyboard;
	
	import levels.MainLevel;
	
	import org.osflash.signals.Signal;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	public class MessageBox extends Sprite
	{
		private var _background:Image;
		private var _text:String;
		private var _textField:TextField;
		private var _enter:TextField;
		private static var _instance:MessageBox;
		
		// PUBLIC SWITCHES
		public static var healthMessage:Boolean = false;
		public static var doorMessage:Boolean = false;
		public static var artifactMessage:Boolean = false;
		public static var shipwreckMessage:Boolean = false;
		public static var mapMessage:Number = 0;
		
		public var messageEnding:Signal;
		public var messageStarting:Signal;
		
		private var messageGettingOut:Boolean = false;
		
		private var _theTween:TweenLite;
		
		protected var _listenerAdded:Boolean = false;
		
		public function MessageBox()
		{
			super();
			
			messageEnding = new Signal();
			messageStarting = new Signal();
			
			_background = new Image ( Gravity.assets.getTexture("message_box") );
			_background.x = 0;
			_background.y = 0;
			
			_text = "";
			_textField = new TextField(760, 160, "", "Calibri", 15, 0xCCCCCC, true);
			_textField.hAlign = HAlign.LEFT;
			_textField.vAlign = VAlign.TOP;
			//_textField.border = true;
			_textField.x = 20;
			_textField.y = 20;
			
			_enter = new TextField(800, 24, "<Press ENTER to close this transmission>", "Courier", 13, 0xCCCCCC, true);
			_enter.hAlign = HAlign.CENTER;
			_enter.vAlign = VAlign.CENTER;
			//_textField.border = true;
			_enter.x = 0
			_enter.y = _background.height + 14;
		
			enterMessageOut();
			_theTween.pause();
			
			addChild(_background);
			addChild(_textField);
			addChild(_enter);
			this.alpha = 0;
		}
		
		private function enterMessageOut():void { _theTween = TweenLite.to( _enter, 2, {alpha: 0, ease:Cubic.easeIn, onComplete: enterMessageIn}); }
		private function enterMessageIn():void { _theTween = TweenLite.to( _enter, 2, {alpha: 1, ease:Cubic.easeOut, onComplete: enterMessageOut}); }
			
		
		public function affiche(message:String):void
		{
			_text = message;
			_textField.text = _text;
			Starling.current.stage.addChild(this);
			messageStarting.dispatch();
			_theTween.play();
			TweenLite.to(this, 1, {alpha: 1});
			if ( !(CitrusEngine.getInstance()).sound.getSound("message_in").hasEventListener(CitrusSoundEvent.SOUND_END) ) {
				(CitrusEngine.getInstance()).sound.getSound("message_in").addEventListener(
					CitrusSoundEvent.SOUND_END, prepareEndMessage
				);
			}
			(CitrusEngine.getInstance()).sound.playSound("message_in");
		}
		
		protected function prepareEndMessage():void
		{
			// Message exist
			if  ( !_listenerAdded ) {
				Starling.juggler.delayCall( function():void {
					Starling.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
				}, 1.5 );
				_listenerAdded = true;
			}
		}
		
		protected function onKey(e:KeyboardEvent):void {
			if ( !messageGettingOut && _theTween.isActive()) {
				if ( e.keyCode == Keyboard.ENTER ) {
					messageGettingOut = true;
					TweenLite.to( this, 0.4, {alpha: 0, onComplete: removeMessage});
					(CitrusEngine.getInstance()).sound.playSound("message_out");
				}
			}
		}
		
		public function reboot():void
		{
			MessageBox.healthMessage = false;
			MessageBox.doorMessage = false;
			MessageBox.artifactMessage = false;
			MessageBox.shipwreckMessage = false;
			MessageBox.mapMessage = 0;
		}
		
		protected function removeMessage():void
		{
			_theTween.pause();
			//Starling.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
			messageGettingOut = false;
			this.removeFromParent();
			messageEnding.dispatch();
		}
		
		
		public static function get instance():MessageBox 
		{
			if ( _instance == null ) _instance = new MessageBox();
			return _instance;
		}
	}
}