package funkin.song;

import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import funkin.song.SongFormat.SongData;

class Song {
	public static final fallbackSong:SongData = {
		song: "ERROR, CHECK YOUR CHART JSON!",
		player1: "bf",
		player2: "bf",
		gfVersion: "gf",
		stage: "stage",
		speed: 1,
		bpm: 100,
		notes: [],
		events: [],
		changeableSkin: null,
		splashSkin: "noteSplashes",
		needsVoices: false,
		assetModifier: "base"
	};

	public static inline function loadFromJson(song:String, ?diff:String = "normal") {
		return loadChart(song, diff);
	}

    public static function loadChart(song:String, ?diff:String = "normal"):SongData {
		var data:SongData = try {
			var path:String = Paths.songJson(song, diff);
            Json.parse(FileSystem.exists(path) ? File.getContent(path) : Json.stringify({song: fallbackSong})).song;
        } catch(e) {
            Logs.trace('Error occured while loading chart for $song on $diff difficulty: $e', ERROR);
            fallbackSong;
        };

        return data;
    }
}