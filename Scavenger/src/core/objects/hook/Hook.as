package core.objects.hook
{
	import citrus.core.CitrusObject;
	import citrus.objects.NapePhysicsObject;
	
	import core.hero.Player;
	import core.objects.grabbable.Grabbable;
	import core.objects.grabbable.Missile;
	
	import levels.MVLevel;
	
	import nape.geom.Vec2;
	
	import starling.core.Starling;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.deg2rad;

	public class Hook extends CitrusObject
	{
		private const damageMissile:Number = 10;
		private var _claw:HookClaw;
		private var _string:HookString;
		private var _player:Player;
		private var _distance:Number;
		private const DISTANCE_MAX:Number = 200;
		public static var isFiring:Boolean = false;
		private var _isRetracting:Boolean = false;
		private var _grabbed:Grabbable;
		
		// Monitoring
		private const __isMonitoring:Boolean = false;
		private var tfDistance:TextField;
		private var tfDistanceBodies:TextField;
		private var tfIsFiring:TextField;
		private var tfIsRectracting:TextField;
		private var tfClawPosition:TextField;
		private var tfPlayerPosition:TextField;
		
		public function Hook(player:Player)
		{
			super("hook");
			_player = player;
			_claw = new HookClaw();
			_string = new HookString(new Vec2(1,1));
			updateCallEnabled = true;
			// Define starting position of the claw
			var posClaw:Vec2 = new Vec2(_player.x, _player.y - 30);
			posClaw.angle = _player.rotation;
			_claw.x = posClaw.x;
			_claw.y = posClaw.y;
			
			_claw.retractSignal.add( handleClawTouch );
		}
		
		public function fireHook():void
		{
			if ( _claw.canFire() && _grabbed == null ) {
				_ce.sound.playSound("fire_hook");
				Hook.isFiring = true;
			} else if ( _claw.canFire() && _grabbed != null ) {
				// we fire the item
				_grabbed.body.velocity = new Vec2();
				var eject:Vec2 = new Vec2(0, -70);
				eject.rotate( deg2rad(_grabbed.rotation) );
				_grabbed.activatePhysic();
				_grabbed.body.applyImpulse(eject)
				if ( _grabbed is Missile ) (_grabbed as Missile).launch();
				_grabbed = null;
			}
		}
		
		protected function handleClawTouch(grabbed:NapePhysicsObject = null):void
		{
			if ( Hook.isFiring && !_isRetracting ) {
				_isRetracting = true;
				if ( grabbed != null ) {
					_ce.sound.getSound("grab_something").volume = 0.7;
					_ce.sound.playSound("grab_something");
					// We caught something
					_grabbed = grabbed as Grabbable;
					_grabbed.desactivatePhysic();
					if ( _grabbed is Missile) (_grabbed as Missile).damage = damageMissile;
				} else {
					// it was just a wall or something.
				}
			}
		}
		
		public function addHook(state:MVLevel):void
		{
			if ( _claw != null && _string != null ) {
				state.add(this);
				state.add(_claw);
				state.add(_string);
			}
			
			if ( __isMonitoring ) {
				tfClawPosition = new TextField(400, 20, "", "Courier", 12, 0xFFFFFF);
				tfDistance = new TextField(400, 20, "", "Courier", 12, 0xFFFFFF);
				tfDistanceBodies = new TextField(400, 20, "", "Courier", 12, 0xFFFFFF);
				tfIsFiring = new TextField(400, 20, "", "Courier", 12, 0xFFFFFF);
				tfIsRectracting = new TextField(400, 20, "", "Courier", 12, 0xFFFFFF);
				tfPlayerPosition = new TextField(400, 20, "", "Courier", 12, 0xFFFFFF);
				
				tfClawPosition.x = tfDistance.x = tfDistanceBodies.x = tfIsFiring.x = tfIsRectracting.x = tfPlayerPosition.x = 400
				tfClawPosition.y = 0;
				tfDistance.y = 22;
				tfDistanceBodies.y = 46;
				tfIsFiring.y = 68;
				tfIsRectracting.y = 90;
				tfPlayerPosition.y = 112;
				
				tfPlayerPosition.hAlign = tfClawPosition.hAlign = tfDistance.hAlign = tfDistanceBodies.hAlign = tfIsFiring.hAlign = tfIsRectracting.hAlign = HAlign.LEFT;
				
				Starling.current.stage.addChild(tfClawPosition);
				Starling.current.stage.addChild(tfDistance);
				Starling.current.stage.addChild(tfDistanceBodies);
				Starling.current.stage.addChild(tfIsFiring);
				Starling.current.stage.addChild(tfIsRectracting);
				Starling.current.stage.addChild(tfPlayerPosition);
			}
			
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			updateClaw();
			updateString();
			updateGrabbed();
			
			/******** MONITORING **********/
			if ( __isMonitoring && tfClawPosition != null) {
				tfClawPosition.text = "Claw : ( x: "+ _claw.x + ", y: " + _claw.y + " )";
				tfDistance.text = "Distance : ( " + _distance + " )";
				tfDistanceBodies.text = "Distance Bodies : ( " + Vec2.distance(_player.body.position, _claw.body.position) + " )";
				tfIsFiring.text = "IsFiring : ( " + Hook.isFiring + " )";
				tfIsRectracting.text = "IsRetracting : ( " + _isRetracting + " )";
				tfPlayerPosition.text = "Player : ( x: " + _player.x + ", y: " + _player.y +" )";
			}
		}
		
		protected function updateClaw():void
		{
			_claw.rotation = _player.rotation;
			if ( Hook.isFiring ) {
				if ( _isRetracting && _distance <= 30 ) {
					Hook.isFiring = false;
					_isRetracting = false;
					_distance = NaN;
				}
				// We calculate the distance between the player and the claw
				if ( Hook.isFiring && _distance > DISTANCE_MAX && !_isRetracting) _isRetracting = true;
				
				// If we're still in Firing mod.
				if ( Hook.isFiring ) {
					// We move the hook claw
					if ( (_distance < 0 || isNaN(_distance)) && !_isRetracting ) {
						_distance = 30;
					} else if ( _isRetracting ) {
						_distance -= 10;
					} else {
						_distance += 10;
					}
					
					var position:Vec2 = new Vec2(0, -1);
					position.length = _distance;
					position.rotate( deg2rad(_player.rotation));
					
					_claw.x = _player.x + position.x;
					_claw.y = _player.y + position.y;
				}
			} 
			if ( !Hook.isFiring ) {
				_claw.x = _player.x;
				_claw.y = _player.y;
				var pos:Vec2 = new Vec2(0, -30);
				pos.rotate(deg2rad(_claw.rotation));
				_claw.x += pos.x;
				_claw.y += pos.y;
			}
		}
			
		protected function updateString():void
		{
			if ( Hook.isFiring ) {
				// We define the length of the string
				_string.visible = true;
				var playerPos:Vec2 = new Vec2(_player.x, _player.y);
				var clawPos:Vec2 = new Vec2(_claw.x, _claw.y);
				
				var string:Vec2 = new Vec2();
				string.x = Vec2.distance(playerPos, clawPos);
				string.rotate( deg2rad(_player.rotation) );
				_string.handleSizeChange(string);
				
				string.muleq(0.5);
				
				var stringPos:Vec2 = new Vec2((_player.x + _claw.x)/2, (_player.y + _claw.y)/2);
				_string.x = stringPos.x;
				_string.y = stringPos.y;
			} else {
				_string.visible = false;
			}
		}
			
		protected function updateGrabbed():void
		{
			if ( _grabbed != null ) {
				_grabbed.x = _claw.x;
				_grabbed.y = _claw.y;
				_grabbed.rotation = _claw.rotation;
			}
		}
		
		public function grabbed():Grabbable { return _grabbed; }
	}
}