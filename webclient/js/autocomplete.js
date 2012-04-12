$(function() {
	$('.typeahead').typeahead({
	    source: function(typeahead, query) {$.getJSON(
	        	'http://whateverorigin.org/get?url=' + encodeURIComponent('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + query + '&types=(cities)&sensor=false&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4') + '&callback=?', 
    	  	  	function(data) {
    	  	  		var response = $.parseJSON(data.contents);
          			typeahead.process(response.predictions);
      			}	
  		)},
	    property: "description"
	 });

	$('.venue-typeahead').typeahead({
	    source: function(typeahead, query) {$.getJSON(
	        	'http://whateverorigin.org/get?url=' + encodeURIComponent('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + query + '&sensor=false&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4') + '&callback=?', 
    	  	  	function(data) {
    	  	  		var response = $.parseJSON(data.contents);
          			typeahead.process(response.predictions);
      			}	
  		)},
	    property: "description", 
	    onselect: function(val) {
	    	//console.dir(val)
	    	$.getJSON(
	        	'http://whateverorigin.org/get?url=' + encodeURIComponent('https://maps.googleapis.com/maps/api/place/details/json?reference=' + val.reference + '&sensor=false&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4') + '&callback=?',
	        	function (data) {
	        		var response = $.parseJSON(data.contents);

	        		var venue = {
	        			address: response.result.formatted_address,
	        			location: response.result.geometry.location
	        		};

	        		if (response.result.types.indexOf('street_address') == -1) {
	        		// i.e. it's an establishment, and not just an address
	        			venue.name = response.result.name;
	        		}

	        		console.log("*** VENUE DATA FOLLOWS ***");
	        		console.dir(venue);
	        	});
	    }
	 });
});