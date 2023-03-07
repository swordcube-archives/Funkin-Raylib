package scenes;

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

    public var unspawnNotes:Array<Note>;
    public var scrollSpeed:Float = 1;

    override function create() {
        super.create();
        current = this;

        Game.sound.music.stop();

        Conductor.mapBPMChanges(SONG);
        Conductor.changeBPM(SONG.bpm);
        Conductor.position = Conductor.crochet * -5;

        if(SONG.keyCount == null)
            SONG.keyCount = 4;

        add(inst = new MusicEx(Paths.songInst(SONG.song), 1, false));
        inst.onComplete = endSong;

        add(vocals = new MusicEx(Paths.songVoices(SONG.song), 1, false));

        add(cpuStrums = new TypedGroup<Receptor>());
        add(playerStrums = new TypedGroup<Receptor>());

        add(notes = new NoteField());

        var receptorOffset:Float = 80;

        for(i in 0...SONG.keyCount) {
            // CPU receptor
            var receptor = new Receptor((Note.swagWidth * i) + receptorOffset, 50, SONG.keyCount, i);
            receptor.alpha = 0;
            Tween.tween(receptor, {alpha: 1}, 0.5, {ease: Ease.circOut, startDelay: 0.3 * i});
            cpuStrums.add(receptor);

            // Player receptor
            var receptor = new Receptor((Note.swagWidth * i) + ((Game.width * 0.5) + receptorOffset), 50, SONG.keyCount, i);
            receptor.alpha = 0;
            Tween.tween(receptor, {alpha: 1}, 0.5, {ease: Ease.circOut, startDelay: 0.3 * i});
            playerStrums.add(receptor);
        }

        unspawnNotes = ChartParser.parseNotes(SONG);

        startCountdown();
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

        Conductor.position += elapsed * 1000;
        if(startingSong) {
            if(Conductor.position >= 0)
                startSong();
        }

        if(unspawnNotes[0] != null) {
            while(unspawnNotes[0] != null && unspawnNotes[0].strumTime <= Conductor.position + (2500 / scrollSpeed))
                notes.add(unspawnNotes.shift());
        }
    }

    public function startSong() {
        startingSong = false;
        Conductor.position = 0;
        inst.play();
        vocals.play();
    }

    public function endSong() {
        Game.switchScene(new MainMenu());
    }

    override function destroy() {
        for(object in [inst, vocals])
            object.destroy();

        super.destroy();
    }
}