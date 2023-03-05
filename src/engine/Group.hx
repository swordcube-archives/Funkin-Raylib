package engine;

import engine.Object;

typedef Group = TypedGroup<Object>;

class TypedGroup<T:Object> extends Object {
    public var maxSize:Int = 0;

    /**
     * @param maxSize The maximum amount of members that can be in this group.
     */
    public function new(?maxSize:Int = 0) {
        super();
        this.maxSize = maxSize;
    }

    public var members:Array<T> = [];

    public var length(get, never):Int;
    private function get_length():Int {
        return members.length;
    }

    override function update(elapsed:Float) {
        for(member in members) {
            if(!member.alive) continue;
            member.update(elapsed);
        }
    }

    override function draw() {
        for(member in members) {
            if(!member.alive) continue;
            member.draw();
        }
    }

    public function add(object:T) {
        if(maxSize > 0 && members.length >= maxSize)
            return object;

        members.push(object);
        return object;
    }

    public function remove(object:T) {
        members.remove(object);
        return object;
    }

    public function forEach(callback:T->Void) {
        for(member in members)
            callback(member);
    }

    public function forEachAlive(callback:T->Void) {
        for(member in members) {
            if(member.alive)
                callback(member);
            else
                continue;
        }
    }

    public function forEachDead(callback:T->Void) {
        for(member in members) {
            if(!member.alive)
                callback(member);
            else
                continue;
        }
    }

    /**
     * Destroys every member of this group.
     * This does not **remove** the members from the group, so crashes could occur.
     */
    override function destroy() {
        for(member in members)
            member.destroy();
    }
}