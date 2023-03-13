package engine.keyboard;

import engine.keyboard.Keys;

class KeyboardManager {
    #if !macro
    public var justPressed(get, never):Int->Bool;
    private function get_justPressed() {
        return (key:Int) -> {
            return (key == Keys.ANY) ? getStatusOfAnyKey(JUST_PRESSED) : Rl.isKeyPressed(key);
        };
    }

    public var pressed(get, never):Int->Bool;
    private function get_pressed() {
        return (key:Int) -> {
            return (key == Keys.ANY) ? getStatusOfAnyKey(PRESSED) : Rl.isKeyDown(key);
        };
    }

    public var justReleased(get, never):Int->Bool;
    private function get_justReleased() {
        return (key:Int) -> {
            return (key == Keys.ANY) ? getStatusOfAnyKey(JUST_RELEASED) : Rl.isKeyReleased(key);
        };
    }

    public var released(get, never):Int->Bool;
    private function get_released() {
        return (key:Int) -> {
            return (key == Keys.ANY) ? getStatusOfAnyKey(RELEASED) : Rl.isKeyUp(key);
        };
    }

    public var anyJustPressed(get, never):(Array<Int>)->Bool;
    private function get_anyJustPressed() {
        return (keys:Array<Int>) -> {
            for(key in keys) {
                if((key == Keys.ANY) ? getStatusOfAnyKey(JUST_PRESSED) : Rl.isKeyPressed(key))
                    return true;
            }
            return false;
        };
    }

    public var anyPressed(get, never):(Array<Int>)->Bool;
    private function get_anyPressed() {
        return (keys:Array<Int>) -> {
            for(key in keys) {
                if((key == Keys.ANY) ? getStatusOfAnyKey(PRESSED) : Rl.isKeyDown(key))
                    return true;
            }
            return false;
        };
    }

    public var anyJustReleased(get, never):(Array<Int>)->Bool;
    private function get_anyJustReleased() {
        return (keys:Array<Int>) -> {
            for(key in keys) {
                if((key == Keys.ANY) ? getStatusOfAnyKey(JUST_RELEASED) : Rl.isKeyReleased(key))
                    return true;
            }
            return false;
        };
    }

    public var anyReleased(get, never):(Array<Int>)->Bool;
    private function get_anyReleased() {
        return (keys:Array<Int>) -> {
            for(key in keys) {
                if((key == Keys.ANY) ? getStatusOfAnyKey(RELEASED) : Rl.isKeyUp(key))
                    return true;
            }
            return false;
        };
    }

    private function getStatusOfAnyKey(status:KeyState) {
        for(key in Keys.toStringMap.keys()) {
            if(key == ANY) continue;

            switch(status) {
                case JUST_PRESSED: if(justPressed(key)) return true;
                case PRESSED: if(pressed(key)) return true;
                case JUST_RELEASED: if(justReleased(key)) return true;
                case RELEASED: if(released(key)) return true;
            }
        }
        return false;
    }
    #end

    public function new() {}
}