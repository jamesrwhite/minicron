Ember.Handlebars.helper('ansi_to_html', function(value, options) {
  value = Handlebars.Utils.escapeExpression(value);
  value = ansi_up.ansi_to_html(value, { use_classes: true });

  return new Handlebars.SafeString(value);
});

App = Ember.Application.create();

App.Router.map(function() {
  this.resource('executions', function() {
    this.resource('execution', { path: ':execution_id' });
  });

  this.resource('jobs', function() {
    this.resource('job', { path: ':job_id' });
  });
});

App.IndexRoute = Ember.Route.extend({
  redirect: function () {
    this.transitionTo('executions');
  }
});

App.ExecutionsRoute = Ember.Route.extend({
  model: function() {
    return $.getJSON('/api/executions.json');
  }
});

App.ExecutionRoute = Ember.Route.extend({
  model: function(params) {
    return $.getJSON('/api/executions/' + params.execution_id + '.json');
  }
});

App.JobsRoute = Ember.Route.extend({
  model: function() {
    return $.getJSON('/api/jobs.json');
  }
});

App.JobRoute = Ember.Route.extend({
  model: function(params) {
    return $.getJSON('/api/jobs/' + params.job_id + '.json');
  }
});
