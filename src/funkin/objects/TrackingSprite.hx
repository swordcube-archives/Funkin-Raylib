package funkin.objects;

import engine.utilities.Atlas;
import engine.utilities.Color;
import engine.math.Point2D;
import engine.Object;

/**
 * Enum to store the mode (or direction) that a tracking sprite tracks.
 */
enum abstract TrackingMode(Int) to Int from Int {
    var RIGHT = 0;
    var LEFT = 1;
    var UP = 2;
    var DOWN = 3;
}

/**
 * A sprite that tracks another sprite with customizable offsets.
 * @author Leather128
 */
 class TrackingSprite extends FNFSprite {
    /**
     * The offest in X and Y to the tracked object.
     */
    public var trackingOffset:Point2D = new Point2D(10, -30);

    /**
     * The object / sprite we are tracking.
     */
    public var tracked:Object;

    /**
     * Tracking mode (or direction) of this sprite.
     */
    public var trackingMode:TrackingMode = RIGHT;

    public var copyAlpha:Bool = true;

    override function update(elapsed:Float):Void {
        // tracking modes
        if (tracked != null) {
            switch (trackingMode) {
                case RIGHT: setPosition(tracked.x + tracked.width + trackingOffset.x, tracked.y + trackingOffset.y);
                case LEFT: setPosition(tracked.x + trackingOffset.x, tracked.y + trackingOffset.y);
                case UP: setPosition(tracked.x + (tracked.width * 0.5) + trackingOffset.x, tracked.y - height + trackingOffset.y);
                case DOWN: setPosition(tracked.x + (tracked.width * 0.5) + trackingOffset.x, tracked.y + tracked.height + trackingOffset.y);
            }
            if(copyAlpha && tracked is engine.Sprite) alpha = cast(tracked, engine.Sprite).alpha;
        }

        super.update(elapsed);
    }

    override public function loadGraphic(Graphic:String, Width:Int = 0, Height:Int = 0) {
        super.loadGraphic(Graphic, Width, Height);
        return this;
    }

    override public function makeGraphic(Width:Int, Height:Int, Color:Color = null) {
        super.makeGraphic(Width, Height, Color);
        return this;
    }

    override public function loadAtlas(Data:Atlas) {
        frames = Data;
        return this;
    }
}