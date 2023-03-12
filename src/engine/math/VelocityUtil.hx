package engine.math;

#if !macro
import engine.Sprite;
#end

class VelocityUtil {
	/**
	 * Sets the source Sprite x/y velocity so it will move directly towards the destination Sprite at the speed given (in pixels per second)
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.
	 * If you need the object to accelerate, see accelerateTowardsObject() instead
	 * Note: Doesn't take into account acceleration, maxVelocity or drag (if you set drag or acceleration too high this object may not move at all)
	 *
	 * @param	Source		The Sprite on which the velocity will be set
	 * @param	Dest		The Sprite where the source object will move to
	 * @param	Speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	MaxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsObject(Source:#if !macro Sprite #else Dynamic #end, Dest:#if !macro Sprite #else Dynamic #end, Speed:Float = 60, MaxTime:Int = 0):Void {
		var a:Float = AngleUtil.angleBetween(Source, Dest);

		if (MaxTime > 0) {
			var d:Int = MathUtil.distanceBetween(Source, Dest);

			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}

		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}

	/**
	 * Sets the x/y acceleration on the source Sprite so it will move towards the destination Sprite at the speed given (in pixels per second)
	 * You must give a maximum speed value, beyond which the Sprite won't go any faster.
	 * If you don't need acceleration look at moveTowardsObject() instead.
	 *
	 * @param	Source			The Sprite on which the acceleration will be set
	 * @param	Dest			The Sprite where the source object will move towards
	 * @param	Acceleration	The speed it will accelerate in pixels per second
	 * @param	MaxSpeed		The maximum speed in pixels per second in which the sprite can move
	 */
	public static function accelerateTowardsObject(Source:#if !macro Sprite #else Dynamic #end, Dest:#if !macro Sprite #else Dynamic #end, Acceleration:Float, MaxSpeed:Float):Void {
		var a:Float = AngleUtil.angleBetween(Source, Dest);
		accelerateFromAngle(Source, a, Acceleration, MaxSpeed);
	}

	#if FLX_MOUSE
	/**
	 * Move the given Sprite towards the mouse pointer coordinates at a steady velocity
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.
	 *
	 * @param	Source		The Sprite to move
	 * @param	Speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	MaxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsMouse(Source:#if !macro Sprite #else Dynamic #end, Speed:Float = 60, MaxTime:Int = 0):Void {
		var a:Float = AngleUtil.angleBetweenMouse(Source);

		if (MaxTime > 0) {
			var d:Int = MathUtil.distanceToMouse(Source);

			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}

		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}
	#end

	#if FLX_TOUCH
	/**
	 * Move the given Sprite towards a FlxTouch point at a steady velocity
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.
	 *
	 * @param	source			The Sprite to move
	 * @param	speed				The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	maxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsTouch(Source:#if !macro Sprite #else Dynamic #end, Touch:FlxTouch, Speed:Float = 60, MaxTime:Int = 0):Void {
		var a:Float = AngleUtil.angleBetweenTouch(Source, Touch);

		if (MaxTime > 0) {
			var d:Int = MathUtil.distanceToTouch(Source, Touch);

			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}

		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}
	#end

	#if FLX_MOUSE
	/**
	 * Sets the x/y acceleration on the source Sprite so it will move towards the mouse coordinates at the speed given (in pixels per second)
	 * You must give a maximum speed value, beyond which the Sprite won't go any faster.
	 * If you don't need acceleration look at moveTowardsMouse() instead.
	 *
	 * @param	Source			The Sprite on which the acceleration will be set
	 * @param	Acceleration			The speed it will accelerate in pixels per second
	 * @param	MaxSpeed		The maximum speed in pixels per second in which the sprite can move
	 */
	public static function accelerateTowardsMouse(Source:#if !macro Sprite #else Dynamic #end, Acceleration:Float, MaxSpeed:Float):Void {
		var a:Float = AngleUtil.angleBetweenMouse(Source);

		accelerateFromAngle(Source, a, Acceleration, MaxSpeed);
	}
	#end

	#if FLX_TOUCH
	/**
	 * Sets the x/y acceleration on the source Sprite so it will move towards a FlxTouch at the speed given (in pixels per second)
	 * You must give a maximum speed value, beyond which the Sprite won't go any faster.
	 * If you don't need acceleration look at moveTowardsMouse() instead.
	 *
	 * @param	Source			The Sprite on which the acceleration will be set
	 * @param	Touch			The FlxTouch on which to accelerate towards
	 * @param	Acceleration	The speed it will accelerate in pixels per second
	 * @param	MaxSpeed		The maximum speed in pixels per second in which the sprite can move
	 */
	public static function accelerateTowardsTouch(Source:#if !macro Sprite #else Dynamic #end, Touch:FlxTouch, Acceleration:Float, MaxSpeed:Float):Void {
		var a:Float = AngleUtil.angleBetweenTouch(Source, Touch);

		accelerateFromAngle(Source, a, Acceleration, MaxSpeed);
	}
	#end

