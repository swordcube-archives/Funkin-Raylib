package engine;

import engine.math.Point2D;
import engine.math.VelocityUtil;

/**
 * The base object that classes like `Sprite`, `Group`, `Camera`, and more are based on.
 * Provides camera variables, velocity, update and draw functions
 */
class Object extends Basic {
	/**
	 * The first camera this object can draw to.
	 */
	public var camera(get, set):Camera;

	/**
	 * The list of every camera this object can draw to.
	 */
	public var cameras(get, set):Array<Camera>;

	private var _camera:Camera;
	private var _cameras:Array<Camera>;

	@:noCompletion
	function get_camera():Camera {
		return (_cameras == null || _cameras.length == 0) ? Camera.defaultCameras[0] : _cameras[0];
	}

	@:noCompletion
	function set_camera(Value:Camera):Camera {
		if (_cameras == null)
			_cameras = [Value];
		else
			_cameras[0] = Value;
		return Value;
	}

	@:noCompletion
	function get_cameras():Array<Camera> {
		return (_cameras == null) ? Camera.defaultCameras : _cameras;
	}

	@:noCompletion
	function set_cameras(Value:Array<Camera>):Array<Camera> {
		return _cameras = Value;
	}

	/**
	 * Whether or not this object is movable.
	 */
	public var immovable:Bool = false;

	/**
	 * Whether or not this object gets affected by velocity.
	 * Set this to `false` for a small performance boost.
	 */
	public var moves:Bool = true;

	/**
	 * Whether or not this object can draw to the screen.
	 */
	public var visible:Bool = true;

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

	@:noCompletion
	private function get_x():Float {
		return position.x;
	}

	@:noCompletion
	private function set_x(v:Float):Float {
		return position.x = v;
	}

	/**
	 * The Y position of the object.
	 * Shortcut to `position.y`.
	 */
	public var y(get, set):Float;

	@:noCompletion
	private function get_y():Float {
		return position.y;
	}

	@:noCompletion
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

	/**
	 * How much the object should rotate when shown on screen. (in degrees)
	 */
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
		if(position == null || !moves) return;

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
