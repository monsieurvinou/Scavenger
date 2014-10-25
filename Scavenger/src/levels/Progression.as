package levels
{
	public class Progression
	{
		private static var _treasureFound:Array;
		
		public function Progression()
		{
			throw new Error("Can't be instanced");
		}
		
		public static function initGame():void
		{
			_treasureFound = new Array();
			_treasureFound[0] = false;
			_treasureFound[1] = false;
			_treasureFound[2] = false;
			_treasureFound[3] = false;
			_treasureFound[4] = false;
			_treasureFound[5] = false;
			_treasureFound[6] = false;
			_treasureFound[7] = false;
		}
		
		public static function found(index:int):void
		{
			if ( !isNaN(index) ) {
				_treasureFound[index] = true;
			}
		}
		
		public static function getAvancement():int
		{
			var treasureFound:int = 0;
			for each ( var tfound:Boolean in _treasureFound ) {
				if ( tfound ) treasureFound++;
			}
			
			return treasureFound;
		}
		
		public static function reboot():void
		{
			_treasureFound[0] = false;
			_treasureFound[1] = false;
			_treasureFound[2] = false;
			_treasureFound[3] = false;
			_treasureFound[4] = false;
			_treasureFound[5] = false;
			_treasureFound[6] = false;
			_treasureFound[7] = false;
		}
		
		public static function foundAll():Boolean
		{
			var foundAll:Boolean = true;
			for (var i:int = 0; i<_treasureFound.length; i++ ) {
				if ( !_treasureFound[i] ) {
					foundAll = false;
					break;
				}
			}
			
			return foundAll;
		}
		
		
		
	}
}