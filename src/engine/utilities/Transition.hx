package engine.utilities;

interface ITransition {
    public var out:Bool;
}

class Transition extends SubScene implements ITransition {
    public var out:Bool = false;

    /**
     * @param out Whether or not should transition should act like an outwards transition.
     */
    public function new(?out:Bool = false) {
        super();
        this.out = out;
    }

    public var finishCallback:Void->Void = () -> Game.switchScene(Game.nextScene, true);
}