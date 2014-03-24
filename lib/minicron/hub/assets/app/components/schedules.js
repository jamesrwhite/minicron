'use strict';

(function() {
  Minicron.ScheduleEditorComponent = Ember.Component.extend({
    actions: {
      save: function() {
        this.sendAction('save', {
          job_id: this.get('job_id'),
          schedule_id: this.get('schedule_id'),
          schedule: this.get('schedule'),
        });
      }
    }
  });
})();
