set_street_scoring_submitters = ->
  # update the displayed ranks

  $('.street_score').change ->
    current_row = $(this).parents("tr")
    current_row.addClass('score_changed');
    $(this).parents("form").submit()

update_all_scores = ->
  arr = all_scores()
  sorted = arr.slice().sort (a,b) ->
    b-a
  clean_sorted = []
  sorted.each (i) ->
    clean_sorted[i] = sorted[i]

  ranks = arr.slice().map (_, v) ->
    clean_sorted.indexOf(v) + 1
  $(".place").each (index, element) ->
    $(element).text(ranks[index])

$ ->
  set_street_scoring_submitters()
  update_all_scores()

  $('.street_score').change ->
    update_all_scores()

all_scores = ->
  $(".street_score").map (index, element) ->
    if $(element).val() != ""
      parseInt($(element).val(), 10)
    else
      0
