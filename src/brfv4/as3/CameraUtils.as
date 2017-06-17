package brfv4.as3 {
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.PermissionEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.permissions.PermissionStatus;
	
	public class CameraUtils extends EventDispatcher {
		
		public var cameraWidth : int;
		public var cameraHeight : int;
		
		public var doMirror : Boolean;
		public var rotation : Number;
		
		public var camera : Camera;
		public var cameraData : BitmapData;

		public var video : Video;
		
		public var cameraResolution : Rectangle;
		public var cameraMatrix : Matrix;
		
		public function CameraUtils() {
			
			cameraResolution = new Rectangle();
			cameraMatrix = new Matrix();
		}
		
		public function init(cameraWidth : int = 640, cameraHeight : int = 480, 
				mirrored : Boolean = true, rotation : Number = 0.0) : Boolean {
					
			this.cameraWidth = cameraWidth;
			this.cameraHeight = cameraHeight;
			this.doMirror = mirrored;
			this.rotation = rotation;
			
			if(Camera.isSupported) {
			
				camera = Camera.getCamera("1");
			
				if(camera == null) {
					camera = Camera.getCamera();
				}
			
				if(camera != null) {
			
					if(Camera.permissionStatus != PermissionStatus.GRANTED) {
						camera.addEventListener(PermissionEvent.PERMISSION_STATUS, function(event : PermissionEvent) : void {
							if(event.status == PermissionStatus.GRANTED) {
								onPermissionGranted();
							}
						});
						
						try {
							camera.requestPermission();	
						} catch(error : Error) {
							trace("error: " + error);
						}
					} else {
						onPermissionGranted();
					}
				}
			}
			
			return camera != null;
		}
		
		public function onPermissionGranted() : void {
			
			camera.setMode(cameraWidth, cameraHeight, 30);
			
			cameraWidth = camera.width;
			cameraHeight = camera.height;
			
			updateMatrix();
			
			if(video != null) {
				if(video.parent != null) {
					video.parent.removeChild(video);	
				}
				video.attachCamera(null);
				video = null;
			}
			
			if(cameraData != null) {
				try {
					cameraData.dispose();
					cameraData = null;
				} catch(error : Error) {}
			}
			
			video = new Video(cameraWidth, cameraHeight);
			video.transform.matrix = cameraMatrix;
			video.smoothing = true;
			
			video.attachCamera(camera);
			
			cameraData = new BitmapData(cameraResolution.width, cameraResolution.height, true, 0xff444444);
			
			dispatchEvent(new Event("ready"));
		}

		public function update() : void {
			cameraData.draw(video, cameraMatrix);
		}
		
		public function updateMatrix() : void {
			
			var cw : Number = cameraWidth;
			var ch : Number = cameraHeight;
			
			cameraMatrix.identity();
			
			var rotated : Boolean = false;
			
			if(rotation == 90) {
				cameraMatrix.rotate(rotation * Math.PI / 180);
				cameraMatrix.translate(ch, 0);
				rotated = true;
			} else if(rotation == -90) {
				cameraMatrix.rotate(rotation * Math.PI / 180);
				cameraMatrix.translate(0, cw);
				rotated = true;
			}
			
			if(doMirror) {
				cameraMatrix.scale(-1.0, 1.0);
				if(rotated) {
					cameraMatrix.translate(ch, 0.0);
				} else {
					cameraMatrix.translate(cw, 0.0);
				}
			}
			
			if(rotated) {
				cw = cameraHeight;
				ch = cameraWidth;
			}
			
			cameraResolution.setTo(0, 0, cw, ch);
		}
	}
}
