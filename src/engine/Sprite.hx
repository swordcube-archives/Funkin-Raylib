package engine;

import engine.utilities.Axes;
import engine.utilities.FrameData;
import engine.utilities.Animation;
import engine.Vector2;

#if !macro
import Rl.Colors;
import Rl.Color;
import Rl.Texture2D;

class Sprite extends Object {
    public var frames:Map<String, Array<FrameData>> = [];
    public var animation:Animation = new Animation();
    public var texture:Texture2D;

    public var angle:Float = 0;
    public var scale:Vector2 = new Vector2(1, 1);

    public var color:Color = Colors.WHITE;
    public var alpha:Float = 1;

    public var origin:Vector2 = new Vector2(0, 0);
    public var offset:Vector2 = new Vector2(0, 0);

    public var frameWidth:Int = 0;
    public var frameHeight:Int = 0;

    public var width:Int = 0;
    public var height:Int = 0;

    public function loadGraphic(path:String) {
        if(texture != null) {
            Rl.unloadTexture(texture);
            texture = null;
        }
        texture = Rl.loadTexture(path);
        frameWidth = texture.width;
        frameHeight = texture.height;
        updateHitbox();
        return this;
    }

    public function updateHitbox() {
        width = Std.int(frameWidth * scale.x);
        height = Std.int(frameHeight * scale.y);
        centerOrigin();
    }

    public function centerOrigin() {
        origin.set(width * 0.5, height * 0.5);
    }

    public function screenCenter(?axes:Axes = XY) {
        if(axes.x)
            position.x = (Game.width - width) * 0.5;

        if(axes.y)
            position.y = (Game.height - height) * 0.5;

        return this;
    }

    public function makeGraphic(width:Int, height:Int, color:Color) {
        texture = Rl.loadTextureFromImage(Rl.genImageColor(width, height, color));
        frameWidth = texture.width;
        frameHeight = texture.height;
        updateHitbox();
        return this;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    override function draw() {
        var x:Float = (position.x + offset.x);
        var y:Float = (position.y + offset.y);

        color.a = Std.int(alpha * 255);
        texture.width = width;
        texture.height = height;
        Rl.drawTexturePro(texture, Rl.Rectangle.create(0, 0, width, height), Rl.Rectangle.create(x + origin.x, y + origin.y, width, height), Rl.Vector2.create(origin.x, origin.y), angle, color);
    }

    override function destroy() {
        Rl.unloadTexture(texture);
        texture = null;
        offset = null;
        super.destroy();
    }
}
#end