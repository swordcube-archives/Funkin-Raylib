package;

class Init extends Scene {
    public static var controls:Controls;
    
    override function create() {
        super.create();
        controls = new Controls();
        Conductor.init();

        Game.switchScene(new scenes.menus.TitleScreen());
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}