package core.objects.grabbable
{
	import com.greensock.TweenLite;
	
	import citrus.objects.CitrusSprite;
	
	import core.hero.Player;
	
	import nape.geom.Vec2;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.extensions.particles.PDParticleSystem;
	
	import utils.MessageBox;

	public class Treasure extends Grabbable
	{
		protected static var _triggerBoss:Signal;
		protected static var idTreasure:int = 0;
		public var id:int;
		protected var _particle:PDParticleSystem;
		protected static var _finalPosition:Array;
		protected static var _treasureGathered:Array;
		protected var _positionWhenGathered:Vec2;
		
		public function Treasure(name:String, params:Object=null)
		{
			Treasure.idTreasure++;
			id=Treasure.idTreasure;
			params.group = 20;
			super(name, params);
			var imageView:Image = new Image( Gravity.assets.getTexture("treasure_"+Treasure.idTreasure) );
			_particle = new PDParticleSystem(Gravity.assets.getXml("treasure_particle"), Gravity.assets.getTexture("treasure_8"));
			
			_ce.state.add( new CitrusSprite("particle_treasure_"+ Treasure.idTreasure, {view: _particle, group: 10}));
			_view = imageView;
			
			updateCallEnabled = true;
			
			if ( Treasure._finalPosition == null ) {
				Treasure._finalPosition = new Array();
				Treasure._finalPosition[0] = new Vec2(11375, 110);
				Treasure._finalPosition[1] = new Vec2(11478, 110);
				Treasure._finalPosition[2] = new Vec2(11573, 110);
				Treasure._finalPosition[3] = new Vec2(11657, 110);
				Treasure._finalPosition[4] = new Vec2(11747, 110);
				Treasure._finalPosition[5] = new Vec2(11845, 110);
				Treasure._finalPosition[6] = new Vec2(11950, 110);
				Treasure._finalPosition[7] = new Vec2(12042, 110);
			}
			
			if ( Treasure._treasureGathered == null ) {
				Treasure._treasureGathered = new Array();
				Treasure._treasureGathered[0] = false;
				Treasure._treasureGathered[1] = false;
				Treasure._treasureGathered[2] = false;
				Treasure._treasureGathered[3] = false;
				Treasure._treasureGathered[4] = false;
				Treasure._treasureGathered[5] = false;
				Treasure._treasureGathered[6] = false;
				Treasure._treasureGathered[7] = false;
			}
				
			
			_positionWhenGathered = Treasure._finalPosition[Treasure.idTreasure - 1];
			
		}
		
		public static function reboot():void
		{
			Treasure._treasureGathered = new Array();
			Treasure._treasureGathered[0] = false;
			Treasure._treasureGathered[1] = false;
			Treasure._treasureGathered[2] = false;
			Treasure._treasureGathered[3] = false;
			Treasure._treasureGathered[4] = false;
			Treasure._treasureGathered[5] = false;
			Treasure._treasureGathered[6] = false;
			Treasure._treasureGathered[7] = false;
			Treasure.idTreasure = 0
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_body.mass = 25;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			var distanceVaisseau:Number = Vec2.distance( new Vec2(Player.instance.x, Player.instance.y), new Vec2(x,y));
			if (  distanceVaisseau < 1500 && !_particle.isEmitting) {
				_particle.start();
			} else if ( distanceVaisseau > 1500 && _particle.isEmitting ) {
				_particle.stop();
			}
			
			if ( _particle.isEmitting ) {
				_particle.emitterX = x;
				_particle.emitterY = y;
			}
		}
		
		public function gather():void
		{
			this.desactivatePhysic();
			var referenceTreasure:Treasure = this;
			TweenLite.to( this, 4, {x: 11475, y: 615, rotation: 0, onComplete: function():void {
				TweenLite.to( referenceTreasure, 2, {x: _positionWhenGathered.x, y: _positionWhenGathered.y, onComplete: function():void {
					Treasure._treasureGathered[id-1] = true;
					body.velocity = new Vec2();
					if ( allTreasureGathered() ) {
						Treasure.triggerBoss.dispatch();
					}
				}});
			}});
			
		}
		
		protected function allTreasureGathered():Boolean
		{
			var returnValue:Boolean = true;
			for ( var i:int = 0; i<Treasure._treasureGathered.length; i++ ) {
				if ( !Treasure._treasureGathered[i] ) {
					returnValue = false;
					break;
				}
			}
			return returnValue;
		}
		
		public static function get triggerBoss():Signal 
		{
			if ( Treasure._triggerBoss == null ) Treasure._triggerBoss = new Signal();
			return Treasure._triggerBoss
		}
		
		override public function desactivatePhysic():void
		{
			super.desactivatePhysic();
			if ( !MessageBox.artifactMessage ) {
				MessageBox.artifactMessage = true;
				MessageBox.instance.affiche("Pilot.\n" +
					"You finally found one of the artifact. Good job!\n" +
					"Bring it back to the station and put it in the repair area. We will transport it in a container.\n" +
					"Scavenge the other ones as fast as possible. There should be around 7 other artifacts in this sector.\n\n" +
					"Over & out.");
			}
		}
		
		override public function destroy():void
		{
			super.destroy();
			if ( _particle.isEmitting ) {
				_particle.stop();
				_particle.removeFromParent();
			}
		}
	}
}