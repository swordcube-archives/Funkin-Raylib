package funkin.ui.transitions;

import Rl.Color;
import Rl.Colors;

class FadeTransition extends Transition {
    override function create() {
        super.create();

        var inColor = Colors.BLACK;
        var outColor = Color.create(0, 0, 0, 0);
        if(out) {
            var oldIn = inColor;
            var oldOut = outColor;

            inColor = oldOut;
            outColor = oldIn;
        }

        var sprite = new Sprite().loadGraphicFromImage(Rl.genImageGradientV(Game.width, Game.height, inColor, outColor));
        add(sprite);
    }
}