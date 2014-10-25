package core.decors
{
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.PhysicsCollisionCategories;
	
	import nape.shape.Circle;
	
	public class Planete extends Platform
	{
		private var _rayon:Number = 50;
		
		public function Planete(name:String, params:Object=null)
		{
			super(name, params);
			
		}
		
		public function get rayon():Number { return _rayon; }
		public function set rayon(value:Number):void { _rayon = value;}

		override protected function createShape():void {
			super.createShape();
			var sha:Circle = new Circle(_rayon);
			body.shapes.clear();
			body.shapes.add(sha);
			_shape.filter.collisionGroup = PhysicsCollisionCategories.Get("Level");
		}
	}
}