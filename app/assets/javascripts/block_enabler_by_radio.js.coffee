# Enable Elements when a radio button is checked
# Also visually adjust the displays
#
# usage:
#  radio element:
#    class: 'js--disableByRadio'
#    data: 'disable_wrapper' - the class of the area to disable when selected
#    data: 'enable_wrapper' - the class of the area to enable when selected

class @BlockEnablerByRadio

  constructor: (@radio)->
    @bindSource()
    @enableDisable()

  enableTargetClass: ->
    @radio.data("enable-wrapper")

  disableTargetClass: ->
    @radio.data("disable-wrapper")

  enableTargetElements: ->
    $(".#{@enableTargetClass()}")

  disableTargetElements: ->
    $(".#{@disableTargetClass()}")

  bindSource: ->
    @radio.on "change", =>
      @enableDisable()

  # Initial setup
  enableDisable: ->
    if @radio.prop("checked")
      @enableElements(@enableTargetElements())
      @disableElements(@disableTargetElements())

      @enableInputs(@enableTargetElements())
      @disableInputs(@disableTargetElements())

  enableElements: (elements) ->
    elements.each ->
      $(this).removeClass("copy_choice--disabled")

  disableElements: (elements) ->
    elements.each ->
      $(this).addClass("copy_choice--disabled")

  enableInputs: (elements) ->
    elements.find("input, select").each ->
      $(this).attr("disabled", false)

  disableInputs: (elements) ->
    elements.find("input, select").each ->
      $(this).attr("disabled", true)

$ ->
  $(".js--disableByRadio").each (_, element) ->
    new BlockEnablerByRadio($(element))
