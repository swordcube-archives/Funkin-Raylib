package engine.math;

class Point2D {
	public var x:Float;
	public var y:Float;

	public function new(?x:Float = 0, ?y:Float = 0) {
		set(x, y);
	}

	public function set(?x:Float = 0, ?y:Float = 0) {
		this.x = x;
		this.y = y;
	}

	public function add(?x:Float = 0, ?y:Float = 0) {
		this.x += x;
		this.y += y;
	}

	public function substract(?x:Float = 0, ?y:Float = 0) {
		this.x -= x;
		this.y -= y;
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
	public inline function setPolarDegrees(length:Float, degrees:Float) {
        // i  am fucking dying
        #if !macro
		return setPolarRadians(length, degrees * AngleUtil.TO_RAD);
        #else
        return this;
        #end
	}
}
