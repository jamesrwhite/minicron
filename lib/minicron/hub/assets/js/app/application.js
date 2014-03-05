window.Minicron = Ember.Application.create();

// This should be called by all views when they are loaded
Minicron.onViewLoad = function() {
  // Twitter tooltip plugin
  Ember.$('body').tooltip({
    selector: '[data-toggle=tooltip]',
    placement: 'right'
  });
};

// Configure Ember Data so it can find the API
Minicron.ApplicationAdapter = DS.ActiveModelAdapter.extend({
  namespace: 'api',
});
