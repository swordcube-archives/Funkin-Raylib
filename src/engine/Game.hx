package engine;

import sys.thread.Thread;
import engine.tweens.Tween;
import engine.gui.VolumeTray;
import engine.sound.SoundManager;
import engine.keyboard.KeyboardManager;
import engine.keyboard.Keys;
import engine.Scene;
import engine.utilities.AssetCache;
import engine.utilities.Colors;
import engine.utilities.Color;
import engine.math.Random;
import engine.math.MathUtil;
import engine.managers.*;

#if !macro
import Rl.Texture2D;
import Rl.Font;
import Rl.RenderTexture2D;
#end

enum abstract ScaleMode(Int) to Int from Int {
	/**
	 * Maintains the game's scene at a fixed size. 
	 * This will clip off the edges of the scene for dimensions which are too small, 
	 * and leave black margins on the sides for dimensions which are too large.
	 */
	var FIXED = 0;

	/**
	 * Stretches and squashes the game to exactly fit the provided window. 
	 * This may result in the graphics of your game being distorted if the user resizes their game window.
	 */
	var FILL = 1;
}

class Game {
	public static var scaleMode:ScaleMode = FIXED;
	public static var assetCache:AssetCache;

	/**
	 * Used to generate random numbers.
	 */
	public static var random:Random;

	/**
	 * Used to manage cameras. To have multiple cameras in one scene,
	 * Do this:
	 * ```haxe
	 * Game.cameras.add(camera);
	 * ```
	 * 
	 * To let the game know that the camera should be rendered.
	 */
	public static var cameras:CameraManager;

	public static var keys:KeyboardManager;
	public static var sound:SoundManager;

	public static var timers:TimerManager;
	public static var signals:SignalManager;

	public static var scene:Scene;
	public static var width:Int = 0;
	public static var height:Int = 0;

	public static var framerate:Int = 60;
	public static var locusLostFramerate:Int = 10;
	public static var timeScale:Float = 1;

	public static var volumeTray:VolumeTray;

	public static var nextScene:Scene;
	public static var initialScene:Class<Scene>;

	public static var autoPause:Bool = true;
	public static var focusLostScreen:Bool = false;

	public static var camera:Camera;

	public static var elapsed(get, never):Float;
	private static inline function get_elapsed():Float {
		#if !macro
		var elapsedTime:Float = Rl.getFrameTime();
		if(elapsedTime > maxElapsed)
			elapsedTime = maxElapsed;

		return elapsedTime;
		#else
		return 0;
		#end
	}

	#if !macro
	/**
	 * The maximum amount that `elapsed` can be during update functions.
	 */
	public static var maxElapsed:Float = 0.1;

	/**
	 * Switches to a instance of a new scene.
	 * @param toScene The scene to switch to.
	 */
	public static function switchScene(toScene:Scene) {
		nextScene = toScene;
		__switchToNextScene();
	}

	private static function __switchToNextScene() {
		signals.preSceneCreate.dispatch();

		if(scene != null)
			scene.destroy();

		if(Game.camera != null)
			Game.camera.destroy();

		signals.sceneDestroy.dispatch();

		Game.camera = new Camera();
		Game.cameras.init();

		scene = nextScene;
		if(scene != null) scene.create();

		if(scene != null) scene.createPost();
		signals.postSceneCreate.dispatch();
	}

	public function new(title:String, width:Int = 1280, height:Int = 720, framerate:Int = 60, initialScene:Class<Scene>, ?skipSplash:Bool = false) {
		Game.width = width;
		Game.height = height;
		Game.framerate = framerate;

		Rl.setTraceLogLevel(Rl.TraceLogLevel.WARNING);
		Rl.initWindow(width, height, title);
		Rl.setWindowState(Rl.ConfigFlags.WINDOW_RESIZABLE);
        Rl.setTargetFPS(framerate);
		Rl.initAudioDevice();
		Rl.setWindowIcon(Rl.loadImage(Paths.image("gameIcon")));
		Rl.setExitKey(Keys.NONE);

		Game.signals = new SignalManager();
		Tween.globalManager = new TweenManager();
		Game.keys = new KeyboardManager();
		Game.timers = new TimerManager();
		Game.sound = new SoundManager();
		Game.assetCache = new AssetCache();

		Game.camera = new Camera();
		Game.cameras = new CameraManager();
		Game.cameras.init();
		
		Game.random = new Random();
		Game.random.resetInitialSeed();

		Game.initialScene = initialScene;
		if (skipSplash)
			Game.switchScene(Type.createInstance(initialScene, []));
		else
			Game.switchScene(new engine.SplashScene());

		start();
	}

