package engine.sound;

import engine.interfaces.ISound;
import engine.utilities.typeLimit.OneOfTwo;
import sys.FileSystem;
import engine.Object;

#if !macro
import Rl.Music;
#end

/**
 * A class for playing long sound effects.
 * Has the ability to get the time of the sound unlike `SoundEx`.
 * 
 * Do ***NOT*** use this class for every sound, only use it when necessary.
 */
class MusicEx extends Object implements ISound {
    #if !macro
    public var audioLoaded:Bool = false;

    private var __sound:Music;

    /**
     * The volume of this sound. (Ranges from 0 - 1)
     */
    public var volume(default, set):Float;
    private function set_volume(v:Float):Float {
        if(audioLoaded)
            Rl.setMusicVolume(__sound, v);

        return volume = v;
    }

    /**
     * The pitch of this sound. (Ranges from 0 - 1)
     */
    public var pitch(default, set):Float;
    private function set_pitch(v:Float):Float {
        if(audioLoaded)
            Rl.setMusicPitch(__sound, v);
        
        return pitch = v;
    }

    /**
     * The time of this sound in milliseconds.
     */
    public var time(get, set):Float;
    private function get_time():Float {
        return (audioLoaded) ? Rl.getMusicTimePlayed(__sound) * 1000 : 0;
    }
    private function set_time(v:Float):Float {
        if(audioLoaded)
            Rl.seekMusicStream(__sound, v / 1000);

        return v;
    }

    /**
     * The length of this sound in milliseconds.
     */
    public var length(get, never):Float;
    private function get_length():Float {
        var ret:Float = (audioLoaded) ? (Rl.getMusicTimeLength(__sound) * 1000) : 0;
        if(ret < 0) ret = 0;
        return ret;
    }

    /**
     * Whether or not this sound is playing.
     */
    public var playing:Bool = false;

    /**
     * Whether or not this sound is looping.
     */
    public var loop(default, set):Bool;
    private function set_loop(v:Bool):Bool {
        if(audioLoaded)
            __sound.looping = v;

        return loop = v;
    }

    public var onComplete:Void->Void;

    private var __path:String;
    #end

    public function new(path:String, ?volume:Float = 1, ?loop:Bool = true) {
        super();
        #if !macro
        this.__path = path;

        audioLoaded = FileSystem.exists(path);
        if(!audioLoaded) return;

        __sound = Rl.loadMusicStream(path);
        this.volume = volume;
        this.pitch = 1;
        this.loop = loop;
        Rl.playMusicStream(__sound);
        #end
    }

    #if !macro
    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!audioLoaded) return;

        if(playing)
            Rl.updateMusicStream(__sound);
        
        if(!Rl.isMusicStreamPlaying(__sound) && playing && !loop) {
            stop();
            if(onComplete != null)
                onComplete();
        }
    }
    #end

    public function stop() {
        #if !macro
        playing = false;
        if(!audioLoaded) return this;

        Rl.stopMusicStream(__sound);
        #end
        return this;
    }
    public function play() {return resume();}

    public function pause() {
        #if !macro
        playing = false;
        if(!audioLoaded) return this;

        Rl.pauseMusicStream(__sound);
        #end
        return this;
    }

    public function resume() {
        #if !macro
        playing = true;
        if(!audioLoaded) return this;
        
        Rl.resumeMusicStream(__sound);
        #end
        return this;
    }

    override function destroy() {
        #if !macro
        playing = false;
        if(audioLoaded)
            Rl.unloadMusicStream(__sound);

        audioLoaded = false;
        #end
        super.destroy();
    }
}