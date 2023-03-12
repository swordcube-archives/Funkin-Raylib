package engine;

class Camera extends Object {
    private var __rlCamera:Rl.Camera2D;

    public var target:Object = null;
    public var scroll:Point2D = new Point2D();
    public var renderPos:Point2D = new Point2D();
    public var followLerp:Float = 1;
    public var initialZoom:Float = 1.0;
    public var zoom:Float = 1.0;

    public function new(?zoom:Float = 1.0) {
        super();
        __rlCamera = Rl.RlCamera2D.create(
            Rl.Vector2.create(Game.width * 0.5, Game.height * 0.5),
            Rl.Vector2.create(Game.width * 0.5, Game.height * 0.5),
            angle,
            zoom
        );
        this.initialZoom = this.zoom = zoom;
    }

    /**
     * Utilizes the camera's zoom and the texture's resolution to prevent weird render positioning.
     * @param width 
     * @param height 
     */
    public function getCamOffsets(width:Int, height:Int) {
        return Rl.Vector2.create(
            -0.5 * (width * Math.abs(zoom) - width),
            -0.5 * (height * Math.abs(zoom) - height)
        );
    }

    /**
     * Utilizes a vector and cam offsets to adjust the position correctly to the camera's properties.
     * @param vec The position to adjust.
     * @param camX The camera x offset. This should already be calculated in the class calling this function.
     * @param camY The camera y offset.
     * @param scrollFactor The factor to multiply to create a parallax effect.
     */
    public function adjustToCamera(vec:Rl.Vector2, camX:Float, camY:Float, scrollFactor:Point2D) {
        vec.x += -camX - renderPos.x * scrollFactor.x;
        vec.y += -camY - renderPos.y * scrollFactor.y;
        return vec;
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