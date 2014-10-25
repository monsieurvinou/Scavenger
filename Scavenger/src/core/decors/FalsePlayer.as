package core.decors
{
	import citrus.objects.CitrusSprite;
	import citrus.objects.NapePhysicsObject;
	
	import nape.geom.Vec2;
	
	import starling.display.Image;
	import starling.extensions.particles.PDParticleSystem;
	import starling.utils.deg2rad;
	
	public class FalsePlayer extends NapePhysicsObject
	{
		public function FalsePlayer()
		{
			super("");
			
			var imgView:Image = new Image(Gravity.assets.getTexture("VaisseauFinal"));
			imgView.alpha = 1;
			imgView.scaleX = imgView.scaleY = 1/15;
			view = imgView;
			
			updateCallEnabled = true;
			group = 30;
			
		}
		
		override public function initialize(poolObjectParams:Object=null):void
		{
			super.initialize(poolObjectParams);
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			/*
			
			*/
			
			_body.velocity = new Vec2(0, 30);
			_body.rotation = Math.PI;
		}
	}
}