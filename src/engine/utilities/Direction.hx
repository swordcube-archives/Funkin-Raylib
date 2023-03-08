package engine.utilities;

/**
 * Simple enum for orthogonal directions. Can be combined into `DirectionFlags`.
 */
enum abstract Direction(Int) to Int {
	var LEFT = 0x0001;
	var RIGHT = 0x0010;
	var UP = 0x0100;
	var DOWN = 0x1000;

	public function toString() {
		return switch (cast this : Direction) {
			case LEFT: "L";
			case RIGHT: "R";
			case UP: "U";
			case DOWN: "D";
		}
	}
}
