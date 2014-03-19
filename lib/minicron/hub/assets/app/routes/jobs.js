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
  }
});

Minicron.JobIndexRoute = Ember.Route.extend({
  model: function() {
    return this.modelFor('job');
  },
  afterModel: Minicron.onViewLoad
});

Minicron.JobsNewRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('host');
  },
  setupController: function(controller, model) {
    controller.set('model', model);
  },
  afterModel: Minicron.onViewLoad
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