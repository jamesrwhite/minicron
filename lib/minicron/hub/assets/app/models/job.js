'use strict';

(function() {
  Minicron.Job = DS.Model.extend({
    job_hash: DS.attr('string'),
    name: DS.attr('string'),
    user: DS.attr('string'),
    command: DS.attr('string'),
    created_at: DS.attr('date'),
    updated_at: DS.attr('date'),

    host: DS.belongsTo('host'),
    executions: DS.hasMany('execution', { async: true }),
    schedules: DS.hasMany('schedule', { async: true })
  });
})();
