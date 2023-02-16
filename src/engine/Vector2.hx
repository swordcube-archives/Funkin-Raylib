package engine;

abstract Vector2(Array<Float>) to Array<Float> from Array<Float> {
    public var x(get, set):Float;
    private function get_x():Float {
        return this[0];
    }
    private function set_x(v:Float):Float {
        return this[0] = v;
    }

    public var y(get, set):Float;
    private function get_y():Float {
        return this[1];
    }
    private function set_y(v:Float):Float {
        return this[1] = v;
    }

    public function new(?x:Float = 0, ?y:Float = 0) {
        this = [x, y];
    }

    public function set(?x:Float = 0, ?y:Float = 0) {
        this[0] = x;
        this[1] = y;
    }

    public function add(?x:Float = 0, ?y:Float = 0) {
        this[0] += x;
        this[1] += y;
    }

    public function substract(?x:Float = 0, ?y:Float = 0) {
        this[0] -= x;
        this[1] -= y;
    }
}