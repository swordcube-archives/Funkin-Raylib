package engine;

import engine.interfaces.IDestroyable;

class Object implements IDestroyable {
    public var ID:Int = 0;
    
    public var alive:Bool = true;
    public var immovable:Bool = false;
    
    public var position:Point2D = new Point2D(0, 0);
    
    public var x(get, set):Float;
    private function get_x():Float {
        return position.x;
    }
    private function set_x(v:Float):Float {
        return position.x = v;
    }

    public var y(get, set):Float;
    private function get_y():Float {
        return position.y;
    }
    private function set_y(v:Float):Float {
        return position.y = v;
    }

    public function setPosition(?x:Float = 0, ?y:Float = 0) {
        position.set(x, y);
    }

    public function new(?x:Float = 0, ?y:Float = 0) {
        position.set(x, y);
    }

    public function update(elapsed:Float) {}
    public function draw() {}

    public function kill() {alive = false;}
    public function revive() {alive = true;}
    public function destroy() {
        alive = false;
        position = null;
    }
}