package core.objects.hook
{
	import flash.geom.Point;
	
	import citrus.objects.CitrusSprite;
	
	import core.hero.Player;
	
	import nape.geom.Vec2;
	
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	public class HookString extends CitrusSprite
	{
		private var _imageView:Image;
		private var _textureLine:Texture;
		
		public function HookString(line:Vec2)
		{
			super("hook_string");
			_textureLine = Gravity.assets.getTexture("hook_string");
			_imageView = new Image(_textureLine);
			handleSizeChange(line);
			view = _imageView;
		}
		
		public function handleSizeChange(line:Vec2):void
		{
			if ( Hook.isFiring ) {
				_imageView.width = line.length;
				_imageView.alpha = 1;
				
				_imageView.height = _textureLine.height;
				_imageView.setTexCoords(1, new Point(_imageView.width/_textureLine.width,0));
				_imageView.setTexCoords(2, new Point(0,1));
				_imageView.setTexCoords(3, new Point(_imageView.width/_textureLine.width,1));
			} else {
				_imageView.width = 10;
				_imageView.alpha = 0;
			}
			_imageView.x = -_imageView.width/2;
			rotation = rad2deg(line.angle) - 90;
		}
	}
}