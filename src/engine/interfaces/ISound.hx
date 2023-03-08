package engine.interfaces;

interface ISound extends IBasic {
    public function play():ISound;
    public function stop():ISound;
    public function pause():ISound;
    public function resume():ISound;
}