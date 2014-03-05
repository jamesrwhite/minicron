window.Minicron = Ember.Application.create();

// This should be called by all views when they are loaded
Minicron.onViewLoad = function() {
  // Twitter tooltip plugin
  Ember.$('body').tooltip({
    selector: '[data-toggle=tooltip]',
    placement: 'right'
  });

  // Make the left and right panels the same height
  // var $main_panel = Ember.$('.main-panel');
  // var $sidebar = Ember.$('.sidebar');

  // console.log('before', $main_panel.height(), $sidebar.height());

  // if ($sidebar.height() > $main_panel.height()) {
  //   $main_panel.height($sidebar.height());
  // } else {
  //   $sidebar.height($main_panel.height());
  // }

  // console.log('after', $main_panel.height(), $sidebar.height());
};

// Configure Ember Data so it can find the API
Minicron.ApplicationAdapter = DS.ActiveModelAdapter.extend({
  namespace: 'api',
});
