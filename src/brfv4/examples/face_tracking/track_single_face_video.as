package brfv4.examples.face_tracking {
	import brfv4.BRFFace;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class track_single_face_video extends BRFBasicAS3Example {
		
		public var _faceDetectionRoi : Rectangle = new Rectangle();
	
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - basic - face tracking - track single face\n" +
				"Detect and track one face and draw the 68 facial landmarks.");
	
			// By default everything necessary for a single face tracking app
			// is set up for you in brfManager.init. There is actually no
			// need to configure much more for a jump start.

			brfManager.init(resolution, resolution, appId);
	
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
	
			brfManager.setFaceDetectionParams(		maxFaceSize * 0.15, maxFaceSize * 1.00, 12, 6);
			brfManager.setFaceTrackingStartParams(	maxFaceSize * 0.15, maxFaceSize * 1.00, 32, 35, 32);
			brfManager.setFaceTrackingResetParams(	maxFaceSize * 0.10, maxFaceSize * 1.00, 40, 55, 32);
		};
	
		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
					
			// In a webcam example imageData is the mirrored webcam video feed.
			// In an image example imageData is the (not mirrored) image content.
	
			brfManager.update(imageData);
	
			// Drawing the results:
	
			draw.clear();
	
			// Face detection results: a rough rectangle used to start the face tracking.
	
			draw.drawRects(brfManager.getAllDetectedFaces(),	false, 1.0, 0x00a1ff, 0.5);
			draw.drawRects(brfManager.getMergedDetectedFaces(),	false, 2.0, 0xffd200, 1.0);
	
			// Get all faces. The default setup only tracks one face.
	
			var faces : Vector.<BRFFace> = brfManager.getFaces();
	
			for(var i : int = 0; i < faces.length; i++) {
	
				var face : BRFFace = faces[i];
	
				if(		face.state == brfv4.BRFState.FACE_TRACKING_START ||
						face.state == brfv4.BRFState.FACE_TRACKING) {
	
					// Face tracking results: 68 facial feature points.
	
					draw.drawTriangles(	face.vertices, face.triangles, false, 1.0, 0x00a0ff, 0.4);
					draw.drawVertices(	face.vertices, 2.0, false, 0x00a0ff, 0.4);
				}
			}
		}
	}
}