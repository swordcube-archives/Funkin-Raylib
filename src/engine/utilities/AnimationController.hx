package engine.utilities;

import engine.Object;
import engine.utilities.Atlas.FrameData;

#if !macro
typedef ParentSprite = Sprite;
#else
typedef ParentSprite = Dynamic;
#end

class AnimationController extends Object {
    private var __parent:ParentSprite;
    private var __animations:Map<String, Animation> = [];
    
    //** Helper Functions & Variables **//

    /**
     * The currently loaded animation.
     * 
     * #### ⚠⚠ WARNING!! ⚠⚠ 
     * This can be `null`!
     */
    public var curAnim:Animation;

    /**
     * The name of the currently loaded animation.
     */
    public var name(get, never):String;
    private function get_name():String {
		var animName:String = "";
		if (curAnim != null)
			animName = curAnim.name;
		
		return animName;
    }

    /**
     * Whether or not the current animation should be reversed.
     */
    public var reversed:Bool = false;

    /**
     * Whether or not the current animation is finished.
     */
    public var finished:Bool = false;

    public function add(name:String, frames:Array<Int>, ?frameRate:Int = 30, ?loop:Bool = true) {
        var atlas:Atlas = __parent.frames;
        if(atlas == null) return;

        // Then filter it to only the frames specified
        var neededFrames:Array<FrameData> = [];
        for(num in frames) 
            neededFrames.push(atlas.frames[num]);

        // Then add the animation
        var animationData = new Animation(name, frameRate, loop);
        @:privateAccess
        animationData.__frames = neededFrames;

        __animations.set(name, animationData);
    }

    public function addByPrefix(name:String, prefix:String, ?frameRate:Int = 30, ?loop:Bool = true) {
        var atlas:Atlas = __parent.frames;
        if(atlas == null) return;

        // Get the frames for the animation we want
        // Then make the animation data
        var animationData = new Animation(name, frameRate, loop);
        for(frame in atlas.frames) {
            if(frame.name.startsWith(prefix)) {
                @:privateAccess
                animationData.__frames.push(frame);
            }
        }

        // Add the animation
        __animations.set(name, animationData);
    }

    public function addByIndices(name:String, prefix:String, indices:Array<Int>, ?frameRate:Int = 30, ?loop:Bool = true) {
        var atlas:Atlas = __parent.frames;
        if(atlas == null) return;

        // Get all of the frames of the animation we want
        var allFrames:Array<FrameData> = [];
        for(frame in atlas.frames) {
            if(frame.name.startsWith(prefix))
                allFrames.push(frame);
        }

        // Then filter it to only the frames specified in the indices
        var neededFrames:Array<FrameData> = [];
        for(num in indices) 
            neededFrames.push(allFrames[num]);

        // Then add the animation
        var animationData = new Animation(name, frameRate, loop);
        @:privateAccess
        animationData.__frames = neededFrames;

        __animations.set(name, animationData);
    }

    public function play(name:String, ?force:Bool = false, ?reversed:Bool = false, ?frame:Int = 0) {
        if(!exists(name) || __animations.get(name) == null) return Logs.trace('Animation called "$name" doesn\'t exist!', ERROR);
        if(this.name == name && !finished && !force) return;

        __elapsedTime = 0;
        finished = false;
        curAnim = __animations.get(name);
        curAnim.curFrame = frame;

        @:privateAccess {
            if(__parent != null && curAnim != null && curAnim.__frames[0] != null) {
                __parent.frameWidth = curAnim.__frames[0].width;
                __parent.frameHeight = curAnim.__frames[0].height;
                __parent.updateHitbox();
            }
        }

        this.reversed = reversed;
    }

    public function exists(name:String) {
        return __animations.exists(name);
    }

    //** Don't worry about the stuff past this point! This just handles the animation and makes it work. **//
    //** Unless you wanna fix a bug you find here, then go right ahead! **//

    private var __elapsedTime:Float = 0;
    
    public function new(parent:ParentSprite) {
        super();
        this.__parent = parent;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(finished || curAnim == null) return;
        
        __elapsedTime += elapsed;
        if(__elapsedTime >= (1 / curAnim.frameRate)) {
            if(curAnim.curFrame < curAnim.numFrames - 1)
                curAnim.curFrame++;
            else {
                if(curAnim.loop)
                    curAnim.curFrame = 0;
                else
                    finished = true;
            }
            __elapsedTime = 0;
        }
    }

    override function destroy() {
        __animations = null;
        curAnim = null;
        reversed = false;
        finished = true;
        super.destroy();
    }
}

class Animation {
    private var __frames:Array<FrameData> = [];

    /**
     * The name of the animation.
     */
    public var name:String;

    /**
     * The framerate the animation plays at.
     */
    public var frameRate:Int = 30;

    /**
     * The current frame of the animation.
     */
    public var curFrame:Int = 0;

    /**
     * The amount of frames the animation has.
     */
    public var numFrames(get, never):Int;
    private function get_numFrames():Int {
        return __frames.length;
    }

    /**
     * The amount of frames the animation has.
     */
    public var frameCount(get, never):Int;
    private function get_frameCount():Int {
        return __frames.length;
    }

    /**
     * Whether or not this animation loops when finished.
     */
    public var loop:Bool = true;

    public function new(name:String, ?frameRate:Int = 30, ?loop:Bool = true) {
        this.name = name;
        this.frameRate = frameRate;
        this.loop = loop;
    }
}