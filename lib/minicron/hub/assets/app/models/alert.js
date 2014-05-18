'use strict';

(function() {
  Minicron.Alert = DS.Model.extend({
    kind: DS.attr('string'),
    expected_at: DS.attr('date'),
    sent_at: DS.attr('date'),

    schedule: DS.belongsTo('schedule'),
    execution: DS.belongsTo('execution')
  });
})();
