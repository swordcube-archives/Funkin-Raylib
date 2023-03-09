package engine;

import engine.utilities.AssetCache.CacheMap;
import engine.utilities.Atlas;
import engine.utilities.Axes;
import engine.utilities.AnimationController;
import engine.math.Point2D;
#if !macro
import Rl.Image;
import Rl.Colors;
import Rl.Color;
import Rl.Texture2D;
import Rl.Rectangle;

class Sprite extends Object {
	/**
	 * The atlas used to animate the sprite.
	 */
	public var frames(default, set):Atlas;

	private function set_frames(atlas:Atlas) {
		texture = atlas.texture;
		frameWidth = atlas.frames[0].width;
		frameHeight = atlas.frames[0].height;
		updateHitbox();
		set_antialiasing(antialiasing);

		return frames = atlas;
	}

	/**
	 * Allows you to add, remove, and play animations!
	 */
	public var animation:AnimationController;

	/**
	 * The texture used to draw this sprite.
     * Unused if `frames` isn't `null`.
	 */
	public var texture:Texture2D;

	/**
	 * How small or big the sprite is.
	 */
	public var scale:Point2D = new Point2D(1, 1);

	/**
	 * Tints the sprite to a color.
	 */
	public var color:Color = Colors.WHITE;

	/**
	 * The transparency of the sprite.
     * 
     * 0 = Invisible
     * 1 = Fully Visible
	 */
	public var alpha:Float = 1;

	/**
	 * The origin at which the sprite should rotate at.
	 */
	public var origin:Point2D = new Point2D(0, 0);

	/**
	 * The position of the sprite's graphic relative to its hitbox. For example, `offset.x = 10;` will
	 * show the graphic 10 pixels left of the hitbox. Likely needs to be adjusted after changing a sprite's
	 * `width`, `height` or `scale`.
	 */
	public var offset:Point2D = new Point2D(0, 0);

	/**
	 * The width of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 */
	public var frameWidth:Int = 0;

	/**
	 * The height of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 */
	public var frameHeight:Int = 0;

	/**
	 * The width of this object's hitbox. For sprites, use `offset` to control the hitbox position.
	 */
	public var width:Int = 0;

	/**
	 * The height of this object's hitbox. For sprites, use `offset` to control the hitbox position.
	 */
	public var height:Int = 0;

	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 */
	public var antialiasing(default, set):Bool;

	private function set_antialiasing(v:Bool) {
		if (texture != null)
			Rl.setTextureFilter(texture, (v) ? 1 : 0);

		return antialiasing = v;
	}

    /**
	 * Can be set to `LEFT`, `RIGHT`, `UP`, and `DOWN` to take advantage
	 * of flipped sprites and/or just track player orientation more easily.
	 */
	public var facing:DirectionFlags = RIGHT;

	/**
	 * Whether this sprite is flipped on the X axis.
	 */
    public var flipX:Bool = false;

     /**
      * Whether this sprite is flipped on the Y axis.
      */
    public var flipY:Bool = false;

