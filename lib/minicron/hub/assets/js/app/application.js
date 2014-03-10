window.Minicron = Ember.Application.create({
  LOG_TRANSITIONS: true
});

// This should be called by all views when they are loaded
Minicron.onViewLoad = function() {
  // Twitter tooltip plugin
  Ember.$('body').tooltip({
    selector: '[data-toggle=tooltip]'
  });
};

// Configure Ember Data so it can find the API
Minicron.ApplicationAdapter = DS.ActiveModelAdapter.extend({
  namespace: 'api',
});

// Making Ember Data work with the activemodel generated JSON
// Taken from http://mozmonkey.com/2013/12/loading-json-with-embedded-records-into-ember-data-1-0-0-beta/ <3
Minicron.ApplicationSerializer = DS.RESTSerializer.extend({
  /**
   The current ID index of generated IDs
   @property
   @private
  */
  _generatedIds: 0,

  /**
   Sideload a JSON object to the payload

   @method sideloadItem
   @param {Object} payload   JSON object representing the payload
   @param {subclass of DS.Model} type   The DS.Model class of the item to be sideloaded
   @param {Object} item JSON object   representing the record to sideload to the payload
  */
  sideloadItem: function(payload, type, item){
    var sideloadKey = type.typeKey.pluralize(),     // The key for the sideload array
        sideloadArr = payload[sideloadKey] || [],   // The sideload array for this item
        primaryKey = Ember.get(this, 'primaryKey'), // the key to this record's ID
        id = item[primaryKey];

    // Missing an ID, generate one
    if (typeof id == 'undefined') {
      id = 'generated-'+ (++this._generatedIds);
       item[primaryKey] = id;
    }

    // Don't add if already side loaded
    if (sideloadArr.findBy('id', id) != undefined) {
        return payload;
    }

    // Add to sideloaded array
    sideloadArr.push(item);
    payload[sideloadKey] = sideloadArr;
    return payload;
  },

  /**
   Extract relationships from the payload and sideload them. This function recursively
   walks down the JSON tree

   @method sideloadItem
   @param {Object} payload   JSON object representing the payload
   @paraam {Object} recordJSON   JSON object representing the current record in the payload to look for relationships
   @param {Object} recordType   The DS.Model class of the record object
  */
  extractRelationships: function(payload, recordJSON, recordType) {
    // Loop through each relationship in this record type
    recordType.eachRelationship(function(key, relationship) {
        var related = recordJSON[key], // The record at this relationship
            type = relationship.type;  // belongsTo or hasMany

        if (related) {
            // One-to-one
            if (relationship.kind == 'belongsTo') {
              // Sideload the object to the payload
              this.sideloadItem(payload, type, related);

              // Replace object with ID
              recordJSON[key] = related.id;

              // Find relationships in this record
              this.extractRelationships(payload, related, type);
            }

            // Many
            else if (relationship.kind == 'hasMany') {
              // Loop through each object
              related.forEach(function(item, index){
                  // Sideload the object to the payload
                  this.sideloadItem(payload, type, item);

                  // Replace object with ID
                  related[index] = item.id;

                  // Find relationships in this record
                  this.extractRelationships(payload, item, type);
                }, this);
            }
        }
    }, this);

    return payload;
  },

  /**
   Overrided method
  */
  normalizePayload: function(type, payload) {
    var typeKey = type.typeKey,
        typeKeyPlural = typeKey.pluralize();

    // if (type === Minicron.Job) {
    //   payload.jobs = payload.jobs.map(function(job) {
    //     job.executions = job.executions.map(function(execution) {
    //       console.log(execution.job_id);
    //       delete execution.job_id;
    //       console.log(execution.job_id);

    //       return execution;
    //     });

    //     return job;
    //   });
    //   console.log(payload);
    // }

    payload = this._super(type, payload);

    // Many items (findMany, findAll)
    if (typeof payload[typeKeyPlural] != 'undefined') {
      payload[typeKeyPlural].forEach(function(item, index) {
        this.extractRelationships(payload, item, type);
      }, this);
    }

    // Single item (find)
    else if (typeof payload[typeKey] != 'undefined') {
      this.extractRelationships(payload, payload[typeKey], type);
    }

    return payload;
  },
});

Minicron.ApplicationController = Ember.ArrayController.extend({
  sorted: function() {
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
          var job_execution_id = segments[3];
          var type = segments[4];
          var message_data = message.data.message;

          // TODO: remove this!
          console.log(job_id, job_execution_id, type, message);

          // Is it a status message?
          if (type === 'status') {
            // Is it a setup message
            if (typeof message_data.action != 'undefined' && message_data.action === 'SETUP') {
              // Append the job relationship to it
              store.find('job', job_id).then(function(job) {
                // Create the execution
                execution = store.push('execution', {
                  id: job_execution_id,
                  created_at: moment(message.data.ts).format()
                });

                execution.set('job', job);
              });
            // Is it a start message?
            } else if (message_data.substr(0, 5) === 'START') {
              // Set the execution start time
              store.find('execution', job_execution_id).then(function(execution) {
                execution.set('started_at', moment(message_data.substr(6)).format());
              });
            // Is it a finish message?
            } else if (message_data.substr(0, 6) === 'FINISH') {
              // Set the execution finish time
              store.find('execution', job_execution_id).then(function(execution) {
                execution.set('finished_at', moment(message_data.substr(7)).format());
              });
            // Is it an exit message?
            } else if (message_data.substr(0, 4) === 'EXIT') {
              // Set the execution exit status
              store.find('execution', job_execution_id).then(function(execution) {
                execution.set('exit_status', +message_data.substr(5));
              });
            }
          // Is it an output message?
          } else if (type === 'output') {
            store.find('execution', job_execution_id).then(function(execution) {
              // Add this bit of job execution output
              output = store.push('job_execution_output', {
                // Generate a randomish number for the id as we don't know the real id
                id: (+new Date()) + (Math.random() * 16|0),
                execution_id: job_execution_id,
                output: message_data,
                timestamp: moment(message.data.ts).format()
              });

              output.set('execution', execution);
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
