package funkin.interfaces;

interface IMusicHandler {
    public function beatHit(v:Int):Void;
    public function stepHit(v:Int):Void;
    public function sectionHit(v:Int):Void;
}