# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $("table.alternate tr:even").css "background-color", "#f9f9f9"
  $("table.alternate tr:odd").css "background-color", "#e1e1e1"
  $("table.alternate th").css "background-color", "#fff"


findDeleteCheck = (el) ->
  row = el.parent().parent();
  del = row.find("input[type='checkbox']").first();
  return del;

calculateTotal = ->
  all_values = $("input[data-cents]");
  total_cents = 0;
  all_values.each ->
    el = $(this);
    if (el.prop('checked')) 
      total_cents += parseInt(el.data("cents"));
  return (total_cents / 100).toFixed(2);

payment_submit_text = null

$(document).on "change", ".anon", ->
  el = $(this);
  del = findDeleteCheck(el);
  del.prop('checked', !el.prop('checked'));
  $("#total_field").html(calculateTotal());
  #/ change and disable payment button if no payment items are selected
  if calculateTotal() is "0.00"
    $("form").click ->
      $("#payment_submit", this)[0].disabled = true
      $("#payment_submit", this)[0].value = "Select an item..."
  else
    $("form").click ->
      $("#payment_submit", this)[0].disabled = false
      $("#payment_submit", this)[0].value = payment_submit_text

$(document).on "click", "#unselect_all", ->
    select_all(false);

$(document).on "click", "#select_all", ->
    select_all(true);

select_all = (check_on) ->
  $(".anon").each ->
    el = $(this);
    if (el.prop('checked') != check_on)
      el.trigger("click");
  return false

$(document).ready ->
  payment_submit_text = $("#payment_submit")[0].value
  #/ calculate initially
  $("#total_field").html(calculateTotal());
  #/ change and disable payment button if no payment items exist
  all_values = $("input[data-cents]");
  if all_values.length is 0
    $("form").ready ->
      $("#payment_submit", this)[0].disabled = true
      $("#payment_submit", this)[0].value = "No items..."

