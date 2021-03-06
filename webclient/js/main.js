/*
 *  Setup Backbone to work with Parse
 *
 *  We must include the X-Parse-Application-Id and
 *  X-Parse-REST-API-Key headers.
 */
var PARSE_HEADERS = {
  'X-Parse-Application-Id':'FFO9TzzLbMB5A4PM8A0vzNpb0M8DSeAgbsP0fGNB',
  'X-Parse-REST-API-Key': 'YwfE7q918UGjEkpufKPpm5GMgPI5jK08Pf2meEkh'
};
var originalSync = Backbone.sync;
Backbone.sync = function (method, model, options) {
  if (!options) options = {};
  var session;

  _.extend(options,
           // add default headers
           { headers: PARSE_HEADERS },
           // add to options 'X-Parse-Session-Token':
           Circle.me && (session = Circle.me.get('sessionToken')) ?
           { 'X-Parse-Session-Token': session } :
           {});

  return originalSync(method, model, options);
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
Circle.User = Backbone.Model.extend({
  // Parse uses objectId for the entities id, so tell backbone about
  // it
  idAttribute: 'objectId',

  // this is where backbone will POST to when creating a new User
  // entity.
  urlRoot: 'https://api.parse.com/1/users',

  initialize: function() {
    this.on('change:sessionToken', this.renewSession, this);
  },

  validate: function (attrs) {
    var errors = {};

    // don't validate the created response
    if (attrs.objectId) return;

    if (attrs.username == '') errors.username = 'required';
    if (attrs.email == '') errors.email = 'required';
    if (attrs.password == '') errors.password = 'required';
    if (attrs.password != this.confirmPassword) {
      errors.password = 'Passwords must match.';
      errors.confirmPassword = ''; //so both fields are error-colored
    }

    if (!_.isEmpty(errors)) return errors;
  },

  renewSession: function (e) {
    // set a cookie to keep the sessionToken around for 7 days
    monster.set('ParseSessionToken', this.get('sessionToken'), 7);
    // also store the user id for 7 days
    monster.set('ParseUserId', this.id, 7);
  },

  logout: function () {
    Circle.me = null;
    monster.remove('ParseSessionToken');
    monster.remove('ParseUserId');
  }
});

Circle.restoreSession = function () {
  var id = monster.get('ParseUserId');
  var sessionToken = monster.get('ParseSessionToken');

  function notLoggedIn() {
    $('#account').html(t('not-logged-in')());
    Circle.setupLoginAndSignup();
  }

  if (id) {
    Circle.me = new Circle.User({objectId: id});
    Circle.me.fetch({
      success: function (response, status) {
        Circle.me.set('sessionToken', sessionToken);
        $('#account').html(t('logged-in')(Circle.me.toJSON()));
      },
      error: function (response, status) {
        Circle.me = null;
        monster.remove('ParseSessionToken');
        monster.remove('ParseUserId');
        notLoggedIn();
      }
    });
  } else {
    Circle.me = null;
    monster.remove('ParseSessionToken');
    monster.remove('ParseUserId');
    notLoggedIn();
  }
}

Circle.AttendeeList = Backbone.Collection.extend({
  model: Circle.User,

  url:'https://api.parse.com/1/classes/Rsvp',

  parse: function (response) {
    var attending = false;
    var users = _.map(response.results, function (item, key) {
      if (Circle.me && Circle.me.id == item.user.objectId) {
        attending = true;
        Circle.me.set('RsvpId', item.objectId);
        this.trigger('attending', Circle.me, this, {index: key});
      }
      return item.user;
    }, this);
    if (!attending) {
      this.trigger('attending:no', Circle.me);
    }
    return users;
  },

  comparator: function (user) {
    return Circle.me && Circle.me.id == user.id ? 0 : 1;
  }
});

Circle.AttendeeListItemView = Backbone.View.extend({
  tagName: 'tr',
  className: 'attendee',

  events: {
  },

  initialize: function () {
    this.template = t('attendee-list-item-view');
  },

	render: function () {
		this.$el.html(this.template(this.model.toJSON()));
    return this;
	}
});

Circle.AttendeeListView = Backbone.View.extend({
  initialize: function () {
    this.model.on('add', this.addOne, this);
    this.model.on('remove', this.removeOne, this);
		this.model.on('reset', this.addAll, this);
		this.model.on('all', this.render, this);
  },

	render: function () {
		return this;
	},

	addOne: function (item, collection, options) {
    var view = new Circle.AttendeeListItemView({model: item});
    var row = view.render().el;
    if (Circle.me && Circle.me.id == item.id) {
      this.$el.prepend(row);
      view.$el.addClass('active');
    } else {
      this.$el.append(row);
    }
	},

  removeOne: function (item, collection, options) {
    $(this.$el.children()[options.index]).fadeOut().remove();
  },

	addAll: function () {
    $('tbody', this.$el).html('');
		this.model.each(this.addOne, this);
	}
});

/* Views */
Circle.SignUpView = Backbone.View.extend({
  template: null, //josh says: why? we define it in the initialize function? all well...

  events: {
    'click #signup-close': 'close',
    'click #signup-save': 'save',
    'click #image-close-button': 'reshowUploadButton',
  },

  initialize: function (args) {
    this.template = t('sign-up');
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
    }, {silent: true});
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
    var attrs = {
      name: $('#name').val(),
      username: $('#email').val(),
      email: $('#email').val(),
      password: $('#password').val(),
    };

    // store the confirmPassword as a model property, but not as an
    // attribute
    this.model.confirmPassword = $('#confirmPassword').val();

    var self = this;
    this.model.save(attrs, {
      error: function (model, response) {
        _.each(response, function (error, key) {
          var $el = $('#' + key),
              help = null;
          $el.parents('.control-group').addClass('error');
          help = $el.siblings('.help-inline');
          if (help.length == 0) {
            help = $el.parent().siblings('.help-inline');
          }
          help.text(error);
        });
      },
      success: function (model, response) {
        self.$el.modal('hide');
        Circle.me = self.model;
        $('#account').html(t('logged-in')(Circle.me.toJSON()));
      }
    });

    // remove password from the attributes
    this.model.unset('password');

    // ensure that we delete confirmPassword regardless of success
    // or fail
    delete this.model.confirmPassword;
  },

  render: function () {
    this.$el.html(this.template(this.model.toJSON()));
    this.setupUploader();

    return this;
  }

});

