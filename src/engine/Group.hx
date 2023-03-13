package engine;

import engine.Object;
import engine.utilities.Logs;
import engine.utilities.DestroyUtil;
import engine.utilities.Signal.TypedSignal;
import engine.utilities.Sort;
import Std.isOfType;

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

	@:noCompletion
	private function get_length():Int {
		return members.length;
	}

	/**
	 * A `Signal` that dispatches when a child is added to this group.
	 */
	public var memberAdded:TypedSignal<T->Void> = new TypedSignal<T->Void>();

	/**
	 * A `Signal` that dispatches when a child is removed from this group.
	 */
	public var memberRemoved:TypedSignal<T->Void> = new TypedSignal<T->Void>();

	/**
	 * Internal helper variable for recycling objects.
	 */
	@:noCompletion
	var __marker:Int = 0;

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

			if (memberAdded != null)
				memberAdded.dispatch(object);

			return object;
		}

		// If the group is full, return the Object
		if (maxSize > 0 && length >= maxSize)
			return object;

		// If we made it this far, we need to add the object to the group.
		members.push(object);

		if (memberAdded != null)
			memberAdded.dispatch(object);

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

			if (memberAdded != null)
				memberAdded.dispatch(object);

			return object;
		}

		// If the group is full, return the object
		if (maxSize > 0 && length >= maxSize)
			return object;

		// If we made it this far, we need to insert the object into the group at the specified position.
		members.insert(position, object);

		if (memberAdded != null)
			memberAdded.dispatch(object);

		return object;
	}

	/**
	 * Removes anything that is/extends an `Object` from this group.
	 * @param object The object to remove.
	 */
	public function remove(object:T) {
		var index:Int = members.indexOf(object);
		if(index == -1) return object;

		members.remove(object);

		if (memberRemoved != null)
			memberRemoved.dispatch(object);

		return object;
	}

	/**
	 * Replaces an existing `Basic` with a new one.
	 * Does not do anything and returns `null` if the old object is not part of the group.
	 *
	 * @param   OldObject   The object you want to replace.
	 * @param   NewObject   The new object you want to use instead.
	 * @return  The new object.
	 */
	public function replace(OldObject:T, NewObject:T):T {
		var index:Int = members.indexOf(OldObject);

		if (index < 0)
			return null;

		members[index] = NewObject;

		if (memberRemoved != null)
			memberRemoved.dispatch(OldObject);
		
		if (memberAdded != null)
			memberAdded.dispatch(NewObject);

		return NewObject;
	}

	/**
	 * Call this function to sort the group according to a particular value and order.
	 * For example, to sort game objects for Zelda-style overlaps you might call
	 * `group.sort(Sort.byY, Sort.ASCENDING)` at the bottom of your `State#update()` override.
	 *
	 * @param   Function   The sorting function to use - you can use one of the premade ones in
	 *                     `Sort` or write your own using `Sort.byValues()` as a "backend".
	 * @param   Order      A constant that defines the sort order.
	 *                     Possible values are `Sort.ASCENDING` (default) and `Sort.DESCENDING`.
	 */
	public inline function sort(Function:Int->T->T->Int, Order:Int = Sort.ASCENDING):Void {
		members.sort(Function.bind(Order));
	}

	/**
	 * Call this function to retrieve the first object with `alive == false` in the group.
	 * This is handy for recycling in general, e.g. respawning enemies.
	 *
	 * @param   ObjectClass   An optional parameter that lets you narrow the
	 *                        results to instances of this particular class.
	 * @param   Force         Force the object to be an `ObjectClass` and not a super class of `ObjectClass`.
	 * @return  A `Basic` currently flagged as not existing.
	 */
	public function getFirstAvailable(?ObjectClass:Class<T>, Force:Bool = false):T {
		var i:Int = 0;
		var basic:Basic = null;

		while (i < length) {
			basic = members[i++]; // we use basic as Basic for performance reasons

			if (basic != null && !basic.alive && (ObjectClass == null || isOfType(basic, ObjectClass))) {
				if (Force && Type.getClassName(Type.getClass(basic)) != Type.getClassName(ObjectClass)) {
					continue;
				}
				return members[i - 1];
			}
		}

		return null;
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

	/**
	 * Call this function to retrieve the first object with `dead == false` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `Basic` currently flagged as not dead.
	 */
	public function getFirstAlive():T {
		var i:Int = 0;
		var basic:Basic = null;

		while (i < length) {
			basic = members[i++]; // we use basic as Basic for performance reasons

			if (basic != null && basic.alive)
				return cast basic;
		}

		return null;
	}

	/**
	 * Call this function to retrieve the first object with `dead == true` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `Basic` currently flagged as dead.
	 */
	public function getFirstDead():T {
		var i:Int = 0;
		var basic:Basic = null;

		while (i < length) {
			basic = members[i++]; // we use basic as Basic for performance reasons

			if (basic != null && !basic.alive)
				return cast basic;
		}

		return null;
	}

	/**
	 * Call this function to find out how many members of the group are not dead.
	 *
	 * @return  The number of `Basic`s flagged as not dead. Returns `-1` if group is empty.
	 */
	public function countLiving():Int {
		var i:Int = 0;
		var count:Int = -1;
		var basic:Basic = null;

		while (i < length) {
			basic = members[i++];

			if (basic != null) {
				if (count < 0)
					count = 0;
				if (basic.alive)
					count++;
			}
		}

		return count;
	}

	/**
	 * Call this function to find out how many members of the group are dead.
	 *
	 * @return  The number of `Basic`s flagged as dead. Returns `-1` if group is empty.
	 */
	public function countDead():Int {
		var i:Int = 0;
		var count:Int = -1;
		var basic:Basic = null;

		while (i < length) {
			basic = members[i++];

			if (basic != null) {
				if (count < 0)
					count = 0;
				if (!basic.alive)
					count++;
			}
		}

		return count;
	}

	/**
	 * Returns a member at random from the group.
	 *
	 * @param   StartIndex  Optional offset off the front of the array.
	 *                      Default value is `0`, or the beginning of the array.
	 * @param   Length      Optional restriction on the number of values you want to randomly select from.
	 * @return  A `Basic` from the `members` list.
	 */
	public function getRandom(StartIndex:Int = 0, Length:Int = 0):T {
		if (StartIndex < 0)
			StartIndex = 0;
		if (Length <= 0)
			Length = length;

		return Game.random.getObject(members, StartIndex, Length);
	}

	/**
	 * Recycling is designed to help you reuse game objects without always re-allocating or "newing" them.
	 * It behaves differently depending on whether `maxSize` equals `0` or is bigger than `0`.
	 *
	 * `maxSize > 0` / "rotating-recycling" (used by `Emitter`):
	 *   - at capacity:  returns the next object in line, no matter its properties like `alive`, `exists` etc.
	 *   - otherwise:    returns a new object.
	 *
	 * `maxSize == 0` / "grow-style-recycling"
	 *   - tries to find the first object with `exists == false`
	 *   - otherwise: adds a new object to the `members` array
	 *
	 * WARNING: If this function needs to create a new object, and no object class was provided,
	 * it will return `null` instead of a valid object!
	 *
	 * @param   ObjectClass     The class type you want to recycle (e.g. `Sprite`, `EvilRobot`, etc).
	 * @param   ObjectFactory   Optional factory function to create a new object
	 *                          if there aren't any dead members to recycle.
	 *                          If `null`, `Type.createInstance()` is used,
	 *                          which requires the class to have no constructor parameters.
	 * @param   Force           Force the object to be an `ObjectClass` and not a super class of `ObjectClass`.
	 * @param   Revive          Whether recycled members should automatically be revived
	 *                          (by calling `revive()` on them).
	 * @return  A reference to the object that was created.
	 */
	public function recycle(?ObjectClass:Class<T>, ?ObjectFactory:Void->T, Force:Bool = false, Revive:Bool = true):T {
		var basic:Basic = null;

		// rotated recycling
		if (maxSize > 0) {
			// create new instance
			if (length < maxSize)
				return recycleCreateObject(ObjectClass, ObjectFactory);

			// get the next member if at capacity
			else {
				basic = members[__marker++];

				if (__marker >= maxSize)
					__marker = 0;

				if (Revive)
					basic.revive();

				return cast basic;
			}
		}
		// grow-style recycling - grab a basic with exists == false or create a new one
		else {
			basic = getFirstAvailable(ObjectClass, Force);

			if (basic != null) {
				if (Revive)
					basic.revive();
				return cast basic;
			}

			return recycleCreateObject(ObjectClass, ObjectFactory);
		}
	}

	@:noCompletion
	inline function recycleCreateObject(?ObjectClass:Class<T>, ?ObjectFactory:Void->T):T {
		var object:T = null;

		if (ObjectFactory != null)
			add(object = ObjectFactory());
		else if (ObjectClass != null)
			add(object = Type.createInstance(ObjectClass, []));

		return object;
	}

	public function forEach(callback:T->Void) {
		for (member in members) {
			if (member == null) continue;
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
		DestroyUtil.destroy(memberAdded);
		DestroyUtil.destroy(memberRemoved);

		for (member in members) {
			if (member == null) continue;
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
