package engine.sound;

import engine.interfaces.ISound;
#if !macro
class SoundManager {
    public var music:MusicEx;

    public var volume(default, set):Float = 1;
    private function set_volume(v:Float) {
        Rl.setMasterVolume(v);
        return volume = v;
    }

    public var muted(default, set):Bool = false;
    private function set_muted(v:Bool) {
        Rl.setMasterVolume((v) ? 0 : volume);
        return muted = v;
    }
    
    public var list:Array<ISound> = [];
    
    public function new() {
        volume = 0.3;
        Game.signals.preSceneCreate.add(() -> {
            Logs.trace("Clearing sounds...", ENGINE);
            for(sound in list) {
                sound.kill();
                sound.stop();
                sound.destroy();
                sound = null;
            }
            list = [];
        });

        Game.signals.preSceneUpdate.add(update);
    }

    public function update(elapsed:Float) {
        for(sound in list) {
            if(sound != null)
                sound.update(elapsed);
        }

        if(music != null)
            music.update(elapsed);
    }

    public function play(path:String, ?volume:Float) {
        list.push(new SoundEx(path, volume).play());
    }

    public function playMusic(path:String, ?volume:Float, ?loop:Bool = true) {
		if (music != null)
			music.destroy();

		music = new MusicEx(path, volume).play();
        music.loop = loop;
	}
}
#end