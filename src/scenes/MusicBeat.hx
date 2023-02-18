package scenes;

import funkin.ui.transitions.FadeTransition;
import funkin.interfaces.IMusicHandler;

class MusicBeatScene extends Scene implements IMusicHandler {
    override function create() {
        transIn = new FadeTransition();
        transOut = new FadeTransition(true);

        Conductor.onBeatHit.add(beatHit);
        Conductor.onStepHit.add(stepHit);
        Conductor.onSectionHit.add(sectionHit);
        super.create();
    }

    /**
     * Destroys every member of this scene.
     * This does not **remove** the members from the scene, so crashes could occur.
     */
    override function destroy() {
        Conductor.onBeatHit.remove(beatHit);
        Conductor.onStepHit.remove(stepHit);
        Conductor.onSectionHit.remove(sectionHit);
        super.destroy();
    }

	public function beatHit(v:Int) {
        for(member in members) {
            if(member is IMusicHandler)
                cast(member, IMusicHandler).beatHit(v);
        }
    }

	public function stepHit(v:Int) {
        for(member in members) {
            if(member is IMusicHandler)
                cast(member, IMusicHandler).stepHit(v);
        }
    }

	public function sectionHit(v:Int) {
        for(member in members) {
            if(member is IMusicHandler)
                cast(member, IMusicHandler).sectionHit(v);
        }
    }
}