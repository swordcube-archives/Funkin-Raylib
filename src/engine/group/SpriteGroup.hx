package engine.group;

import engine.math.CallbackPoint2D;
import engine.Sprite;
import engine.math.Point2D;
import engine.math.MathUtil;
import engine.math.Point4D;
import engine.group.Group.TypedGroupIterator;
import engine.utilities.Sort;
import engine.group.Group.TypedGroup;
import engine.utilities.Color;

typedef SpriteGroup = TypedSpriteGroup<Sprite>;

/**
 * `SpriteGroup` is a special `Sprite` that can be treated like
 * a single sprite even if it's made up of several member sprites.
 * It shares the `TypedGroup` API, but it doesn't inherit from it.
 */
class TypedSpriteGroup<T:Sprite> extends Sprite {
	/**
	 * The actual group which holds all sprites.
	 */
	public var group:TypedGroup<T>;

	/**
	 * The link to a group's `members` array.
	 */
	public var members(get, never):Array<T>;

	/**
	 * The number of entries in the members array. For performance and safety you should check this
	 * variable instead of `members.length` unless you really know what you're doing!
	 */
	public var length(get, never):Int;

	/**
	 * Whether to attempt to preserve the ratio of alpha values of group members, or set them directly through
	 * the alpha property. Defaults to `false` (preservation).
	 */
	public var directAlpha:Bool = false;

	/**
	 * The maximum capacity of this group. Default is `0`, meaning no max capacity, and the group can just grow.
	 */
	public var maxSize(get, set):Int;

	/**
	 * Optimization to allow setting position of group without transforming children twice.
	 */
	var _skipTransformChildren:Bool = false;

	/**
	 * Array of all the `Sprite`s that exist in this group for
	 * optimization purposes / static typing on cpp targets.
	 */
	var _sprites:Array<Sprite>;

	/**
	 * @param   X         The initial X position of the group.
	 * @param   Y         The initial Y position of the group.
	 * @param   MaxSize   Maximum amount of members allowed.
	 */
	public function new(X:Float = 0, Y:Float = 0, MaxSize:Int = 0) {
		super(X, Y);
		group = new TypedGroup<T>(MaxSize);
		_sprites = cast group.members;

		position = new CallbackPoint2D(positionCallback);
		offset = new CallbackPoint2D(offsetCallback);
		origin = new CallbackPoint2D(originCallback);
		scale = new CallbackPoint2D(scaleCallback);
		scrollFactor = new CallbackPoint2D(scrollFactorCallback);

		scale.set(1, 1);
		scrollFactor.set(1, 1);
	}

	override function destroy() {
		group.destroy();
		super.destroy();
	}

	override function update(elapsed:Float) {
		group.update(elapsed);

		if (moves)
			updateMotion(elapsed);
	}

	override public function draw() {
		group.draw();
	}

	/**
	 * Adds a new `Sprite` subclass to the group.
	 *
	 * @param   Sprite   The sprite or sprite group you want to add to the group.
	 * @return  The same object that was passed in.
	 */
	public function add(Sprite:T):T {
		preAdd(Sprite);
		return group.add(Sprite);
	}

	/**
	 * Inserts a new `Sprite` subclass to the group at the specified position.
	 *
	 * @param   Position The position that the new sprite or sprite group should be inserted at.
	 * @param   Sprite   The sprite or sprite group you want to insert into the group.
	 * @return  The same object that was passed in.
	 */
	public function insert(Position:Int, Sprite:T):T {
		preAdd(Sprite);
		return group.insert(Position, Sprite);
	}

	/**
	 * Adjusts the position and other properties of the soon-to-be child of this sprite group.
	 * Private helper to avoid duplicate code in `add()` and `insert()`.
	 *
	 * @param	Sprite	The sprite or sprite group that is about to be added or inserted into the group.
	 */
	function preAdd(Sprite:T):Void {
		var sprite:Sprite = cast Sprite;
		sprite.x += x;
		sprite.y += y;
		sprite.alpha *= alpha;
		sprite.scrollFactor.copyFrom(scrollFactor);
		sprite.cameras = _cameras; // _cameras instead of cameras because get_cameras() will not return null

		if (clipRect != null)
			clipRectTransform(sprite, clipRect);
	}

