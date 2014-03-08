Minicron.JobExecutionOutput = DS.Model.extend({
  execution_id: DS.attr('number'),
  output: DS.attr('string'),
  timestamp: DS.attr('date'),

  execution: DS.belongsTo('execution')
});