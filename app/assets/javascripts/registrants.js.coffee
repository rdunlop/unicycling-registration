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
    $(".display_new_registrant").hide()
    $(".js--display_new_registrant").click ->
        reg_type = $(this).data("registrantType")

        el = $(".display_new_registrant")
        el.removeClass(el.data('displaying'))
        el.addClass("show_#{reg_type}_elements")
        el.data("displaying", "show_#{reg_type}_elements")

        $(".display_new_registrant").show("blind", {easing: "easeOutBounce", direction: "up", duration: 1400})
        $("#registrant_registrant_type").val(reg_type)
        return false
    $(".js--hide_new_registrant").click ->
        $(".display_new_registrant").hide("blind", {easing: "easeOutBounce", direction: "up", duration: 1400})
        return false
