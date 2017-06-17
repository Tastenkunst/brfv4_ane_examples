package brfv4.examples.face_tracking {
	import brfv4.BRFFace;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class face_swap_two_faces extends BRFBasicAS3Example {
		
		// We need two face textures thus create two canvases that will hold the
		// extracted faces.
	
		private var _size : Number = 256; // texture size
	
		private var _extractedFace0 : BitmapData = null;
		private var _extractedFace1 : BitmapData = null;
	
		// BRF analysis image data.
	
		private var _resolution : Rectangle = null;
			
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - advanced - face swap of two faces.\n" +
				"Switch faces with a friend.");
				
			_extractedFace0 = new BitmapData(_size, _size, true, 0x00000000);
			_extractedFace1 = new BitmapData(_size, _size, true, 0x00000000);
	
			_resolution = resolution;
	
			brfManager.init(resolution, resolution, appId);
			brfManager.setNumFacesToTrack(2); // two faces
	
			// Relax starting conditions to eventually find more faces.
	
			var maxFaceSize : Number = resolution.height;
	
			if(resolution.width < resolution.height) {
				maxFaceSize = resolution.width;
			}
	
			brfManager.setFaceDetectionParams(		maxFaceSize * 0.20, maxFaceSize * 1.00, 12, 8);
			brfManager.setFaceTrackingStartParams(	maxFaceSize * 0.20, maxFaceSize * 1.00, 32, 35, 32);
			brfManager.setFaceTrackingResetParams(	maxFaceSize * 0.15, maxFaceSize * 1.00, 40, 55, 32);
		};
	
		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
	
			if(!_resolution || !imageData) return;
			
			brfManager.update(imageData);
	
			draw.clear(); // also clears separate _faceSub canvas
	
			var faces : Vector.<BRFFace> = brfManager.getFaces();
	
			if(faces.length < 2) {
				return;
			}
	
			var face0 : BRFFace = faces[0];
			var face1 : BRFFace = faces[1];
	
			// leave out the inner mouth, remove the last 6 triangles:
	
			var triangles : Vector.<int> = face0.triangles.concat();
			triangles.splice(triangles.length - 3 * 6, 3 * 6);
	
			if(		face0.state == brfv4.BRFState.FACE_TRACKING &&
					face1.state == brfv4.BRFState.FACE_TRACKING) {
	
				_extractedFace0.fillRect(_extractedFace0.rect, 0x00000000);
				_extractedFace1.fillRect(_extractedFace0.rect, 0x00000000);
		
				var uvData0 : Vector.<Number> = prepareFaceTexture(face0, imageData, _extractedFace0);
				var uvData1 : Vector.<Number> = prepareFaceTexture(face1, imageData, _extractedFace1);
	
				draw.drawTexture(face0.vertices, triangles, uvData1, _extractedFace1);
				draw.drawTexture(face1.vertices, triangles, uvData0, _extractedFace0);
			}
	
			// optional visualize the tracking results as dots.
	
			if(face0.state == brfv4.BRFState.FACE_TRACKING) {
				draw.drawVertices(face0.vertices, 2.0, false, 0x00a0ff, 0.4);
			}
	
			if(face1.state == brfv4.BRFState.FACE_TRACKING) {
				draw.drawVertices(face1.vertices, 2.0, false, 0x00a0ff, 0.4);
			}
		}
		
		private function prepareFaceTexture(face : BRFFace, imageData : BitmapData, ctx : BitmapData) : Vector.<Number> {
	
			var f : Number = _size / face.bounds.width;
	
			if (face.bounds.height > face.bounds.width) {
				f = _size / face.bounds.height;
			}
			
			var m : Matrix = new Matrix(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
			m.scale(f, f);
			m.translate(-face.bounds.x * f, -face.bounds.y * f);
			
			ctx.draw(imageData, m, null, null, null, true);
	
			var uvData : Vector.<Number> = new Vector.<Number>();
	
			for(var u : int = 0; u < face.vertices.length; u += 2) {
				var ux : Number = (((face.vertices[u]   - face.bounds.x) * f) / _size);
				var uy : Number = (((face.vertices[u+1] - face.bounds.y) * f) / _size);
				uvData.push(ux);
				uvData.push(uy);
			}
	
			return uvData;
		}
	}
}