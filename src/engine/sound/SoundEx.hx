package engine.sound;

import engine.interfaces.ISound;
import sys.FileSystem;
#if !macro
import engine.Object;
import Rl.Sound;

/**
 * A class for playing short sound effects.
 * Use `MusicEx` to play longer sounds with the ability to get the time of them.
 */
class SoundEx extends Object implements ISound {
    public var audioLoaded:Bool = false;

    private var __sound:Sound;

    /**
     * The volume of this sound. (Ranges from 0 - 1)
     */
    public var volume(default, set):Float;
    private function set_volume(v:Float):Float {
        if(audioLoaded)
            Rl.setSoundVolume(__sound, v);

        return volume = v;
    }

    /**
     * The pitch of this sound. (Ranges from 0 - 1)
     */
    public var pitch(default, set):Float;
    private function set_pitch(v:Float):Float {
        if(audioLoaded)
            Rl.setSoundPitch(__sound, v);

        return pitch = v;
    }

    // you can't get the time of a sound in raylib :(

    /**
     * The length of this sound in milliseconds.
     */
    public var length(get, never):Float;
    private function get_length():Float {
        return (audioLoaded) ? (__sound.frameCount / __sound.stream.sampleRate) * 1000 : 0;
    }

    /**
     * Whether or not this sound is playing.
     */
    public var playing:Bool = false;

    /**
     * Whether or not this sound is looping.
     */
    public var loop:Bool = false;

    private var __path:String;

    public function new(path:String, ?volume:Float = 1) {
        super();
        this.__path = path;

        audioLoaded = FileSystem.exists(path);
        if(!audioLoaded) return;

        __sound = Rl.loadSound(path);
        this.volume = volume;
        this.pitch = 1;
        Rl.playSound(__sound);
        Rl.pauseSound(__sound);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!audioLoaded) return;

        if(!Rl.isSoundPlaying(__sound) && loop && playing)
            Rl.playSound(__sound);
    }

    public function stop() {
        playing = false;
        if(!audioLoaded) return this;
        Rl.stopSound(__sound);
        return this;
    }
    public function play() {return resume();}

    public function pause() {
        playing = false;
        if(!audioLoaded) return this;
        Rl.pauseSound(__sound);
        return this;
    }

    public function resume() {
        playing = true;
        if(!audioLoaded) return this;
        Rl.resumeSound(__sound);
        return this;
    }

    override function destroy() {
        playing = false;
        if(audioLoaded)
            Rl.unloadSound(__sound);

        audioLoaded = false;
        super.destroy();
    }
}
#end