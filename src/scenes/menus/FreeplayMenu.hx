package scenes.menus;

import engine.utilities.Logs;
import funkin.objects.ui.HealthIcon;
import engine.utilities.ColorUtil;
import engine.utilities.Color;
import engine.tweens.Tween;
import engine.math.MathUtil;
import engine.utilities.Assets;
import haxe.Json;
import engine.utilities.typeLimit.OneOfTwo;
import engine.group.Group.TypedGroup;
import funkin.objects.fonts.Alphabet;
import engine.Game;
import engine.Sprite;
import scenes.MusicBeat.MusicBeatScene;

class FreeplayMenu extends MusicBeatScene {
    public var bg:Sprite;
    public var grpSongs:TypedGroup<Alphabet>;
    public var grpIcons:TypedGroup<HealthIcon>;

    public var globalDifficulties:Array<String> = ["easy", "normal", "hard"];
    public var songs:Array<SongMetadata> = [];

    public var curSelected:Int = 0;
    public var curDifficulty:Int = 2;

    public var colorTween:Tween;

    override function create() {
        super.create();

        if(Game.sound.music == null || !Game.sound.music.playing)
            Game.sound.playMusic(Paths.music("freakyMenu"), 1);

        add(bg = new Sprite().loadGraphic(Paths.image("menus/menuBGDesat")));
        bg.screenCenter();

        try {
            var json:Dynamic = Json.parse(Assets.getText(Paths.json("data/freeplaySonglist")));
            var jsonList:Array<OneOfTwo<String, SongMetadata>> = json.list;
            jsonList = jsonList.filter((f) -> {
                return !(f is String);
            });
            globalDifficulties = (json.globalDifficulties != null) ? json.globalDifficulties : ["easy", "normal", "hard"];
            songs = cast jsonList;
        } catch(e) {
            Logs.trace('Failed to load freeplay song list: ${e.toString()}', ERROR);
            songs = [
                {
                    song: "No songs found",
                    character: "face",
                    difficulties: ["error"],
                    color: "#9271FD"
                }
            ];
            globalDifficulties = ["easy", "normal", "hard"];
        }

        add(grpSongs = new TypedGroup<Alphabet>());
        add(grpIcons = new TypedGroup<HealthIcon>());

        for(i => meta in songs) {
            if(meta.displayName == null) meta.displayName = meta.song;
            if(meta.difficulties == null || meta.difficulties.length < 1) meta.difficulties = globalDifficulties;

            var songText = new Alphabet(0, (70 * i) + 30, meta.displayName, true);
            songText.isMenuItem = true;
            songText.targetY = i;
            songText.alpha = 0.6;
            grpSongs.add(songText);

            var songIcon = new HealthIcon(songText.x, songText.y, meta.character);
            songIcon.tracked = songText;
            grpIcons.add(songIcon);
        }

        changeSelection();
    }

    public function changeSelection(change:Int = 0) {
        grpSongs.members[curSelected].alpha = 0.6;
        curSelected = MathUtil.wrap(curSelected + change, 0, grpSongs.length - 1);
        grpSongs.members[curSelected].alpha = 1;

        for(i in 0...grpSongs.length)
            grpSongs.members[i].targetY = i - curSelected;

        if(colorTween != null)
            colorTween.cancel();

        var bgColor:Color = (songs[curSelected].color != null && songs[curSelected].color is Array) 
            ? Color.create(songs[curSelected].color[0], songs[curSelected].color[1], songs[curSelected].color[2], 255) 
            : ColorUtil.fromHexString(songs[curSelected].color);

        colorTween = Tween.color(bg, 0.45, bg.color, bgColor, {onComplete: (twn:Tween) -> {
            colorTween.destroy();
            colorTween = null;
        }});

        Game.sound.play(Paths.sound("menus/scrollMenu"));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(controls.BACK) {
            Game.sound.play(Paths.sound("menus/cancelMenu"));
            Game.switchScene(new MainMenu());
        }
        if(controls.UI_UP) changeSelection(-1);
        if(controls.UI_DOWN) changeSelection(1);

        if(controls.ACCEPT) {
            PlayState.SONG = Song.loadChart(songs[curSelected].song, songs[curSelected].difficulties[curDifficulty]);
            Game.switchScene(new PlayState());
        }
    }
}

typedef SongMetadata = {
    /**
     * The song that actually loads.
     */
    var song:String;

    /**
     * The icon that shows next to the song name in freeplay.
     * Defaults to the `face` icon if the icon couldn't load.
     */
    var character:String;

    /**
     * What the song actually displays as in freeplay.
     * 
     * This is ***optional*** as if you set this to `null`, 
     * It just shows whatever `song` is set to.
     */
    @:optional var displayName:Null<String>;

    /**
     * The color that the background should switch to
     * when this song is selected in freeplay.
     * 
     * Can either be a hex string (`"#FFFFFF"`) or an rgb array (`[255, 0, 80]`).
     */
    var color:OneOfTwo<String, Array<Int>>;

    /**
     * The difficulties that this song has.
     * 
     * Don't set this to anything to use the difficulties from `globalDifficulties`
     * from the freeplay json.
     */
    @:optional var difficulties:Array<String>;
}