function deleteHost(self, host) {
  var confirmation = "Are you sure want to delete this host?\n";
      confirmation += 'All associated jobs and executions will also be deleted!';

  if (window.confirm(confirmation)) {
    // TODO: Do the same cascading delete that happens on the backend
    // i.e deleting jobs -> executions -> job_execution_outputs linked
    // to this host
    host.destroyRecord().then(function() {
      self.transitionToRoute('hosts');
    }).catch(function(host) {
      window.alert('Error deleting host!');
      console.log(host);
    });
  }
}

function testConnection(self, host) {
  self.set('test_connection', 'Testing..');

  jQuery.getJSON('/api/hosts/' + host.id + '/test_ssh').done(function(data) {
    if (data.success) {
      window.alert('Connected successfully to host!');
      console.log(data);
    } else {
      window.prompt('Failed to connect to host, reason:', data.error);
      console.log(data);
    }
  }).fail(function(xhr, status, error) {
    window.prompt('Failed to connect to API, reason:', error);
    console.log(xhr, status, error);
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
                   ip: this.get('ip'),
                   public_key: this.get('public_key')
                 });

      host.save().then(function(host) {
        self.transitionToRoute('host', host);
      // TODO: better error handling here
      }).catch(function(host) {
        alert('Error saving host!');
        console.log(host);
      });
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
                   ip: this.get('ip'),
                   public_key: this.get('public_key')
                 });

      host.save().then(function(host) {
        self.transitionToRoute('host', host);
      // TODO: better error handling here
      }).catch(function(host) {
        alert('Error saving host!');
        console.log(host);
      });
    },
    delete: function(host) {
      deleteHost(this, host);
    },
    test: function(host) {
      testConnection(this, host);
    }
  }
});