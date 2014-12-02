package levels
{
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import utils.MessageContent;
	
	import utils.MessageBox;
	
	public class MapHidder extends Sprite
	{
		private var _explored:Array;
		private var _hidders:Array;
		private var _heroPosition:Image;
		 
		public function MapHidder()
		{
			super();
			
			width = 504;
			height = 504;
			
			_explored = new Array();
			_hidders = new Array();
			
			
			for ( var i:int = 0; i < 24 ; i++ ) {
				for ( var j:int = 0; j < 24; j++ ) {
					if (j == 0) {
						_explored[i] = new Array();
						_hidders[i] = new Array();
					}
					_explored[i][j] = false;
					_hidders[i][j] = new Quad(21,21, 0x555555);
					(_hidders[i][j] as Quad).x = i*21;
					(_hidders[i][j] as Quad).y = j*21;
					this.addChild(_hidders[i][j]);
				}
			}
		}
		
		public function isExplored(chunkX:int, chunkY:int):Boolean
		{
			if (!isNaN(chunkX) && !isNaN(chunkY) && chunkX < 25 && chunkY < 25 && chunkX > 0 && chunkY > 0 ) {
				return _explored[chunkX-1][chunkY-1];
			} else return true;
		}
		
		public function explore(chunkX:int, chunkY:int):void
		{
			if (!isNaN(chunkX) && !isNaN(chunkY) && chunkX < 25 && chunkY < 25 && chunkX > 0 && chunkY > 0 ) {
				if ( MessageBox.mapMessage <= 3 ) {
					if (MessageBox.mapMessage == 3 ) {
						MessageBox.mapMessage += 1;
						MessageBox.instance.affiche(MessageContent.getMessage("map"));
					} else if ( MessageBox.mapMessage < 3 ) {
						MessageBox.mapMessage += 0.5;
					}
				}
				(_hidders[chunkX-1][chunkY-1] as Quad).removeFromParent(true);
				_explored[chunkX-1][chunkY-1] = true;
			}
		}
	}
}