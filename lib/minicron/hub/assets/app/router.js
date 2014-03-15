Minicron.Router.map(function() {
  this.resource('executions', function() {
    this.resource('execution', { path: ':id' }, function() {});
  });

  this.resource('jobs', function() {
    this.resource('job', { path: ':id' }, function() {
      this.route('edit');
    });
  });

  this.resource('hosts', function() {
    this.route('new', { path: 'new' });
    this.resource('host', { path: ':id' }, function() {
      this.route('edit');
    });
  });
});