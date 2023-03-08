package funkin.objects.ui;

import scenes.PlayState;
import engine.Group.TypedGroup;

class NoteField extends TypedGroup<Note> {
    public var game = PlayState.current;

    override function update(elapsed:Float) {
        super.update(elapsed);
        forEachAlive((note:Note) -> {
            note.x = note.strumLine.members[note.noteData].x;
            note.y = note.strumLine.members[note.noteData].y - ((0.45 * (SettingsAPI.downscroll ? -1 : 1)) * (Conductor.position - note.strumTime) * game.scrollSpeed);

            if(note.mustPress) {
                if(note.strumTime <= Conductor.position - (Conductor.safeZoneOffset + 50))
                    deleteNote(note);
            } else {
                if(note.strumTime <= Conductor.position)
                    deleteNote(note);
            }
        });
    }

    public function deleteNote(note:Note) {
        note.kill();
        note.destroy();
        remove(note);
    }
}