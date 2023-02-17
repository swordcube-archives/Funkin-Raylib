package helpers;

class Paths {
    public inline static function asset(path:String) {
        return 'assets/$path';
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

    public inline static function font(path:String) {
        return asset('fonts/$path');
    }
}