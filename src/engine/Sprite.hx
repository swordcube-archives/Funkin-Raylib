package engine;

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

    public var offset:Vector2 = new Vector2(0, 0);
    public var width:Int = 0;
    public var height:Int = 0;

    private var __usedMakeGraphic:Bool = false;
    private var __rectColor:Color = Colors.WHITE;

    public function loadGraphic(path:String) {
        __usedMakeGraphic = false;
        if(texture != null) {
            Rl.unloadTexture(texture);
            texture = null;
        }
        texture = Rl.loadTexture(path);
        width = texture.width;
        height = texture.height;
        return this;
    }

    public function makeGraphic(width:Int, height:Int, color:Color) {
        this.width = width;
        this.height = height;
        __usedMakeGraphic = true;
        __rectColor = color;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    override function draw() {
        color.a = Std.int(alpha * 255);
        if(__usedMakeGraphic) 
            Rl.drawRectangle(Std.int(position.x + offset.x), Std.int(position.y + offset.y), Std.int(width * scale.x), Std.int(height * scale.y), __rectColor);
        else {
            texture.width = Std.int(width * scale.x);
            texture.height = Std.int(height * scale.y);
            Rl.drawTextureEx(texture, Rl.Vector2.create(position.x + offset.x, position.y + offset.y), angle, 1, color);
        }
    }

    override function destroy() {
        Rl.unloadTexture(texture);
        texture = null;
        offset = null;
        super.destroy();
    }
}
#end