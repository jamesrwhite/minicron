Ember.Handlebars.helper('ansi_to_html', function(value, options) {
  value = Handlebars.Utils.escapeExpression(value);
  value = ansi_up.ansi_to_html(value, { use_classes: true });

  return new Handlebars.SafeString(value);
});