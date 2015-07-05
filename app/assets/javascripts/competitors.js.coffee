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
  new ChosenEnabler($(".chosen-select"))

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


$ ->
  $(".js--hiddenToggle").hide()
  $(".js--hiddenToggleMenu").each ->
    $(this).on "click", ->
      $(".js--hiddenToggle").toggle()
      return false

$ ->
  $(".js--shouldNotMatchSet").each ->
    all_children = $(this).find(".js--shouldNotMatch")

    all_children.each ->
      match_count = 0
      child_value = $(this).text()
      all_children.each ->
        if $(this).text() == child_value
          match_count += 1
      if match_count > 1
        all_children.each ->
          if $(this).text() == child_value
            $(this).addClass('sameValue')


show_element = (target) ->
  return $(".js--showElement[data-key='" + target + "']").length

$ ->
  $(".js--showElementTarget").each ->
    target = $(this)
    if (!show_element(target.data("key")))
      target.hide()

$ ->
  $(".js--highlightIfBlank").each ->
    if $(this).text() == ""
      $(this).addClass('unmatching')

$ ->
  $(".js--highlightIfNotBlank").each ->
    if $(this).text() != ""
      $(this).addClass('unmatching')

$ ->
  $(".js--hideElementIfEmpty").each ->
    if $(this).children().size() == 0
      console.log "hiding"
      $("." + $(this).data("hide-target")).hide()

$ ->
  $(".js--autoFocus").trigger('chosen:activate');
