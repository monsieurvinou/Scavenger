package core.objects.grabbable
{
	import citrus.objects.NapePhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.nape.NapeUtils;
	import citrus.view.starlingview.AnimationSequence;
	
	import core.ennemies.MVEnnemy;
	import core.hero.Player;
	import core.objects.hook.HookClaw;
	
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	
	import starling.animation.DelayedCall;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import utils.assets.Assets;

	public class Missile extends Grabbable
	{
		protected static var missileNumber:Number = 0;
		protected var _damage:Number;
		protected var _lifespan:Number;
		protected var _speed:Number;
		protected var _angle:Number;
		protected var _isFired:Boolean = false;
		protected var _juggler:DelayedCall;
		
		public function Missile(pos:Vec2, damage:Number = 0, lifespan:Number = 5, speed:Number = 0, angle:Number = 0)
		{
			Missile.missileNumber++;
			if ( pos == null ) pos = new Vec2();
			super("bullet_"+Missile.missileNumber, {
				width: 16, height: 24,
				x: pos.x, y: pos.y,
				view: new Image( Gravity.assets.getTexture("missile") )
			});
			
			_damage = damage;
			_lifespan = lifespan;
			_speed = speed;
			_angle = angle;
			_rotation = _angle;
			_juggler = Starling.current.juggler.delayCall( this.explose, _lifespan );
			beginContactCallEnabled = true;
			updateCallEnabled = true;
			group = 40;
		}
		
		public function explose():void
		{
			// animation
			var ta:TextureAtlas = new TextureAtlas(
				Texture.fromBitmap(new Assets.SpriteSheetExplosionBleuTexture()), 
				new XML( new Assets.SpriteSheetExplosionBleuXml() )
			);
			var sequence:AnimationSequence = new AnimationSequence(ta, ["explo_bleu"],"explo_bleu");
			view = sequence;
			desactivatePhysic();
			if ( _ce.sound.getSound("missile_explode").volume != 0.3 ) _ce.sound.getSound("missile_explode").volume = 0.15;
			_ce.sound.playSound("missile_explode");
			sequence.onAnimationComplete.add(destroyMissile);
		}
		
		public function destroyMissile(animationName:String):void { this.kill = true; }
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			if ( _body != null ) {
				_body.angularVel = 0;
				if ( !_isFired ) {
					_body.rotation = _rotation;
					_body.velocity = new Vec2(0,-_speed);
					_body.velocity.rotate(_rotation);
					_isFired = true;
				}
			}
			
			if ( view is AnimationSequence ) _body.velocity = new Vec2(0,0);
		}
		
		/**
		 * RE-set the timer before it explodes
		 */
		public function launch():void
		{
			_juggler = Starling.current.juggler.delayCall( this.explose, _lifespan );
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void
		{
			super.handleBeginContact(callback);
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			if ( collider is Player ) {
				if( _juggler != null ) Starling.juggler.remove(_juggler); _juggler = null;
				(collider as Player).damage(_damage);
				explose();
			} else if ( collider is MVEnnemy ) {
				if( _juggler != null ) Starling.juggler.remove(_juggler); _juggler = null;
				(collider as MVEnnemy).damage(_damage);
				explose();
			} else if ( collider is HookClaw && _juggler != null) {
				Starling.juggler.remove(_juggler);
				_juggler = null;
			} else {
				if( _juggler != null ) Starling.juggler.remove(_juggler); _juggler = null;
				explose();
			}
		}
		
		override protected function createFilter():void
		{
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("Bullets"), 
					PhysicsCollisionCategories.GetAllExcept("BadGuys", "Bullets")
				)
			);
		}
		
		override public function activatePhysic():void
		{
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("Bullets"), 
					PhysicsCollisionCategories.GetAllExcept("GoodGuys")
				)
			);
		}
		
		override public function desactivatePhysic():void
		{
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("Bullets"), 
					PhysicsCollisionCategories.GetNone()
				) 
			);
		}
		
		public function set damage(value:Number):void { _damage = value; }
		public function get damage():Number { return _damage; }
	}
}