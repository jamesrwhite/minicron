Minicron.Job = DS.Model.extend({
  name: DS.attr('string'),
  command: DS.attr('string'),
  created_at: DS.attr('date'),

  host: DS.belongsTo('host'),
  executions: DS.hasMany('execution')
});