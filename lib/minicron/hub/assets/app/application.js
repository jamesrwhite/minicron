'use strict';

(function() {
  window.Minicron = Ember.Application.create({
    LOG_TRANSITIONS: true,
    LOG_ACTIVE_GENERATION: true,
    LOG_VIEW_LOOKUPS: true,
    LOG_TRANSITIONS_INTERNAL: true
  });

  // This should be called by all views when they are loaded
  Minicron.onViewLoad = function() {
    // Twitter tooltip plugin
    Ember.$('body').tooltip({
      selector: '[data-toggle=tooltip]'
    });

    // We'll keep on waiting, waiting, waiting on the DOM to change..
    var waitUntilReady = setInterval(function() {
      var $sidebar = Ember.$('.sidebar'),
          $main_panel = Ember.$('.main-panel');

      if ($sidebar.length && $main_panel.length) {
        // Sidebar perfect scrollbar init
        $sidebar.perfectScrollbar();

        // Main Panel perfect scrollbar init
        $main_panel.perfectScrollbar();
        $main_panel.scrollTop(0);
        $main_panel.perfectScrollbar('update');

        // Stop waiting on the DOM to change
        clearInterval(waitUntilReady);
      }
    }, 100);
  };

  // Configure Ember Data so it can find the API
  Minicron.ApplicationAdapter = DS.RESTAdapter.extend({
    namespace: 'api',
  });

  Minicron.ApplicationController = Ember.ArrayController.extend({
    sortedExecutions: function() {
      return this.get('content').toArray().sort(function(a, b) {
        a = +moment(a.get('created_at'));
        b = +moment(b.get('created_at'));

        if (a > b) {
           return -1;
        } else if (a < b) {
          return 1;
        }

        return 0;
      });
    }.property('content.@each').cacheable()
  });

  Minicron.ApplicationRoute = Ember.Route.extend({
    actions: {
      error: function(error) {
        console.log(error);

        // Create a new error to be passed as the controller
        var ember_error = new Ember.Error();

        // Set the details of the error we need
        ember_error.name = 'Error';
        ember_error.message = error.responseJSON.error;
        ember_error.number = error.status;

        this.render('fatal-error', {
          controller: ember_error
        });
      }
    },
    model: function() {
      return this.store.find('execution');
    },
    setupController: function(controller, model) {
      controller.set('application', model);
      this._super(controller, model);
    },
    afterModel: function(model, transition) {
      var client = new Faye.Client(window.location.protocol + '//' + window.location.host + '/faye'),
          store = model.store,
          self = this;
          window.store = store;

      client.addExtension({
        incoming: function(message, callback) {
          // We only care about job messages
          if (message.channel.substr(1, 3) === 'job') {
            var segments = message.channel.split('/');
            var job_id = segments[2];
            var execution_id = segments[3];
            var type = segments[4];
            var message_data = message.data.message;

            // TODO: remove this!
            console.log(job_id, execution_id, type, message);

            // Is it a status message?
            if (type === 'status') {
              // Is it a setup message
              if (typeof message_data.action != 'undefined' && message_data.action === 'SETUP') {
                // The SETUP message is defined slightly differently, segment 2 contains the
                // job hash and segment 3 contains '*job_id*-*execution_id*-*execution_number*'
                var ids = execution_id.split('-');
                    job_id = ids[0];
                    execution_id = ids[1];
                var execution_number = ids[2];

                // Append the job relationship to it
                store.find('job', job_id).then(function(job) {
                  // Create the execution
                  store.push('execution', {
                    id: execution_id,
                    number: execution_number,
                    created_at: moment.utc(message.data.ts).format('YYYY-MM-DDTHH:mm:ss[Z]'),
                    job: job
                  }, true);
                });
              // Is it a start message?
              } else if (message_data.substr(0, 5) === 'START') {
                // Set the execution start time
                store.find('execution', execution_id).then(function(execution) {
                  execution.set('started_at', moment.utc(message_data.substr(6)).format('YYYY-MM-DDTHH:mm:ss[Z]'));
                });
              // Is it a finish message?
              } else if (message_data.substr(0, 6) === 'FINISH') {
                // Set the execution finish time
                store.find('execution', execution_id).then(function(execution) {
                  execution.set('finished_at', moment.utc(message_data.substr(7)).format('YYYY-MM-DDTHH:mm:ss[Z]'));
                });
              // Is it an exit message?
              } else if (message_data.substr(0, 4) === 'EXIT') {
                // Set the execution exit status
                store.find('execution', execution_id).then(function(execution) {
                  execution.set('exit_status', +message_data.substr(5));
                });
              }
            // Is it an output message?
            } else if (type === 'output') {
              store.find('execution', execution_id).then(function(execution) {
                // Add this bit of job execution output
                var output = store.createRecord('job_execution_output', {
                    id: message.data.job_execution_output_id,
                    output: message_data,
                    seq: message.data.seq,
                    timestamp: moment(message.data.ts).format()
                });

                output.set('execution', execution);

                execution.get('job_execution_outputs').then(function(outputs) {
                  outputs.pushObject(output);
                });
              });
            }
          }

          // We're done with the message, pass it back to Faye
          callback(message);
        }
      });

      client.subscribe('/job/**');
    }
  });
})();
