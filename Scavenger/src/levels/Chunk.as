package levels
{
	import citrus.core.CitrusObject;
	import citrus.objects.CitrusSprite;
	import citrus.utils.objectmakers.ObjectMaker2D;
	
	import starling.display.Image;

	public class Chunk extends CitrusObject
	{
		private static var _state:MVLevel;
		public static const EMPTY:String = "empty";
		protected var _map:String;
		protected var _offsetX:Number;
		protected var _offsetY:Number;
		protected var _xml:XML;
		protected var _bg:CitrusSprite;
		
		public function Chunk(map:String, offsetX:Number, offsetY:Number)
		{
			super("");
			_state = _ce.state as MVLevel;
			_map = map;
			_offsetX = offsetX;
			_offsetY = offsetY;
			if ( _map != Chunk.EMPTY && _map != "") {
				_xml = Gravity.assets.getXml(_map);
				_bg = new CitrusSprite("", {view: new Image(Gravity.assets.getTexture(_map))});
			}
		}
		
		public function addElements():void
		{
			if ( _map != Chunk.EMPTY ) {
				// Load the map
				var chunkObjects:Array = ObjectMaker2D.FromTiledMap(_xml, [], false);
				for each ( var obj:* in chunkObjects ) {
					obj.x += _offsetX;
					obj.y += _offsetY;
					Chunk._state.add(obj);
				}
				_bg.x = _offsetX;
				_bg.y = _offsetY;
				Chunk._state.add(_bg);
			}
		}
		
		public function set offsetX(value:Number):void { _offsetX = value; }
		public function set offsetY(value:Number):void { _offsetY = value; }
	}
}