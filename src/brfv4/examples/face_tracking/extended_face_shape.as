package brfv4.examples.face_tracking {
	import brfv4.BRFFace;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;
	import brfv4.utils.BRFv4ExtendedFace;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class extended_face_shape extends BRFBasicAS3Example {
		
		private var _extendedShape : BRFv4ExtendedFace = new BRFv4ExtendedFace();
	
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - basic - face tracking - extended face shape\n" +
				"There are 6 more landmarks for the forehead calculated from the 68 landmarks.");
				
			brfManager.init(resolution, resolution, appId);
		};
	
		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
	
			brfManager.update(imageData);
	
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
	
					// The extended face shape is calculated from the usual 68 facial features.
					// The additional landmarks are just estimated, they are not actually tracked.
	
					_extendedShape.update(face);
	
					// Then we draw all 74 landmarks of the _extendedShape.
	
					draw.drawTriangles(	_extendedShape.vertices, _extendedShape.triangles,
						false, 1.0, 0x00a0ff, 0.4);
					draw.drawVertices(	_extendedShape.vertices, 2.0, false, 0x00a0ff, 0.4);
				}
			}
		}
	}
}