package core.ennemies
{
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	
	import starling.display.Image;
	
	public class BossTurret extends Turret
	{
		private var _boss:Boss;
		private var _offset:Vec2;
		
		public function BossTurret(boss:Boss, offset:Vec2 = null)
		{
			super(name, {
				width: 6, height: 14
			});
			angleFOV = 45;
			_boss = boss;
			if ( offset == null ) _offset = new Vec2();
			else _offset = offset;
			view = new Image(Gravity.assets.getTexture("boss_turret"));
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_body.type = BodyType.DYNAMIC;
		}
		
		override public function damage(value:Number):void
		{
			_boss.damage(value); // Only the boss can be hit
		}
		
		override public function update(timeDelta:Number):void
		{
			// We update the position of the turret 
			_body.rotation = _boss.body.rotation + Math.PI;
			var newPosition:Vec2 = new Vec2(_offset.x, _offset.y);
			newPosition.rotate(_body.rotation - Math.PI);
			x = _boss.x + newPosition.x;
			y = _boss.y + newPosition.y;
			super.update(timeDelta);
		}
	}
}