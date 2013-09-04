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

$ ->
  $(document).on "click", "#copy_address", ->
    $('#registrant_address').val($(this).data("address"));
    $('#registrant_city').val($(this).data("city"));
    $('#registrant_state').val($(this).data("state"));
    $('#registrant_country').val($(this).data("country"));
    $('#registrant_zip').val($(this).data("zip"));
    $('#registrant_phone').val($(this).data("phone"));
    return false;

$(document).ready ->
  $(".fancybox").fancybox
    type: "iframe"
    maxWidth: 800
    maxHeight: 600
    width: "70%"
    height: "70%"
    autoSize: false
    closeClick: false
    openEffect: "none"
    closeEffect: "none"