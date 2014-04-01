'use strict';

(function() {
  function deleteJob(self, job) {
    var confirmation = "Are you sure want to delete this job?\n\n";
        confirmation += 'All associated data will be deleted and it will be REMOVED from the host!';

    if (window.confirm(confirmation)) {
      job.deleteRecord();

      job.save().then(function() {
        // This is needed to reload all the relationships correctly after a delete
        // TODO: do this in a nicer way
        window.location.hash = '/jobs';
        window.location.reload();
      }, function(response) {
        job.rollback();
        console.log(response);
        window.prompt('Error deleting job, reason:', response.responseJSON.error);
      });
    }
  }

  Minicron.JobsIndexController = Ember.ObjectController.extend({
    actions: {
      delete: function(job) {
        deleteJob(this, job);
      }
    }
  });

  Minicron.JobsNewController = Ember.ObjectController.extend({
    save_button: 'Save',
    job_name: null,
    job_command: null,
    actions: {
      save: function() {
        var self = this,
            job = this.store.createRecord('job', {
                    name: this.get('job_name'),
                    command: this.get('job_command'),
                  });
        // Let the user know the job is being saved
        this.set('save_button', 'Saving..');

        // Look up the host
        this.store.find('host', this.get('id')).then(function(host) {
          // Set the job relationship
          job.set('host', host);

          job.save().then(function(job) {
            // Reset the save button text
            self.set('save_button', 'Save');

            self.transitionToRoute('job', job);
          // TODO: better error handling here
          }).catch(function(job) {
            // Reset the save button text
            self.set('save_button', 'Save');

            window.alert('Error saving job!');
            console.log(job);
          });
        });
      },
      cancel: function() {
        this.transitionToRoute('jobs');
      }
    }
  });

  Minicron.JobIndexController = Ember.ObjectController.extend({
    actions: {
      delete: function(job) {
        deleteJob(this, job);
      },
      test: function(job) {
        testConnection(this, job);
      }
    }
  });

  Minicron.JobEditController = Ember.ObjectController.extend({
    actions: {
      save: function() {
        var self = this,
            job = this.store.push('job', {
                    id: this.get('id'),
                    name: this.get('name')
                  });

        job.save().then(function(job) {
          self.transitionToRoute('job', job);
        // TODO: better error handling here
        }).catch(function(job) {
          window.alert('Error saving job!');
          console.log(job);
        });
      },
      delete: function(job) {
        deleteJob(this, job);
      },
      cancel: function(job) {
        job.rollback();
        this.transitionToRoute('job', job);
      }
    }
  });
})();
