package scenes;

import Rl.Colors;
import engine.utilities.Timer;
import helpers.Paths;
import engine.keyboard.Keys;
import engine.Sprite;
import engine.Scene;

class TitleScreen extends Scene {
    var logo:Sprite;

    override function create() {
        super.create();

        if(Game.sound.music == null || !Game.sound.music.playing)
            Game.sound.playMusic(Paths.music("freakyMenu"), 1, true);

        add(logo = new Sprite(-150, -100).loadGraphic(Paths.image("menus/title/logoBumpin")));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Game.keys.justPressed(Keys.ENTER) || Game.keys.justPressed(Keys.SPACE)) {
            Game.switchScene(new MainMenu());
        }
    }
}