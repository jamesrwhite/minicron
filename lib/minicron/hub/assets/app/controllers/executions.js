function deleteExecution(self, execution) {
  var confirmation = "Are you sure want to delete this execution?";

  if (window.confirm(confirmation)) {
    // TODO: Do the same cascading delete that happens on the backend
    // i.e deleting this execution also deletes the job execution output
    execution.deleteRecord();

    execution.save().then(function() {
      self.transitionToRoute('executions');
    }, function(response) {
      execution.rollback();
      console.log(response);
      window.prompt('Error deleting execution, reason:', response.responseJSON.error);
    });
  }
}

Minicron.ExecutionIndexController = Ember.ObjectController.extend({
  actions: {
    delete: function(execution) {
      deleteExecution(this, execution);
    }
  },
  sortedOutput: (function() {
    return Ember.ArrayProxy.createWithMixins(Ember.SortableMixin, {
      sortProperties: ['seq'],
      content: this.get('content.job_execution_outputs')
    });
  }).property('content.job_execution_outputs')
});
