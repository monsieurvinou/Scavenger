package levels
{
	import com.greensock.TweenLite;
	
	import flash.geom.Point;
	
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.physics.nape.Nape;
	import citrus.sounds.CitrusSoundGroup;
	
	import core.decors.FalsePlayer;
	
	import nape.geom.Vec2;
	
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.extensions.particles.PDParticleSystem;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;
	
	import utils.Background;
	
	public class Credit extends StarlingState
	{
		private var player:FalsePlayer;
		protected var _nape:Nape;
		protected var _bg:Background;
		protected var _particle:PDParticleSystem;
		
		protected var thanks:TextField;
		protected var text:TextField;
		
		public function Credit()
		{
			super();
			_nape = new Nape("nape");
			_nape.gravity = new Vec2(0,0);
			_nape.visible = false;
			
			_ce.sound.getGroup(CitrusSoundGroup.BGM).volume = 0.5;
			_ce.sound.getSound("credit").volume = 0;
			_ce.sound.playSound("credit");
			TweenLite.to( _ce.sound.getSound("credit"), 5, {volume: 0.8});
			TweenLite.to(this, 4, {alpha: 1});
			
			player = new FalsePlayer();
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			add(_nape);
			
			player.x = 100;
			player.y = 320;
			add(player);
			
			view.camera.setUp(player, null, new Point(0.2, 0.5));
			
			_bg = new Background("Background", {
				tiles: Gravity.assets.getTexture("star_1"), 
				widthScene: 800,
				heightScene: 640
			});
			add(_bg);
			_bg.x = player.x - _bg.widthScene/2;
			_bg.y = player.y - _bg.heightScene/2;
			
			_particle = new PDParticleSystem(Gravity.assets.getXml("hero_particle"), Gravity.assets.getTexture("VaisseauFinal"));
			_ce.state.add( new CitrusSprite("particule_hero", {view: _particle, group: 10}));
			_particle.start();
			
			// TEXT
			thanks = new TextField(800, 52, "<Thanks for playing>", "Courier", 50, 0xEAEAEA, true);
			thanks.hAlign = HAlign.CENTER;
			thanks.vAlign = VAlign.CENTER;
			
			text = new TextField(600, 500, "", "Courier", 32, 0xEAEAEA, true);
			text.hAlign = HAlign.RIGHT;
			
			Starling.current.stage.addChild(text);
			Starling.current.stage.addChild(thanks);
			
			thanks.x = 0; 
			thanks.y = 24;
			
			text.x = 800 - text.width; 
			text.y = 100;
			
			text.text = "Thanks for the help : ";
			text.text += "\n\n";
			text.text += "<Matthieu Nedey for the loading screen>\n";
			text.text += "<http://www.matthieunedey.com/>";
			text.text += "\n\n";
			text.text += "<Master484 for the explosions assets>\n";
			text.text += "<http://m484games.ucoz.com/>";
			text.text += "\n\n";
			text.text += "<OpenGameArt in general>\n";
			text.text += "<http://opengameart.org/>";
			
			
			var blackScreen:Quad = new Quad(800,640, 0x000000);
			Starling.current.stage.addChild(blackScreen);
			TweenLite.to( blackScreen, 5, {alpha: 0});
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			if ( _bg != null ) _bg.updateBackground(view.camera);
			if ( _particle != null && _particle.isEmitting ) {
				_particle.emitterX = player.x;
				_particle.emitterY = player.y;
				_particle.emitAngle = player.body.rotation + deg2rad(90);
				_particle.startRotation = player.body.rotation;
				_particle.endRotation = player.body.rotation;
			}
		}
	}
}