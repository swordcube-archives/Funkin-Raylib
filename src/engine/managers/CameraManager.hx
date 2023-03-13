package engine.managers;

import engine.utilities.Logs;

class CameraManager {
    public var list:Array<Camera> = [];

    public function new() {
        Game.signals.preSceneUpdate.add((elapsed:Float) -> {
            Game.camera.update(elapsed);

            for(camera in list)
                camera.update(elapsed);
        });
    }

    public function init() {
        Logs.trace("Clearing cameras...", ENGINE);
        for(camera in list) {
            camera.kill();
            camera.destroy();
        }
        list = [];
        Camera.defaultCameras = [Game.camera];
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