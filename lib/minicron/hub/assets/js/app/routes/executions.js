Minicron.ExecutionsRoute = Ember.Route.extend({
  model: function() {
    return this.store.all('execution');
  }
});

Minicron.ExecutionsIndexRoute = Ember.Route.extend({
  model: function() {
    return this.store.all('execution');
  },
  afterModel: function(executions) {
    this.transitionTo('execution', executions.objectAt(0));
  }
});

Minicron.ExecutionRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('execution', params.id);
  },
  afterModel: Minicron.onViewLoad
});