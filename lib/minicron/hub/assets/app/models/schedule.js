'use strict';

(function() {
  Minicron.Schedule = DS.Model.extend({
    minute: DS.attr('string', { defaultValue: '*' }),
    hour: DS.attr('string', { defaultValue: '*' }),
    day_of_the_month: DS.attr('string', { defaultValue: '*' }),
    month: DS.attr('string', { defaultValue: '*' }),
    day_of_the_week: DS.attr('string', { defaultValue: '*' }),
    special: DS.attr('string', { defaultValue: null }),
    // Replicate the server side helper to format the schedule
    // so that it can be kept up to date on the frontend when
    // changes are made
    formatted: function() {
      if (this.get('special') === null) {
        var formatted =  this.get('minute') + ' ';
            formatted += this.get('hour') + ' ';
            formatted += this.get('day_of_the_month') + ' ';
            formatted += this.get('month') + ' ';
            formatted += this.get('day_of_the_week');

        return formatted;
      } else {
        return this.get('special');
      }
    }.property('minute', 'hour', 'day_of_the_month', 'month', 'day_of_the_week', 'special'),
    created_at: DS.attr('date'),
    updated_at: DS.attr('date'),

    job: DS.belongsTo('job')
  });
})();
