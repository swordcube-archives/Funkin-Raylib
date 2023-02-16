package scenes;

class MainMenu extends Scene {
    override function create() {
        super.create();

        var bg:Sprite = new Sprite().loadGraphic(Paths.image("menus/menuBG"));
        add(bg);
    }
}