package engine;

class SubScene extends Scene {
    private var __parentScene:Scene;

	/**
	 * Closes this substate.
	 */
    public function close() {
        if (__parentScene != null && __parentScene.subScene == this)
            __parentScene.closeSubScene();
    }
}