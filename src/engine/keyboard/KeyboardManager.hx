package engine.keyboard;

#if !macro
class KeyboardManager {
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

    public var anyJustPressed(get, never):(Array<Int>)->Bool;
    private function get_anyJustPressed() {
        return (keys:Array<Int>) -> {
            for(key in keys) {
                if(Rl.isKeyPressed(key))
                    return true;
            }
            return false;
        };
    }

    public var anyPressed(get, never):(Array<Int>)->Bool;
    private function get_anyPressed() {
        return (keys:Array<Int>) -> {
            for(key in keys) {
                if(Rl.isKeyDown(key))
                    return true;
            }
            return false;
        };
    }

    public var anyJustReleased(get, never):(Array<Int>)->Bool;
    private function get_anyJustReleased() {
        return (keys:Array<Int>) -> {
            for(key in keys) {
                if(Rl.isKeyReleased(key))
                    return true;
            }
            return false;
        };
    }

    public var anyReleased(get, never):(Array<Int>)->Bool;
    private function get_anyReleased() {
        return (keys:Array<Int>) -> {
            for(key in keys) {
                if(Rl.isKeyUp(key))
                    return true;
            }
            return false;
        };
    }

    public function new() {}
}
#end