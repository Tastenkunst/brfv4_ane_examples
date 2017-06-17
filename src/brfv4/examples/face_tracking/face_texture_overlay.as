package brfv4.examples.face_tracking {
	import brfv4.BRFFace;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class face_texture_overlay extends BRFBasicAS3Example {
		
		[Embed(source="../../../../bin/assets/brfv4_face_textures.jpeg")]
		public static var textureFile : Class;
		[Embed(source="../../../../bin/assets/brfv4_face_textures.txt", mimeType="application/octet-stream")]
		public static var uvFile : Class;
		
		public var _texture : BitmapData;
		public var _uvData : Vector.<Number>;
		
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - basic - face tracking - track single face\n" +
				"Detect and track one face and draw the 68 facial landmarks.");
	
			_texture = (new textureFile() as Bitmap).bitmapData;
			_uvData = Vector.<Number>((new uvFile() as Object).toString().split(","));
			
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
	
					//draw.drawTriangles(face.vertices, face.triangles, false, 1.0, 0x00a0ff, 0.4);
					draw.drawVertices(face.vertices, 2.0, false, 0x00a0ff, 0.4);
	
					// Now draw the texture onto the vertices/triangles using UV mapping.
	
					// draw.drawTexture(face.vertices, face.triangles, faceTex.uv, texture);
	
					// ... or if you want to leave out the inner mouth, remove the last 6 triangles:
	
					var triangles : Vector.<int> = face.triangles.concat();
	
					triangles.splice(triangles.length - 3 * 6, 3 * 6);
	
					draw.drawTexture(face.vertices, triangles, _uvData, _texture);
				}
			}
		}
	}
}