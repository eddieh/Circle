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
    'click #save': 'save'
  },

  initialize: function (args) {
		this.template = t('create-event-view');
    this.categories = new Circle.CategoryList();
  },

  whereChanged: function (e, venueInfo) {
    console.log('Loc>>>>>');
    console.dir(venueInfo);
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
    console.log('Cat>>>>');
    console.dir(category);
    this.selectedCategory = category;
    $('#category').html(this.selectedCategory.get('name'));
    this.model.set('category', {
      '__type': 'Pointer',
      'className': 'Category',
      'objectId': this.selectedCategory.id
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
    if (this.model.isNew()) {
      this.model.save();
    } else {
      this.model.save();
    }
    this.$el.modal('hide');
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

    return this;
  }

});

Circle.currentLocation = null;
Circle.position = null;
Circle.mapOptions = {
  zoom: 9,
  mapTypeId: google.maps.MapTypeId.ROADMAP,
  scrollwheel: false
};
Circle.map = null;

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
  var latlng = new google.maps.LatLng(pos.coords.latitude,
                                      pos.coords.longitude);


    Circle.map = new google.maps.Map(document.getElementById('map_canvas'),
                                     Circle.mapOptions);
    var markerImage = new google.maps.MarkerImage(
      'img/blue dot.png',
      new google.maps.Size(50, 50),
      new google.maps.Point(0,0),
      new google.maps.Point(25, 25));

    var marker = new google.maps.Marker({
      map: Circle.map,
      position: latlng,
      icon: markerImage
    });


  Circle.map.setCenter(latlng);
}

Circle.errorPosition = function () {
};

Circle.getPosition = function () {
  if (!Circle.position) {
    // get the location from the browser, if supported
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(Circle.gotPosition,
                                               Circle.errorPosition);
    }
  }
}

Circle.Router = Backbone.Router.extend({
  routes: {
    '': 'home',
    'events': 'events',
    'search': 'search',
    'create-event-modal': 'createEvent'
  },

  home: function () {
    $('#layout.container').html(t('home-layout')());
    Circle.getPosition();

    // setup our fancy carousel
    $('.carousel').carousel();

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
    });
    Circle.setMapCenter(Circle.position);
  },

  events: function () {
    $('#layout.container').html(t('events-layout')());
    Circle.getPosition();

    // the collections of models
    Circle.events = new Circle.EventList();

    // the list view
    Circle.eventsView = new Circle.EventListView({
      // the selector corresponding to the element this view should be
      // attached to
      el: '#event-list',

      // the collection
	    model: Circle.events
    });

    function get_em () {
      // get the data from Parse
      Circle.events.fetch({
        data: 'where=' + JSON.stringify({
          location: {
            '$nearSphere': {
              '__type': 'GeoPoint',
              'latitude': Circle.position.coords.latitude,
              'longitude': Circle.position.coords.longitude
            },
            '$maxDistanceInMiles': 20.0
          }
        })
      });
      Circle.setMapCenter(Circle.position);
    }

    if (Circle.position) {
      get_em();
    }

    $(window).on('location:change', function () {
      get_em();
    });
  },

  search: function () {
  },

  createEvent: function () {
    $('#create-event-modal').modal('show');
    $('#create-event-modal').on('hidden', function () {
      Circle.app.navigate('', {
        trigger: false
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

  }
});

$(function () {
  // make moment.js global
  window.moment = Kalendae.moment;

  // set up the backbone.js router
  Circle.app = new Circle.Router();
  Backbone.history.start();
});
