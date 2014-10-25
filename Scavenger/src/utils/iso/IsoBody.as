package utils.iso
{
	import nape.geom.AABB;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.IsoFunction;
	import nape.geom.MarchingSquares;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Polygon;

	public class IsoBody {
		public static function run(iso:IsoFunction, bounds:AABB, granularity:Vec2=null, quality:int=2, simplification:Number=1.5):Body {
			var body:Body = new Body();
			
			if (granularity==null) granularity = Vec2.weak(8, 8);
			var polys:GeomPolyList = MarchingSquares.run(iso, bounds, granularity, quality);
			for (var i:int = 0; i < polys.length; i++) {
				var p:GeomPoly = polys.at(i);
				
				var qolys:GeomPolyList = p.simplify(simplification).convexDecomposition(true);
				for (var j:int = 0; j < qolys.length; j++) {
					var q:GeomPoly = qolys.at(j);
					
					body.shapes.add(new Polygon(q));
					
					// Recycle GeomPoly and its vertices
					q.dispose();
				}
				// Recycle list nodes
				qolys.clear();
				
				// Recycle GeomPoly and its vertices
				p.dispose();
			}
			// Recycle list nodes
			polys.clear();
			
			// Align body with its centre of mass.
			// Keeping track of our required graphic offset.
			var pivot:Vec2 = body.localCOM.mul(-1);
			body.translateShapes(pivot);
			
			body.userData.graphicOffset = pivot;
			return body;
		}
	}
}



