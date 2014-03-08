Minicron.JobRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('job', params.id);
  },
  afterModel: Minicron.onViewLoad
});