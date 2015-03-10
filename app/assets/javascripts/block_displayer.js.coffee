# Display Blocks when a checkbox/radio is checked
# usage:
#  checkbox/radio element:
#    class: 'js--displayIfChecked'
#    data: 'displayblock' - the class of the target elements
#
# target element:
#    class: class matching the displayblock class

class @BlockDisplayer

  constructor: (@radioElements) ->
    @bindSources()
    @displayHideAll()

  bindSources: ->
    @radioElements.on "change", =>
      @displayHideAll()

  displayHideAll: ->
    @radioElements.each (_, el) =>
      @displayHide($(el))

  displayHide: (radioElement) ->
    blockElement = $("." + $(radioElement).data("displayblock"))
    if radioElement.prop("checked")
      blockElement.show()
    else
      blockElement.hide()

$ ->
  new BlockDisplayer($(".js--displayIfChecked"))
