package engine.math;

class Point2D {
    public var x:Float;
    public var y:Float;

    public function new(?x:Float = 0, ?y:Float = 0) {
        set(x, y);
    }

    public function set(?x:Float = 0, ?y:Float = 0) {
        this.x = x;
        this.y = y;
    }

    public function add(?x:Float = 0, ?y:Float = 0) {
        this.x += x;
        this.y += y;
    }

    public function substract(?x:Float = 0, ?y:Float = 0) {
        this.x -= x;
        this.y -= y;
    }
}