Minicron.JobExecutionOutput = DS.Model.extend({
  output: DS.attr('string'),
  timestamp: DS.attr('date'),

  execution: DS.belongsTo('execution')
});