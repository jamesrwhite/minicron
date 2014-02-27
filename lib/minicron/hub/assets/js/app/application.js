window.Minicron = Ember.Application.create();

// JavaScript Plugins
$(function(){
  $('body').tooltip({
    selector: '[data-toggle=tooltip]',
    placement: 'right'
  });
});