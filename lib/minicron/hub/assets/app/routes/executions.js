'use strict';

(function() {
  Minicron.ExecutionsRoute = Ember.Route.extend({
    model: function() {
      return this.store.all('execution');
    },
    afterModel: Minicron.onViewLoad
  });

  Minicron.ExecutionsIndexRoute = Ember.Route.extend({
    model: function() {
      return this.store.all('execution');
    },
    afterModel: function(executions) {
      if (typeof executions.objectAt(0) != 'undefined') {
        this.transitionTo('execution', executions.objectAt(0));
      } else {
        Minicron.onViewLoad();
      }
    }
  });

  Minicron.ExecutionRoute = Ember.Route.extend({
    model: function(params) {
      return this.store.find('execution', params.id);
    },
    afterModel: Minicron.onViewLoad
  });

  Minicron.ExecutionIndexRoute = Ember.Route.extend({
    model: function() {
      return this.modelFor('execution');
    },
    setupController: function(controller, model) {
      controller.set('model', model);
    },
    afterModel: Minicron.onViewLoad
  });
})();
