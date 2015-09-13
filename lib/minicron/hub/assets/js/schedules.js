'use strict';

(function() {
  var Schedule = {
    minute: '*',
    hour: '*',
    day_of_the_month: '*',
    month: '*',
    day_of_the_week: '*',
    special: null,

    _initialised: false,
    _view_only: false,

    /**
     * Initialise the schedule
     * @param {String} schedule
     */
    init: function() {
      this._initialised = true;

      // Get a reference to the form
      var $form = $('#schedule-editor').parent('form');

      // Are we in view only mode?
      this._view_only = $form.data('view-only') === '';

      // Grab the schedule from the input box
      var schedule = $('#schedule-input').find('input').val();

      // Parse and set the schedule
      if (schedule) {
        // Parse the schedule into a nice structured object
        var parsed_schedule = this.parse(schedule);

        // Update each of the schedules parts based on the parsed schedule
        this.minute = parsed_schedule.minute.value;
        this.hour = parsed_schedule.hour.value;
        this.day_of_the_month = parsed_schedule.day_of_the_month.value;
        this.month = parsed_schedule.month.value;
        this.day_of_the_week = parsed_schedule.day_of_the_week.value;
        this.special = parsed_schedule.special.value;

        // Update the GUI
        this._updateGui(parsed_schedule);
      }

      // Watch for updates
      this._watch();
    },

    /**
     * Return the formatted cron schedule
     * @return {String}
     */
    formatted: function() {
      this._checkInit();

      if (this.special !== null) {
        return this.special;
      }

      var schedule =  this.minute + ' ';
          schedule += this.hour + ' ';
          schedule += this.day_of_the_month + ' ';
          schedule += this.month + ' ';
          schedule += this.day_of_the_week;

      return schedule;
    },

    /**
     * Return the structured cron schedule
     * @return {String}
     */
    structured: function() {
      this._checkInit();

      return {
        minute: this.minute,
        hour: this.hour,
        day_of_the_month: this.day_of_the_month,
        month: this.month,
        day_of_the_week: this.day_of_the_week,
        special: this.special,
      };
    },

    /**
     * Parse a cron expression into an object
     * @param {String} schedule
     */
    parse: function(schedule) {
      // Set up the cron object
      var parsed_schedule = {
        type: null,
        minute: {
          value: null,
          type: null
        },
        hour: {
          value: null,
          type: null
        },
        day_of_the_month: {
          value: null,
          type: null
        },
        month: {
          value: null,
          type: null
        },
        day_of_the_week: {
          value: null,
          type: null
        },
        special: {
          value: null
        }
      };

      // Is it a special cron or not?
      if (schedule.substr(0, 1) === '@') {
        parsed_schedule.type = 'special';
        parsed_schedule.special.value = schedule;
      // Otherwise it's a 'normal' expression
      } else {
        parsed_schedule.type = 'normal';

        // Split the schedule into its 5 parts based on whitespace
        var expression = schedule.split(' ');

        // It should be an array of length 5..
        if (expression.length !== 5) {
          throw 'Expression "' + schedule + '" is not valid, expected to contain 5 parts';
        }

        // Map of indexes to expression parts
        var map = {
          0: 'minute',
          1: 'hour',
          2: 'day_of_the_month',
          3: 'month',
          4: 'day_of_the_week'
        };

        // Loop every value in the expression
        for (var i = 0; i < expression.length; i++) {
          // What part of the expression is it?
          var part = map[i];

          // Get the value of this part of the expression
          var value = expression[i];

          // Set the value of this partof the expression
          parsed_schedule[part].value = value;

          // Is it an every minute/hour/day etc part?
          if (value === '*') {
            parsed_schedule[part].type = 'every';
          // If it's a */n expression
          } else if (value.substr(0, 2) === '*/' && this._isNumeric(value.substr(2))) {
            parsed_schedule[part].type = 'every-n';
          // If it's an each selected expression
          } else if (this._isNumeric(value)) {
            parsed_schedule[part].type = 'each';
          } else if (value.split(',').length > 1) {
            parsed_schedule[part].type = 'each-csv';
          } else if (value.split('-').length > 1) {
            parsed_schedule[part].type = 'each-range';
          } else {
            throw 'Unknown expression part "' + value + '" in expression "' + schedule + '"';
          }
        }
      }

      return parsed_schedule;
    },

    /**
     * Check that the schedule has been initialised
     */
    _checkInit: function() {
      if (!this._initialised) {
        throw 'Not initialised! You must call init() first.';
      }
    },

    /**
     * Watch for events we care about, such as tabs or labels being clicked
     */
    _watch: function() {
      this._checkInit();

      var self = this;

      // If we're in view only mode we want to disable clicking the inner nav tabs
      if (self._view_only) {
        $('#schedule-editor').find('.nav-tabs a').on('click', function(e) {
          e.preventDefault();
          return false;
        });
      }

      // Handle when one of the tabs or labels (checkboxes) is clicked
      $('#schedule-editor').find('a[data-toggle="tab"], .btn-group > label').on('click', function(e) {
        var $this = $(this);

        // Are we in view only mode?
        if (self._view_only) {
          e.preventDefault();

          // Is it a label (checkbox)? Then we want to stop the click event bubbling
          // up the DOM so the label doesn't get highlighted
          if ($this[0].nodeName === 'LABEL') {
            return false;
          }
        } else {
          // Only handle the update if it isn't a label (checkbox)
          if ($this[0].nodeName !== 'LABEL') {
            self._onUpdate($this);
          }
        }
      });

      // Handle when one of the 'every n x' is inputs is changed
      $('#schedule-editor').find('input[type="number"], input[type="checkbox"], input[type="radio"]').on('change', function(e) {
        if (self._view_only) {
          e.preventDefault();
          return false;
        } else {
          self._onUpdate($(this));
        }
      });
    },

    /**
     * Used to parse the schedule on view load and update the GUI with those values
     * @param {Object} parsed_schedule
     */
    _updateGui: function(parsed_schedule) {
      this._checkInit();

      if (parsed_schedule.type === 'special') {
        // TODO: support special schedules here
      } else {
        // Loop each part of the schedule
        Object.keys(parsed_schedule).forEach(function(key, i) {
          var value = parsed_schedule[key].value;
          var type = parsed_schedule[key].type;
          i--; // We need i to be zero indexed

          // Handle updating the GUI, TODO: this can probably be refactored into something more simple

          // If it's an every type part, i.e *, then we can just leave the editor in its default state
          if (type === 'every') {
            return;
          }

          // Select the panel for this expression
          var panel = $('#schedule-editor').find('.panel').eq(i);

          // If it's an every-n, i.e */n expression
          if (type === 'every-n') {
            // Show the correct tab
            panel.find('.nav li:eq(1) a').tab('show');

            // Set the value of the expression in the input box
            panel.find('.tab-content .active input[type="number"]').val(value.substr(2));
          // If it's an each selected or range, i.e 1,2,3 or 4-5 expression
          } else if (type === 'each' || type === 'each-csv' || type === 'each-range') {
            var value,
                range,
                selected = [],
                split_by_comma = value.split(',');

            // Show the correct tab
            panel.find('.nav li').last().find('a').tab('show');

            // If it's just a plain number add it to selected array and we're done
            if (type === 'each') {
              selected.push(value);
            // If it's a group of values then we need to split them up and handle them
            } else if (split_by_comma.length > 0) {
              for (var j = 0; j < split_by_comma.length; j++) {
                // If it was a range expresssion convert it to a csv format
                if (type === 'range') {
                  range = split_by_comma[j].split('-');

                  // Loop every value in the range and add it to the selected array
                  for (var pos = parseInt(range[0]); pos <= parseInt(range[1]); pos++) {
                    selected.push(pos.toString());
                  }
                // If it was just a normal csv expression
                } else {
                  selected.push(this._normaliseExpressionValue(split_by_comma[j]));
                }
              }
            }

            // Loop every value in the selected array and 'check' it
            panel.find('.tab-content .active input[type="checkbox"]').each(function(k, v) {
              // Get the 'value' of the checkbox
              var $this = $(this);
              value = $this.data('value');

              // Should it be checked?
              if (selected.indexOf(value.toString()) >= 0) {
                $this[0].checked = true;
                $this.closest('label').addClass('active');
              }
            });
          }
        });
      }

      // Update the hidden form inputs for the schedule
      var formatted_schedule = this.formatted();
      this._updateForm(this.formatted(), this.parse(formatted_schedule));
    },

    /**
     * Used to update the hidden form values
     * @param {String} formatted_schedule
     * @param {Object} parsed_schedule
     */
    _updateForm: function(formatted_schedule, parsed_schedule) {
      // Update the schedule input box
      $('#schedule-input').find('input').val(formatted_schedule);

      $hidden_container = $('#hidden-schedule-inputs');

      // Reset all the values first
      $hidden_container.find('input').val('');

      // Is it a special schedule?
      if (parsed_schedule.type === 'special') {
        $hidden_container.find('input[name="special"]').val(parsed_schedule.special.value);
      // Otherwise set all the individual parts of the schedules value
      } else {
        $hidden_container.find('input[name="minute"]').val(parsed_schedule.minute.value);
        $hidden_container.find('input[name="hour"]').val(parsed_schedule.hour.value);
        $hidden_container.find('input[name="day_of_the_month"]').val(parsed_schedule.day_of_the_month.value);
        $hidden_container.find('input[name="month"]').val(parsed_schedule.month.value);
        $hidden_container.find('input[name="day_of_the_week"]').val(parsed_schedule.day_of_the_week.value);
      }
    },

    /**
     * Called when updates are made to the cron GUI
     * @param  {Object} $this
     */
    _onUpdate: function($this) {
      this._checkInit();

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
        if ($this.attr('type') === 'checkbox' || $this.attr('type') === 'radio') {
          id = $this.closest('.tab-pane').attr('id');
        // If it's a every-n-value then strip off the -value
        } else if (id.substr(-6) === '-value') {
          id = id.substr(0, id.length - 6);
        }
      }

      // Define the types of schedules we are searching for
      var every_n = ['every-minute', 'every-hour', 'every-day-of-the-month', 'every-month', 'every-day-of-the-week'];
      var every_n_type = ['every-n-minutes', 'every-n-hours'];

      // Define the key/value vars used when the change to the schedule is set
      var key, value = '';

      // Is it a special schedule?
      if (id === 'special') {
        key = id;
        value = $this.data('value');
      // Is it an 'every n' i.e *
      } else if (every_n.indexOf(id) >= 0) {
        // Transform the id into a key for the schedule, replace - with _
        key = id.substr(6).split('-').join('_');
        value = '*';
      // Is it any 'every n type' i.e */n
      } else if (every_n_type.indexOf(id) >= 0) {
        // Transform the id into a key for the schedule, replace - with _ and strip the trailing s
        key = id.substr(8, (id.length - 1) - 8).split('-').join('_');

        // Set the value using the value of the input
        value = '*/' + $('#' + id + '-value').val();
      // Otherwise we can assume it's a each selected type
      } else {
        // Transform the id into a key for the schedule, removing the every-selected-
        // and replace- with _
        key = id.substr(14).split('-').join('_');

        // Loop every checkbox
        $('#' + id).find('input[type="checkbox"]').each(function(k, v) {
          // If the checkbox is checked add the value
          if (v.checked === true) {
            value += $(this).data('value') + ',';
          }
        });

        // If no value has been set i.e no checkboxes are ticked, default to *
        if (value.length === 0) {
          value = '*';
        // Otherwise we need to remove the trailing ,
        } else if (value.substr(-1) === ',') {
          value = value.substr(0, value.length - 1);
        }
      }

      console.log('setting', key, value);

      // Update the schedule part
      this[key] = value;

      console.log('schedule', this.structured());

      // Update the schedule input text box
      var formatted_schedule = this.formatted();
      this._updateForm(this.formatted(), this.parse(formatted_schedule));
    },

    /**
     * Normalise expression values, such as the string equivelants of months/days
     * @param  {String} value
     * @return {String}
     */
    _normaliseExpressionValue: function(value) {
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
        'sat': '6',
        '@annually': '@yearly'
      };

      // If it was found in the mappings object return it
      if (typeof mappings[value.toLowerCase()] !== 'undefined') {
        return mappings[value.toLowerCase()];
      }

      return value;
    },

    /**
     * Is a value numeric?
     * @param  {mixed} value
     * @return {Boolean}
     */
    _isNumeric: function(value) {
      return !isNaN(parseFloat(value)) && isFinite(value);
    }
  };

  // Add it to the Minicron global object
  window.Minicron.Schedule = Schedule;

  // Go!
  window.Minicron.Schedule.init();
})();
