'use strict';

(function() {
  // Taken from http://stackoverflow.com/a/1830844/483271
  function isNumeric(value) {
    return !isNaN(parseFloat(value)) && isFinite(value);
  }

  // Normalise expression values, such as the string equivelants of months/days
  function normaliseExpressionValue(value) {
    var mappings = {
      'jan': '1',
      'feb': '2',
      'mar': '3',
      'apr': '4',
      'may': '5',
      'jun': '6',
      'jul': '7',
      'aug': '8',
      'sep': '9',
      'oct': '10',
      'nov': '11',
      'dec': '12',
      'sun': '0',
      'mon': '1',
      'tue': '2',
      'wed': '3',
      'thu': '4',
      'fri': '5',
      'sat': '6'
    };

    // If it was found in the mappings object return it
    if (typeof mappings[value.toLowerCase()] !== 'undefined') {
      return mappings[value.toLowerCase()];
    }

    return value;
  }

  // Used to parse the schedule on view load and update the GUI with those values
  function parseSchedule(schedule) {
    // Split the schedule into its 5 parts based on whitespace
    var expression = schedule.split(' ');

    // Loop every value in the expression
    for (var i = 0; i < expression.length; i++) {
      // If the value is '*' we don't need to do anything
      if (expression[i] === '*') {
        continue;
      }

      // Select the panel for this expression
      var panel = Ember.$('#schedule-editor').find('.panel').eq(i);

      // If it's a */n expression
      if (expression[i].substr(0, 2) === '*/' && isNumeric(expression[i].substr(2))) {
        // Show the correct tab
        panel.find('.nav li:eq(1) a').tab('show');

        // Set the value of the expression in the input box
        panel.find('.tab-content .active input[type="number"]').val(expression[i].substr(2));
      }

      // If it's an each selected expression
      // TODO: support range expression e.g 10-15
      else if (isNumeric(expression[i]) || expression[i].split(',').length > 1 || expression[i].split('-').length > 1) {
        var value,
            range,
            selected = [],
            split_by_comma = expression[i].split(',');

        // Show the correct tab
        panel.find('.nav li').last().find('a').tab('show');

        // If it's just a plain number add it to selected array and we're done
        if (isNumeric(expression[i])) {
          selected.push(expression[i]);
        }

        // If it's a group of values then we need to split them up and handle them
        else if (split_by_comma.length > 0) {
          for (var j = 0; j < split_by_comma.length; j++) {
            // If it was a range expresssion convert it to a csv format
            if (split_by_comma[j].split('-').length > 1) {
              range = split_by_comma[j].split('-');

              // Loop every value in the range and add it to the selected array
              for (var pos = parseInt(range[0]); pos <= parseInt(range[1]); pos++) {
                selected.push(pos.toString());
              }
            // If it was just a normal csv expression
            } else {
              selected.push(normaliseExpressionValue(split_by_comma[j]));
            }
          }
        }

        // Loop every value in the selected array and 'check' it
        panel.find('.tab-content .active input[type="checkbox"]').each(function(k, v) {
          // Get the 'value' of the checkbox
          var $this = Ember.$(this);
          value = $this.data('value');

          // Should it be checked?
          if (selected.indexOf(value.toString()) >= 0) {
            $this[0].checked = true;
            $this.trigger('click');
          }
        });
      }
    }

    // Finally set the schedule in the schedule input textbox
    updateScheduleInput(schedule);
  }

  // Helper to set the value of the schedule input textbox when it has been updated
  function updateScheduleInput(value) {
    Ember.$('#schedule-input').find('input').val(value);
  }

  // Called when updates made to the cron GUI, this will update the schedule record
  function handleUpdate(self, e, $this) {
    // Get the schedule
    var schedule = self.get('schedule');

    // The 'id' of the event which we use to defer the type
    // it's either the href with the # stripped off if it's a
    // tab click or the actual id attribute of the element
    var id;

    // If the href exists we can assume it's a tab
    if (typeof $this.attr('href') !== 'undefined') {
      id = $this.attr('href').substr(1);
    } else {
      id = $this.attr('id');

      // If it's a checkbox set the id to it's parents parent
      if ($this.attr('type') === 'checkbox') {
        id = $this.closest('.tab-pane').attr('id');
      }

      // If it's a every-n-value then strip off the -value
      else if (id.substr(-6) === '-value') {
        id = id.substr(0, id.length - 6);
      }
    }

    // Define the types of schedules we are searching for
    var every_n = ['every-minute', 'every-hour', 'every-day-of-the-month', 'every-month', 'every-day-of-the-week'];
    var every_n_type = ['every-n-minutes', 'every-n-hours'];

    // Define the key/value vars used when the change to the schedule is set
    var key, value = '';

    // Is it an 'every n' i.e *
    if (every_n.indexOf(id) >= 0) {
      // Transform the id into a key for the schedule, replace - with _
      key = id.substr(6).split('-').join('_');
      value = '*';
    }

    // Is it any 'every n type' i.e */n
    else if (every_n_type.indexOf(id) >= 0) {
      // Transform the id into a key for the schedule, replace - with _ and strip the trailing s
      key = id.substr(8, (id.length - 1) - 8).split('-').join('_');

      // Set the value using the value of the input
      value = '*/' + Ember.$('#' + id + '-value').val();
    }

    // Otherwise we can assume it's a each selected type
    else {
      // Transform the id into a key for the schedule, removing the every-selected-
      // and replace- with _
      key = id.substr(14).split('-').join('_');

      // Loop every checkbox
      Ember.$('#' + id).find('input[type="checkbox"]').each(function(k, v) {
        // If the checkbox is checked add the value
        if (v.checked === true) {
          value += Ember.$(this).data('value') + ',';
        }
      });

      // If no value has been set i.e no checkboxes are ticked, default to *
      if (value.length === 0) {
        value = '*';
      // Otherwise we need to remove the trailing ,
      } else {
        if (value.substr(-1) === ',') {
          value = value.substr(0, value.length - 1);
        }
      }
    }

    // Update the schedule
    console.log('setting', key, value);
    schedule.set(key, value);

    // Update the schedule input text box
    updateScheduleInput(schedule.get('formatted'));
  }

  Minicron.ScheduleEditorComponent = Ember.Component.extend({
    didInsertElement: function() {
      this.store = this.get('targetObject.store');
      var self = this;

      // Do we already have the schedule id? i.e we are editing a schedule
      if (this.get('schedule_id')) {
        // Look up the schedule
        this.store.find('schedule', this.get('schedule_id')).then(function(schedule) {
          self.set('schedule', schedule);

          // Parse the schedule and display it in the GUI
          parseSchedule(self.get('schedule.formatted'));
        });
      // If not we must be adding a new schedule
      } else {
        // Create a default schedule record
        this.set('schedule', this.store.createRecord('schedule', {
          minute: '*',
          hour: '*',
          day_of_the_month: '*',
          month: '*',
          day_of_the_week: '*'
        }));

        // Parse the schedule and display it in the GUI
        parseSchedule(this.get('schedule.formatted'));
      }

      // Update our reference to 'this' so we can pass it to the update handlers
      self = this;

      // Handle when one of the tabs is clicked
      this.$('#schedule-editor').find('a[data-toggle="tab"]').on('click', function(e) {
        handleUpdate(self, e, Ember.$(this));
      });

      // Handle when one of the checkboxes for 'each selected x' or 'every n x' is changed
      this.$('#schedule-editor').find('input[type="checkbox"], input[type="number"]').on('change', function(e) {
        handleUpdate(self, e, Ember.$(this));
      });
    },
    actions: {
      save: function() {
        this.sendAction('save', {
          job_id: this.get('job_id'),
          schedule: this.get('schedule')
        });
      },
      cancel: function(schedule) {
        this.sendAction('cancel', schedule);
      }
    }
  });
})();
