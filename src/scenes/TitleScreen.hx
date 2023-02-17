package scenes;

import engine.utilities.Atlas;
import haxe.xml.Access;
import sys.io.File;
import Rl.Texture2D;
import Rl.Colors;
import engine.utilities.Timer;
import helpers.Paths;
import engine.keyboard.Keys;
import engine.Sprite;
import engine.Scene;

class TitleScreen extends Scene {
	var logo:Sprite;

	var fart:Texture2D;

	var frames:Array<Dynamic> = [];
	var frame:Int = 0;

	var animations:Map<String, Array<Dynamic>> = [];
	var animation:String = "bump";

    var timer:Float = 0.0;

	override function create() {
		super.create();

		if (Game.sound.music == null || !Game.sound.music.playing)
			Game.sound.playMusic(Paths.music("freakyMenu"), 1, true);

		logo = new Sprite(-150, -100);
        logo.frames = Paths.getSparrowAtlas("menus/title/logoBumpin");

		var xmlData = new Access(Xml.parse(File.getContent(Paths.asset("images/menus/title/logoBumpin.xml")).trim()).firstElement());

		for (frame in xmlData.nodes.SubTexture) {
            frames.push({
                name: frame.att.name,
                x: Std.parseInt(frame.att.x),
                y: Std.parseInt(frame.att.y),
                width: Std.parseInt(frame.att.width),
                height: Std.parseInt(frame.att.height),
                frameX: frame.has.frameX ? Std.parseInt(frame.att.frameX) : 0,
                frameY: frame.has.frameY ? Std.parseInt(frame.att.frameY) : 0,
            });
		}

        var bumpAnimation:Array<Dynamic> = [];

        for (key in frames) {
            bumpAnimation.push(key);
        }

        animations.set("bump", bumpAnimation);
        fart = Rl.loadTexture(Paths.image("menus/title/logoBumpin"));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Game.keys.justPressed(Keys.ENTER) || Game.keys.justPressed(Keys.SPACE)) {
			Game.switchScene(new MainMenu());
		}

        if (timer >= 1.0 / 24.0) {
            timer = 0;
            frame = (frame + 1) % animations.get(animation).length;
        } else
            timer += elapsed;
	}

    override function draw() {
        super.draw();

        var frameData:Dynamic = animations.get(animation)[frame];
		Rl.drawTexturePro(fart, Rl.Rectangle.create(frameData.x, frameData.y, frameData.width, frameData.height), Rl.Rectangle.create(-frameData.frameX, -frameData.frameY, frameData.width, frameData.height), Rl.Vector2.create(0, 0), 0, Colors.WHITE);
    }
}
