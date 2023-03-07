package funkin.objects.ui;

import engine.Group.TypedGroup;

typedef DirectionData = {
    var directions:Array<String>;
    @:optional var scaleMult:Float;
    @:optional var spacingMult:Float;
}

class Note extends Sprite {
    public static var swagWidth:Float = 160 * 0.7;

    public static var directionData:Map<Int, DirectionData> = [
        4 => {
            directions: ["left", "down", "up", "right"],
            scaleMult: 1,
            spacingMult: 1
        }
    ];

    public var strumLine:TypedGroup<Receptor>;
    public var strumTime:Float = 0;
    public var keyCount:Int = 4;
    public var noteData:Int = 0;
    public var mustPress:Bool = false;

    public function new(?x:Float = 0, ?y:Float = 0, ?strumLine:TypedGroup<Receptor>, ?strumTime:Float = 0, ?keyCount:Int = 0, ?noteData:Int = 0, ?mustPress:Bool = false) {
        super(x, y);
        this.strumLine = strumLine;
        this.strumTime = strumTime;
        this.keyCount = keyCount;
        this.noteData = noteData;
        this.mustPress = mustPress;

        var directionData = Note.directionData.get(keyCount);

        frames = Paths.getSparrowAtlas("gameplay/notes/default/assets");
        animation.addByPrefix("static", directionData.directions[noteData]+"0", 24);
        animation.play("static");

        scale.set(0.7 * directionData.scaleMult, 0.7 * directionData.scaleMult);
        updateHitbox();
    }
}