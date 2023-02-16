package engine;

import engine.interfaces.IDestroyable;

#if !macro
class Scene implements IDestroyable {
    public var members:Array<Object> = [];

    public function new() {
        create();
    }

    public function create() {}

    public function update(elapsed:Float) {
        for(member in members) {
            if(!member.alive) continue;
            member.update(elapsed);
        }
    }

    public function draw() {
        for(member in members)
            member.draw();
    }

    public function add<T:Object>(object:T) {
        members.push(object);
        return object;
    }

    public function remove<T:Object>(object:T) {
        members.remove(object);
        return object;
    }

    public function destroy() {
        for(member in members)
            member.destroy();
    }
}
#end