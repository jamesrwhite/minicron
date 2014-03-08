Minicron.Host = DS.Model.extend({
  hostname: DS.attr('string'),
  name: DS.attr('string'),
  created_at: DS.attr('date'),

  jobs: DS.hasMany('job')
});