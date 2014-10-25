package core.ennemies
{
	import com.greensock.TweenLite;
	
	import citrus.core.CitrusObject;
	import citrus.objects.CitrusSprite;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.sounds.CitrusSoundGroup;
	
	import core.hero.Player;
	import core.objects.grabbable.Missile;
	
	import levels.MainLevel;
	
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.extensions.particles.PDParticleSystem;
	import starling.utils.deg2rad;
	
	public class Boss extends MVEnnemy
	{
		private var _maxSpeed:Number = 30;
		private var _instance:Boss;
		protected var _particle:PDParticleSystem;
		
		protected var whiteScreen:Quad;
		
		public function Boss(name:String, params:Object=null)
		{
			if ( params == null ) params = {width: 128, height: 128};
			else {
				params.width = 128;
				params.height = 128;
			}
			super(name, params);
			_health = 300;
			view = new Image( Gravity.assets.getTexture("boss"));
			updateCallEnabled = true;
			group = 32;
			
			_particle = new PDParticleSystem(Gravity.assets.getXml("boss_particle"), Gravity.assets.getTexture("boss"));
			
			_ce.state.add( new CitrusSprite("particule_boss", {view: _particle, group: 10}));
		}
		
		override public function die(s:String=""):void
		{
			super.die();
			var listTurrets:Vector.<CitrusObject> = (_ce.state as MainLevel).getObjectsByType(BossTurret);
			for each ( var turret:BossTurret in listTurrets ) {
				turret.explode();
			}
		}
		
		override public function explode():void
		{
			var listMissiles:Vector.<CitrusObject> = (_ce.state as MainLevel).getObjectsByType(Missile);
			for each ( var missile:Missile in listMissiles ) {
				missile.explose();
			}
			
			whiteScreen = new Quad(800, 640, 0xFFFFFF);
			whiteScreen.alpha = 0;
			Starling.current.stage.addChild(whiteScreen);
			TweenLite.to( whiteScreen, 5, {alpha: 1, onComplete: function():void{
				Starling.juggler.purge();
				(_ce.state as MainLevel).removeUI();
				TweenLite.to(_ce.sound.getGroup(CitrusSoundGroup.BGM), 3, {volume: 0});
				TweenLite.to(_ce.sound.getGroup(CitrusSoundGroup.SFX), 3, {volume: 0, onComplete:function():void {
					_ce.sound.getSound((_ce.state as MainLevel).songPlaying).stop();
					var blackScreen:Quad = new Quad(800, 640, 0x000000);
					blackScreen.alpha = 0;
					Starling.current.stage.addChild(blackScreen);
					TweenLite.to(blackScreen, 2, {alpha: 1, onComplete: function():void {
						(_ce.state as MainLevel).alpha = 0;
						blackScreen.removeFromParent(true);
						whiteScreen.removeFromParent(true);
						(_ce.state as MainLevel).goToCredit();
					}});
				}});
			}});
			
			_ce.sound.playSound("boss_explode");
			Player.instance.controlsEnabled = false;
			_particle.stop();
			_body.velocity = new Vec2();
			Player.instance.body.velocity = new Vec2();
			var timer:Number = 0;
			for ( var i:int = 0; i<70; i++ ) {
				if ( timer == 0 ) {
					_ce.state.add( new ExplosionBoss(new Vec2(x, y)) );
				} else {
					Starling.juggler.delayCall( function ():void {
						_ce.state.add( new ExplosionBoss(new Vec2(x, y)) );
					}, timer);
				}
				timer += Math.random() * 0.3;
			}
		}
		
		
		override protected function createBody():void
		{
			super.createBody();
			_body.type = BodyType.DYNAMIC;
			_body.allowMovement = true;
			_body.allowRotation = true;
			
			// We create the turrets
			for ( var i:int = 0; i<4; i++ ) {
				var offset:Vec2;
				var turret:BossTurret;
				switch(i) {
					case 0: 
						offset = new Vec2(-40,39);
					break;
					case 1: 
						offset = new Vec2(40,39);
					break;
					case 2: 
						offset = new Vec2(-24,55);
					break;
					case 3: 
						offset = new Vec2(24,55);
					break;
				}
				turret = new BossTurret(this, offset);
				_ce.state.add(turret);
			}
		}
		
		override protected function createShape():void
		{
			super.createShape();
			_body.shapes.clear();
			var forme:Polygon = new Polygon(new Array(
				new Vec2(0,64), new Vec2(-16, 48), new Vec2(-32,48), new Vec2(-32,32), new Vec2(-48,32),
				new Vec2(-48,16), new Vec2(-64,0), new Vec2(-64,-32), new Vec2(-32,-64), new Vec2(32,-64),
				new Vec2(64, -32), new Vec2(64,0), new Vec2(48,16), new Vec2(48,32), new Vec2(32,32),
				new Vec2(32,48), new Vec2(16,48), new Vec2(0,64)
			), Material.steel(),new InteractionFilter(
				PhysicsCollisionCategories.Get("BadGuys"), 
				PhysicsCollisionCategories.Get("GoodGuys")
			));
			_body.shapes.add(forme);
		}
		
		override protected function createFilter():void
		{
			super.createFilter();
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("BadGuys"), 
					PhysicsCollisionCategories.Get("GoodGuys", "Bullets")
				)
			);
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			if ( Player.instance.controlsEnabled ) {
				var distance:Number = Vec2.distance(
					new Vec2(x, y),
					new Vec2(Player.instance.x, Player.instance.y)
				);
				var vecDirection:Vec2 = new Vec2(x - Player.instance.x, y - Player.instance.y);
				var rotationPlayer:Number = vecDirection.angle - deg2rad(90);
				if ( distance > 150 ) {
					if ( !_particle.isEmitting ) _particle.start();
					var speedVector:Vec2 = new Vec2(0, -_maxSpeed);
					speedVector.rotate(rotationPlayer);
					_body.velocity = speedVector;
				} else {
					if ( _particle.isEmitting ) _particle.stop();
					_body.velocity = new Vec2();
				}
				_body.rotation = rotationPlayer - Math.PI;
			}
			
			if ( _particle.isEmitting ) {
				_particle.emitterX = x;
				_particle.emitterY = y;
				_particle.emitAngle = _body.rotation - deg2rad(90);
				_particle.startRotation = _body.rotation;
				_particle.endRotation = _body.rotation;
			}
		}
		
		public function get instance():Boss 
		{
			if ( _instance == null ) _instance = this;
			return _instance;
		}
	}
}