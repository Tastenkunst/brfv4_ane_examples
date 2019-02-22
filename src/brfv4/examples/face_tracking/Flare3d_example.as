package brfv4.examples.face_tracking {
	import brfv4.BRFFace;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;
//	import brfv4.utils.BRFv4Drawing3DUtils_Flare3D;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class Flare3d_example extends BRFBasicAS3Example {
		
//		private var f3d : BRFv4Drawing3DUtils_Flare3D;
//		
//		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
//	
//			trace("BRFv4 - advanced - face_tracking - Flare3D example.\n" +
//				"Puts glasses on a face.");
//				
//			brfManager.init(resolution, resolution, appId);
//	
//			// Relax starting conditions to eventually find more faces.
//	
//			if(f3d == null) {
//				f3d = new BRFv4Drawing3DUtils_Flare3D(resolution);
//				addChild(f3d);
//			}
//			
//			loadModels();
//		};
//	
//		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
//		
//			brfManager.update(imageData);
//	
//			if(f3d) {
//				f3d.hideAll(); // Hide 3d models. Only show them on top of tracked faces.
//				f3d.updateVideo(imageData);
//			}
//	
//			draw.clear();
//	
//			var faces : Vector.<BRFFace> = brfManager.getFaces();
//	
//			for(var i : int = 0; i < faces.length; i++) {
//	
//				var face : BRFFace = faces[i];
//	
//				if(face.state == brfv4.BRFState.FACE_TRACKING) {
//	
//					// Draw the 68 facial feature points as reference.
//	
//					draw.drawVertices(face.vertices, 2.0, false, 0x00a0ff, 0.4);
//	
//					// Set the 3D model according to the tracked results.
//	
//					if(f3d) f3d.update(i, face, true);
//				}
//			}
//		}
//	
//		public function loadModels() : void {
//			
//			if(f3d) {
//	
//				// Remove all models and load new ones.
//	
//				f3d.removeAll();
//				f3d.loadOcclusionHead("assets/brfv4_occlusion_head.zf3d", 1);
//				f3d.loadModel("assets/brfv4_flare3d_glasses.zf3d", 1);
//			}
//		}
	}
}