	/**
	 * Recycling is designed to help you reuse game objects without always re-allocating or "newing" them.
	 * It behaves differently depending on whether `maxSize` equals `0` or is bigger than `0`.
	 *
	 * `maxSize > 0` / "rotating-recycling":
	 *   - at capacity:  returns the next object in line, no matter its properties like `alive`, `alive` etc.
	 *   - otherwise:    returns a new object.
	 *
	 * `maxSize == 0` / "grow-style-recycling"
	 *   - tries to find the first object with `alive == false`
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
	public inline function recycle(?ObjectClass:Class<T>, ?ObjectFactory:Void->T, Force:Bool = false, Revive:Bool = true):T {
		return group.recycle(ObjectClass, ObjectFactory, Force, Revive);
	}

	/**
	 * Removes the specified sprite from the group.
	 *
	 * @param   Sprite   The `Sprite` you want to remove.
	 * @return  The removed sprite.
	 */
	public function remove(Sprite:T):T {
		var sprite:Sprite = cast Sprite;
		sprite.x -= x;
		sprite.y -= y;
		// alpha
		sprite.cameras = null;
		return group.remove(Sprite);
	}

	/**
	 * Replaces an existing `Sprite` with a new one.
	 *
	 * @param   OldObject   The sprite you want to replace.
	 * @param   NewObject   The new object you want to use instead.
	 * @return  The new sprite.
	 */
	public inline function replace(OldObject:T, NewObject:T):T {
		return group.replace(OldObject, NewObject);
	}

	/**
	 * Call this function to sort the group according to a particular value and order.
	 * For example, to sort game objects for Zelda-style overlaps you might call
	 * `group.sort(Sort.byY, Sort.ASCENDING)` at the bottom of your `Scene#update()` override.
	 *
	 * @param   Function   The sorting function to use - you can use one of the premade ones in
	 *                     `Sort` or write your own using `Sort.byValues()` as a "backend".
	 * @param   Order      A constant that defines the sort order.
	 *                     Possible values are `Sort.ASCENDING` (default) and `Sort.DESCENDING`.
	 */
	public inline function sort(Function:Int->T->T->Int, Order:Int = Sort.ASCENDING):Void {
		group.sort(Function, Order);
	}

	/**
	 * Call this function to retrieve the first object with `alive == false` in the group.
	 * This is handy for recycling in general, e.g. respawning enemies.
	 *
	 * @param   ObjectClass   An optional parameter that lets you narrow the
	 *                        results to instances of this particular class.
	 * @param   Force         Force the object to be an `ObjectClass` and not a super class of `ObjectClass`.
	 * @return  A `Sprite` currently flagged as not existing.
	 */
	public inline function getFirstAvailable(?ObjectClass:Class<T>, Force:Bool = false):T {
		return group.getFirstAvailable(ObjectClass, Force);
	}

	/**
	 * Call this function to retrieve the first index set to `null`.
	 * Returns `-1` if no index stores a `null` object.
	 *
	 * @return  An `Int` indicating the first `null` slot in the group.
	 */
	public inline function getFirstNull():Int {
		return group.getFirstNull();
	}

	/**
	 * Call this function to retrieve the first object with `dead == false` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `Sprite` currently flagged as not dead.
	 */
	public inline function getFirstAlive():T {
		return group.getFirstAlive();
	}

	/**
	 * Call this function to retrieve the first object with `dead == true` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `Sprite` currently flagged as dead.
	 */
	public inline function getFirstDead():T {
		return group.getFirstDead();
	}

	/**
	 * Call this function to find out how many members of the group are not dead.
	 *
	 * @return  The number of `Sprite`s flagged as not dead. Returns `-1` if group is empty.
	 */
	public inline function countLiving():Int {
		return group.countLiving();
	}

	/**
	 * Call this function to find out how many members of the group are dead.
	 *
	 * @return  The number of `Sprite`s flagged as dead. Returns `-1` if group is empty.
	 */
	public inline function countDead():Int {
		return group.countDead();
	}

	/**
	 * Returns a member at random from the group.
	 *
	 * @param   StartIndex  Optional offset off the front of the array.
	 *                      Default value is `0`, or the beginning of the array.
	 * @param   Length      Optional restriction on the number of values you want to randomly select from.
	 * @return  A `Sprite` from the `members` list.
	 */
	public inline function getRandom(StartIndex:Int = 0, Length:Int = 0):T {
		return group.getRandom(StartIndex, Length);
	}

	/**
	 * Iterate through every member
	 *
	 * @return An iterator
	 */
	public inline function iterator(?filter:T->Bool):TypedGroupIterator<T> {
		return new TypedGroupIterator<T>(members, filter);
	}

