package scenes;

import funkin.backend.hscript.HScript;
import engine.keyboard.Keys;
import funkin.objects.ui.NoteField;
import engine.tweens.Ease;
import engine.tweens.Tween;
import funkin.objects.ui.Note;
import funkin.objects.ui.Receptor;
import engine.Group.TypedGroup;
import scenes.MusicBeat.MusicBeatScene;
import scenes.menus.*;
import engine.sound.MusicEx;
import funkin.song.SongFormat.SongData;
import engine.utilities.Timer;
import engine.math.MathUtil;
import engine.Camera;
import engine.Object;
import engine.Game;
import engine.Sprite;

class PlayState extends MusicBeatScene {
    public static var current:PlayState;
    public static var SONG:SongData;

    public var startingSong:Bool = true;
    public var endingSong:Bool = false;

    public var inst:MusicEx;
    public var vocals:MusicEx;

    public var startTimer:Timer;

    public var cpuStrums:TypedGroup<Receptor>;
    public var playerStrums:TypedGroup<Receptor>;
    public var notes:NoteField;

    public var camHUD:Camera;
    var camFollow:Object;

    public var unspawnNotes:Array<Note> = [];
    public var scrollSpeed:Float = 2.7;
    public var defaultCamZoom:Float = 0.9;

    public var scripts:Array<HScript> = [];

    override function create() {
        super.create();
        current = this;

        Game.sound.music.stop();

        Conductor.mapBPMChanges(SONG);
        Conductor.changeBPM(SONG.bpm);
        Conductor.position = Conductor.crochet * -5;

        if(SONG.keyCount == null)
            SONG.keyCount = 4;

        scripts.push(new HScript(Paths.script('data/stages/${SONG.stage}')));
        scripts.push(new HScript(Paths.script("data/scripts/testing")));
        for (script in scripts) {
            script.setParent(this);
            script.call("onCreate");
        }
        Game.camera.zoom = defaultCamZoom;

        Game.sound.list.push(inst = new MusicEx(Paths.songInst(SONG.song), 1, false));
        inst.onComplete = endSong;
        inst.pitch = Game.timeScale;

        Game.sound.list.push(vocals = new MusicEx(Paths.songVoices(SONG.song), 1, false));
        vocals.pitch = Game.timeScale;

        Game.cameras.add(camHUD = new Camera());

        add(cpuStrums = new TypedGroup<Receptor>());
        add(playerStrums = new TypedGroup<Receptor>());

        add(notes = new NoteField());
        notes.cameras = [camHUD];

        var strumY:Float = (SettingsAPI.downscroll) ? Game.height - 160 : 50;
        var receptorOffset:Float = 90;

        for(i in 0...SONG.keyCount) {
            // CPU receptor
            var receptor = new Receptor((Note.swagWidth * i) + receptorOffset, strumY, SONG.keyCount, i);
            receptor.cameras = [camHUD];
            receptor.alpha = 0;
            Tween.tween(receptor, {alpha: 1}, 0.5, {ease: Ease.circOut, startDelay: 0.3 * i});
            cpuStrums.add(receptor);
            receptor.animation.finishCallback = (name:String) -> {
                if(name == "confirm")
                    receptor.playAnim("static", true);
            };

            // Player receptor
            var receptor = new Receptor((Note.swagWidth * i) + ((Game.width * 0.5) + receptorOffset), strumY, SONG.keyCount, i);
            receptor.cameras = [camHUD];
            receptor.alpha = 0;
            Tween.tween(receptor, {alpha: 1}, 0.5, {ease: Ease.circOut, startDelay: 0.3 * i});
            if(SettingsAPI.botplay) {
                receptor.animation.finishCallback = (name:String) -> {
                    if(name == "confirm")
                        receptor.playAnim("static", true);
                };
            }
            playerStrums.add(receptor);
        }

        unspawnNotes = ChartParser.parseNotes(SONG);

        camFollow = new Object(0, 0);
        camFollow.setPosition(770 + 411 / 2 - 100, 450 + 412 / 2 - 100); // 875.5, 556
        Game.camera.target = camFollow;
        Game.camera.followLerp = 0.04;
        
        startCountdown();

        call("onCreatePost");
    }

