package engine.graphics;

/**
 * A list of Blend Modes from Raylib
 */
enum abstract BlendMode(Int) to Int from Int {
    var ALPHA:Int = 0;
    var ADD:Int = 1;
    var MULTIPLY:Int = 2;
    var ADD_ALT:Int = 3;
    var SUBTRACT:Int = 4;

    var CUSTOM:Int = 5;
    var CUSTOM_SEPARATE:Int = 6;
}