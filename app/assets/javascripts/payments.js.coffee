# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on "click", "#unselect_all", ->
    select_all(false);

$(document).on "click", "#select_all", ->
    select_all(true);

select_all = (check_on) ->
  $(".delete_payment_item").each ->
    el = $(this);
    if (el.prop('checked') != check_on)
      el.trigger("click");
  return false

$(document).on "click", ".js--showOtherPaymentOptions", ->
  $('.js--otherPaymentOptions').toggle("is--hidden");
  return false;