    public function startCountdown() {
        var swagCounter:Int = 0;
        startTimer = new Timer().start(Conductor.crochet / 1000, (timer:Timer) -> {
            switch(swagCounter++) {
                case 0: Game.sound.play(Paths.sound("game/countdown/base/intro3"));
                case 1: Game.sound.play(Paths.sound("game/countdown/base/intro2"));
                case 2: Game.sound.play(Paths.sound("game/countdown/base/intro1"));
                case 3: Game.sound.play(Paths.sound("game/countdown/base/introGo"));
            }
        }, 4);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(!endingSong) {
            Conductor.position += elapsed * 1000;
            call("onUpdate", [elapsed]);
        }

        if(startingSong) {
            if(Conductor.position >= 0)
                startSong();
        }

        Game.camera.zoom = MathUtil.lerp(Game.camera.zoom, defaultCamZoom, 0.05, true);
        camHUD.zoom = MathUtil.lerp(camHUD.zoom, 1, 0.05, true);

        if(unspawnNotes[0] != null && !endingSong) {
            while(unspawnNotes[0] != null && unspawnNotes[0].strumTime <= Conductor.position + (2500 / (scrollSpeed / Game.timeScale)))
                notes.add(unspawnNotes.shift());
        }

        keyShit();
    }

    public var keyBinds:Array<Int> = [
        Keys.S,
        Keys.D,
        Keys.K,
        Keys.L
    ];

    public function goodNoteHit(note:Note) {
        if(note.mustPress) {
            if(!note.isSustainNote) {
                var ratingSpr:Sprite = new Sprite((Game.width * 0.55) - 40, (Game.height * 0.5) - 60).loadGraphic(Paths.image('gameplay/ratings/sick'));
                ratingSpr.scale.set(0.7, 0.7);
                ratingSpr.updateHitbox();
                ratingSpr.alpha = 1;
                ratingSpr.acceleration.y = 550;
                ratingSpr.velocity.y = -Game.random.int(140, 175);
                ratingSpr.velocity.x = -Game.random.int(0, 10);
                add(ratingSpr);

                Tween.tween(ratingSpr, {alpha: 0}, 0.2, {
                    onComplete: (tween:Tween) -> {
                        ratingSpr.kill();
                    },
                    startDelay: Conductor.crochet * 0.001
                });
            }
        }
        note.strumLine.members[note.noteData].playAnim("confirm", true);
        notes.deleteNote(note);
    }

    public function keyShit() {
        if(SettingsAPI.botplay) return;

        for(i => bind in keyBinds) {
            if(Game.keys.justPressed(bind))
                playerStrums.members[i].playAnim("pressed", true);
        }

        var possibleNotes:Array<Note> = [];
        notes.forEachAlive((note:Note) -> {
            if(!note.mustPress || !note.canBeHit || note.isSustainNote) return;
            possibleNotes.push(note);
        });
        possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

        var hitBlocked:Array<Bool> = [for(_ in 0...SONG.keyCount) false];
        for(note in possibleNotes) {
            if(!Game.keys.justPressed(keyBinds[note.noteData]) || hitBlocked[note.noteData]) continue;
            hitBlocked[note.noteData] = true;
            goodNoteHit(note);
        }

        for(i => bind in keyBinds) {
            if(Game.keys.justReleased(bind))
                playerStrums.members[i].playAnim("static", true);
        }
    }

    override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);

        if(startingSong || endingSong) return;

        call("onBeatHit");

        if (SONG.notes[Math.floor(curBeat / 4)].mustHitSection)
            camFollow.setPosition(770 + 411 / 2 - 100, 450 + 412 / 2 - 100); // 875.5, 556
        else
            camFollow.setPosition(100 + 429 / 2 + 150, 100 + 767 / 2 - 100); // 464.5, 385.5

        if(curBeat % 4 == 0) {
            Game.camera.zoom += 0.015;
            camHUD.zoom += 0.03;
        }

        var resyncTime:Float = 20 * Game.timeScale;
        if(Math.abs(Conductor.position - inst.time) > resyncTime || Math.abs(Conductor.position - vocals.time) > resyncTime)
            resyncVocals();
    }

    public function resyncVocals() {
        inst.pause();
        vocals.pause();

        inst.time = vocals.time = Conductor.position;

        inst.play();
        vocals.play();
    }

    public function startSong() {
        startingSong = false;
        inst.time = vocals.time = Conductor.position = 0;
        inst.play();
        vocals.play();
    }

    public function endSong() {
        Game.timeScale = 1;
        endingSong = true;
        Game.switchScene(new MainMenu());
    }

    override function destroy() {
        for (script in scripts)
            script.destroy();
        super.destroy();
    }

    function call(method:String, ?parameters:Array<Dynamic>) {
        for (script in scripts)
            script.call(method, parameters);
    }
}