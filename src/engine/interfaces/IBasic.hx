package engine.interfaces;

interface IBasic extends IDestroyable {
    public var ID:Int;

	/**
	 * Whether or not this object is alive.
	 */
	public var alive:Bool;

	public function update(elapsed:Float):Void;
	public function draw():Void;

	public function kill():Void;
	public function revive():Void;
}