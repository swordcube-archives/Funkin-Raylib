package funkin.backend.hscript;

import engine.tweens.Ease;
import engine.tweens.Tween;
import haxe.io.Path;
import engine.interfaces.IDestroyable;

import hscript.Parser;
import hscript.Expr;
import hscript.Interp;

/**
 * The class for a script/modchart.
 * 
 * This can do anything you want, Such as:
 * - Go to another state
 * - Do random shit with the notes
 * - Kill the game
 */
class HScript implements IDestroyable {
    public var parent:Dynamic;
    public var fileName:String;

    public var interp:Interp;
    public var parser:Parser;
    public var expr:Expr;

    public function new(filePath:String) {
        fileName = Path.withoutDirectory(filePath);

        interp = new Interp();
        interp.errorHandler = (error:Error) -> {
            Logs.trace('$fileName - Line ${error.line}: ${error.toString()}', ERROR);
        };
        preset();

        parser = new Parser();
        parser.allowJSON = true;
        parser.allowMetadata = true;
        parser.allowTypes = true;

        var code:String = Assets.getText(filePath);
        expr = parser.parseString(code, fileName);

        try {
            interp.execute(expr);
        } catch(e) {
            Logs.trace('Error occured while trying to run script ($fileName): ${e.toString()}', ERROR);
        }
    }

    /**
     * This function sets up default variables for this script.
     */
    public function preset() {
        set("Game", Game);
        set("Sprite", Sprite);
        set("Init", Init);
        set("Paths", Paths);
        set("Std", Std);
        set("Math", Math);
        set("MathUtil", MathUtil);
        set("Timer", Timer);
        set("Assets", Assets);
        set("Tween", Tween);
        set("Ease", Ease);
    }

    /**
     * Allows the all of the variables and functions from `parent` to be accessed as if
     * they are apart of the script itself.
     * @param parent The parent to get the variables/functions from.
     */
    public function setParent(parent:Dynamic) {
        if(interp == null) return;
        interp.scriptObject = this.parent = parent;
    }

    /**
     * Returns a variable from the script.
     * @param variable The variable to return.
     */
    public function get(variable:String):Dynamic {
        if(interp == null) return null;
        return interp.variables.get(variable);
    }

    /**
     * Sets a variable in the script to any value.
     * @param variable The variable to set.
     * @param value The value to set the script to.
     */
    public function set(variable:String, value:Dynamic) {
        if(interp == null) return;
        interp.variables.set(variable, value);
    }

    /**
     * Calls a function from the script.
     * If the function we are trying to call returns a value, this function will return that value if possible.
     * 
     * @param method The function to call.
     * @param parameters (Optional) The parameters of the function.
     */
    public function call(method:String, ?parameters:Array<Dynamic>):Dynamic {
        // If this function doesn't exist, don't try to run it.
        if(!interp.variables.exists(method)) return null;

        var func:Dynamic = interp.variables.get(method);

        // If the function itself is somehow null, don't try to run it.
        if(func == null) return null;

        // Try to run the function and return whatever the function should return.
        // If the function fails to run we trace a message and return null.
        try {
            return (parameters != null && parameters.length > 0) ? Reflect.callMethod(null, func, parameters) : func();
        } catch(e) {
            Logs.trace('Error occured while calling function on script ($fileName, $method): ${e.toString()}', ERROR);
            return null;
        }
    }

    public function destroy() {
        interp = null;
        parser = null;
        expr = null;
    }
}