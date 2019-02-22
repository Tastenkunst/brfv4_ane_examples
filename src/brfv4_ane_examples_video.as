package {
	import brfv4.as3.VideoUtils;
	import brfv4.as3.BitmapDataStats;
	import brfv4.as3.CameraUtils;
	import brfv4.examples.BRFBasicAS3Example;
	import brfv4.examples.face_detection.*;
	import brfv4.examples.face_tracking.*;
	import brfv4.examples.point_tracking.*;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Capabilities;

	/**
	 * @author Marcel Klammer, Tastenkunst GmbH, 2017
	 */
	public class brfv4_ane_examples_video extends Sprite {
		
		public var _videoUtils : VideoUtils;
		public var _stats : BitmapDataStats;
		public var _example : BRFBasicAS3Example;
		
		public var _width : Number = 640;
		public var _height : Number = 480;
				
		public function brfv4_ane_examples_video() {
			
			if(stage == null) {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			} else {
				onAddedToStage();
			}
		}
		
		private function onAddedToStage(event : Event = null) : void {
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.MEDIUM;
			stage.frameRate = 30;
			
			init();
		}

		public function init() : void {
			_videoUtils = new VideoUtils();
			_videoUtils.addEventListener("ready", onVideoStreamReady);
			_videoUtils.init(_width, _height, "34.flv");
		}

		private function onVideoStreamReady(event : Event = null) : void {
			
			// Choose only one of the following examples:
			 
			// "+++ basic - face detection +++"
			
//			_example = new detect_in_whole_image();					// "basic - face detection - detect in whole image"
//			_example = new detect_in_center();						// "basic - face detection - detect in center"
//			_example = new detect_smaller_faces();					// "basic - face detection - detect smaller faces"
//			_example = new detect_larger_faces();					// "basic - face detection - detect larger faces"
//
			// "+++ basic - face tracking +++"
			
//			_example = new track_single_face();						// "basic - face tracking - track single face"
//			_example = new track_multiple_faces();					// "basic - face tracking - track multiple faces"
//			_example = new candide_overlay();						// "basic - face tracking - candide overlay"
			
			// "+++ basic - point tracking +++"

//			_example = new track_multiple_points();					// "basic - point tracking - track multiple points"
//			_example = new track_points_and_face();					// "basic - point tracking - track points and face"

			// "+++ intermediate - face tracking +++"

//			_example = new restrict_to_center();					// "intermediate - face tracking - restrict to center"
//			_example = new extended_face_shape();					// "intermediate - face tracking - extended face"
//			_example = new smile_detection();						// "intermediate - face tracking - smile detection"
//			_example = new yawn_detection();						// "intermediate - face tracking - yawn detection"
//			_example = new png_mask_overlay();						// "intermediate - face tracking - png/mask overlay"
//			_example = new color_libs();							// "intermediate - face tracking - color libs"

			// "+++ advanced - face tracking +++"
			
//			_example = new blink_detection();						// "advanced - face tracking - blink detection"
//			_example = new Flare3d_example();						// "advanced - face tracking - Flare3D example"
//			_example = new face_texture_overlay();					// "advanced - face tracking - face texture overlay"
//			_example = new face_swap_two_faces();					// "advanced - face tracking - face swap (two faces)"

			_example = new track_single_face_video();				// "basic - face tracking - track single face"

			_stats = new BitmapDataStats();
			
			if(!(_example is Flare3d_example)) {
				addChild(_videoUtils.video);	
			}
			addChild(_example);
			addChild(_stats);
						
			_example.initCurrentExample(_example.brfManager, _videoUtils.videoResolution);
			
			_videoUtils.play();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		public function onEnterFrame(event : Event = null) : void {
			
			_videoUtils.update();
			
			_example.updateCurrentExample(
				_example.brfManager, 
				_videoUtils.videoData, 
				_example.drawing
			);
		}
		
		public function onResize(event : Event = null) : void {
				
			var w : Number = _width;
			var h : Number = _height;
						
			scaleX = stage.stageWidth / w;
			scaleY = scaleX;
			y = (stage.stageHeight - (h * scaleY)) * 0.5;
		}
		
		// this just to keep the imports, no other meaning
		private static var ar : Array = [
			
			detect_in_whole_image,
			detect_in_center,
			detect_smaller_faces,
			detect_larger_faces,
			
			track_single_face,
			track_multiple_faces,
			candide_overlay,
			
			track_multiple_points,
			track_points_and_face,
			
			restrict_to_center,
			extended_face_shape,
			smile_detection,
			yawn_detection,
			png_mask_overlay,
			color_libs,
			
			blink_detection,
			Flare3d_example,
			face_texture_overlay,
			face_swap_two_faces
		]; ar;
	}
}