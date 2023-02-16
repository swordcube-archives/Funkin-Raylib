package engine.sound;

#if !macro
import engine.Object;
import Rl.Sound as Sound;

class Audio extends Object {
    private var __sound:Sound;

    /**
     * The volume of this sound. (Ranges from 0 - 1)
     */
    public var volume(default, set):Float;
    private function set_volume(v:Float):Float {
        Rl.setSoundVolume(__sound, v);
        return volume = v;
    }

    /**
     * The pitch of this sound. (Ranges from 0 - 1)
     */
    public var pitch(default, set):Float;
    private function set_pitch(v:Float):Float {
        Rl.setSoundPitch(__sound, v);
        return pitch = v;
    }

    /**
     * Whether or not this sound is playing.
     */
    public var playing:Bool = true;

    /**
     * Whether or not this sound is looping.
     */
    public var loop:Bool = false;

    private var __path:String;

    public function new(path:String, ?volume:Float = 1) {
        super();
        this.__path = path;
        __sound = Rl.loadSound(path);
        this.volume = volume;
        this.pitch = 1;
        Rl.playSound(__sound);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!Rl.isSoundPlaying(__sound) && loop)
            Rl.playSound(__sound);
    }

    public function stop() {return pause();}
    public function play() {return resume();}

    public function pause() {
        playing = false;
        Rl.pauseSound(__sound);
        return this;
    }

    public function resume() {
        playing = true;
        Rl.resumeSound(__sound);
        return this;
    }

    override function destroy() {
        playing = false;
        Rl.unloadSound(__sound);
        super.destroy();
    }
}
#end