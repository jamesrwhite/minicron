'use strict';

(function() {
  function deleteExecution(self, execution) {
    var confirmation = "Are you sure want to delete this execution?";

    if (window.confirm(confirmation)) {
      execution.deleteRecord();

      execution.save().then(function() {
        // This is needed to reload all the relationships correctly after a delete
        // TODO: do this in a nicer way
        window.location.hash = '/executions';
        window.location.reload();
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
})();
