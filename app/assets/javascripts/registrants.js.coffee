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
    $('#registrant_contact_detail_attributes_address').val($(this).data("address"));
    $('#registrant_contact_detail_attributes_city').val($(this).data("city"));
    $('#registrant_contact_detail_attributes_state').val($(this).data("state"));
    $('#registrant_contact_detail_attributes_country').val($(this).data("country"));
    $('#registrant_contact_detail_attributes_zip').val($(this).data("zip"));
    $('#registrant_contact_detail_attributes_phone').val($(this).data("phone"));
    $('#registrant_contact_detail_attributes_country_residence').val($(this).data("country-residence"));
    $('#registrant_contact_detail_attributes_country_representing').val($(this).data("country-representing"));
    return false;

$(document).ready ->
  $('input, textarea').placeholder()
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

$ ->
    $("#registrant_birthday_1i").focusout ->
      show_hide_wheel_size()

$(document).ready ->
    show_hide_wheel_size()

show_hide_wheel_size = ->
  current_year = parseInt($("#registrant_birthday_1i option:last-child").val(), 10)
  birthday_year = parseInt($("#registrant_birthday_1i").val(), 10)
  # To account for month-to-month differences, subtract 11 instead of 10
  if( birthday_year < current_year - 10 - 1)
    # disable the option to select your wheel size
    $("#registrant_wheel_size_id").val(3) # 24" Wheel Size
    $("#registrant_wheel_size_id").hide()
    $("registrant_wheel_size_constant").show()
  else
    $("#registrant_wheel_size_id").show()
    $("registrant_wheel_size_constant").hide()
