package helpers;

class Paths {
    public static function image(path:String) {
        return 'assets/images/$path.png';
    }

    public static function music(path:String) {
        return 'assets/music/$path.ogg';
    }

    public static function sound(path:String) {
        return 'assets/sounds/$path.ogg';
    }

    public static function font(path:String) {
        return 'assets/fonts/$path';
    }
}