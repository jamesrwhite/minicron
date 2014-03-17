Minicron.JobSchedule = DS.Model.extend({
  schedule: DS.attr('string'),

  job: DS.belongsTo('job')
});