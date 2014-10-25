package core.objects
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.physics.nape.NapeUtils;
	
	import core.hero.Player;
	import core.objects.hook.Hook;
	
	import levels.MainLevel;
	
	import nape.callbacks.InteractionCallback;
	
	import starling.display.Image;
	
	import utils.MessageBox;
	
	public class Collectible extends Sensor
	{
		public function Collectible(name:String, params:Object=null)
		{
			super(name, params);
			if ( name == "hook" ) {
				view = new Image( Gravity.assets.getTexture("buff_hook") );
			} else {
				view = new Image( Gravity.assets.getTexture("buff_booster") );
			}
			beginContactCallEnabled = true;
		}
		
		override public function handleBeginContact(interactionCallback:InteractionCallback):void
		{
			super.handleBeginContact(interactionCallback);
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, interactionCallback);
			if( collider is Player ) {
				switch(name){
					case "hook":
						if ( !Player.hookUnlocked ) {
							Player.hookUnlocked = true;
							Player.instance.hook = new Hook(Player.instance);
							Player.instance.hook.addHook(_ce.state as MainLevel);
							MessageBox.instance.affiche("Pilot.\n" +
								"I just saw that you got your hands on an hold tow hook. Well done.\n\n" +
								"You can connect it to the missile launcher panel, I don't think you'll see any missile that can be loaded in " +
								"this old ship.\n" +
								"Once this is done, you'll be able to press the big 'X' button on the control panel.\n" +
								"Now go get the artifacts. The only one we precisely located was around the coordinates (15,4).\n\n" +
								"Over & out.");
						}
						this.kill = true;
						break;
					case "boosterA": 
					case "boosterB":
						Player.instance.addBooster();
						this.kill = true;
						break;
						
				}
			}
		}
	}
}