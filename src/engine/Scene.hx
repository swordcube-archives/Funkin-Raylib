package engine;

class Scene extends Group {
	/**
	 * Determines whether or not this scene is updated even when it is not the active scene.
	 * For example, if you have your game scene first, and then you push a menu scene on top of it,
	 * if this is set to `true`, the game scene would continue to update in the background.
	 * By default this is `false`, so background scenes will be "paused" when they are not active.
	 */
    public var persistentUpdate:Bool = false;

     /**
      * Determines whether or not this scene is updated even when it is not the active scene.
      * For example, if you have your game scene first, and then you push a menu scene on top of it,
      * if this is set to `true`, the game scene would continue to be drawn behind the pause scene.
      * By default this is `true`, so background scenes will continue to be drawn behind the current scene.
      *
      * If background scenes are not `visible` when you have a different scene on top,
      * you should set this to `false` for improved performance.
      */
    public var persistentDraw:Bool = true;

    /**
     * The currently loaded subscene.
     * 
     * #### ⚠⚠ WARNING!! ⚠⚠ 
     * This can be `null`!
     */
    public var subScene:SubScene;

    public function create() {}
    public function createPost() {}

    public function tryUpdate(elapsed:Float) {
        if(persistentUpdate || subScene == null)
            update(elapsed);

        if(subScene != null)
            subScene.update(elapsed);
    }

    override function draw() {
        if(persistentDraw || subScene == null)
            super.draw();

        if(subScene != null)
            subScene.draw();
    }

    public function openSubScene(subScene:SubScene) {
        closeSubScene();
        @:privateAccess {
            this.subScene = subScene;
            this.subScene.__parentScene = this;
            this.subScene.create();
        }
    }

    public function closeSubScene() {
        if(subScene != null)
            subScene.destroy();

        subScene = null;
    }
}