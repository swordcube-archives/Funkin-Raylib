package engine.math;

class Point2D {
	// These setter functions are needed for CallbackPoint2D!
	public var x(default, set):Float;
	private function set_x(v:Float):Float {
		return x = v;
	}

	public var y(default, set):Float;
	private function set_y(v:Float):Float {
		return y = v;
	}

	public function new(x:Float = 0, y:Float = 0) {
		set(x, y);
	}

	public function set(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
		return this;
	}

	public function add(x:Float = 0, y:Float = 0) {
		this.x += x;
		this.y += y;
		return this;
	}

	public function subtract(x:Float = 0, y:Float = 0) {
		this.x -= x;
		this.y -= y;
		return this;
	}

	/**
	 * Sets the polar coordinates of the point
	 *
	 * @param   length   The length to set the point
	 * @param   radians  The angle to set the point, in radians
	 * @return  The rotated point
	 */
	public function setPolarRadians(length:Float, radians:Float) {
		x = length * Math.cos(radians);
		y = length * Math.sin(radians);
		return this;
	}

	/**
	 * Sets the polar coordinates of the point
	 *
	 * @param   length  The length to set the point
	 * @param   degrees The angle to set the point, in degrees
	 * @return  The rotated point
	 */
	public function setPolarDegrees(length:Float, degrees:Float) {
        // i  am fucking dying
        #if !macro
		return setPolarRadians(length, degrees * AngleUtil.TO_RAD);
        #else
        return this;
        #end
	}

	/**
	 * Copies the X and Y from another point into this point.
	 * @param point The point to copy from.
	 */
	public function copyFrom(point:Point2D) {
        set(point.x, point.y);
		return this;
    }
}
