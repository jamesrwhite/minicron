Minicron.JobsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('job');
  }
});

Minicron.JobsIndexRoute = Ember.Route.extend({
  model: function() {
    return this.store.all('job');
  },
  afterModel: Minicron.onViewLoad
});

Minicron.JobRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('job', params.id);
  },
  afterModel: Minicron.onViewLoad
});