	/**
	 * Sets the x/y velocity on the source Sprite so it will move towards the target coordinates at the speed given (in pixels per second)
	 * If you specify a maxTime then it will adjust the speed (over-writing what you set) so it arrives at the destination in that number of seconds.
	 * Timings are approximate due to the way Flash timers work, and irrespective of SWF frame rate. Allow for a variance of +- 50ms.
	 * The source object doesn't stop moving automatically should it ever reach the destination coordinates.
	 *
	 * @param	Source		The Sprite to move
	 * @param	Target		The Point2D coordinates to move the source Sprite towards
	 * @param	Speed		The speed it will move, in pixels per second (default is 60 pixels/sec)
	 * @param	MaxTime		Time given in milliseconds (1000 = 1 sec). If set the speed is adjusted so the source will arrive at destination in the given number of ms
	 */
	public static function moveTowardsPoint(Source:#if !macro Sprite #else Dynamic #end, Target:Point2D, Speed:Float = 60, MaxTime:Int = 0):Void {
		var a:Float = AngleUtil.angleBetweenPoint(Source, Target);

		if (MaxTime > 0) {
			var d:Int = MathUtil.distanceToPoint(Source, Target);

			//	We know how many pixels we need to move, but how fast?
			Speed = Std.int(d / (MaxTime / 1000));
		}

		Source.velocity.x = Math.cos(a) * Speed;
		Source.velocity.y = Math.sin(a) * Speed;
	}

	/**
	 * Sets the x/y acceleration on the source Sprite so it will move towards the target coordinates at the speed given (in pixels per second)
	 * You must give a maximum speed value, beyond which the Sprite won't go any faster.
	 * If you don't need acceleration look at moveTowardsPoint() instead.
	 *
	 * @param	Source			The Sprite on which the acceleration will be set
	 * @param	Target			The Point2D coordinates to move the source Sprite towards
	 * @param	Acceleration	The speed it will accelerate in pixels per second
	 * @param	MaxSpeed		The maximum speed in pixels per second in which the sprite can move
	 */
	public static function accelerateTowardsPoint(Source:#if !macro Sprite #else Dynamic #end, Target:Point2D, Acceleration:Float, MaxSpeed:Float):Void {
		var a:Float = AngleUtil.angleBetweenPoint(Source, Target);

		accelerateFromAngle(Source, a, Acceleration, MaxSpeed);
	}

	/**
	 * Given the angle and speed calculate the velocity and return it as an Point2D
	 *
	 * @param	Angle	The angle (in degrees) calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * @param	Speed	The speed it will move, in pixels per second sq
	 * @return	A Point2D where Point2D.x contains the velocity x value and Point2D.y contains the velocity y value
	 */
	public static inline function velocityFromAngle(Angle:Float, Speed:Float):Point2D {
		var a:Float = AngleUtil.asRadians(Angle);

		return new Point2D(Math.cos(a) * Speed, Math.sin(a) * Speed);
	}

	/**
	 * Given the Sprite and speed calculate the velocity and return it as an Point2D based on the direction the sprite is facing
	 *
	 * @param	Parent	The Sprite to get the facing value from
	 * @param	Speed	The speed it will move, in pixels per second
	 * @return	An Point2D where Point2D.x contains the velocity x value and Point2D.y contains the velocity y value
	 */
	public static function velocityFromFacing(Parent:#if !macro Sprite #else Dynamic #end, Speed:Float):Point2D {
		return new Point2D().setPolarDegrees(Speed, Parent.facing.degrees);
	}

	/**
	 * A tween-like function that takes a starting velocity and some other factors and returns an altered velocity.
	 *
	 * @param	Velocity		Any component of velocity (e.g. 20).
	 * @param	Acceleration		Rate at which the velocity is changing.
	 * @param	Drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
	 * @param	Max				An absolute value cap for the velocity (0 for no cap).
	 * @param	Elapsed			The amount of time passed in to the latest update cycle
	 * @return	The altered Velocity value.
	 */
	public static function computeVelocity(Velocity:Float, Acceleration:Float, Drag:Float, Max:Float, Elapsed:Float):Float {
		if (Acceleration != 0) {
			Velocity += Acceleration * Elapsed;
		} else if (Drag != 0) {
			var drag:Float = Drag * Elapsed;
			if (Velocity - drag > 0) {
				Velocity -= drag;
			} else if (Velocity + drag < 0) {
				Velocity += drag;
			} else {
				Velocity = 0;
			}
		}
		if ((Velocity != 0) && (Max != 0)) {
			if (Velocity > Max) {
				Velocity = Max;
			} else if (Velocity < -Max) {
				Velocity = -Max;
			}
		}
		return Velocity;
	}

	/**
	 * Sets the x/y acceleration on the source Sprite so it will accelerate in the direction of the specified angle.
	 * You must give a maximum speed value (in pixels per second), beyond which the Sprite won't go any faster.
	 *
	 * @param	Source			The Sprite on which the acceleration will be set
	 * @param	Radians			The angle in which the Point2D will be set to accelerate
	 * @param	Acceleration	The speed it will accelerate in pixels per second
	 * @param	MaxSpeed		The maximum speed in pixels per second in which the sprite can move
	 * @param	ResetVelocity	Whether to reset the Sprite velocity to 0 each time
	 */
	public static inline function accelerateFromAngle(source:#if !macro Sprite #else Dynamic #end, radians:Float, acceleration:Float, maxSpeed:Float, resetVelocity:Bool = true):Void {
		var sinA = Math.sin(radians);
		var cosA = Math.cos(radians);

		if (resetVelocity)
			source.velocity.set(0, 0);

		source.acceleration.set(cosA * acceleration, sinA * acceleration);
		source.maxVelocity.set(Math.abs(cosA * maxSpeed), Math.abs(sinA * maxSpeed));
	}
}
