package core.decors
{
	import citrus.objects.platformer.nape.Platform;
	
	import nape.callbacks.InteractionCallback;
	
	public class Decors extends Platform
	{
		public function Decors(name:String, params:Object=null)
		{
			super(name, params);
			updateCallEnabled = true;
		}
		
		
		override public function handleBeginContact(callback:InteractionCallback):void
		{
			super.handleBeginContact(callback);
		}
	}
}