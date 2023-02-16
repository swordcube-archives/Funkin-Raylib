package engine;

import engine.Vector2;

import Rl.Colors;
import Rl.Color;
import Rl.Texture2D;

class Sprite extends Object {
    public var texture:Texture2D;
    public var angle:Float = 0;
    public var scale:Float = 1;
    public var color:Color = Colors.WHITE;
    public var offset:Vector2 = new Vector2(0, 0);

    public function loadGraphic(path:String) {
        if(texture != null) {
            Rl.unloadTexture(texture);
            texture = null;
        }
        texture = Rl.loadTexture(path);
        return this;
    }

    override function update(elapsed:Float) {}

    override function draw() {
        Rl.drawTextureEx(texture, Rl.Vector2.create(position.x + offset.x, position.y + offset.y), angle, scale, color);
    }

    override function destroy() {
        Rl.unloadTexture(texture);
        texture = null;
        offset = null;
        super.destroy();
    }
}