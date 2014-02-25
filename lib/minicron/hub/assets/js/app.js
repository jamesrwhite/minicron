App = Ember.Application.create({});

App.Router.map(function() {
  this.resource('jobs', function() {
    this.resource('job', { path: ':job_id' });
  });
});

App.IndexRoute = Ember.Route.extend({
  redirect: function () {
    this.transitionTo('jobs');
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
