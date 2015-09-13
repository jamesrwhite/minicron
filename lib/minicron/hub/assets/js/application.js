'use strict';

// Set up the global Minicron object
window.Minicron = {};

$(function() {
  // Twitter tooltip plugin
  $('body').tooltip({
    selector: '[data-toggle=tooltip]'
  });

  // Set up our fancy scrollbars
  var $sidebar = $('.sidebar'),
      $main_panel = $('.main-panel');

  if ($sidebar.length && $main_panel.length) {
    // Sidebar perfect scrollbar init
    $sidebar.perfectScrollbar();

    // Main Panel perfect scrollbar init
    $main_panel.perfectScrollbar();
    $main_panel.scrollTop(0);
    $main_panel.perfectScrollbar('update');
  }
});
