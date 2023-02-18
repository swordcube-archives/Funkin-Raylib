package engine.utilities;

import sys.io.File;
import haxe.xml.Access;

#if !macro
import Rl.Texture2D;
#else
typedef Texture2D = Dynamic;
#end

typedef FrameData = {
    var name:String;
    var x:Int;
    var y:Int;
    var frameX:Int;
    var frameY:Int;
    var width:Int;
    var height:Int;
}

class Atlas {
    public var texture:Texture2D;
    public var frames:Array<FrameData> = [];

    public function new() {}

    //** Helper Functions **//

    /**
     * Generates an Atlas from a `png` and `xml` file.
     * @param imagePath The path to the image.
     * @param xmlPath The path to the xml.
     */
    public static function fromSparrow(imagePath:String, xmlPath:String) {
        var atlas = new Atlas();

        #if !macro
        atlas.texture = Rl.loadTexture(imagePath);

        var xmlData = new Access(Xml.parse(File.getContent(xmlPath).trim()).firstElement());
        
		for (frame in xmlData.nodes.SubTexture) {
            atlas.frames.push({
                name: frame.att.name,
                x: Std.parseInt(frame.att.x),
                y: Std.parseInt(frame.att.y),
                width: frame.has.frameWidth ? Std.parseInt(frame.att.frameWidth) : Std.parseInt(frame.att.width),
                height: frame.has.frameHeight ? Std.parseInt(frame.att.frameHeight) : Std.parseInt(frame.att.height),
                frameX: frame.has.frameX ? Std.parseInt(frame.att.frameX) : 0,
                frameY: frame.has.frameY ? Std.parseInt(frame.att.frameY) : 0,
            });
		}
        #end

        return atlas;
    }
}