'use strict';

(function() {
  function deleteHost(self, host) {
    var confirmation = "Are you sure want to delete this host?\n\n";
        confirmation += 'All associated data i.e jobs on this host and the jobs in this hosts crontab will be REMOVED!';

    if (window.confirm(confirmation)) {
      host.deleteRecord();

      host.save().then(function() {
        // This is needed to reload all the relationships correctly after a delete
        // TODO: do this in a nicer way
        window.location.hash = '/hosts';
        window.location.reload();
      }, function(response) {
        host.rollback();
        console.log(response);
        window.prompt('Error deleting host, reason:', response.responseJSON.error);
      });
    }
  }

  function testConnection(self, host) {
    self.set('test_connection', 'Testing..');
    var path_prefix = window.config.path === '/' ? '' : window.config.path;

    jQuery.getJSON(path_prefix + '/api/hosts/' + host.id + '/test_ssh').done(function(data) {
      // Could we at least connect to the host?
      if (data.connect) {
        // TODO: make this use a bootstrap model as a component
        var results = 'Test Results\n\n';
            results += 'connect:                     ' + data.connect + '\n';
            results += '/etc writeable:           ' + data.etc.write + '\n';
            results += '/etc executable:         ' + data.etc.execute + '\n';
            results += 'crontab readable:       ' + data.crontab.read + '\n';
            results += 'crontab writeable:      ' + data.crontab.write;

        window.alert(results);
      } else {
        window.prompt('Failed to connect to host, reason:', data.responseJSON.error);
      }
    // If the actual ajax request failed
    }).fail(function(xhr, status, error) {
      console.log(xhr, status, error);
      window.prompt('Failed to connect to API, reason:', xhr.responseJSON.error);
    }).always(function() {
      self.set('test_connection', 'Test Connection');
    });
  }

  Minicron.HostsIndexController = Ember.ObjectController.extend({
    actions: {
      delete: function(host) {
        deleteHost(this, host);
      }
    }
  });

  Minicron.HostIndexController = Ember.ObjectController.extend({
    test_connection: 'Test Connection',
    actions: {
      delete: function(host) {
        deleteHost(this, host);
      },
      test: function(host) {
        testConnection(this, host);
      }
    }
  });

  Minicron.HostsNewController = Ember.Controller.extend({
    actions: {
      save: function() {
        var self = this,
                   host = this.store.createRecord('host', {
                     name: this.get('name'),
                     fqdn: this.get('fqdn'),
                     user: this.get('user'),
                     host: this.get('host'),
                     port: this.get('port'),
                     public_key: this.get('public_key')
                   });

        host.save().then(function(host) {
          self.transitionToRoute('host', host);
        // TODO: better error handling here
        }).catch(function(host) {
          window.alert('Error saving host!');
          console.log(host);
        });
      },
      cancel: function(host) {
        this.transitionToRoute('hosts');
      }
    }
  });

  Minicron.HostEditController = Ember.ObjectController.extend({
    test_connection: 'Test Connection',
    actions: {
      save: function() {
        var self = this,
            host = this.store.push('host', {
                     id: this.get('id'),
                     name: this.get('name'),
                     fqdn: this.get('fqdn'),
                     user: this.get('user'),
                     host: this.get('host'),
                     port: this.get('port'),
                     public_key: this.get('public_key')
                   });

        host.save().then(function(host) {
          self.transitionToRoute('host', host);
        // TODO: better error handling here
        }).catch(function(host) {
          window.alert('Error saving host!');
          console.log(host);
        });
      },
      delete: function(host) {
        deleteHost(this, host);
      },
      test: function(host) {
        testConnection(this, host);
      },
      cancel: function(host) {
        host.rollback();
        this.transitionToRoute('host', host);
      }
    }
  });
})();
