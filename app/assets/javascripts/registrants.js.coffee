$ ->
  $("[title]").filter(":not(.select2-selection__rendered)").tooltip
    position:
      at: "left bottom-10"

$ ->
  $("#show-option").tooltip show:
    effect: "slideDown"
    delay: 250

$ ->
  $(document).on "click", "#copy_address", ->
    $('#registrant_contact_detail_attributes_address').val($(this).data("address"));
    $('#registrant_contact_detail_attributes_city').val($(this).data("city"));
    $('#registrant_contact_detail_attributes_country').val($(this).data("country"));
    $('#registrant_contact_detail_attributes_zip').val($(this).data("zip"));
    $('#registrant_contact_detail_attributes_phone').val($(this).data("phone"));
    $('#registrant_contact_detail_attributes_country_residence').val($(this).data("country-residence"));
    $('#registrant_contact_detail_attributes_country_representing').val($(this).data("country-representing"));

    # store the state so that the ajax callback can select the correct state
    $('select#registrant_contact_detail_attributes_country_residence').data("state-to-be", $(this).data("state"));

    $('select#registrant_contact_detail_attributes_country_residence').trigger("change");
    $('select#registrant_contact_detail_attributes_country_representing').trigger('change');
    return false;

$(document).ready ->
  $('input, textarea').placeholder()

$ ->
  $(".js--display_new_registrant").click ->
    reg_type = $(this).data("registrantType")

    el = $(".display_new_registrant")
    el.removeClass(el.data('displaying'))
    el.addClass("show_#{reg_type}_elements")
    el.data("displaying", "show_#{reg_type}_elements")

    # jQuery UI blind Effect animation
    $(".display_new_registrant").show("blind", {easing: "easeOutBounce", direction: "up", duration: 1400})
    $("#registrant_registrant_type").val(reg_type)
    top_pos = el.offset().top
    $('body').animate({scrollTop:top_pos}, 600)
    return false
  $(".js--hide_new_registrant").click ->
    $(".display_new_registrant").hide("blind", {easing: "easeOutBounce", direction: "up", duration: 1400})
    return false

$ ->
  $('select#registrant_contact_detail_attributes_country_residence').change (event) ->
    select_wrapper = $('#registrant_contact_detail_attributes_state_wrapper')

    $('select', select_wrapper).attr('disabled', true)

    country_residence = $(this).val()

    url = "/registrants/subregion_options?parent_region=#{country_residence}"
    select_wrapper.load url, ->
      new ChosenEnabler($(".chosen-select"))
      state = $('select#registrant_contact_detail_attributes_country_residence').data("state-to-be");
      if state != undefined
        $('#registrant_contact_detail_attributes_state_code').val(state);
        $('select#registrant_contact_detail_attributes_state_code').trigger("change");
