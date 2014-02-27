Minicron.Job = DS.Model.extend({
  job_id: DS.attr('string'),
  name: DS.attr('string'),
  command: DS.attr('string'),
  host: DS.attr('string'),
  created_at: DS.attr('string')
});