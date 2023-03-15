package engine.utilities;

import engine.utilities.AssetCache.CacheMap;
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

    /**
     * The amount of frames in this atlas.
     */
    public var numFrames(get, never):Int;

    @:noCompletion
    private function get_numFrames():Int {
        return frames.length;
    }

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
        var cacheMap:CacheMap = Game.assetCache.cachedAssets.get(IMAGE);

        if(cacheMap.exists(imagePath)) 
            atlas.texture = cacheMap.get(imagePath).asset;
        else {
            atlas.texture = Rl.loadTexture(imagePath);
            Game.assetCache.cache(IMAGE, imagePath, atlas.texture);
        }

        var rawXml:Xml = null;
        var cacheMap:CacheMap = Game.assetCache.cachedAssets.get(XML);

        if(cacheMap.exists(xmlPath)) 
            rawXml = cacheMap.get(xmlPath).asset;
        else {
            rawXml = Xml.parse(File.getContent(xmlPath).trim());
            Game.assetCache.cache(XML, xmlPath, rawXml);
        }

        var xmlData = new Access(rawXml.firstElement());
        
		for (frame in xmlData.nodes.SubTexture) {
            atlas.frames.push({
                name: frame.att.name,
                x: Std.parseInt(frame.att.x),
                y: Std.parseInt(frame.att.y),
                width: Std.parseInt(frame.att.width),
                height: Std.parseInt(frame.att.height),
                frameX: frame.has.frameX ? Std.parseInt(frame.att.frameX) : 0,
                frameY: frame.has.frameY ? Std.parseInt(frame.att.frameY) : 0,
            });
		}
        #end

        return atlas;
    }
}