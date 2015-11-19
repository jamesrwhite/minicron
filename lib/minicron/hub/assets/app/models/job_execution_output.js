'use strict';

(function() {
  Minicron.JobExecutionOutput = DS.Model.extend({
    output: DS.attr('string'),
    timestamp: DS.attr('date'),
    seq: DS.attr('number'),

    execution: DS.belongsTo('execution')
  });
})();