	/**
	 * Applies a function to all members.
	 *
	 * @param   Function   A function that modifies one element at a time.
	 * @param   Recurse    Whether or not to apply the function to members of subgroups as well.
	 */
	public inline function forEach(Function:T->Void, Recurse:Bool = false):Void {
		group.forEach(Function, Recurse);
	}

	/**
	 * Applies a function to all `alive` members.
	 *
	 * @param   Function   A function that modifies one element at a time.
	 * @param   Recurse    Whether or not to apply the function to members of subgroups as well.
	 */
	public inline function forEachAlive(Function:T->Void, Recurse:Bool = false):Void {
		group.forEachAlive(Function, Recurse);
	}

	/**
	 * Applies a function to all dead members.
	 *
	 * @param   Function   A function that modifies one element at a time.
	 * @param   Recurse    Whether or not to apply the function to members of subgroups as well.
	 */
	public inline function forEachDead(Function:T->Void, Recurse:Bool = false):Void {
		group.forEachDead(Function, Recurse);
	}

	/**
	 * Applies a function to all members of type `Class<K>`.
	 *
	 * @param   ObjectClass   A class that objects will be checked against before Function is applied, ex: `Sprite`.
	 * @param   Function      A function that modifies one element at a time.
	 * @param   Recurse       Whether or not to apply the function to members of subgroups as well.
	 */
	public inline function forEachOfType<K>(ObjectClass:Class<K>, Function:K->Void, Recurse:Bool = false) {
		group.forEachOfType(ObjectClass, Function, Recurse);
	}

	/**
	 * Remove all instances of `Sprite` from the list.
	 * WARNING: does not `destroy()` or `kill()` any of these objects!
	 */
	public inline function clear():Void {
		group.clear();
	}

	/**
	 * Calls `kill()` on the group's members and then on the group itself.
	 * You can revive this group later via `revive()` after this.
	 */
	override public function kill():Void {
		_skipTransformChildren = true;
		super.kill();
		_skipTransformChildren = false;
		group.kill();
	}

	/**
	 * Revives the group.
	 */
	override public function revive():Void {
		_skipTransformChildren = true;
		super.revive(); // calls set_alive
		_skipTransformChildren = false;
		group.revive();
	}

	/**
	 * Helper function to set the coordinates of this object.
	 * Handy since it only requires one line of code.
	 *
	 * @param   X   The new x position
	 * @param   Y   The new y position
	 */
	override public function setPosition(X:Float = 0, Y:Float = 0):Void {
		// Transform children by the movement delta
		var dx:Float = X - x;
		var dy:Float = Y - y;
		multiTransformChildren([xTransform, yTransform], [dx, dy]);

		// don't transform children twice
		_skipTransformChildren = true;
		x = X; // this calls set_x
		y = Y; // this calls set_y
		_skipTransformChildren = false;
	}

	/**
	 * Handy function that allows you to quickly transform one property of sprites in this group at a time.
	 *
	 * @param   Function   Function to transform the sprites. Example:
	 *                     `function(sprite, v:Dynamic) { s.acceleration.x = v; s.makeGraphic(10,10,0xFF000000); }`
	 * @param   Value      Value which will passed to lambda function.
	 */
	@:generic
	public function transformChildren<V>(Function:T->V->Void, Value:V):Void {
		if (_skipTransformChildren || group == null)
			return;

		for (sprite in _sprites) {
			if (sprite != null)
				Function(cast sprite, Value);
		}
	}

	/**
	 * Handy function that allows you to quickly transform multiple properties of sprites in this group at a time.
	 *
	 * @param   FunctionArray   `Array` of functions to transform sprites in this group.
	 * @param   ValueArray      `Array` of values which will be passed to lambda functions
	 */
	@:generic
	public function multiTransformChildren<V>(FunctionArray:Array<T->V->Void>, ValueArray:Array<V>):Void {
		if (_skipTransformChildren || group == null)
			return;

		var numProps:Int = FunctionArray.length;
		if (numProps > ValueArray.length)
			return;

		var lambda:T->V->Void;
		for (sprite in _sprites) {
			if ((sprite != null) && sprite.alive) {
				for (i in 0...numProps) {
					lambda = FunctionArray[i];
					lambda(cast sprite, ValueArray[i]);
				}
			}
		}
	}

	// PROPERTIES GETTERS/SETTERS
	override function set_camera(Value:Camera):Camera {
		if (camera != Value)
			transformChildren(cameraTransform, Value);
		return super.set_camera(Value);
	}

