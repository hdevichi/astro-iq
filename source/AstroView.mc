using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;

// Watch face that displays the current sky in Paris
// (location hardcoded as API to get it doesnt exist in watch faces)
class AstroView extends Ui.WatchFace {

	// TODO
	// voie lactée
	// s'initialise mal (seul le label apparait, sur la montre) 
	// => KO sur transition vert (retour menus ou widgets), ok sur transition horiz (ex retour apps)
	// (version qui attends 1 sec avant de dessiner)

	// change of day

	// Location (long needs to be in degrees, latitude in radians)
	var longitude = -2.2;
	var latitude = 48.5 / 360 * 2 * Math.PI;
	
	var tsMidnight;
	// partial redraw management
	var secondsSinceStarUpdate = 0;
	var sleep = true;
	var redrawAll = false;
	
    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
	    tsMidnight = TimeUtils.computeSiderealTime();
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    	redrawAll = true;
	}

    //! Update the view - called once a minute
    function onUpdate(dc) {
  	    
  	    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_DK_BLUE); 
  	    
  	    if (redrawAll) {	   
	        View.onUpdate(dc);
	        dc.clear();
	        displayTime(dc);
		    redrawAll = false;
	        secondsSinceStarUpdate = 197; // waits at least 2 seconds (for horiz. animations...).	        
  	    	return;
  	    } 
  	    
  	    displayTime(dc);

		if (secondsSinceStarUpdate < 200) {
			secondsSinceStarUpdate = secondsSinceStarUpdate + 1;
			if (!sleep) {
  	    		secondsSinceStarUpdate = secondsSinceStarUpdate + 59;
  	    	}
			return;
		}
		
  	    secondsSinceStarUpdate = 0;
  	    dc.clear();
  	    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE); 
  	      	    	    
  	    var screenSize = dc.getWidth() /2;
                
  		// Compute time & local sidereal time
        var clockTime = Sys.getClockTime();
        var h = clockTime.hour-clockTime.timeZoneOffset/3600 + clockTime.min.toFloat()/ 60 + clockTime.sec.toFloat() / 3600;
      
        // only display once per 5 minutes if low power, 1 per minute if high power
        
    	// compute local sidereal time (radians)
        var TSL = tsMidnight + h * 1.0027379d - longitude / 15;
		TSL = TimeUtils.mod(TSL, 24) / 12 * Math.PI;
		
		var map =  new SkyMap();
		map.setContext(TSL, latitude);
		
		// for 400 Stars it takes about 5s on fenix 3
		// for about 350 stars in fails on simulator (watchdog error)
		for(var i = 0; i < 320; i ++) {		
			var star = StarCatalog.getStar(i);
			map.plot(star.alpha, star.delta, dc, (3-star.magnitude)/2);
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
		
	// display time at the bottom of the screen (hh:mm)
	function displayTime(dc) {
		var clockTime = Sys.getClockTime();
		var s = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
	    dc.drawText(109, 180, Gfx.FONT_LARGE , s , Gfx.TEXT_JUSTIFY_CENTER );
	}
}