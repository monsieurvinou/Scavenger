package core.ennemies
{
	import citrus.objects.CitrusSprite;
	
	import core.hero.Player;
	import core.objects.grabbable.Missile;
	
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	public class Turret_Old extends MVEnnemy
	{
		private static var turret_nb:int = 0;
		private var _cannon:Image;
		private var _base:Image;
		private var _turretSprite:Sprite;
		
		public function Turret_Old(name:String, params:Object)
		{
			var rotation:Number = 0;
			if ( params != null && params.rotation != null )  {
				rotation = params.rotation;
				params.rotation = null;
			}
			if ( params != null && params.height != null ) params.height = 16;
			Turret_Old.turret_nb ++;
			if ( name == "" ) name = "turret_"+Turret_Old.turret_nb
			super(name, params);
			
			updateCallEnabled = true;
			
			_base = new Image( Gravity.assets.getTexture("turret_base") );
			_base.y = 8;
			_cannon = new Image( Gravity.assets.getTexture("turret_cannon") );
			_cannon.x = 16;
			_cannon.y = 24;
			_cannon.pivotY = 30;
			_cannon.pivotX = 4;
			var bg:Image = new Image( Gravity.assets.getTexture("turret_bg") );
			_turretSprite = new Sprite();
			_turretSprite.width = 32;
			_turretSprite.height = 32;
			//_turretSprite.addChild(bg);
			_turretSprite.addChild(_cannon);
			_turretSprite.addChild(_base);
			
			view = _turretSprite;
			
			_rotation = deg2rad(rotation);
			
			//_turretSprite.rotation = rotation;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			var angleLimit:Number = _rotation + deg2rad(80);
			var limitAngleNeg:Number = _rotation - deg2rad(80);
			var canSee:Boolean = false;
			var possibleRotation:Number = 0;
			var playerPos:Vec2 = new Vec2(Player.instance.x, Player.instance.y);
			var cannonVec:Vec2 = new Vec2( x - playerPos.x, y - playerPos.y);
			if ( rad2deg(cannonVec.angle) - deg2rad(90) >= limitAngleNeg && cannonVec.angle - deg2rad(90) <= angleLimit ) {
				_cannon.rotation = cannonVec.angle - deg2rad(90) - _rotation;
				
				// Look for the end of the cannon
				var cannonPos:Vec2 = new Vec2(0, -24);
				cannonPos.rotate(_cannon.rotation);
				cannonPos.x += x;
				cannonPos.y += y;
				/*
				// Ray cast to the hero
				var ray:Ray = Ray.fromSegment(cannonPos, playerPos);
				ray.maxDistance = _rangeSight;
				var rayResult:RayResult = _nape.space.rayCast(ray);
				if ( rayResult ) {
				var intersection:Vec2 = ray.at(rayResult.distance);
				if ( Player.instance.body.contains(intersection) ) {
				// The turret can see the hero
				canSee = true;
				}
				}
				*/
			}
			
			if ( _canFire && canSee && Player.instance.controlsEnabled ) {
				// Create missile
				var missile:Missile = new Missile(cannonPos, _damageMissile, 8, 40, _cannon.rotation);
				_ce.state.add(missile);
				_canFire = false;
				Starling.juggler.delayCall( function():void {_canFire = true;}, 2);
			}
		}
	}
}
import core.ennemies;

