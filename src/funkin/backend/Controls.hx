package funkin.backend;

import engine.keyboard.Keys;
import engine.Game;

class Controls {
    public static var controlsList:Map<String, Array<Int>> = [
        "UI_UP" => [Keys.W, Keys.UP],
        "UI_DOWN" => [Keys.S, Keys.DOWN],
        "UI_LEFT" => [Keys.A, Keys.LEFT],
        "UI_RIGHT" => [Keys.D, Keys.RIGHT],

        "ACCEPT" => [Keys.ENTER, Keys.SPACE],
        "PAUSE" => [Keys.ENTER, Keys.P],
        "BACK" => [Keys.BACKSPACE, Keys.ESCAPE]
    ];

    public function new() {}

    public var UI_UP(get, never):Bool;
    private inline function get_UI_UP() return checkKeys(JUST_PRESSED, controlsList["UI_UP"]);

    public var UI_DOWN(get, never):Bool;
    private inline function get_UI_DOWN() return checkKeys(JUST_PRESSED, controlsList["UI_DOWN"]);

    public var UI_LEFT(get, never):Bool;
    private inline function get_UI_LEFT() return checkKeys(JUST_PRESSED, controlsList["UI_LEFT"]);

    public var UI_RIGHT(get, never):Bool;
    private inline function get_UI_RIGHT() return checkKeys(JUST_PRESSED, controlsList["UI_RIGHT"]);

    public var ACCEPT(get, never):Bool;
    private inline function get_ACCEPT() return checkKeys(JUST_PRESSED, controlsList["ACCEPT"]);

    public var PAUSE(get, never):Bool;
    private inline function get_PAUSE() return checkKeys(JUST_PRESSED, controlsList["PAUSE"]);

    public var BACK(get, never):Bool;
    private inline function get_BACK() return checkKeys(JUST_PRESSED, controlsList["BACK"]);

    private function checkKeys(status:KeyState, keys:Array<Int>) {
        for(key in keys) {
            switch(status) {
                case JUST_PRESSED:
                    if(Game.keys.justPressed(key))
                        return true;

                case PRESSED:
                    if(Game.keys.pressed(key))
                        return true;

                case JUST_RELEASED:
                    if(Game.keys.justReleased(key))
                        return true;

                case RELEASED:
                    if(Game.keys.released(key))
                        return true;
            }
        }
        return false;
    }
}