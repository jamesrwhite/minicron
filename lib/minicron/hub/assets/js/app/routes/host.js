Minicron.HostRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('host', params.id);
  },
  afterModel: Minicron.onViewLoad
});