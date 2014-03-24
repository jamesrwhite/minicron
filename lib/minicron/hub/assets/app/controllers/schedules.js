'use strict';

(function() {
  function deleteSchedule(self, schedule) {
    var confirmation = "Are you sure want to delete this schedule? It will be removed from the host crontab also!\n";
    var job_id = schedule.get('job.id');

    schedule.deleteRecord();

    schedule.save().then(function() {
      self.transitionToRoute('job', job_id);
    }, function(response) {
      schedule.rollback();
      console.log(response);
      window.prompt('Error deleting schedule, reason:', response.responseJSON.error);
    });
  }

  Minicron.SchedulesNewController = Ember.ObjectController.extend({
    actions: {
      save: function(data) {
        var self = this;

        // Look up the job, this should already be in the cache
        this.store.find('job', data.job_id).then(function(job) {
          var schedule = self.store.createRecord('schedule', {
            schedule: data.schedule,
          });

          // Set the job relationship
          schedule.set('job', job);

          schedule.save().then(function(schedule) {
            self.transitionToRoute('job', job);
          // TODO: better error handling here
          }, function(response) {
            console.log(response);
            window.prompt('Error adding schedule, reason:', response.responseJSON.error);
          });
        });
      },
      cancel: function(schedule) {
        this.transitionToRoute('job', schedule.get('id'));
      }
    }
  });

  Minicron.ScheduleIndexController = Ember.ObjectController.extend({
    actions: {
      delete: function(schedule) {
        deleteSchedule(this, schedule);
      }
    }
  });

  Minicron.ScheduleEditController = Ember.ObjectController.extend({
    actions: {
      save: function(data) {
        var self = this;

        // Look up the job, this should already be in the cache
        this.store.find('job', data.job_id).then(function(job) {
          var schedule = self.store.push('schedule', {
            id: data.schedule_id,
            schedule: data.schedule,
          });

          // Set the job relationship
          schedule.set('job', job);

          schedule.save().then(function(schedule) {
            self.transitionToRoute('schedule', schedule);
          // TODO: better error handling here
          }, function(response) {
            console.log(response);
            window.prompt('Error saving schedule, reason:', response.responseJSON.error);
          });
        });
      },
      delete: function(schedule) {
        deleteSchedule(this, schedule);
      },
      cancel: function(schedule) {
        // TODO: work out why this messes up the belogsTo job
        schedule.rollback();
        this.transitionToRoute('schedule', schedule);
      }
    }
  });
})();
