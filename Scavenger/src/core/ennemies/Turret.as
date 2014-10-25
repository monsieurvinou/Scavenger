package core.ennemies
{
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.view.starlingview.AnimationSequence;
	
	import core.hero.Player;
	import core.objects.grabbable.Missile;
	
	import nape.dynamics.InteractionFilter;
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	import utils.assets.Assets;

	public class Turret extends MVEnnemy
	{
		private static var turret_nb:int = 0;
		protected var angleFOV:Number = 30;
		
		public function Turret(name:String, params:Object)
		{
			Turret.turret_nb ++;
			if ( name == "" ) name = "turret_"+Turret.turret_nb
			super(name, params);
			
			updateCallEnabled = true;
			
			view = new Image( Gravity.assets.getTexture("turret"));
		}
		
		override public function explode():void
		{
			// animation
			var ta:TextureAtlas = new TextureAtlas(
				Texture.fromBitmap(new Assets.SpriteSheetExplosionJauneTexture()), 
				new XML( new Assets.SpriteSheetExplosionJauneXml() )
			);
			var sequence:AnimationSequence = new AnimationSequence(ta, ["explo_jaune"],"explo_jaune");
			view = sequence;
			if ( !this is BossTurret ) _ce.sound.playSound("turret_explode");
			sequence.onAnimationComplete.add(die);
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			var canSee:Boolean = false;
			var playerPos:Vec2 = new Vec2(Player.instance.x, Player.instance.y);
			var turretPos:Vec2 = new Vec2(x,y);
			
			if ( Vec2.distance(playerPos, turretPos) <= _rangeSight ) { // We are in range
				var ray:Ray = Ray.fromSegment(turretPos, playerPos);
				var angleInf:Number = rad2deg(_body.rotation) - 90 - angleFOV;
				var angleSup:Number = rad2deg(_body.rotation) - 90 + angleFOV;
				var angleRay:Number = rad2deg(ray.direction.angle);
				while ( angleInf < 0 || angleSup < 0 ) {
					angleInf += 360;
					angleSup += 360;
				}
				while ( angleRay < 0 ) angleRay += 360;
				
				if ( name == "dupont" ) {
					trace("Angle Inf : ", angleInf, "\n" +
						"Angle Sup : ", angleSup, "\n" +
						"Angle Ray : ", angleRay)
				}
				
				if ( angleRay >= angleInf && angleRay <= angleSup ) {
					ray.maxDistance = _rangeSight;
					var rayResult:RayResult = _nape.space.rayCast(ray,false,
						new InteractionFilter(
							PhysicsCollisionCategories.Get("Level"), 
							PhysicsCollisionCategories.GetAllExcept("BadGuys", "Bullets", "Hook")
						)
					);
					if ( rayResult) {
						var intersection:Vec2 = ray.at(rayResult.distance);
						if ( Player.instance.body.contains(intersection) ) canSee = true;
					}
				}
			}
				
			if ( _canFire && canSee && Player.instance.controlsEnabled ) {
				// Create missile
				var decalMissile:Vec2 = new Vec2(0, -24);
				decalMissile.rotate(this.body.rotation);
				turretPos.x += decalMissile.x;
				turretPos.y += decalMissile.y;
				var missile:Missile = new Missile(turretPos, _damageMissile, 8, 40, deg2rad(angleRay + 90));
				_ce.state.add(missile);
				_canFire = false;
				Starling.juggler.delayCall( function():void {_canFire = true;}, 2);
				_ce.sound.playSound("fire_from_turret");
			}
		}
	}
}