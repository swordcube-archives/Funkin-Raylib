package engine.utilities;

enum abstract LogType(Int) from Int to Int {
    var INFO = 0;
    var WARNING = 1;
    var ERROR = 2;
    var TRACE = 3;
    var VERBOSE = 4;
    var ENGINE = 5;
}

/**
 * A class for printing stuff to the console in a more readable way.
 */
class Logs {
    public static var colors:Map<String, String> = [
		'black'		=> '\033[0;30m',
		'red'		=> '\033[31m',
		'green'		=> '\033[32m',
		'yellow'	=> '\033[33m',
		'blue'		=> '\033[1;34m',
		'magenta'	=> '\033[1;35m',
		'cyan'		=> '\033[0;36m',
		'grey'		=> '\033[0;37m',
		'gray'		=> '\033[0;37m',
		'white'		=> '\033[1;37m',
		'orange'	=> '\033[38;5;214m',
		'reset'		=> '\033[0;37m'
	];

    public static function trace(value:Dynamic, type:LogType, ?showTag:Bool = true) {
        var time = Date.now();
        var timeStr:String = '${colors["cyan"]}[${Std.string(time.getHours()).addZeros(2)}:${Std.string(time.getMinutes()).addZeros(2)}:${Std.string(time.getSeconds()).addZeros(2)}] ';

        Sys.println(switch(type) {
            case WARNING: timeStr + colors["yellow"] +  (showTag ? "[ WARNING ] " : "") + colors["reset"] + value;
            case ERROR:   timeStr + colors["red"] +     (showTag ? "[ ERROR ] " : "") + colors["reset"] + value;
            case TRACE:   timeStr + colors["gray"] +    (showTag ? "[ TRACE ] " : "") + colors["reset"] + value;
            case VERBOSE: timeStr + colors["magenta"] + (showTag ? "[ VERBOSE ] " : "") + colors["reset"] + value;
            case ENGINE:  timeStr + colors["green"] +   (showTag ? "[ ENGINE ] " : "") + colors["reset"] + value;
            default:      timeStr + colors["cyan"] +    (showTag ? "[ INFO ] " : "") + colors["reset"] + value;
        });
    }
}