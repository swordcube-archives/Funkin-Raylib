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

    public function new(path:String, ?volume:Float = 1) {
        super();
        __sound = Rl.loadSound(path);
        this.volume = volume;
        this.pitch = 1;
        Rl.playSound(__sound);
    }

    public function stop() {
        Rl.stopSound(__sound);
        return this;
    }

    override function kill() {
        super.kill();
        Rl.pauseSound(__sound);
    }

    override function revive() {
        super.revive();
        Rl.resumeSound(__sound);
    }

    public function pause() {
        Rl.pauseSound(__sound);
        return this;
    }

    public function play() {
        Rl.resumeSound(__sound);
        return this;
    }

    public function resume() {
        Rl.resumeSound(__sound);
        return this;
    }

    override function destroy() {
        Rl.unloadSound(__sound);
        super.destroy();
    }
}
#end