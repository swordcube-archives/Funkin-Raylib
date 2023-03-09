package engine;

class Camera extends Object {
    private var __rlCamera:Rl.Camera2D;

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
    }

    override function destroy() {
        __rlCamera = null;
        super.destroy();
    }
}