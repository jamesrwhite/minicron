Minicron.HostsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('host');
  }
});