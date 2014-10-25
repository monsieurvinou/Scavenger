package core.ennemies
{
	import citrus.objects.CitrusSprite;
	import citrus.view.starlingview.AnimationSequence;
	
	import nape.geom.Vec2;
	
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import utils.assets.Assets;
	
	public class ExplosionBoss extends CitrusSprite
	{
		private var sequence:AnimationSequence
		private var _bossPos:Vec2;
		
		public function ExplosionBoss(bossPosition:Vec2, isHero:Boolean = false)
		{
			super("");
			_bossPos = bossPosition;
			var factor:Number = 64;
			if ( isHero ) factor = 2;
			x = Math.random() * (factor*2) - factor + _bossPos.x; // Random X
			y = Math.random() * (factor*2) - factor + _bossPos.y; // Random Y
			if(!isHero) rotation = Math.random() * 2 * Math.PI - Math.PI; // Random Rotation
			group = 40;
		}
		
		override public function initialize(poolObjectParams:Object=null):void
		{
			super.initialize(poolObjectParams);
			// animation
			var ta:TextureAtlas = new TextureAtlas(
				Texture.fromBitmap(new Assets.SpriteSheetExplosionJauneTexture()), 
				new XML( new Assets.SpriteSheetExplosionJauneXml() )
			);
			sequence = new AnimationSequence(ta, ["explo_jaune"],"explo_jaune");
			view = sequence;
			// Is added to state, we can play the sound
			_ce.sound.playSound("turret_explode");
			sequence.onAnimationComplete.add(removeExplosion);
		}
		
		private function removeExplosion(machin:*):void
		{
			kill = true;
		}
	}
}