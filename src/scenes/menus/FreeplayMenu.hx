package scenes.menus;

import scenes.MusicBeat.MusicBeatScene;

class FreeplayMenu extends MusicBeatScene {
    public var bg:Sprite;

    override function create() {
        super.create();

        if(Game.sound.music == null || !Game.sound.music.playing)
            Game.sound.playMusic(Paths.music("freakyMenu"), 1);

        add(bg = new Sprite().loadGraphic(Paths.image("menus/menuBGDesat")));
        bg.screenCenter();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(controls.BACK)
            Game.switchScene(new MainMenu());
    }
}