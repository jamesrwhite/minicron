// Router
Minicron.Router.map(function() {
  this.resource('executions', function() {
    this.resource('execution', { path: ':execution_id' });
  });

  this.resource('jobs', function() {
    this.resource('job', { path: ':job_id' });
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
  }
});

Minicron.ExecutionRoute = Ember.Route.extend({
  model: function(params) {
    return $.getJSON('/api/executions/' + params.execution_id + '.json');
  }
});

Minicron.JobsRoute = Ember.Route.extend({
  model: function() {
    return $.getJSON('/api/jobs.json');
  }
});

Minicron.JobRoute = Ember.Route.extend({
  model: function(params) {
    return $.getJSON('/api/jobs/' + params.job_id + '.json');
  }
});