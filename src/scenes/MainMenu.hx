package scenes;

import Rl.Color;
import Rl.Colors;

class MainMenu extends Scene {
    public var bg:Sprite;

    override function create() {
        super.create();

        if(Game.sound.music == null || !Game.sound.music.playing)
            Game.sound.playMusic(Paths.music("freakyMenu"), 1);

        add(bg = new Sprite().loadGraphic(Paths.image("menus/menuBG")));
        bg.scale.set(1.2, 1.2);
        bg.updateHitbox();
        bg.screenCenter();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}