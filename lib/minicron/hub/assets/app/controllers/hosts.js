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
      alert('Error deleting host!');
      console.log(host);
    });
  }
}

Minicron.HostsIndexController = Ember.ObjectController.extend({
  actions: {
    delete: function(host) {
      deleteHost(this, host);
    }
  }
});

Minicron.HostIndexController = Ember.ObjectController.extend({
  actions: {
    delete: function(host) {
      deleteHost(this, host);
    }
  }
});

Minicron.HostsNewController = Ember.Controller.extend({
  actions: {
    save: function() {
      var self = this,
                 host = this.store.createRecord('host', {
                   name: this.get('name'),
                   hostname: this.get('hostname')
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
  actions: {
    save: function() {
      var self = this,
          host = this.store.push('host', {
                   id: this.get('id'),
                   name: this.get('name'),
                   hostname: this.get('hostname')
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
    }
  }
});