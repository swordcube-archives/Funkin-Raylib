package funkin.objects.ui;

import scenes.PlayState;
import engine.Group.TypedGroup;

class NoteField extends TypedGroup<Note> {
    public var game = PlayState.current;

    override function update(elapsed:Float) {
        super.update(elapsed);
        forEachAlive((note:Note) -> {
			var strumLine:TypedGroup<Receptor> = note.strumLine;

			var roundedSpeed = MathUtil.roundDecimal(note.getScrollSpeed(), 2);
			var downscrollMultiplier:Int = (SettingsAPI.downscroll ? -1 : 1) * MathUtil.signOf(roundedSpeed);

			var psuedoX:Float = 25;
			var psuedoY:Float = (downscrollMultiplier * -((Conductor.position - note.strumTime) * (0.45 * Math.abs(roundedSpeed))));
			var receptor:Receptor = strumLine.members[note.noteData];

			note.x = (receptor.x - psuedoX)
                + (Math.cos(AngleUtil.asRadians(-note.angle)) * psuedoX)
				+ (Math.sin(AngleUtil.asRadians(-note.angle)) * psuedoY)
				+ note.offsetX;

			note.y = receptor.y
                + (Math.cos(AngleUtil.asRadians(-note.angle)) * psuedoY) 
                + (Math.sin(AngleUtil.asRadians(-note.angle)) * psuedoX)
				+ note.offsetY;

			if (note.isSustainNote) {
				if (downscrollMultiplier < 0)
					note.y -= Note.swagWidth * 0.5;
				else
					note.y += Note.swagWidth * 0.5;

                note.flipY = (downscrollMultiplier < 0);
			}

            // this dumb but it works
			if (downscrollMultiplier < 0 && note.isSustainNote) {
				note.y += Note.swagWidth;
				note.y -= note.height;
			}

            if(note.mustPress) {
                // hitting sustain notes
                if(!SettingsAPI.botplay && note.isSustainNote && note.strumTime <= Conductor.position && Game.keys.pressed(game.keyBinds[note.noteData]))
                    game.goodNoteHit(note);
                
                // missing notes
                if(note.strumTime <= Conductor.position - (Conductor.safeZoneOffset + (50 * Game.timeScale)))
                    deleteNote(note);

                // botplay
                if(SettingsAPI.botplay && note.strumTime <= Conductor.position)
                    game.goodNoteHit(note);
            } else {
                if(note.strumTime <= Conductor.position)
                    game.goodNoteHit(note);
            }
        });
    }

    public function deleteNote(note:Note) {
        note.kill();
        note.destroy();
        remove(note);
    }
}