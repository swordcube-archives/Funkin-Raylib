package engine;

import engine.utilities.Transition.ITransition;
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

	public static var scene:Scene;
	public static var width:Int = 0;
	public static var height:Int = 0;

	public static var volumeTray:VolumeTray;

	public static var nextScene:Scene;
	public static var initialScene:Class<Scene>;

	public static function switchScene(toScene:Scene, ?force:Bool = false) {
		nextScene = toScene;

		if(scene != null && scene.transIn != null && !force) {
			if(scene != null && !(scene.subScene is ITransition))
				scene.openSubScene(scene.transIn);
		}
		else {
			signals.preSceneCreate.dispatch();

			if(scene != null)
				scene.destroy();
	
			signals.sceneDestroy.dispatch();

			scene = nextScene;
			if(scene != null)
				scene.create();

			signals.postSceneCreate.dispatch();
		}
	}

	public function new(title:String, width:Int = 1280, height:Int = 720, fps:Int = 60, initialScene:Class<Scene>) {
		Game.width = width;
		Game.height = height;

		Rl.initWindow(width, height, title);
		Rl.setWindowState(4);
        Rl.setTargetFPS(fps);
		Rl.initAudioDevice();
		Rl.setWindowIcon(Rl.loadImage(Paths.image("gameIcon")));

		Game.signals = new SignalManager();
		Game.keys = new KeyboardManager();
		Game.timers = new TimerManager();
		Game.sound = new SoundManager();

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

			// Rendering things from the current scene
			var elapsedTime:Float = Rl.getFrameTime();

			if(Game.scene != null) {
				var updateAllowed:Bool = (Game.scene != null && (Game.scene.persistentUpdate || Game.scene.subScene == null));
				var drawAllowed:Bool = (Game.scene != null && (Game.scene.persistentDraw || Game.scene.subScene == null));

				if(updateAllowed) Game.signals.preSceneUpdate.dispatch(elapsedTime);
				Game.scene.update(elapsedTime);
				if(updateAllowed) Game.signals.postSceneUpdate.dispatch(elapsedTime);

				if(drawAllowed) Game.signals.preSceneDraw.dispatch();
				Game.scene.draw();
				if(drawAllowed) Game.signals.postSceneDraw.dispatch();
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
