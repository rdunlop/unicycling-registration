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

$ ->
  # enable chosen js
  $('.chosen-select').chosen
    allow_single_deselect: true
    search_contains: true
    no_results_text: 'No matches'
    width: '200px'


# Highlights pairs/sets of data which are not all matching
$ ->
  $(".js--highlightMatching").each ->
    all_children = $(this).find(".js--shouldMatch")
    first_value = $(all_children[0]).text()
    all_match = true;
    all_children.each ->
      if $(this).text() != first_value
        all_match = false
    all_children.each ->
      if all_match
        $(this).addClass('matching')
      else
        $(this).addClass('unmatching')