Circle.Event = Backbone.Model.extend({
  // Parse uses objectId for the entities id, so tell backbone about
  // it
  idAttribute: 'objectId',

  // this is where backbone will POST to when creating a new Event
  // entity.
  urlRoot: 'https://api.parse.com/1/classes/Event',

  validate: function (attrs) {
    var errors = {};

    if (attrs.name == '') errors.name = 'required';
    if (attrs.details == '') errors.details = 'required';

    if (!attrs.location) errors.where = 'required';
    if (!attrs.category) errors.category = 'required';

    if (!attrs.startDate) errors.startDate = 'invalid';

    if (!_.isEmpty(errors)) return errors;
  }
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
  },
  /**
   * the sorting function for the collection.
   * defaults to sorting by "happening soonest", but will sort differently
   * if Circle.EventList.sortBy is set.
   * @type {function}
   */
  comparator: function (event) {
    if (typeof Circle.sortBy === 'undefined'
      || Circle.sortBy === 'soonest') {
      /* compare the start dates to the current date/time.
       *
       * since our query to Parse only returns events that have yet to begin or in
       * progress, we don't have to worry about negative values; just means they'll
       * get sorted sooner in the list.
       */
      var now = new Date();
      var start = new Date(event.attributes.startDate.iso);
      return start - now;

    } else if (Circle.sortBy === 'nearest') {
      //convert from degrees to radians
      function toRad(x) {
        return x * Math.PI/180;
      };

      var lat1 = toRad(Circle.position.coords.latitude);
      var lon1 = toRad(Circle.position.coords.longitude);

      var lat2 = toRad(event.attributes.location.latitude);
      var lon2 = toRad(event.attributes.location.longitude);

      //this times 6371 would be the distance in KM
      ////or times 3959 for the distance in miles
      return Math.acos(Math.sin(lat1)*Math.sin(lat2) +
                  Math.cos(lat1)*Math.cos(lat2) *
                  Math.cos(lon2-lon1));
    }
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
    var row = view.render().el;
    this.$el.append(row);

    if (typeof Circle.markers[item.id] !== 'undefined') {
      var src = Circle.markers[item.id].origIcon.url;

      $('<img />')
          .attr('src', src)
          .addClass('marker')
          .prependTo($(row).find('td').eq(0));
    }
	},

  // add all the models in the collection 'this.model' to the list
	addAll: function () {
    $('tbody',this.$el).html('');
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

    if (json.length != 0) {
      //render template
      json[0].active = ' active';
      this.$el.html(this.template(json));

      // setup our fancy carousel
      $('.carousel').carousel();
    }

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
    'click #image-close-button': 'reshowUploadButton',
    'keyup #name': 'changeText',
    'keyup #details': 'changeText'
  },

  initialize: function (args) {
		this.template = t('create-event-view');
    this.categories = new Circle.CategoryList();
  },

  changeText: function (e) {
    var $el = $(e.target);
    if ($el.val().length > 0) {
      $el.parents('.control-group').removeClass('error');
      $el.siblings('.help-inline').text('');
    }
  },

  whereChanged: function (e) {
    //We attach the venue data to the event object when we trigger the event
    //in jquery.venueTypeahead.js
    var venueInfo = e.venue;
    this.model.set('address', venueInfo.address, {silent: true});
    this.model.set('location', {
        '__type': 'GeoPoint',
       'latitude': venueInfo.location.lat,
       'longitude': venueInfo.location.lng
      },
      {silent: true}
    );
    this.model.set('venueName', venueInfo.name, {silent: true});
    var $el = $('#where');
    $el.parents('.control-group').removeClass('error');
    $el.siblings('.help-inline').text('');
  },

  showDatePicker: function (e) {
    var clickedElement = e.currentTarget;
    $('.auto-kal', clickedElement.parentElement).focus();
  },

  showTimePicker: function (e) {
    var clickedElement = e.currentTarget;
    $('.auto-time', clickedElement.parentElement).focus();
  },

  fixEndDate: function (startDate) {
    // get the base end date from the current start date or now if we
    // can't construct a valid date from the values in startDate and
    // startTime
    var endDate = null;
    try {
      endDate = moment((startDate ?
             startDate :
             $('#startDate').val()) +
             ' ' +
             $('#startTime').val(),
             'MM/DD/YYYY h:mm a');
    } catch (e) {
      endDate = moment();
    }

    // the end date is seeded with the start date
    $('#endDate').val(endDate.format('MM/DD/YYYY'));

    // fix the minutes so that the time is of the form 6:00 pm or 6:30
    // pm only.
    var minutesToNextHour = 60 - endDate.minutes();
    if (minutesToNextHour < 30) {
      endDate.minutes(0);
      endDate.add('hours', 1);
    } else {
      endDate.minutes(30);
    }

    // end date is always seeded to be 4 hours after the start date
    endDate.add('hours', 4);

    $('#endTime').val(endDate.format('h:mm a'));
  },

  addEndTime: function (e) {
    $('#add-end-time').hide();
    $('#end-time-group').show();

    this.fixEndDate();
  },

  removeEndTime: function (e) {
    $('#add-end-time').show();
    $('#end-time-group').hide();

    $('#endDate').val('');
    $('#endTime').val('');
  },

  startDateChanged: function (startDate) {
    // if the start date is now past the end date, set the end date to
    // the start date
    if (moment($('#endDate').val()).diff(moment(startDate)) < 0) {
      this.fixEndDate(startDate);
    }
  },

  startTimeChanged: function () {
  },

  endDateChanged: function () {
  },

  endTimeChanged: function () {
  },

  selectCategory: function (category) {
    var $el = $('#category');
    this.selectedCategory = category;
    $el.html(this.selectedCategory.get('name'));
    this.model.set('category', {
      '__type': 'Pointer',
      'className': 'Category',
      'objectId': this.selectedCategory.id
    }, {silent: true});
    $el.parents('.control-group').removeClass('error');
    $el.siblings('.help-inline').text('');
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
    }, {silent: true});
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
      startDate = null;
    }
    try {
      endDate = moment($('#endDate').val() +
                       ' ' +
                       $('#endTime').val(),
                       'MM/DD/YYYY hh:mm a').toDate();
    } catch (e) {
      endDate = null;
    }

    var attrs = {
      name: $('#name').val(),
      details: $('#details').val(),
      startDate: startDate ? {
        '__type': 'Date',
        'iso': startDate
      } : null,
      endDate: endDate ? {
        '__type': 'Date',
        'iso': endDate
      } : null,

    };

    var self = this;
    this.model.save(attrs, {
      error: function (model, response) {
        _.each(response, function (error, key) {
          var $el = $('#' + key),
              help = null;
          $el.parents('.control-group').addClass('error');
          help = $el.siblings('.help-inline');
          if (help.length == 0) {
            help = $el.parent().siblings('.help-inline');
          }
          help.text(error);
        });
      },
      success: function (model, response) {
        self.$el.modal('hide');

        // Parse sends the objectId back in the response, so let's use
        // it to navigate to the event's detail page.
        Circle.app.navigate('detail/' + response.objectId, {
          trigger: true
        });
      }
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

    var that = this;
    if (!this.venueTypeaheadConfigured) {
      $('.venue-typeahead', this.$el)
          .venueTypeahead()
          .on('change', function(e) {
            that.whereChanged(e);
          });
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

Circle.infoWindow = new google.maps.InfoWindow;

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
  google.maps.event.addListener(Circle.map, 'click', function () {
    Circle.infoWindow.close();
  });
}

Circle.errorPosition = function () {
};

//
Circle.markers = {};


/**
 * Set up up the map pins and assigns infowindow content to each
 * @param {backbone collection or array}  data The models or data for each event
 * @param {Boolean} isDetailView If isDetailView, renders a different template
 *     without the "find out more!" link
 */
Circle.setMapPinsWithData = function (data, isDetailView) {
  // allow for a passed in collection or a passed in array of models
  var models = data.models ? data.models : data;

  var newMarkers = {};
  var bounds = new google.maps.LatLngBounds();

  // ensure we start with no markers
  Circle.markers && delete Circle.markers
  $('.marker').remove();
  Circle.markers = {};

  /*
   Iterate through the list of markers. If it's not in there, already,
   create it.

   If it is in the list of markers, but not in the new list of events,
   remove it.
   */
  for (var i = 0, len = models.length; i < len; i++) {
    var attribs = models[i].attributes;

    //get the first 15 words for the infowindow snippet
    var detailsArray = attribs.details.split(' ');
    if (detailsArray.length > 15) {
      detailsArray = detailsArray.slice(0, 15);
      attribs.detailsSnippet = detailsArray.join(" ") + " ...";
    } else {
      attribs.detailsSnippet = attribs.details;
    }

    var content;
    if (isDetailView) {
      content = t('infowindow-detail')(attribs);
    } else {
      content = t('infowindow')(attribs);
    }

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
      content: content,
      icon: pinImage,
      shadow: pinShadow,
      //these aren't necessary for the google maps constructor - just
      //stashing some info
      origIcon: pinImage, //we save this for when we change marker
    };

    var marker = new google.maps.Marker(markerOpts);
    google.maps.event.addListener(marker, 'click', function() {
      Circle.infoWindow.setContent(this.content);
      Circle.infoWindow.open(Circle.map, this);
    });

    //here we prepend the marker image to the appropriate table row
    $('<img />')
        .attr('src', src)
        .addClass('marker')
        .prependTo($('#' + attribs.objectId));

    //create a bounds object that fits all the objects
    bounds.extend(marker.getPosition());
    newMarkers[attribs.objectId] = marker;
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
    $(window).trigger('location:change');

    // this causes the generic city name to become super specific when
    // navigating back to the homepage
    //Circle.gotPosition(Circle.position);
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
  var now = new Date();

  var base_query = {
    location: {
      '$nearSphere': {
        '__type': 'GeoPoint',
        'latitude': position.coords.latitude,
        'longitude': position.coords.longitude
      },
      '$maxDistanceInMiles': radius,
    },
    //'startDate': { '$gte': { "__type": "Date", "iso":now.toISOString() }}
    //get only events that are now or in the future
  };

  // since: _.extend({one:1}, undefined) => {one:1}
  query = _.extend(base_query, query);

  //HACK: (the hackiest!) We need to "or" constraints "and"-ed together, so we kludge in some
  //handwritten JSON
  // var dateConstraint = ',"$or":[{"startDate":{"$gte":{"__type":"Date","iso":"'
  //   + now.toISOString() + '"}}},{"endDate":{"$gte":{"__type":"Date","iso":"' + now.toISOString() +'"}}}]}';
  query = JSON.stringify(query);
  Circle.events.fetch({
    data: 'where=' + query,
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

Circle.setupLoginAndSignup = function () {
  //set up login and signup popover/modal views
  $('#login-nav')
      .popover({
        title: '<a id="close-login" class="close">&times;</a><h3>Login</h3>',
        content: t('login'),
        placement: 'bottom',
        trigger: 'manual'
      })
      .click(function (e) {
        // stop proagation of the event, otherwise we bind the body's
        // click.hideLoginPopover event before THIS click bubbles up,
        // hiding the login popover before we even see it.
        e.stopPropagation();

        var $that = $(this);
        $that.popover('show');

        var performLogin = function () {
          var $this = $(this).button('loading');
          $.ajax('https://api.parse.com/1/login', {
            type: 'GET',
            headers: PARSE_HEADERS,
            data: {
              username: $('input[name="username"]').val(),
              password: $('input[name="password"]').val()
            },
            success: function (response, status) {
              $that.popover('hide');
              Circle.me = new Circle.User(response);
              Circle.me.renewSession();
              $('#account').html(t('logged-in')(Circle.me.toJSON()));
            },
            error: function (response, status) {
              $this.button('incorrect');
            }
          });
        }

        // bind the login button
        $('#login-button').on('click', performLogin);
        $('#login-username, #login-password').on('keyup', function(e) {
          if (e.which == 13) performLogin();
        });

        // bind a close event to the popover close &times;
        $('#close-login').one('click', function () {
          $that.popover('hide');
        });

        // bind a close event to everywhere else BUT the popover
        $('body').on('click.hideLoginPopover',function (e) {
          if ($(e.srcElement).closest('.popover').length == 0) {
            $that.popover('hide');
            $('body').off('click.hideLoginPopover');
          }
        });
      });
}

Circle.Router = Backbone.Router.extend({
  routes: {
    '': 'home',
    'events': 'events',
    'events/': 'events',
    'events/:query': 'events',
    'detail/:event_id': 'detail',
    'create-event-modal': 'createEvent',
    'sign-up-modal': 'signUp',
    'logout': 'logout',
    '*default': 'home'
  },

  home: function () {
    $('#layout.container').html(t('home-layout')());

    // if our location changes update our events
    $(window).one('location:change', function (e) {
      Circle.getEventsNearPosition();
    });

    var doSearch = function (e) {
      var query = $('#search-field').val();
      Circle.app.navigate('events/' + query, {
        trigger: true
      });
    }

    $('#search-field').on('keyup', function (e) {
      if (e.which == 13) {
        doSearch(e);
      }
    });
    $('#search-button').on('click', doSearch);

    if (!Circle.events) {
      // create the collections of models
      Circle.events = new Circle.EventList();
    }

    Circle.eventSlideshow = new Circle.EventSlideshowSlideView({
      el: '#slides',
      model: Circle.events
    });

    // setup our fancy city selector
    $('.city-picker').text(Circle.currentLocation);
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

    var performSearch = function (e) {
      var query = $('#search-field').val();
      Circle.app.navigate('events/' + query, {
        trigger: true
      });
    };

    $('#search-button').on('click', performSearch);
    $('#search-field').on('keyup', function(e) {
      if (e.which == 13) performSearch();
    });


    // put the query into the search field
    $('#search-field').val(query ? query : '');

    // handle window resizing
    function resizeMap () {
      $('.map-wrapper').width($('#map-area').width());
    };
    resizeMap();
    $(window).resize(resizeMap);

    var parse_query;
    if (query) {
      parse_query = {
        '$or': []
      };
      _.each(query.split(/\s/), function (q) {
        _.each([
          {'name': {'$regex': q, '$options': 'im'}},
          {'details': {'$regex': q, '$options': 'im'}},
          {'venueName': {'$regex': q, '$options': 'im'}},
          {'category': {
            '$inQuery': {
              'where' : {
                'name': {'$regex': q, '$options': 'im'}
              },
              'className': 'Category'
            }
          }}], function (t) {
            parse_query['$or'].push(t);
          });
      });
    }


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

    $('#event-sort').change(function () {
      Circle.sortBy = $(this).val();
      Circle.events.sort();
    });
  },

  detail: function (event_id) {
    $(window).off('location:change');

    var event = Circle.events ? Circle.events.get(event_id) : null;

    // if our location changes set the markers
    $(window).one('location:change', function (e) {
      Circle.setMapCenter(Circle.position);
      Circle.setMapPinsWithData([event], true);

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

      if (Circle.me) {
        $('#attending').removeClass('hidden');
        var $yesButton = $('#attending-yes-button'),
        $noButton = $('#attending-no-button');

        function attendingYesClick (e) {
          $this = $(this);
          $noButton.removeClass('btn-danger');
          $.ajax('https://api.parse.com/1/classes/Rsvp', {
            type: 'POST',
            headers: PARSE_HEADERS,
            contentType: 'application/json',
            data: JSON.stringify({
              event: {
                '__type': 'Pointer',
                'className': 'Event',
                'objectId': event.id
              },
              user: {
                '__type': 'Pointer',
                'className': '_User',
                'objectId': Circle.me.id
              },
              eventStartDate: {
                '__type': 'Date',
                'iso': event.get('startDate').iso
              }
            }),
            success: function (response, status) {
              Circle.me.set('RsvpId', response.objectId);
              attendees.add(Circle.me)
            },
            error: function (response, status) {
              $this.removeClass('active');
            }
          });
        }
        function attendingNoClick (e) {
          $this = $(this);
          $yesButton.removeClass('btn-success');
          $.ajax('https://api.parse.com/1/classes/Rsvp/' +
                 Circle.me.get('RsvpId'), {
                   type: 'DELETE',
                   headers: PARSE_HEADERS,
                   success: function (response, status) {
                     Circle.me.unset('RsvpId');
                     attendees.remove(Circle.me);
                   },
                   error: function (response, status) {
                     $this.removeClass('active');
                   }
                 });
        }

        var attendees = new Circle.AttendeeList();
        var attendeeView = new Circle.AttendeeListView({
          el: '#attendees tbody',
          model: attendees
        });
        attendees.on('add attending', function (model, collection, options) {
          if (Circle.me && Circle.me.id == model.id) {
            $yesButton.addClass('btn-success active').off('click');
            $noButton.on('click', attendingNoClick);
          }
        });
        attendees.on('remove attending:no', function (model,
                                                      collection,
                                                      optoins) {
          if (Circle.me && model.id && Circle.me.id == model.id) {
            $noButton.addClass('btn-danger active').off('click');
            $yesButton.on('click', attendingYesClick);
          }
        });
        attendees.fetch({
          data: 'include=user&where=' + JSON.stringify({
            event: {
              '__type': 'Pointer',
              'className': 'Event',
              'objectId': event.id
            }
          })
        });
      }

      if (Circle.position) {
        Circle.setMapCenter(Circle.position);
        Circle.setMapPinsWithData([event], true);
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


    var ksd = new Kalendae.Input('startDate', {
      subscribe: {
        'change': function () {
          createEventView.startDateChanged(this.getSelected());
        }
      },
      direction: 'today-future'
    });
    var kst = $('#startTime').timePicker({
      show24Hours: false,
      step: 30
    }).change(function () {
      createEventView.startTimeChanged();
    });

    // set the start date to a reasonable default
    var now = moment();
    $('#startDate').val(now.format('MM/DD/YYYY'));

    // fix the minutes so that the time is of the form 6:00 pm or 6:30
    // pm only.
    var minutesToNextHour = 60 - now.minutes();
    if (minutesToNextHour < 30) {
      now.minutes(0);
      now.add('hours', 1);
    } else {
      now.minutes(30);
    }
    kst.val(now.format('h:mm a'));

    var ked = new Kalendae.Input('endDate', {
      subscribe: {
        'change': function () {
          createEventView.endDateChanged();
        }
      },
      direction: 'today-future',
      blackout: function (date) {
        var startDate = null;
        try {
          startDate = moment($('#startDate').val() +
                           ' ' +
                           $('#startTime').val(),
                           'MM/DD/YYYY h:mm a');
        } catch (e) {
          startDate = moment();
        }
        return (date.diff(startDate) < 0);
      }
    });
    $('#endTime').timePicker({
      show24Hours: false,
      step: 30
    }).change(function () {
      createEventView.endTimeChanged();
    });

    Circle.getPositionFromBrowser();
  },

  signUp: function () {
    $('#sign-up-modal').modal('show');
    $('#sign-up-modal').on('hidden', function () {
      Circle.app.navigate('', {
        // if there isn't a layout loaded then trigger the route, so
        // that we load a layout
        trigger: ($('#layout.container').html().trim() == '')
      });
    });

    var newUser = new Circle.User();
    var signUpView = new Circle.SignUpView({
      model: newUser,
      el: '#sign-up-modal'
    }).render();
  },

  logout: function () {
    $('#account').html(t('not-logged-in')());
    Circle.setupLoginAndSignup();
    Circle.me && Circle.me.logout()
    Circle.app.navigate('', { trigger: true });
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

  Circle.restoreSession();
});
