// Router
Minicron.Router.map(function() {
  this.resource('executions', function() {
    this.resource('execution', { path: ':id' });
  });

  this.resource('jobs', function() {
    this.resource('job', { path: ':id' });
  });

  this.resource('hosts', function() {
    this.resource('host', { path: ':id' });
  });
});

// Routes
Minicron.IndexRoute = Ember.Route.extend({
  redirect: function () {
    this.transitionTo('executions');
  }
});

Minicron.ExecutionsController = Ember.ArrayController.extend({
  sortProperties: ['created_at'],
  sortAscending: false
});

Minicron.ExecutionsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('execution');
  },
  setupController: function(controller, model) {
    controller.set('executions', model);
    this._super(controller, model);
  },
  afterModel: function(executions, transition) {
    // this.transitionTo('execution', executions.objectAt(0));
  }
});

Minicron.ExecutionRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('execution', params.id);
  },
  afterModel: Minicron.onViewLoad
});

Minicron.JobsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('job');
  },
  afterModel: function(jobs, transition) {
    // this.transitionTo('job', jobs.objectAt(0));
  }
});

Minicron.JobRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('job', params.id);
  },
  afterModel: Minicron.onViewLoad
});

Minicron.HostsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('host');
  },
  afterModel: function(hosts, transition) {
    // this.transitionTo('host', hosts.objectAt(0));
  }
});

Minicron.HostRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('host', params.id);
  },
  afterModel: Minicron.onViewLoad
});