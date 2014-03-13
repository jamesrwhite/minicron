Minicron.HostsCreateController = Ember.Controller.extend({
  actions: {
    create: function() {
      var self = this,
          host = this.store.createRecord('host', {
            name: this.get('name'),
            hostname: this.get('hostname')
          });

      host.save().then(function(host) {
        self.transitionTo('host', host);
      // TODO: better error handling here
      }).catch(function(host) {
        alert('Error saving host!');
        console.log(host);
      });
    }
  }
});