	override function set_cameras(Value:Array<Camera>):Array<Camera> {
		if (cameras != Value)
			transformChildren(camerasTransform, Value);
		return super.set_cameras(Value);
	}

	override function set_visible(Value:Bool):Bool {
		if (alive && visible != Value)
			transformChildren(visibleTransform, Value);
		return super.set_visible(Value);
	}

	override function set_alive(Value:Bool):Bool {
		if (alive != Value)
			transformChildren(aliveTransform, Value);
		return super.set_alive(Value);
	}

	override function set_x(Value:Float):Float {
		return position.x = Value;
	}

	override function set_y(Value:Float):Float {
		return position.y = Value;
	}

	override function set_angle(Value:Float):Float {
		if (alive && angle != Value)
			transformChildren(angleTransform, Value - angle); // offset
		return angle = Value;
	}

	override function set_alpha(Value:Float):Float {
		Value = MathUtil.bound(Value, 0, 1);

		if (alive && alpha != Value) {
			var factor:Float = (alpha > 0) ? Value / alpha : 0;
			if (!directAlpha && alpha != 0)
				transformChildren(alphaTransform, factor);
			else
				transformChildren(directAlphaTransform, Value);
		}
		return alpha = Value;
	}

	override function set_facing(Value:Int):Int {
		if (alive && facing != Value)
			transformChildren(facingTransform, Value);
		return facing = Value;
	}

	override function set_flipX(Value:Bool):Bool {
		if (alive && flipX != Value)
			transformChildren(flipXTransform, Value);
		return flipX = Value;
	}

	override function set_flipY(Value:Bool):Bool {
		if (alive && flipY != Value)
			transformChildren(flipYTransform, Value);
		return flipY = Value;
	}

	override function set_moves(Value:Bool):Bool {
		if (alive && moves != Value)
			transformChildren(movesTransform, Value);
		return moves = Value;
	}

	override function set_immovable(Value:Bool):Bool {
		if (alive && immovable != Value)
			transformChildren(immovableTransform, Value);
		return immovable = Value;
	}

	override function set_color(Value:#if !macro Color #else Dynamic #end) {
        #if !macro
		if (alive && color != Value)
			transformChildren(gColorTransform, Value);
        #end
		return color = Value;
	}

