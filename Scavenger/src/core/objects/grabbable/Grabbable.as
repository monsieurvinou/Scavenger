package core.objects.grabbable
{
	import citrus.objects.NapePhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	
	public class Grabbable extends NapePhysicsObject
	{
		protected var originalMass:Number;
		protected var originalGravMass:Number
		
		
		public function Grabbable(name:String, params:Object=null)
		{
			super(name, params);
			updateCallEnabled = true;
			beginContactCallEnabled = true;
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_body.gravMass = 0;
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void
		{
			super.handleBeginContact(callback);
		}
		
		public function activatePhysic():void
		{
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("Level"), 
					PhysicsCollisionCategories.GetAll()
				)
			);
		}
		
		public function desactivatePhysic():void
		{
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("Level"), 
					PhysicsCollisionCategories.GetNone()
				) 
			);
		}
	}
}