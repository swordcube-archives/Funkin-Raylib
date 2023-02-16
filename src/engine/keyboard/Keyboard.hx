package engine.keyboard;

class Keyboard {
    public var justPressed(get, never):Int->Bool;
    private function get_justPressed() {
        return (key:Int) -> {
            return Rl.isKeyPressed(key);
        };
    }

    public var pressed(get, never):Int->Bool;
    private function get_pressed() {
        return (key:Int) -> {
            return Rl.isKeyDown(key);
        };
    }

    public var justReleased(get, never):Int->Bool;
    private function get_justReleased() {
        return (key:Int) -> {
            return Rl.isKeyReleased(key);
        };
    }

    public var released(get, never):Int->Bool;
    private function get_released() {
        return (key:Int) -> {
            return Rl.isKeyUp(key);
        };
    }

    public function new() {}
}