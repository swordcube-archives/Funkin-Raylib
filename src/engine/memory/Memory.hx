package engine.memory;

import cpp.vm.Gc;

/**
 * Memory class to properly get memory counts for the program.
 */
class Memory {
    public static var memoryPeak:Float = 0;

    public static function getPeakUsage():Float {
        if(getCurrentUsage() > memoryPeak)
            memoryPeak = getCurrentUsage();

        return memoryPeak;
    };

    public static function getCurrentUsage():Float {
        return Gc.memInfo64(Gc.MEM_INFO_USAGE);
    };
}