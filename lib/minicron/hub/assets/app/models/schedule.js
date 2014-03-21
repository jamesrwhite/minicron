Minicron.Schedule = DS.Model.extend({
  schedule: DS.attr('string'),
  created_at: DS.attr('date'),
  updated_at: DS.attr('date'),

  job: DS.belongsTo('job', { async: true })
});
