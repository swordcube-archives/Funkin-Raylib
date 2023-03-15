package engine.math;

/**
 * A Point2D that calls a function when set_x(), set_y() or set() is called. Used in SpriteGroup.
 * IMPORTANT: Calling set(x, y); is MUCH FASTER than setting x and y separately. Needs to be destroyed unlike simple Point2Ds!
 */
class CallbackPoint2D extends Point2D {
	var _setXCallback:Point2D->Void;
	var _setYCallback:Point2D->Void;
	var _setXYCallback:Point2D->Void;

	var _preSetXCallback:Point2D->Void;
	var _preSetYCallback:Point2D->Void;
	var _preSetXYCallback:Point2D->Void;

	public function new(setXCallback:Point2D->Void, ?setYCallback:Point2D->Void, ?setXYCallback:Point2D->Void) {
		super();

		_setXCallback = setXCallback;
		_setYCallback = setXYCallback;
		_setXYCallback = setXYCallback;

		if (_setXCallback != null) {
			if (_setYCallback == null)
				_setYCallback = setXCallback;
			if (_setXYCallback == null)
				_setXYCallback = setXCallback;
		}

		_preSetXCallback = _setXCallback;
		_preSetYCallback = _setYCallback;
		_preSetXYCallback = _setXYCallback;
	}

	/**
	 * Sets the polar coordinates of the point
	 *
	 * @param   length   The length to set the point
	 * @param   radians  The angle to set the point, in radians
	 * @return  The rotated point
	 */
	override function setPolarRadians(length:Float, radians:Float) {
		setPolarRadians(length, radians);
		return this;
	}

	/**
	 * Sets the polar coordinates of the point
	 *
	 * @param   length  The length to set the point
	 * @param   degrees The angle to set the point, in degrees
	 * @return  The rotated point
	 */
	override function setPolarDegrees(length:Float, degrees:Float) {
		setPolarDegrees(length, degrees);
		return this;
	}

	/**
	 * Copies the X and Y from another point into this point.
	 * @param point The point to copy from.
	 */
	override function copyFrom(point:Point2D) {
		super.copyFrom(point);
		return this;
	}

	override public function set(x:Float = 0, y:Float = 0):CallbackPoint2D {
		if (_preSetXYCallback != null)
			_preSetXYCallback(new Point2D(x, y));
		super.set(x, y);
		if (_setXYCallback != null)
			_setXYCallback(this);
		return this;
	}

	override function set_x(value:Float):Float {
		if (_preSetXCallback != null)
			_preSetXCallback(new Point2D(value, y));
		super.set_x(value);
		if (_setXCallback != null)
			_setXCallback(this);
		return value;
	}

	override function set_y(value:Float):Float {
		if (_preSetYCallback != null)
			_preSetYCallback(new Point2D(x, value));
		super.set_y(value);
		if (_setYCallback != null)
			_setYCallback(this);
		return value;
	}
}
