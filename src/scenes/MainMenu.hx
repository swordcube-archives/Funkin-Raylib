package scenes;

class MainMenu extends Scene {
    override function create() {
        super.create();

        if(Game.sound.music == null || !Game.sound.music.playing)
            Game.sound.playMusic(Paths.music("freakyMenu"), 1);

        var bg:Sprite = new Sprite().loadGraphic(Paths.image("menus/menuBG"));
        add(bg);
    }
}