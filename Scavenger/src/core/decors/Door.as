package core.decors
{
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.PhysicsCollisionCategories;
	
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
								MessageBox.instance.affiche("Pilot.\n" +
									"Do you see this thing? It kind of look like a door. I think it is linked to something our radars located.\n" +
									"It looks like a shipwreck with something being able to destroy those doors. The only one we located " +
									"is around the coordinates (9,5).\n\n" +
									"By the way, you should go around the (16,10) to get something to tow the shipwreck back to the station.\n\n" +
									"Over & out.");
							} else {
								MessageBox.instance.affiche("Pilot.\n" +
									"Do you see this thing? It kind of look like a door. I think it is linked to something our radars located.\n" +
									"It looks like a shipwreck with something being able to destroy those doors. The only one we located " +
									"is around the coordinates (9,5).\n\n" +
									"Over & out.");
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
					MessageBox.instance.affiche("Pilot.\n" +
						"We have successfully desactivated the red doors. You should be able to explore more of this sector.\n\n" +
						"Over & out.");
				break;
				case "blue":
					MessageBox.instance.affiche("Pilot.\n" +
						"We have successfully desactivated the blue doors.\n" +
						"We also retrieved some old music from this shipwreck, but I don't think you can use it in any way.\n" +
						"You can continue your mission.\n\n" +
						"Over & out.");
				break;
				case "yellow":
					MessageBox.instance.affiche("Pilot.\n" +
						"Yellow doors destroyed! It is starting to feel like a cheap way to make your mission longer.\n" +
						"Sorry for the inconvinience.\n\n" +
						"Over & out.");
				break;
				case "cyan":
					MessageBox.instance.affiche("Pilot.\n" +
						"Cyan doors destroyed. We think it was the last ones. Well, we just didn't located any other shipwreck in the area.\n" +
						"I don't think I'll be communicating with you anymore, unless you find something interesting.\n" +
						"Keep up the good work.\n\n" +
						"Over & out.");
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