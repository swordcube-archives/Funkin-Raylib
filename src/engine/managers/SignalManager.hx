package engine.managers;

import engine.utilities.Signal;

class SignalManager {
    public var preSceneCreate:#if !macro Signal = new Signal(); #else Dynamic = null; #end
    public var postSceneCreate:#if !macro Signal = new Signal(); #else Dynamic = null; #end

    public var preSceneUpdate:#if !macro TypedSignal<Float->Void> = new TypedSignal<Float->Void>(); #else Dynamic = null; #end
    public var postSceneUpdate:#if !macro TypedSignal<Float->Void> = new TypedSignal<Float->Void>(); #else Dynamic = null; #end

    public var sceneDestroy:#if !macro Signal = new Signal(); #else Dynamic = null; #end

    public var preSceneDraw:#if !macro Signal = new Signal(); #else Dynamic = null; #end
    public var postSceneDraw:#if !macro Signal = new Signal(); #else Dynamic = null; #end

    public function new() {}
}