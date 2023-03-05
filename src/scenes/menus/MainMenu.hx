package scenes.menus;

import engine.Group.TypedGroup;
import scenes.MusicBeat.MusicBeatScene;
import engine.keyboard.Keys;

class MainMenu extends MusicBeatScene {
    public var bg:Sprite;

    public var menuItems:Array<String> = [
        "story mode",
        "freeplay",
        "options"
    ];
    public var grpButtons:TypedGroup<Sprite>;
    public var curSelected:Int = 0;

    override function create() {
        super.create();

        if(Game.sound.music == null || !Game.sound.music.playing)
            Game.sound.playMusic(Paths.music("freakyMenu"), 1);

        add(bg = new Sprite().loadGraphic(Paths.image("menus/menuBG")));
        bg.scale.set(1.2, 1.2);
        bg.updateHitbox();
        bg.screenCenter();

        add(grpButtons = new TypedGroup<Sprite>());

        var buttonSpacing:Float = 300;

        for(i => item in menuItems) {
            var button = new Sprite();
            button.frames = Paths.getSparrowAtlas('menus/mainmenu/$item');
            button.animation.addByPrefix("idle", "idle", 24);
            button.animation.addByPrefix("selected", "selected", 24);
            button.animation.play("idle");
            button.screenCenter();
            button.ID = i;
            button.y += buttonSpacing * i;
            grpButtons.add(button);
        }

        for(i => button in grpButtons.members) {
            button.y -= (buttonSpacing * i) * 0.5;
            button.y -= 150;
        }

        changeSelection(0);
    }

    function changeSelection(?change:Int = 0) {
        curSelected = MathUtil.wrap(curSelected + change, 0, grpButtons.length - 1);

        grpButtons.forEach((button:Sprite) -> {
            button.animation.play((curSelected == button.ID) ? "selected" : "idle");
            button.screenCenter(X);
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Game.keys.justPressed(Keys.UP))
            changeSelection(-1);

        if(Game.keys.justPressed(Keys.DOWN))
            changeSelection(1);

        if(Game.keys.justPressed(Keys.ENTER)) {
            switch(menuItems[curSelected]) {
                case "freeplay":
                    PlayState.SONG = Song.loadChart("fresh", "hard");
                    Game.switchScene(new PlayState());
            }
        }
    }
}