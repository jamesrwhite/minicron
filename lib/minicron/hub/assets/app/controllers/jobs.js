function deleteJob(self, job) {
  var confirmation = "Are you sure want to delete this job?\n";
      confirmation += 'All associated executions will also be deleted!';

  if (window.confirm(confirmation)) {
    // TODO: Do the same cascading delete that happens on the backend
    // i.e deleting jobs -> executions -> job_execution_outputs linked
    // to this job
    job.destroyRecord().then(function() {
      self.transitionToRoute('jobs');
    }).catch(function(job) {
      window.alert('Error deleting job!');
      console.log(job);
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
        alert('Error saving job!');
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