class @ChosenEnabler
  constructor: (@selects) ->
    @selects.select2
      placeholder: "Select an Option"
  oldconstructor: (@selects)->
    # enable chosen js
    @selects.chosen
      allow_single_deselect: true
      search_contains: true
      no_results_text: 'No matches'
      width: '200px'
