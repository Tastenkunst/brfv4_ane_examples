package brfv4.examples.face_tracking {
	import flash.geom.Point;
	import brfv4.BRFFace;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;
	import brfv4.utils.BRFv4PointUtils;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class smile_detection extends BRFBasicAS3Example {
		
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - intermediate - face tracking - simple smile detection.\n" +
				"Detects how much someone is smiling.");
	
			brfManager.init(resolution, resolution, appId);
		};
	
		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
					
			brfManager.update(imageData);
	
			draw.clear();
	
			// Face detection results: a rough rectangle used to start the face tracking.
	
			draw.drawRects(brfManager.getAllDetectedFaces(),	false, 1.0, 0x00a1ff, 0.5);
			draw.drawRects(brfManager.getMergedDetectedFaces(),	false, 2.0, 0xffd200, 1.0);
	
			var faces : Vector.<BRFFace> = brfManager.getFaces(); // default: one face, only one element in that array.
	
			for(var i : int = 0; i < faces.length; i++) {
	
				var face : BRFFace = faces[i];
	
				if(	face.state == brfv4.BRFState.FACE_TRACKING_START ||
						face.state == brfv4.BRFState.FACE_TRACKING) {
	
					// Smile Detection
	
					setPoint(face.vertices, 48, p0); // mouth corner left
					setPoint(face.vertices, 54, p1); // mouth corner right
	
					var mouthWidth : Number = calcDistance(p0, p1);
	
					setPoint(face.vertices, 39, p1); // left eye inner corner
					setPoint(face.vertices, 42, p0); // right eye outer corner
	
					var eyeDist : Number = calcDistance(p0, p1);
					var smileFactor : Number = mouthWidth / eyeDist;
	
					smileFactor -= 1.40; // 1.40 - neutral, 1.70 smiling
	
					if(smileFactor > 0.25) smileFactor = 0.25;
					if(smileFactor < 0.00) smileFactor = 0.00;
	
					smileFactor *= 4.0;
	
					if(smileFactor < 0.0) { smileFactor = 0.0; }
					if(smileFactor > 1.0) { smileFactor = 1.0; }
	
					// Let the color show you how much you are smiling.
	
					var color : int =
						(((0xff * (1.0 - smileFactor) & 0xff) << 16)) +
						(((0xff * smileFactor) & 0xff) << 8);
	
					// Face Tracking results: 68 facial feature points.
	
					draw.drawTriangles(	face.vertices, face.triangles, false, 1.0, color, 0.4);
					draw.drawVertices(	face.vertices, 2.0, false, color, 0.4);
	
					trace("smile factor: " +
						(smileFactor * 100).toFixed(0) + "%");
				}
			}
		}
		
		private var p0 : Point = new Point();
		private var p1 : Point = new Point();
		
		private var setPoint : Function		= BRFv4PointUtils.setPoint;
		private var calcDistance : Function	= BRFv4PointUtils.calcDistance;
	}
}