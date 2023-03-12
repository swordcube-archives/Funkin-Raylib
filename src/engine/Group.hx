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
		for (member in members) {
			if (member == null || !member.alive)
				continue;
			member.update(elapsed);
		}
	}

	override function draw() {
		var i:Int = 0;
		var basic:Object = null;

		var oldDefaultCameras = Camera.defaultCameras;
		if (cameras != null)
			Camera.defaultCameras = cameras;

		while (i < length) {
			basic = members[i++];

			if (basic != null && basic.alive && basic.visible)
				basic.draw();
		}

		Camera.defaultCameras = oldDefaultCameras;
	}

	/**
	 * Adds anything that is/extends an `Object` to this group.
	 * @param object The object to add.
	 */
	public function add(object:T) {
		if (object == null) {
			Logs.trace("Cannot add a `null` object to a Group.", WARNING);
			return null;
		}

		// Don't bother adding an object twice.
		if (members.indexOf(object) >= 0)
			return object;

		// First, look for a null entry where we can add the object.
		var index:Int = getFirstNull();
		if (index != -1) {
			members[index] = object;
			return object;
		}

		// If the group is full, return the Object
		if (maxSize > 0 && length >= maxSize)
			return object;

		// If we made it this far, we need to add the object to the group.
		members.push(object);
		return object;
	}

	/**
	 * Inserts anything that is/extends an `Object` to this group at a specific position.
	 * @param position The position to add the object at.
	 * @param object The object to add.
	 */
	public function insert(position:Int, object:T) {
		if (object == null) {
			Logs.trace("Cannot insert a `null` object into a Group.", ERROR);
			return null;
		}

		// Don't bother inserting an object twice.
		if (members.indexOf(object) >= 0)
			return object;

		// First, look if the member at position is null, so we can directly assign the object at the position.
		if (position < length && members[position] == null) {
			members[position] = object;
			return object;
		}

		// If the group is full, return the object
		if (maxSize > 0 && length >= maxSize)
			return object;

		// If we made it this far, we need to insert the object into the group at the specified position.
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

	/**
	 * Call this function to retrieve the first index set to `null`.
	 * Returns `-1` if no index stores a `null` object.
	 *
	 * @return  An `Int` indicating the first `null` slot in the group.
	 */
	public function getFirstNull():Int {
		var i:Int = 0;

		while (i < length) {
			if (members[i] == null)
				return i;
			i++;
		}

		return -1;
	}

	public function forEach(callback:T->Void) {
		for (member in members) {
			if (member == null)
				continue;
			callback(member);
		}
	}

	public function forEachAlive(callback:T->Void) {
		for (member in members) {
			if (member != null && member.alive)
				callback(member);
			else
				continue;
		}
	}

	public function forEachDead(callback:T->Void) {
		for (member in members) {
			if (member != null && !member.alive)
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
		for (member in members) {
			if (member == null)
				continue;
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
