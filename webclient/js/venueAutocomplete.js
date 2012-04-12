;$(function() {
	$('.venue-typeahead').typeahead({
	    source: function(typeahead, query) {$.getJSON(
	        	'http://whateverorigin.org/get?url=' + encodeURIComponent('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + query + '&sensor=true&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4') + '&callback=?', 
    	  	  	function(data) {
    	  	  		var contents = $.parseJSON(data.contents);
    	  	  		console.log(contents);
          			typeahead.process(contents.predictions);
      			}	
  		)},
	    property: "description"
	 });
});