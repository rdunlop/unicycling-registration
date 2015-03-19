# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $("table.alternate tr:even").css "background-color", "#f9f9f9"
  $("table.alternate tr:odd").css "background-color", "#e1e1e1"
  $("table.alternate th").css "background-color", "#fff"


calculateTotal = ->
  all_values = $("input[data-cents]");
  total_cents = 0;
  all_values.each ->
    el = $(this);
    if (el.prop('checked'))
      total_cents += parseInt(el.data("cents"));
  return (total_cents / 100).toFixed(2);

$(document).on "change", ".delete_payment_item", ->
  del = $(this);
  $("#total_field").html(calculateTotal());

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

$(document).ready ->
  #/ calculate initially
  $("#total_field").html(calculateTotal());
