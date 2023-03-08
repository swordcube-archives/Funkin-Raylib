package engine;

import Rl.Keys;
import engine.tweens.Tween;
import engine.gui.VolumeTray;
import engine.utilities.TimerManager;
import engine.utilities.SignalManager;
import engine.sound.SoundManager;
import engine.keyboard.KeyboardManager;
import engine.Scene;
import Rl.Colors;

class Game {
	public static var assetCache:AssetCache;

	public static var keys:KeyboardManager;
	public static var sound:SoundManager;
	public static var signals:SignalManager;

	public static var timers:TimerManager;

	public static var scene:Scene;
	public static var width:Int = 0;
	public static var height:Int = 0;

	public static var framerate:Int = 60;
	public static var locusLostFramerate:Int = 10;

	public static var volumeTray:VolumeTray;

	public static var nextScene:Scene;
	public static var initialScene:Class<Scene>;

	public static var autoPause:Bool = true;

	public static var elapsed(get, never):Float;
	private static inline function get_elapsed():Float {
		var elapsedTime:Float = Rl.getFrameTime();
		if(elapsedTime > maxElapsed)
			elapsedTime = maxElapsed;

		return elapsedTime;
	}

	public static var maxElapsed:Float = 0.1;

	public static function switchScene(toScene:Scene) {
		nextScene = toScene;
		__switchToNextScene();
	}

	private static function __switchToNextScene() {
		signals.preSceneCreate.dispatch();

		if(scene != null)
			scene.destroy();

		signals.sceneDestroy.dispatch();

		scene = nextScene;
		if(scene != null) scene.create();

		if(scene != null) scene.createPost();
		signals.postSceneCreate.dispatch();
	}

	public function new(title:String, width:Int = 1280, height:Int = 720, framerate:Int = 60, initialScene:Class<Scene>) {
		Game.width = width;
		Game.height = height;
		Game.framerate = framerate;

		Rl.setTraceLogLevel(Rl.TraceLogLevel.WARNING);
		Rl.initWindow(width, height, title);
		Rl.setWindowState(4);
        Rl.setTargetFPS(framerate);
		Rl.initAudioDevice();
		Rl.setWindowIcon(Rl.loadImage(Paths.image("gameIcon")));
		Rl.setExitKey(Keys.NULL);

		Game.signals = new SignalManager();
		Tween.globalManager = new TweenManager();
		Game.keys = new KeyboardManager();
		Game.timers = new TimerManager();
		Game.sound = new SoundManager();
		Game.assetCache = new AssetCache();

		Game.initialScene = initialScene;
		Game.switchScene(Type.createInstance(initialScene, []));

		start();
	}

	public function start() {
		Game.volumeTray = new VolumeTray();

		var fpsFont = Rl.loadFont(Paths.font("vcr.ttf"));

		while (!Rl.windowShouldClose()) {
			Rl.beginDrawing();
			Rl.clearBackground(Colors.BLACK);

			if(!(!Rl.isWindowFocused() && autoPause)) {
				Rl.setTargetFPS(framerate);

				// Rendering things from the current scene
				var elapsedTime:Float = Rl.getFrameTime();
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

				// Rendering volume tray
				for(object in [volumeTray, Tween.globalManager]) {
					if(!object.alive) continue;
					
					object.update(elapsedTime);
					object.draw();
				}
			} else {
				Rl.setTargetFPS(locusLostFramerate);

				var text:String = "Game is currently unfocused";
				var fontSize:Int = 24;

				var textShit = Rl.measureTextEx(fpsFont, text, fontSize, 0);
				Rl.drawTextEx(fpsFont, text, Rl.Vector2.create((Game.width - textShit.x) * 0.5, (Game.height - textShit.y) * 0.5), fontSize, 0, Colors.WHITE);
			}

			// Rendering FPS counter
			Rl.drawTextEx(fpsFont, Rl.getFPS()+" FPS", Rl.Vector2.create(10, 3), 16, 0, Rl.Colors.WHITE);

			Rl.endDrawing();
		}

		Rl.closeAudioDevice();
		Rl.closeWindow();
	}
}
