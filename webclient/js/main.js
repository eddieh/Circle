/*
 *  Setup Backbone to work with Parse
 *
 *  We must include the X-Parse-Application-Id and
 *  X-Parse-REST-API-Key headers.
 */
var originalSync = Backbone.sync;
Backbone.sync = function (method, model, options) {
  if (!options) options = {};
  return originalSync(method, model, _.extend(options, {
    headers: {
      'X-Parse-Application-Id':'FFO9TzzLbMB5A4PM8A0vzNpb0M8DSeAgbsP0fGNB',
      'X-Parse-REST-API-Key': 'YwfE7q918UGjEkpufKPpm5GMgPI5jK08Pf2meEkh'
    }
  }));
}

/*
 * Handlebars Helper
 */
function t(name) {
	return Handlebars.compile($('#' + name + '-template').html());
}

Handlebars.registerHelper('dateAsCalendar', function(date) {
  //text = Handlebars.Utils.escapeExpression(text);
  date = moment(date.iso);
  var json = {
    month: date.monthStr(),
    weekday: date.weekdayStr(),
    day: date.date()
  };
  return new Handlebars.SafeString(t('calendar-day')(json));
});

Handlebars.registerHelper('dateAsCalendarWithTime', function(date) {
  //text = Handlebars.Utils.escapeExpression(text);
  date = moment(date.iso);
  var json = {
    month: date.monthStr(),
    weekday: date.weekdayStr(),
    day: date.date(),
    time: date.format('h:mm a')
  };
  return new Handlebars.SafeString(t('calendar-day-time')(json));
});

Handlebars.registerHelper('directionsLink', function(destLocation) {
  return Circle.directionsLink(destLocation);
});

/* Setup the Circle namespace */
var Circle = {};

/* Models */
Circle.Event = Backbone.Model.extend({
  // Parse uses objectId for the entities id, so tell backbone about
  // it
  idAttribute: 'objectId',

  // this is where backbone will POST to when creating a new Event
  // entity.
  urlRoot: 'https://api.parse.com/1/classes/Event'

  // toJSON_: function (options) {
  //   options = {
  //     'categoryName': function () {
  //     }
  //   }
  //   return _.extend(_.clone(this.attributes), {
  //   });
  // }
});

Circle.EventList = Backbone.Collection.extend({
  // this collections model
	model: Circle.Event,

  // this is where backbone will make a GET request to when fetching a
  // list of events
	url: 'https://api.parse.com/1/classes/Event',

  // parse sends the response back from the server in the following form:
  //
  // {
  //   "results":[{...}, {...}]
  // }
  //
  // where the values we want are inside of 'results' we can ensure we
  // get only the values like so:
  parse: function (response) {
    return response.results;
  }
});

/* Views */
Circle.EventListItemView = Backbone.View.extend({
  tagName: 'tr',
  className: 'event',

  events: {
    'mouseenter': 'showOnlyMyMapPin',
    'mouseleave': 'showAllMapPins'
  },

  initialize: function () {
    // since we're extending Backbone.View objects before the DOM is
    // ready we must set the view's template inside of initialize() so
    // that _.template is not called when we extend Backbone.View.
    this.template = t('event-list-item-view');
  },

	render: function () {
		this.$el.html(this.template(this.model.toJSON()));

    // render should alway return this
		return this;
	},

  showOnlyMyMapPin: function () {
    //grey out all of the other map pins but this'
    var objectId =this.model.attributes.objectId;

    for (id in Circle.markers) {
      var marker = Circle.markers[id];

      if (id != objectId) {
        marker.setIcon(Circle.mapOptions.disabledMarkerIcon);
      } else {
        marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
      }
    }
  },

  showAllMapPins: function () {
    //return state of all map pins to normal

    var objectId =this.model.attributes.objectId;

    for (id in Circle.markers) {
      var marker = Circle.markers[id];
      marker.setIcon(marker.origIcon);

      //reset the z-index if we made it jump to the front on mouseenter
      if (id == objectId) {
        marker.setZIndex(1);
      }
    }
  }

});

