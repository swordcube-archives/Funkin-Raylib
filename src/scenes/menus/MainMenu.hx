package scenes.menus;

import engine.tweens.Tween;
import engine.tweens.Ease;
import scenes.MusicBeat.MusicBeatScene;
import engine.keyboard.Keys;

class MainMenu extends MusicBeatScene {
    public var bg:Sprite;

    override function create() {
        super.create();

        if(Game.sound.music == null || !Game.sound.music.playing)
            Game.sound.playMusic(Paths.music("freakyMenu"), 1);

        add(bg = new Sprite().loadGraphic(Paths.image("menus/menuBG")));
        bg.scale.set(1.2, 1.2);
        bg.updateHitbox();
        bg.screenCenter();

        // Tween.color(bg, 2, bg.color, Colors.RED, {ease: Ease.cubeOut});
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Game.keys.justPressed(Keys.ENTER)) {
            Game.switchScene(new PlayState());
        }
    }
}