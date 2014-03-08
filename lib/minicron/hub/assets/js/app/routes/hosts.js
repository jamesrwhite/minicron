Minicron.HostsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('host');
  }
});

Minicron.HostsIndexRoute = Ember.Route.extend({
  model: function() {
    return this.store.all('host');
  }
});

Minicron.HostRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('host', params.id);
  },
  afterModel: Minicron.onViewLoad
});