Circle.EventListView = Backbone.View.extend({
  initialize: function () {
    // setup event handlers for events triggered by the collection,
    // note the last parameter 'this' ensures when the handlers are
    // called our functions run in the context of this object
    this.model.on('add', this.addOne, this);
		this.model.on('reset', this.addAll, this);
		this.model.on('all', this.render, this);
  },

	render: function () {
		return this;
	},

  // add a single item to the list, the parameter 'item' will be a
  // single model of the collection. note: this is called be addAll.
	addOne: function (item) {
    var view = new Circle.EventListItemView({model: item});
    this.$el.append(view.render().el);
	},

  // add all the models in the collection 'this.model' to the list
	addAll: function () {
    // note the last parameter 'this' ensures that addOne is run in
    // the correct context
		this.model.each(this.addOne, this);
	}
});

Circle.EventSlideshowSlideView = Backbone.View.extend ({
  initialize: function () {
    // since we're extending Backbone.View objects before the DOM is
    // ready we must set the view's template inside of initialize() so
    // that _.template is not called when we extend Backbone.View.
    this.template = t('event-slideshow-slide-view');
    this.model.on('reset', this.render, this);
  },

  render: function() {
    //the first slide needs to have class "active" so we set that here
    var json = this.model.toJSON();

    //render template
    json[0].active = ' active';
    this.$el.html(this.template(json));

    // setup our fancy carousel
    $('.carousel').carousel();
    return this;
  }

}),


Circle.Category = Backbone.Model.extend({
  // Parse uses objectId for the entities id, so tell backbone about
  // it
  idAttribute: 'objectId',

  // this is where backbone will POST to when creating a new Category
  // entity.
  urlRoot: 'https://api.parse.com/1/classes/Category'
});

Circle.CategoryList = Backbone.Collection.extend({
  // this collections model
	model: Circle.Category,

  // this is where backbone will make a GET request to when fetching a
  // list of categories
	url: 'https://api.parse.com/1/classes/Category',

  // parse sends the response back from the server in the following form:
  //
  // {
  //   "results":[{...}, {...}]
  // }
  //
  // where the values we want are inside of 'results' we can ensure we
  // get only the values like so:
  parse: function (response) {
    return response.results;
  }
});

Circle.CategoryListItemView = Backbone.View.extend({
  tagName: 'li',
  controller: null,

  events: {
    'click': 'click'
  },

  initialize: function (args) {
    this.template = t('category-list-item-view');
    this.controller = args.controller;
  },

  click: function (e) {
    this.controller.selectCategory(this.model);
  },

	render: function () {
		this.$el.html(this.template(this.model.toJSON()));
		return this;
	}
});

Circle.CategoryListView = Backbone.View.extend({
  controller: null,

  initialize: function (args) {
    this.model.on('add', this.addOne, this);
		this.model.on('reset', this.addAll, this);
		this.model.on('all', this.render, this);
    this.controller = args.controller;
  },

	render: function () {
		return this;
	},

	addOne: function (item) {
    var view = new Circle.CategoryListItemView({
      model: item,
      controller: this.controller
    });
    this.$el.append(view.render().el);
	},

	addAll: function () {
		this.model.each(this.addOne, this);
	}
});

