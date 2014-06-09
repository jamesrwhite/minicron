'use strict';

(function() {
  Minicron.Alert = DS.Model.extend({
    kind: DS.attr('string'),
    medium: DS.attr('string'),
    expected_at: DS.attr('date'),
    sent_at: DS.attr('date'),

    isFail: function() {
      return this.get('kind') === 'fail';
    }.property('kind'),
    isMiss: function() {
      return this.get('kind') === 'miss';
    }.property('kind'),

    job: DS.belongsTo('job', { async: true }),
    execution: DS.belongsTo('execution', { async: true }),
    schedule: DS.belongsTo('schedule', { async: true })
  });
})();
