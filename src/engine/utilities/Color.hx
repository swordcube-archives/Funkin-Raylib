package engine.utilities;

#if !macro
typedef Color = Rl.Color;
#else
class Color {
    public var r:Int;
    public var g:Int;
    public var b:Int;
    public var a:Int;

    public function new() {}

    public static function create(r:Int, g:Int, b:Int, a:Int) {
        var c = new Color();
        c.r = r;
        c.g = g;
        c.b = b;
        c.a = a;
        return c;
    }
}
#end