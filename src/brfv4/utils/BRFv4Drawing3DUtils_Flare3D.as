package brfv4.utils {
	import brfv4.BRFFace;

	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Light3D;
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.LightFilter;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	import flare.utils.Matrix3DUtils;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * @author marcelklammer
	 */
	public class BRFv4Drawing3DUtils_Flare3D extends Sprite {
		
		private var scene : Scene3D;
		private var camera : Camera3D;
		
		private var baseNodes : Vector.<Pivot3D>;
		private var occlusionNodes : Vector.<Pivot3D>;
		private var modelZ : int;
		private var planeZ : int;
		
		private var renderWidth : int;
		private var renderHeight : int;
		
		private var videoPlaneTexture : Texture3D;
		private var videoPlaneMaterial : Shader3D;
		private var videoPlane : Plane;
		private var light : Light3D;

		public function BRFv4Drawing3DUtils_Flare3D(resolution : Rectangle) {
			
			scene = new Scene3D(this);
			scene.antialias = 2;
			scene.allowImportSettings = false;
			
			camera = new Camera3D();
			camera.orthographic = true;
			
			baseNodes = new Vector.<Pivot3D>();
			occlusionNodes = new Vector.<Pivot3D>();
			modelZ = 2000;
			planeZ = 4000;
			
			scene.lights.maxDirectionalLights = 1;
			scene.lights.maxPointLights = 1;
			scene.lights.techniqueName = LightFilter.PER_VERTEX;
			scene.lights.defaultLight.color.setTo(0.25, 0.25, 0.25);
			
			light = new Light3D("scene_light", Light3D.POINT);
			light.setPosition(150, 150, 0);
			light.infinite = true;
			light.color.setTo(255 / 255, 253 / 255, 244 / 255);
			light.multiplier = 1.0;
			
			scene.addChild(light);
			
			updateLayout(resolution.width, resolution.height);
		}
		
		public function updateLayout(width : int, height : int) : void {
	
			renderWidth 	= width;
			renderHeight 	= height;
	
			scene.setViewport(0, 0, width, height, 2);
			
			camera.projection = Matrix3DUtils.buildOrthoProjection(
				-width * 0.5, 
				 width * 0.5,
				-height * 0.5,
				 height * 0.5, 
				 0, 10000
			);
			camera.setPosition(0, 0, 0);
			camera.lookAt(0, 0, 1);
			camera.near = 10;
			camera.far = 5000;
			
			scene.camera = camera;
		}
		
		public function update(index : int, face : BRFFace, show : Boolean) : void {
				
			if(index >= baseNodes.length || !face) {
				return;
			}
	
			var baseNode : Pivot3D = baseNodes[index];
			var occlusionNode : Pivot3D = occlusionNodes[index];
			
			if(!baseNode) return;
	
			if (show) {
				
				var s : Number =  (face.scale / 180);
				var x : Number =  (face.translationX - (renderWidth  * 0.5));
				var y : Number = -(face.translationY - (renderHeight * 0.5));
				var z : Number =  modelZ;
	
				var rx : Number = BRFv4PointUtils.toDegree(-face.rotationX);
				var ry : Number = BRFv4PointUtils.toDegree( face.rotationY);
				var rz : Number = BRFv4PointUtils.toDegree(-face.rotationZ);
				
				// Some fiddling around with the angles to get a better rotated 3d model.
				if(rx > 0) {
					rx = rx * 1.35 + 5;
					rz = rz / 2.00;	
				} else {
					var ryp : Number = Math.abs(ry) / 40.0;
					rx = rx * (1.0 - ryp * 1.0) + 5;
				}
				
				baseNode.transform.identity();
				baseNode.setPosition(x, y, z);
				baseNode.setScale(s, s, s);
				baseNode.setRotation(rx, ry, rz);
				
				setVisible(baseNode, true);
					
				if(occlusionNode != null) {
					occlusionNode.setPosition(x, y, z);
					occlusionNode.setScale(s, s, s);
					occlusionNode.setRotation(rx, ry, rz);
				}
	
			} else {
				setVisible(baseNode, false); // Hide the 3d object, if no face was tracked.
			}
		}
		
		public function render() : void {
			scene.render();
		}
		
		public function hideAll() : void {
			for(var k : int = 0; k < baseNodes.length; k++) {
				var baseNode : Pivot3D = baseNodes[k];
				setVisible(baseNode, true);
			}
			render();
		}
		
		public function removeAll() : void {
			for(var k : int = 0; k < baseNodes.length; k++) {
				var baseNode : Pivot3D = baseNodes[k];
				for(var j : int = baseNode.children.length - 1; j >= 0; j--) {
					baseNode.removeChild(baseNode.children[j]);
				}
			}
			render();
		}
		
		public function loadOcclusionHead(url : String, maxFaces : int) : void {

			var containers : Vector.<Pivot3D> = occlusionNodes;
			
			addBaseNodes(maxFaces, containers, "occlusionNode");
			
			var i : int;
			var group : Pivot3D;
	
			for(i = 0; i < containers.length; i++) {
				
				var holder : Pivot3D = getHolder();
				
				group = containers[i];
				group.addChild(holder);
				
				scene.addChildFromFile(url, holder);
				group.parent = null;
			}
			
			scene.addEventListener(Scene3D.RENDER_EVENT, onRender);
		}
		
		public function loadModel(url : String, maxFaces : int) : void {
			
			var containers : Vector.<Pivot3D> = baseNodes;
			
			addBaseNodes(maxFaces, containers, "baseNode");
			
			var i : int;
			var group : Pivot3D;
	
			for(i = 0; i < containers.length; i++) {
				
				var holder : Pivot3D = getHolder();
				
				group = containers[i];
				group.addChild(holder);

				scene.addChildFromFile(url, holder);
			}
		}

		private function getHolder() : Pivot3D {
			var p : Pivot3D = new Pivot3D();
		
			p.setPosition(0, -10, -5);
			p.setScale(1.9, 1.9, 1.9);
		
			return p;
		}
		
		private function setVisible(baseNode : Pivot3D, show : Boolean) : void {
			for(var j : int = baseNode.children.length - 1; j >= 0; j--) {
				baseNode.children[j].visible = show;
			}
			baseNode.visible = show;
		}
			
		private function addBaseNodes(maxFaces : int, containers : Vector.<Pivot3D>, namePrefix : String) : void {
	
			var i : int;
			var group : Pivot3D;
	
			for(i = containers.length; i < maxFaces; i++) {
				group = new Pivot3D(namePrefix+""+i);
				group.visible = false;
				containers.push(group);
				scene.addChild(group);
			}
	
			for(i = containers.length - 1; i > maxFaces; i--) {
				group = containers[i];
				scene.removeChild(group);
			}
		}
		
		//Stage3D is not transparent. We need to create a video plane and map the video bitmapdata to it.
		public function initVideoPlane(bitmapData : BitmapData) : void {
			
			videoPlaneTexture = new Texture3D(bitmapData, false);
			videoPlaneTexture.mipMode = Texture3D.MIP_NONE;
			videoPlaneTexture.loaded = true;
			videoPlaneTexture.upload(scene);
			
			videoPlaneMaterial = new Shader3D("_videoPlaneMaterial", [new TextureMapFilter(videoPlaneTexture)], false);
			videoPlaneMaterial.twoSided = true;
			videoPlaneMaterial.build();
			
			videoPlane = new Plane("_videoPlane", bitmapData.width, bitmapData.height, 10, videoPlaneMaterial, "+xy");
			videoPlane.setPosition(0, 0, planeZ);
				
			scene.addChild(videoPlane);
		}

		public function updateVideo(imageData : BitmapData) : void {
			
			if(videoPlaneTexture == null) {
				initVideoPlane(imageData);
			}
			
			if(videoPlaneTexture != null) {
				videoPlaneTexture.uploadTexture();
			}
		}
		
		//the occlusion magic goes here
		private function onRender(event : Event = null) : void {
			
			//first: draw the video plane in the background
			videoPlane.draw();
			
			//if there is an occlusion object, ...
			if(occlusionNodes.length > 0) {
					
					//... write it to the buffer, but hide all coming polys behind it
						
					scene.context.setColorMask(false, false, false, false);
						
					var containers : Vector.<Pivot3D> = occlusionNodes;
					
					var i : int;
					var group : Pivot3D;
			
					for(i = 0; i < containers.length; i++) {
						
						group = containers[i];
						group.draw();
					}
					
					scene.context.setColorMask(true, true, true, true);
			}
			
			//all objects, that where not drawn here, will be drawn by Flare3D automatically
		}
		

		// need a screenshot of the scene?
		public function getScreenshot() : BitmapData {
			
			var bmd : BitmapData = new BitmapData(scene.viewPort.width, scene.viewPort.height);
			
			scene.context.clear();
			
			onRender();
			
			scene.render();
			scene.context.drawToBitmapData(bmd);
			
			return bmd;
		}


//		
//		public function set model(model : String) : void {
//			_scene3D.pause();
//			if(_model != null) {				
//				_baseNode.removeChild(_holder);
//				_models[_model] = _holder;
//				_model = null;
//			}
//			_holder = null;
//			if(model != null) {
//				var holderOld : Pivot3D = _models[model];
//				
//				if(holderOld != null) {
//					_holder = holderOld;
//					_baseNode.addChild(_holder);
//					_scene3D.resume();
//				} else {
//					_holder = new Pivot3D(); 
//					_holder.name = "_holder_"+model;
//					_baseNode.addChild(_holder);
//					
//					_scene3D.addEventListener(Scene3D.COMPLETE_EVENT, onCompleteLoading);
//					_scene3D.addChildFromFile(model, _holder);
//				}
//			}			
//			_model = model;
//		}
//		
//		public function onCompleteLoading(e : Event) : void {
//			_scene3D.removeEventListener(Scene3D.COMPLETE_EVENT, onCompleteLoading);
//			_scene3D.camera = _camera3D;
//			_scene3D.resume();
//		}		
//		// You have more GPU power to spent? Then let's hide the glasses bows behind a invisible head! 
//		// (or any other object behind any other invisible object)
//		public function initOcclusion(url : String) : void {
//			_scene3D.addEventListener(Scene3D.COMPLETE_EVENT, onCompleteOcclusion);
//			_scene3D.addChildFromFile(url, _occlusionNode);
//		}
//		// We extract the occlusion object and remove it from the scene
//		// the _scene3D gets a render event and handles drawing semi-automatically
//		public function onCompleteOcclusion(event : Event) : void {
//			_scene3D.removeEventListener(Scene3D.COMPLETE_EVENT, onCompleteOcclusion);
//			
//			_occlusion = _occlusionNode;
//			
//			if(_occlusion != null) {
//				_occlusion.parent = null;
//				_occlusion.upload(_scene3D);
//			}			
//			
//			_scene3D.addEventListener(Scene3D.RENDER_EVENT, onRender);
//			_scene3D.resume();
//		}
//		/** need a screenshot of the scene? */
//		public function getScreenshot() : BitmapData {
//			var bmd : BitmapData = new BitmapData(
//					_scene3D.viewPort.width, _scene3D.viewPort.height);
//			
//			_scene3D.context.clear();
//			
//			onRender();
//			
//			_scene3D.render();
//			_scene3D.context.drawToBitmapData(bmd);
//			
//			return bmd;
//		}
//		//the occlusion magic goes here
//		private function onRender(event : Event = null) : void {
//			//first: draw the video plane in the background
//			_videoPlane.draw();
//			//if there is an occlusion object, ...
//			if(_occlusion != null) {
//				//... write it to the buffer, but hide all coming polys behind it
//				_scene3D.context.setColorMask(false, false, false, false);
//				_occlusion.draw();
//				_scene3D.context.setColorMask(true, true, true, true);
//			}
//			//all objects, that where not drawn here, will be drawn by Flare3D automatically
//		}
//		//Stage3D is not transparent. We need to create a video plane and map the video bitmapdata to it.
//		public function initVideoPlane(bitmapData : BitmapData) : void {
//			_videoPlaneTexture = new Texture3D(bitmapData, true);
//			_videoPlaneTexture.mipMode = Texture3D.MIP_NONE;
//			_videoPlaneTexture.loaded = true;
//			_videoPlaneTexture.upload(_scene3D);
//			
//			_videoPlaneMaterial = new Shader3D("_videoPlaneMaterial", [new TextureMapFilter(_videoPlaneTexture)], false);
//			_videoPlaneMaterial.twoSided = true;
//			_videoPlaneMaterial.build();
//			
//			_videoPlane = new Plane("_videoPlane", 
//				_screenRect.width  * _planeFactor,
//				_screenRect.height * _planeFactor,
//				10, _videoPlaneMaterial, "+xy");
//			_scene3D.addChild(_videoPlane);
//
//			var x : Number = -((_scene3D.viewPort.width  - _screenRect.width)  * 0.5 - _screenRect.x) * _planeFactor;
//			var y : Number =  ((_scene3D.viewPort.height - _screenRect.height) * 0.5 - _screenRect.y) * _planeFactor;
//			var z : Number = _planeZ;
//
//			_videoPlane.setPosition(x, y, z);
//		}
	}
}