package funkin.helpers;

import scenes.PlayState;
import funkin.objects.ui.Note;
import funkin.song.SongFormat.SongData;

class ChartParser {
    public static function parseNotes(SONG:SongData) {
        var game = PlayState.current;

        var unspawnNotes:Array<Note> = [];
        for(section in SONG.notes) {
            for(note in section.sectionNotes) {
                var mustPress:Bool = section.mustHitSection;
                if(note[1] > SONG.keyCount - 1)
                    mustPress = !section.mustHitSection;

                var swagNote = new Note(-9999, -9999, (mustPress) ? game.playerStrums : game.cpuStrums, note[0], SONG.keyCount, note[1], mustPress);
                unspawnNotes.push(swagNote);
            }
        }
        return unspawnNotes;
    }
}