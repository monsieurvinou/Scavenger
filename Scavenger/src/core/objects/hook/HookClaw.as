package core.objects.hook
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.nape.NapeUtils;
	
	import core.decors.ZoneBase;
	import core.objects.grabbable.Grabbable;
	
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.phys.BodyType;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	
	public class HookClaw extends Sensor
	{
		
		public var retractSignal:Signal;
		public var listContact:Array;
		
		public function HookClaw()
		{
			super("hook_claw", {width: 16, height: 16});
			view = new Image( Gravity.assets.getTexture("hook_claw") );
			retractSignal = new Signal();
			beginContactCallEnabled = true;
			endContactCallEnabled = true;
			listContact = new Array();
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_body.type = BodyType.KINEMATIC;
		}
		
		override protected function createFilter():void
		{
			super.createFilter();
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("Hook"), 
					PhysicsCollisionCategories.GetAll()
				)
			);
		}
		
		override public function handleBeginContact(interactionCallback:InteractionCallback):void
		{
			super.handleBeginContact(interactionCallback);
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, interactionCallback);
			if ( collider is Grabbable && collider.body != null ) {
				retractSignal.dispatch(collider);
			} else if ( !(collider is ZoneBase) ) {
				listContact.push(collider);
				retractSignal.dispatch(null);
			}
		}
		
		override public function handleEndContact(interactionCallback:InteractionCallback):void
		{
			super.handleEndContact(interactionCallback);
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, interactionCallback);
			if ( listContact.indexOf(collider) >= 0 ) {
				listContact.splice( listContact.indexOf(collider), 1 );
			}
		}
		
		public function canFire():Boolean
		{
			return (listContact.length == 0);
		}
	}
}