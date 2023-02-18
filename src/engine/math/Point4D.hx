package engine.math;

class Point4D {
    public var x:Float;
    public var y:Float;
    public var w:Float;
    public var h:Float;

    public function new(?x:Float = 0, ?y:Float = 0, ?w:Float = 0, ?h:Float = 0) {
        set(x, y, w, h);
    }

    public function set(?x:Float = 0, ?y:Float = 0, ?w:Float = 0, ?h:Float = 0) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    public function add(?x:Float = 0, ?y:Float = 0, ?w:Float = 0, ?h:Float = 0) {
        this.x += x;
        this.y += y;
        this.w += w;
        this.h += h;
    }

    public function substract(?x:Float = 0, ?y:Float = 0, ?w:Float = 0, ?h:Float = 0) {
        this.x -= x;
        this.y -= y;
        this.w -= w;
        this.h -= h;
    }
}