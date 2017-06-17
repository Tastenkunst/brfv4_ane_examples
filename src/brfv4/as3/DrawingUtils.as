package brfv4.as3 {
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * @author Marcel Klammer, Tastenkunst GmbH, 2016
	 */
	public class DrawingUtils {
		
		public var imageContainer : Sprite;
		public var draw : Graphics;

		public function DrawingUtils(drawing : Sprite) {
			draw = drawing.graphics;
			imageContainer = drawing;
		}
		
		public function clear() : void {
			draw.clear();
		}
		
		public function drawVertices(vertices : Vector.<Number>, radius : Number = 2.0, 
				clear : Boolean = false,
				fillColor : uint = 0x00a0ff, fillAlpha : Number = 1.0) : void {
			
			var g : Graphics = draw;
			
			clear && g.clear();
			
			g.beginFill(fillColor, fillAlpha);
			
			var i : int = 0;
			var l : int = vertices.length;
			
			for(; i < l;) {
				
				var x : Number = vertices[i++];
				var y : Number = vertices[i++];
				
				g.drawCircle(x, y, radius);
			}

			g.endFill();
		}
		
		public function drawTriangles(vertices : Vector.<Number>, triangles : Vector.<int>, 
				clear : Boolean = false, lineThickness : Number = 0.50, 
				lineColor : uint = 0x00a0ff, lineAlpha : Number = 0.85) : void {
			
			var g : Graphics = draw;
			
			clear && g.clear();
			
			g.lineStyle(lineThickness, lineColor, lineAlpha);
			g.drawTriangles(vertices, triangles);
			g.lineStyle();
		}
		
		public function fillTriangles(vertices : Vector.<Number>, triangles : Vector.<int>, 
				clear : Boolean = false, 
				fillColor : uint = 0x00a0ff, fillAlpha : Number = 0.85) : void {
			
			var g : Graphics = draw;
			
			clear && g.clear();
			
			g.beginFill(fillColor, fillAlpha);
			g.drawTriangles(vertices, triangles);
			g.endFill();
		}
		
		public function drawTexture(vertices : Vector.<Number>, triangles : Vector.<int>, 
				uvData : Vector.<Number>, texture : BitmapData) : void {
			
			var g : Graphics = draw;
			
			g.lineStyle();
			g.beginBitmapFill(texture);
			g.drawTriangles(vertices, triangles, uvData);
			g.endFill();
		}
		
		public function drawRect(rect : Rectangle, clear : Boolean = false, 
				lineThickness : Number = 1.0, lineColor : uint = 0x00a0ff, lineAlpha : Number = 1.0) : void {
			
			var g : Graphics = this.draw;
			
			clear && g.clear();
			
			g.lineStyle(lineThickness, lineColor, lineAlpha);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
			g.lineStyle();
		}
		
		public function drawRects(rects : Vector.<Rectangle>, clear : Boolean = false, 
				lineThickness : Number = 1.0, lineColor : uint = 0x00a0ff, lineAlpha : Number = 1.0) : void {
			
			var g : Graphics = this.draw;
			
			clear && g.clear();
			
			g.lineStyle(lineThickness, lineColor, lineAlpha);
			
			for(var i : int = 0, l : int = rects.length; i < l; i++) {
				var rect : Rectangle = rects[i];
				g.drawRect(rect.x, rect.y, rect.width, rect.height);	
			}
			
			g.lineStyle();
		}
		
		public function drawPoint(point : Point, radius : Number = 2.0, clear : Boolean = false, 
				fillColor : uint = 0x00a0ff, fillAlpha : Number = 1.0) : void {
			
			var g : Graphics = this.draw;
			
			clear && g.clear();
			
			g.beginFill(fillColor, fillAlpha);
			g.drawCircle(point.x, point.y, radius);
			g.lineStyle();
		}
		
		public function drawPoints(points : Vector.<Point>, radius : Number = 2.0, clear : Boolean = false, 
				fillColor : uint = 0x00a0ff, fillAlpha : Number = 1.0) : void {
			
			var g : Graphics = this.draw;
			
			clear && g.clear();
			
			g.beginFill(fillColor, fillAlpha);
			
			for(var i : int = 0, l : int = points.length; i < l; i++) {
				var point : Point = points[i];
				g.drawCircle(point.x, point.y, radius);
			}
			
			g.lineStyle();
		}
	}
}