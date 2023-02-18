package engine;

import Rl.Image;
import engine.utilities.Atlas;
import engine.utilities.Axes;
import engine.utilities.AnimationController;
import engine.Vector2;

#if !macro
import Rl.Colors;
import Rl.Color;
import Rl.Texture2D;
import Rl.Rectangle;

class Sprite extends Object {
    public var frames(default, set):Atlas;
    private function set_frames(atlas:Atlas) {
        if(texture != null) {
            Rl.unloadTexture(texture);
            texture = null;
        }
        texture = atlas.texture;
        frameWidth = atlas.frames[0].width;
        frameHeight = atlas.frames[0].height;
        updateHitbox();
        set_antialiasing(antialiasing);
        
        return frames = atlas;
    }

    public var animation:AnimationController;

    public var texture:Texture2D;

    public var angle:Float = 0;
    public var scale:Vector2 = new Vector2(1, 1);

    public var color:Color = Colors.WHITE;
    public var alpha:Float = 1;

    public var origin:Vector2 = new Vector2(0, 0);
    public var offset:Vector2 = new Vector2(0, 0);

    public var frameWidth:Int = 0;
    public var frameHeight:Int = 0;

    public var width:Int = 0;
    public var height:Int = 0;

    public var antialiasing(default, set):Bool;
    private function set_antialiasing(v:Bool) {
        if(texture != null)
            Rl.setTextureFilter(texture, (v) ? 6 : 0);

        return antialiasing = v;
    }

    public function new(?x:Float = 0, ?y:Float = 0) {
        super(x, y);
        this.animation = new AnimationController(this);
        this.antialiasing = true;
    }

    public function loadGraphicFromTexture(texture:Texture2D, ?width:Int = 0, ?height:Int = 0) {
        if(width > 0 && height > 0) {
            var atlas = new Atlas();
            atlas.texture = texture;
    
            var numRows:Int = (height == 0) ? 1 : Std.int(atlas.texture.height / height);
            var numCols:Int = (width == 0) ? 1 : Std.int(atlas.texture.width / width);
    
            var tileRect:Rectangle;
    
            for (j in 0...numRows) {
                for (i in 0...numCols) {
                    tileRect = Rectangle.create(i * width, j * height, width, height);
                    atlas.frames.push({
                        name: "",
                        x: Std.int(tileRect.x),
                        y: Std.int(tileRect.y),
                        frameX: 0,
                        frameY: 0,
                        width: Std.int(tileRect.width),
                        height: Std.int(tileRect.height)
                    });
                }
            }

            frames = atlas;
            return this;
        }
        else {
            if(this.texture != null) {
                Rl.unloadTexture(this.texture);
                this.texture = null;
            }
            this.texture = texture;
            frameWidth = texture.width;
            frameHeight = texture.height;
            updateHitbox();
        }
        set_antialiasing(antialiasing);
        
        return this;
    }

    public function loadGraphicFromImage(image:Image, ?width:Int = 0, ?height:Int = 0) {
        return loadGraphicFromTexture(Rl.loadTextureFromImage(image), width, height);
    }

    public function loadGraphic(path:String, ?width:Int = 0, ?height:Int = 0) {
        return loadGraphicFromTexture(Rl.loadTexture(path), width, height);
    }

	/**
	 * Helper function to set the graphic's dimensions by using `scale`, allowing you to keep the current aspect ratio
	 * should one of the Integers be `<= 0`. It might make sense to call `updateHitbox()` afterwards!
	 *
	 * @param   width    How wide the graphic should be. If `<= 0`, and `Height` is set, the aspect ratio will be kept.
	 * @param   height   How high the graphic should be. If `<= 0`, and `Width` is set, the aspect ratio will be kept.
	 */
    public function setGraphicSize(width:Int = 0, height:Int = 0):Void {
        if (width <= 0 && height <= 0)
            return;

        var newScaleX:Float = width / frameWidth;
        var newScaleY:Float = height / frameHeight;
        scale.set(newScaleX, newScaleY);

        if (width <= 0)
            scale.x = newScaleY;
        else if (height <= 0)
            scale.y = newScaleX;
    }

