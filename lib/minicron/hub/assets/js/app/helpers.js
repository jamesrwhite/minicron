// Converts ANSI output to HTML spans with css classes
Ember.Handlebars.helper('ansi_to_html', function(value, options) {
  value = Handlebars.Utils.escapeExpression(value);
  value = ansi_up.ansi_to_html(value, { use_classes: true });

  return new Handlebars.SafeString(value);
});

// Returns how long ago a date was
// Taken from: https://github.com/tildeio/bloggr-client/blob/master/js/app.js
Ember.Handlebars.helper('format_date', function(date) {
  return moment(date).fromNow();
});