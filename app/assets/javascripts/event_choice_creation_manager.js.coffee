# Display Blocks when a checkbox/radio is checked
# usage:
#  checkbox/radio element:
#    class: 'js--displayIfChecked'
#    data: 'displayblock' - the class of the target elements
#
# target element:
#    class: class matching the displayblock class

class @EventChoiceCreationManager

  constructor: (@form) ->
    @bindSources()
    @updateDisabledElements()

  bindSources: ->
    @form.on "change", "#event_choice_cell_type", =>
      @updateDisabledElements()

  updateDisabledElements: ->
    switch $("#event_choice_cell_type").val()
      when "boolean"
        @disableElements(true, true, true, true)
      when "multiple"
        @disableElements(false, false, false, false)
      when "text", "best_time"
        @disableElements(true, false, false, false)
      else
        @disableElements(false, false, false, false)

  disableElements: (multiple, optional, optional_if, required_if) ->
    $("#event_choice_multiple_values").attr("disabled", multiple)
    $("#event_choice_optional").attr("disabled", optional)
    $("#event_choice_optional_if_event_choice_id").attr("disabled", optional_if)
    $("#event_choice_required_if_event_choice_id").attr("disabled", required_if)

$ ->
  new EventChoiceCreationManager($(".js--eventChoiceForm"))
