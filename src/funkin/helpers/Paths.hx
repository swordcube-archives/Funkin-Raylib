package funkin.helpers;

import sys.FileSystem;
import engine.utilities.Atlas;

class Paths {
    public static final scriptExtensions:Array<String> = [
        "hx",
        "hxs",
        "hsc",
        "hscript"
    ];

    public static function asset(path:String) {
        var srcPath:String = '../../assets/$path';
        if(FileSystem.exists(srcPath))
            return srcPath;

        return './assets/$path';
    }

    public inline static function image(path:String) {
        return asset('images/$path.png');
    }

    public inline static function music(path:String) {
        return asset('music/$path.ogg');
    }

    public inline static function sound(path:String) {
        return asset('sounds/$path.ogg');
    }

    public static function songInst(song:String, ?diff:String = "normal") {
        var songPaths:Array<String> = [
            asset('songs/${song.toLowerCase()}/Inst-$diff.ogg')
        ];
        for(p in songPaths) {
            if(FileSystem.exists(p))
                return p;
        }
        var p:String = asset('songs/${song.toLowerCase()}/Inst.ogg');
        return p;
    }

    public static function songVoices(song:String, ?diff:String = "normal") {
        var songPaths:Array<String> = [
            asset('songs/${song.toLowerCase()}/Voices-$diff.ogg')
        ];
        for(p in songPaths) {
            if(FileSystem.exists(p))
                return p;
        }
        var p:String = asset('songs/${song.toLowerCase()}/Voices.ogg');
        return p;
    }

    public static function songJson(song:String, ?diff:String = "normal") {
        var songPaths:Array<String> = [
            asset('songs/$song/$song-$diff.json'),
            asset('data/$song/$song-$diff.json'),
            asset('data/$song/$diff.json'),
            asset('data/charts/$song/$diff.json'),
            asset('data/charts/$song/$song-$diff.json'),
        ];
        for(p in songPaths) {
            if(FileSystem.exists(p))
                return p;
        }
        var p:String = asset('songs/$song/$diff.json');
        return p;
    }

    public inline static function font(path:String) {
        return asset('fonts/$path');
    }

    public inline static function xml(path:String) {
        return asset('$path.xml');
    }

    public inline static function txt(path:String) {
        return asset('$path.txt');
    }

    public static function script(path:String) {
        for(ext in scriptExtensions) {
            var p:String = asset('$path.$ext');
            if(FileSystem.exists(p))
                return p;
        }
        var p:String = asset('$path.hx');
        return p;
    }

    public inline static function json(path:String) {
        return asset('$path.json');
    }

    public inline static function getSparrowAtlas(path:String) {
        return Atlas.fromSparrow(image(path), xml('images/$path'));
    }
}