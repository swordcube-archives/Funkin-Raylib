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
        __rlCamera = Rl.Camera2D.create(
            Rl.Vector2.create(Game.width * 0.5, Game.height * 0.5), 
            Rl.Vector2.create(Game.width * 0.5, Game.height * 0.5),
            angle,
            zoom
        );
        this.initialZoom = this.zoom = __rlCamera.zoom = zoom;
    }

    override function update(elapsed:Float) {
        // no super because that only calculates velocity shit
        // which we don't need for a fucking camera

        __rlCamera.rotation = angle % 360;
        __rlCamera.zoom = zoom;

        if (target != null) { 
            scroll.x = MathUtil.lerp(scroll.x, target.x, MathUtil.bound(followLerp * 60 * elapsed, 0, 1));
            scroll.y = MathUtil.lerp(scroll.y, target.y, MathUtil.bound(followLerp * 60 * elapsed, 0, 1));
        }
        var sin = Math.sin(angle / -180 * MathUtil.STANDARD_PI);
        var cos = Math.cos(angle / 180 * MathUtil.STANDARD_PI);
        renderPos.x = (scroll.x * cos + scroll.y * sin);
        renderPos.y = (scroll.x * -sin + scroll.y * cos);
    }

    override function destroy() {
        __rlCamera = null;
        super.destroy();
    }
}