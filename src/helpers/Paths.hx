package helpers;

class Paths {
    public static function image(path:String) {
        return 'assets/images/$path.png';
    }

    public static function sound(path:String) {
        return 'assets/sounds/$path.ogg';
    }
}