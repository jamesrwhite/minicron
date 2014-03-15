Minicron.JobsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('job');
  }
});

Minicron.JobsIndexRoute = Ember.Route.extend({
  model: function() {
    return this.store.all('job');
  },
  setupController: function(controller, model) {
    controller.set('model', model);
  },
  afterModel: Minicron.onViewLoad
});

Minicron.JobRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('job', params.id);
  },
  afterModel: Minicron.onViewLoad
});

Minicron.JobIndexRoute = Ember.Route.extend({
  model: function() {
    return this.modelFor('job');
  }
});

Minicron.JobEditRoute = Ember.Route.extend({
  model: function() {
    return this.modelFor('job');
  },
  setupController: function(controller, model) {
    controller.set('model', model);
  },
  afterModel: Minicron.onViewLoad
});