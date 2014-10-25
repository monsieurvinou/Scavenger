package core.objects.grabbable
{
	import com.greensock.TweenLite;
	
	import citrus.objects.CitrusSprite;
	
	import core.decors.Door;
	
	import starling.display.Image;
	import starling.extensions.particles.PDParticleSystem;
	
	import utils.MessageBox;

	public class Shipwreck extends Grabbable
	{
		public var colorName:String;
		protected var _particle:PDParticleSystem;
		
		public function Shipwreck(name:String, params:Object=null)
		{
			super(name, params);
			view = new Image( Gravity.assets.getTexture("shipwreck") );
			var color:uint = 0xFFFFFF;
			switch(name) {
				case "shipwreck_red": color = 0xFF3333; colorName = "red"; break;
				case "shipwreck_blue": color = 0x3333FF; colorName = "blue"; break;
				case "shipwreck_yellow": color = 0xEAE317; colorName = "yellow"; break;
				case "shipwreck_cyan": color = 0x17EAE3; colorName = "cyan"; break;
			}
			group = 10;
			(view as Image).color = color;
		}
		
		public function recycle():void {
			this.desactivatePhysic();
			_particle = new PDParticleSystem(Gravity.assets.getXml("star_particle"), Gravity.assets.getTexture("star_texture"));
			_ce.state.add( new CitrusSprite("particle_shipwreck_"+ colorName, {view: _particle, group: 30}));
			_particle.start();
			_particle.alpha = 0;
			TweenLite.to(_particle, 4, {alpha: 1});
			TweenLite.to( this, 6, {x: 11475, y: 615, onComplete: function():void {
				TweenLite.to(_particle, 1, {alpha: 0, onComplete: function():void {
					// Destoy the doors
					Door.desactivateDoor( colorName );
					_particle.dispose();
				}});
				// Destroy this shipwreck
				kill = true;
			}});
		}
		
		override public function desactivatePhysic():void
		{
			super.desactivatePhysic();
			if ( !MessageBox.shipwreckMessage ) {
				MessageBox.shipwreckMessage = true;
				if ( MessageBox.doorMessage ) {
					MessageBox.instance.affiche("Pilot.\n" +
						"I see you've got your hand on a shipwreck. Bring it back to the station and put it in the repair area.\n" +
						"We should be able to recycle it and desactivate those doors I talked to you about.\n\n" +
						"Don't ask how we can do it, we just can.\n\n" +
						"Over & out.");
				} else {
					MessageBox.doorMessage = true;
					MessageBox.instance.affiche("Pilot.\n" +
						"I see you've got your hand on a shipwreck. Bring it back to the station and put it in the repair area.\n" +
						"We should be able to recycle it. I don't think you saw it yet, but some part of this universe are blocked by some " +
						"sort of doors. I think that with that shipwreck we can desactivate those doors. At least the red ones.\n\n" +
						"Don't ask how we can do it, we just can.\n\n" +
						"Over & out.");
				}
			}
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			if ( _particle != null && _particle.isEmitting ) {
				_particle.emitterX = x;
				_particle.emitterY = y;
			}
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_body.mass = 25;
		}
	}
}