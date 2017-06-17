package brfv4.utils {
	import flash.geom.Point;
	
	public class BRFv4PointUtils {
		
		public static function setPoint(v : Vector.<Number>, i : int, p : Point) : void {
			p.x = v[i * 2]; p.y = v[i * 2 + 1];
		}
		
		public static function applyMovementVector(p : Point, p0 : Point, pmv : Point, f : Number) : void {
			p.x = p0.x + pmv.x * f;
			p.y = p0.y + pmv.y * f;
		}
		
		public static function interpolatePoint(p : Point, p0 : Point, p1 : Point, f : Number) : void {
			p.x = p0.x + f * (p1.x - p0.x);
			p.y = p0.y + f * (p1.y - p0.y);
		}
		
		public static function getAveragePoint(p : Point, ar : Vector.<Point>) : void {
			p.x = 0.0; p.y = 0.0;
			for(var i : int = 0, l : int = ar.length; i < l; i++) {
				p.x += ar[i].x;
				p.y += ar[i].y;
			}
			p.x /= l; p.y /= l;
		}
		
		public static function calcMovementVector(p : Point, p0 : Point, p1 : Point, f : Number) : void {
			p.x = f * (p1.x - p0.x);
			p.y = f * (p1.y - p0.y);
		}
		
		public static function calcMovementVectorOrthogonalCW(p : Point, p0 : Point, p1 : Point, f : Number) : void {
			BRFv4PointUtils.calcMovementVector(p, p0, p1, f);
			var x : Number = p.x;
			var y : Number = p.y;
			p.x = -y;
			p.y = x;
		}
		
		public static function calcMovementVectorOrthogonalCCW(p : Point, p0 : Point, p1 : Point, f : Number) : void {
			BRFv4PointUtils.calcMovementVector(p, p0, p1, f);
			var x : Number = p.x;
			var y : Number = p.y;
			p.x = y;
			p.y = -x;
		}
		
		public static function calcIntersectionPoint(p : Point, pk0 : Point, pk1 : Point, pg0 : Point, pg1 : Point) : void {
			
			//y1 = m1 * x1  + t1 ... y2 = m2 * x2 + t1
			//m1 * x  + t1 = m2 * x + t2
			//m1 * x - m2 * x = (t2 - t1)
			//x * (m1 - m2) = (t2 - t1)

			var dx1 : Number = (pk1.x - pk0.x); if(dx1 == 0) dx1 = 0.01;
			var dy1 : Number = (pk1.y - pk0.y); if(dy1 == 0) dy1 = 0.01;

			var dx2 : Number = (pg1.x - pg0.x); if(dx2 == 0) dx2 = 0.01;
			var dy2 : Number = (pg1.y - pg0.y); if(dy2 == 0) dy2 = 0.01;

			var m1 : Number = dy1 / dx1;
			var t1 : Number = pk1.y - m1 * pk1.x;

			var m2 : Number = dy2 / dx2;
			var t2 : Number = pg1.y - m2 * pg1.x;

			var m1m2 : Number = (m1 - m2); if(m1m2 == 0) m1m2 = 0.01;
			var t2t1 : Number = (t2 - t1); if(t2t1 == 0) t2t1 = 0.01;
			var px : Number = t2t1 / m1m2;
			var py : Number = m1 * px + t1;

			p.x = px;
			p.y = py;
		}
		
		public static function calcDistance(p0 : Point, p1 : Point) : Number {
			return Math.sqrt(
				(p1.x - p0.x) * (p1.x - p0.x) +
				(p1.y - p0.y) * (p1.y - p0.y));
		}
		
		public static function calcAngle(p0 : Point, p1 : Point) : Number {
			return Math.atan2((p1.y - p0.y), (p1.x - p0.x));
		}
		
		public static function toDegree(x : Number) : Number {
			return x * 180.0 / Math.PI;
		}
		
		public static function toRadian(x : Number) : Number {
			return x * Math.PI / 180.0;
		}
	}
}