package engine.utilities;

class AnimationController {
    private var __animations:Array<Animation> = [];
    
    public function new() {}
}

class Animation {
    public var frameRate:Int = 30;

    public function new(?frameRate:Int = 30) {
        this.frameRate = frameRate;
    }
}