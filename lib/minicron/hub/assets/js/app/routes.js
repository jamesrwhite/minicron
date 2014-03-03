// Router
Minicron.Router.map(function() {
  this.resource('executions', function() {
    this.resource('execution', { path: ':execution_id' });
  });

  this.resource('jobs', function() {
    this.resource('job', { path: ':job_id' });
  });

  this.resource('hosts', function() {
    this.resource('host', { path: ':host_id' });
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
    return $.getJSON('/api/executions.json');
  },
  afterModel: Minicron.onViewLoad
});

Minicron.ExecutionRoute = Ember.Route.extend({
  model: function(params) {
    return $.getJSON('/api/executions/' + params.execution_id + '.json');
  },
  afterModel: Minicron.onViewLoad
});

Minicron.JobsRoute = Ember.Route.extend({
  model: function() {
    return $.getJSON('/api/jobs.json');
  },
  afterModel: Minicron.onViewLoad
});

Minicron.JobRoute = Ember.Route.extend({
  model: function(params) {
    return $.getJSON('/api/jobs/' + params.job_id + '.json');
  },
  afterModel: Minicron.onViewLoad
});

Minicron.HostsRoute = Ember.Route.extend({
  model: function() {
    return $.getJSON('/api/hosts.json');
  },
  afterModel: Minicron.onViewLoad
});

Minicron.HostRoute = Ember.Route.extend({
  model: function(params) {
    return $.getJSON('/api/hosts/' + params.host_id + '.json');
  },
  afterModel: Minicron.onViewLoad
});