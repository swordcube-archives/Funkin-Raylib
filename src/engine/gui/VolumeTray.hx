package engine.gui;

import engine.math.MathUtil;
import engine.keyboard.Keys;
import Rl.Font;
import Rl.Color;
import Rl.Colors;

enum abstract VolumeStatus(Int) to Int from Int {
    var UP = 0;
    var DOWN = 1;
    var MUTE = 2;
    var UNMUTE = 3;
}

class VolumeTray extends Object {
    private var __globalVolume:Int = Std.int(Game.sound.volume * 10);
    private var __timer:Float = 0;

    public var volumeDownSound:String = "engine/beep";
    public var volumeUpSound:String = "engine/beep";
    public var muteSound:String = "engine/beep";
    public var unmuteSound:String = "engine/beep";

    public var volumeDownKeys:Array<Int> = [Keys.MINUS, Keys.NUMPAD_MINUS];
    public var volumeUpKeys:Array<Int> = [Keys.PLUS, Keys.NUMPAD_PLUS];
    public var muteKeys:Array<Int> = [Keys.ZERO, Keys.NUMPAD_ZERO];

    public var font:Font = Rl.loadFont(Paths.font("nokiafc22.ttf"));
    public var scale:Float = 2;
    
    // note to self: alpha is an INT from 0 - 255
    // this is 0.7 * 255
    public var boxColor:Color = Color.create(0, 0, 0, 178);
    public var boxSize:Point2D = new Point2D(80, 30);

    public var active = false;

    public function new() {
        super();
        position.set(0, -boxSize.y * scale);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Game.keys.anyJustPressed(volumeUpKeys)) {
            Game.sound.muted = false;
            Game.sound.volume = MathUtil.roundDecimal(MathUtil.bound(Game.sound.volume + 0.1, 0, 1), 1);
            show(UP);
        }

        if(Game.keys.anyJustPressed(volumeDownKeys)) {
            Game.sound.muted = false;
            Game.sound.volume = MathUtil.roundDecimal(MathUtil.bound(Game.sound.volume - 0.1, 0, 1), 1);
            show(DOWN);
        }

        if(Game.keys.anyJustPressed(muteKeys)) {
            Game.sound.muted = !Game.sound.muted;
            show((Game.sound.muted) ? MUTE : UNMUTE);
        }

        if(!active) return;

		if (__timer > 0)
            __timer -= elapsed;
        else if (position.y > (-boxSize.y * scale)) {
            position.y -= (elapsed) * Game.height * 2;

            if (position.y <= (-boxSize.y * scale))
                active = false;
        }
    }

    public function show(?volumeStatus:VolumeStatus) {
        __timer = 1;
        position.y = 0;
        active = true;

        switch(volumeStatus) {
            case UP:        Game.sound.play(Paths.sound("engine/beep"));
            case DOWN:      Game.sound.play(Paths.sound("engine/beep"));
            case MUTE:      Game.sound.play(Paths.sound("engine/beep"));
            case UNMUTE:    Game.sound.play(Paths.sound("engine/beep"));
        }
        __globalVolume = Std.int(Game.sound.volume * 10);
    }

    override function draw() {
        var boxX:Float = ((Rl.getScreenWidth() - (boxSize.x * scale)) * 0.5) + position.x;
        var boxY:Float = position.y;

        Rl.drawRectangle(Std.int(boxX), Std.int(boxY), Std.int(boxSize.x * scale), Std.int(boxSize.y * scale), boxColor);
        Rl.drawTextEx(font, "VOLUME", Rl.Vector2.create(boxX + (16 * scale), boxY + (18 * scale)), 12.5 * scale, 0, Colors.WHITE);

        var bx:Int = 5;
        var by:Int = 2;
        for(i in 0...10) {
            var color:Color = Color.create(255, 255, 255, (i < __globalVolume && !Game.sound.muted) ? 255 : 128);
            Rl.drawRectangle(Std.int((boxX + (5 * scale)) + (bx * scale)), Std.int((boxY + (13 * scale)) - (i * scale)), Std.int(4 * scale), Std.int(by * scale), color);
            bx += 6;
            by++;
        }
    }
}