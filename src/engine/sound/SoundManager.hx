package engine.sound;

import engine.interfaces.ISound;

class SoundManager {
    public var music:MusicEx;

    public var volume(default, set):Float = 1;
    private function set_volume(v:Float) {
        #if !macro
        Rl.setMasterVolume(v);
        #end
        return volume = v;
    }

    public var muted(default, set):Bool = false;
    private function set_muted(v:Bool) {
        #if !macro
        Rl.setMasterVolume((v) ? 0 : volume);
        #end
        return muted = v;
    }
    
    public var list:Array<ISound> = [];
    
    public function new() {
        #if !macro
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
        #end
    }

    public function update(elapsed:Float) {
        #if !macro
        for(sound in list) {
            if(sound != null)
                sound.update(elapsed);
        }

        if(music != null)
            music.update(elapsed);
        #end
    }

    public function play(path:String, ?volume:Float) {
        #if !macro
        list.push(new SoundEx(path, volume).play());
        #end
    }

    public function playMusic(path:String, ?volume:Float, ?loop:Bool = true) {
        #if !macro
		if (music != null)
			music.destroy();

		music = new MusicEx(path, volume).play();
        music.loop = loop;
        #end
	}
}