	public static var defaultAntialiasing:Bool = true;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);
		this.animation = new AnimationController(this);
		this.antialiasing = defaultAntialiasing;
	}

	public function loadGraphicFromTexture(texture:Texture2D, ?width:Int = 0, ?height:Int = 0) {
		if (width > 0 && height > 0) {
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
		} else {
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
		var cacheMap:CacheMap = Game.assetCache.cachedAssets.get(IMAGE);
		var texture:Texture2D = null;

		if (cacheMap.exists(path))
			texture = cacheMap.get(path).asset;
		else {
			texture = Rl.loadTexture(path);
			Game.assetCache.cache(IMAGE, path, texture);
		}
		return loadGraphicFromTexture(texture, width, height);
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

	/**
	 * Updates the sprite's hitbox (`width`, `height`, `offset`) according to the current `scale`.
	 * Also calls `centerOrigin()`.
	 */
	public function updateHitbox() {
		width = Std.int(Math.abs(scale.x) * frameWidth);
		height = Std.int(Math.abs(scale.y) * frameHeight);
		offset.set(0.5 * (width - frameWidth), 0.5 * (height - frameHeight));
		centerOrigin();
	}

	/**
	 * Helper function that adjusts the offset automatically to center the bounding box within the graphic.
	 *
	 * @param   AdjustPosition   Adjusts the actual X and Y position just once to match the offset change.
	 */
	public function centerOffsets(AdjustPosition:Bool = false):Void {
		offset.x = (frameWidth - width) * -0.5;
		offset.y = (frameHeight - height) * -0.5;
		if (AdjustPosition) {
			x += offset.x;
			y += offset.y;
		}
	}

	/**
	 * Sets the sprite's origin to its center - useful after adjusting
	 * `scale` to make sure rotations work as expected.
	 */
	public function centerOrigin() {
		origin.set(width * 0.5, height * 0.5);
	}

	/**
	 * Updates the sprite's hitbox (`width`, `height`, `offset`) according to the current `scale`.
	 * Also calls `centerOrigin()`.
	 */
	public function screenCenter(?axes:Axes = XY) {
		if (axes.x)
			position.x = (Game.width - width) * 0.5;

		if (axes.y)
			position.y = (Game.height - height) * 0.5;

		return this;
	}

	public function makeGraphic(width:Int, height:Int, ?color:Color) {
		if (color == null)
			color = Colors.WHITE;

		texture = Rl.loadTextureFromImage(Rl.genImageColor(width, height, color));
		frameWidth = texture.width;
		frameHeight = texture.height;
		updateHitbox();
		return this;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (frames != null)
			animation.update(elapsed);
	}

	override function draw() {
		super.draw();
		angle %= 360;

		if(flipX) scale.x *= -1;
		if(flipY) scale.y *= -1;

		var x:Float = (position.x + offset.x);
		var y:Float = (position.y + offset.y);

		color.a = Std.int(alpha * 255);

		if (frames != null) {
			var texture:Texture2D = frames.texture;
			var oldSize = new Point2D(texture.width, texture.height);

            // TODO: fix all of this to work with negative scales correctly
            // (it should just display the sprite but flipped on x and/or y axis)

			// draw the thing
			@:privateAccess {
				if (animation.reversed && animation.curAnim != null)
					animation.curAnim.__frames.reverse();

				var fallbackFrameData:FrameData = {
					name: "",
					x: 0,
					y: 0,
					frameX: 0,
					frameY: 0,
					width: MathUtil.absInt(texture.width),
					height: MathUtil.absInt(texture.height)
				};

				var frameData:FrameData = null;
				if (animation.curAnim != null)
					frameData = animation.curAnim.__frames[animation.curAnim.curFrame];
				else
					frameData = (frames.frames != null) ? frames.frames[0] : fallbackFrameData;

				var sin = Math.sin(angle / -180 * MathUtil.STANDARD_PI);
				var cos = Math.cos(angle / 180 * MathUtil.STANDARD_PI);
				var testCoords = [
					(-frameData.frameX * Math.abs(scale.x)) * cos + (-frameData.frameY * Math.abs(scale.y)) * sin,
					(-frameData.frameX * Math.abs(scale.x)) * -sin + (-frameData.frameY * Math.abs(scale.y)) * cos
				];
				Rl.drawTexturePro(texture, // the texture (woah)
					Rl.Rectangle.create(
                        frameData.x, 
                        frameData.y, 
                        frameData.width * (scale.x < 0 ? -1 : 1),
						frameData.height * (scale.y < 0 ? -1 : 1)
                    ), // the coordinates of x, y, width, and height FROM the image
					Rl.Rectangle.create(
                        (x + testCoords[0]) + (origin.x + (-0.5 * ((frameWidth * Math.abs(scale.x)) - frameWidth))),
						(y + testCoords[1]) + (origin.y + (-0.5 * ((frameHeight * Math.abs(scale.y)) - frameHeight))), 
                        frameData.width * Math.abs(scale.x),
						frameData.height * Math.abs(scale.y)
                    ), // where we want to display it on screen + how big it should be
					Rl.Vector2.create(origin.x, origin.y), // origin shit
					angle, // rotation
					color // tint
				);

				if (animation.reversed && animation.curAnim != null)
					animation.curAnim.__frames.reverse();
			}
		} else {
			texture.width = Std.int(frameWidth * scale.x);
			texture.height = Std.int(frameHeight * scale.y);
			Rl.drawTexturePro(
                texture, 
                Rl.Rectangle.create(0, 0, MathUtil.absInt(texture.width), MathUtil.absInt(texture.height)),
				Rl.Rectangle.create(
                    x + (origin.x + (-0.5 * ((frameWidth * Math.abs(scale.x)) - frameWidth))),
					y + (origin.y + (-0.5 * ((frameHeight * Math.abs(scale.y)) - frameHeight))), 
                    MathUtil.absInt(texture.width), 
                    MathUtil.absInt(texture.height)
                ),
				Rl.Vector2.create(origin.x, origin.y), 
                angle, color
            );
		}

		if(flipX) scale.x *= -1;
		if(flipY) scale.y *= -1;
	}

	override function destroy() {
		texture = null;
		offset = null;
		animation.destroy();
		animation = null;
		super.destroy();
	}
}
#end
