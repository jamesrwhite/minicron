'use strict';

(function() {
  Minicron.Router.map(function() {
    this.resource('executions', function() {
      this.resource('execution', { path: ':id' }, function() {
        this.route('edit');
      });
    });

    this.resource('jobs', function() {
      this.route('new');
      this.resource('job', { path: ':id' }, function() {
        this.route('edit');
        this.resource('schedules', function() {
          this.route('new');
          this.resource('schedule', { path: ':schedule_id' }, function() {
            this.route('edit');
          });
        });
      });
    });

    this.resource('hosts', function() {
      this.route('new');
      this.resource('host', { path: ':id' }, function() {
        this.route('edit');
      });
    });

    this.resource('alerts', function() {
      this.resource('alert', { path: ':id' }, function() {});
    });
  });
})();
