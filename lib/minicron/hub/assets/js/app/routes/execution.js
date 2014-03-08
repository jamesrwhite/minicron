Minicron.ExecutionRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('execution', params.id);
  },
  afterModel: Minicron.onViewLoad
});