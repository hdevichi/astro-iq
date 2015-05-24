using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Math as Math;

class AstroView extends Ui.WatchFace {

	// TODO
	// voie lactée
	// s'initialise mal (seul le label apparait, sur la montre)

	var JJ;
	var TSmidnight;
	var longitude = -2.2;
	var latitude = 48.5 / 360 * 2 * Math.PI;
	var stars = new Stars();
	var screenSize = 109; // for fenix 3, use API to get 
	var counter = 0l;
	var sleep = true;
	var redraw = true;
	
    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        computeJulianDay();
	    computeSiderealTime();
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    	redraw = true;
	}

    //! Update the view - called once a minute
    function onUpdate(dc) {
  	    
        if (redraw) {
        	dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_BLACK);
        	dc.fillCircle(screenSize, screenSize, screenSize);
        }
        
  		// Compute time & local sidereal time
        var clockTime = Sys.getClockTime();
        if (clockTime.hour == 0 && clockTime.min == 0) {
			computeJulianDay();
		    computeSiderealTime();
        }
        
        var h = clockTime.hour-clockTime.timeZoneOffset/3600 + clockTime.min.toDouble()/ 60 + clockTime.sec.toDouble() / 3600;
      
      	// Draw layout & time
		//var view = View.findDrawableById("TimeLabel");
        //view.setText(format(h+clockTime.timeZoneOffset/3600));
        // Call the parent onUpdate function to redraw the layout
        // View.onUpdate(dc);
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_DK_BLUE);
        dc.drawText(109, 188, Gfx.FONT_MEDIUM,format(h+clockTime.timeZoneOffset/3600) , Gfx.TEXT_JUSTIFY_CENTER);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        
        // only display once per 5 minutes if low power, 1 per minute if high power
        
        if (redraw ) { 
		        
	        var TSL = TSmidnight + h * 1.0027379d - longitude / 15;
			TSL = mod(TSL, 24);
			//Sys.println(TSL);
		    // Draw map
		        
	        // do some precomputations
	        var sinLat = Math.sin(latitude);
	        var cosLat = Math.cos(latitude);
		        
	       // to draw milky way
			var lx = 0;
			var ly = 0;
			// express TSL in radians
			TSL = TSL / 12 * Math.PI;
			for(var i = 0; i < stars.stars.size(); i ++) {	// 500 ok in simulator ; 300 ok on watch 
				var star = stars.stars[i];
				
				//var mag = star[2];
				//var alpha = star[0]; 
				//var delta = star[1];

				
				var mag = star % 10;
				star = star / 10;
				var delta = (star % 10000 - 1800).toDouble()/20;
				var alpha = (star / 10000).toDouble()/10;
				
				alpha= alpha/180*Math.PI;
				delta= delta/180*Math.PI;
				
				// calcul de l'angle horaire (en radians)
				var H = TSL - alpha;
				var cosH = Math.cos(H);
				var cosDelta = Math.cos(delta);
				var sinDelta = Math.sin(delta); 
		   		// calcul de la hauteur (radians)
		   		var hauteur = sinLat * sinDelta + cosLat * cosDelta * cosH;
		   		hauteur = Math.asin(hauteur);
		   		
		   		if (hauteur > 0) {
		   			// calcul de l'azimut (radians, origine sud)
	   				var sinazimut = cosDelta * Math.sin(H) / Math.cos(hauteur);
				    var cosazimut = - cosLat * sinDelta + sinLat * cosDelta * cosH;

					var r = screenSize * ( Math.PI / 2 - hauteur ) / Math.PI *2;
				   	var x = screenSize + r * sinazimut; 
				   	var y = screenSize + r * cosazimut; 
		
					//if (i < 20) {
					//	Sys.println("saz: "+sinazimut+" caz:"+cosazimut+" h:"+hauteur+" r:"+r+" x:"+x+" y:"+y); //
			   		//}
		
					if (mag == 0 ) {
						dc.drawPoint(x, y);
					} else {
						if (mag == 1) {
							dc.drawCircle(x, y, 1); 
							dc.fillCircle(x,y,1);
						} 
					}
		    		
		    	}
		   	}
		}   
		
		counter = counter + 1 ;
  		redraw = false;
  		if ((counter % 5 ) == 0) {
       		if ( (!sleep) || ((counter % 50) == 0) ) {
       			redraw = true;	
       		}
       	}
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    	sleep = false;
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	sleep = true;
    }
	
	function computeJulianDay() {
		var date = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var year = date.year;
    	var month = date.month;
        var day = date.day;
		JJ = 367 * year;
		JJ = JJ - ( 1.75 * ( ((month+9)/12).toLong() + year) ).toLong();
		JJ = JJ - ( 0.75 * ( 1 + (( ((month-9)/7).toLong() + year ) * 0.01 ).toLong() ) ).toLong();
		JJ = JJ + (275 * month / 9 ).toLong() + day + 1721028.5;
		//  test unitaire: 15/5/2015 : trouver 2457157.5 - OK		
	}
	
	function computeSiderealTime() {
		// calcul du temps en siecle julien 2000.0
		var T = (JJ - 2451545) / 36525;
		TSmidnight = 6.69737456d + 2400.051337d*T;
		TSmidnight = mod(TSmidnight,24);
		// test unitaire: trouver 15/5/2015: 15h29m37s (15.4937646929)		
	}
	
	function mod(x, base) {
		x = x - ((x / base).toLong() ) * base;
		return x;
	}
	
	function format(s) {
		var s1 = s.toLong();
		var s2 = ((s-s1)*60).toLong();
	 	return Lang.format("$1$:$2$", [s1, s2.format("%02d")]);
	}
}