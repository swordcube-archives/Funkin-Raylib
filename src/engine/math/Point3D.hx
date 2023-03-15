package engine.math;

class Point3D {
    public var x:Float;
    public var y:Float;
    public var z:Float;

    public function new(?x:Float = 0, ?y:Float = 0, ?z:Float = 0) {
        set(x, y, z);
    }

    public function set(?x:Float = 0, ?y:Float = 0, ?z:Float = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function add(?x:Float = 0, ?y:Float = 0, ?z:Float = 0) {
        this.x += x;
        this.y += y;
        this.z += z;
    }

    public function subtract(?x:Float = 0, ?y:Float = 0, ?z:Float = 0) {
        this.x -= x;
        this.y -= y;
        this.z -= z;
    }

    /**
	 * Copies the X, Y, and Z from another point into this point.
	 * @param point The point to copy from.
	 */
	public function copyFrom(point:Point3D) {
        set(point.x, point.y, point.z);
		return this;
    }
}