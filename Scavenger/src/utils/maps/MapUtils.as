package utils.maps
{
	import citrus.utils.objectmakers.ObjectMaker2D;

	public class MapUtils
	{
		public function MapUtils()
		{
		}
		
		public static function getMap(mapName:String):Array
		{
			return ObjectMaker2D.FromTiledMap( Gravity.assets.getXml(mapName), [], false);
		}
	}
}