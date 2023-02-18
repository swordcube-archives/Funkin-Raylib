package engine.tweens.motion;

import engine.Object;
import engine.tweens.Tween;

/**
 * Base class for motion Tweens.
 */
class Motion extends Tween {
	/**
	 * Current x position of the Tween.
	 */
	public var x:Float = 0;

	/**
	 * Current y position of the Tween.
	 */
	public var y:Float = 0;

	var _object:Object;
	var _wasObjectImmovable:Bool;

	override public function destroy():Void {
		super.destroy();
		_object = null;
	}

	public function setObject(object:Object):Motion {
		_object = object;
		_wasObjectImmovable = _object.immovable;
		_object.immovable = true;
		return this;
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		postUpdate();
	}

	override function onEnd():Void {
		_object.immovable = _wasObjectImmovable;
		super.onEnd();
	}

	function postUpdate():Void {
		if (_object != null) {
			_object.position.set(x, y);
		}
	}

	override function isTweenOf(object:Dynamic, ?field:String):Bool {
		return _object == object && (field == null || field == "x" || field == "y");
	}
}
