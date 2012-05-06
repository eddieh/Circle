/**
 * Utility class to get random colors that are evenly distributed across the colorspace.
 *
 * Usage: var rgbColor = Circle.colors.getRandom(); //returns string like "31a57c"
 */

var golden_ratio_conjugate =  0.618033988749895,
					   hue = Math.random();

var randomColor = function () {

	//converts the value to radians
	var toRad = function(value) {
		/** Converts numeric degrees to radians */
		return value * Math.PI / 180;
	};

	/**
	 * hsv2rbgb
	 *
	 * converts a color in hsv format to rgb
	 * source: http://jsres.blogspot.com/2008/01/convert-hsv-to-rgb-equivalent.html
	 *
	 * @param h the hue of the color
	 * @param s the saturation of the color
	 * @param v the value of the color
	 * @return an rgb string in the format "rrggbb"
	 */
	var hsv2rgb = function(h,s,v) {
		// Adapted from http://www.easyrgb.com/math.html
		// hsv values = 0 - 1, rgb values = 0 - 255
		var r, g, b;
		var RGB = new Array();
		if(s==0){
		  RGB['red']=RGB['green']=RGB['blue']=Math.round(v*255);
		}else{
		  // h must be < 1
		  var var_h = h * 6;
		  if (var_h==6) var_h = 0;
		  //Or ... var_i = floor( var_h )
		  var var_i = Math.floor( var_h );
		  var var_1 = v*(1-s);
		  var var_2 = v*(1-s*(var_h-var_i));
		  var var_3 = v*(1-s*(1-(var_h-var_i)));
		  switch (var_i)
		  {
			case 0:
				var_r = v;
				var_g = var_3;
				var_b = var_1;
				break;
			case 1:
				var_r = var_2;
				var_g = v;
				var_b = var_1;
				break;
			case 2:
				var_r = var_1;
				var_g = v;
				var_b = var_3;
				break;
			case 3:
				var_r = var_1;
				var_g = var_2;
				var_b = v;
				break;
			case 4:
				var_r = var_3;
				var_g = var_1;
				var_b = v;
				break;
			default:
				var_r = v;
				var_g = var_1;
				var_b = var_2
		  }
		  //rgb results = 0 ÷ 255
		  var red = Math.round(var_r * 255);
		  var green = Math.round(var_g * 255);
		  var blue = Math.round(var_b * 255);

		  var rgb = blue | (green << 8) | (red << 16);
		  }
		return rgb.toString(16);
	};

	 hue += golden_ratio_conjugate;
	 hue %= 1;
	 return hsv2rgb(hue, 0.9, 0.9);
}
