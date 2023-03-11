package engine.managers;

class TimerManager {
    public static var timers:Array<Timer> = [];

    public function new() {
        Game.signals.preSceneUpdate.add((elapsed:Float) -> {
            for(timer in timers)
                timer.update(elapsed);
        });

        Game.signals.preSceneCreate.add(() -> {
            Logs.trace("Clearing timers...", ENGINE);
            for(timer in timers) {
                timer.kill();
                timer.stop();
                timer.destroy();
            }
            timers = [];
        });
    }

    public function add(timer:Timer) {
        timers.push(timer);
        return timer;
    }

    public function remove(timer:Timer) {
        timers.remove(timer);
        return timer;
    }
}