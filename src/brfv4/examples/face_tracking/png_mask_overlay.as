package brfv4.examples.face_tracking {
	import flash.display.PixelSnapping;
	import brfv4.BRFFace;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;
	import brfv4.utils.BRFv4PointUtils;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	public class png_mask_overlay extends BRFBasicAS3Example {
		
		public var numFacesToTrack : int = 2;				// Set the number of faces to detect and track.
		
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - advanced - face tracking - PNG/mask image overlay.\n" +
				"Click to cycle through images.");
	
			brfManager.init(resolution, resolution, appId);
			brfManager.setNumFacesToTrack(numFacesToTrack);
	
			// Relax starting conditions to eventually find more faces.
	
			var maxFaceSize : Number = resolution.height;
	
			if(resolution.width < resolution.height) {
				maxFaceSize = resolution.width;
			}
	
			brfManager.setFaceDetectionParams(		maxFaceSize * 0.20, maxFaceSize * 1.00, 12, 8);
			brfManager.setFaceTrackingStartParams(	maxFaceSize * 0.20, maxFaceSize * 1.00, 32, 35, 32);
			brfManager.setFaceTrackingResetParams(	maxFaceSize * 0.15, maxFaceSize * 1.00, 40, 55, 32);
	
			// Load all image masks for quick switching.
	
			prepareImages(this.drawing);
	
			// Add a click event to cycle through the image overlays.

			this.addEventListener(MouseEvent.CLICK, onClicked);
		};
	
		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
	
			brfManager.update(imageData);
	
			draw.clear();
	
			// Face detection results: a rough rectangle used to start the face tracking.
	
			draw.drawRects(brfManager.getAllDetectedFaces(),	false, 1.0, 0x00a1ff, 0.5);
			draw.drawRects(brfManager.getMergedDetectedFaces(),	false, 2.0, 0xffd200, 1.0);
	
			// Get all faces. The default setup only tracks one face.
	
			var faces : Vector.<BRFFace> = brfManager.getFaces();
	
			// If no face was tracked: hide the image overlays.
	
			for(var i : int = 0; i < faces.length; i++) {
	
				var face : BRFFace = faces[i];			// get face
				var baseNode : Sprite = _baseNodes[i];	// get image container
	
				if(		face.state == brfv4.BRFState.FACE_TRACKING_START ||
						face.state == brfv4.BRFState.FACE_TRACKING) {
	
					// Face Tracking results: 68 facial feature points.
	
					draw.drawTriangles(	face.vertices, face.triangles, false, 1.0, 0x00a0ff, 0.4);
					draw.drawVertices(	face.vertices, 2.0, false, 0x00a0ff, 0.4);
	
					// Set position to be nose top and calculate rotation.
	
					baseNode.x			= face.points[27].x;
					baseNode.y			= face.points[27].y;
	
					baseNode.scaleX		= (face.scale / 480) * (1 - toDegree(Math.abs(face.rotationY)) / 110.0);
					baseNode.scaleY		= (face.scale / 480) * (1 - toDegree(Math.abs(face.rotationX)) / 110.0);
					baseNode.rotation	= toDegree(face.rotationZ);
	
					baseNode.alpha		= 1.0;
	
				} else {
	
					baseNode.alpha		= 0.0;
				}
			}
		}

		private function onClicked(event : MouseEvent) : void {
			var i : int = _images.indexOf(_image) + 1;
	
			if(i == _images.length) {
				i = 0;
			}
	
			_image = _images[i];
			changeImage(_image, i);
		}
		
		private function changeImage(bitmap : Loader, index : int) : void {
	
			bitmap.scaleX = _imageScales[index];
			bitmap.scaleY = _imageScales[index];
	
			bitmap.x = -int(bitmap.width  * 0.50);
			bitmap.y = -int(bitmap.height * 0.45);
			
			for(var i : int = 0; i < numFacesToTrack; i++) {
	
				var baseNode : Sprite = _baseNodes[i];
				baseNode.removeChildren();
				
				var loaderBitmap : Bitmap = bitmap.content as Bitmap;
				if(loaderBitmap != null) {
					var bm : Bitmap = new Bitmap(loaderBitmap.bitmapData, PixelSnapping.NEVER, true);
					bm.x = bitmap.x;
					bm.y = bitmap.y;
					bm.scaleX = bitmap.scaleX;
					bm.scaleY = bitmap.scaleY;
					baseNode.addChild(bm);
				}
			}
		}
		
		private function prepareImages(draw : DrawingUtils) : void {
	
			draw.imageContainer.removeChildren();
	
			var i : int = 0;
			var l : int = 0;
	
			for(i = 0, l = numFacesToTrack; i < l; i++) {
				var baseNode : Sprite = new Sprite();
				draw.imageContainer.addChild(baseNode);
				_baseNodes.push(baseNode);
			}
			
			
			i = 0;
			l = _imageURLs.length;
			var loader : Loader;
			
			for(; i < l; i++) {
				loader = new Loader();
				if(i == 0) loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e : Event) : void {changeImage(_image, 0);});
				loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e : Event) : void { trace("security error");});
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e : Event) : void {trace("io error");});
				loader.load(new URLRequest(_imageURLs[i]));
				
				_images.push(loader);
			}
			
			_image = _images[0];
		}
		
		private var _imageURLs : Vector.<String>	= Vector.<String>(["assets/brfv4_lion.png",  "assets/brfv4_img_glasses.png"]);
		private var _imageScales : Vector.<Number>	= Vector.<Number>([3.3, 1.0]);
	
		private var _images : Vector.<Loader>		= new Vector.<Loader>();
		private var _image : Loader					= null;
		private var toDegree : Function				= BRFv4PointUtils.toDegree;
		
		private var _baseNodes : Vector.<Sprite>	= new Vector.<Sprite>();
	}
}