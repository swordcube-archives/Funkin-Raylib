package engine;

class Object extends Basic {
	/**
	 * Whether or not this object is movable.
	 */
	public var immovable:Bool = false;

	/**
	 * The X and Y position of the object.
	 */
	public var position:Point2D = new Point2D(0, 0);

	/**
	 * The basic speed of this object (in pixels per second).
	 */
	public var velocity:Point2D = new Point2D(0, 0);

	/**
	 * How fast the speed of this object is changing (in pixels per second).
	 * Useful for smooth movement and gravity.
	 */
	public var acceleration:Point2D = new Point2D(0, 0);

	/**
	 * This isn't drag exactly, more like deceleration that is only applied
	 * when `acceleration` is not affecting the sprite.
	 */
	public var drag:Point2D = new Point2D(0, 0);

	/**
	 * If you are using `acceleration`, you can use `maxVelocity` with it
	 * to cap the speed automatically (very useful!).
	 */
	public var maxVelocity:Point2D = new Point2D(0, 0);

	/**
	 * This is how fast you want this sprite to spin (in degrees per second).
	 */
	public var angularVelocity:Float = 0;

	/**
	 * How fast the spin speed should change (in degrees per second).
	 */
	public var angularAcceleration:Float = 0;

	/**
	 * Like drag but for spinning.
	 */
	public var angularDrag:Float = 0;

	/**
	 * Use in conjunction with angularAcceleration for fluid spin speed control.
	 */
	public var maxAngular:Float = 10000;

	/**
	 * The X position of the object.
	 * Shortcut to `position.x`.
	 */
	public var x(get, set):Float;

	private function get_x():Float {
		return position.x;
	}

	private function set_x(v:Float):Float {
		return position.x = v;
	}

	/**
	 * The Y position of the object.
	 * Shortcut to `position.y`.
	 */
	public var y(get, set):Float;

	private function get_y():Float {
		return position.y;
	}

	private function set_y(v:Float):Float {
		return position.y = v;
	}

	/**
	 * A helper function to set the X and Y position of the sprite.
	 * @param x The X position to use.
	 * @param y The Y position to use.
	 */
	public function setPosition(?x:Float = 0, ?y:Float = 0) {
		position.set(x, y);
	}

	public function new(?x:Float = 0, ?y:Float = 0) {
        super();
		position.set(x, y);
	}

    public var angle:Float = 0;

	override function update(elapsed:Float) {
        updateMotion(elapsed);
    }

	/**
	 * Internal function for updating the position and speed of this object.
	 * Useful for cases when you need to update this but are buried down in too many supers.
	 * Does a slightly fancier-than-normal integration to help with higher fidelity framerate-independent motion.
	 */
	@:noCompletion
	function updateMotion(elapsed:Float):Void {
		if (position == null) return;

		var velocityDelta = 0.5 * (VelocityUtil.computeVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngular, elapsed) - angularVelocity);
		angularVelocity += velocityDelta;
		angle += angularVelocity * elapsed;
		angularVelocity += velocityDelta;

		velocityDelta = 0.5 * (VelocityUtil.computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x, elapsed) - velocity.x);
		velocity.x += velocityDelta;
		var delta = velocity.x * elapsed;
		velocity.x += velocityDelta;
		position.x += delta;

		velocityDelta = 0.5 * (VelocityUtil.computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y, elapsed) - velocity.y);
		velocity.y += velocityDelta;
		delta = velocity.y * elapsed;
		velocity.y += velocityDelta;
		position.y += delta;
	}
    
	override function destroy() {
		position = null;
        super.destroy();
	}
}
