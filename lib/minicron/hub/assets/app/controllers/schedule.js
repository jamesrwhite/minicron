function deleteSchedule(self, schedule) {
  var confirmation = "Are you sure want to delete this schedule? It will be removed from the host crontab also!\n";

  if (window.confirm(confirmation)) {
    schedule.destroyRecord().then(function() {
      self.transitionToRoute('jobs');
    }).catch(function(schedule) {
      window.alert('Error deleting schedule!');
      console.log(schedule);
    });
  }
}

Minicron.SchedulesNewController = Ember.ObjectController.extend({
  actions: {
    save: function() {
      var self = this,
                 schedule = this.store.createRecord('schedule', {
                   schedule: this.get('schedule'),
                 });

      // Look up the job, this should already be in the cache
      this.store.find('job', this.get('id')).then(function(job) {
        // Set the job relationship
        schedule.set('job', job);

        schedule.save().then(function(schedule) {
          self.transitionToRoute('job', job);
        // TODO: better error handling here
        }).catch(function(schedule) {
          alert('Error saving schedule!');
          console.log(schedule);
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
    save: function() {
      var self = this,
          schedule = this.store.push('schedule', {
                       id: this.get('id'),
                       schedule: this.get('schedule'),
                     });
      // Look up the job, this should already be in the cache
      this.store.find('job', this.get('job')).then(function(job) {
        // Set the job relationship
        schedule.set('job', job);

        schedule.save().then(function(schedule) {
          self.transitionToRoute('schedule', schedule);
        // TODO: better error handling here
        }).catch(function(schedule) {
          alert('Error saving schedule!');
          console.log(schedule);
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
