'use strict';

(function() {
  Minicron.Execution = DS.Model.extend({
    number: DS.attr('number'),
    created_at: DS.attr('date'),
    started_at: DS.attr('date'),
    finished_at: DS.attr('date'),
    exit_status: DS.attr('number'),

    job: DS.belongsTo('job'),
    job_execution_outputs: DS.hasMany('job_execution_output', { async: true })
  });
})();
