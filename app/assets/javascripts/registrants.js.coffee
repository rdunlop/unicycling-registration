# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(document).tooltip position:
    at: "left bottom-10"

$ ->
  $("#show-option").tooltip show:
    effect: "slideDown"
    delay: 250