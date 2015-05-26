using Toybox.Lang as Lang;
using Toybox.Math as Math;

// A memory compact star catalog
class SkyMap extends Lang.Object {

	var TSL = 0;
	var sinLat = 0;
	var cosLat = 1;
	
	function setContext(time, latitude) {
		TSL = time;
	    sinLat = Math.sin(latitude);
	    cosLat = Math.cos(latitude);
	}
	
	// Plots on the dc the position at alpha, delta (in degrees)
	// with a dot of diameter = size
	// circle view, south at the bottom, centered in the dc (use the full dc size)
	function plot(alpha, delta, dc, size) {
	
		alpha= alpha/180*Math.PI;
		delta= delta/180*Math.PI;
			
		var screenSize = dc.getWidth()/2;
				
		// calcul de l'angle horaire (en radians)
		var H = TSL - alpha;
		var cosH = Math.cos(H);
		var cosDelta = Math.cos(delta);
		var sinDelta = Math.sin(delta); 
		// calcul de la hauteur (radians)
		var hauteur = sinLat * sinDelta + cosLat * cosDelta * cosH;
		hauteur = Math.asin(hauteur);
		   		
		if (hauteur < 0) {
			return;
		}
		   			
		// calcul de l'azimut (radians, origine sud)
	   	var sinazimut = cosDelta * Math.sin(H) / Math.cos(hauteur);
		var cosazimut = - cosLat * sinDelta + sinLat * cosDelta * cosH;

		var r = screenSize * ( Math.PI / 2 - hauteur ) / Math.PI *2;
	   	var x = screenSize + r * sinazimut; 
	   	var y = screenSize + r * cosazimut; 
			
		if (size == 0 ) {
			dc.drawPoint(x, y);
		} else {
			dc.drawCircle(x, y, size); 
			dc.fillCircle(x,y,size);
		}
	}
}