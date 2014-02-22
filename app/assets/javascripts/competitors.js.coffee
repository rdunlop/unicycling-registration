# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on "click", "#competitor_unselect_all", ->
    select_all_competitors(false);

$(document).on "click", "#competitor_select_all", ->
    select_all_competitors(true);

select_all_competitors = (check_on) ->
  $(".registrant_checkbox").each ->
    el = $(this);
    if (el.prop('checked') != check_on)
      el.trigger("click");
  return false
