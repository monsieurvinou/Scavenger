package core.hero
{
	import com.greensock.TweenLite;
	
	import citrus.objects.CitrusSprite;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Hero;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.nape.NapeUtils;
	import citrus.sounds.CitrusSound;
	import citrus.sounds.CitrusSoundGroup;
	
	import core.ennemies.ExplosionBoss;
	import core.objects.grabbable.Grabbable;
	import core.objects.grabbable.Shipwreck;
	import core.objects.hook.Hook;
	
	import levels.MainLevel;
	
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.Material;
	import nape.shape.Polygon;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.extensions.particles.PDParticleSystem;
	import starling.utils.deg2rad;
	
	import utils.MessageBox;
	
	public class Player extends Hero
	{
		// Caractéristiques
		public static var instance:Player;
		// Vitesse de tir
		private static var _firerate:int = 10;
		// Point de vie
		private static var _health:int = 100;
		public var healthSignal:Signal;
		// Accélération
		private static var _acceleration:Number = 0.3;
		// Vitesse max
		private static var _vitesseMax:Number = 130;
		private static var _vitesseMaxBooster_1:Number = 190;
		private static var _vitesseMaxBooster_2:Number = 260;
		// Vitesse de rotation
		private static var _rotationSpeed:int = 6;
		// Vitesse Projectiles
		private static var _vitesseMissile:int = 150;
		// Portée
		private static var _range:int = 1000;
		
		// PARTICLES
		protected var _particle:PDParticleSystem;
		
		// Hook 
		public static var hookUnlocked:Boolean = false;
		public var boosterState:int = 0;
		public var hook:Hook;
		
		// Aides
		private var frameFired:int = 0;
		private var _bulletNumber:Number = 0;
		// Vecteur définissant la trajectoire du vaisseau
		private var vecRocket:Vec2;
		
		// Vitesse par défaut quand on dérive
		private var vitesseCroisiere:Number = 10;
		
		public function Player(name:String, params:Object=null)
		{
			super(name, {});
			instance = this;
			maxVelocity = 2;
			
			vecRocket = new Vec2(0, -5);
			healthSignal = new Signal();
			
			var imgView:Image = new Image(Gravity.assets.getTexture("VaisseauFinal"));
			imgView.alpha = 1;
			imgView.scaleX = imgView.scaleY = 1/15;
			view = imgView;
			
			beginContactCallEnabled = true;
			endContactCallEnabled = true;
			updateCallEnabled = true;
			
			_particle = new PDParticleSystem(Gravity.assets.getXml("hero_particle"), Gravity.assets.getTexture("VaisseauFinal"));
			_ce.state.add( new CitrusSprite("particule_hero", {view: _particle, group: 10}));
			
			group = 30;
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void
		{
			super.handleBeginContact(callback);
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			if ( collider is Platform ) {
				_ce.sound.playSound("hit_wall");
				damage(5);
			} else if ( collider is Grabbable ) {
				if ( collider is Shipwreck ) {
					_ce.sound.playSound("hit_wall");
					damage(1);
				}
			}
		}
		
		public function addBooster():void
		{
			boosterState += 1;
			if ( boosterState == 1 ) {
				MessageBox.instance.affiche("Pilot.\n" +
					"You found an old Nitrogen Accelerator Module. This is perfect!\n" +
					"The N.A.M. is activated by the switch on the control panel with the 'CTRL' on it.\n" +
					"It used to stand for something, but I don't have any information on that. All you have to do is keep this switch " +
					"on and you should be able to go much faster.\n" +
					"Although it is a nice finding, don't forget that your mission is to bring back the artifacts. Not collect junk.\n\n" +
					"Over & out.");
			} else if ( boosterState == 2 ) {
				MessageBox.instance.affiche("Pilot.\n" +
					"You found another N.A.M. I see. You know that no one is gonna try to race you out there, you're alone.\n" +
					"Go onward with the mission. Please.\n\n" +
					"Over & out.");
			}
			if ( boosterState > 2 ) boosterState = 2;
		}
		
		override public function initialize(poolObjectParams:Object=null):void
		{
			super.initialize(poolObjectParams);
		}
		
		override protected function createBody():void
		{
			super.createBody();
			body.allowRotation = true;
			body.gravMass = 0;
		}
		
		override protected function createFilter():void
		{
			super.createFilter();
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("GoodGuys"), 
					PhysicsCollisionCategories.GetAll()
				) 
			);
		}
		
		override protected function createShape():void
		{
			super.createShape();
			body.shapes.clear();
			var corps:Polygon = new Polygon( new Array(new Vec2(0,-15), new Vec2(-10,15), new Vec2(10,15)));
			corps.material = Material.rubber();
			body.shapes.add(corps);
		}
		
		override public function update(timeDelta:Number):void
		{
			if (controlsEnabled) {
				updateMovements();
				updateGrappin();
			}
		}
		
		public function explose():void
		{
			if ( controlsEnabled ) {
				controlsEnabled = false;
				_ce.sound.playSound("hero_explode");
				_particle.stop();
				var timer:Number = 0;
				for ( var i:int = 0; i<24; i++ ) {
					if ( timer == 0 ) {
						_ce.state.add( new ExplosionBoss(new Vec2(x, y)) );
					} else {
						Starling.juggler.delayCall( function ():void {
							_ce.state.add( new ExplosionBoss(new Vec2(x, y)) );
						}, timer);
					}
					timer += Math.random() * 0.15;
				}
					
				TweenLite.to (view, timer, {alpha: 0, onComplete: function():void {
					kill = true;
					var blackScreen:Quad = new Quad ( 800, 640, 0x000000 );
					blackScreen.alpha = 0;
					Starling.current.stage.addChild(blackScreen);
					TweenLite.to ( _ce.sound.getSound( (_ce.state as MainLevel).songPlaying ), 4, {volume: 0});
					TweenLite.to ( blackScreen, 4, {alpha: 1, onComplete: function():void {
						if ( _ce.state is MainLevel ) {
							(_ce.state as MainLevel).alpha = 0;
							blackScreen.removeFromParent(true);
							(_ce.state as MainLevel).removeUI();
							_ce.sound.getSound((_ce.state as MainLevel).songPlaying).stop();
							var listSounds:Vector.<CitrusSound> = _ce.sound.getGroup( CitrusSoundGroup.SFX ).getAllSounds();
							for each ( var sound:CitrusSound in listSounds ) {
								sound.stop();
							}
							(_ce.state as MainLevel).goToTitle();
						}
					}});
				}});
			}
		}
		
		public function reboot():void
		{
			Player.hookUnlocked = false;
			Player.health = 100;
		}
		
		public function damage(damageValue:Number):void
		{
			_health -= damageValue;
			healthSignal.dispatch();
			
			if ( _health <= 0 ) {
				// DEAD
				explose();
			} else if ( _health >= 100 ) {
				_health = 100;
			}
			
			if ( _health <= 50 && !MessageBox.healthMessage ) {
				MessageBox.healthMessage = true;
				MessageBox.instance.affiche("Pilot.\n" +
					"I'm reading that you damaged your ship quick a good amount. First of, can you try not to do it?\n" +
					"Second, don't forget that we have a repair module back at the base at the coordinates (12,1).\n" +
					"The nano-bots can take care of your ship if you feel like there's anything wrong. We can't afford to lose you because you just" +
					" didn't repair your ship.\n\n" +
					"Over & out.");
			}
			
			// Screen Shake
			if ( damageValue >= 0 ) {
				(_ce.state as MainLevel).isShaking = true;
				Starling.juggler.delayCall( function():void {
					(_ce.state as MainLevel).isShaking = false;
					(_ce.state as MainLevel).x = 0;
					(_ce.state as MainLevel).y = 0;
				}, 0.2);
			}
		}
		
		private function updateGrappin():void
		{
			if ( hookUnlocked ) {
				if ( _ce.input.hasDone("hook") && !Hook.isFiring) {
					hook.fireHook();
				}
			}
		}
		
		private function startForwardSound():void
		{
			if ( _ce.sound.getSound("player_forward").mute ) {
				_ce.sound.getSound("player_forward").mute = false;
			} 
			if ( !_ce.sound.getSound("player_forward").isPlaying ) {
				_ce.sound.getSound("player_forward").volume = 0.5;
				_ce.sound.playSound("player_forward");
			}
		}
		
		private function stopForwardSound():void
		{
			if ( !_ce.sound.getSound("player_forward").mute ) {
				_ce.sound.getSound("player_forward").mute = true
			}
		}
		
		private function updateMovements():void
		{
			var needSound:Boolean = true;
			if (_ce.input.isDoing("rocket",1) ) {
				// Traitement du mouvement
				var vec:Vec2 = new Vec2(vecRocket.x, vecRocket.y);
				vec.mul(_acceleration/3);
				vec.rotate(body.rotation);
				applyImpulseVitesse(vec);
				if(!_particle.isEmitting) _particle.start();
				_particle.emitterX = x;
				_particle.emitterY = y;
				_particle.emitAngle = _body.rotation + deg2rad(90);
				_particle.startRotation = _body.rotation;
				_particle.endRotation = _body.rotation;
			} else if(_ce.input.isDoing("back",1)) {
				var vecBack:Vec2 = new Vec2(vecRocket.x, vecRocket.y);
				vecBack.mul(_acceleration/3);
				vecBack.rotate(body.rotation);
				vecBack.length *= 0.75;
				vecBack.rotate(deg2rad(180));
				applyImpulseVitesse(vecBack);
				if(!_particle.isEmitting) _particle.start();
				_particle.emitterX = x;
				_particle.emitterY = y;
				_particle.emitAngle = _body.rotation + deg2rad(90);
				_particle.startRotation = _body.rotation;
				_particle.endRotation = _body.rotation;
			} else {
				needSound = false;
				if ( _particle.isEmitting ) _particle.stop();
				if (body.velocity.length > 0 ) body.velocity.length -= 1;
				else body.velocity = new Vec2(0,0);
			}
			
			if ( needSound ) startForwardSound();
			else stopForwardSound();
			
			
			if (_ce.input.isDoing("left",1) )
				body.angularVel = -(_rotationSpeed/3);
			else if ( _ce.input.isDoing("right",1) )
				body.angularVel = _rotationSpeed/3;
			else if(body.angularVel != 0)
				body.angularVel = 0;
		}
		
		private function applyImpulseVitesse(vec:Vec2):void
		{
			body.applyImpulse(vec);
			if ( _ce.input.isDoing("booster", 1) && boosterState == 1 ) {
				if(body.velocity.length > _vitesseMaxBooster_1) body.velocity.length = _vitesseMaxBooster_1;
			} else if ( _ce.input.isDoing("booster", 1) && boosterState == 2 ) {
				if(body.velocity.length > _vitesseMaxBooster_2) body.velocity.length = _vitesseMaxBooster_2;
			} else {
				if(body.velocity.length > _vitesseMax) {
					if ( body.velocity.length > _vitesseMax + 30) body.velocity.length -= 15;
					else body.velocity.length = _vitesseMax;
				}
			}
		}
		
		public static function get firerate():int { return _firerate; }
		public function get health():int { return _health; }
		public static function get acceleration():int { return _acceleration; }
		public static function get vitesseMax():int { return _vitesseMax; }
		public static function get rotationSpeed():int { return _rotationSpeed; }
		public static function get vitesseMissile():int { return _vitesseMissile; }
		public static function get range():int { return _range; }
		
		public static function set firerate(value:int):void { _firerate = value; }
		public static function set health(value:int):void { _health = value; }
		public static function set acceleration(value:int):void { _acceleration = value; }
		public static function set vitesseMax(value:int):void { _vitesseMax = value; }
		public static function set rotationSpeed(value:int):void { _rotationSpeed = value; }
		public static function set vitesseMissile(value:int):void { _vitesseMissile = value; }
		public static function set range(value:int):void { _range = value; }
	}
}