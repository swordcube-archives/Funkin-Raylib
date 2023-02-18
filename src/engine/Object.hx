package engine;

import engine.interfaces.IDestroyable;

class Object implements IDestroyable {
    public var alive:Bool = true;
    public var immovable:Bool = false;
    
    public var position:Point2D = new Point2D(0, 0);

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