package;

class Init extends Scene {
    override function create() {
        super.create();
        Conductor.init();

        Game.switchScene(new scenes.menus.TitleScreen());
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}