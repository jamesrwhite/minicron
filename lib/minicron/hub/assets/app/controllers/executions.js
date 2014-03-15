function deleteExecution(self, execution) {
  var confirmation = "Are you sure want to delete this execution?";

  if (window.confirm(confirmation)) {
    // TODO: Do the same cascading delete that happens on the backend
    // i.e deleting this execution also deletes the job execution output
    execution.destroyRecord().then(function() {
      self.transitionToRoute('executions');
    }).catch(function(execution) {
      window.alert('Error deleting execution!');
      console.log(execution);
    });
  }
}

Minicron.ExecutionIndexController = Ember.ObjectController.extend({
  actions: {
    delete: function(execution) {
      deleteExecution(this, execution);
    }
  }
});