Circle.CreateEventView = Backbone.View.extend({
  template: null,

  events: {
    'click .my-date-picker .add-on': 'showDatePicker',
    'click .my-time-picker .add-on': 'showTimePicker',
    'click #add-end-time': 'addEndTime',
    'click #remove-end-time': 'removeEndTime',
    'click #close': 'close',
    'click #save': 'save',
    'click #image-close-button': 'reshowUploadButton'
  },

  initialize: function (args) {
		this.template = t('create-event-view');
    this.categories = new Circle.CategoryList();
  },

  whereChanged: function (e, venueInfo) {
    if (!venueInfo) return;
    this.model.set('address', venueInfo.address);
    this.model.set('location', {
      '__type': 'GeoPoint',
      'latitude': venueInfo.location.lat,
      'longitude': venueInfo.location.lng
    });
    this.model.set('venueName', venueInfo.name);
  },

  showDatePicker: function (e) {
    var clickedElement = e.currentTarget;
    $('.auto-kal', clickedElement.parentElement).focus();
  },

  showTimePicker: function (e) {
    var clickedElement = e.currentTarget;
    $('.auto-time', clickedElement.parentElement).focus();
  },

  addEndTime: function (e) {
    $('#add-end-time').hide();
    $('#end-time-group').show();
  },

  removeEndTime: function (e) {
    $('#add-end-time').show();
    $('#end-time-group').hide();
  },

  selectCategory: function (category) {
    this.selectedCategory = category;
    $('#category').html(this.selectedCategory.get('name'));
    this.model.set('category', {
      '__type': 'Pointer',
      'className': 'Category',
      'objectId': this.selectedCategory.id
    });
  },

  // when you use the server files they give you, the server returns two other parameters
  // that parse doesn't, so ignore the first two parameters because they're junk
  showUploadedImageAndHideUploadButton: function(useless_variable, useless_also, json) {
    var that = this;

    //show a thumbnail of the uploaded image
    var $container = $('#uploaded-image');
    $container.find('img').attr('src', json.url);

    var $uploader = $("#file-uploader").fadeOut();

    $container.fadeIn();

    //remove the filename now that we're done uploading
    $uploader.find('li').remove();

    //change the label
    $('#upload-label')
      .html('<a>Choose a different image?</a>')
      .click(that.reshowUploadButton);

    this.imageUploadedNamed(json.name);
  },

  reshowUploadButton: function(e) {
    $('#uploaded-image').fadeOut();
    var $uploader = $('#file-uploader').fadeIn();
    $('#upload-label').off('click').text('Upload an image?');
  },

  /*
   the first two parameters are returned by the server files included with
   this plugin, but not by parse, so they're basically junk for our purposes
   */
  imageUploadedNamed: function(name) {
    this.model.set('image', {
      '__type': 'File',
      'name': name
    });
  },

  setupUploader: function() {
    var that = this;
    var uploader = new qq.FileUploader({
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],

      // pass the dom node (ex. $(selector)[0] for jQuery users)
      element: document.getElementById('file-uploader'),

      // path to server-side upload script
      action: 'https://api.parse.com/1/files',

      // override to change the button text or style (css classes defined in fileuploader.css).
      // the upload area allows you to drag and drop files to upload, and the upload list is a
      // list of the files uploaded. neither of these can be removed without breaking the plugin.
      template: '<div class="qq-uploader">' +
                '<div class="qq-upload-drop-area"><span>Drop files here to upload</span></div>' +
                '<div class="qq-upload-button btn btn-success">Choose file</div>' +
                '<ul class="qq-upload-list"></ul>' +
             '</div>',

      onComplete: $.proxy(that.showUploadedImageAndHideUploadButton, that)
    });
  },

  close: function (e) {
    this.$el.modal('hide');
  },

  save: function (e) {
    var startDate = null,
        endDate = null;
    try {
      startDate = moment($('#startDate').val() +
             ' ' +
             $('#startTime').val(),
             'MM/DD/YYYY h:mm a').toDate();
    } catch (e) {
      startDate = new Date();
    }
    try {
      endDate = moment($('#endDate').val() +
                       ' ' +
                       $('#endTime').val(),
                       'MM/DD/YYYY hh:mm a').toDate();
    } catch (e) {
      endDate = new Date();
    }

    this.model.set({
      name: $('#name').val(),
      details: $('#details').val(),
      startDate: {
        '__type': 'Date',
        'iso': startDate
      },
      endDate: {
        '__type': 'Date',
        'iso': endDate
      }
    });

    var self = this;
    this.model.save().done(function (response, status) {
      self.$el.modal('hide');

      // Parse sends the objectId back in the response, so let's use
      // it to navigate to the event's detail page.
      Circle.app.navigate('detail/' + response.objectId, {
        trigger: true
      });
    });
  },

  render: function () {
    this.$el.html(this.template(this.model.toJSON()));

    if (!this.categoryListView) {
      this.categoriesView = new Circle.CategoryListView({
        el: '#category-list',
        model: this.categories,
        controller: this
      });
      this.categories.fetch();
    }

    if (!this.venueTypeaheadConfigured) {
      $('.venue-typeahead', this.$el)
          .venueTypeahead()
          .on('change', $.proxy(this.whereChanged, this));
      this.venueTypeaheadConfigured = true;
    }

    this.setupUploader();

    return this;
  }

});

