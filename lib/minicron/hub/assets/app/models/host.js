Minicron.Host = DS.Model.extend({
  name: DS.attr('string'),
  fqdn: DS.attr('string'),
  host: DS.attr('string'),
  port: DS.attr('number'),
  public_key: DS.attr('string'),
  created_at: DS.attr('date'),
  updated_at: DS.attr('date'),

  jobs: DS.hasMany('job')
});