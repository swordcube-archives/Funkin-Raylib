package funkin.objects.ui;

import scenes.PlayState;
import engine.Group.TypedGroup;

typedef DirectionData = {
    var directions:Array<String>;
    @:optional var scaleMult:Float;
    @:optional var spacingMult:Float;
}

class Note extends Sprite {
    public var game = PlayState.current;

    public static var swagWidth:Float = 160 * 0.7;

    public static var directionData:Map<Int, DirectionData> = [
        4 => {
            directions: ["left", "down", "up", "right"],
            scaleMult: 1,
            spacingMult: 1
        }
    ];

    public var initialScale:Float = 0.7;

    public var sustainNotes:Array<Note> = [];
    public var strumLine:TypedGroup<Receptor>;
    public var strumTime:Float = 0;
    public var keyCount:Int = 4;
    public var noteData:Int = 0;
    public var mustPress:Bool = false;
    public var canBeHit:Bool = false;

    public var isSustainNote:Bool = false;
    public var isSustainTail:Bool = false;
    public var stepCrochet:Float = 0;

    public var offsetX:Float = 0;
    public var offsetY:Float = 0;

    public var scrollSpeed:Null<Float> = null;
    public function getScrollSpeed():Float {
        if(strumLine != null && strumLine.members[noteData] != null && strumLine.members[noteData].scrollSpeed != null)
            return strumLine.members[noteData].scrollSpeed / Game.timeScale;

        if(scrollSpeed != null)
            return scrollSpeed / Game.timeScale;

        return game.scrollSpeed / Game.timeScale;
    }

    public function new(?x:Float = 0, ?y:Float = 0, ?strumLine:TypedGroup<Receptor>, ?strumTime:Float = 0, ?keyCount:Int = 0, ?noteData:Int = 0, ?mustPress:Bool = false, ?isSustainNote:Bool = false, ?isSustainTail:Bool = false) {
        super(x, y);
        this.strumLine = strumLine;
        this.strumTime = strumTime;
        this.keyCount = keyCount;
        this.noteData = noteData;
        this.mustPress = mustPress;
        this.isSustainNote = isSustainNote;
        this.isSustainTail = isSustainTail;

        var directionData = Note.directionData.get(keyCount);

        frames = Paths.getSparrowAtlas("gameplay/notes/default/assets");
        animation.addByPrefix("static", directionData.directions[noteData]+"0", 24);
        animation.addByPrefix("hold", directionData.directions[noteData]+" hold piece0", 24);
        animation.addByPrefix("tail", directionData.directions[noteData]+" hold end0", 24);

        scale.set(0.7 * directionData.scaleMult, 0.7 * directionData.scaleMult);
        initialScale = scale.x;
        updateHitbox();

        if(isSustainNote) {
            if(isSustainTail)
                playAnim("tail");
            else 
                playAnim("hold");
        } else
            playAnim("static");
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        canBeHit = strumTime <= Conductor.position + (Conductor.safeZoneOffset * 1.5);

        if(isSustainNote) {
            if(!isSustainTail) {
                scale.y = initialScale * ((stepCrochet / 100) * 1.5) * Math.abs(getScrollSpeed());
            }
            updateHitbox();
            centerXOffset();
        }
    }

    public function centerXOffset() {
        offset.x = frameWidth * -0.5;
        offset.x += 156 * (initialScale * 0.5);
    }

    public function playAnim(name:String, ?force:Bool = false, ?reversed:Bool = false, ?frame:Int = 0) {
        animation.play(name, force, reversed, frame);

        centerOrigin();
        offset.x = frameWidth * -0.5;
        offset.y = frameHeight * -0.5;

        offset.x += 156 * (initialScale * 0.5);
        offset.y += 156 * (initialScale * 0.5);
    }
}