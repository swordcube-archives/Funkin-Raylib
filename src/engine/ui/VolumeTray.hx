package engine.ui;

import engine.keyboard.KeyCode;
import engine.keyboard.Keys;
import Rl.Font;
import Rl.Color;
import Rl.Colors;

class VolumeTray extends Object {
    public var volumeDownKeys:Array<KeyCode> = [Keys.MINUS];
    public var volumeUpKeys:Array<KeyCode> = [Keys.EQUAL];

    public var font:Font = Rl.loadFont(Paths.font("nokiafc22.ttf"));
    public var scale:Float = 2;
    
    // note to self: alpha is an INT from 0 - 255
    // this is 0.7 * 255
    public var boxColor:Color = Color.create(0, 0, 0, 178);
    public var boxSize:Vector2 = new Vector2(80, 30);

    public var offset:Vector2 = new Vector2(0, 0);

    var _timer:Float;

    public function new() {
        super();
        offset.set(0, -boxSize.y * scale);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Game.keys.anyJustPressed(volumeDownKeys)) {
            offset.y = 0;
        }
    }

    override function draw() {
        var boxX:Float = ((Rl.getScreenWidth() - (boxSize.x * scale)) * 0.5) + offset.x;
        var boxY:Float = offset.y;

        Rl.drawRectangle(Std.int(boxX), Std.int(boxY), Std.int(boxSize.x * scale), Std.int(boxSize.y * scale), boxColor);
        Rl.drawTextEx(font, "VOLUME", Rl.Vector2.create(boxX + (16 * scale), boxY + (18 * scale)), 12.5 * scale, 0, Colors.WHITE);

        var bx:Int = 5;
        var by:Int = 2;
        for(i in 0...10) {
            var color:Color = Color.create(255, 255, 255, 255);
            Rl.drawRectangle(Std.int((boxX + (5 * scale)) + (bx * scale)), Std.int((boxY + (13 * scale)) - (i * scale)), Std.int(4 * scale), Std.int(by * scale), color);
            bx += 6;
            by++;
        }
    }
}