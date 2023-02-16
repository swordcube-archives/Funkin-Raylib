package engine.sound;

#if !macro
class SoundManager {
    public var volume(default, set):Float = 1;
    private function set_volume(v:Float) {
        Rl.setMasterVolume(v);
        return volume = v;
    }
    
    public var list:Array<Audio> = [];
    
    public function new() {
        Game.signals.preSceneCreate.add(() -> {
            trace("[ENGINE] Clearing sounds...");
            for(sound in list) {
                sound.kill();
                sound.stop();
                sound.destroy();
            }
            list = [];
        });

        Game.signals.preSceneUpdate.add(update);
    }

    public function update(elapsed:Float) {
        for(sound in list)
            sound.update(elapsed);
    }

    public function play(path:String, ?volume:Float) {
        list.push(new Audio(path, volume).play());
    }
}
#end