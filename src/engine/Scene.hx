package engine;

class Scene {
    public var members:Array<Object> = [];

    public function new() {
        create();
    }

    public function create() {}

    public function update(elapsed:Float) {
        for(member in members)
            member.update(elapsed);
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