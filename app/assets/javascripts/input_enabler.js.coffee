# Enable Elements when a checkbox is checked
# usage:
#  checkbox element:
#    class: 'js--inputEnable'
#    data: 'targets' - the class of the target elements
#
# target element:
#    class: class matching the targets class

class @InputEnabler

  constructor: (@checkbox)->
    @bindSource()
    @enableDisable()

  targetClass: ->
    @checkbox.data("targets")

  targetElements: ->
    $(".#{@targetClass()}")

  bindSource: ->
    @checkbox.on "change", =>
      console.log "Hi"
      @enableDisable()

  enableDisable: ->
    if @checkbox.prop("checked")
      @targetElements().each ->
        $(this).attr("disabled", false)
    else
      @targetElements().each ->
        $(this).attr("disabled", true)

$ ->
  $(".js--inputEnable").each (_, element) ->
    new InputEnabler($(element))