	override function set_clipRect(rect:Point4D):Point4D {
		if (alive)
			transformChildren(clipRectTransform, rect);
		return super.set_clipRect(rect);
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	override function set_width(Value:Int):Int {
		return Value;
	}

	override function get_width():Int {
		if (length == 0)
			return 0;

		return Std.int(findMaxXHelper() - findMinXHelper());
	}

	/**
	 * Returns the left-most position of the left-most member.
	 * If there are no members, x is returned.
	 */
	public function findMinX() {
		return length == 0 ? x : findMinXHelper();
	}

	function findMinXHelper() {
		var value = Math.POSITIVE_INFINITY;
		for (member in _sprites) {
			if (member == null)
				continue;

			var minX:Float;
			if (member is TypedSpriteGroup)
				minX = (cast member : SpriteGroup).findMinX();
			else
				minX = member.x;

			if (minX < value)
				value = minX;
		}
		return value;
	}

	/**
	 * Returns the right-most position of the right-most member.
	 * If there are no members, x is returned.
	 */
	public function findMaxX() {
		return length == 0 ? x : findMaxXHelper();
	}

	function findMaxXHelper() {
		var value = Math.NEGATIVE_INFINITY;
		for (member in _sprites) {
			if (member == null)
				continue;

			var maxX:Float;
			if (member is TypedSpriteGroup)
				maxX = (cast member : SpriteGroup).findMaxX();
			else
				maxX = member.x + member.width;

			if (maxX > value)
				value = maxX;
		}
		return value;
	}

	/**
	 * This functionality isn't supported in SpriteGroup
	 */
	override function set_height(Value:Int):Int {
		return Value;
	}

	override function get_height():Int {
		if (length == 0)
			return 0;

		return Std.int(findMaxYHelper() - findMinYHelper());
	}

	/**
	 * Returns the top-most position of the top-most member.
	 * If there are no members, y is returned.
	 */
	public function findMinY() {
		return length == 0 ? y : findMinYHelper();
	}

	function findMinYHelper() {
		var value = Math.POSITIVE_INFINITY;
		for (member in _sprites) {
			if (member == null)
				continue;

			var minY:Float;
			if (member is SpriteGroup)
				minY = (cast member : SpriteGroup).findMinY();
			else
				minY = member.y;

			if (minY < value)
				value = minY;
		}
		return value;
	}

	/**
	 * Returns the top-most position of the top-most member.
	 * If there are no members, y is returned.
	 */
	public function findMaxY() {
		return length == 0 ? y : findMaxYHelper();
	}

	function findMaxYHelper() {
		var value = Math.NEGATIVE_INFINITY;
		for (member in _sprites) {
			if (member == null)
				continue;

			var maxY:Float;
			if (member is SpriteGroup)
				maxY = (cast member : SpriteGroup).findMaxY();
			else
				maxY = member.y + member.height;

			if (maxY > value)
				value = maxY;
		}
		return value;
	}

	// GROUP FUNCTIONS

	inline function get_length():Int {
		return group.length;
	}

	inline function get_maxSize():Int {
		return group.maxSize;
	}

	inline function set_maxSize(Size:Int):Int {
		return group.maxSize = Size;
	}

	inline function get_members():Array<T> {
		return group.members;
	}

	// TRANSFORM FUNCTIONS - STATIC TYPING

	inline function xTransform(Sprite:Sprite, X:Float)
		Sprite.x += X; // addition

	inline function yTransform(Sprite:Sprite, Y:Float)
		Sprite.y += Y; // addition

	inline function angleTransform(Sprite:Sprite, Angle:Float)
		Sprite.angle += Angle; // addition

	inline function alphaTransform(Sprite:Sprite, Alpha:Float) {
		if (Sprite.alpha != 0 || Alpha == 0)
			Sprite.alpha *= Alpha; // multiplication
		else
			Sprite.alpha = 1 / Alpha; // direct set to avoid stuck sprites
	}

	inline function directAlphaTransform(Sprite:Sprite, Alpha:Float)
		Sprite.alpha = Alpha; // direct set

	inline function facingTransform(Sprite:Sprite, Facing:Int)
		Sprite.facing = Facing;

	inline function flipXTransform(Sprite:Sprite, FlipX:Bool)
		Sprite.flipX = FlipX;

	inline function flipYTransform(Sprite:Sprite, FlipY:Bool)
		Sprite.flipY = FlipY;

	inline function movesTransform(Sprite:Sprite, Moves:Bool)
		Sprite.moves = Moves;

	inline function gColorTransform(Sprite:Sprite, Color:#if !macro Color #else Dynamic #end)
		Sprite.color = Color;

	inline function immovableTransform(Sprite:Sprite, Immovable:Bool)
		Sprite.immovable = Immovable;

	inline function visibleTransform(Sprite:Sprite, Visible:Bool)
		Sprite.visible = Visible;

	inline function aliveTransform(Sprite:Sprite, Alive:Bool)
		Sprite.alive = Alive;

	inline function cameraTransform(Sprite:Sprite, Camera:Camera)
		Sprite.camera = Camera;

	inline function camerasTransform(Sprite:Sprite, Cameras:Array<Camera>)
		Sprite.cameras = Cameras;

	inline function offsetTransform(Sprite:Sprite, Offset:Point2D)
		Sprite.offset.copyFrom(Offset);

	inline function originTransform(Sprite:Sprite, Origin:Point2D)
		Sprite.origin.copyFrom(Origin);

	inline function scaleTransform(Sprite:Sprite, Scale:Point2D)
		Sprite.scale.copyFrom(Scale);

	inline function scrollFactorTransform(Sprite:Sprite, ScrollFactor:Point2D)
		Sprite.scrollFactor.copyFrom(ScrollFactor);

	inline function clipRectTransform(Sprite:Sprite, ClipRect:Point4D) {
		if (ClipRect == null)
			Sprite.clipRect = null;
		else
			Sprite.clipRect = new Point4D(ClipRect.x - Sprite.x + x, ClipRect.y - Sprite.y + y, ClipRect.w, ClipRect.h);
	}

	inline function positionCallback(NewPosition:Point2D) {
		if (alive && position.x != NewPosition.x)
			transformChildren(xTransform, NewPosition.x - position.x); // offset

		if (alive && position.y != NewPosition.y)
			transformChildren(yTransform, NewPosition.y - position.y); // offset
	}

	inline function offsetCallback(Offset:Point2D)
		transformChildren(offsetTransform, Offset);

	inline function originCallback(Origin:Point2D)
		transformChildren(originTransform, Origin);

	inline function scaleCallback(Scale:Point2D)
		transformChildren(scaleTransform, Scale);

	inline function scrollFactorCallback(ScrollFactor:Point2D)
		transformChildren(scrollFactorTransform, ScrollFactor);
}
