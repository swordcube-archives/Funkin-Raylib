package engine.utilities;

import sys.io.File;
import sys.FileSystem;
import engine.utilities.AssetCache.CacheMap;
import Rl.Texture2D;

class Assets {
    public static inline function getImage(path:String) {
        var texture:Texture2D = null;
        var cacheMap:CacheMap = Game.assetCache.cachedAssets.get(IMAGE);

        if(cacheMap.exists(path)) 
            texture = cacheMap.get(path).asset;
        else {
            texture = Rl.loadTexture(path);
            Game.assetCache.cache(IMAGE, path, texture);
        }
        return texture;
    }

    public static inline function getText(path:String) {
        var contents:String = "";
        var cacheMap:CacheMap = Game.assetCache.cachedAssets.get(TEXT);

        if(cacheMap.exists(path)) 
            contents = cacheMap.get(path).asset;
        else {
            contents = FileSystem.exists(path) ? File.getContent(path) : "";
            Game.assetCache.cache(TEXT, path, contents);
        }
        return contents;
    }

    public static inline function getSound(path:String) {
        return Rl.loadSound(path);
    }
}