    public function updateHitbox() {
		width = Std.int(scale.x * frameWidth);
		height = Std.int(scale.y * frameHeight);
        offset.set(0.5 * (width - frameWidth), 0.5 * (height - frameHeight));
        centerOrigin();
    }

    public function centerOrigin() {
        origin.set(width * 0.5, height * 0.5);
    }

	/**
	 * Updates the sprite's hitbox (`width`, `height`, `offset`) according to the current `scale`.
	 * Also calls `centerOrigin()`.
	 */
    public function screenCenter(?axes:Axes = XY) {
        if(axes.x)
            position.x = (Game.width - (frameWidth * scale.x)) * 0.5;

        if(axes.y)
            position.y = (Game.height - (frameHeight * scale.y)) * 0.5;

        return this;
    }

    public function makeGraphic(width:Int, height:Int, color:Color) {
        texture = Rl.loadTextureFromImage(Rl.genImageColor(width, height, color));
        frameWidth = texture.width;
        frameHeight = texture.height;
        updateHitbox();
        return this;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(frames != null)
            animation.update(elapsed);
    }

    override function draw() {
        super.draw();
        angle %= 360;
        
        var x:Float = (position.x + offset.x);
        var y:Float = (position.y + offset.y);

        color.a = Std.int(alpha * 255);

        if(frames != null) {
            var texture:Texture2D = frames.texture;
            var oldSize = new Vector2(texture.width, texture.height);

            // adjust width and height to scale
            texture.width = Std.int(oldSize.x * scale.x);
            texture.height = Std.int(oldSize.y * scale.y);

            // draw the thing
            @:privateAccess {
                if(animation.reversed && animation.curAnim != null) 
                    animation.curAnim.__frames.reverse();

                var fallbackFrameData:FrameData = {name: "", x: 0, y: 0, frameX: 0, frameY: 0, width: texture.width, height: texture.height};
                
                var frameData:FrameData = null;
                if(animation.curAnim != null)
                    frameData = animation.curAnim.__frames[animation.curAnim.curFrame];
                else
                    frameData = (frames.frames != null) ? frames.frames[0] : fallbackFrameData;
                
                Rl.drawTexturePro(
                    texture, // the texture (woah)
                    Rl.Rectangle.create(frameData.x * scale.x, frameData.y * scale.y, frameData.width * scale.x, frameData.height * scale.y), // the coordinates of x, y, widht, and height FROM the image
                    Rl.Rectangle.create((x + (-frameData.frameX * scale.x)) + (origin.x + (-0.5 * ((frameWidth * scale.x) - frameWidth))), (y + (-frameData.frameY * scale.y)) + (origin.y + (-0.5 * ((frameHeight * scale.y) - frameHeight))), frameData.width * scale.x, frameData.height * scale.y), // where we want to display it on screen + how big it should be
                    Rl.Vector2.create(origin.x, origin.y), // origin shit
                    angle, // rotation
                    Colors.WHITE // tint
                );

                if(animation.reversed && animation.curAnim != null) 
                    animation.curAnim.__frames.reverse();
            }

            // set the width and height back
            texture.width = Std.int(oldSize.x);
            texture.height = Std.int(oldSize.y);
        }
        else {
            texture.width = Std.int(frameWidth * scale.x);
            texture.height = Std.int(frameHeight * scale.y);
            Rl.drawTexturePro(
                texture, 
                Rl.Rectangle.create(0, 0, texture.width, texture.height), 
                Rl.Rectangle.create(x + (origin.x + (-0.5 * ((frameWidth * scale.x) - frameWidth))), y + (origin.y + (-0.5 * ((frameHeight * scale.y) - frameHeight))), texture.width, texture.height), 
                Rl.Vector2.create(origin.x, origin.y), 
                angle, 
                color
            );
        }
    }

    override function destroy() {
        Rl.unloadTexture(texture);
        texture = null;
        offset = null;
        animation.destroy();
        animation = null;
        super.destroy();
    }
}
#end