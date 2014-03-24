'use strict';

(function() {
  Minicron.SchedulesNewRoute = Ember.Route.extend({
    model: function() {
      return this.modelFor('job');
    },
    setupController: function(controller, model) {
      controller.set('model', model);
    },
    afterModel: Minicron.onViewLoad
  });

  Minicron.ScheduleRoute = Ember.Route.extend({
    model: function(params) {
      return this.store.find('schedule', params.schedule_id);
    }
  });

  Minicron.ScheduleIndexRoute = Ember.Route.extend({
    model: function() {
      return this.modelFor('schedule');
    },
    afterModel: Minicron.onViewLoad
  });


  Minicron.ScheduleEditRoute = Ember.Route.extend({
    model: function() {
      return this.modelFor('schedule');
    },
    setupController: function(controller, model) {
      controller.set('model', model);
    },
    afterModel: Minicron.onViewLoad
  });
})();
