package engine;

class Camera extends Object {
    public var initialZoom:Float = 1.0;
    public var zoom:Float = 1.0;

    public function new(?zoom:Float = 1.0) {
        super();
        this.initialZoom = this.zoom = zoom;
    }
}