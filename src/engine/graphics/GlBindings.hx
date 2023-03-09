package engine.graphics;

@:include('external/glad.h')
/**
 * Please note, this doesn't have all the bindings.
 */
extern class GlBindings {
    @:native('glad_glUseProgram')
    public static function glUseProgram(program:Int):Void;

    @:native('glad_glUniform1f')
    public static function glUniform1f(location:Int, v0:Float):Void;

    //public static function glUniform1fv(location:Int, GLsizei count, const GLfloat *value);

    @:native('glad_glUniform1i')
    public static function glUniform1i(location:Int, v0:Int):Void;

    //public static function glUniform1iv(location:Int, GLsizei count, const GLint *value);

    @:native('glad_glUniform2f')
    public static function glUniform2f(location:Int, v0:Float, v1:Float):Void;

    //public static function glUniform2fv(location:Int, GLsizei count, const GLfloat *value);

    @:native('glad_glUniform2i')
    public static function glUniform2i(location:Int, v0:Int, v1:Int):Void;

    //public static function glUniform2iv(location:Int, GLsizei count, const GLint *value);

    @:native('glad_glUniform3f')
    public static function glUniform3f(location:Int, v0:Float, v1:Float, v2:Float):Void;

    //public static function glUniform3fv(location:Int, GLsizei count, const GLfloat *value);

    @:native('glad_glUniform3i')
    public static function glUniform3i(location:Int, v0:Int, v1:Int, v2:Int):Void;

    //public static function glUniform3iv(location:Int, GLsizei count, const GLint *value);

    @:native('glad_glUniform4f')
    public static function glUniform4f(location:Int, v0:Float, v1:Float, v2:Float, v3:Float):Void;

    //public static function glUniform4fv(location:Int, GLsizei count, const GLfloat *value);

    @:native('glad_glUniform4i')
    public static function glUniform4i(location:Int, v0:Int, v1:Int, v2:Int, v3:Int):Void;

    //public static function glUniform4iv(location:Int, GLsizei count, const GLint *value);
    //public static function glUniformMatrix2fv(location:Int, GLsizei count, GLboolean transpose, const GLfloat *value);
    //public static function glUniformMatrix3fv(location:Int, GLsizei count, GLboolean transpose, const GLfloat *value);
    //public static function glUniformMatrix4fv(location:Int, GLsizei count, GLboolean transpose, const GLfloat *value);
}