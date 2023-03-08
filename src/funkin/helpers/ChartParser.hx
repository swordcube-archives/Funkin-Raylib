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
                if(note[1] < 0) continue;

                var mustPress:Bool = section.mustHitSection;
                if(note[1] > SONG.keyCount - 1)
                    mustPress = !section.mustHitSection;

                var swagNote = new Note(-9999, -9999, (mustPress) ? game.playerStrums : game.cpuStrums, note[0] + SettingsAPI.noteOffset, SONG.keyCount, Std.int(note[1]) % SONG.keyCount, mustPress);
                unspawnNotes.push(swagNote);
            }
        }

        var notesOnly:Array<Note> = [];
        for(note in unspawnNotes) {
            // if(note.isSustainNote) continue;
            notesOnly.push(note);
        }
        notesOnly.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

        var oldNote:Note = null;
        for(note in notesOnly) {
            if(oldNote != null && note.mustPress == oldNote.mustPress && note.noteData == oldNote.noteData && (note.strumTime - oldNote.strumTime) <= 5) {
                // for(sus in note.sustainNotes) {
                //     sus.kill();
                //     sus.destroy();
                //     unspawnNotes.remove(sus);
                // }
                note.kill();
                note.destroy();
                unspawnNotes.remove(note);
            }
            oldNote = note;
        }
        oldNote = null;
        notesOnly = [];

        unspawnNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
        return unspawnNotes;
    }
}