/** Geolocation */
Circle.position = null;

/** Formatted address */
Circle.currentLocation = null;


Circle.mapOptions = {
  zoom: 9,
  mapTypeId: google.maps.MapTypeId.ROADMAP,
  scrollwheel: false,
  //this is the icon we set non-active map pins to when we hover over
  //an event list row
  disabledMarkerIcon: new google.maps.MarkerImage(
    "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|CCCCCC")
};
Circle.map = null;

/**
 * Construct a Google maps directions link given a destination
 * address. The start address is the current value of Circle.position
 * or Circle.currentLocation.
 */
Circle.directionsLink = function (destLocation) {
  var startLocation = Circle.position ?
      '' + Circle.position.coords.latitude
      + ',' +
      Circle.position.coords.longitude :
      Circle.currentLocation ?
      Circle.currentLocation : '';

  return ('http://maps.google.com/maps?saddr=' +
          startLocation +
          '&daddr=' +
          destLocation);
};

/**
 * Performs a reverse geocoding given the position and triggers a
 * 'location:change' event on success.
 */
Circle.gotPosition = function (pos) {
  Circle.position = pos;
  Circle.setMapCenter(pos);

  var latlng = new google.maps.LatLng(pos.coords.latitude,
                                      pos.coords.longitude),
      geocoder = new google.maps.Geocoder();

  geocoder.geocode({'latLng': latlng}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      if (results[1]) {
        Circle.currentLocation = results[1].formatted_address;
        $(window).trigger('location:change');
      }
    } else {
      alert("Geocoder failed due to: " + status);
    }
  });
};

Circle.setMapCenter = function (pos) {
  var mapElement = document.getElementById('map_canvas');
  if (!mapElement) {
    console.log('no map');
    return;
  }

  var latlng = new google.maps.LatLng(pos.coords.latitude,
                                      pos.coords.longitude);


  Circle.map = new google.maps.Map(mapElement,
                                   Circle.mapOptions);

  var markerImage = new google.maps.MarkerImage(
    'img/blue dot.png',
    new google.maps.Size(50, 50),
    new google.maps.Point(0,0),
    new google.maps.Point(25, 25));

  Circle.youAreHere = new google.maps.Marker({
    map: Circle.map,
    position: latlng,
    icon: markerImage
  });

  Circle.map.setCenter(latlng);
}

Circle.errorPosition = function () {
};

//
Circle.markers = {};

Circle.setMapPinsWithData = function (data) {
  // allow for a passed in collection or a passed in array of models
  var models = data.models ? data.models : data;

  var newMarkers = {};
  var bounds = new google.maps.LatLngBounds();

  // ensure we start with no markers
  Circle.markers && delete Circle.markers;
  Circle.markers = {};

  /*
   Iterate through the list of markers. If it's not in there, already,
   create it.

   If it is in the list of markers, but not in the new list of events,
   remove it.
   */
  for (var i = 0, len = models.length; i < len; i++) {
    var attribs = models[i].attributes;

    var html = '<h1>' + attribs.name +
        '<div class="infowindow"></h1><h4>at' +
        attribs.venueName + '</h4><p>' +
        attribs.details + '</p></div>';

    //generate a randomly-colored pin
    var pinColor = randomColor();
    var src = "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|" + pinColor;

    var pinImage = new google.maps.MarkerImage(src,
                                               new google.maps.Size(21, 34),
                                               new google.maps.Point(0,0),
                                               new google.maps.Point(10, 34));
    var pinShadow = new google.maps.MarkerImage(
      "http://chart.apis.google.com/chart?chst=d_map_pin_shadow",
      new google.maps.Size(40, 37),
      new google.maps.Point(0, 0),
      new google.maps.Point(12, 35));

    //These are the appearance options for the marker
    var markerOpts = {
      map: Circle.map,
      position: new google.maps.LatLng(
        attribs.location.latitude,
        attribs.location.longitude
      ),
      title: attribs.name,
      content: html,
      icon: pinImage,
      shadow: pinShadow,
      //these aren't necessary for the google maps constructor - just
      //stashing some info
      origIcon: pinImage, //we save this for when we change marker
    };

    newMarkers[attribs.objectId] = new google.maps.Marker(markerOpts);

    //here we prepend the marker image to the appropriate table row
    $('<img />')
        .attr('src', src)
        .addClass('marker')
        .prependTo($('#' + attribs.objectId));

    //create a bounds object that fits all the objects
    bounds.extend(newMarkers[attribs.objectId].getPosition());
  }

  //fit the map to the new bounds
  bounds.extend(Circle.youAreHere.getPosition());
  Circle.map.fitBounds(bounds);

  //reset the globla markers object
  Circle.markers = newMarkers;
};

