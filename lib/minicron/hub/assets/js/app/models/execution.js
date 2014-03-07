Minicron.Execution = DS.Model.extend({
  job_id: DS.attr('string'),
  created_at: DS.attr('date'),
  started_at: DS.attr('date'),
  finished_at: DS.attr('date'),
  exit_status: DS.attr('number'),

  job: DS.belongsTo('job', { embedded: 'always' }),
  host: DS.belongsTo('host', { embedded: 'always' }),
  job_execution_outputs: DS.hasMany('job_execution_output', { embedded: 'always' })
});