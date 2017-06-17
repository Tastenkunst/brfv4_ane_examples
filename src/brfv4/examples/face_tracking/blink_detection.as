package brfv4.examples.face_tracking {
	import brfv4.BRFFace;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class blink_detection extends BRFBasicAS3Example {
		
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - advanced - face tracking - simple blink detection.\n" +
				"Detects a blink of the eyes: ");
	
			brfManager.init(resolution, resolution, appId);
		};
	
		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
						
			brfManager.update(imageData);
	
			draw.clear();
	
			// Face detection results: a rough rectangle used to start the face tracking.
	
			draw.drawRects(brfManager.getAllDetectedFaces(),	false, 1.0, 0x00a1ff, 0.5);
			draw.drawRects(brfManager.getMergedDetectedFaces(),	false, 2.0, 0xffd200, 1.0);
	
			var faces : Vector.<BRFFace> = brfManager.getFaces(); // default: one face, only one element in that array.
	
			for(var i : int= 0; i < faces.length; i++) {
	
				var face : BRFFace = faces[i];
	
				if(face.state == brfv4.BRFState.FACE_TRACKING) {
	
					// simple blink detection
	
					// A simple approach with quite a lot false positives. Fast movement can't be
					// handled properly. This code is quite good when it comes to
					// starring contest apps though.
	
					// It basically compares the old positions of the eye points to the current ones.
					// If rapid movement of the current points was detected it's considered a blink.
	
					var v : Vector.<Number> = face.vertices;
	
					if(_oldFaceShapeVertices.length == 0) storeFaceShapeVertices(v);
	
					var k : int, l : int, yLE : Number, yRE : Number;
	
					// Left eye movement (y)
	
					for(k = 36, l = 41, yLE = 0; k <= l; k++) {
						yLE += v[k * 2 + 1] - _oldFaceShapeVertices[k * 2 + 1];
					}
					yLE /= 6;
	
					// Right eye movement (y)
	
					for(k = 42, l = 47, yRE = 0; k <= l; k++) {
						yRE += v[k * 2 + 1] - _oldFaceShapeVertices[k * 2 + 1];
					}
	
					yRE /= 6;
	
					var yN : Number = 0;
	
					// Compare to overall movement (nose y)
	
					yN += v[27 * 2 + 1] - _oldFaceShapeVertices[27 * 2 + 1];
					yN += v[28 * 2 + 1] - _oldFaceShapeVertices[28 * 2 + 1];
					yN += v[29 * 2 + 1] - _oldFaceShapeVertices[29 * 2 + 1];
					yN += v[30 * 2 + 1] - _oldFaceShapeVertices[30 * 2 + 1];
					yN /= 4;
	
					var blinkRatio : Number = Math.abs((yLE + yRE) / yN);
	
					if((blinkRatio > 12 && (yLE > 0.4 || yRE > 0.4))) {
						trace("blink " + blinkRatio.toFixed(2) + " " + yLE.toFixed(2) + " " +
							yRE.toFixed(2) + " " + yN.toFixed(2));
	
						blink();
					}
	
					// Let the color of the shape show whether you blinked.
	
					var color : uint = 0x00a0ff;
	
					if(_blinked) {
						color = 0xffd200;
					}
	
					// Face Tracking results: 68 facial feature points.
	
					draw.drawTriangles(	face.vertices, face.triangles, false, 1.0, color, 0.4);
					draw.drawVertices(	face.vertices, 2.0, false, color, 0.4);
	
					trace("blinked: " + (_blinked ? "Yes" : "No"));
	
					storeFaceShapeVertices(v);
				}
			}
		}			
	
		private function blink() : void {
			_blinked = true;
	
			if(_timeOut > -1) { clearTimeout(_timeOut); }
	
			_timeOut = setTimeout(resetBlink, 150);
		}
	
		private function resetBlink() : void {
			_blinked = false;
		}
	
		private function storeFaceShapeVertices(vertices : Vector.<Number>) : void {
			for(var i : int = 0, l : int = vertices.length; i < l; i++) {
				_oldFaceShapeVertices[i] = vertices[i];
			}
		}
	
		var _oldFaceShapeVertices : Vector.<Number> = new Vector.<Number>();
		var _blinked: Boolean	= false;
		var _timeOut : uint		= 0;
	}
}