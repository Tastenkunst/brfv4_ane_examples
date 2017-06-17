package brfv4.examples {
	import flash.display.Sprite;
	import brfv4.BRFManager;
	import brfv4.as3.DrawingUtils;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	/**
	 * @author marcelklammer
	 */
	public class BRFBasicAS3Example extends Sprite {
		
		public var appId		: String;
		public var drawSprite	: Sprite;
		public var drawing		: DrawingUtils;
		public var brfManager	: BRFManager;

		public function BRFBasicAS3Example() {
			
			appId		= "com.tastenkunst.brfv4.as3.examples"; // Choose your own app id. 8 chars minimum.
			drawSprite	= new Sprite();
			drawing		= new DrawingUtils(drawSprite);
			brfManager	= new BRFManager();
			
			addChild(drawSprite);
			
			this.graphics.beginFill(0xffffff, 0.01);
			this.graphics.drawRect(0, 0, 1920, 1080);
			this.graphics.endFill();
			this.mouseChildren = true;
			this.mouseEnabled = true;
		}
		
		public function initCurrentExample(brfManager : BRFManager, resolution : Rectangle) : void {}
		public function updateCurrentExample(brfManager : BRFManager, imageData : BitmapData, _drawing : DrawingUtils) : void {}
	}
}