/**
 * Get the geolocation position from the browser if we don't already
 * have it.
 *
 * Calls Circle.gotPosition on success. Circle.gotPositon performs a
 * reverse geocoding given the position and triggers a
 * 'location:change' event on success.
 *
 * If we already have a position call the callback if provided.
 */
Circle.getPositionFromBrowser = function () {
  if (!Circle.position) {
    // get the location from the browser, if supported
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(Circle.gotPosition,
                                               Circle.errorPosition);
    }
  } else {
    Circle.gotPosition(Circle.position);
  }
}

/**
 * Get the events near a position, or near the current position saved
 * in Circle.position if no position is provided. Optionally pass a
 * radius in miles and/or a query.
 *
 * position = {
 *   coords: {
 *     latitude: 42.0,
 *     longitude: 13.1
 *   }
 * }
 *
 * @param {Dict} position See above.
 * @param {Number} radius The search radius in miles (defaults to 20
 *                        miles).
 * @param {Dict} query See <https://parse.com/docs/rest#queries>.
 *
 */
Circle.getEventsNearPosition = function (position, radius, query) {
  if (!position) position = Circle.position;
  if (!radius) radius = 20.0;

  var base_query = {
    location: {
      '$nearSphere': {
        '__type': 'GeoPoint',
        'latitude': position.coords.latitude,
        'longitude': position.coords.longitude
      },
      '$maxDistanceInMiles': radius
    }
  };

  // since: _.extend({one:1}, undefined) => {one:1}
  query = _.extend(base_query, query);

  // get the data from Parse
  Circle.events.fetch({
    data: 'where=' + JSON.stringify(query),
    success: function(collection, response) {
      Circle.setMapPinsWithData(collection);
    }
  });

  // set the center of the map too
  Circle.setMapCenter(position);
}

/**
 * Get events that match 'query'. This calls
 * Circle.getEventsNerPosition passing undefined as the first two
 * arguments.
 *
 * @param {Dict} query See <https://parse.com/docs/rest#queries>.
 */
Circle.getEventsWithQuery = function (query) {
  Circle.getEventsNearPosition(undefined, undefined, query);
}

