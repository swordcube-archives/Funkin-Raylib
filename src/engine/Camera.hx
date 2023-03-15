package engine;

import engine.math.Point2D;
import engine.math.MathUtil;

#if !macro
import Rl.Camera2D;
import Rl.Vector2;
#else
typedef Camera2D = Dynamic;
typedef Vector2 = Dynamic;
#end

class Camera extends Object {
    private var __rlCamera:Camera2D;

    public static var currentCamera:Camera;
    public static var defaultCameras:Array<Camera>;

    public var renderQueue:Array<Void->Void> = [];

    public var target:Object = null;
    public var scroll:Point2D = new Point2D();
    public var renderPos:Point2D = new Point2D();
    public var followLerp:Float = 1;
    public var initialZoom:Float = 1.0;
    public var zoom:Float = 1.0;

    public function new(?zoom:Float = 1.0) {
        super();
        #if !macro
        __rlCamera = Rl.RlCamera2D.create(
            Vector2.create(Game.width * 0.5, Game.height * 0.5),
            Vector2.create(Game.width * 0.5, Game.height * 0.5),
            angle,
            zoom
        );
        #end
        this.initialZoom = this.zoom = zoom;
    }

    /**
     * Utilizes the camera's zoom and the texture's resolution to prevent weird render positioning.
     * @param width 
     * @param height 
     */
    public function getCamOffsets(width:Int, height:Int):Vector2 {
        #if !macro
        return Vector2.create(
            -0.5 * (width * Math.abs(zoom) - width),
            -0.5 * (height * Math.abs(zoom) - height)
        );
        #else
        return null;
        #end
    }

    /**
     * Utilizes a vector and cam offsets to adjust the position correctly to the camera's properties.
     * @param vec The position to adjust.
     * @param camX The camera x offset. This should already be calculated in the class calling this function.
     * @param camY The camera y offset.
     * @param scrollFactor The factor to multiply to create a parallax effect.
     */
    public function adjustToCamera(vec:Vector2, camX:Float, camY:Float, scrollFactor:Point2D):Vector2 {
        #if !macro
        vec.x += -camX - renderPos.x * scrollFactor.x;
        vec.y += -camY - renderPos.y * scrollFactor.y;
        return vec;
        #else
        return null;
        #end
    }

    /**
     * Corrects a `Vector2` to the camera's zoom.
     * @param position The vector to correct.
     */
    public function correctToZoom(position:Vector2):Vector2 {
        #if !macro
        return Vector2.create(
            (position.x / zoom - Game.width * 0.5) * zoom + Game.width * 0.5,
            (position.y / zoom - Game.height * 0.5) * zoom + Game.height * 0.5
        );
        #else
        return null;
        #end
    }

    /**
     * Returns if a sprite is on screen.
     * @param sprite The sprite to check.
     */
    public function isOnScreen(sprite:Sprite) {
        return !((sprite.x < (-Math.abs((sprite.frameWidth * sprite.scale.x) * 1.2) / camera.zoom)) ||
            (sprite.y < (-Math.abs((sprite.frameHeight * sprite.scale.y) * 1.2) / camera.zoom)) ||
            (sprite.x > ((Game.width + Math.abs((sprite.frameWidth * sprite.scale.x) * 1.2)) / camera.zoom)) ||
            (sprite.y > ((Game.height + Math.abs((sprite.frameHeight * sprite.scale.y) * 1.2)) / camera.zoom)));
    }

    override function update(elapsed:Float) {
        // no super because that only calculates velocity shit
        // which we don't need for a fucking camera
        __rlCamera.rotation = angle % 360;

        if (target != null) {
            scroll.x = MathUtil.lerp(scroll.x, (target.x - Game.width * 0.5), MathUtil.bound(followLerp * 60 * elapsed, 0, 1));
            scroll.y = MathUtil.lerp(scroll.y, (target.y - Game.height * 0.5), MathUtil.bound(followLerp * 60 * elapsed, 0, 1));
        }
        var sin = Math.sin(angle / -180 * MathUtil.STANDARD_PI);
        var cos = Math.cos(angle / 180 * MathUtil.STANDARD_PI);
        renderPos.x = (scroll.x * cos + scroll.y * sin) * zoom;
        renderPos.y = (scroll.x * -sin + scroll.y * cos) * zoom;
    }

    override function draw() {
        super.draw();
        for(drawCall in renderQueue)
            drawCall();
        renderQueue = [];
    }
}

enum CameraFollowStyle {
	/**
	 * Camera has no deadzone, just tracks the focus object directly.
	 */
	LOCKON;

	/**
	 * Camera's deadzone is narrow but tall.
	 */
	PLATFORMER;

	/**
	 * Camera's deadzone is a medium-size square around the focus object.
	 */
	TOPDOWN;

	/**
	 * Camera's deadzone is a small square around the focus object.
	 */
	TOPDOWN_TIGHT;

	/**
	 * Camera will move screenwise.
	 */
	SCREEN_BY_SCREEN;

	/**
	 * Camera has no deadzone, just tracks the focus object directly and centers it.
	 */
	NO_DEAD_ZONE;
}