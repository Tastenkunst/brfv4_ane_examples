package brfv4.as3 {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	/**
	 * A prerendered stats class (removes Textfield rendering for every frame, needed on mobile to get more FPS ;) ).
	 */
	public class BitmapDataStats extends Bitmap {	

		public const WIDTH : uint = 58;
		public const HEIGHT : uint = 14;
		
		public var _bmd : BitmapData;
		public var _cache : Vector.<BitmapData>;
		
		public var _time : int;
		public var _lastTime : int;
		public var _fps : int;

		public function BitmapDataStats() : void {
			_bmd = new BitmapData(WIDTH, HEIGHT, false, 0x000033);
			super(_bmd, PixelSnapping.NEVER, true);
			
			_cache = new Vector.<BitmapData>(120, true);
			
			_time = 0;
			_lastTime = 0;
			_fps = 0;
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);	
		}

		private function cache(frameRate : int) : void {
			var i : int = 0;
			var l : int = _cache.length;
			
			var text : TextField;
			var style : StyleSheet;
			
			style = new StyleSheet();
			style.setStyle('xml', {fontSize:'9px', fontFamily:'_sans', leading:'-2px'});
			style.setStyle('fps', {color: "#00a0ff"});
			
			text = new TextField();
			text.width = WIDTH + 12;
			text.height = 50;
			text.styleSheet = style;
			text.condenseWhite = true;
			text.selectable = false;
			text.mouseEnabled = false;
			
			while(i < l) {
				var str : String = "FPS: " + i + " / " + frameRate; 
				text.htmlText = <xml><fps>{str}</fps></xml>;
				
				var cachedBmd : BitmapData = _bmd.clone();
				cachedBmd.draw(text);
				_cache[i] = cachedBmd;
				
				++i;
			}
		}
		
		private function init(event : Event) : void {
			cache(stage.frameRate);
			
			addEventListener(Event.ENTER_FRAME, update);
		}

		private function destroy(event : Event) : void {
			removeEventListener(Event.ENTER_FRAME, update);			
		}

		private function update(event : Event) : void {
			_time = getTimer();
			
			if(_time > _lastTime + 1000) {
				_lastTime = _time;
				
				var bmd : BitmapData = _cache[0];
				
				if(_fps < _cache.length) {
					bmd = _cache[_fps]; 
				}
				
				if(this.bitmapData != bmd) {
					this.bitmapData = bmd;
				}
				
				_fps = 0;				
			} else {
				_fps++;
			}
		}
	}
}