Circle.Router = Backbone.Router.extend({
  routes: {
    '': 'home',
    'events/': 'events',
    'events/:query': 'events',
    'detail/:event_id': 'detail',
    'create-event-modal': 'createEvent'
  },

  home: function () {
    $('#layout.container').html(t('home-layout')());

    // if our location changes update our events
    $(window).one('location:change', function (e) {
      Circle.getEventsNearPosition();
    });

    $('#search-button').on('click', function (e) {
      var query = $('#search-field').val();
      Circle.app.navigate('events/' + query, {
        trigger: true
      });
    });

    if (!Circle.events) {
      // create the collections of models
      Circle.events = new Circle.EventList();
    }

    Circle.eventSlideshow = new Circle.EventSlideshowSlideView({
      el: '#slides',
      model: Circle.events
    });

    // setup our fancy city selector
    $('.city-picker').cityPicker({
      attachedTo: $('#search-field')
    }).on('change', function (e, val) {
      Circle.currentLocation = val.formatted_address;
      Circle.position = {
        coords: {
          latitude: val.geometry.location.lat,
          longitude: val.geometry.location.lng
        }
      };
      Circle.setMapCenter(Circle.position);

      Circle.getEventsNearPosition();
    });

    Circle.getPositionFromBrowser();
  },

  events: function (query) {
    $(window).off('location:change');

    $('#layout.container').html(t('events-layout')());

    // put the query into the search field
    $('#search-field').val(query ? query : '');

    // handle window resizing
    function resizeMap () {
      $('.map-wrapper').width($('#map-area').width());
    };
    resizeMap();
    $(window).resize(resizeMap);

    var parse_query = {
      '$or': [
        {'name': {'$regex': query, '$options': 'im'}},
        {'details': {'$regex': query, '$options': 'im'}},
        {'venueName': {'$regex': query, '$options': 'im'}},
        {'category': {
          '$inQuery': {
            'where' : {
              'name': {'$regex': query, '$options': 'im'}
            },
            'className': 'Category'
          }
        }}
      ]
    };

    // if our location changes update our events
    $(window).one('location:change', function (e) {
      //Circle.getEventsNearPosition();
      Circle.getEventsWithQuery(parse_query);
    });

     // create the collections of models, if needed
    if (!Circle.events) {
      Circle.events = new Circle.EventList();
    }

    /*
    Circle.events.comparator = function(event1, event2) {
      // "sort" comparator functions take two models, and return -1 if
      // the first model should come before the second, 0 if they are
      // of the same rank and 1 if the first model should come after.

    };
    */

    // the event list
    Circle.eventsView = new Circle.EventListView({
      // the selector corresponding to the element this view should be
      // attached to
      el: '#event-list',

      // the collection
	    model: Circle.events
    });

    Circle.getPositionFromBrowser();
  },

  detail: function (event_id) {
    $(window).off('location:change');

    var event = Circle.events ? Circle.events.get(event_id) : null;

    // if our location changes set the marker
    $(window).one('location:change', function (e) {
      Circle.setMapCenter(Circle.position);
      Circle.setMapPinsWithData([event]);

      $('#get-directions-button')
          .attr('href', Circle.directionsLink(event.get('address')));
    });

    function success () {
      var attribs = event.attributes;

      var markerOpts = {
        map: Circle.map,
        position: new google.maps.LatLng(attribs.location.latitude,
                                         attribs.location.longitude),
        title: attribs.name,
      };

      Circle.mymarker = new google.maps.Marker(markerOpts);

      var json = event.toJSON();
      delete json.details;

      $('#layout.container').html(t('detail-layout')(json));

      if (Circle.position) {
        Circle.setMapCenter(Circle.position);
        Circle.setMapPinsWithData([event]);
      } else {
        Circle.getPositionFromBrowser();
      }

      var wiki = new WikiCreole.Creole({
        forIE: document.all,
        interwiki: {},
        linkFormat: ''
      });
      var element = $('#details')[0];
      wiki.parse(element, event.get('details'));
    }

    if (!event) {
      event = new Circle.Event({objectId: event_id});
      event.fetch({
        success: success
      });
    } else {
      success();
    }

    Circle.getPositionFromBrowser();
  },

  search: function () {
  },

  createEvent: function () {
    $('#create-event-modal').modal('show');
    $('#create-event-modal').on('hidden', function () {
      Circle.app.navigate('', {
        // if there isn't a layout loaded then trigger the route, so
        // that we load a layout
        trigger: ($('#layout.container').html().trim() == '')
      });
      $('.kalendae').remove();
      $('.time-picker').remove();
    });

    var newEvent = new Circle.Event();
    var createEventView = new Circle.CreateEventView({
      model: newEvent,
      el: '#create-event-modal'
    }).render();

    $('.auto-kal').kalendae();
    $('.auto-time').timePicker({
      show24Hours: false,
      step: 30
    });

    Circle.getPositionFromBrowser();
  }
});

$(function () {
  // make moment.js global
  window.moment = Kalendae.moment;
  window.moment.fn.weekdayStr = function () {
    return moment.weekdaysShort[this.day()];
  };
  window.moment.fn.monthStr = function () {
    return moment.monthsShort[this.month()];
  };

  // set up the backbone.js router
  Circle.app = new Circle.Router();

  Backbone.history.on('route', function (router, routeName, args) {
		// get the navigation link, if there is one
		var selector = '#' + routeName + '-nav';
		var $el = $(selector);

		// deactivate the links
		$('.nav li').removeClass('active');

		// make this link active
		$el.addClass('active');
	});

  Backbone.history.start();
});
