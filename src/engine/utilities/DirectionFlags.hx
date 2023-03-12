package engine.utilities;

import engine.math.AngleUtil;

/**
 * Uses bit flags to create a list of orthogonal directions.
 */
@:enum abstract DirectionFlags(Int) from Int from Direction to Int {
	var LEFT = 0x0001; // Direction.LEFT;
	var RIGHT = 0x0010; // Direction.RIGHT;
	var UP = 0x0100; // Direction.UP;
	var DOWN = 0x1000; // Direction.DOWN;

	/** Special-case constant meaning no directions. */
	var NONE = 0x0000;

	/** Special-case constant meaning "up". */
	var CEILING = 0x0100; // UP;

	/** Special-case constant meaning "down" */
	var FLOOR = 0x1000; // DOWN;

	/** Special-case constant meaning "left" and "right". */
	var WALL = 0x0011; // LEFT | RIGHT;

	/** Special-case constant meaning any, or all directions. */
	var ANY = 0x1111; // LEFT | RIGHT | UP | DOWN;

	/**
	 * Calculates the angle (in degrees) of the facing flags.
	 * Returns 0 if two opposing flags are true.
	 */
	public var degrees(get, never):Float;

	function get_degrees():Float {
		return switch (this) {
			case RIGHT: 0;
			case DOWN: 90;
			case UP: -90;
			case LEFT: 180;
			case f if (f == DOWN | RIGHT): 45;
			case f if (f == DOWN | LEFT): 135;
			case f if (f == UP | RIGHT): -45;
			case f if (f == UP | LEFT): -135;
			default: 0;
		}
	}

	/**
	 * Calculates the angle (in radians) of the facing flags.
	 * Returns 0 if two opposing flags are true.
	 */
	public var radians(get, never):Float;

	inline function get_radians():Float {
		return degrees * AngleUtil.TO_RAD;
	}

	/**
	 * Returns true if this contains **all** of the supplied flags.
	 */
	public inline function has(dir:DirectionFlags):Bool {
		return this & dir == dir;
	}

	/**
	 * Returns true if this contains **any** of the supplied flags.
	 */
	public inline function hasAny(dir:DirectionFlags):Bool {
		return this & dir > 0;
	}

	/**
	 * Creates a new `Directions` that includes the supplied directions.
	 */
	public inline function with(dir:DirectionFlags):DirectionFlags {
		return this | dir;
	}

	/**
	 * Creates a new `Directions` that excludes the supplied directions.
	 */
	public inline function without(dir:DirectionFlags):DirectionFlags {
		return this & ~dir;
	}

	public function toString() {
		if (this == NONE)
			return "NONE";

		var str = "";
		if (has(LEFT))
			str += " | L";
		if (has(RIGHT))
			str += " | R";
		if (has(UP))
			str += " | U";
		if (has(DOWN))
			str += " | D";

		// remove the first " | "
		return str.substr(3);
	}

	/**
	 * Generates a DirectionFlags instance from 4 bools
	 */
	public static function fromBools(left:Bool, right:Bool, up:Bool, down:Bool):DirectionFlags {
		return (left ? LEFT : NONE) | (right ? RIGHT : NONE) | (up ? UP : NONE) | (down ? DOWN : NONE);
	}

	// Expose int operators
	@:op(A & B) static function and(a:DirectionFlags, b:DirectionFlags):DirectionFlags;

	@:op(A | B) static function or(a:DirectionFlags, b:DirectionFlags):DirectionFlags;

	@:op(A > B) static function gt(a:DirectionFlags, b:DirectionFlags):Bool;

	@:op(A < B) static function lt(a:DirectionFlags, b:DirectionFlags):Bool;

	@:op(A >= B) static function gte(a:DirectionFlags, b:DirectionFlags):Bool;

	@:op(A <= B) static function lte(a:DirectionFlags, b:DirectionFlags):Bool;
}
