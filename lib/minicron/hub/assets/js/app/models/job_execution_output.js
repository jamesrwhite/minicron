Minicron.JobExecutionOutput = DS.Model.extend({
  execution_id: DS.attr('number'),
  job_id: DS.attr('string'),
  output: DS.attr('string'),
  timestamp: DS.attr('date'),

  execution: DS.belongsTo('execution', { embedded: 'always' }),
  job: DS.belongsTo('job', { embedded: 'always' })
});