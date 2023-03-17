package engine.gui;

import engine.math.MathUtil;
#if !macro
import Rl.RenderTexture2D;
import Rl.Texture2D;
#end

import engine.utilities.Color;
import engine.utilities.ColorUtil;

/**
 * A simple bar that can be used to indicate health, loading, or other stats!
 * 
 * This is meant to make ***simple bars*** only though.
 */
class ProgressBar extends Sprite {
    public var fillDirection:ProgressBarFillDirection = LEFT_TO_RIGHT;

    public var emptyColor:Color;
    public var fillColor:Color;

    public var barWidth:Int = 100;
    public var barHeight:Int = 10;

    public var value:Float = 0;

    /**
     * The percent that this bar is at.
     */
    public var percent(default, set):Float = 0;

    @:noCompletion
    private function set_percent(v:Float):Float {
        return percent = MathUtil.bound(v, 0, 100);
    }

    public var minimum:Float = 0;
    public var maximum:Float = 0;

    public var parent:Dynamic;
    public var parentVariable:String;

    private var __renderTex:#if !macro RenderTexture2D #else Dynamic #end;

    public function new(x:Float = 0, y:Float = 0, ?direction:ProgressBarFillDirection = LEFT_TO_RIGHT, width:Int = 100, height:Int = 10, ?parentRef:Dynamic, variable:String = "", min:Float = 0, max:Float = 100) {
        super(x, y);
        #if !macro
        barWidth = width;
        barHeight = height;
        fillDirection = direction;

        setRange(min, max);
        setParent(parentRef, variable);

        __renderTex = Rl.loadRenderTexture(width, height);

        createFilledBar(ColorUtil.fromHexString("#005100"), ColorUtil.fromHexString("#00F400"));
        #end
    }

	/**
	 * Sets a parent for this ProgressBar. Instantly replaces any previously set parent and refreshes the bar.
	 *
	 * @param	parentRef	A reference to an object in your game that you wish the bar to track
	 * @param	variable	The variable of the object that is used to determine the bar position. For example if the parent was an Sprite this could be "health" to track the health value
	 */
    public function setParent(parentRef:Dynamic, variable:String):Void {
        parent = parentRef;
        parentVariable = variable;
        updateValueFromParent();
    }

    /**
     * Sets the minimum and maximum values that this bar is allowed to go to.
     * @param min The minimum value for this bar
     * @param max The maximum value for this bar
     */
    public function setRange(min:Float, max:Float) {
        minimum = min;
        maximum = max;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(parent != null && parentVariable != null && parentVariable.length > 0)
            updateValueFromParent();
    }

    public function updateValueFromParent() {
        value = MathUtil.bound(Reflect.getProperty(parent, parentVariable), minimum, maximum);
        percent = (value / maximum) * 100;
    }

    public function createFilledBar(empty:Color, fill:Color) {
        emptyColor = empty;
        fillColor = fill;
    }

    override function draw() {
        #if !macro
        var bullShit:Texture2D = cast(__renderTex.texture);
        bullShit.width = barWidth;
        bullShit.height = barHeight;

        Rl.endTextureMode();
        Rl.beginTextureMode(__renderTex);

        Rl.drawRectangle(
            0,
            0,
            barWidth,
            barHeight,
            emptyColor
        );

        switch(fillDirection) {
            case RIGHT_TO_LEFT:
                var widthShit:Int = Std.int(barWidth * (percent / 100));
                Rl.drawRectangle(
                    widthShit,
                    0,
                    widthShit,
                    barHeight,
                    fillColor
                );
            
            case TOP_TO_BOTTOM:
                Rl.drawRectangle(
                    0,
                    0,
                    barWidth,
                    Std.int(barHeight * (percent / 100)),
                    fillColor
                );

            case BOTTOM_TO_TOP:
                var heightShit:Int = Std.int(barHeight * (percent / 100));
                Rl.drawRectangle(
                    0,
                    heightShit,
                    barWidth,
                    heightShit,
                    fillColor
                );

            default: // LEFT_TO_RIGHT
                Rl.drawRectangle(
                    0,
                    0,
                    Std.int(barWidth * (percent / 100)),
                    barHeight,
                    fillColor
                );
        }

        Rl.endTextureMode();

        @:privateAccess
        Rl.beginTextureMode(Game.renderTex);

        var bullShit:Texture2D = cast(__renderTex.texture);
        texture = bullShit;
        #end
        super.draw();
    }
}

enum abstract ProgressBarFillDirection(Int) to Int from Int {
	var LEFT_TO_RIGHT = 0;
	var RIGHT_TO_LEFT = 1;
	var TOP_TO_BOTTOM = 2;
	var BOTTOM_TO_TOP = 3;
}
