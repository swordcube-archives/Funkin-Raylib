package engine.utilities;

class ColorUtil {
	public static var COLOR_REGEX = ~/^(0x|#)(([A-F0-9]{2}){3,4})$/i;

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

	/**
	 * Returns a new `Color` instance from a hex string.
	 * 
	 * The string can be formatted like so:
	 * 
	 * - `#FFFFFF`    -> `(255, 255, 255)`
	 * - `0x6bfc03` -> `(107, 252, 3)`
	 * 
	 * @param hex The string to convert to a color.
	 */
	public static function fromHexString(hex:String) {
		// Make sure the hex string is just formatted as something like
		// "FFFFFF" or "6bfc03"
		hex = hex.replace("#", "").replace("0x", "");

		// Get the RGB values from the hex value
		var r = Std.parseInt("0x" + hex.substr(0, 2));
		var g = Std.parseInt("0x" + hex.substr(2, 2));
		var b = Std.parseInt("0x" + hex.substr(4, 2));

		// If any of the values are `null`, they get set to 0.
		if(r == null) r = 0;
		if(g == null) g = 0;
		if(b == null) b = 0;

		return Color.create(r, g, b, 255);
	}
}
