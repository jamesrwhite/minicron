Minicron.ExecutionsController = Ember.ArrayController.extend({
  sortProperties: ['created_at'],
  sortAscending: false
});

Minicron.ExecutionsRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('execution');
  },
  setupController: function(controller, model) {
    controller.set('executions', model);
    this._super(controller, model);
  },
  activate: function() {
    // TODO: Read config here
    var client = new Faye.Client('http://127.0.0.1:9292/faye'),
        self = this;
    console.log(self);
    // var store = self.currentModel.store;

    client.addExtension({
      incoming: function(message, callback) {
        // We only car about job messages
        if (message.channel.substr(1, 3) === 'job') {
          var segments = message.channel.split('/');
          var job_id = segments[2];
          var job_execution_id = segments[3];
          var type = segments[4];
          var message_data = message.data.message;

          console.log(job_id, job_execution_id, type, message);

          // Is it a status message?
          if (type === 'status') {
            // Is it a setup message
            if (typeof message_data.action != 'undefined' && message_data.action === 'SETUP') {
              // Create the execution
              execution = store.createRecord('execution', {
                id: job_execution_id,
                job_id: job_id,
                created_at: message.data.ts
              });

              // Append the job relationship to it
              store.find('job', job_id).then(function(job) {
                execution.set('job', job);
              });
            }
          }
        }

        // We're done with the message, pass it back to Faye
        callback(message);
      }
    });

    client.subscribe('/job/**');
  },
  deactivate: function() {
    console.log('deactivate');
  }
});