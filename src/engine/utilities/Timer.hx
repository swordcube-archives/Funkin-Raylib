package engine.utilities;

class Timer extends Object {
    public var finishCallback:Timer->Void;

    public var loops:Int = 0;
    public var loopsLeft:Int = 0;
    
    public var duration:Float = 0;
    public var active:Bool = false;

    private var __elapsedTime:Float = 0;
    private var __manager:TimerManager = Game.timers;

    public function new(?manager:TimerManager) {
        super();
        if(manager != null)
            this.__manager = manager;

        __manager.add(this);
    }

    /**
     * Starts this timer.
     * @param duration The duration of the timer.
     * @param finishCallback The function that runs when the timer loops/finishes
     * @param loops The amount of times the timer runs. 0 is infinite.
     */
    public function start(duration:Float, ?finishCallback:Timer->Void, ?loops:Int = 1) {
        this.duration = duration;
        this.finishCallback = finishCallback;
        this.loops = this.loopsLeft = loops;
        this.active = true;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(!active) return;

        __elapsedTime += elapsed;

        if(__elapsedTime >= duration) {
            __elapsedTime = 0;
            
            if(loops <= 0) {
                if(finishCallback != null)
                    finishCallback(this);
            } else {
                loopsLeft--;
                if(loopsLeft <= 0) {
                    if(finishCallback != null)
                        finishCallback(this);

                    stop();
                    destroy();
                } else {
                    if(finishCallback != null)
                        finishCallback(this);
                }
            }
        }
    }

    public function resume() {
        active = true;
    }

    public function pause() {
        active = false;
    }

    public function stop() {pause();}

    override function destroy() {
        if(__manager != null)
            __manager.remove(this);

        active = false;

        super.destroy();
    }
}