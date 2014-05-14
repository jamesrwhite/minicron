'use strict';

(function() {
  Minicron.HostsRoute = Ember.Route.extend({
    model: function() {
      return this.store.find('host');
    },
    afterModel: Minicron.onViewLoad
  });

  Minicron.HostsIndexRoute = Ember.Route.extend({
    model: function() {
      return this.store.all('host');
    },
    setupController: function(controller, model) {
      controller.set('model', model);
    },
    afterModel: Minicron.onViewLoad
  });

  Minicron.HostRoute = Ember.Route.extend({
    model: function(params) {
      return this.store.find('host', params.id);
    }
  });

  Minicron.HostIndexRoute = Ember.Route.extend({
    model: function() {
      return this.modelFor('host');
    },
    afterModel: Minicron.onViewLoad
  });

  Minicron.HostEditRoute = Ember.Route.extend({
    model: function() {
      return this.modelFor('host');
    },
    setupController: function(controller, model) {
      controller.set('model', model);
    },
    afterModel: Minicron.onViewLoad
  });
})();
