package brfv4.as3 {
	import flash.display.BitmapData;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.setTimeout;
	
	public class VideoUtils extends EventDispatcher {
		
		public var videoWidth : int;
		public var videoHeight : int;
		
		public var videoData : BitmapData;

		public var video : Video;
		
		public var videoResolution : Rectangle;
		public var videoMatrix : Matrix;
		
		public var videoURL : String = "video.flv";
		public var videoStreamConnection : NetConnection;
		public var videoStream : NetStream;
		
		public function VideoUtils() {
			
			videoResolution = new Rectangle();
			videoMatrix = new Matrix();
		}
		
		public function init(width : int = 640, height : int = 480, url : String = null) : Boolean {
					
			this.videoWidth = width;
			this.videoHeight = height;
			
			updateMatrix();
			
			if(url != null) {
				this.videoURL = url;
			}
			
			if(video != null) {
				if(video.parent != null) {
					video.parent.removeChild(video);	
				}
				video.attachCamera(null);
				video.attachNetStream(null);
				video = null;
			}
			
			if(videoData != null) {
				try {
					videoData.dispose();
					videoData = null;
				} catch(error : Error) {}
			}
			
			video = new Video(videoWidth, videoHeight);
			video.transform.matrix = videoMatrix;
			video.smoothing = true;

			videoStreamConnection = new NetConnection();
			videoStreamConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			videoStreamConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			videoStreamConnection.connect(null);
			
			videoData = new BitmapData(videoResolution.width, videoResolution.height, true, 0xff444444);
			
			return true;
		}

		private function onNetStatus(event : NetStatusEvent) : void {
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					connectStream();
					break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: " + videoURL);
                    break;
            }
		}

		private function onAsyncError(event : AsyncErrorEvent) : void {
			trace("onSecurityError: " + event);
		}

		private function onSecurityError(event : SecurityErrorEvent) : void {
			trace("onSecurityError: " + event);			
		}
		
		private function connectStream() : void {
			
			videoStream = new NetStream(videoStreamConnection);
			videoStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			videoStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			
			var client = {
				
				onMetaData: function(info : Object) : void {
				
					trace("metadata: duration=" + info.duration + " framerate=" + info.framerate);
				}
			};
			
			videoStream.client = client;

			video.attachNetStream(videoStream);
			
			dispatchEvent(new Event("ready"));
		}
		
		public function play() : void {
		    videoStream.play(videoURL);
		}
		
		public function update() : void {
			videoData.draw(video, videoMatrix);
		}
		
		public function updateMatrix() : void {
			
			var cw : Number = videoWidth;
			var ch : Number = videoHeight;
			
			videoMatrix.identity();
			
			videoMatrix.scale(1.2, 1.0);
			videoMatrix.translate(-64, 0);
			
			videoResolution.setTo(0, 0, cw, ch);
		}
	}
}
