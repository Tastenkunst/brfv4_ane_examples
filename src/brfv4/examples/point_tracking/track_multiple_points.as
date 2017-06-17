package brfv4.examples.point_tracking {
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;
	import brfv4.examples.BRFBasicAS3Example;

	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class track_multiple_points extends BRFBasicAS3Example {
		
		private var _pointsToAdd : Vector.<Point>	= new Vector.<Point>();
		private var _numTrackedPoints : int			= 0;
	
		override public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {
	
			trace("BRFv4 - basic - point tracking.\n" +
				"Click eg. on your face to add a bunch of points to track.");
		
			brfManager.init(resolution, resolution, appId);
	
			// BRFMode.POINT_TRACKING skips the face detection/tracking entirely.
			// You can do point tracking and face detection/tracking simultaneously
			// by settings BRFMode.FACE_TRACKING or BRFMode.FACE_DETECTION.
	
			brfManager.setMode(brfv4.BRFMode.POINT_TRACKING);
	
			// Default settings: a patch size of 21 (needs to be odd), 4 pyramid levels,
			// 50 iterations and a small error of 0.0006
	
			brfManager.setOpticalFlowParams(21, 4, 50, 0.0006);
	
			// true means:  BRF will remove points if they are not valid anymore.
			// false means: developers handle point removal on their own.
	
			brfManager.setOpticalFlowCheckPointsValidBeforeTracking(true);

			this.addEventListener(MouseEvent.CLICK, onClicked);
		};
	
		override public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, draw : DrawingUtils) : void {
	
			// We add the _pointsToAdd right before an update.
			// If you do that onclick, the tracking might not
			// handle the new points correctly.
	
			if(_pointsToAdd.length > 0) {
				brfManager.addOpticalFlowPoints(_pointsToAdd);
				_pointsToAdd.length = 0;
			}
	
			brfManager.update(imageData);
	
			draw.clear();
	
			var points : Vector.<Point> = brfManager.getOpticalFlowPoints();
			var states : Vector.<Boolean> = brfManager.getOpticalFlowPointStates();
	
			// Draw points by state: green valid, red invalid
	
			for(var i : int = 0, l : int = points.length; i < l; i++) {
				if(states[i]) {
					draw.drawPoint(points[i], 2, false, 0x00ff00, 1.0);
				} else {
					draw.drawPoint(points[i], 2, false, 0xff0000, 1.0);
				}
			}
	
			// ... or just draw all points that got tracked.
			//draw.drawPoints(points, 2, false, 0x00ff00, 1.0);
	
			if(points.length != _numTrackedPoints) {
				_numTrackedPoints = points.length;
				trace("BRFv4 - Basic - Point Tracking\n" +
					"Tracking " + _numTrackedPoints + " points.");
			}
		}
		
		
	
		private function onClicked(event : MouseEvent) : void {
	
			var x : Number = event.localX;
			var y : Number = event.localY;
	
			// Add 1 point:
	
			// _pointsToAdd.push(new brfv4.Point(x, y));
	
			//Add 100 points
	
			var w : Number = 60.0;
			var step : Number = 6.0;
			var xStart : Number = x - w * 0.5;
			var xEnd : Number = x + w * 0.5;
			var yStart : Number = y - w * 0.5;
			var yEnd : Number = y + w * 0.5;
			var dy : Number = yStart;
			var dx : Number = xStart;
	
			for(; dy < yEnd; dy += step) {
				for(dx = xStart; dx < xEnd; dx += step) {
					_pointsToAdd.push(new Point(dx, dy));
				}
			}
		}
	}
}