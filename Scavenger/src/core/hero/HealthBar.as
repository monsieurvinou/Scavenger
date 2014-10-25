package core.hero
{
	import flash.geom.Point;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class HealthBar extends Sprite
	{
		protected var _maxHealthBar:Number;
		protected var _healthBar:Number
		// Image ghostBar
		protected var _imgHealthBarTexture:Texture;
		protected var _imgHealthBar:Image;
		// Image ghostBarBackground
		protected var _imgHealthBarBackgroundTexture:Texture;
		protected var _imgHealthBarBackground:Image;
		
		protected var _target:*;
		
		protected var _textOverlay:TextField;
		
		public function HealthBar(typeBar:String, target:*)
		{
			super();
			if (target != null ) _target = target;
			else _target = Player.instance;
			
			if ( typeBar == "hero") {
				_imgHealthBarTexture = Gravity.assets.getTexture("health_bar");
				_imgHealthBarBackgroundTexture = Gravity.assets.getTexture("health_bar_bg");
				_maxHealthBar = 100;
			} else if ( typeBar == "boss" ) {
				_imgHealthBarTexture = Gravity.assets.getTexture("health_bar_boss");
				_imgHealthBarBackgroundTexture = Gravity.assets.getTexture("health_bar_bg_boss");
				_maxHealthBar = 300;
				_textOverlay = new TextField(800, 32, "Artifact Guardian", "Calibri", 18, 0xDDDDDD, true );
				_textOverlay.hAlign = HAlign.CENTER;
				_textOverlay.vAlign = VAlign.CENTER;
			}
			width = _imgHealthBarBackgroundTexture.width;
			height = _imgHealthBarBackgroundTexture.height;
			_healthBar = _target.health;
			_target.healthSignal.add(updateHealthBar);
			
			_healthBar = _target.health;
			
			defineBackground();
			updateHealthBar();
		}
		
		protected function defineBackground():void
		{
			_imgHealthBarBackground = new Image(_imgHealthBarBackgroundTexture);
			_imgHealthBarBackground.width = _imgHealthBarBackgroundTexture.width;
			_imgHealthBarBackground.height = _imgHealthBarBackgroundTexture.height;
			
			addChild(_imgHealthBarBackground);
		}
		
		protected function updateHealthBar():void
		{
			_healthBar = _target.health;
			if ( _imgHealthBar != null ) _imgHealthBar.removeFromParent();
			if ( _textOverlay != null ) _textOverlay.removeFromParent();
			
			_imgHealthBar = new Image(_imgHealthBarTexture);
			
			var widthHealth:Number = (_imgHealthBarBackgroundTexture.width * _healthBar) / _maxHealthBar;
			var heightHealth:Number = _imgHealthBarBackgroundTexture.height;
			
			if ( widthHealth < 0 ) widthHealth = 0;
			
			_imgHealthBar.width = widthHealth;
			_imgHealthBar.height = heightHealth;
			
			var p:Point = new Point(0,0);
			p.x = widthHealth / _imgHealthBarBackgroundTexture.width;
			_imgHealthBar.setTexCoords(1, p);
			p.y = heightHealth /_imgHealthBarBackgroundTexture.height;
			_imgHealthBar.setTexCoords(3, p);
			p.x = 0;
			_imgHealthBar.setTexCoords(2, p);

			addChild(_imgHealthBar);
			if ( _textOverlay != null ) addChild(_textOverlay);
		}
		
	}
}