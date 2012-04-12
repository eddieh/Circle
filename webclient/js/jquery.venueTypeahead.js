!function($) {
  var VenueTypeahead = function (element, options) {
    this.$element = $(element);
    this.options = $.extend({}, $.fn.venueTypeahead.defaults, options); //options TBD
    this.init();
  }

  VenueTypeahead.prototype = {

    constructor: VenueTypeahead

    /**
     * Sets up the searchbox and the location searchbox
     * @return {void} 
     */
  , init: function() {
      this.$container = $('<div>in </div>').insertAfter(this.$element.parent());

      this.$searchLocationField = $('<input type="text" />')
        .hide()
        .val(Circle.currentLocation)
        .appendTo(this.$container)
        .typeahead({
          source: function(typeahead, query) {$.getJSON(
                'http://whateverorigin.org/get?url=' + encodeURIComponent('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + query + '&types=(cities)&sensor=false&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4') + '&callback=?', 
                  function(data) {
                    response = $.parseJSON(data.contents);
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

                  this.searchCoords = response.result.geometry.location;
                  console.dir(this);
              })
          }
       });
        
      //set up the location link, and set it to be replaced with the textfield when clicked
      this.$searchLocationLink = $('<a />')
        .text(Circle.currentLocation)
        .appendTo(this.$container)
        .click($.proxy(this.showSearchLocationField, this));

      //finally, we set up autocomplete for the form field
      this.$element
        .typeahead({
            //gets autocomplete data from the google maps API
            source: function(typeahead, query) {
              var url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + query + '&sensor=false&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4';
                
              //encode search with location and a 50-mile radius to locally-biased results
              if (typeof Circle.searchLocation !== "undefined") {
                var coords = Circle.searchLocation.coords;
              } else {
                var coords = Circle.position.coords;
              }
              if (typeof coords !== "undefined") {
                url += '&location=' + coords.latitude + ',' + coords.longitude + '&radius=80000';
              }

              //do the request!
              $.getJSON(
                  'http://whateverorigin.org/get?url=' + encodeURIComponent(url) + '&callback=?', 
                    function(data) {
                      var response = $.parseJSON(data.contents);
                      typeahead.process(response.predictions);
                  } 
            )},
            property: "description", 
            onselect: this.getLocationDetails
         });
    }

    /**
     * hides the clicked link, and replaces it with a form field so the user can input a custom location
     * @return {void} 
     */
  , showSearchLocationField: function() {
      this.$searchLocationLink.hide();
      this.$searchLocationField.fadeIn(function() {$(this).select()});
    }

    /**
     * When a user selects a venue, get the venue details (esp. lat/lng data) from Google Places API
     * @param  {Object} val The Google Places Autocomplete object for the venue the user selected
     * @return {void} 
     */
  , getLocationDetails: function(val) {
      var that = this;
      $.getJSON('http://whateverorigin.org/get?url=' + encodeURIComponent('https://maps.googleapis.com/maps/api/place/details/json?reference=' + val.reference + '&sensor=false&key=AIzaSyDi1oeiNkBAo_dNgbJwdcY-usEv-d6FOt4') + '&callback=?',
        function(data) {
          var response = $.parseJSON(data.contents);

          that.venue = {
            address: response.result.formatted_address,
            location: response.result.geometry.location
          };

          if (response.result.types.indexOf('street_address') == -1) {
          // i.e. it's an establishment, and not just an address
            that.venue.name = response.result.name;
          }

          console.log("*** VENUE DATA FOLLOWS: Let's do something with it sometime! ***");
          console.dir(that.venue);
        });
    }
}

    /* PLUGIN DEFINITION
   * ===================== */

  $.fn.venueTypeahead = function ( option ) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('venueTypeahead')
        , options = typeof option == 'object' && option
      if (!data) $this.data('venueTypeahead', (data = new VenueTypeahead(this, options)))
      if (typeof option == 'string') data[option]() //apply function
    })
  }

  $.fn.venueTypeahead.defaults = {
    key: 'value' //TBD
  }

  $.fn.venueTypeahead.Constructor = VenueTypeahead


 /* VENUE TYPEAHEAD DATA-API
  * ================== */

  $(function () {
    $('body').on('focus.venueTypeahead.data-api', '[data-provide="venueTypeahead"]', function (e) {
      var $this = $(this)
      if ($this.data('venueTypeahead')) return
      e.preventDefault()
      $this.venueTypeahead($this.data())
    })
  })
} (window.jQuery);