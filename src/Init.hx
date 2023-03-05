package;

class Init extends Scene {
    override function create() {
        super.create();
        Conductor.init();
        Rl.setTraceLogLevel(Rl.TraceLogLevel.WARNING); //I'm sorry but I don't want to see million tracews just because i loaded something.
        Game.switchScene(new scenes.menus.TitleScreen());
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}