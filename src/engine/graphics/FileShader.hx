package engine.graphics;

import engine.graphics.GlBindings;

/**
 * Runs a shader from a file.
 * Can currently be applied to `Sprite` objects.
 */
class FileShader implements engine.interfaces.IDestroyable {
    public var actualShader:#if !macro Rl.Shader #else Dynamic #end;

    public function new(fragFilePath:String, ?vertexFilePath:String) {
        #if !macro
        Rl.setTraceLogLevel(Rl.TraceLogLevel.FATAL);
        actualShader = Rl.loadShader(vertexFilePath, fragFilePath);
        Rl.setTraceLogLevel(Rl.TraceLogLevel.WARNING);
        #end
    }

    public var failedToFind:Array<String> = [];
    public function setUniform(varName:String, value:Dynamic) {
        #if !macro
        if (failedToFind.contains(varName))
            return;

        var location = Rl.getShaderLocation(actualShader, varName);
        if (location == -1) {
            failedToFind.push(varName);
            return;
        }
        var varType = Type.typeof(value);

        GlBindings.glUseProgram(actualShader.id);

        switch (varType) {
            case TInt:
                GlBindings.glUniform1i(location, cast (value, Int));
            case TFloat:
                GlBindings.glUniform1f(location, cast (value, Float));
            case TClass(Array):
                var array = cast (value, Array<Dynamic>);
                switch (array.length) {
                    case 3:
                        GlBindings.glUniform3f(location, array[0], array[1], array[2]);
                    case 4:
                        GlBindings.glUniform4f(location, array[0], array[1], array[2], array[3]);
                    default:
                        GlBindings.glUniform2f(location, array[0], array[1]);
                }
            default:
                Rl.traceLog(Rl.TraceLogLevel.WARNING, 'Variable type $varType currently not supported.');
        }
        #end
    }

    public function destroy() {
        #if !macro
        Rl.unloadShader(actualShader);
        failedToFind = null;
        #end
    }
}