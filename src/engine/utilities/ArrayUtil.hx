package engine.utilities;

class ArrayUtil {
	/**
	 * Gets the last item of an array and returns it.
	 * @param array The array to get the item from.
	 */
	public inline static function last<T>(array:Array<T>):T {
		return array[array.length - 1];
	}
}