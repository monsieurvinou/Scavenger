package core.decors
{
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.PhysicsCollisionCategories;
	import utils.MessageContent;
	
	import core.hero.Player;
	
	import nape.dynamics.InteractionFilter;
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	
	import starling.display.Quad;
	
	import utils.MessageBox;
	
	public class Door extends Platform
	{
		protected var _color:String = "";
		public static var listDoors:Array;
		
		
		public function Door(name:String, params:Object=null)
		{
			super(name, params);
			if ( listDoors == null ) listDoors = new Array();
			if ( listDoors.indexOf(this) < 0 ) listDoors.push(this);
			createView();
			updateCallEnabled = true;
		}
		
		protected function createView():void
		{
			var colorValue:uint = 0xFFFFFF;
			switch ( _color ) {
				case "blue": colorValue = 0x3333FF; break;
				case "red": colorValue = 0xFF3333; break;
				case "yellow": colorValue = 0xEAE317; break;
				case "cyan": colorValue = 0x17EAE3; break;
			}
			
			var quad:Quad = new Quad(_width, _height, colorValue);
			
			view = quad;
		}
		
		override protected function createFilter():void
		{
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("Level"), 
					PhysicsCollisionCategories.GetAll()
				)
			);
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			if ( !MessageBox.doorMessage ) {
				if ( Vec2.distance( new Vec2(x,y), new Vec2(Player.instance.x, Player.instance.y) ) <= 200 ) {
					var ray:Ray = Ray.fromSegment(new Vec2(x,y), new Vec2(Player.instance.x, Player.instance.y));
					var rayResult:RayResult = this.body.space.rayCast(ray);
					if ( rayResult ) {
						if ( Player.instance.body.contains( ray.at(rayResult.distance) ) ) {
							MessageBox.doorMessage = true;
							if ( !Player.hookUnlocked ) {
								MessageBox.instance.affiche(MessageContent.getMessage("see_door_not_hook"));
							} else {
								MessageBox.instance.affiche(MessageContent.getMessage("see_door_hook_unlock"));
							}
						}
					}
				}
			}
		}
		
		public static function desactivateDoor(colorParameter:String):void
		{
			switch(colorParameter)
			{
				case "red":
					MessageBox.instance.affiche(MessageContent.getMessage("unlock_door_red"));
				break;
				case "blue":
					MessageBox.instance.affiche(MessageContent.getMessage("unlock_door_blue"));
				break;
				case "yellow":
					MessageBox.instance.affiche(MessageContent.getMessage("unlock_door_yellow"));
				break;
				case "cyan":
					MessageBox.instance.affiche(MessageContent.getMessage("unlock_door_cyan"));
				break;
			}
			for ( var i:int = 0; i<listDoors.length; i++ ) {
				var door:Door = listDoors[i];
				if ( door.color == colorParameter ) {
					door.kill = true; // We destroy all the "color" door.
				}
			}
		}
		
		public function get color():String  { return _color; }
		public function set color(value:String):void { _color = value; }
	}
}