package engine.managers;

class CameraManager {
    public var list:Array<Camera> = [];

    public function new() {
        Game.signals.preSceneUpdate.add((elapsed:Float) -> {
            Game.camera.update(elapsed);

            for(camera in list)
                camera.update(elapsed);
        });

        Game.signals.preSceneCreate.add(reset);
    }

    public function reset() {
        Logs.trace("Clearing cameras...", ENGINE);
        for(camera in list) {
            camera.kill();
            camera.destroy();
        }
        list = [];
    }

    public function add(camera:Camera) {
        list.push(camera);
        return camera;
    }

    public function remove(camera:Camera) {
        list.remove(camera);
        return camera;
    }
}