package engine.utilities;

import engine.interfaces.IDestroyable;

enum abstract AssetType(Int) to Int from Int {
    var IMAGE = 0;
    var SOUND = 1;
    var TEXT = 2;
    var XML = 3;
    var JSON = 4;
    var ATLAS = 5;
}

typedef CacheMap = Map<String, CachedAsset>;

class CachedAsset implements IDestroyable {
    public var type:AssetType;
    public var asset:Any;

    public function new(type:AssetType, asset:Any) {
        this.type = type;
        this.asset = asset;
    }

	public function destroy() {
        switch(type) {
            #if !macro
            case IMAGE: Rl.unloadTexture(cast(asset, Rl.Texture2D));
            case SOUND: Rl.unloadSound(cast asset);
            #end
            default:
        }
        asset = null;
    }
}

class AssetCache {
    public function new() {
        Game.signals.preSceneCreate.add(reset);
    }

    public var cachedAssets:Map<AssetType, CacheMap> = [
        IMAGE => [],
        SOUND => [],
        TEXT  => [],
        XML   => [],
        JSON  => [],
        ATLAS => [],
    ];

    public function cache(type:AssetType, path:String, asset:Any) {
        var cacheMap:CacheMap = cachedAssets.get(type);
        if(cacheMap == null) return;

        cacheMap.set(path, new CachedAsset(type, asset));
    }

    public function reset() {
        for(cacheMap in cachedAssets) {
            for(asset in cacheMap)
                asset.destroy();

            cacheMap.clear();
        }
    }
}