package scenes.menus;

import scenes.MusicBeat.MusicBeatScene;
import engine.keyboard.Keys;
import engine.Sprite;

class TitleScreen extends MusicBeatScene {
    var logo:Sprite;
    var gfDance:Sprite;
    var titleEnter:Sprite;

    var confirmed:Bool = false;

    override function create() {
        super.create();

        if(Game.sound.music == null || !Game.sound.music.playing)
            Game.sound.playMusic(Paths.music("freakyMenu"));

        Conductor.changeBPM(102);

        add(logo = new Sprite(-150, -100));
        logo.frames = Paths.getSparrowAtlas("menus/title/logoBumpin");
        logo.animation.addByPrefix("bump", "logo bumpin", 24, false);
        logo.animation.play("bump");

        add(gfDance = new Sprite(Game.width * 0.4, Game.height * 0.07));
        gfDance.frames = Paths.getSparrowAtlas("menus/title/gfDanceTitle");
        gfDance.animation.addByIndices("danceLeft", "gfDance", [for(i in 0...15) i], 24, false);
        gfDance.animation.addByIndices("danceRight", "gfDance", [for(i in 15...30) i], 24, false);
        gfDance.animation.play("danceLeft");

        add(titleEnter = new Sprite(100, Game.height * 0.8));
        titleEnter.frames = Paths.getSparrowAtlas("menus/title/titleEnter");
        titleEnter.animation.addByPrefix("idle", "Press Enter to Begin", 24);
        titleEnter.animation.addByPrefix("press", "ENTER PRESSED", 24);
        titleEnter.animation.play("idle");
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        Conductor.position = Game.sound.music.time;

        if(Game.keys.justPressed(Keys.ENTER) && !confirmed) {
            confirmed = true;
            titleEnter.animation.play("press");
            Game.sound.play(Paths.sound("menus/confirmMenu"));
            new Timer().start(2, (timer:Timer) -> {
                Game.switchScene(new MainMenu());
            });
        }
    }

    override function beatHit(curBeat:Int) {
        logo.animation.play("bump", true);
        gfDance.animation.play((curBeat % 2 == 0) ? "danceRight" : "danceLeft");

        super.beatHit(curBeat);
    }
}
