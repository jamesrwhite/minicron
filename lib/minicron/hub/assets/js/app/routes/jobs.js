Minicron.JobsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('job');
  }
});