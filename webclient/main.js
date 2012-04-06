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

/* Setup the Circle namespace */
var Circle = {};

/* Models */
Circle.Event = Backbone.Model.extend({
  // this is where backbone will POST to when creating a new Event
  // entity.
  urlRoot: 'https://api.parse.com/1/classes/Event'
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
  tagName: 'li',

  initialize: function () {
    // since we're extending Backbone.View objects before the DOM is
    // ready we must set the view's template inside of initialize() so
    // that _.template is not called when we extend Backbone.View.
    this.template = _.template($('#item-template').html());
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

$(function () {
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

  // get the data from parse
  Circle.events.fetch();
});
