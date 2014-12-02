package levels
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import utils.MessageContent;
	
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import citrus.core.starling.StarlingState;
	import citrus.input.controllers.Keyboard;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.Nape;
	import citrus.view.ACitrusCamera;
	
	import core.hero.Player;
	
	import nape.geom.Vec2;
	
	import org.osflash.signals.Signal;
	
	import starling.core.Starling;
	
	import utils.Background;
	import utils.MessageBox;
	
	public class MVLevel extends StarlingState
	{
		// Nape instance
		public var nape:Nape;
		// Camera. Can be redefined in the override of "initialize" in each level
		protected var cam:ACitrusCamera;
		
		protected var camOffset:Point;
		protected var camBounds:Rectangle;
		public var player:Player;
		
		protected var bg:Background;
		
		protected var camBoundsWidth:Number = 400;
		protected var camBoundsHeight:Number = 320;
		
		public var lvlEnded:Signal;
		protected var appDir:File;
		
		public function MVLevel()
		{
			super();
 			appDir = File.applicationDirectory;
			
			// On crée l'espace physique
			nape = new Nape("nape");
			nape.gravity = new Vec2(0,0);
			nape.visible = true;
			
			// Réglage de la caméra
			camOffset = new Point(0.5, 0.5);
			camBounds = new Rectangle(0, 0, 0, 0); // Taille de la map
			
			lvlEnded = new Signal();
		}
		
		override public function initialize():void {
			super.initialize();
			alpha = 0;
			// On ajoute nape
			add(nape);
			
			// Définition des touches
			var keyboard:Keyboard = _ce.input.keyboard as Keyboard;
			
			// On enlève toute précédente actions
			keyboard.removeKeyActions(Keyboard.SPACE);
			keyboard.removeKeyActions(Keyboard.LEFT);
			keyboard.removeKeyActions(Keyboard.RIGHT);
			keyboard.removeKeyActions(Keyboard.DOWN);
			
			// On détermine les touches du claviers et leurs actions
			keyboard.addKeyAction("left", Keyboard.LEFT, 1);
			keyboard.addKeyAction("right", Keyboard.RIGHT, 1)
			keyboard.addKeyAction("rocket", Keyboard.UP,1);
			keyboard.addKeyAction("back", Keyboard.DOWN,1);
			//keyboard.addKeyAction("fire", Keyboard.W,1);
			keyboard.addKeyAction("booster", Keyboard.CTRL,1);
			keyboard.addKeyAction("hook", Keyboard.X,1);
			// Map
			keyboard.addKeyAction("map", Keyboard.M, 1);
			addElements();
		}
		
		protected function createBounds():void
		{
			var epaisseur:Number = 30;
			// On créer les murs
			var mur:Platform = new Platform("murHaut", {
				x: ( 1024 * 24 ) / 2, y: -15,
				width: 1024 * 24, height: epaisseur
			});
			add(mur);
			mur = new Platform("murGauche", {
				x: -15, y: ( 1024 * 24 ) / 2,
				width: epaisseur, height: ( 1024 * 24 )
			});
			add(mur);
			mur = new Platform("murDroite", {
				x: ( 1024 * 24 ) + 15, y: ( 1024 * 24 ) / 2,
				width: epaisseur, height: ( 1024  * 24 ) 
			});
			add(mur);
			mur = new Platform("murBas", {
				x: ( 1024 * 24 )  / 2, y: ( 1024 * 24 ) + 15,
				width: ( 1024 * 24 ), height: epaisseur
			});
			add(mur);
		}
		
		protected function addElements():void
		{
			player = new Player("player");
			add(player);
			player.controlsEnabled = false;
			
			// Réglage de la caméra
			view.camera.setUp(player, new Rectangle(0,0,(1024*24), (1024*24)), camOffset);
			view.camera.easing = new Point(0.6,0.6);
			view.camera.rotationEasing = 0.4;
		}
		
		protected function addElementTiled(objects:Array, offsetX:Number, offsetY:Number):void
		{
			for each (var object:NapePhysicsObject in objects) {
				object.x += offsetX;
				object.y += offsetY;
				if( object is Platform) object.group = 50;
				add(object);
			}
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			if ( player != null ) {
				if ( alpha == 0 && player.controlsEnabled == false) {
					alpha = 0;
					Starling.current.stage.alpha = 0;
					view.camera.manualPosition = new Point(player.x, player.y + 5000);
					TweenLite.to(this, 7, {alpha: 1});
					TweenLite.to(Starling.current.stage, 10, {alpha: 1});
					TweenLite.to(view.camera.manualPosition, 15, {
						x: player.x, y:player.y, ease: Cubic.easeInOut,
						onComplete: function():void {
							player.controlsEnabled = true;
							view.camera.manualPosition = null;
							view.camera.target = player;
							MessageBox.instance.affiche(MessageContent.getMessage("welcome"));
						}
					});
				}
			}
			if (bg != null) bg.updateBackground(view.camera);
		}
		
		protected function endLevel(type:String="credit"):void
		{
			lvlEnded.dispatch(type);
		}
	}
}