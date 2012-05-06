$(function() {
	$('.cityTypeahead').typeahead({
		    source: function(typeahead, query) {$.getJSON(
		        	'http://whateverorigin.org/get?url=https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + actuallyEncodeURIComponent(query) + '&types=(cities)&sensor=false&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4&callback=?',
	    	  	  	function(data) {
	    	  	  		response = $.parseJSON(data.contents);
	          			typeahead.process(response.predictions);
	      			}
	  		)},
		    property: "description",
	});
});
