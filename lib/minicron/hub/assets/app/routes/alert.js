'use strict';

(function() {
  Minicron.AlertsRoute = Ember.Route.extend({
    model: function() {
      return this.store.find('alert');
    },
    afterModel: Minicron.onViewLoad
  });

  Minicron.AlertsIndexRoute = Ember.Route.extend({
    model: function() {
      return this.store.all('alert');
    },
    afterModel: Minicron.onViewLoad
  });

  Minicron.AlertRoute = Ember.Route.extend({
    model: function(params) {
      return this.store.find('alert', params.id);
    },
    afterModel: Minicron.onViewLoad
  });

   Minicron.AlertIndexRoute = Ember.Route.extend({
    model: function() {
      return this.modelFor('alert');
    },
    afterModel: Minicron.onViewLoad
  });
})();
