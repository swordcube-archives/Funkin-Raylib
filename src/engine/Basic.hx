package engine;

import engine.interfaces.IBasic;

class Basic implements IBasic {
	public var ID:Int = 0;

	/**
	 * Whether or not this object is alive.
	 */
	public var alive(default, set):Bool = true;

	@:noCompletion
	private function set_alive(v:Bool):Bool {
		return alive = v;
	}

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
	 * Whether or not this object can draw to the screen.
	 */
	public var visible(default, set):Bool = true;

	@:noCompletion
	private function set_visible(v:Bool):Bool {
		return visible = v;
	}

	public function new() {}

	public function update(elapsed:Float) {}

	public function draw() {}

	public function kill() {
		alive = false;
	}

	public function revive() {
		alive = true;
	}

	public function destroy() {
		alive = false;
	}
}
