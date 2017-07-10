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

$(document).on "click", ".reg_group_select", (e) ->
  el = $(e.target)
  ids = el.data("registrant-ids")
  select_all_competitors(false);
  select_group_competitors(ids)

select_group_competitors = (reg_ids) ->
  count = 0
  $(".registrant_checkbox").each ->
    el = $(this);
    reg_id = parseInt(el.val())
    if (reg_ids.includes(reg_id))
      el.trigger("click");
      count += 1
  alert("selected " + count + " members")
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
      $("." + $(this).data("hide-target")).hide()

$ ->
    $(".js--autoFocus").each ->
      $(@).select2('open');
