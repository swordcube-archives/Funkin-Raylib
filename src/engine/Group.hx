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
            if(member == null || !member.alive) continue;
            member.update(elapsed);
        }
    }

    public function queueDraw() {
        for(member in members) {
            if(member == null || !member.alive) continue;
            
            if (member is TypedGroup)
                cast(member, TypedGroup<Dynamic>).queueDraw();
            else
                member.camera.renderQueue.push(member.draw);
        }
    }

    override function draw() {
        var cameraList = Game.cameras.list.copy();
        cameraList.insert(0, Game.camera);

        queueDraw();

        for(camera in cameraList) { 
            @:privateAccess
            Rl.beginMode2D(camera.__rlCamera);

            for (drawFunc in camera.renderQueue)
                drawFunc();
            camera.renderQueue = [];

            Rl.endMode2D();
        }
    }

    /**
     * Adds anything that is/extends an `Object` to this group.
     * @param object The object to add.
     */
    public function add(object:T) {
        if(object == null) {
            Logs.trace("Cannot add a `null` object into a Group.", ERROR);
            return null;
        }

		// Don't bother adding an object twice.
		if (members.indexOf(object) >= 0)
			return object;

        // Make sure we don't have the maximum amount of objects allowed in the group.
        // 0 and below is equal to infinite.
        if(maxSize > 0 && members.length >= maxSize)
            return object;

        members.push(object);
        return object;
    }

    /**
     * Inserts anything that is/extends an `Object` to this group at a specific position.
     * @param position The position to add the object at.
     * @param object The object to add.
     */
    public function insert(position:Int, object:T) {
        if(object == null) {
            Logs.trace("Cannot insert a `null` object into a Group.", ERROR);
            return null;
        }

		// Don't bother adding an object twice.
		if (members.indexOf(object) >= 0)
			return object;

        // Make sure we don't have the maximum amount of objects allowed in the group.
        // 0 and below is equal to infinite.
        if(maxSize > 0 && members.length >= maxSize)
            return object;

        members.insert(position, object);
        return object;
    }

    /**
     * Removes anything that is/extends an `Object` from this group.
     * @param object The object to remove.
     */
    public function remove(object:T) {
        members.remove(object);
        return object;
    }

    public function forEach(callback:T->Void) {
        for(member in members) {
            if(member == null) continue;
            callback(member);
        }
    }

    public function forEachAlive(callback:T->Void) {
        for(member in members) {
            if(member != null && member.alive)
                callback(member);
            else
                continue;
        }
    }

    public function forEachDead(callback:T->Void) {
        for(member in members) {
            if(member != null && !member.alive)
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
        for(member in members) {
            if(member == null) continue;
            member.destroy();
        }
        clear();
    }

    /**
     * Removes all members from this group.
     * This does not **kill** or **destroy** the members automatically!
     */
    public function clear() {
        members = [];
    }
}