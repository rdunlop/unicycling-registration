/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on("click", "#unselect_all", () => select_all(false));

$(document).on("click", "#select_all", () => select_all(true));

var select_all = function(check_on) {
  $(".delete_payment_item").each(function() {
    const el = $(this);
    if (el.prop('checked') !== check_on) {
      return el.trigger("click");
    }
  });
  return false;
};

$(document).on("click", ".js--showOtherPaymentOptions", function() {
  $('.js--otherPaymentOptions').toggle("is--hidden");
  return false;
});