	public static function resetScene() {
		Game.switchScene(Type.createInstance(Type.getClass(scene), []));
	}

	public function start() {
		Game.volumeTray = new VolumeTray();

		var fpsFont:Font = Rl.loadFont(Paths.font("vcr.ttf"));
		var renderTex:RenderTexture2D = Rl.loadRenderTexture(Game.width, Game.height);
		var clearColor:Color = Colors.BLACK;

		while (!Rl.windowShouldClose()) {
			// NOTE TO SELF: render textures are stupid
			// and have to be casted to be used
			// otherwise c++ compiler errors happen :3
			var bullShit = cast(renderTex.texture, Texture2D);

			Rl.beginDrawing();

			switch(Game.scaleMode) {
				case FILL:
					bullShit.width = Rl.getScreenWidth();
					bullShit.height = Rl.getScreenHeight();

				default:
					bullShit.width = Game.width;
					bullShit.height = Game.height;
			}

			// TODO: fix transparent sprites being tinted to
			// the color of clear background shit

			Rl.beginTextureMode(renderTex);
			Rl.clearBackground(Colors.BLACK);

			if(!(!Rl.isWindowFocused() && autoPause)) {
				Rl.setTargetFPS(framerate);

				// Rendering things from the current scene
				var elapsedTime:Float = Rl.getFrameTime() * Game.timeScale;
				if(elapsedTime > maxElapsed)
					elapsedTime = maxElapsed;

				if(Game.scene != null) {
					Game.signals.preSceneUpdate.dispatch(elapsedTime);
					Game.scene.tryUpdate(elapsedTime);
					Game.signals.postSceneUpdate.dispatch(elapsedTime);

					Game.signals.preSceneDraw.dispatch();
					Game.scene.draw();
					Game.signals.postSceneDraw.dispatch();
				}

				// Draw contents of all visible cameras
				if(Game.camera != null)
					Game.camera.draw();

				for(camera in Game.cameras.list)
					camera.draw();

				// Rendering volume tray
				for(object in [volumeTray, Tween.globalManager]) {
					if(!object.alive) continue;
					
					object.update(elapsedTime);
					object.draw();
				}
			} else {
				Rl.setTargetFPS(locusLostFramerate);

				if(focusLostScreen) {
					var text:String = "Game is currently unfocused";
					var fontSize:Int = 24;

					var textShit = Rl.measureTextEx(fpsFont, text, fontSize, 0);
					Rl.drawTextEx(fpsFont, text, Rl.Vector2.create((Game.width - textShit.x) * 0.5, (Game.height - textShit.y) * 0.5), fontSize, 0, Colors.WHITE);
				} else {
					if(Game.scene != null)
						Game.scene.draw();

					// Draw contents of all visible cameras
					if(Game.camera != null)
						Game.camera.draw();

					for(camera in Game.cameras.list)
						camera.draw();
				}
			}

			Rl.endTextureMode();

			var destRect = MathUtil.letterBoxRectangle( 
				Rl.Vector2.create(bullShit.width, bullShit.height),
				Rl.Rectangle.create(0.0, 0.0, Rl.getScreenWidth(), Rl.getScreenHeight())
			);

			// Draw black bars on the window based on scale mode
			switch(Game.scaleMode) {
				case FIXED:
					// left and right
					if(destRect.x > 0) {
						Rl.drawRectangle(
							0,
							0,
							Std.int(destRect.x) + 1,
							Rl.getScreenHeight(),
							clearColor
						);
			
						Rl.drawRectangle(
							Std.int(destRect.x + destRect.width),
							0,
							Std.int(destRect.x),
							Rl.getScreenHeight(),
							clearColor
						);
					}

					// top and bottom
					if(destRect.y > 0) {
						Rl.drawRectangle(
							0,
							0,
							Rl.getScreenWidth(),
							Std.int(destRect.y) + 1,
							clearColor
						);
			
						Rl.drawRectangle(
							0,
							Std.int(destRect.y + destRect.height),
							Rl.getScreenWidth(),
							Std.int(destRect.y),
							clearColor
						);
					}

				default: // nah
			}

			Rl.drawTexturePro(
				bullShit,
				Rl.Rectangle.create(
					0.0,
					bullShit.height,
					bullShit.width,
					-bullShit.height
				),
				destRect,
				Rl.Vector2.zero(),
				0.0,
				Colors.WHITE
			);

			// Rendering FPS counter
			Rl.drawTextEx(fpsFont, Rl.getFPS()+" FPS", Rl.Vector2.create(10, 3), 16, 0, Rl.Colors.WHITE);

			Rl.endDrawing();
		}

		Rl.closeAudioDevice();
		Rl.closeWindow();
	}
	#end
}
