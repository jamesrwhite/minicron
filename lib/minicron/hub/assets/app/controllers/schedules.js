'use strict';

(function() {
  function deleteSchedule(self, schedule) {
    var confirmation = "Are you sure want to delete this schedule? It will be removed from the host crontab also!\n";
    var job_id = schedule.get('job.id');

    schedule.deleteRecord();

    schedule.save().then(function() {
      // This is needed to reload all the relationships correctly after a delete
      // TODO: do this in a nicer way
      window.location.hash = '/jobs/' + job_id;
      window.location.reload();
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
          // Set the job relationship
          data.schedule.set('job', job);

          data.schedule.save().then(function(schedule) {
            self.transitionToRoute('job', job);
          // TODO: better error handling here
          }, function(response) {
            console.log(response);
            window.prompt('Error adding schedule, reason:', response.responseJSON.error);
          });
        });
      },
      cancel: function(job_id) {
        this.transitionToRoute('job', job_id);
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
          // Set the job relationship
          data.schedule.set('job', job);

          data.schedule.save().then(function(schedule) {
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
        schedule.rollback();
        this.transitionToRoute('schedule', schedule);
      }
    }
  });
})();
