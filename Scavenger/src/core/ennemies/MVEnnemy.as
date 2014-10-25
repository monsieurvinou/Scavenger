package core.ennemies
{
	import citrus.objects.NapePhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	
	import nape.dynamics.InteractionFilter;
	import nape.phys.BodyType;
	
	import org.osflash.signals.Signal;
	
	import utils.MessageBox;
	
	public class MVEnnemy extends NapePhysicsObject
	{
		protected var _health:Number = 20; // Health of this ennemy
		protected var _canFire:Boolean = true; // When true, the ennemy can fire
		protected var _reloadTime:Number = 5; // Time before the ennemy can shoot again
		protected var _missileSpeed:Number = 120; // Speed of the missiles that this ennemy shoots
		protected var _damageBody:Number = 40; // The damages it inflicts to the player if he touches it.
		protected var _damageMissile:Number = 10; // The damages its missiles inflict on the player
		protected var _rangeSight:Number = 2000; // The distance of sight
		public var healthSignal:Signal;
		
		public function MVEnnemy(name:String, params:Object=null)
		{
			super(name, params);
			healthSignal = new Signal(); 
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_body.type = BodyType.STATIC;
		}
		
		override protected function createFilter():void
		{
			super.createFilter();
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("BadGuys"), 
					PhysicsCollisionCategories.Get("GoodGuys","Bullets")
				) 
			);
		}
		
		/**
		 * Inflict damages to the ennemy
		 * if the value is superior to the current health of the ennemy, it dies and trigger
		 * the function MVEnnemy.explode();
		 */
		public function damage(value:Number):void
		{
			_health -= value;
			if ( _health < 0 ) _health = 0;
			healthSignal.dispatch();
			if ( _health <= 0 ) explode();
		}
		
		/**
		 * Contain the animation of death. You have to override it
		 */
		public function explode():void
		{
			die();
		}
		
		/** 
		 * Activate the death animation and then is removed from the stage 
		 */
		public function die(s:String = ""):void
		{
			this.kill = true;
		}

		public function get health():Number { return _health; }
		public function set health(value:Number):void { _health = value; }

	}
}