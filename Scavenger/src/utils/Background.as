package utils
{
	import flash.geom.Point;
	
	import citrus.objects.CitrusSprite;
	import citrus.view.ACitrusCamera;
	
	import core.hero.Player;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class Background extends CitrusSprite
	{
		private var _tiles:Texture;
		private var _widthScene:Number;
		private var _heightScene:Number;
		private var _imageFinale:Image;
		
		
		public function Background(name:String, params:Object=null)
		{
			super(name, params);
			_tiles.repeat = true;
			var heightImage:Number = (_heightScene/_tiles.height) + 4;
			var widthImage:Number = (_widthScene/_tiles.width) + 4;

			_imageFinale = new Image(_tiles);
			_imageFinale.alpha = 0.7;

			_imageFinale.width = widthImage * _tiles.width;
			_imageFinale.height = heightImage * _tiles.height;

			_imageFinale.setTexCoords(1, new Point(widthImage, 0) );
			_imageFinale.setTexCoords(2, new Point(0, heightImage) );
			_imageFinale.setTexCoords(3, new Point(widthImage, heightImage) );
			
			this.view = _imageFinale;
			this.width = _imageFinale.width;
			this.height = _imageFinale.height;
		}
		
		public function updateBackground(camera:ACitrusCamera):void 
		{
			if ( camera.camPos.x - (x + width/2) <= -_tiles.width || camera.camPos.x - (x + width/2) >= _tiles.width ) {
				if((x + width/2) < camera.camPos.x) x += _tiles.width;
				else x -= _tiles.width;
			}
			if ( camera.camPos.y - (y + height/2) <= -tiles.height || camera.camPos.y - (y + height/2) >= _tiles.height ) {
				if ( (y + height/2) < camera.camPos.y ) y += _tiles.height;
				else y -= _tiles.height;
			}
			
		}
		
		public function get tiles():Texture { return _tiles; }
		public function get widthScene():Number { return _widthScene; }
		public function get heightScene():Number { return _heightScene; }
		
		public function set tiles(value:Texture):void { _tiles = value; }
		public function set widthScene(value:Number):void { _widthScene = value; }
		public function set heightScene(value:Number):void { _heightScene = value; }
		
	}
}