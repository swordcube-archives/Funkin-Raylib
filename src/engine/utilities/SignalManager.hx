package engine.utilities;

import engine.utilities.Signal.TypedSignal;

class SignalManager {
    public var preSceneCreate:Signal = new Signal();
    public var postSceneCreate:Signal = new Signal();

    public var preSceneUpdate:TypedSignal<Float->Void> = new TypedSignal<Float->Void>();
    public var postSceneUpdate:TypedSignal<Float->Void> = new TypedSignal<Float->Void>();

    public var sceneDestroy:Signal = new Signal();

    public var preSceneDraw:Signal = new Signal();
    public var postSceneDraw:Signal = new Signal();

    public function new() {}
}