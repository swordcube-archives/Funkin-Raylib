package funkin.objects.ui;

import scenes.PlayState;
import engine.Group.TypedGroup;

class NoteField extends TypedGroup<Note> {
    public var game = PlayState.current;

    override function update(elapsed:Float) {
        super.update(elapsed);
        forEachAlive((note:Note) -> {
            note.x = note.strumLine.members[note.noteData].x;
            note.y = note.strumLine.members[note.noteData].y - (0.45 * (Conductor.position - note.strumTime) * game.scrollSpeed);

            if(note.mustPress) {
                // idk yet man
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