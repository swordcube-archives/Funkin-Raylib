package;

import engine.ui.VolumeTray;
import engine.utilities.TimerManager;
import engine.utilities.SignalManager;
import engine.sound.SoundManager;
import engine.keyboard.KeyboardManager;
import engine.Scene;
import Rl.Colors;

class Game {
	public static var keys:KeyboardManager;
	public static var sound:SoundManager;
	public static var signals:SignalManager;

	public static var timers:TimerManager;

	public static var currentScene:Scene;
	public static var width:Int = 0;
	public static var height:Int = 0;

	public static var volumeTray:VolumeTray;

	public static function switchScene(toScene:Scene) {
		signals.preSceneCreate.dispatch();

		if(currentScene != null)
			currentScene.destroy();

		signals.sceneDestroy.dispatch();

		currentScene = toScene;

		signals.postSceneCreate.dispatch();
	}

	public function new(title:String, width:Int = 1280, height:Int = 720, fps:Int = 60) {
		Game.width = width;
		Game.height = height;

		Game.signals = new SignalManager();
		Game.keys = new KeyboardManager();
		Game.sound = new SoundManager();
		Game.timers = new TimerManager();

		Rl.initWindow(width, height, title);
		Rl.setWindowState(4);
        Rl.setTargetFPS(fps);
		Rl.initAudioDevice();
		Rl.setWindowIcon(Rl.loadImage(Paths.image("gameIcon")));
	}

	public function start() {
		Game.volumeTray = new VolumeTray();

		var fpsFont = Rl.loadFont(Paths.font("vcr.ttf"));

		while (!Rl.windowShouldClose()) {
			Rl.beginDrawing();
			Rl.clearBackground(Colors.BLACK);

			// Rendering things from the current scene
			var elapsedTime:Float = Rl.getFrameTime();

			if(Game.currentScene != null) {
				Game.signals.preSceneUpdate.dispatch(elapsedTime);
				Game.currentScene.update(elapsedTime);
				Game.signals.postSceneUpdate.dispatch(elapsedTime);

				Game.signals.preSceneDraw.dispatch();
				Game.currentScene.draw();
				Game.signals.postSceneDraw.dispatch();
			}

			// Rendering volume tray
			for(object in [volumeTray]) {
				if(!object.alive) continue;
				
				object.update(elapsedTime);
				object.draw();
			}

			// Rendering FPS counter
			Rl.drawTextEx(fpsFont, Rl.getFPS()+" FPS", Rl.Vector2.create(10, 3), 16, 0, Rl.Colors.WHITE);

			Rl.endDrawing();
		}

		Rl.closeAudioDevice();
		Rl.closeWindow();
	}
}
