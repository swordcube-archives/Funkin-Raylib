package engine.tweens.misc;

import engine.tweens.Tween;
import engine.utilities.ColorUtil;

#if !macro
import engine.Sprite;
import Rl.Color;
#else
typedef Color = Dynamic;
#end

/**
 * Tweens a color's red, green, and blue properties
 * independently. Can also tween an alpha value.
 */
class ColorTween extends Tween {
	public var color(default, null):Color;

	var startColor:Color;
	var endColor:Color;

	/**
	 * Optional sprite object whose color to tween
	 */
	public var sprite(default, null):#if !macro Sprite #else Dynamic #end;

	/**
	 * Clean up references
	 */
	override public function destroy() {
		super.destroy();
		sprite = null;
	}

	/**
	 * Tweens the color to a new color and an alpha to a new alpha.
	 *
	 * @param	Duration		Duration of the tween.
	 * @param	FromColor		Start color.
	 * @param	ToColor			End color.
	 * @param	Sprite			Optional sprite object whose color to tween.
	 * @return	The ColorTween.
	 */
	public function tween(Duration:Float, FromColor:Color, ToColor:Color, ?Sprite:#if !macro Sprite #else Dynamic #end):ColorTween {
		color = startColor = FromColor;
		endColor = ToColor;
		duration = Duration;
		sprite = Sprite;
		start();
		return this;
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		color = ColorUtil.interpolate(startColor, endColor, scale);

		if (sprite != null) {
			sprite.color = color;
			sprite.alpha = color.a / 255;
		}
	}

	override function isTweenOf(object:Dynamic, ?field:String):Bool {
		return sprite == object && (field == null || field == "color");
	}
}
