# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on "click", "#show_hide_admin_payments_other_new", ->
  $('#admin_payments_other_new').toggle();
