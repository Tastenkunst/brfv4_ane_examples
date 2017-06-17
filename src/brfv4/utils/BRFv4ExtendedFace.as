package brfv4.utils {
	import brfv4.BRFFace;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BRFv4ExtendedFace {
		
		public var vertices		: Vector.<Number>;
		public var triangles	: Vector.<int>;
		public var points		: Vector.<Point>;
		public var bounds		: Rectangle;
		
		private var _tmpPoint0	: Point;
		private var _tmpPoint1	: Point;
		private var _tmpPoint2	: Point;
		private var _tmpPoint3	: Point;
		private var _tmpPoint4 : Point;
		private var _tmpPoint5 : Point;

		public function BRFv4ExtendedFace() {
			
			vertices	= new Vector.<Number>();
			triangles	= new Vector.<int>();
			points		= new Vector.<Point>();
			bounds		= new Rectangle();
			
			_tmpPoint0	= new Point();
			_tmpPoint1	= new Point();
			_tmpPoint2	= new Point();
			_tmpPoint3	= new Point();
			_tmpPoint4	= new Point();
			_tmpPoint5	= new Point();
		}
		
		public function update(face : BRFFace) : void {
	
			var i : int, l : int;
	
			for(i = points.length, l = face.points.length + 6; i < l; ++i) {
				points[i] = new Point(0.0, 0.0);
			}
	
			generateExtendedVertices(face);
			generateExtendedTriangles(face);
			updateBounds();
			updatePoints();
		};
	
		public function generateExtendedVertices(face : BRFFace) : void {
	
			var v : Vector.<Number> = face.vertices;
			var i : int, l : int;
	
			vertices.length = 0;
	
			for(i = 0, l = v.length; i < l; i++) {
				vertices[i] = v[i];
			}
	
			addUpperForeheadPoints(vertices);
		};
	
		public function generateExtendedTriangles(face : BRFFace) : void {
			if(triangles.length == 0) {
				triangles = face.triangles.concat();
				triangles.push(
					0, 17, 68,
					17, 18, 68,
					18, 19, 69,
					18, 68, 69,
					19, 20, 69,
					20, 23, 71,
					20, 69, 70,
					20, 70, 71,
					23, 24, 72,
					23, 71, 72,
					24, 25, 72,
					25, 26, 73,
					25, 72, 73,
					16, 26, 73
				);
			}
		};
	
		public function updateBounds() : void {
	
			var minX : Number = 0;
			var minY : Number = 0;
			var maxX : Number = 9999;
			var maxY : Number = 9999;
	
			var i : int, l : int, value : Number;
	
			for(i = 0, l = vertices.length; i < l; i++) {
				value = vertices[i];
	
				if((i % 2) == 0) {
					if(value < minX) minX = value;
					if(value > maxX) maxX = value;
				} else {
					if(value < minY) minY = value;
					if(value > maxY) maxY = value;
				}
			}
	
			bounds.x = minX;
			bounds.y = minY;
			bounds.width = maxX - minX;
			bounds.height = maxY - minY;
		};
	
		public function updatePoints() : void {
	
			var i : int, k : int, l : int, x : Number, y : Number;
	
			for(i = 0, k = 0, l = points.length; i < l; ++i) {
				x = vertices[k]; k++;
				y = vertices[k]; k++;
	
				points[i].x = x;
				points[i].y = y;
			}
		};
	
		public function addUpperForeheadPoints(v : Vector.<Number>) : void {
	
			var p0 : Point = _tmpPoint0;
			var p1 : Point = _tmpPoint1;
			var p2 : Point = _tmpPoint2;
			var p3 : Point = _tmpPoint3;
			var p4 : Point = _tmpPoint4;
			var p5 : Point = _tmpPoint5;
	
			// base distance
	
			setPoint(v, 33, p0); // nose top
			setPoint(v, 27, p1); // nose base
			var baseDist : Number = calcDistance(p0, p1) * 1.5;
	
			// eyes as base line for orthogonal vector
	
			setPoint(v, 39, p0); // left eye inner corner
			setPoint(v, 42, p1); // right eye inner corner
	
			var distEyes : Number = calcDistance(p0, p1);
	
			calcMovementVectorOrthogonalCCW(p4, p0, p1, baseDist / distEyes);
	
			// orthogonal line for intersection point calculation
	
			setPoint(v, 27, p2); // nose top
			applyMovementVector(p3, p2, p4, 10.95);
			applyMovementVector(p2, p2, p4, -10.95);
	
			calcIntersectionPoint(p5, p2, p3, p0, p1);
	
			// simple head rotation
	
			var f : Number = 0.5-calcDistance(p0, p5) / distEyes;
	
			// outer left forehead point
	
			setPoint(v, 0, p5); // top left outline point
			var dist : Number = calcDistance(p0, p5) * 0.75;
	
			interpolatePoint(		p2, p0, p1, (dist / -distEyes));
			applyMovementVector(	p3, p2, p4, 0.75);
			addToExtendedVertices(	p3);
	
			// upper four forehead points
	
			interpolatePoint(		p2, p0, p1, f - 0.65);
			applyMovementVector(	p3, p2, p4, 1.02);
			addToExtendedVertices(	p3);
	
			interpolatePoint(		p2, p0, p1, f + 0.0);
			applyMovementVector(	p3, p2, p4, 1.10);
			addToExtendedVertices(	p3);
	
			interpolatePoint(		p2, p0, p1, f + 1.0);
			applyMovementVector(	p3, p2, p4, 1.10);
			addToExtendedVertices(	p3);
	
			interpolatePoint(		p2, p0, p1, f + 1.65);
			applyMovementVector(	p3, p2, p4, 1.02);
			addToExtendedVertices(	p3);
	
			// outer right forehead point
	
			setPoint(v, 16, p5); // top right outline point
			dist = calcDistance(p1, p5) * 0.75;
	
			interpolatePoint(		p2, p1, p0, (dist / -distEyes));
			applyMovementVector(	p3, p2, p4, 0.75);
			addToExtendedVertices(	p3);
		};
	
		public function addToExtendedVertices(p : Point) : void {
			vertices.push(p.x);
			vertices.push(p.y);
		};

		private var setPoint : Function 						= BRFv4PointUtils.setPoint;
		private var applyMovementVector : Function 				= BRFv4PointUtils.applyMovementVector;
		private var interpolatePoint : Function 				= BRFv4PointUtils.interpolatePoint;
		private var calcMovementVector : Function 				= BRFv4PointUtils.calcMovementVector;
		private var calcMovementVectorOrthogonalCW : Function 	= BRFv4PointUtils.calcMovementVectorOrthogonalCW;
		private var calcMovementVectorOrthogonalCCW : Function	= BRFv4PointUtils.calcMovementVectorOrthogonalCCW;
		private var calcIntersectionPoint : Function 			= BRFv4PointUtils.calcIntersectionPoint;
		private var calcDistance : Function 					= BRFv4PointUtils.calcDistance;

	}
}