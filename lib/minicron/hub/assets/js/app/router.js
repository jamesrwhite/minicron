Minicron.Router.map(function() {
  this.resource('executions', function() {
    this.resource('execution', { path: ':id' });
  });

  this.resource('jobs', function() {
    this.resource('job', { path: ':id' });
  });

  this.resource('hosts', function() {
    this.resource('host', { path: ':id' });
  });
});