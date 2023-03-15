package engine;

import engine.graphics.BlendMode;
import engine.math.Point4D;
import engine.math.MathUtil;
import engine.utilities.DirectionFlags;
import engine.utilities.AssetCache.CacheMap;
import engine.utilities.Atlas;
import engine.utilities.Axes;
import engine.graphics.FileShader;
import engine.managers.AnimationController;
import engine.math.Point2D;
import engine.utilities.Colors;
import engine.utilities.Color;

#if !macro
import Rl.Image;
import Rl.Texture2D;
import Rl.Rectangle;
#end

class Sprite extends Object {
	/**
	 * The atlas used to animate the sprite.
	 */
	public var frames(default, set):Atlas;

	private function set_frames(atlas:Atlas) {
		#if !macro
		texture = atlas.texture;
		frameWidth = atlas.frames[0].width;
		frameHeight = atlas.frames[0].height;
		updateHitbox();
		set_antialiasing(antialiasing);
		#end

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
	public var texture:#if !macro Texture2D #else Dynamic #end;

	/**
	* A custom shader for the sprite.
	* Set to `null` to use the default shader.
	*/
	public var shader:FileShader = null;

	/**
	 * How small or big the sprite is.
	 */
	public var scale:Point2D = new Point2D(1, 1);

	/**
	 * Tints the sprite to a color.
	 */
	public var color(default, set):#if !macro Color = Colors.WHITE #else Dynamic = null #end;

	@:noCompletion
	private function set_color(v:#if !macro Color #else Dynamic #end) {
		return color = v;
	}

	/**
	 * Clipping rectangle for this sprite.
	 * Changing the rect's properties directly doesn't have any effect,
	 * reassign the property to update it (`sprite.clipRect = sprite.clipRect;`).
	 * Set to `null` to discard graphic frame clipping.
	 */
	public var clipRect(default, set):Point4D = new Point4D();

	@:noCompletion
	private function set_clipRect(v:Point4D):Point4D {
		return clipRect = v;
	}

	/**
	 * The transparency of the sprite.
     * 
     * 0 = Invisible
     * 1 = Fully Visible
	 */
	public var alpha(default, set):Float = 1;

	@:noCompletion
	private function set_alpha(v:Float):Float {
		return alpha = v;
	}

	/**
	 * The origin at which the sprite should rotate at.
	 */
	public var origin:Point2D = new Point2D(0, 0);

	/**
	 * The position of the sprite's graphic relative to its hitbox. For example, `offset.x = 10;` will
	 * show the graphic 10 pixels right (left if `flipOffsets` is set to `true`) of the hitbox.
	 * 
	 * Likely needs to be adjusted after changing a sprite's `width`, `height` or `scale`.
	 */
	public var offset:Point2D = new Point2D(0, 0);

	/**
	 * Whether or not you want this sprite's offsets to act like `HaxeFlixel`,
	 * where negative = right/down + positive = left/up
	 */
	public var flipOffsets:Bool = false;

	/**
	 * How much the sprite moves with the camera.
	 * Can be used for parallax.
	 */
	public var scrollFactor:Point2D = new Point2D(1, 1);

	/**
	 * The width of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 */
	public var frameWidth:Int = 0;

	/**
	 * The height of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 */
	public var frameHeight:Int = 0;

	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 */
	public var antialiasing(default, set):Bool;

	@:noCompletion
	private function set_antialiasing(v:Bool) {
		#if !macro
		if (texture != null)
			Rl.setTextureFilter(texture, (v) ? 1 : 0);
		#end

		return antialiasing = v;
	}

	/**
	 * Blending modes, just like Photoshop or whatever, e.g. "multiply", "add", etc.
	 */
	public var blend:BlendMode = ALPHA;

    /**
	 * Can be set to `LEFT`, `RIGHT`, `UP`, and `DOWN` to take advantage
	 * of flipped sprites and/or just track player orientation more easily.
	 */
	public var facing(default, set):DirectionFlags = RIGHT;

	@:noCompletion
	private function set_facing(v:Int):Int {
		return facing = v;
	}

	/**
	 * Whether this sprite is flipped on the X axis.
	 */
    public var flipX(default, set):Bool = false;

	@:noCompletion
	private function set_flipX(v:Bool):Bool {
		return flipX = v;
	}

     /**
      * Whether this sprite is flipped on the Y axis.
      */
    public var flipY(default, set):Bool = false;

	@:noCompletion
	private function set_flipY(v:Bool):Bool {
		return flipY = v;
	}

	public static var defaultAntialiasing:Bool = true;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);
		this.animation = new AnimationController(this);
		this.antialiasing = defaultAntialiasing;
	}

	public function loadGraphicFromTexture(texture:#if !macro Texture2D #else Dynamic #end, ?width:Int = 0, ?height:Int = 0) {
		#if !macro
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
		#end

		return this;
	}

	public function loadGraphicFromImage(image:#if !macro Image #else Dynamic #end, ?width:Int = 0, ?height:Int = 0) {
		#if !macro
		return loadGraphicFromTexture(Rl.loadTextureFromImage(image), width, height);
		#else
		return this;
		#end
	}

	public function loadGraphic(path:String, width:Int = 0, height:Int = 0) {
		#if !macro
		var cacheMap:CacheMap = Game.assetCache.cachedAssets.get(IMAGE);
		var texture:Texture2D = null;

		if (cacheMap.exists(path))
			texture = cacheMap.get(path).asset;
		else {
			texture = Rl.loadTexture(path);
			Game.assetCache.cache(IMAGE, path, texture);
		}
		return loadGraphicFromTexture(texture, width, height);
		#else
		return this;
		#end
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
		if(flipOffsets)
			offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		else 
			offset.set(0.5 * (width - frameWidth), 0.5 * (height - frameHeight));

		centerOrigin();
	}

	/**
	 * Helper function that adjusts the offset automatically to center the bounding box within the graphic.
	 *
	 * @param   AdjustPosition   Adjusts the actual X and Y position just once to match the offset change.
	 */
	public function centerOffsets(AdjustPosition:Bool = false):Void {
		offset.x = (frameWidth - width) * (flipOffsets ? 0.5 : -0.5);
		offset.y = (frameHeight - height) * (flipOffsets ? 0.5 : -0.5);

		if (AdjustPosition) {
			if(flipOffsets) {
				x += offset.x;
				y += offset.y;
			} else {
				x -= offset.x;
				y -= offset.y;
			}
		}
	}

	/**
	 * Sets the sprite's origin to its center - useful after adjusting
	 * `scale` to make sure rotations work as expected.
	 */
	 public function centerOrigin() {
		origin.set(width * 0.5, height * 0.5);
	}

	public function makeGraphic(width:Int, height:Int, color:#if !macro Color #else Dynamic #end = null) {
		#if !macro
		if (color == null)
			color = Colors.WHITE;

		texture = Rl.loadTextureFromImage(Rl.genImageColor(width, height, color));
		frameWidth = texture.width;
		frameHeight = texture.height;
		updateHitbox();
		#end
		return this;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (frames != null)
			animation.update(elapsed);
	}

	override function draw() {
		super.draw();
		if(cameras == null) cameras = [];
		
		for(camera in cameras)
			drawOnCamera(camera);
	}

	/**
	 * Queues the camera to draw the sprite onto a specific camera.
	 * You have to do `camera.draw()` to get the camera to actually draw anything.
	 * 
	 * @param camera The camera to draw this sprite onto.
	 */
	public function drawOnCamera(camera:Camera) {
		#if !macro
		if(!(Game.cameras.list.contains(camera) || camera == Game.camera)) return;

		camera.renderQueue.push(() -> {
			if(!camera.isOnScreen(this)) return;

			@:privateAccess {
				Rl.beginBlendMode(blend);
				Rl.beginMode2D(camera.__rlCamera);
			}
	
			var ogAngle:Float = angle;
			angle %= 360;
	
			var camOffset:Rl.Vector2 = camera.getCamOffsets(width, height);
	
			scale.x *= camera.zoom;
			scale.y *= camera.zoom;
			if (flipX) scale.x *= -1;
			if (flipY) scale.y *= -1;
			if (shader != null) Rl.beginShaderMode(shader.actualShader);
	
			var correctedPos = Rl.Vector2.create(
				(position.x + (flipOffsets ? -offset.x : offset.x) / camera.zoom - Game.width * 0.5) * camera.zoom + Game.width * 0.5,
				(position.y + (flipOffsets ? -offset.x : offset.y) / camera.zoom - Game.height * 0.5) * camera.zoom + Game.height * 0.5
			);
	
			color.a = Std.int(alpha * 255);
	
			if (frames != null) {
				var texture:Texture2D = frames.texture;
	
				// TODO: fix all of this to work with negative scales correctly
				// (it should just display the sprite but flipped on x and/or y axis)
				//hi i sorta fixed this :D -srt
	
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
						width: texture.width,
						height: texture.height
					};
	
					var frameData:FrameData = null;
					var animOffsetX:Float = 0;
					var animOffsetY:Float = 0;
					if (animation.curAnim != null) {
						frameData = animation.curAnim.__frames[animation.curAnim.curFrame];
						animOffsetX = animation.curAnim.offset.x;
						animOffsetY = animation.curAnim.offset.y;
					} else
						frameData = (frames.frames != null) ? frames.frames[0] : fallbackFrameData;
	
					var sin = Math.sin(angle / -180 * MathUtil.STANDARD_PI);
					var cos = Math.cos(angle / 180 * MathUtil.STANDARD_PI);
					var increments = [0.0, 0.0];
					if (scale.y < 0) {
						increments[0] = sin * -1;
						increments[1] = cos * -1;
					}
					var frameOffsetCoords = [
						(-frameData.frameX * Math.abs(scale.x) - animOffsetX * Math.abs(scale.x) + camOffset.x) * cos + (-frameData.frameY * Math.abs(scale.y) - animOffsetY * Math.abs(scale.y) + camOffset.y) * (sin + increments[0]),
						(-frameData.frameX * Math.abs(scale.x) - animOffsetX * Math.abs(scale.x) + camOffset.x) * -sin + (-frameData.frameY * Math.abs(scale.y) - animOffsetY * Math.abs(scale.y) + camOffset.y) * (cos + increments[1])
					];
	
					var adjustedPos:Rl.Vector2 = camera.adjustToCamera(Rl.Vector2.create(
						(correctedPos.x + frameOffsetCoords[0]) + (origin.x + (-0.5 * ((frameWidth * Math.abs(scale.x)) - frameWidth))), 
						(correctedPos.y + frameOffsetCoords[1]) + (origin.y + (-0.5 * ((frameHeight * Math.abs(scale.y)) - frameHeight)))
					), camOffset.x, camOffset.y, scrollFactor);
					
					Rl.drawTexturePro(texture, // the texture (woah)
						Rl.Rectangle.create(
							frameData.x, 
							frameData.y, 
							frameData.width * (scale.x < 0 ? -1 : 1),
							frameData.height * (scale.y < 0 ? -1 : 1)
						), // the coordinates of x, y, width, and height FROM the image
						Rl.Rectangle.create(
							MathUtil.roundDecimal(adjustedPos.x, 2),
							MathUtil.roundDecimal(adjustedPos.y, 2),
							MathUtil.absInt(Std.int(frameData.width * Math.abs(scale.x))),
							MathUtil.absInt(Std.int(frameData.height * Math.abs(scale.y)))
						), // where we want to display it on screen + how big it should be
						Rl.Vector2.create(origin.x, origin.y), // origin shit
						angle, // rotation
						color // tint
					);
	
					if (animation.reversed && animation.curAnim != null)
						animation.curAnim.__frames.reverse();
				}
			} else {
				@:privateAccess
				var adjustedPos = camera.adjustToCamera(Rl.Vector2.create(
					correctedPos.x + (origin.x + (-0.5 * ((frameWidth * Math.abs(scale.x)) - frameWidth))),
					correctedPos.y + (origin.y + (-0.5 * ((frameHeight * Math.abs(scale.y)) - frameHeight)))
				), camOffset.x, camOffset.y, scrollFactor);
	
				Rl.drawTexturePro(
					texture, 
					Rl.Rectangle.create(
						0, 
						0, 
						texture.width * (scale.x < 0 ? -1 : 1), 
						texture.height * (scale.y < 0 ? -1 : 1)
					),
					Rl.Rectangle.create(
						adjustedPos.x,
						adjustedPos.y,
						MathUtil.absInt(Std.int(texture.width * scale.x)), 
						MathUtil.absInt(Std.int(texture.height * scale.y))
					),
					Rl.Vector2.create(origin.x, origin.y), 
					angle, 
					color
				);
			}
	
			angle = ogAngle;
			scale.x /= camera.zoom;
			scale.y /= camera.zoom;
			if (flipX) scale.x *= -1;
			if (flipY) scale.y *= -1;
			if (shader != null) Rl.endShaderMode();
	
			Rl.endBlendMode();
			Rl.endMode2D();
		});
		#end
	}

	override function destroy() {
		if (shader != null) {
			shader.destroy();
			shader = null;
		}
		texture = null;
		offset = null;
		animation.destroy();
		animation = null;
		super.destroy();
	}
}