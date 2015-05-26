using Toybox.Lang as Lang;
using Toybox.Time as Time;

// utility for astronomy computations
class TimeUtils extends Lang.Object {

	static function computeJulianCentury2000Now() {
		var date = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var year = date.year;
    	var month = date.month;
        var day = date.day;
		return computeJulianCentury2000(year, month, day);
	}
	
	//  test unitaire: 15/5/2015 : trouver 2457157.5 avant division - OK	
	// Compute time as number of Julian centuries since epoch 2000.0 for current date (UT) at midnight	
	static function computeJulianCentury2000(year, month, day) {
		var JJ = 367 * year;
		JJ = JJ - ( 1.75 * ( ((month+9)/12).toLong() + year) ).toLong();
		JJ = JJ - ( 0.75 * ( 1 + (( ((month-9)/7).toLong() + year ) * 0.01 ).toLong() ) ).toLong();
		JJ = JJ + (275 * month / 9 ).toLong() + day + 1721028.5;
		JJ = (JJ - 2451545) / 36525;
		return JJ;	
	}
	
	// test unitaire: trouver 15/5/2015: 15h29m37s (15.4937646929)		
	// Returns sidereal time at midnight given T in julian centuries 2000.0
	// Precision <= 1 min for current decenny
	static function computeSiderealTime() {
		var T = computeJulianCentury2000Now();
		var	TSmidnight = 6.69737456d + 2400.051337d*T;
		TSmidnight = mod(TSmidnight,24);
		return TSmidnight;
	}
	
	// mod exists only for int in the API, this works for float
	static function mod(x, base) {
		x = x - ((x / base).toLong() ) * base;
		return x;
	}
}