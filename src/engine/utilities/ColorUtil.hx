package engine.utilities;

#if !macro
import Rl.Color;
#else
typedef Color = Dynamic;
#end

class ColorUtil {
	/**
	 * Get an interpolated color based on two different colors.
	 *
	 * @param 	color1 The first color
	 * @param 	color2 The second color
	 * @param 	factor Value from 0 to 1 representing how much to shift color1 toward color2
	 * @return	The interpolated color
	 */
	public static inline function interpolate(color1:Color, color2:Color, factor:Float = 0.5):Color {
		#if !macro
		var r:Int = Std.int((color2.r - color1.r) * factor + color1.r);
		var g:Int = Std.int((color2.g - color1.g) * factor + color1.g);
		var b:Int = Std.int((color2.b - color1.b) * factor + color1.b);
		var a:Int = Std.int((color2.a - color1.a) * factor + color1.a);

		return Color.create(r, g, b, a);
		#else
		return null;
		#end
	}
}
