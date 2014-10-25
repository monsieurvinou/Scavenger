package core.decors
{
	
	import citrus.objects.platformer.nape.Platform;
	
	import nape.phys.Body;
	import nape.shape.Shape;
	
	public class DecorsGenere extends Platform
	{
		private var _generatedBody:Body;
		
		public function DecorsGenere(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		override protected function createShape():void
		{
			super.createShape();
			if(_generatedBody != null) {
				_body.shapes.clear();
				_generatedBody.shapes.foreach( function (sha:Shape):void {
					_body.shapes.add(sha);
				});
			}
		}
		
		public function set generatedBody(value:Body):void { _generatedBody = value; }
		
	}
}