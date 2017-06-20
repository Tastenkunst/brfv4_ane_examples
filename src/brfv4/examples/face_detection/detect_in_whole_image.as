package brfv4.examples.face_detection {
	import brfv4.BRFManager;
	import brfv4.BRFMode;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class detect_in_whole_image extends BRFBasicAS3Example {
			
		public var _faceDetectionRoi : Rectangle = new Rectangle();
	
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - basic - face detection - detect faces in the whole image\n"+
				"Set most of the/the whole image as detection area (region of interest).");
	
			brfManager.init(resolution, resolution, appId);
	
			// We explicitly set the mode to run in: BRFMode.FACE_DETECTION.
	
			brfManager.setMode(brfv4.BRFMode.FACE_DETECTION);
	
			// Then we set the face detection region of interest to be
			// most/all of the overall analysed image (green rectangle, 100%).
	
			_faceDetectionRoi.setTo(
				resolution.width * 0.00, resolution.height * 0.00,
				resolution.width * 1.00, resolution.height * 1.00
			);
			brfManager.setFaceDetectionRoi(_faceDetectionRoi);
	
			// We can have either a landscape area (desktop), then choose height or
			// we can have a portrait area (mobile), then choose width as max face size.
	
			var maxFaceSize : Number = _faceDetectionRoi.height;
	
			if(_faceDetectionRoi.width < _faceDetectionRoi.height) {
				maxFaceSize = _faceDetectionRoi.width;
			}
	
			// Merged faces (yellow) will only show up if they are at least 30% of maxFaceSize.
			// Move away from the camera to see the merged detected faces (yellow) disappear.
	
			// Btw. the following settings are the default settings set by BRFv4 on init.
	
			brfManager.setFaceDetectionParams(maxFaceSize * 0.30, maxFaceSize * 1.00, 12, 8);
		};
	
		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
		
			brfManager.update(imageData);
	
			// Drawing the results:
	
			draw.clear();
	
			// Show the region of interest (green).
	
			draw.drawRect(_faceDetectionRoi,					false, 4.0, 0x8aff00, 0.5);
	
			// Then draw all detected faces (blue).
	
			draw.drawRects(brfManager.getAllDetectedFaces(),	false, 1.0, 0x00a1ff, 0.5);
	
			// In the end add the merged detected faces that have at least 12 detected faces
			// in a certain area (yellow).
	
			draw.drawRects(brfManager.getMergedDetectedFaces(),	false, 2.0, 0xffd200, 1.0);
	
			// Now print the face sizes:
	
			printSize(brfManager.getMergedDetectedFaces(), false);
		};
	
		public function printSize(rects : Vector.<Rectangle>, printAlwaysMinMax : Boolean) : void {
	
			var maxWidth : Number = 0;
			var minWidth : Number = 9999;
	
			for(var i : int = 0, l : int = rects.length; i < l; i++) {
	
				if(rects[i].width < minWidth) {
					minWidth = rects[i].width;
				}
	
				if(rects[i].width > maxWidth) {
					maxWidth = rects[i].width;
				}
			}
	
			if(maxWidth > 0) {
	
				var str : String = "";
	
				// One face or same size: name it size, otherwise name it min/max.
	
				if(minWidth == maxWidth && !printAlwaysMinMax) {
					str = "size: " + maxWidth.toFixed(0);
				} else {
					str = "min: " + minWidth.toFixed(0) + " max: " + maxWidth.toFixed(0);
				}
	
				trace(str);
			}
		}
	}
}