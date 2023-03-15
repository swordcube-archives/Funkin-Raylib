package funkin.objects;

import engine.utilities.Color;
import engine.utilities.Atlas;
import engine.Sprite;
import engine.math.Point2D;

enum abstract AtlasType(String) to String from String {
    var SPARROW = "SPARROW";
    var PACKER = "PACKER";
}

enum abstract AnimationContext(String) to String from String {
    var NORMAL = "NORMAL";
    var SING = "SING";
}

class FNFSprite extends Sprite {
    public var lastAnimContext:AnimationContext = NORMAL;
    public var animOffsets:Map<String, Point2D> = [];

    public function addOffset(name:String, ?x:Float = 0, ?y:Float = 0, ?adjustToScale:Bool = false) {
        animOffsets.set(name, new Point2D(x / (adjustToScale ? scale.x : 1), y / (adjustToScale ? scale.y : 1)));
    }

    public function addAnim(name:String, prefix:String, ?fps:Int = 24, ?loop:Bool = false, ?offsets:Point2D) {
        if(offsets == null) offsets = new Point2D(0, 0);
        animation.addByPrefix(name, prefix, fps, loop);
        addOffset(name, offsets.x, offsets.y);
    }

    public function addAnimByIndices(name:String, prefix:String, indices:Array<Int>, ?fps:Int = 24, ?loop:Bool = false, ?offsets:Point2D) {
        if(offsets == null) offsets = new Point2D(0, 0);
        animation.addByIndices(name, prefix, indices, fps, loop);
        addOffset(name, offsets.x, offsets.y);
    }

    public function playAnim(name:String, force:Bool = false, context:AnimationContext = NORMAL, frame:Int = 0) {
        animation.play(name, force, false, frame);
        lastAnimContext = context;
        if(animOffsets.exists(name)) {
            var daOffset:Point2D = animOffsets.get(name);
            offset.set(daOffset.x, daOffset.y);
        } else
            offset.set(0, 0);
    }

	override public function loadGraphic(Graphic:String, Width:Int = 0, Height:Int = 0) {
        super.loadGraphic(Graphic, Width, Height);
        return this;
    }

    override public function makeGraphic(Width:Int, Height:Int, Color:Color = null) {
        super.makeGraphic(Width, Height, Color);
        return this;
    }

    public function loadAtlas(Data:Atlas) {
        frames = Data;
        return this;
    }
}