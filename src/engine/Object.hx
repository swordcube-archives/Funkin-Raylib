package engine;

import engine.interfaces.IDestroyable;
import engine.Vector2;

#if !macro
class Object implements IDestroyable {
    public var position:Vector2 = new Vector2(0, 0);

    public function new(?x:Float = 0, ?y:Float = 0) {
        position.set(x, y);
    }

    public var alive:Bool = true;

    public function update(elapsed:Float) {}
    public function draw() {}

    public function kill() {alive = false;}
    public function revive() {alive = true;}
    public function destroy() {
        alive = false;
        position = null;
    }
}
#end