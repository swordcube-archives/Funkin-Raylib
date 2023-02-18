package scenes;

import scenes.MusicBeat.MusicBeatScene;
import scenes.menus.*;
import engine.sound.MusicEx;
import funkin.song.SongFormat.SongData;

class PlayState extends MusicBeatScene {
    public static var current:PlayState;
    public static var SONG:SongData;

    public var inst:MusicEx;
    public var vocals:MusicEx;

    override function create() {
        super.create();

        Game.sound.music.stop();

        Conductor.position = 0;

        add(inst = new MusicEx(Paths.songInst(SONG.song), 1, false).play());
        inst.onComplete = endSong;

        add(vocals = new MusicEx(Paths.songVoices(SONG.song), 1, false).play());
    }

    public function endSong() {
        Game.switchScene(new MainMenu());
    }

    override function destroy() {
        for(object in [inst, vocals])
            object.destroy();

        super.destroy();
    }
}