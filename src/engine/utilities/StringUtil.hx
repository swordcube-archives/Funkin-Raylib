package engine.utilities;

class StringUtil {
    public static function addZeros(str:String, num:Int) {
		while(str.length < num) str = '0${str}';
		return str;
	}

	/**
		Makes the first letter of each word in `s` uppercase.
		@param s       The string to modify
		@author swordcube
	**/
	public inline static function firstLetterUppercase(s:String):String {
		var strArray:Array<String> = s.split(' ');
		var newArray:Array<String> = [];
		
		for (str in strArray)
			newArray.push(str.charAt(0).toUpperCase()+str.substring(1));
	
		return newArray.join(' ');
	}
}