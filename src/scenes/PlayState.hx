package scenes;

import funkin.song.SongFormat.SongData;

class PlayState extends Scene {
    public static var current:PlayState;
    public static var SONG:SongData;

    override function create() {
        super.create();

        Game.sound.music.stop();
    }
}