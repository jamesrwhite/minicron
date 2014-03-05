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

Minicron.ExecutionsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('execution');
  },
  afterModel: Minicron.onViewLoad
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
  afterModel: Minicron.onViewLoad
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
  afterModel: Minicron.onViewLoad
});

Minicron.HostRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('host', params.id);
  },
  afterModel: Minicron.onViewLoad
});