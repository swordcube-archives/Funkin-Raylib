package;

import engine.keyboard.Keyboard;
import Rl.Rectangle;
import engine.Sprite;
import engine.Scene;
import Rl.Vector2;
import Rl.Colors;

class Game {
	public static var keys:Keyboard;

	public static var currentScene:Scene;
	public static var width:Int = 0;
	public static var height:Int = 0;

	public function switchScene(toScene:Scene) {
		currentScene = toScene;
	}

	public function new(title:String, width:Int = 1280, height:Int = 720, fps:Int = 60) {
		Game.width = width;
		Game.height = height;
		Game.keys = new Keyboard();

		Rl.initWindow(width, height, title);
		Rl.setWindowState(4);
        Rl.setTargetFPS(fps);
	}

	public function start() {
		while (!Rl.windowShouldClose()) {
			Rl.beginDrawing();
			Rl.clearBackground(Colors.BLACK);

			// Rendering things from the current scene
			if(Game.currentScene != null) {
				Game.currentScene.update(Rl.getFrameTime());
				Game.currentScene.draw();
			}

			Rl.endDrawing();
		}

		Rl.closeWindow();
	}
}
