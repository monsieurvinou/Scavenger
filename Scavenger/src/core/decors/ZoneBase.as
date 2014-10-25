package core.decors
{
	import com.greensock.TweenLite;
	
	import citrus.objects.CitrusSprite;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.physics.nape.NapeUtils;
	
	import core.hero.Player;
	import core.objects.grabbable.Shipwreck;
	import core.objects.grabbable.Treasure;
	
	import levels.Progression;
	
	import nape.callbacks.InteractionCallback;
	
	import starling.display.Quad;
	import starling.extensions.particles.PDParticleSystem;
	
	public class ZoneBase extends Sensor
	{
		protected var _playerIn:Boolean = false;
		protected var _compteur:Number = 0;
		protected var _particle:PDParticleSystem;
		
		public function ZoneBase(name:String, params:Object=null)
		{
			super(name, params);
			updateCallEnabled = true;
			beginContactCallEnabled = true;
			endContactCallEnabled = true;
			
			_particle = new PDParticleSystem( Gravity.assets.getXml("regen_particle"), Gravity.assets.getTexture("regen_texture") );
			_ce.state.add( new CitrusSprite("regen_particle", {view: _particle}) );
			
			view = new Quad(_width, _height, 0x77FF77);
			(view as Quad).alpha = 0.4;
		}
		
		override public function handleBeginContact(interactionCallback:InteractionCallback):void
		{
			super.handleBeginContact(interactionCallback);
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, interactionCallback);
			if ( collider is Player) _playerIn = true;
			else {
				// We bringed back something
				if ( collider is Treasure && Player.instance.controlsEnabled) {
					Progression.found((collider as Treasure).id);
					if ( Player.instance.hook != null && Player.instance.hook.grabbed() != null && Player.instance.hook.grabbed() == collider ) {
						Player.instance.hook.fireHook();
					}
					(collider as Treasure).gather();
					(collider as Treasure).body.angularVel = 0;
				} else if ( collider is Shipwreck ) {
					if ( Player.instance.hook != null && Player.instance.hook.grabbed() != null && Player.instance.hook.grabbed() == collider ) {
						Player.instance.hook.fireHook();
					}
					_ce.sound.playSound("transformation_shipwreck");
					(collider as Shipwreck).recycle();
				}
			}
		}
		
		override public function handleEndContact(interactionCallback:InteractionCallback):void
		{
			super.handleEndContact(interactionCallback);
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, interactionCallback);
			if ( collider is Player) _playerIn = false;
		}
		
		private function regenSoundOn():void
		{
			if ( !_ce.sound.getSound("healing").isPlaying ) {
				_ce.sound.playSound("healing");
				TweenLite.to ( _ce.sound.getSound("healing"), 0.5, {volume: 0.5});
			}
		}
		
		
		private function regenSoundOff():void
		{
			if ( _ce.sound.getSound("healing").isPlaying && _ce.sound.getSound("healing").volume == 0.5 ) {
				TweenLite.to( _ce.sound.getSound("healing"), 0.5, {volume: 0, onComplete: function():void {
					_ce.sound.getSound("healing").stop();
				}} );
			}
			
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			if ( _playerIn ) {
				if ( Player.instance.health < 100 && _compteur <= 0) {
					// The sound should be playing
					regenSoundOn();
					Player.instance.damage(-1);
					_compteur = 7;
				} else if( Player.instance.health < 100 ) {
					_compteur -= 1;
				} else {
					regenSoundOff();
				}
				
				if ( Player.instance.health < 100 && !_particle.isEmitting) {
					_particle.start();
				}
				
				if ( Player.instance.health >= 100 && _particle.isEmitting ) {
					_particle.stop();
				}
				
				if ( _particle.isEmitting ) {
					_particle.emitterX = Player.instance.x;
					_particle.emitterY = Player.instance.y;
				}
			} else {
				if ( _particle.isEmitting ) _particle.stop();
				regenSoundOff();
			}
		}
	}
}