package utils.assets
{
	public class Assets 
	{
		[Embed(source="../embed/spritesheets/explosion_bleu_01.png")]
		public static var SpriteSheetExplosionBleuTexture:Class;
		[Embed(source="../embed/spritesheets/explosion_bleu_01.xml", mimeType="application/octet-stream")]
		public static var SpriteSheetExplosionBleuXml:Class;
		
		[Embed(source="../embed/spritesheets/explosion_jaune_01.png")]
		public static var SpriteSheetExplosionJauneTexture:Class;
		[Embed(source="../embed/spritesheets/explosion_jaune_01.xml", mimeType="application/octet-stream")]
		public static var SpriteSheetExplosionJauneXml:Class;
		
		[Embed(source="../embed/spritesheets/cursor_map.png")]
		public static var SpriteSheetCursorMapTexture:Class;
		[Embed(source="../embed/spritesheets/cursor_map.xml", mimeType="application/octet-stream")]
		public static var SpriteSheetCursorMapXml:Class;
		
		[Embed(source="../embed/loadingscreen/loading_screen.jpg")]
		public static var LoadingScreen:Class;
	}

}