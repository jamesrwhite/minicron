Minicron.IndexRoute = Ember.Route.extend({
  redirect: function () {
    this.transitionTo('executions');
  }
});