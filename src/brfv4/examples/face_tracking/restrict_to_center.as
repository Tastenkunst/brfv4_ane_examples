package brfv4.examples.face_tracking {
	import brfv4.BRFFace;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;
	import brfv4.utils.BRFv4PointUtils;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class restrict_to_center extends BRFBasicAS3Example {
		
		private var _faceDetectionRoi : Rectangle = new Rectangle();
	
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - basic - face tracking - restrict to frontal and center\n" +
				"Only track a face if it is in a certain distance to the camera and is frontal.");
	
			brfManager.init(resolution, resolution, appId);
	
			// Sometimes you want to restrict the position and pose of a face.
	
			// In this setup we will restrict pick up of the face to the center of the image
			// and we will let BRFv4 reset if the user turns his head too much.
	
			// We limit the face detection region of interest to be in the central
			// part of the overall analysed image (green rectangle).
	
			_faceDetectionRoi.setTo(
				resolution.width * 0.25, resolution.height * 0.10,
				resolution.width * 0.50, resolution.height * 0.80
			);
			brfManager.setFaceDetectionRoi(_faceDetectionRoi);
	
			// We can have either a landscape area (desktop), then choose height or
			// we can have a portrait area (mobile), then choose width as max face size.
	
			var maxFaceSize : Number = _faceDetectionRoi.height;
	
			if(_faceDetectionRoi.width < _faceDetectionRoi.height) {
				maxFaceSize = _faceDetectionRoi.width;
			}
	
			// Use the usual detection distances to be able to tell the user what to do.
	
			brfManager.setFaceDetectionParams(maxFaceSize * 0.30, maxFaceSize * 1.00, 12, 8);
	
			// Set up the pickup parameters for the face tracking:
			// startMinFaceSize, startMaxFaceSize, startRotationX/Y/Z
	
			// Faces will only get picked up, if they look straight into the camera
			// and have a certain size (distance to camera).
	
			brfManager.setFaceTrackingStartParams(maxFaceSize * 0.50, maxFaceSize * 0.70, 15, 15, 15);
	
			// Set up the reset conditions for the face tracking:
			// resetMinFaceSize, resetMaxFaceSize, resetRotationX/Y/Z
	
			// Face tracking will reset to face detection, if the face turns too much or leaves
			// the desired distance to the camera.
	
			brfManager.setFaceTrackingResetParams(maxFaceSize * 0.45, maxFaceSize * 0.75, 25, 25, 25);
		};
	
		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
	
			brfManager.update(imageData);
	
			draw.clear();
	
			draw.drawRect(_faceDetectionRoi,					false, 2.0, 0x8aff00, 0.5);
			draw.drawRects(brfManager.getAllDetectedFaces(),	false, 1.0, 0x00a1ff, 0.5);
	
			var mergedFaces : Vector.<Rectangle> = brfManager.getMergedDetectedFaces();
	
			draw.drawRects(mergedFaces,							false, 2.0, 0xffd200, 1.0);
	
			var faces : Vector.<BRFFace> = brfManager.getFaces();
			var oneFaceTracked : Boolean = false;
	
			for(var i : int = 0; i < faces.length; i++) {
	
				var face : BRFFace = faces[i];
	
				if(face.state == brfv4.BRFState.FACE_TRACKING) {
	
					// Read the rotation of the face and draw it
					// green if the face is frontal or
					// red if the user turns the head too much.
	
					var maxRot : Number = BRFv4PointUtils.toDegree(
						Math.max(
							Math.abs(face.rotationX),
							Math.abs(face.rotationY),
							Math.abs(face.rotationZ)
						)
					);
	
					var percent : Number = maxRot / 20.0;
	
					if(percent < 0.0) { percent = 0.0; }
					if(percent > 1.0) { percent = 1.0; }
	
					var color : uint =
						(((0xff * percent) & 0xff) << 16) +
						(((0xff * (1.0 - percent) & 0xff) << 8));
	
					draw.drawTriangles(	face.vertices, face.triangles, false, 1.0, color, 0.4);
					draw.drawVertices(	face.vertices, 2.0, false, color, 0.4);
	
					oneFaceTracked = true;
				}
			}
	
			// Check, if the face is too close or too far way and tell the user what to do.
	
			if(!oneFaceTracked && mergedFaces.length > 0) {
	
				var mergedFace : Rectangle = mergedFaces[0];
	
				if(mergedFace.width < _faceDetectionRoi.width * 0.50) { // startMinFaceSize
	
					trace("Come closer.");
	
				} else if(mergedFace.width > _faceDetectionRoi.width * 0.70) { // startMaxFaceSize
	
					trace("Move further away.");
				}
			}
		}
	}
}