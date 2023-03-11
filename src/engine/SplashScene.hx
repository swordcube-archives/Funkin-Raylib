package engine;

import engine.utilities.Timer;
import engine.tweens.Ease;
import engine.tweens.Tween;
import engine.graphics.FileShader;

class SplashScene extends engine.Scene {
    var icon:Sprite;
    var textFont:Rl.Font;

    override public function create() {
        super.create();

        textFont = Rl.loadFont("./assets/droplet/fonts/gothamRoundedBook.otf");

        icon = new Sprite();
        icon.loadGraphic('./assets/droplet/images/logo_outline_glow.png');
        icon.scale.set(0.85, 0.85);
        icon.updateHitbox();
        icon.screenCenter();
        add(icon);

        icon.shader = new FileShader('./assets/droplet/shaders/logoShader.fs');
        icon.shader.setUniform("alphaMult", 0);
        icon.shader.setUniform("percent", 0);
    }

    var time:Float = 0;
    var didFlash:Bool = false;
    var textY:Float = 360;
    var textAlpha:Float = 0;
    override public function update(elapsed:Float) {
        super.update(elapsed);
        
        time += elapsed * 4;
        icon.shader.setUniform("time", time);
        icon.shader.setUniform("percent", time / 6);

        if (time >= 6 && !didFlash) {
            didFlash = true;
            icon.shader.setUniform("alphaMult", 2);
            textY = Game.height / 2;
            Tween.tween(this, {textY: Game.height * 0.8, textAlpha: 1}, 0.35, {ease: Ease.circOut});
            Tween.num(2, 1, 0.5, {ease: Ease.circOut}, (num:Float) -> {icon.shader.setUniform("alphaMult", num);});
            Tween.tween(this, {"icon.alpha": 0, textAlpha: 0}, 1, {startDelay: 1, onComplete: function(twn:Tween) {
                Game.switchScene(Type.createInstance(Game.initialScene, []));
            }});
        }
    }

    override public function draw() {
        if (time >= 6) {
            var text:String = "droplet";
            var fontSize:Int = Std.int(48 + 16 * ((textY - 360) / 220)); // Not using textAlpha as that messes with the fade.
    
            var textWidth = Rl.measureTextEx(textFont, text, fontSize, 0);
            Rl.drawTextEx(textFont, text, Rl.Vector2.create((Game.width - textWidth.x) * 0.5 - 20, textY), fontSize, 0, Color.create(246, 91, 146, Std.int(255 * textAlpha)));
        }

        super.draw();
    }
}